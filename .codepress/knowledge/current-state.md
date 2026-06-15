# Current State

What this system can do today.

> Seed this file using `skills/bootstrap.md` or fill in manually.
> Update whenever a Galley significantly changes capabilities.

---

## Core capabilities
What the system currently does.

- Galley and Slug lifecycle management (shaping → delivery → review → done)
- Signal capture and Pattern promotion (failure + cost types)
- Budget declaration and cost-check verification
- Self-reported cost tracking per slug via `type: cost` signals

## Live / in production
What is deployed and being used.

- CodePress CLI v0.3

## In progress
What is actively being built (link to active Galleys).

- `product/galleys/ai-finops/` — AI FinOps: cost signal format, budget templates, build integration, verify gate, cost compounding
- `product/galleys/loop-interop-v1/` — Loop interoperability: manifest adoption, signal emission, interop docs

## Known limitations
What it cannot do, or does poorly.

- Cost tracking is self-reported (v0) — no automatic wrapper or provider API integration
- No cross-galley cost trending yet (cost Patterns will enable this as galleys close)
- No budget field validation in the CLI — relies on verify gates

## Last updated
2026-06-15 — Galley `ai-finops` initiated
