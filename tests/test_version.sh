#!/usr/bin/env bash
# One source of truth for the version, and drift in a project's markers is detectable.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

marker=$(sed -n 's/^codepress-version: *//p' "$REPO_ROOT/.codepress/system/codepress.md" | head -1)
assert "the bundled marker is a real version" bash -c "[[ '$marker' =~ ^[0-9]+\.[0-9]+\.[0-9]+\$ ]]"
eq "the CLI reports the bundled marker's version" "$(cd "$REPO_ROOT" && "$CODEPRESS" version | head -1)" "codepress v$marker"
eq "…also via --version" "$("$CODEPRESS" --version | head -1)" "codepress v$marker"
has "…and in the usage banner" "$("$CODEPRESS" --help | head -1)" "CodePress v$marker"
lacks "the CLI carries no hard-coded version literal" "$(grep -n '^VERSION="[0-9]' "$CODEPRESS" || true)" "VERSION"

# the marker lives in exactly one file of this repo's system dir
count=$( (grep -l '^codepress-version:' "$REPO_ROOT"/.codepress/system/*.md 2>/dev/null || true) | wc -l | tr -d ' ')
eq "exactly one file carries the marker" "$count" "1"

d=$(mk_project)
cp_run "$d" version
has "version shows the project marker beside the CLI's" "$OUT" "project marker: v$CP_VERSION"

# a copy of the CLI without a bundle says so rather than inventing a number
solo=$(mktemp -d); CLEANUP+=("$solo")
cp "$CODEPRESS" "$solo/codepress"
eq "a standalone CLI copy reports 'unknown' honestly" "$("$solo/codepress" version | head -1)" "codepress vunknown"

# the Loom-style mismatch: one project, two different markers
d=$(mk_project)
echo "codepress-version: 0.1.0" > "$d/.codepress/system/config.md"
echo "codepress-version: 0.2.0" > "$d/.codepress/system/codepress.md"
lint_run "$d" --base none
eq "lint catches a project whose markers disagree (0.1.0 vs 0.2.0)" "$RC" "1"
has "…naming both files and their versions" "$OUT" ".codepress/system/codepress.md says 0.2.0; .codepress/system/config.md says 0.1.0"

# ── upgrade keeps ONE marker, and does not clobber project config ─────────────

src=$(mktemp -d); CLEANUP+=("$src")
mkdir -p "$src/.codepress"
cp -r "$REPO_ROOT/.codepress/system" "$src/.codepress/system"
python3 - "$src/.codepress/system/codepress.md" <<'PYEOF2'
import re, sys
p = sys.argv[1]
s = open(p).read()
open(p, "w").write(re.sub(r"(?m)^codepress-version:.*$", "codepress-version: 9.9.9", s, count=1))
PYEOF2
(cd "$src" && git init -q && git config user.email t@e.com && git config user.name T && git add -A && git commit -q -m src)

d=$(mk_project)
cat > "$d/.codepress/system/codepress.md" <<EOF
codepress-version: 0.1.0
codepress-source: $src

name: my project
custom-setting: keep-me
EOF
echo "codepress-version: 0.1.0" > "$d/.codepress/system/config.md"
RC=0; OUT=$(cd "$d" && echo y | "$CODEPRESS" upgrade 2>&1) || RC=$?
eq "upgrade runs against a local source" "$RC" "0"
has "…reaching the new version" "$OUT" "Upgraded from v0.1.0 to v9.9.9"
has "project-owned codepress.md keeps its content" "$(cat "$d/.codepress/system/codepress.md")" "custom-setting: keep-me"
has "…and its marker moved" "$(cat "$d/.codepress/system/codepress.md")" "codepress-version: 9.9.9"
eq "a leftover config.md marker is brought along (no more 0.1.0 vs 0.2.0)" "$(sed -n 's/^codepress-version: *//p' "$d/.codepress/system/config.md")" "9.9.9"
assert "the lint engine is installed by upgrade" test -f "$d/.codepress/system/lib/lint.py"
assert "…and the schema" test -f "$d/.codepress/system/schema/lifecycle.yaml"
lint_run "$d" --base none
lacks "after an upgrade the markers do not disagree" "$OUT" "V001"
has "…but the duplicate is called out for cleanup" "$OUT" "V002"

summary
