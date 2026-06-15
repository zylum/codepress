---
id: af-v1-s5
status: complete
galley: af-v1
autonomy: confirm
budget:
  tokens: 4000
  cost: 0.20
---

# Slug: cost-compounding

## Purpose

Enhance `skills/review.md` to aggregate cost signals at galley-close, compare actual vs budgeted cost, and promote cost Patterns (e.g. "documentation slugs cost 20% of backend slugs") into Knowledge.

## Acceptance checklist

- [ ] `skills/review.md` has a cost aggregation step in the review workflow
- [ ] Cost step reads all `type: cost` signals from the galley's slug files and sums tokens-in, tokens-out, and cost-estimate
- [ ] Cost step compares actual vs budget (from galley frontmatter `budget.tokens` + `budget.cost`) and records variance in `review.md`
- [ ] Cost step proposes Patterns when a slug-type consistently costs more or less than others
- [ ] Cost step is skippable if no cost signals exist (no budget set, no error)
- [ ] Entropy check question updated: "What would make the next galley 20% cheaper?" now specifically prompts the review to reference the aggregated cost data

## Context

The review skill currently has 7 steps. The cost aggregation step fits naturally after step 1 (Gather Signals) and before step 2 (Draft Pattern candidates) — it processes the gathered signals into a cost summary that feeds into Pattern drafting.

The existing entropy question "What would make the next galley 20% cheaper?" should prompt: "Reference the cost-per-slug data from this galley. Which slug type was most expensive? What knowledge, if seeded, would reduce that cost?"

## Dependencies

- af-v1-s1 (cost-signal-format) — reads `type: cost` YAML
- af-v1-s3 (build-cost-capture) — ensures cost signals exist to aggregate
- af-v1-s4 (verify-gate) — consistent budget parsing logic

## Evidence

- `skills/review.md` has cost aggregation step 1b between Gather Signals and Draft Pattern candidates
- Step reads all `type: cost` YAML blocks from slug files, sums tokens-in, tokens-out, cost-estimate
- Compares actual vs budget from galley frontmatter, computes variance %, writes Cost section table to review.md
- Flags overrun if actual > budget (Cost table includes variance row)
- Proposes cost Patterns when slug-type consistently costs more/less
- Skippable: "No cost signals captured — FinOps not active for this galley."
- Entropy question 4 updated: "Reference the cost-per-slug data from the Cost section. Which slug type was most expensive?"

---

## Signals

```yaml
---
type: cost
slug: af-v1-s5
tokens-in: 3500
tokens-out: 600
model: deepseek-v4-flash-free
cost-estimate: 0.00
source: self-reported
---
```

- 2026-06-15: Cost aggregation felt natural as step 1b — it's literally processing the signals you just gathered. It would feel like overhead if cost signals were rare, but the build skill now makes them routine.
- 2026-06-15: The Cost section in review.md uses a markdown table — this is parseable by both humans and agents. Considered JSON but rejected — markdown keeps it consistent with the rest of the review artefact.
