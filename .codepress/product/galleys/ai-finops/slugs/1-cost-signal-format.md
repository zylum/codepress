---
id: af-v1-s1
status: complete
galley: af-v1
autonomy: continuous
budget:
  tokens: 3000
  cost: 0.15
---

# Slug: cost-signal-format

## Purpose

Extend `skills/signal.md` with a `type: cost` YAML variant so builders can capture token usage and cost estimates in the same structured format as the existing `type: failure` signals.

## Acceptance checklist

- [ ] `skills/signal.md` has a `## Cost signal` section after the existing `## Failure signal` section
- [ ] Cost signal format documented with YAML frontmatter fields: `type`, `slug`, `tokens-in`, `tokens-out`, `model`, `cost-estimate`, `source`
- [ ] `source` field documents allowed values: `self-reported`, `wrapper`, `estimated`
- [ ] Cost signals store to the same location (`knowledge/signals/` or slug `## Signals` block) as other signal types
- [ ] Existing `type: failure` and observation signal behaviour completely unchanged

## Context

The Galley's `budget:` fields (`tokens`, `cost`) declare the expected spend. The cost signal captures the actual spend per slug. The verify gate (slug 4) compares them.

Follow the exact same structural pattern as `type: failure` in signal.md — YAML frontmatter block with required fields, described in a `## Cost signal` subsection.

## Dependencies

None. This modifies only `skills/signal.md`.

## Evidence

- `skills/signal.md` updated with `## Cost signal` section after `## Failure signal`
- Cost signal YAML format defined with all required fields: slug, tokens-in, tokens-out, model, cost-estimate, source
- `source` field documents three allowed values: self-reported, wrapper, estimated
- Cost signal stored to same location as other signal types (slug `## Signals` block or `knowledge/signals/`)
- Existing `type: failure` and observation signal sections completely unchanged
- Verified by reading file — all AC items met

---

## Signals

```yaml
---
type: cost
slug: af-v1-s1
tokens-in: 3500
tokens-out: 800
model: deepseek-v4-flash-free
cost-estimate: 0.00
source: self-reported
---
```

- 2026-06-15: The cost format slotted naturally after the failure section — no structural friction. Mirroring the `type: failure` YAML pattern made the format feel like a convention, not a new thing.
- 2026-06-15: Initially considered adding unit fields (e.g. `cost-currency: USD`) but decided to keep it minimal for v0. Can add later if multi-currency needed.
