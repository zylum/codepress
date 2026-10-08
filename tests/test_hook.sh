#!/usr/bin/env bash
# The pre-commit hook: `codepress hook install|run|uninstall`. The hook runs
# lint plus the verify gates and finds a tool environment even in a fresh git
# worktree, so no one needs `git commit --no-verify`.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# the gate command `mytool` only exists inside a venv's bin/
mk_venv() {
  mkdir -p "$1/bin"
  printf '#!/bin/sh\nexit 0\n' > "$1/bin/mytool"
  chmod +x "$1/bin/mytool"
  : > "$1/bin/activate"
}

with_mytool_gate() {
  printf 'codepress-version: %s\n\nverify:\n  test: mytool\n\nengines:\n  build: opencode\n  verifier: claude\n' "$CP_VERSION" > "$1/.codepress/system/codepress.md"
}

# hook_run <dir> [VAR=value ...] — sets OUT and RC. PATH is kept free of `mytool`.
hook_run() {
  local d="$1"; shift
  RC=0
  OUT=$(cd "$d" && env "$@" "$CODEPRESS" hook run 2>&1) || RC=$?
}

# ── install / uninstall ───────────────────────────────────────────────────────

d=$(mk_project); mk_git "$d"
cp_run "$d" hook install
eq "hook install succeeds in a git repo" "$RC" "0"
assert "…writing an executable pre-commit hook" test -x "$d/.git/hooks/pre-commit"
has "…marked as codepress-managed" "$(cat "$d/.git/hooks/pre-commit")" "codepress-managed"
has "…which calls 'hook run' on the CLI that installed it" "$(cat "$d/.git/hooks/pre-commit")" "$CODEPRESS"

printf '#!/bin/sh\necho mine\n' > "$d/.git/hooks/pre-commit"
cp_run "$d" hook install
eq "install refuses to overwrite someone else's hook" "$RC" "1"
has "…saying so" "$OUT" "not codepress-managed"
eq "…leaving it intact" "$(cat "$d/.git/hooks/pre-commit")" $'#!/bin/sh\necho mine'
cp_run "$d" hook install --force
eq "--force replaces it" "$RC" "0"
cp_run "$d" hook uninstall
assert "uninstall removes a managed hook" test ! -e "$d/.git/hooks/pre-commit"
printf '#!/bin/sh\necho mine\n' > "$d/.git/hooks/pre-commit"
cp_run "$d" hook uninstall
assert "uninstall leaves a foreign hook alone" test -e "$d/.git/hooks/pre-commit"

d=$(mk_project)
cp_run "$d" hook install
eq "install outside a git repo fails cleanly" "$RC" "1"

d=$(mk_project); mk_git "$d"
(cd "$d" && git config core.hooksPath .githooks)
cp_run "$d" hook install
assert "install honours core.hooksPath" test -x "$d/.githooks/pre-commit"

# ── run: lint + gates ─────────────────────────────────────────────────────────

d=$(mk_project); mk_galley "$d" alpha shaped; mk_git "$d"
hook_run "$d" CODEPRESS_HOOK_GATES=lint
eq "a clean project passes the hook" "$RC" "0"
has "…reporting the gate it ran" "$OUT" "✅ lint"

d=$(mk_project); mk_galley "$d" alpha review; mk_git "$d"
hook_run "$d" CODEPRESS_HOOK_GATES=lint
eq "lint errors fail the hook" "$RC" "1"
has "…showing the finding" "$OUT" "retired galley status 'review'"

d=$(mk_project); mk_git "$d"
hook_run "$d"
eq "the default gates are lint and test" "$RC" "0"
has "…test ran from codepress.md" "$OUT" "✅ test — true"

d=$(mk_project); mk_git "$d"
printf 'codepress-version: %s\n\nverify:\n  test: exit 3\n' "$CP_VERSION" > "$d/.codepress/system/codepress.md"
hook_run "$d"
eq "a failing test gate fails the hook" "$RC" "1"
has "…with its exit code" "$OUT" "(exit 3)"

d=$(mk_project); mk_git "$d"
printf 'codepress-version: %s\n' "$CP_VERSION" > "$d/.codepress/system/codepress.md"
hook_run "$d"
eq "a project with no test gate still passes" "$RC" "0"
has "…noting the gate was skipped" "$OUT" "no command"

# ── environment discovery ─────────────────────────────────────────────────────

