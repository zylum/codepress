---
id: agents-update
status: done
galley: learning-loop
autonomy: continuous
---

# Slug: AGENTS Update

## Purpose
Update AGENTS.md to surface the quick-capture mechanic and the "fill Signals before committing" expectation.

## Acceptance checklist
- [ ] Operating rules section updated: "Capture Signals" now says to fill Slug Signals block before each commit
- [ ] Quick-capture mechanic mentioned: `/signal <observation>` for mid-session capture
- [ ] No new sections — edit existing rules, don't add ceremony

## Context
The key change is making "fill Signals" feel like a commit habit, not a review ritual. The operating rule should say "fill the Signals block before you commit" rather than "record signals in review.md".

## Dependencies
Depends on all prior slugs.

## Evidence

`system/AGENTS.md` updated: "Capture Signals" rule already had the correct first sentence; added the quick-capture line beneath it. `skills/signal.md` added to the Skills table.

---

## Signals
- 2026-06-13: The "Capture Signals" rule already contained the key phrase from the acceptance criteria — confirms the spec was written after the rule, not before it.
- 2026-06-13: Adding signal.md to the Skills table in AGENTS.md is the only place an agent would look for available skills — it must be there to be discoverable.
- 2026-06-13: No new section was needed; the edit is two lines — a good sign the change is targeted rather than ceremonial.
