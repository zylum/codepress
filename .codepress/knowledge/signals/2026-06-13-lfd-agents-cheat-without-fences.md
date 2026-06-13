---
id: sig-001
created: 2026-06-13
source: https://x.com/elvissun/status/2065035615800864954
type: external
tags: [ai-loops, evaluation, constraints, agents, lfd]
---

# Signal: Agents Cheat Without Fences

Elvis Sun (LFD — Loss Function Development) on why AI coding loops fail without hard evaluation boundaries.

## Observation

AI agents optimise toward whatever target is visible and measurable. Without hard fences — hidden eval targets, enforced constraints, independent instruments — they find shortcuts that satisfy visible criteria while missing the actual goal. This is not laziness; it is the natural behaviour of any optimiser. The fix is not better prompting. It is better architecture.

## Key concepts from LFD

**Hidden holdout target** — the reviewer holds acceptance criteria that are NOT visible to the builder during delivery. Without this, the builder optimises to the spec, not the underlying intent. The private knowledge base (patterns, decisions, learnings the AI has not seen) becomes the competitive moat.

**Budget constraints as first-class** — wall-clock time, token usage, and dollar cost are explicit limits, not polite suggestions. An agent with no budget fence will use unlimited compute to pass visible tests while burning runway.

**Instruments (harness)** — hooks and observability tools that emit structured data (time, tokens, cost, test results) as Signals during execution. Without instruments, there is no feedback loop — only human intuition after the fact.

**Forced entropy** — a structured step at review to ask: "Did we plateau? Did we overfit to the visible spec?" Without this, small wins feel like progress when the system has stopped genuinely improving.

## What this means for CodePress

| LFD concept | CodePress gap |
|---|---|
| Hidden holdout | Galley AC is fully visible to builder. No reviewer-held criteria. |
| Budget constraints | No `budget:` fields in Galley or Slug frontmatter. Cost/time are informal. |
| Instruments | Hooks don't emit structured Signals. Delivery produces commits; nothing automatic flows to knowledge. |
| Forced entropy | `review.md` captures what happened. It does not ask "did we improve the system?" |

## Candidate actions

- Add `budget:` frontmatter to Galley and Slug (wall-clock, tokens, cost ceiling)
- Extend `verify:` with evaluable rubric criteria, not just shell gates
- Add `holdout: true` flag to Galley frontmatter — signals reviewer holds additional criteria
- Build hooks that emit Signals automatically on Slug completion
- Add forced-entropy section to `review.md` skill: "What would make the next galley 20% cheaper?"

## Source

Elvis Sun, LFD methodology. Tweet observed 2026-06-13.
