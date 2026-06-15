# Skill: Signal

Quick-capture an observation mid-session without running a full review.

---

## Observation signal (default)

1. Identify the target file:
   - If a galley is active, use `product/galleys/{id}/review.md`
   - If no active galley, use `knowledge/signals/scratch.md` (create if absent)

2. Append under the `## Signals` section:
   ```
   - YYYY-MM-DD: <observation>
   ```
   Use today's date. One bullet per call. Keep the observation to one sentence.

3. No other changes. Do not open the review workflow. Do not restructure the file.

---

## Failure signal

When capturing a failure — a gate that didn't pass, an assumption that broke, a rework incident — use the structured failure format instead. Create a file in `knowledge/signals/` or append to `review.md`:

```yaml
---
type: failure
what-failed: "<specific gate, test, or criterion that failed>"
why: "<root cause — be honest, not diplomatic>"
rule-changed: "<generalisable lesson — the rule the system should follow next time>"
---
```

`rule-changed` is mandatory. A failure without a lesson is just an incident log. A failure with a rule is a Pattern candidate.

---

## Cost signal

When capturing token usage and cost for a slug during delivery, use the structured cost format. Append to the slug's `## Signals` block or create a file in `knowledge/signals/`:

```yaml
---
type: cost
slug: <slug-id>
tokens-in: <integer>
tokens-out: <integer>
model: <model-name>
cost-estimate: <float>
source: <self-reported | wrapper | estimated>
---
```

Fields:

| Field | Required | Description |
|---|---|---|
| `slug` | yes | The slug ID this cost entry covers |
| `tokens-in` | yes | Input/prompt token count |
| `tokens-out` | yes | Output/completion token count |
| `model` | yes | Model used (e.g. `claude-sonnet-4-20250514`) |
| `cost-estimate` | yes | Estimated USD cost |
| `source` | yes | How the data was captured: `self-reported` (builder estimate), `wrapper` (provider API wrapper), `estimated` (best guess without exact counts) |

Self-reported is the default. If exact counts are unavailable, estimate and set `source: estimated`.

Cost signals feed the `cost-check` verify gate (defined in `codepress.md`). Without them, budget enforcement cannot run.

---

**Invoke:** `/signal <observation>` — or pass the text directly when calling this skill.
