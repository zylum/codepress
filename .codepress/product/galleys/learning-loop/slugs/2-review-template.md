---
id: review-template
status: done
galley: learning-loop
autonomy: continuous
---

# Slug: Review Template

## Purpose
Update the review.md template to the four-section structure so galley-close is structured and agent-fillable.

## Acceptance checklist
- [ ] `templates/` review template updated with four sections: Signals / Surprises / Pattern candidates / Knowledge updates
- [ ] Each section has a clear one-line prompt (not empty, not verbose)
- [ ] Existing blank `review.md` files in the project updated to new format

## Context
The new structure must make it obvious what the agent should write in each section. Signals = raw observations. Surprises = what didn't match expectations. Pattern candidates = signals seen in 2+ galleys. Knowledge updates = what changed.

## Dependencies
None (can run in parallel with signal-skill).

## Evidence

`system/templates/review.md` created with four sections and inline comment prompts. `execution-engine-v1/review.md` updated from the old `Patterns`+`Retrospective` structure to the four-section format. Three other existing review.md files already matched the target format.

---

## Signals
- 2026-06-13: One existing review.md (`execution-engine-v1`) used `Patterns` + `Retrospective` instead of `Pattern candidates` + `Surprises` — confirming the template was needed before it diverged further.
- 2026-06-13: Inline HTML comments in the template (rather than empty sections) give agents a prompt without adding ceremony visible in the rendered output.
- 2026-06-13: The templates directory had no review.md despite review.md files being created per galley — a gap that silently allowed format drift.
