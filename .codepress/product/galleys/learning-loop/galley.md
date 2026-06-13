---
id: learning-loop
status: done
initiative: 
release: 
created: 2026-06-13
verify: []
---

# Galley: Learning Loop

## Problem
Learning is deferred to galley-close, which is the moment least likely to happen. Signals accumulate in `review.md` but are rarely promoted to Patterns. The compound loop is theoretically sound but practically skipped. The system grows in volume but not in understanding.

## Users
AI agents and humans building inside a CodePress project. They lose context between sessions, repeat discoveries, and don't benefit from past work.

## Success
- Signals are captured *during* delivery (at the Slug commit moment), not after
- `review.md` has a structured format that an agent can fill without friction
- At galley-close, the model drafts Pattern candidates — human approves, not writes
- Rework is annotated in commit messages so the review skill can surface it
- A quick signal capture mechanism works mid-session without opening a file

## Constraints
- No new tooling required — markdown only, platform-agnostic
- Works with the existing skill dispatch (the `review` skill already exists after Phase 1)
- Must not add more ceremony for simple work — the change should feel lighter, not heavier

## Approach
Three targeted changes:

1. **Signals in the slug template** — the Signals block (added in Phase 1) is now the primary capture point. Fill 2–3 bullets before the commit. This pushes signal capture to the lowest-friction moment.

2. **Structured `review.md` template** — four sections (Signals / Surprises / Pattern candidates / Knowledge updates). At galley-close, the agent reads the Slug Signals blocks and synthesises them into this template. Human only approves pattern candidates, never writes from scratch.

3. **`skills/signal.md` quick-capture** — a one-line skill callable mid-session. Appends a dated bullet to the active galley's `review.md` Signals section without requiring the full review skill.

## Acceptance Criteria
- [ ] `skills/signal.md` exists and works: given a galley ID + observation, appends to `review.md`
- [ ] `review.md` template updated to the four-section structure
- [ ] `skills/review.md` updated: step 1 reads Slug Signals blocks first (not just the Galley file), drafts pattern candidates
- [ ] The Loom project's existing `review.md` files converted to the new format
- [ ] AGENTS.md updated to reference the quick-capture mechanic
