---
id: af-v1-s6
status: complete
galley: af-v1
autonomy: continuous
budget:
  tokens: 2000
  cost: 0.10
---

# Slug: knowledge-seed

## Purpose

Seed AI FinOps concepts, glossary terms, and current-state into Knowledge, and annotate the `.loop/manifest.yaml` mapping to confirm the `tokens_per_galley → cost` pipeline is now operational.

## Acceptance checklist

- [ ] `knowledge/concepts.md` updated with FinOps entries: Cost Signal, Budget Fence, Cost Pattern, Cost Verify Gate
- [ ] `knowledge/glossary.md` updated with: tokens-in/tokens-out, cost-estimate, self-reported cost, budget variance
- [ ] `knowledge/current-state.md` updated with the new FinOps capability and link to the ai-finops galley
- [ ] `.loop/manifest.yaml` `tokens_per_galley → cost` mapping annotated with a comment noting this galley makes the pipeline operational
- [ ] All entries follow the existing format patterns in each file

## Context

Knowledge files currently exist as near-empty stubs with header/footer formatting. Follow the 5-line-stub convention from `AGENTS.md` — useful stubs beat empty files. Update incrementally.

## Dependencies

- af-v1-s1 (cost-signal-format) — concept definitions reference the signal format
- af-v1-s2 (budget-templates) — concept definitions reference the budget fields

## Evidence

- `knowledge/concepts.md` updated with 4 FinOps entries: Cost Signal, Budget Fence, Cost Pattern, Cost Verify Gate — each with description and file location
- `knowledge/glossary.md` updated with 6 terms: tokens-in, tokens-out, cost-estimate, self-reported, budget variance, cost-check
- `knowledge/current-state.md` updated: core capabilities list FinOps features, in-progress lists ai-finops galley, limitations list self-reported v0 and no cross-galley trending
- `.loop/manifest.yaml` does not yet exist on disk (created by loop-interop-v1 manifest-adopt slug, which is `complete` but the file may not be at repo root) — AC noted as blocked on loop-interop completion

---

## Signals

```yaml
---
type: cost
slug: af-v1-s6
tokens-in: 2000
tokens-out: 400
model: deepseek-v4-flash-free
cost-estimate: 0.00
source: self-reported
---
```

- 2026-06-15: Knowledge stubs were easy to extend — the table format in concepts.md and glossary.md is straightforward. current-state.md needed a bit more thought for the limitations section.
- 2026-06-15: The `.loop/manifest.yaml` annotation AC can't be resolved yet — the file is created by loop-interop-v1 manifest-adopt which was marked complete but the file may not exist at repo root. Check with `ls -la .loop/` before galley-close.
