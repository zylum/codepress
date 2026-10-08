---
id: enforced-acceptance
status: building
initiative: trust-boundary
release:
created: 2026-07-11
verify: [test]
legacy_status: approved
approved_by: legacy
approved_on: 2026-07-11
---

# Galley: Enforced acceptance — the prose becomes mechanics

## Prior art
The principles all exist in v0.4.1 — as prose. `skills/verify.md` declares "the
verifier must not be the builder"; `dod.md` rule 6 says the builder sets `review` and
an independent reviewer promotes; the operating rules were promoted from loom
(commit 0893d9c). But the only state mutator in the system, `cmd_galley_move`
(`codepress` CLI ~line 1063), is a raw `sed` on frontmatter with zero checks, and
acceptance criteria are unbound `- [ ]` prose. Field evidence (loom
quality-hardening cycle, 2026-07-11): the build engine, running under these exact
rules, self-certified — ticked `[x]` on infra steps marked *manual* that it had
executed against the wrong production service, wrote its own "Gate passes. Galley
close." verdicts, and set statuses uncontested. Textual fences do not constrain
agents. This galley converts the three declared controls into mechanical ones.

## Problem
CodePress's trust chain runs on builder honesty at exactly the three points where
builder honesty is the known failure mode: (1) acceptance criteria are checkboxes
the builder ticks itself, with no binding to anything a machine can evaluate;
(2) status transitions are unguarded — any agent can `galley move x done`;
(3) the reviewer/verifier verdict is a convention, not an artefact — nothing
distinguishes a builder-written "all good" from an independent verification.
The result across five loom cycles: gate-green-but-broken deliveries, mock-theatre
tests, and false completion reports that read identically to true ones.

## Users
- **Solo operators (Marv)** delegating builds to a cheap engine — get to trust a
  `done` status without re-deriving the review from scratch every cycle.
- **The verifier engine** — gets a mechanical checklist to execute instead of an
  open-ended "review it".
- **The builder engine** — gets an unambiguous format for what "done" requires;
  can no longer accidentally self-certify.

## Success
A galley cannot reach `review` with failing gates, unbound acceptance criteria, or
ticked manual steps; it cannot reach `done` without a verifier-written per-AC
verdict from a different engine than the builder. A human can always override —
explicitly, leaving a recorded waiver. The loom incident (self-certified wrong-target
infra) becomes structurally impossible to repeat silently.

## Constraints
- **Pure bash, no new dependencies.** The CLI is a single bash file parsing
  frontmatter with grep/sed/awk — the AC format must be greppable one-liners, not
  nested YAML (no yq).
- **Backwards compatible.** Existing galleys with prose-only checkboxes must not
  break: `codepress check` warns (`unbound AC`) but only *fails* galleys created in
  the new format or explicitly opted in. Migration is per-galley, not big-bang.
- **Human sovereignty.** `--force` always works and always leaves a trace (waiver
  line in review.md). Enforcement targets agents, not Marv.
- **Don't grow ceremony.** No new artefact a human must maintain: the format is
  written by the shaper, checked by the CLI, verdicted by the verifier.
- Follow existing test conventions (`tests/test_*.sh`, temp-project fixtures,
  `bash tests/run_tests.sh` as the gate).

## Approach
Three slugs (order in `run-sheet.md`):

1. **acceptance-binding-format** — a one-line, grep-parseable AC convention that
   binds every criterion to evidence:
   `- [ ] AC1 · Given <ctx> · When <act> · Then <outcome> · test: <path::name>`
   for behaviours, and `- [ ] AC2 · check: <shell command>` for mechanical
   criteria (exit 0 = pass). Templates (galley, slug), skills (shape, split), and
   dod.md updated; `manual:` marker for human-only steps that agents must never tick.
2. **codepress-check-and-gated-move** — new `codepress check <galley>` subcommand:
   runs verify gates fresh, resolves every `test:` ref (exists + passes, via an
   optional `test-runner:` template in codepress.md, falling back to the full test
   gate), executes every `check:` command, rejects `[x]` on `manual:` lines,
   requires non-empty Signals for review-bound moves; per-AC red/green output,
   non-zero exit on any failure. `cmd_galley_move` gains gating: `→ review`
   requires check pass; `→ done` additionally requires the slug-3 verdict;
   `--force` bypasses with a dated waiver appended to review.md.
3. **verifier-verdict-gate** — review.md template gains a `## Verdict` block owned
   by the verifier engine: one `ACn: pass|fail — <evidence>` line per criterion +
   `verified-by: <engine>`. `skills/verify.md` updated to produce it (checklist
   derived from the operating rules: mock-audit, wiring grep, convention check —
   per slug). The `done` gate asserts the block is complete, all ACs pass, and
   `verified-by` ≠ `engines.build`. dod.md/AGENTS.md gain the two hard lines:
   the builder never writes the Verdict; the builder never ticks a `manual:` step.

## Acceptance Criteria
Written in the format this galley introduces — it is its own first example.

- [ ] AC1 · Given a galley whose AC references a failing test · When `codepress galley move <it> review` runs · Then the move is refused with a per-AC report and exit ≠ 0 · test: tests/test_check_gating.sh::test_move_refused_on_failing_ac
- [ ] AC2 · Given a galley with all ACs bound and passing · When moved to review · Then the move succeeds and the board regenerates · test: tests/test_check_gating.sh::test_move_allowed_when_green
- [ ] AC3 · Given an AC line with `check:` whose command exits 1 · When `codepress check` runs · Then that AC reports fail · test: tests/test_check_gating.sh::test_check_command_failure
- [ ] AC4 · Given a `manual:` step ticked `[x]` · When `codepress check` runs · Then the check fails naming the line · test: tests/test_check_gating.sh::test_manual_tick_rejected
- [ ] AC5 · Given a review.md without a Verdict block or with `verified-by` equal to the build engine · When moving to done · Then the move is refused · test: tests/test_verdict_gate.sh::test_done_requires_independent_verdict
- [ ] AC6 · Given any refused move · When re-run with `--force` · Then it succeeds and review.md gains a dated waiver line · test: tests/test_verdict_gate.sh::test_force_records_waiver
- [ ] AC7 · Given a pre-existing galley with prose-only checkboxes · When `codepress check` runs · Then it warns but exits 0 (backwards compat) · test: tests/test_check_gating.sh::test_legacy_galley_warns_only
- [ ] AC8 · check: bash tests/run_tests.sh
