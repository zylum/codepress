#!/usr/bin/env bash
# Tests for `codepress check <galley>` and the gated `codepress galley move`
# (codepress-check-and-gated-move slug). Test function names match the
# `test:` refs in the enforced-acceptance galley's acceptance criteria.
set -euo pipefail

CODEPRESS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/codepress"
PASS=0
FAIL=0

pass() { echo "PASS  $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL  $1"; FAIL=$((FAIL + 1)); }

# ── Fixture helpers (temp CodePress project) ──────────────────────────────────

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
  mkdir -p "$d/tests"
  cat > "$d/.codepress/system/codepress.md" <<'EOF'
codepress-version: 0.5.0
test-runner: bash {file}

engines:
  build: opencode
  verifier: claude
EOF
  # fixture test scripts referenced by test: ACs
  cat > "$d/tests/fixture_pass.sh" <<'EOF'
#!/usr/bin/env bash
# always_passes
exit 0
EOF
  cat > "$d/tests/fixture_fail.sh" <<'EOF'
#!/usr/bin/env bash
# always_fails
exit 1
EOF
  echo "$d"
}

# mk_galley <dir> <name> <status> — AC lines read from stdin
mk_galley() {
  local dir="$1" name="$2" status="$3" acs
  acs=$(cat)
  mkdir -p "$dir/.codepress/product/galleys/$name/slugs"
  cat > "$dir/.codepress/product/galleys/$name/galley.md" <<EOF
---
id: $name
status: $status
---

# Galley: $name

## Acceptance Criteria

$acs
EOF
}

# mk_review <dir> <name> <signals-line> — empty signals-line = empty section
mk_review() {
  local dir="$1" name="$2" signals="${3:-}"
  cat > "$dir/.codepress/product/galleys/$name/review.md" <<EOF
# Review: $name

## Signals
$signals

## Verdict
EOF
}

galley_status() {
  grep -m1 '^status:' "$1/.codepress/product/galleys/$2/galley.md" | sed 's/status: *//'
}

# ── AC1: move → review refused when a bound test: AC fails ───────────────────

test_move_refused_on_failing_ac() {
  local T="move to review refused when an AC references a failing test"
  local d out rc
  d=$(mk_project)
  mk_galley "$d" "g1" "delivering" <<'EOF'
- [ ] AC1 · Given a fixture project · When its test runs · Then it fails · test: tests/fixture_fail.sh::always_fails
EOF
  mk_review "$d" "g1" "- a real observation"
  set +e
  out=$(cd "$d" && "$CODEPRESS" galley move g1 review 2>&1)
  rc=$?
  set -e
  if [[ "$rc" -ne 0 ]] && echo "$out" | grep -q "refused" && echo "$out" | grep -q "❌ AC1"; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$rc output: $out"
  fi

  T="refused move leaves status unchanged"
  if [[ "$(galley_status "$d" g1)" == "delivering" ]]; then
    pass "$T"
  else
    fail "$T"
    echo "      status: $(galley_status "$d" g1)"
  fi
  rm -rf "$d"
}

# ── AC2: move → review allowed when all bound ACs pass ───────────────────────

test_move_allowed_when_green() {
  local T="move to review succeeds when all bound ACs pass"
  local d out rc
  d=$(mk_project)
  mk_galley "$d" "g2" "delivering" <<'EOF'
- [ ] AC1 · Given a fixture project · When its test runs · Then it passes · test: tests/fixture_pass.sh::always_passes
- [ ] AC2 · check: true
EOF
  mk_review "$d" "g2" "- a real observation"
  set +e
  out=$(cd "$d" && "$CODEPRESS" galley move g2 review 2>&1)
  rc=$?
  set -e
  if [[ "$rc" -eq 0 ]] && [[ "$(galley_status "$d" g2)" == "review" ]]; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$rc output: $out"
  fi

  T="successful move regenerates the board"
  local board="$d/.codepress/views/galley-board.md"
  if [[ -f "$board" ]] && grep -q "## Review" "$board" && grep -q "g2" "$board"; then
    pass "$T"
  else
    fail "$T"
  fi
  rm -rf "$d"
}

# ── AC3: check: command failure reported per-AC ───────────────────────────────

test_check_command_failure() {
  local T="check: command exiting 1 → that AC reports fail, exit non-zero"
  local d out rc
  d=$(mk_project)
  mk_galley "$d" "g3" "delivering" <<'EOF'
- [ ] AC1 · check: false
- [ ] AC2 · check: true
EOF
  set +e
  out=$(cd "$d" && "$CODEPRESS" check g3 2>&1)
  rc=$?
  set -e
  if [[ "$rc" -ne 0 ]] && echo "$out" | grep -q "❌ AC1" && echo "$out" | grep -q "✅ AC2"; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$rc output: $out"
  fi
  rm -rf "$d"
}

# ── AC4: ticked manual: line rejected, naming the line ────────────────────────

