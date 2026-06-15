# Concepts

Core entities in this system and what they do.

> Seed this file using `skills/bootstrap.md` or fill in manually.
> Format: **Name** — one-sentence description. Where it lives.

---

| Concept | Description | Location |
|---|---|---|
| Initiative | A free-form idea or problem worth exploring. The input to the shaping process. | `product/initiatives/` |
| Galley | A shaped solution ready for delivery. Contains Problem, Users, Success, Constraints, Approach, AC, optional budget. | `product/galleys/{name}/galley.md` |
| Slug | An atomic delivery unit with a 3-7 item acceptance checklist. Has autonomy level (continuous/confirm/stop) and a Signals block. | `product/galleys/{name}/slugs/{slug-id}.md` |
| Run Sheet | Defines Slug execution order and parallel groups for a Galley. | `product/galleys/{name}/run-sheet.md` |
| Review | Mandatory galley-close artefact capturing Signals, Surprises, Pattern candidates, Cost, entropy check. | `product/galleys/{name}/review.md` |
| Compound Loop | Signal → Pattern → Knowledge. Raw observations captured per Slug are promoted to Patterns (2+ appearances) and update Knowledge. | `knowledge/` |
| Signal | A raw observation captured during delivery. Three types: observation (free text), failure (structured with rule-changed), cost (structured with token counts). | slug `## Signals` blocks, `knowledge/signals/` |
| Pattern | A generalisable lesson promoted from Signals when they appear in 2+ galleys or are immediately useful. | `knowledge/patterns/` |
| Verify Gate | A shell command that must pass before a Galley's status advances. Defined in codepress.md. | `codepress.md` `verify:` section |
| Loop Fabric | Cross-system standard for declaring loops and emitting signals. CodePress participates via `.loop/manifest.yaml` and `.codepress/loop-events/` outbox. | `.loop/`, `docs/interop.md` |
| Cost Signal | A structured YAML record of token usage and cost per slug. Type: cost, carries tokens-in/out, model, cost-estimate, source. Mirrors the failure signal pattern. | `skills/signal.md` (format), slug `## Signals` blocks (capture) |
| Budget Fence | A declared ceiling for tokens and/or cost in a Galley or Slug frontmatter. The cost-check verify gate enforces it before status transitions. | Galley/Slug frontmatter `budget:` field |
| Cost Pattern | A generalisable lesson about cost that appears in 2+ galleys. Promoted from cost signals during review. E.g. "documentation slugs cost 1/5 of backend slugs". | `knowledge/patterns/` |
| Cost Verify Gate | A shell gate in codepress.md that compares actual cost signals against declared budget and fails on overrun. | `codepress.md` `verify:` section |
