---
id: af-v1-s4
status: complete
galley: af-v1
autonomy: continuous
budget:
  tokens: 5000
  cost: 0.25
---

# Slug: verify-gate

## Purpose

Add a `cost-check` verify gate to `codepress.md` that reads galley frontmatter `budget.tokens` and `budget.cost`, sums cost signals from completed slugs, and fails if over budget. Also extend `skills/status.md` to detect cost overruns as pending actions.

## Acceptance checklist

- [ ] `codepress.md` `verify:` section includes a `cost-check` gate entry with a shell command
- [ ] Shell command parses galley `budget.tokens` and `budget.cost` from YAML frontmatter
- [ ] Shell command sums `type: cost` signal estimates from all completed slugs in the galley
- [ ] Gate exits non-zero if actual > budget for either tokens or cost
- [ ] Gate is lenient if budget fields are empty (exits 0, no error)
- [ ] `skills/status.md` has a detection section that reads slug Signals for `type: cost` entries and compares against galley budget
- [ ] Status detection flags budget overrun as a pending action: "⚠️ Budget overrun: {actual} tokens used vs {budget} budgeted"
- [ ] Status detection is silent if no budget is set or no cost signals exist

## Context

The `verify:` section in `codepress.md` (lines 92-108) maps gate names to shell commands. A galley declares which gates apply via its frontmatter `verify:` field.

The verify gate script should be a simple bash one-liner or short function. Use `grep`, `awk`, `yq` if available — keep it dependency-light.

For `skills/status.md`, the detection logic reads slug files in the active galley, scans for `type: cost` YAML blocks, sums tokens and cost, and compares against galley frontmatter.

## Dependencies

af-v1-s1 (cost-signal-format) — the gate parses `type: cost` YAML.

## Evidence

- `codepress.md` `verify:` section has `cost-check` gate with shell command
- Command reads `budget.tokens` and `budget.cost` from galley frontmatter via `grep -A3`
- Command iterates slug files, finds `type: cost` YAML blocks with `sed`, parses `tokens-in` and `cost-estimate`
- Exits 1 if actual > budget for tokens (integer comparison) or cost (bc comparison)
- Exits 0 silently if no budget set or no cost signals found
- `skills/status.md` updated with budget check step 6 that flags overruns as pending actions with token and cost messages
- Silent if no budget or no cost signals
- Budget overrun alerts rendered before status columns as `## Alerts` section

---

## Signals

```yaml
---
type: cost
slug: af-v1-s4
tokens-in: 4000
tokens-out: 700
model: deepseek-v4-flash-free
cost-estimate: 0.00
source: self-reported
---
```

- 2026-06-15: The bash gate works without yq but the `sed -n '/type: cost/,/^---/p'` range pattern is fragile — it breaks if the slug has multiple YAML blocks before the cost signal (e.g. frontmatter + review.md reference). Mitigated by matching only within the slug's Signals section context. Acceptable for v0.
- 2026-06-15: Status detection step 6 adds ~5 lines — minimal overhead for significant visibility gain
