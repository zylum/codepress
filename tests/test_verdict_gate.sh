#!/usr/bin/env bash
# Tests for the verifier-verdict gate on `codepress galley move <g> done`
# and the --force waiver trail (verifier-verdict-gate slug). Test function
# names match the `test:` refs in the enforced-acceptance galley.
set -euo pipefail

CODEPRESS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/codepress"
PASS=0
FAIL=0

pass() { echo "PASS  $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL  $1"; FAIL=$((FAIL + 1)); }

# ── Fixture helpers ───────────────────────────────────────────────────────────

mk_project() {
  local d
  d=$(mktemp -d)
  mkdir -p "$d/.codepress/system"
  mkdir -p "$d/.codepress/product/galleys"
  mkdir -p "$d/.codepress/views"
  cat > "$d/.codepress/system/codepress.md" <<'EOF'
codepress-version: 0.5.0

engines:
  build: opencode
  verifier: claude
EOF
  echo "$d"
}

# All-green galley (single check: true AC) in review status, signals filled.
mk_green_galley() {
  local dir="$1" name="$2"
  mkdir -p "$dir/.codepress/product/galleys/$name/slugs"
  cat > "$dir/.codepress/product/galleys/$name/galley.md" <<EOF
---
id: $name
status: review
---

# Galley: $name

## Acceptance Criteria

- [ ] AC1 · check: true
- [ ] AC2 · check: true
EOF
}

# mk_review <dir> <name> <verdict-content> — verdict block content from arg
mk_review() {
  local dir="$1" name="$2" verdict="${3:-}"
  cat > "$dir/.codepress/product/galleys/$name/review.md" <<EOF
# Review: $name

## Signals
- a real observation

## Verdict
$verdict
EOF
}

galley_status() {
  grep -m1 '^status:' "$1/.codepress/product/galleys/$2/galley.md" | sed 's/status: *//'
}

try_move_done() {
  local d="$1" name="$2"
  shift 2
  set +e
  MOVE_OUT=$(cd "$d" && "$CODEPRESS" galley move "$name" done "$@" 2>&1)
  MOVE_RC=$?
  set -e
}

# ── AC5: done requires a complete, independent verdict ───────────────────────

test_done_requires_independent_verdict() {
  local T d

  # (a) no Verdict block at all → refused
  T="move to done refused when review.md has no Verdict block"
  d=$(mk_project)
  mk_green_galley "$d" "gv"
  mk_review "$d" "gv" ""
  try_move_done "$d" "gv"
  if [[ "$MOVE_RC" -ne 0 ]] && echo "$MOVE_OUT" | grep -qi "verdict" && [[ "$(galley_status "$d" gv)" == "review" ]]; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$MOVE_RC output: $MOVE_OUT"
  fi
  rm -rf "$d"

  # (b) verified-by equals engines.build → refused (self-certification)
  T="move to done refused when verified-by equals engines.build"
  d=$(mk_project)
  mk_green_galley "$d" "gv"
  mk_review "$d" "gv" "AC1: pass — check exited 0
AC2: pass — check exited 0
verified-by: opencode
verified-on: 2026-07-11"
  try_move_done "$d" "gv"
  if [[ "$MOVE_RC" -ne 0 ]] && echo "$MOVE_OUT" | grep -q "equals engines.build"; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$MOVE_RC output: $MOVE_OUT"
  fi
  rm -rf "$d"

  # (c) a failing AC verdict → refused
  T="move to done refused when any AC is verdicted fail"
  d=$(mk_project)
  mk_green_galley "$d" "gv"
  mk_review "$d" "gv" "AC1: pass — check exited 0
AC2: fail — behaviour not wired end-to-end
verified-by: claude
verified-on: 2026-07-11"
  try_move_done "$d" "gv"
  if [[ "$MOVE_RC" -ne 0 ]] && echo "$MOVE_OUT" | grep -q "AC2: fail"; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$MOVE_RC output: $MOVE_OUT"
  fi
  rm -rf "$d"

  # (d) an AC missing from the verdict → refused
  T="move to done refused when an AC has no verdict line"
  d=$(mk_project)
  mk_green_galley "$d" "gv"
  mk_review "$d" "gv" "AC1: pass — check exited 0
verified-by: claude
verified-on: 2026-07-11"
  try_move_done "$d" "gv"
  if [[ "$MOVE_RC" -ne 0 ]] && echo "$MOVE_OUT" | grep -q "AC2 has no verdict line"; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$MOVE_RC output: $MOVE_OUT"
  fi
  rm -rf "$d"

  # (e) complete independent verdict → move succeeds
  T="move to done succeeds with a complete independent verdict"
  d=$(mk_project)
  mk_green_galley "$d" "gv"
  mk_review "$d" "gv" "AC1: pass — check exited 0
AC2: pass — check exited 0
verified-by: claude
verified-on: 2026-07-11"
  try_move_done "$d" "gv"
  if [[ "$MOVE_RC" -eq 0 ]] && [[ "$(galley_status "$d" gv)" == "done" ]]; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$MOVE_RC output: $MOVE_OUT"
  fi
  rm -rf "$d"

  # (f) verdict must not be builder-written even when engines block is absent
  #     (both default to claude → equality → refused)
  T="missing engines block → verified-by claude refused (defaults collide)"
  d=$(mk_project)
  echo "codepress-version: 0.5.0" > "$d/.codepress/system/codepress.md"
  mk_green_galley "$d" "gv"
  mk_review "$d" "gv" "AC1: pass — check exited 0
AC2: pass — check exited 0
verified-by: claude
verified-on: 2026-07-11"
  try_move_done "$d" "gv"
  if [[ "$MOVE_RC" -ne 0 ]] && echo "$MOVE_OUT" | grep -q "equals engines.build"; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$MOVE_RC output: $MOVE_OUT"
  fi
  rm -rf "$d"
}