d=$(mk_project); with_mytool_gate "$d"; mk_git "$d"
hook_run "$d"
eq "a gate whose tool is missing fails the hook" "$RC" "1"
has "…explaining CODEPRESS_ENV" "$OUT" "CODEPRESS_ENV=/path/to/venv"
has "…and the sanctioned narrower run" "$OUT" "CODEPRESS_HOOK_GATES=lint"
lacks "…never suggesting --no-verify" "$OUT" "no-verify"

hook_run "$d" CODEPRESS_HOOK_GATES=lint
eq "CODEPRESS_HOOK_GATES=lint runs lint alone and passes" "$RC" "0"

venv=$(mktemp -d); CLEANUP+=("$venv"); mk_venv "$venv"
hook_run "$d" CODEPRESS_ENV="$venv"
eq "CODEPRESS_ENV puts the venv's bin on PATH" "$RC" "0"
has "…and the output names the environment" "$OUT" "env: $venv"

hook_run "$d" CODEPRESS_ENV="/no/such/dir"
eq "CODEPRESS_ENV pointing nowhere is an error" "$RC" "1"
has "…saying so" "$OUT" "is not a directory"

d=$(mk_project); with_mytool_gate "$d"; mk_venv "$d/.venv"; mk_git "$d"
hook_run "$d"
eq "a ./.venv in the checkout is found automatically" "$RC" "0"

# a fresh worktree has no virtualenv — the hook borrows the main worktree's
main=$(mk_project); with_mytool_gate "$main"; mk_venv "$main/.venv"
printf '.venv/\n' > "$main/.gitignore"
mk_git "$main"
wt="$main-wt"; CLEANUP+=("$wt")
(cd "$main" && git worktree add -q "$wt" -b feature)
assert "the fresh worktree has no .venv of its own" test ! -e "$wt/.venv"
hook_run "$wt"
eq "…yet the hook finds the main worktree's virtualenv" "$RC" "0"
has "…and says which" "$OUT" "env: $(cd "$main" && pwd -P)/.venv"

# hook-env: in codepress.md
d=$(mk_project); mk_venv "$d/tools/env"
printf 'codepress-version: %s\nhook-env: tools/env   # where the gates live\n\nverify:\n  test: mytool\n' "$CP_VERSION" > "$d/.codepress/system/codepress.md"
mk_git "$d"
hook_run "$d"
eq "hook-env: in codepress.md (relative path) is honoured" "$RC" "0"

# ── the real thing: git commit with the hook installed ────────────────────────

d=$(mk_project); mk_galley "$d" alpha shaped; mk_git "$d"
cp_run "$d" hook install
before=$(cd "$d" && git rev-parse HEAD)
mk_galley "$d" alpha review
rc=0
out=$(cd "$d" && CODEPRESS_HOOK_GATES=lint git commit -q -am "move to a retired status" 2>&1) || rc=$?
eq "git commit is blocked by lint — with no --no-verify in sight" "$rc" "1"
has "…showing why" "$out" "retired galley status"
eq "…and HEAD did not move" "$(cd "$d" && git rev-parse HEAD)" "$before"

mk_galley "$d" alpha shaped "created: 2026-10-02"
rc=0
out=$(cd "$d" && CODEPRESS_HOOK_GATES=lint git commit -q -am "a legal edit" 2>&1) || rc=$?
eq "a clean commit goes through the hook" "$rc" "0"

# an illegal status jump is stopped at commit time (transition vs HEAD)
mk_galley "$d" alpha done
rc=0
out=$(cd "$d" && CODEPRESS_HOOK_GATES=lint git commit -q -am "skip the lifecycle" 2>&1) || rc=$?
eq "the hook stops an illegal transition (shaped -> done) at commit time" "$rc" "1"
has "…naming it" "$out" "illegal transition shaped -> done"

# worktree commit uses the shared hook and the borrowed environment
main=$(mk_project); with_mytool_gate "$main"; mk_venv "$main/.venv"; printf '.venv/\n' > "$main/.gitignore"
mk_galley "$main" alpha shaped; mk_git "$main"
cp_run "$main" hook install
wt="$main-wt2"; CLEANUP+=("$wt")
(cd "$main" && git worktree add -q "$wt" -b feature2)
mk_galley "$wt" beta shaped
rc=0
out=$(cd "$wt" && git add -A && git commit -q -m "add beta from a fresh worktree" 2>&1) || rc=$?
eq "a commit from a fresh worktree passes lint AND the test gate, no flags" "$rc" "0"

summary
