#!/usr/bin/env bash
# The dependency-free YAML subset reader (lib/miniyaml.py).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# py <name> <expected-json> <yaml-text> — parse and compare as JSON.
py() {
  local name="$1" expected="$2" text="$3" got
  got=$(YAML_TEXT="$text" python3 - "$REPO_ROOT/.codepress/system/lib" <<'PYEOF'
import json, os, sys
sys.path.insert(0, sys.argv[1])
import miniyaml
print(json.dumps(miniyaml.loads(os.environ["YAML_TEXT"]), sort_keys=True))
PYEOF
  ) || got="ERROR"
  eq "$name" "$got" "$expected"
}

py_raises() {
  local name="$1" text="$2" rc=0
  YAML_TEXT="$text" python3 - "$REPO_ROOT/.codepress/system/lib" >/dev/null 2>&1 <<'PYEOF' || rc=$?
import os, sys
sys.path.insert(0, sys.argv[1])
import miniyaml
try:
    miniyaml.loads(os.environ["YAML_TEXT"])
except miniyaml.YamlError:
    sys.exit(0)
sys.exit(1)
PYEOF
  if [[ "$rc" -eq 0 ]]; then pass "$name"; else fail "$name"; fi
}

py "mapping with scalars" '{"a": 1, "b": "two", "c": true, "d": false, "e": 1.5}' $'a: 1\nb: two\nc: true\nd: false\ne: 1.5'
py "empty value is null" '{"a": null, "b": 1}' $'a:\nb: 1'
py "nested mapping" '{"x": {"y": {"z": 3}}}' $'x:\n  y:\n    z: 3'
py "block list of scalars" '{"l": ["a", "b"]}' $'l:\n  - a\n  - b'
py "list at the same indent as its key" '{"l": ["a", "b"]}' $'l:\n- a\n- b'
py "list of mappings" '{"l": [{"from": "a", "to": "b"}, {"from": "c", "n": 1, "to": "d"}]}' $'l:\n  - from: a\n    to: b\n  - from: c\n    to: d\n    n: 1'
py "flow list" '{"v": ["a", "b", "c"]}' 'v: [a, b, c]'
py "empty flow list" '{"v": []}' 'v: []'
py "flow map" '{"m": {"k": "v", "n": 2}}' 'm: {k: v, n: 2}'
py "quoted comma survives in flow list" '{"v": ["a, b", "c"]}' 'v: ["a, b", c]'
py "trailing comment is stripped" '{"a": 1}' 'a: 1   # a comment'
py "hash inside quotes is kept" '{"a": "x # y"}' 'a: "x # y"'
py "hash without leading space is kept" '{"a": "x#y"}' 'a: x#y'
py "comment-only and blank lines are ignored" '{"a": 1, "b": 2}' $'# top\n\na: 1\n\n  # indented comment\nb: 2'
py "value containing a colon" '{"url": "http://x.test/a"}' 'url: http://x.test/a'
py "key containing an arrow" '{"proposed->shaped": {"requires": ["a"]}}' $'proposed->shaped:\n  requires: [a]'
py "quoted key" '{"a b": 1}' '"a b": 1'
py "folded block scalar joins lines" '{"s": "one two"}' $'s: >\n  one\n  two'
py "literal block scalar keeps newlines" '{"s": "one\ntwo"}' $'s: |\n  one\n  two'
py "single-quoted string keeps backslashes" '{"p": "\\d+"}' "p: '\\d+'"
py "negative integer" '{"n": -3}' 'n: -3'
py "empty document is an empty mapping" '{}' ''
py "keys after a nested block return to the parent" '{"a": {"b": 1}, "c": 2}' $'a:\n  b: 1\nc: 2'

py_raises "tab indentation is rejected" $'a:\n\tb: 1'
py_raises "a bare word line is rejected" $'a: 1\njust text'
py_raises "unterminated flow list is rejected" 'a: [1, 2'
py_raises "stray indentation is rejected" $'a: 1\n    b: 2'

# frontmatter ------------------------------------------------------------------

fm=$(python3 - "$REPO_ROOT/.codepress/system/lib" <<'PYEOF'
import json, sys
sys.path.insert(0, sys.argv[1])
import miniyaml
fm, body = miniyaml.frontmatter("---\nid: x\nstatus: building\nbudget:\n  tokens:\n---\n\n# Title\n")
print(json.dumps(fm, sort_keys=True), "|", body.strip())
PYEOF
)
eq "frontmatter splits data from body" "$fm" '{"budget": {"tokens": null}, "id": "x", "status": "building"} | # Title'

nofm=$(python3 - "$REPO_ROOT/.codepress/system/lib" <<'PYEOF'
import sys
sys.path.insert(0, sys.argv[1])
import miniyaml
print(miniyaml.frontmatter("# just a heading\n")[0])
PYEOF
)
eq "a file without frontmatter yields {}" "$nofm" "{}"

# every real artefact in this repo parses
bad=$(python3 - "$REPO_ROOT" <<'PYEOF'
import glob, os, sys
sys.path.insert(0, os.path.join(sys.argv[1], ".codepress/system/lib"))
import miniyaml
bad = []
for f in glob.glob(os.path.join(sys.argv[1], ".codepress/**/*.md"), recursive=True):
    try:
        miniyaml.frontmatter(open(f, encoding="utf-8").read())
    except miniyaml.YamlError as e:
        bad.append("%s: %s" % (f, e))
print("\n".join(bad))
PYEOF
)
eq "every .codepress/**/*.md frontmatter in this repo parses" "$bad" ""

summary