test_manual_tick_rejected() {
  local T="ticked manual: line → check fails naming the line"
  local d out rc
  d=$(mk_project)
  mk_galley "$d" "g4" "delivering" <<'EOF'
- [x] AC1 · manual: rotate the production API key
EOF
  set +e
  out=$(cd "$d" && "$CODEPRESS" check g4 2>&1)
  rc=$?
  set -e
  if [[ "$rc" -ne 0 ]] && echo "$out" | grep -q "❌ AC1 · manual: rotate the production API key"; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$rc output: $out"
  fi

  T="unticked manual: line warns only"
  d=$(mk_project)
  mk_galley "$d" "g4b" "delivering" <<'EOF'
- [ ] AC1 · manual: rotate the production API key
EOF
  set +e
  out=$(cd "$d" && "$CODEPRESS" check g4b 2>&1)
  rc=$?
  set -e
  if [[ "$rc" -eq 0 ]] && echo "$out" | grep -q "⚠️  AC1 · manual:"; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$rc output: $out"
  fi
  rm -rf "$d"
}

# ── AC7: legacy prose-only galley warns but exits 0 ──────────────────────────

test_legacy_galley_warns_only() {
  local T="legacy galley with prose-only checkboxes → warns, exits 0"
  local d out rc
  d=$(mk_project)
  mk_galley "$d" "g5" "delivering" <<'EOF'
- [ ] the dashboard loads quickly
- [x] stakeholders are happy
EOF
  set +e
  out=$(cd "$d" && "$CODEPRESS" check g5 2>&1)
  rc=$?
  set -e
  if [[ "$rc" -eq 0 ]] && echo "$out" | grep -q "legacy" && echo "$out" | grep -q "⚠️"; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$rc output: $out"
  fi
  rm -rf "$d"
}

# ── Signals required for → review ─────────────────────────────────────────────

test_signals_required_for_review() {
  local T="move to review refused when ## Signals is empty"
  local d out rc
  d=$(mk_project)
  mk_galley "$d" "g6" "delivering" <<'EOF'
- [ ] AC1 · check: true
EOF
  mk_review "$d" "g6" ""
  set +e
  out=$(cd "$d" && "$CODEPRESS" galley move g6 review 2>&1)
  rc=$?
  set -e
  if [[ "$rc" -ne 0 ]] && echo "$out" | grep -q "Signals"; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$rc output: $out"
  fi
  rm -rf "$d"
}

# ── Earlier statuses stay ungated ─────────────────────────────────────────────

test_earlier_moves_ungated() {
  local T="moves to shaping/approved/delivering are ungated even with failing ACs"
  local d rc s ok=1
  d=$(mk_project)
  mk_galley "$d" "g7" "shaping" <<'EOF'
- [ ] AC1 · check: false
EOF
  for s in approved delivering shaping; do
    set +e
    (cd "$d" && "$CODEPRESS" galley move g7 "$s" > /dev/null 2>&1)
    rc=$?
    set -e
    [[ "$rc" -ne 0 ]] && ok=0
  done
  if [[ "$ok" -eq 1 ]]; then
    pass "$T"
  else
    fail "$T"
  fi
  rm -rf "$d"
}

# ── Fallback: no test-runner template → full test gate, with warning ─────────

test_fallback_full_gate() {
  local T="no test-runner: template → falls back to full test gate with warning"
  local d out rc
  d=$(mk_project)
  # config without test-runner but with a verify block defining the test gate
  cat > "$d/.codepress/system/codepress.md" <<'EOF'
codepress-version: 0.5.0

engines:
  build: opencode
  verifier: claude

verify:
  test: bash tests/fixture_pass.sh
EOF
  mk_galley "$d" "g8" "delivering" <<'EOF'
- [ ] AC1 · Given a fixture · When run via the gate · Then it passes · test: tests/fixture_pass.sh::always_passes
EOF
  set +e
  out=$(cd "$d" && "$CODEPRESS" check g8 2>&1)
  rc=$?
  set -e
  if [[ "$rc" -eq 0 ]] && echo "$out" | grep -q "per-AC attribution unavailable" && echo "$out" | grep -q "✅ AC1"; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$rc output: $out"
  fi
  rm -rf "$d"
}

# ── Missing test: ref file → fail ─────────────────────────────────────────────

test_missing_ref_fails() {
  local T="test: ref pointing at a missing file → AC fails"
  local d out rc
  d=$(mk_project)
  mk_galley "$d" "g9" "delivering" <<'EOF'
- [ ] AC1 · Given a bad ref · When checked · Then it fails · test: tests/does_not_exist.sh::nope
EOF
  set +e
  out=$(cd "$d" && "$CODEPRESS" check g9 2>&1)
  rc=$?
  set -e
  if [[ "$rc" -ne 0 ]] && echo "$out" | grep -q "file not found"; then
    pass "$T"
  else
    fail "$T"
    echo "      rc=$rc output: $out"
  fi
  rm -rf "$d"
}

# ── Run ───────────────────────────────────────────────────────────────────────

test_move_refused_on_failing_ac
test_move_allowed_when_green
test_check_command_failure
test_manual_tick_rejected
test_legacy_galley_warns_only
test_signals_required_for_review
test_earlier_moves_ungated
test_fallback_full_gate
test_missing_ref_fails

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
