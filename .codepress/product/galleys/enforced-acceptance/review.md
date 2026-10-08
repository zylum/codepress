# Review — enforced-acceptance

Signals captured during delivery. Fill immediately, not at close.

## Signals

- The CLI has no `fm()` frontmatter helper despite folklore — parsing is inline
  grep/sed/awk per call site. `extract_acs` follows that house style (one awk
  program) rather than introducing a parser layer.
- BSD awk matches the UTF-8 middot separator byte-for-byte with a plain literal
  `" · "` — no locale handling needed on macOS or Linux; the grammar survived the
  grep/sed/awk toolchain unchanged.
- codepress.md's verify block was bootstrap placeholders (pytest/tsc/ruff/cargo)
  in a bash-only repo. The dogfood run forced the config to become true:
  `test: bash tests/run_tests.sh`. A gate nobody runs stays wrong silently.
- Self-reference is load-bearing: the galley's AC8 (`check: bash tests/run_tests.sh`)
  makes the full suite run inside `codepress check`, and the suite itself exercises
  `codepress check` in temp projects — a cheap end-to-end proof with no mocks.
  Identical test-runner commands are cached within one check run to keep this sane.
- Backwards compat needed no per-galley opt-in flag: bound vs unbound is decidable
  per line from the markers alone, so legacy prose lines warn (kind=legacy) and
  only bound lines can fail.
- bash 3.2 (macOS /bin/bash) ruled out associative arrays for the runner cache —
  parallel indexed arrays instead; `set -euo pipefail` required `|| true` guards
  on every grep that may legitimately not match.
- The `::name` part of a test ref is asserted to exist in the file (grep) before
  running — the ref cannot silently point at a renamed/deleted test while the
  file still passes.

## Knowledge updates needed

- current-state.md: document `codepress check`, the AC binding grammar, the gated
  `galley move` (review = check + Signals, done = check + independent Verdict),
  `--force` waiver trail, and the `test-runner:` config line.
- Pattern candidate: "textual fences do not constrain agents — convert declared
  controls into mechanical ones at the single state mutator" (seen in loom 2026-07,
  now here).

## Verdict
AC1: pass — fresh run: test_move_refused_on_failing_ac green; refusal reproduced live against this galley (`galley move ... done` → exit 1, status unchanged)
AC2: pass — test_move_allowed_when_green green in fresh full-suite run
AC3: pass — test_check_command_failure green; check: semantics confirmed in cmd_check source
AC4: pass — test_manual_tick_rejected green; ticked-manual failure names the line
AC5: pass — test_done_requires_independent_verdict green; adversarial probe on this very galley refused for missing Verdict + verifier-only message
AC6: pass — test_force_records_waiver green; waiver line format verified in test source
AC7: pass — test_legacy_galley_warns_only green; bound-vs-unbound decidable per line, no opt-in flag needed (accepted deviation)
AC8: pass — `bash tests/run_tests.sh` fresh: 43 passed, 0 failed (13 pre-existing + 30 new)

Judgment checklist: tests drive the real CLI against temp CodePress projects (no
mocks of the unit under test — verified by reading test_check_gating.sh fixtures);
extract_acs wired into cmd_check (:1226) and the move gate (:1397); conventions
edited at source (templates/skills/dod, not generated views); deviations 1–7 in the
builder report reviewed and accepted (most notably: codepress.md verify gate
corrected to the repo's real command — a gate nobody runs stays wrong silently).
Caveat for the record: the builder was a Claude subagent directed by this session,
not opencode; the gate's engine comparison (verified-by ≠ engines.build=opencode)
holds, and verification here was performed by fresh independent runs + code reading.

verified-by: claude
verified-on: 2026-07-11
