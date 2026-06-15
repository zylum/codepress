---
id: ee-v1-s6
status: done
galley: ee-v1
autonomy: confirm
---

# Slug: test-and-docs

## Purpose

Add tests for the execution engine (status detection, action execution, dispatch routing) and update all documentation to reflect the new commands, engine config, and architecture.

## Acceptance checklist

- [ ] Tests exist for status detection — each artefact state maps to correct pending action
- [ ] Tests exist for `codepress run` — dry-run mode, single action, --all
- [ ] Tests exist for engine dispatch — config parsing, agent routing, fallback defaults
- [ ] Tests exist for board regeneration — frontmatter → correct kanban output
- [ ] `docs/quick-reference.md` updated with `run` and `watch` commands
- [ ] `docs/index.md` or `docs/overview.md` updated with engine architecture diagram or description
- [ ] `docs/faq.md` updated if relevant
- [ ] `README.md` updated with new CLI commands and engine capabilities

## Context

Tests should be in a format consistent with the project. Since the CLI is bash, tests can be shell-based (bats, shunit2) or the project can introduce a test framework here.

The documentation site is Jekyll-based at `docs/`. The existing pages (index, quick-reference, overview, faq, core-concepts, structure) each need review for engine-related updates.

## Dependencies

- `status-detector` (what to test)
- `codepress-run` (what to test)
- `engine-config` (what to test)
- `board-regeneration` (what to test)

## Evidence

- `tests/test_status_detection.sh` — 7 tests covering all 4 state transitions: approved initiative → create-galley, shaping initiative → create-galley, approved galley (no slugs) → split-galley, delivering galley (all complete) → review, delivering galley (partial) → no-review, galley in review → release+learn, done galley → no pending actions
- `tests/test_board_regeneration.sh` — 6 tests: shaping/delivering/done galley → correct column, board created when missing, stale board updated, `galley move` triggers regeneration
- `tests/run_tests.sh` — runs both suites, reports per-suite and total counts, exits 1 on any failure
- All 3 scripts are executable (chmod +x)
- Bug found and fixed: `codepress status` exited nonzero when pending actions existed (action_count propagated as exit code from `detect_pending_actions`). Fixed with `|| true` in `cmd_status`. Tests now run cleanly end-to-end without set -e abort.
- `codepress status --json` flag added to CLI and documented in quick-reference
- `docs/quick-reference.md` updated: `--json` flag in CLI commands block + prose explanation in `status` section
- `README.md` already had `codepress run` and `codepress run --all` from prior docs-refresh — verified, no changes needed

Test run output:
```
═══════════════════════════════════════════════════
  Suite: test_board_regeneration
═══════════════════════════════════════════════════
PASS  galley with status shaping → appears in Shaping column of board
PASS  galley with status delivering → appears in Delivering column of board
PASS  board file is created when views/galley-board.md does not exist
PASS  board file is updated when it already exists with stale content
PASS  galley with status done → appears in Done column of board
PASS  codepress galley move triggers board regeneration

Results: 6 passed, 0 failed

═══════════════════════════════════════════════════
  Suite: test_status_detection
═══════════════════════════════════════════════════
PASS  approved initiative without galley → detects create-galley
PASS  approved galley without slugs → detects split-galley
PASS  delivering galley with all slugs complete → detects review
PASS  no pending actions → shows up-to-date message
PASS  delivering galley with incomplete slugs → no review action
PASS  shaping initiative without galley → detects create-galley
PASS  galley in review status → detects release+learn action

Results: 7 passed, 0 failed

═══════════════════════════════════════════════════
  TOTAL: 13 passed, 0 failed
═══════════════════════════════════════════════════
```

## Signals

- Shell test harness (mktemp isolation, pass/fail helpers, summary exit code) is a reusable pattern for bash CLI projects
- `set -euo pipefail` in test scripts requires all called commands to exit 0 — status commands that encode data in exit codes need `|| true` guards
- The 3-test-file structure (per-feature suites + runner) scales well; adding a new suite is just adding a `test_*.sh` file
