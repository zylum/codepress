#!/usr/bin/env bash
# Tests for the extract_acs helper (acceptance-binding-format slug).
# Emits id|kind|payload|ticked per checkbox line in the "## Acceptance" section.
set -euo pipefail

CODEPRESS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/codepress"
PASS=0
FAIL=0

pass() { echo "PASS  $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL  $1"; FAIL=$((FAIL + 1)); }

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    pass "$label"
  else
    fail "$label"
    echo "      expected: $expected"
    echo "      actual:   $actual"
  fi
}

# ── Fixture: galley with all three kinds + legacy + ticked lines ─────────────

d=$(mktemp -d)
fixture="$d/galley.md"
cat > "$fixture" <<'EOF'
---
id: fixture
status: delivering
verify: [test]
---

# Galley: fixture

## Problem
Not relevant to the parse.

- [ ] this checkbox is OUTSIDE the acceptance section and must be ignored

## Acceptance Criteria

- [ ] AC1 · Given a logged-in user · When the session expires · Then re-auth is required · test: tests/test_auth.sh::test_session_expiry
- [ ] AC2 · check: bash tests/run_tests.sh
- [x] AC3 · manual: rotate the production API key
- [ ] the app feels fast
- [x] AC4 · Given data · When parsed · Then stored · test: tests/test_store.sh::test_roundtrip

## Notes
- [ ] also outside — not an AC
EOF

out=$("$CODEPRESS" __extract-acs "$fixture")

# ── Test 1: only the acceptance section is parsed ─────────────────────────────
assert_eq "emits exactly the 5 AC lines (sections outside ## Acceptance ignored)" \
  "5" "$(echo "$out" | grep -c '' | tr -d ' ')"

# ── Test 2: GWT + test: line ──────────────────────────────────────────────────
assert_eq "test-kind: GWT line binds to its test ref" \
  "AC1|test|tests/test_auth.sh::test_session_expiry|0" \
  "$(echo "$out" | sed -n '1p')"

# ── Test 3: check: line ───────────────────────────────────────────────────────
assert_eq "check-kind: payload is the shell command" \
  "AC2|check|bash tests/run_tests.sh|0" \
  "$(echo "$out" | sed -n '2p')"

# ── Test 4: manual: line, ticked ──────────────────────────────────────────────
assert_eq "manual-kind: ticked [x] reported as ticked=1" \
  "AC3|manual|rotate the production API key|1" \
  "$(echo "$out" | sed -n '3p')"

# ── Test 5: legacy unbound prose line ─────────────────────────────────────────
assert_eq "legacy-kind: unbound prose line has empty id, kind=legacy" \
  "|legacy|the app feels fast|0" \
  "$(echo "$out" | sed -n '4p')"

# ── Test 6: ticked test line ──────────────────────────────────────────────────
assert_eq "test-kind: ticked [x] reported as ticked=1" \
  "AC4|test|tests/test_store.sh::test_roundtrip|1" \
  "$(echo "$out" | sed -n '5p')"

# ── Test 7: slug-style "## Acceptance checklist" section also parses ─────────

slug_fixture="$d/slug.md"
cat > "$slug_fixture" <<'EOF'
---
id: some-slug
status: open
---

# Slug: some-slug

## Acceptance checklist
- [ ] AC1 · check: true
- [ ] AC2 · manual: confirm the DNS cutover

## Context
Irrelevant.
EOF

out2=$("$CODEPRESS" __extract-acs "$slug_fixture")
assert_eq "slug 'Acceptance checklist' section parses with the same grammar" \
  "AC1|check|true|0
AC2|manual|confirm the DNS cutover|0" \
  "$out2"

# ── Test 8: missing file → non-zero exit ─────────────────────────────────────
T="missing file → non-zero exit"
if "$CODEPRESS" __extract-acs "$d/nope.md" 2>/dev/null; then
  fail "$T"
else
  pass "$T"
fi

rm -rf "$d"

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
