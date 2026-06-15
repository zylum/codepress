#!/usr/bin/env bash
# Tests for codepress status detection (detect_pending_actions)
set -euo pipefail

CODEPRESS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/codepress"
PASS=0
FAIL=0

pass() { echo "PASS  $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL  $1"; FAIL=$((FAIL + 1)); }

# Run codepress from a temp dir, return stdout
run_status() {
  local dir="$1"
  (cd "$dir" && "$CODEPRESS" status 2>/dev/null) || true
}

run_status_pending() {
  local dir="$1"
  (cd "$dir" && "$CODEPRESS" status 2>/dev/null | grep -A50 "Pending actions:" || true)
}

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

mk_initiative() {
  local dir="$1" id="$2" status="$3"
  cat > "$dir/.codepress/product/initiatives/$id.md" <<EOF
---
id: $id
status: $status
---
# Initiative: $id
EOF
}

mk_galley() {
  local dir="$1" name="$2" status="$3" initiative="${4:-}"
  mkdir -p "$dir/.codepress/product/galleys/$name/slugs"
  cat > "$dir/.codepress/product/galleys/$name/galley.md" <<EOF
---
id: $name
status: $status
initiative: $initiative
---
# Galley: $name
EOF
}

mk_slug() {
  local dir="$1" galley="$2" slug_id="$3" status="$4"
  cat > "$dir/.codepress/product/galleys/$galley/slugs/$slug_id.md" <<EOF
---
id: $slug_id
status: $status
galley: $galley
---
# Slug: $slug_id
EOF
}

# ── Test 1: approved initiative with no galley → create-galley ───────────────

T="approved initiative without galley → detects create-galley"
d=$(mk_project)
mk_initiative "$d" "init-001" "approved"
out=$(run_status_pending "$d")
if echo "$out" | grep -q "create-galley"; then
  pass "$T"
else
  fail "$T"
  echo "      output: $out"
fi
rm -rf "$d"

# ── Test 2: approved galley with no slugs → split-galley ────────────────────

T="approved galley without slugs → detects split-galley"
d=$(mk_project)
mk_galley "$d" "my-galley" "approved"
out=$(run_status_pending "$d")
if echo "$out" | grep -q "split-galley"; then
  pass "$T"
else
  fail "$T"
  echo "      output: $out"
fi
rm -rf "$d"

# ── Test 3: delivering galley with all slugs done → review ───────────────────

T="delivering galley with all slugs complete → detects review"
d=$(mk_project)
mk_galley "$d" "eng-galley" "delivering"
mk_slug "$d" "eng-galley" "slug-a" "complete"
mk_slug "$d" "eng-galley" "slug-b" "complete"
out=$(run_status_pending "$d")
if echo "$out" | grep -q "review"; then
  pass "$T"
else
  fail "$T"
  echo "      output: $out"
fi
rm -rf "$d"

# ── Test 4: no pending actions → shows up-to-date message ────────────────────

T="no pending actions → shows up-to-date message"
d=$(mk_project)
mk_galley "$d" "done-galley" "done"
out=$(run_status_pending "$d")
if echo "$out" | grep -q "no pending actions"; then
  pass "$T"
else
  fail "$T"
  echo "      output: $out"
fi
rm -rf "$d"

# ── Test 5: delivering galley with mixed slug states → no review yet ─────────

T="delivering galley with incomplete slugs → no review action"
d=$(mk_project)
mk_galley "$d" "wip-galley" "delivering"
mk_slug "$d" "wip-galley" "slug-a" "complete"
mk_slug "$d" "wip-galley" "slug-b" "open"
out=$(run_status_pending "$d")
if ! echo "$out" | grep -q "review"; then
  pass "$T"
else
  fail "$T"
  echo "      output: $out"
fi
rm -rf "$d"

# ── Test 6: shaping initiative with no galley → create-galley ────────────────

T="shaping initiative without galley → detects create-galley"
d=$(mk_project)
mk_initiative "$d" "init-002" "shaping"
out=$(run_status_pending "$d")
if echo "$out" | grep -q "create-galley"; then
  pass "$T"
else
  fail "$T"
  echo "      output: $out"
fi
rm -rf "$d"

# ── Test 7: review galley → release+learn action ─────────────────────────────

T="galley in review status → detects release+learn action"
d=$(mk_project)
mk_galley "$d" "review-galley" "review"
out=$(run_status_pending "$d")
if echo "$out" | grep -q "release"; then
  pass "$T"
else
  fail "$T"
  echo "      output: $out"
fi
rm -rf "$d"

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
