---
id: verifier-verdict-gate
status: complete
galley: enforced-acceptance
autonomy: confirm
budget:
  wall-clock: 3h
  tokens:
  cost:
---

# Slug: verifier-verdict-gate

## Purpose
`done` requires an independent verdict artefact: per-AC pass/fail written by the
verifier engine, provably not the builder. Self-certification ends here.

## Acceptance checklist
- [x] `system/templates/review.md` gains a `## Verdict` section:
      one `ACn: pass|fail — <one-line evidence>` per criterion, then
      `verified-by: <engine>` and `verified-on: <date>`
- [x] `system/skills/verify.md` updated: the verifier executes `codepress check`
      first (mechanics), then the judgment checklist per slug derived from the
      operating rules — does any named test mock its own subject? does every new
      symbol have a caller (grep)? conventions edited at the source? — and writes
      the Verdict block. Keep the existing fresh-context principle text.
- [x] `cmd_galley_move → done` gate (extends slug 02): Verdict block present, every
      AC verdicted, zero fails, and `verified-by` ≠ `engines.build` from
      codepress.md · test: tests/test_verdict_gate.sh::test_done_requires_independent_verdict
- [x] `system/dod.md` + `system/AGENTS.md` gain the two hard lines: the build
      engine never writes the Verdict block; the build engine never ticks a
      `manual:` AC — and note that the CLI enforces both
- [x] Field-evidence note added to `system/AGENTS.md` operating rules: the 2026-07
      loom incident (builder executed a step marked manual against the wrong
      production target and reported it `[x]` complete) as the canonical example of
      why textual fences are insufficient
- [x] All suites green · check: bash tests/run_tests.sh

## Context
Read `system/skills/verify.md` (the verifier-not-builder principle is already
there — this slug gives it teeth), `system/dod.md` rules 1/5/6, `engines:` block in
`system/codepress.md` (build: opencode, verifier: claude). The verdict is judgment
+ mechanics: `codepress check` proves what a machine can; the verifier's checklist
covers what it can't (mock-theatre, dead code, convention bypass).

## Dependencies
02-codepress-check-and-gated-move (the done-gate hook point).

## Evidence
- `system/templates/review.md` gained the `## Verdict` section (per-AC
  `ACn: pass|fail — evidence`, `verified-by:`, `verified-on:`), marked
  verifier-only with the CLI-enforcement note.
- `system/skills/verify.md` rewritten: verifier runs `codepress check` first,
  then the judgment checklist (mock audit, wiring grep, convention check, manual
  steps), then writes the Verdict; fresh-context verifier principle text retained.
- Done gate in the CLI (`check_verdict`): Verdict block present, every bound AC
  verdicted `pass`, zero fails, `verified-by` ≠ `engines.build` (scoped to the
  engines: block of codepress.md; defaults to claude when absent), `verified-on`
  present.
- `system/dod.md` + `system/AGENTS.md` gained the two hard lines (builder never
  writes the Verdict; builder never ticks a `manual:` AC) with the note that the
  CLI enforces both, plus the 2026-07 loom field-evidence blockquote in AGENTS.md.
- `bash tests/test_verdict_gate.sh` — 10 passed, 0 failed (no verdict, builder-
  written verdict, fail line, missing AC line, green verdict passes, defaults
  collide when engines block missing, --force waiver with and without reason,
  waiver on review-move too).

---

## Signals
- Engine identity is config-trust, not auth: `verified-by` is a claim checked
  against `engines.build`. Good enough to stop accidental self-certification;
  a lying engine is out of scope per the run-sheet stop condition (no auth
  mechanism invented).
- When the engines block is missing, build and verifier both default to claude,
  so the verdict gate refuses by default — projects must declare a distinct
  build engine to use the done gate, which is the right pressure.
- Putting the waiver trail in review.md (not frontmatter) keeps overrides inside
  the learning artefact the review skill already reads at galley close.
