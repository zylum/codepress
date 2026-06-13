# Review: Learning Loop

## Signals
- 2026-06-13: The `templates/` directory had no `review.md` despite galley-created review files existing — format drift was already visible in `execution-engine-v1`.
- 2026-06-13: The old `skills/review.md` step 1 asked agents to recall observations from memory; replacing it with "read Slug Signals blocks" removes the highest-friction point at galley-close.
- 2026-06-13: The ≤20 line constraint on signal.md forced removal of an elaborate active-galley lookup — the simpler heuristic (caller passes galley id, or falls back to scratch.md) is more robust.
- 2026-06-13: `[ ] proposed` markers on Pattern candidates make the human approval gate visible in the file rather than implicit in agent behaviour.

## Surprises
- 2026-06-13: AGENTS.md already contained the correct "fill Signals before committing" phrasing — the spec was written after that rule, so slug 4 was lighter than expected.
- 2026-06-13: Three of four existing review.md files already had the four-section format; only `execution-engine-v1` used the old structure.

## Pattern candidates
- [ ] proposed: Missing template → format drift. When a file type is created repeatedly without a canonical template, format diverges silently. Fix: create the template before the second instance.
- [ ] proposed: File-sourced review beats memory recall. Aggregating from Slug Signals blocks at galley-close is more reliable than asking the agent to recall from memory. Apply this to any structured retrospective.

## Knowledge updates
- `system/templates/review.md` created — canonical four-section format now exists.
- `system/skills/signal.md` created — quick-capture skill available for mid-session use.
- `system/skills/review.md` updated — step 1 now sources from Slug files, not memory; rework detection added.
- `system/AGENTS.md` updated — quick-capture mechanic surfaced in operating rules and Skills table.
- `execution-engine-v1/review.md` migrated to four-section format.
