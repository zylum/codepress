# Concepts

Core entities in this system and what they do.

> Seed this file using `skills/bootstrap.md` or fill in manually.
> Format: **Name** — one-sentence description. Where it lives.

---

| Concept | Description | Location |
|---|---|---|
| Cost Signal | A structured YAML record of token usage and cost per slug. Type: cost, carries tokens-in/out, model, cost-estimate, source. Mirrors the failure signal pattern. | `skills/signal.md` (format), slug `## Signals` blocks (capture) |
| Budget Fence | A declared ceiling for tokens and/or cost in a Galley or Slug frontmatter. The cost-check verify gate enforces it before status transitions. | Galley/Slug frontmatter `budget:` field |
| Cost Pattern | A generalisable lesson about cost that appears in 2+ galleys. Promoted from cost signals during review. E.g. "documentation slugs cost 1/5 of backend slugs". | `knowledge/patterns/` |
| Cost Verify Gate | A shell gate in codepress.md that compares actual cost signals against declared budget and fails on overrun. | `codepress.md` `verify:` section |
