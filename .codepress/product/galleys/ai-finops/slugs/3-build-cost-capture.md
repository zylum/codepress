---
id: af-v1-s3
status: complete
galley: af-v1
autonomy: continuous
budget:
  tokens: 3000
  cost: 0.15
---

# Slug: build-cost-capture

## Purpose

Add a cost-capture step to `skills/build.md` so every slug records its token usage and estimated cost as part of the standard build workflow — immediately before the existing Signals block capture.

## Acceptance checklist

- [ ] `skills/build.md` has a step 6.5 (or equivalent) between "Record evidence" and "Fill the Signals block" that instructs the builder to capture cost
- [ ] Cost capture step references the `type: cost` format from `skills/signal.md`
- [ ] Cost capture step documents what to record: model name, input tokens, output tokens, estimated cost
- [ ] Instructions say to add the cost signal to the slug's `## Signals` block as a YAML frontmatter code block
- [ ] Existing build steps unchanged — the new step is additive only

## Context

The build skill currently has 8 steps (1-8) under `## Per Slug`. The new cost step goes between step 6 ("Record evidence") and step 7 ("Fill the Signals block"). It should reference the cost signal format defined in slug 1.

Self-reported is v0. The instruction should say: "Estimate your token usage based on context size and responses. If you don't know exact counts, provide your best estimate and set `source: estimated`."

## Dependencies

af-v1-s1 (cost-signal-format) — this slug references the `type: cost` format.

## Evidence

- `skills/build.md` updated with new step 4 (read galley budget) and step 8 (capture cost) between existing step 6 (record evidence) and step 9 (fill Signals block)
- Step 8 references `type: cost` format from `skills/signal.md`
- Documents what to record: model name, input tokens, output tokens, estimated cost
- Instructions say to add YAML block to slug's `## Signals` section, use `source: estimated` if exact counts unknown
- Existing build steps unchanged — additive only (old 8 steps → new 10 steps)

---

## Signals

```yaml
---
type: cost
slug: af-v1-s3
tokens-in: 2500
tokens-out: 500
model: deepseek-v4-flash-free
cost-estimate: 0.00
source: self-reported
---
```

- 2026-06-15: The cost step fits naturally between evidence and signals — it's essentially a structured variant of "what did this cost?" alongside "what did I learn?"
- 2026-06-15: Numbering shifted from 8 to 10 steps; checked that no playbooks reference the old step numbers — they don't, they reference step descriptions
