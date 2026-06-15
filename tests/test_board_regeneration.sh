#!/usr/bin/env bash
# Tests for codepress board regeneration (regenerate_boards via codepress status)
set -euo pipefail

CODEPRESS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/codepress"
PASS=0
FAIL=0

pass() { echo "PASS  $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL  $1"; FAIL=$((FAIL + 1)); }

# ── Setup helpers ────────────────────────────────────────────────────────────

mk_project() {
  local d
  d=$(mktemp -d)
  mkdir -p "$d/.codepress/system"
  mkdir -p "$d/.codepress/product/initiatives"
  mkdir -p "$d/.codepress/product/galleys"
  mkdir -p "$d/.codepress/product/releases"
  mkdir -p "$d/.codepress/knowledge/patterns"
  mkdir -p "$d/.codepress/knowledge/signals"
  mkdir -p "$d/.codepress/knowledge/decisions"
  mkdir -p "$d/.codepress/views"
  echo "codepress-version: 0.2.0" > "$d/.codepress/system/codepress.md"
  echo "$d"
}

mk_galley() {
  local dir="$1" name="$2" status="$3"
  mkdir -p "$dir/.codepress/product/galleys/$name/slugs"
  cat > "$dir/.codepress/product/galleys/$name/galley.md" <<EOF
---
id: $name
status: $status
---
# Galley: $name
EOF
}

run_status() {
  local dir="$1"
  (cd "$dir" && "$CODEPRESS" status 2>/dev/null) || true
}

# ── Test 1: shaping galley appears in Shaping column ─────────────────────────

T="galley with status shaping → appears in Shaping column of board"
d=$(mk_project)
mk_galley "$d" "alpha" "shaping"
run_status "$d" > /dev/null
board="$d/.codepress/views/galley-board.md"
if [[ -f "$board" ]] && grep -q "## Shaping" "$board" && grep -q "alpha" "$board"; then
  pass "$T"
else
  fail "$T"
  [[ -f "$board" ]] && echo "      board content:" && cat "$board" || echo "      board file not created"
fi
rm -rf "$d"

# ── Test 2: delivering galley appears in Delivering column ───────────────────

T="galley with status delivering → appears in Delivering column of board"
d=$(mk_project)
mk_galley "$d" "beta" "delivering"
run_status "$d" > /dev/null
board="$d/.codepress/views/galley-board.md"
if [[ -f "$board" ]] && grep -q "## Delivering" "$board" && grep -q "beta" "$board"; then
  pass "$T"
else
  fail "$T"
  [[ -f "$board" ]] && echo "      board content:" && cat "$board" || echo "      board file not created"
fi
rm -rf "$d"

# ── Test 3: board file is created when it doesn't exist ──────────────────────

T="board file is created when views/galley-board.md does not exist"
d=$(mk_project)
rm -f "$d/.codepress/views/galley-board.md"
mk_galley "$d" "gamma" "approved"
run_status "$d" > /dev/null
if [[ -f "$d/.codepress/views/galley-board.md" ]]; then
  pass "$T"
else
  fail "$T"
  echo "      board file was not created"
fi
rm -rf "$d"

# ── Test 4: board is updated when it already exists ──────────────────────────

T="board file is updated when it already exists with stale content"
d=$(mk_project)
echo "## Stale content" > "$d/.codepress/views/galley-board.md"
mk_galley "$d" "delta" "review"
run_status "$d" > /dev/null
board="$d/.codepress/views/galley-board.md"
if [[ -f "$board" ]] && grep -q "## Review" "$board" && grep -q "delta" "$board"; then
  pass "$T"
else
  fail "$T"
  [[ -f "$board" ]] && echo "      board content:" && cat "$board"
fi
rm -rf "$d"

# ── Test 5: done galley appears in Done column ────────────────────────────────

T="galley with status done → appears in Done column of board"
d=$(mk_project)
mk_galley "$d" "epsilon" "done"
run_status "$d" > /dev/null
board="$d/.codepress/views/galley-board.md"
if [[ -f "$board" ]] && grep -q "## Done" "$board" && grep -q "epsilon" "$board"; then
  pass "$T"
else
  fail "$T"
  [[ -f "$board" ]] && echo "      board content:" && cat "$board" || echo "      board file not created"
fi
rm -rf "$d"

# ── Test 6: galley move triggers board update ─────────────────────────────────

T="codepress galley move triggers board regeneration"
d=$(mk_project)
mk_galley "$d" "zeta" "shaping"
(cd "$d" && "$CODEPRESS" galley move zeta approved 2>/dev/null)
board="$d/.codepress/views/galley-board.md"
if [[ -f "$board" ]] && grep -q "## Approved" "$board" && grep -q "zeta" "$board"; then
  pass "$T"
else
  fail "$T"
  [[ -f "$board" ]] && echo "      board content:" && cat "$board" || echo "      board file not created"
fi
rm -rf "$d"

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
