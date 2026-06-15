# Review: Execution Engine v1

## Signals

- `codepress status` exited nonzero when pending actions existed — action_count leaked out of `detect_pending_actions` as the exit code. Shell functions that return counts-as-return-codes are hazardous under `set -e`. Fixed with `|| true` guard in `cmd_status`.
- Shell test harness with mktemp isolation, pass/fail counters, and per-suite summary is sufficient for bash CLI testing without needing bats or shunit2.
- Tests that call a CLI which may exit nonzero must be guarded — either with `|| true` at the call site or by using a subshell capture pattern that ignores exit codes.
- `codepress status --json` was documented in the spec but not yet implemented in the CLI. Added the flag and wired it to `detect_pending_actions json`.

## Surprises

- Test scripts already existed from a prior session but had two bugs: (1) `mk_project` in `test_status_detection.sh` didn't create the `.codepress/system/` directory before writing to it, causing stderr noise and redundant mkdir calls across all 7 tests; (2) `run_status` in `test_board_regeneration.sh` didn't tolerate nonzero exit from `codepress status`, causing tests 3-6 to silently abort under `set -euo pipefail`.
- The board regeneration suite was reporting only 2/6 tests despite all logic being correct — purely a shell exit code propagation issue.

## Pattern candidates

**Test commands that encode data in exit codes with `|| true`**
When a CLI command encodes data (e.g. a count) in its exit code and tests run under `set -e`, every call to that command must be guarded with `|| true`. Alternatively, redesign the CLI to always exit 0 and encode counts in stdout. The latter is cleaner for scripting.

**mktemp isolation for bash CLI tests**
Each test creates a fresh `mktemp -d` project, runs the CLI against it, asserts output/files, then `rm -rf`. This gives true isolation with no shared state between tests. A shared `mk_project` helper keeps setup DRY.

## Knowledge updates

- `docs/quick-reference.md` updated: `codepress status --json` added to CLI commands block + prose description of pipe-delimited output format
- CLI `codepress` updated: `cmd_status` accepts `--json` flag, usage string updated, `case` statement passes args through
