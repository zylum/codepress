---
id: codepress-check-and-gated-move
status: closed
galley: enforced-acceptance
autonomy: confirm
budget:
  wall-clock: 4h
  tokens:
  cost:
---

# Slug: codepress-check-and-gated-move

## Purpose
`codepress check <galley>` evaluates every bound AC mechanically, and
`cmd_galley_move` refuses ungated transitions — the sed becomes a gate.

## Acceptance checklist
- [x] New subcommand `codepress check <galley>` (wire into the dispatch at the
      bottom of the CLI): runs the galley's `verify:` gates fresh; for each AC —
      `test:` ref exists and passes, `check:` command exits 0, `manual:` line is
      NOT ticked `[x]`, legacy unbound lines warn only; per-AC ✅/❌/⚠️ output;
      exit non-zero iff any bound AC fails · test: tests/test_check_gating.sh
- [x] `test:` refs run via an optional `test-runner:` template in
      `system/codepress.md` (e.g. `pytest {ref} -q` / `bash {ref}`); when absent,
      fall back to running the full `test` gate once and warn that per-AC
      attribution is unavailable
- [x] `cmd_galley_move → review` requires `codepress check` to pass;
      `→ done` additionally requires the Verdict gate (slug 03 wires that call);
      moves to `shaping/approved/delivering` remain ungated
- [x] `--force` on `galley move` bypasses any gate and appends
      `> waived: <date> <from>→<to> by human — <reason|unstated>` to the galley's
      review.md · test: tests/test_verdict_gate.sh::test_force_records_waiver
- [x] Non-empty `## Signals` content in review.md required for `→ review`
      (the loop's raw input — a galley with zero signals learned nothing)
- [x] Existing suites still pass and new suites added to `tests/run_tests.sh` ·
      check: bash tests/run_tests.sh

## Context
Read `cmd_galley_move` (~line 1063) and the subcommand dispatch (~line 1108) in the
`codepress` CLI; `tests/test_status_detection.sh` for the temp-project fixture
pattern. Reuse slug 01's `extract_acs` helper — do not re-parse ad hoc. Keep the
CLI a single file. macOS + Linux sed compatibility as per the existing move code.

## Dependencies
01-acceptance-binding-format (the parser).

## Evidence
- `codepress check <galley>` implemented in the CLI (`cmd_check`), wired into the
  dispatch; runs `verify:` gates fresh via `get_gate_command` (handles folded `>`
  values like cost-check), evaluates every AC via `extract_acs`, per-AC ✅/❌/⚠️
  output, exit non-zero iff a gate or bound AC fails.
- `test:` refs resolve via the `test-runner:` template in codepress.md
  (placeholders `{ref}` / `{file}` / `{name}`; this project uses `bash {file}` —
  bash suites are whole-file granularity, and the CLI additionally asserts the
  `::name` exists in the file via grep before running). Absent template → full
  `test` gate once + "per-AC attribution unavailable" warning.
- `cmd_galley_move`: `→ review` requires check pass + non-empty `## Signals`;
  `→ done` additionally requires the slug-03 verdict gate; shaping/approved/
  delivering ungated; `--force [--reason <text>]` bypasses and appends
  `> waived: <date> <from>→<to> by human — <reason|unstated>` to review.md.
- `bash tests/test_check_gating.sh` — 12 passed, 0 failed (refusal on failing AC,
  green move + board regen, check-command failure, manual-tick rejection, legacy
  warns-only exit 0, empty-Signals refusal, ungated earlier moves, fallback gate,
  missing ref file).
- codepress.md `verify.test` corrected from the bootstrap placeholder `pytest` to
  this repo's real gate `bash tests/run_tests.sh` (required for an honest dogfood).

---

## Signals
- Identical test-runner commands are cached within one check run (parallel indexed
  arrays — macOS ships bash 3.2, no associative arrays), otherwise the dogfood
  galley re-runs each suite file once per AC referencing it.
- The Signals gate lives in `galley move`, not in `check`: check is a pure
  evaluator others can call; move owns transition-specific requirements.
- `set -euo pipefail` + grep is a trap: every grep that may legitimately not match
  needs `|| true`, and every deliberately-failing command needs a `set +e` window.