# ── AC6: --force bypasses any refused move and records a waiver ──────────────

test_force_records_waiver() {
  local T d rfile

  T="--force bypasses the verdict gate and moves to done"
  d=$(mk_project)
  mk_green_galley "$d" "gw"
  mk_review "$d" "gw" ""
  try_move_done "$d" "gw"          # refused first (no verdict)
  local refused_rc=$MOVE_RC
  try_move_done "$d" "gw" --force  # then forced
  if [[ "$refused_rc" -ne 0 && "$MOVE_RC" -eq 0 ]] && [[ "$(galley_status "$d" gw)" == "done" ]]; then
    pass "$T"
  else
    fail "$T"
    echo "      refused_rc=$refused_rc rc=$MOVE_RC output: $MOVE_OUT"
  fi

  T="--force appends a dated waiver line to review.md"
  rfile="$d/.codepress/product/galleys/gw/review.md"
  if grep -q "^> waived: $(date +%Y-%m-%d) review→done by human — unstated" "$rfile"; then
    pass "$T"
  else
    fail "$T"
    echo "      review.md tail: $(tail -3 "$rfile")"
  fi
  rm -rf "$d"

  T="--force --reason records the stated reason in the waiver"
  d=$(mk_project)
  mk_green_galley "$d" "gx"
  mk_review "$d" "gx" ""
  try_move_done "$d" "gx" --force --reason "accepting risk for demo"
  rfile="$d/.codepress/product/galleys/gx/review.md"
  if [[ "$MOVE_RC" -eq 0 ]] && grep -q "by human — accepting risk for demo" "$rfile"; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$MOVE_RC review.md tail: $(tail -3 "$rfile")"
  fi
  rm -rf "$d"

  T="--force on a failing-check review move also records a waiver"
  d=$(mk_project)
  mkdir -p "$d/.codepress/product/galleys/gy/slugs"
  cat > "$d/.codepress/product/galleys/gy/galley.md" <<'EOF'
---
id: gy
status: delivering
---

# Galley: gy

## Acceptance Criteria

- [ ] AC1 · check: false
EOF
  mk_review "$d" "gy" ""
  set +e
  MOVE_OUT=$(cd "$d" && "$CODEPRESS" galley move gy review --force 2>&1)
  MOVE_RC=$?
  set -e
  rfile="$d/.codepress/product/galleys/gy/review.md"
  if [[ "$MOVE_RC" -eq 0 ]] && [[ "$(galley_status "$d" gy)" == "review" ]] \
     && grep -q "^> waived: $(date +%Y-%m-%d) delivering→review by human — unstated" "$rfile"; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$MOVE_RC output: $MOVE_OUT"
  fi
  rm -rf "$d"
}

# ── Run ───────────────────────────────────────────────────────────────────────

test_done_requires_independent_verdict
test_force_records_waiver

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
