#!/usr/bin/env bash
# Shared fixtures for the lifecycle / lint / hook suites (sourced, not run).
# Older suites define their own copies and stay self-contained.

export PYTHONDONTWRITEBYTECODE=1
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEPRESS="$REPO_ROOT/codepress"
LINT="$REPO_ROOT/.codepress/system/lib/lint.py"
CP_VERSION="$(sed -n 's/^codepress-version: *//p' "$REPO_ROOT/.codepress/system/codepress.md" | head -1)"
PASS=0
FAIL=0
CLEANUP=()

pass() { echo "PASS  $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL  $1"; FAIL=$((FAIL + 1)); }

cleanup_all() {
  local d
  for d in ${CLEANUP[@]+"${CLEANUP[@]}"}; do rm -rf "$d"; done
}
trap cleanup_all EXIT

# assert <name> <command...> — passes when the command succeeds.
assert() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then pass "$name"; else fail "$name"; fi
}

# has <name> <haystack> <needle> / lacks — fixed-string match, shows output on failure.
has() {
  if printf '%s' "$2" | grep -qF -- "$3"; then pass "$1"; else fail "$1"; echo "      expected to contain: $3"; echo "      got: $(printf '%s' "$2" | head -12)"; fi
}
lacks() {
  if printf '%s' "$2" | grep -qF -- "$3"; then fail "$1"; echo "      expected NOT to contain: $3"; echo "      got: $(printf '%s' "$2" | head -12)"; else pass "$1"; fi
}
# eq <name> <actual> <expected>
eq() {
  if [[ "$2" == "$3" ]]; then pass "$1"; else fail "$1"; echo "      expected: $3"; echo "      actual:   $2"; fi
}

# ── fixtures ──────────────────────────────────────────────────────────────────

mk_project() {
  local d
  d=$(mktemp -d)
  CLEANUP+=("$d")
  mkdir -p "$d/.codepress/system" "$d/.codepress/product/initiatives" "$d/.codepress/product/galleys" \
           "$d/.codepress/product/releases" "$d/.codepress/knowledge/patterns" \
           "$d/.codepress/knowledge/signals" "$d/.codepress/knowledge/decisions" \
           "$d/.codepress/views" "$d/tests"
  cat > "$d/.codepress/system/codepress.md" <<EOF
codepress-version: $CP_VERSION

verify:
  test: true

engines:
  build: opencode
  verifier: claude
EOF
  echo "$d"
}

mk_git() {
  local d="$1"
  (
    cd "$d"
    git init -q
    git config user.email "t@example.com"
    git config user.name "Test"
    git add -A
    git commit -q -m "init" --allow-empty
  )
}

# commit_all <dir> <message> [date]
commit_all() {
  local d="$1" msg="$2" when="${3:-}"
  (
    cd "$d"
    git add -A
    if [[ -n "$when" ]]; then
      GIT_AUTHOR_DATE="$when" GIT_COMMITTER_DATE="$when" git commit -q -m "$msg" --allow-empty
    else
      git commit -q -m "$msg" --allow-empty
    fi
  )
}

# mk_galley <dir> <name> <status> [extra-frontmatter] [acceptance-lines]
mk_galley() {
  local d="$1" name="$2" status="$3" extra="${4:-}" acs="${5:-- [ ] AC1 · check: true}"
  mkdir -p "$d/.codepress/product/galleys/$name/slugs"
  {
    echo "---"
    echo "id: $name"
    echo "status: $status"
    echo "created: 2026-10-01"
    [[ -n "$extra" ]] && echo "$extra"
    echo "---"
    echo ""
    echo "# Galley: $name"
    echo ""
    echo "## Problem"
    echo "p"
    echo ""
    echo "## Success"
    echo "s"
    echo ""
    echo "## Approach"
    echo "a"
    echo ""
    echo "## Acceptance Criteria"
    echo ""
    echo "$acs"
  } > "$d/.codepress/product/galleys/$name/galley.md"
}

# mk_slug <dir> <galley> <id> <status> [extra-frontmatter] [acceptance-line] [evidence]
mk_slug() {
  local d="$1" g="$2" id="$3" status="$4" extra="${5:-}" ac="${6:-- [x] AC1 · check: true}" ev="${7-shipped}"
  {
    echo "---"
    echo "id: $id"
    echo "status: $status"
    echo "galley: $g"
    [[ -n "$extra" ]] && echo "$extra"
    echo "---"
    echo ""
    echo "# Slug: $id"
    echo ""
    echo "## Acceptance checklist"
    echo "$ac"
    echo ""
    echo "## Evidence"
    echo "$ev"
  } > "$d/.codepress/product/galleys/$g/slugs/$id.md"
}

# mk_review <dir> <galley> [signals] [evidence] [verdict-block]
mk_review() {
  local d="$1" g="$2" sig="${3:-}" ev="${4:-}" verdict="${5:-}"
  cat > "$d/.codepress/product/galleys/$g/review.md" <<EOF
# Review: $g

## Signals
$sig

## Evidence
$ev

## Verdict
$verdict
EOF
}

VERDICT_OK=$'AC1: pass — ran it\nverified-by: claude\nverified-on: 2026-10-08'

mk_learned() {
  printf '# Learned: %s\n\n## What worked\nWe learned a thing worth keeping.\n' "$2" > "$1/.codepress/product/galleys/$2/learned.md"
}

# mk_complete_galley <dir> <name> <status> — satisfies every gate up to <status>.
mk_complete_galley() {
  local d="$1" name="$2" status="$3"
  mk_galley "$d" "$name" "$status" $'approved_by: marv\napproved_on: 2026-10-02' "- [x] AC1 · check: true"
  mk_slug "$d" "$name" s1 closed
  mk_review "$d" "$name" "- noticed a thing" "- commit abc123 ran green" "$VERDICT_OK"
  mk_learned "$d" "$name"
}

# lint_run <dir> [args...] — sets OUT and RC.
lint_run() {
  local d="$1"; shift
  RC=0
  OUT=$(cd "$d" && "$CODEPRESS" lint "$@" 2>&1) || RC=$?
}

# cp_run <dir> <args...> — sets OUT and RC.
cp_run() {
  local d="$1"; shift
  RC=0
  OUT=$(cd "$d" && "$CODEPRESS" "$@" 2>&1) || RC=$?
}

summary() {
  echo ""
  echo "Results: $PASS passed, $FAIL failed"
  [[ "$FAIL" -eq 0 ]]
}
