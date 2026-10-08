#!/usr/bin/env bash
# lint.py re-implements the CLI's extract_acs (awk). Both must read every file
# the same way, or `codepress check` and `codepress lint` would disagree.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

parity() {
  local name="$1" file="$2" a b
  a=$(cd "$REPO_ROOT" && "$CODEPRESS" __extract-acs "$file" 2>&1) || a="ERR"
  b=$(python3 "$LINT" acs "$file" 2>&1) || b="ERR"
  eq "$name" "$b" "$a"
}

f=$(mktemp); CLEANUP+=("$f")

cat > "$f" <<'EOF'
# Galley

## Acceptance Criteria

- [ ] AC1 · Given x · When y · Then z · test: tests/t.sh::test_one
- [x] AC2 · check: bash tests/run_tests.sh
- [ ] AC3 · manual: confirm DNS
- [X] AC4 · manual: ticked by mistake
- [ ] plain prose criterion
- [x] another legacy one · with a middot but no marker
EOF
parity "all four kinds, ticked and unticked" "$f"
eq "…and the shape is what we think" "$(python3 "$LINT" acs "$f" | awk -F'|' '{printf "%s:%s:%s ", $1, $2, $4}')" "AC1:test:0 AC2:check:1 AC3:manual:0 AC4:manual:1 :legacy:0 :legacy:1 "

cat > "$f" <<'EOF'
## Acceptance
- [ ] AC1 · check: echo a · test: x
- [ ] AC2 · test: t.sh::n · check: echo b
- [ ]  AC3 · manual: two spaces after the box
-[ ] not a checkbox line
- [] also not
  - [ ] indented, not top-level
- [ ] trailing spaces here    
EOF
parity "first-marker wins, odd spacing, non-matching lines" "$f"

cat > "$f" <<'EOF'
## Problem
- [ ] ignored: outside the acceptance section

## Acceptance Criteria
- [ ] AC1 · check: true

## Notes
- [ ] ignored: after the section

## Acceptance checklist
- [ ] AC9 · check: true
EOF
parity "only checkboxes inside '## Acceptance*' sections count (several sections allowed)" "$f"

cat > "$f" <<'EOF'
- [ ] AC1 · check: true
EOF
parity "a file with no acceptance section yields nothing" "$f"

cat > "$f" <<'EOF'
## Acceptance Criteria
- [ ] AC1 · check: grep -q 'a|b' file
EOF
parity "payloads with shell metacharacters survive (pipes aside)" "$f"

# every real galley and slug in this repo parses identically
mismatch=0
for g in "$REPO_ROOT"/.codepress/product/galleys/*/galley.md "$REPO_ROOT"/.codepress/product/galleys/*/slugs/*.md; do
  a=$(cd "$REPO_ROOT" && "$CODEPRESS" __extract-acs "$g" 2>&1) || a="ERR"
  b=$(python3 "$LINT" acs "$g" 2>&1) || b="ERR"
  if [[ "$a" != "$b" ]]; then mismatch=$((mismatch + 1)); echo "      differs: $g"; fi
done
eq "every galley and slug in this repo parses identically in bash and python" "$mismatch" "0"

summary
