---
id: signal-skill
status: done
galley: learning-loop
autonomy: continuous
---

# Slug: Signal Skill

## Purpose
Create `skills/signal.md` — a quick-capture skill for recording observations mid-session without opening the full review workflow.

## Acceptance checklist
- [ ] `skills/signal.md` exists with clear input/output spec
- [ ] Skill instructions work without a running galley (falls back to `knowledge/signals/scratch.md`)
- [ ] Skill appends a dated bullet: `- YYYY-MM-DD: <observation>` under the Signals section
- [ ] Instructions are ≤20 lines — lightweight, not a ceremony

## Context
The signal should feel like typing a quick note, not running a process. The skill is invoked as `/signal <observation>` or by calling it directly. It should find the most recently active galley's `review.md` automatically.

## Dependencies
None.

## Evidence

`system/skills/signal.md` created at 19 lines. Covers active-galley target, scratch.md fallback, dated-bullet format, and single-call constraint.

---

## Signals
- 2026-06-13: A skill that does exactly one thing (append one bullet) is harder to over-engineer than it looks — resist adding "find active galley" logic beyond what's needed.
- 2026-06-13: The fallback to `knowledge/signals/scratch.md` makes the skill safe to call at any point in a project, not just during an active galley.
- 2026-06-13: 19 lines fit comfortably — the ≤20 line constraint forced removal of an elaborate "find latest galley" algorithm that would have been overkill.
