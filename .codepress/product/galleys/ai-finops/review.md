# Review: AI FinOps v1

## Signals

- The cost format slotted naturally after the failure section — no structural friction. Mirroring the `type: failure` YAML pattern made the format feel like a convention, not a new thing.
- Inline YAML comments work fine for human readers but are stripped by most YAML parsers — the cost-check gate reads the value, not the comment, so this is safe.
- The cost step fits naturally between evidence and signals — it's essentially a structured variant of "what did this cost?" alongside "what did I learn?"
- The bash gate works without yq but the `sed -n '/type: cost/,/^---/p'` range pattern is fragile — acceptable for v0.
- Cost aggregation felt natural as step 1b — it's literally processing the signals you just gathered.
- Knowledge stubs were easy to extend — the table format in concepts.md and glossary.md is straightforward.

## Surprises

- The `.loop/manifest.yaml` already existed from loop-interop-v1 — no conflict, the annotation was a simple description update. The two galleys compose cleanly.
- The cost-check gate glob `grep -A3 '^budget:' .codepress/product/galleys/*/galley.md` could match multiple galleys — it works for single active delivery but would need a target galley parameter for multi-galley projects.

## Cost

| Metric | Budget | Actual | Variance |
|---|---|---|---|
| Tokens | 40000 | 17500 | -56% |
| Cost | $2.00 | $0.00 | -100% |
| Most expensive slug | af-v1-s4 (verify-gate) | $0.00 | |

### Per-slug breakdown
| Slug | Model | Tokens-in | Tokens-out | Cost |
|---|---|---|---|---|
| af-v1-s1 (cost-signal-format) | deepseek-v4-flash-free | 3500 | 800 | $0.00 |
| af-v1-s2 (budget-templates) | deepseek-v4-flash-free | 2000 | 400 | $0.00 |
| af-v1-s3 (build-cost-capture) | deepseek-v4-flash-free | 2500 | 500 | $0.00 |
| af-v1-s4 (verify-gate) | deepseek-v4-flash-free | 4000 | 700 | $0.00 |
| af-v1-s5 (cost-compounding) | deepseek-v4-flash-free | 3500 | 600 | $0.00 |
| af-v1-s6 (knowledge-seed) | deepseek-v4-flash-free | 2000 | 400 | $0.00 |

Budget well under — this galley used a free model, so cost reflects only token consumption patterns. The verify-gate slug was most token-intensive (4700 total).

## Pattern candidates

- [x] proposed: **Structured signal convention** — promoted to `knowledge/patterns/structured-signal-convention.md`

## Knowledge updates

- `knowledge/concepts.md` — added Cost Signal, Budget Fence, Cost Pattern, Cost Verify Gate
- `knowledge/glossary.md` — added tokens-in, tokens-out, cost-estimate, self-reported, budget variance, cost-check
- `knowledge/current-state.md` — updated capabilities, in-progress, limitations
- `.loop/manifest.yaml` — annotated `tokens_per_galley → cost` description with FinOps pipeline note

## Entropy

1. **Did we improve the system, or just deliver a feature?**
   Both. The system now has an operational cost pipeline — budget declarations, cost signal capture, verify gates, and cost compounding at review. Before this galley, budget fields were dead metadata. Now they're wired into build, verify, review, and status.

2. **What rule did this Galley discover?**
   Cost signals should follow the same structural convention as failure signals. A consistent YAML frontmatter pattern across signal types reduces cognitive overhead for builders.

3. **Did we plateau?**
   No — this was new capability, not iteration on existing patterns.

4. **What would make the next galley 20% cheaper?**
   The verify-gate slug was the most token-intensive (4700 total). Reason: the bash gate script required multiple iterations to handle edge cases (empty budgets, missing signals, integer vs float comparison). If the `cost-check` gate were a reusable script reference rather than inline bash in YAML, future galleys wouldn't pay this design cost again. Consider extracting the gate to `.codepress/system/gates/cost-check.sh`.

## Holdout verdict

Not applicable — `holdout: false`.
