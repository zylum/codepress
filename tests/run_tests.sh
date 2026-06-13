#!/usr/bin/env bash
# Run all CodePress test suites and report pass/fail counts.
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOTAL_PASS=0
TOTAL_FAIL=0
SUITE_FAIL=0

run_suite() {
  local script="$1"
  local name
  name=$(basename "$script" .sh)

  echo "═══════════════════════════════════════════════════"
  echo "  Suite: $name"
  echo "═══════════════════════════════════════════════════"

  local output exit_code
  set +e
  output=$(bash "$script" 2>&1)
  exit_code=$?
  set -e

  echo "$output"

  local suite_pass suite_fail
  suite_pass=$(echo "$output" | grep -c "^PASS" || true)
  suite_fail=$(echo "$output" | grep -c "^FAIL" || true)

  TOTAL_PASS=$((TOTAL_PASS + suite_pass))
  TOTAL_FAIL=$((TOTAL_FAIL + suite_fail))

  if [[ "$exit_code" -ne 0 ]]; then
    SUITE_FAIL=$((SUITE_FAIL + 1))
  fi

  echo ""
}

# Find and run all test_*.sh files
for script in "$TESTS_DIR"/test_*.sh; do
  [[ -f "$script" ]] || continue
  run_suite "$script"
done

# Final summary
echo "═══════════════════════════════════════════════════"
echo "  TOTAL: $TOTAL_PASS passed, $TOTAL_FAIL failed"
echo "═══════════════════════════════════════════════════"

if [[ "$TOTAL_FAIL" -gt 0 || "$SUITE_FAIL" -gt 0 ]]; then
  exit 1
fi
