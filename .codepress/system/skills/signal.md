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

3. Emit a `signal_published` event envelope to the loop-events outbox:

   Read `product/galleys/{active-galley}/galley.md` frontmatter for `id`. Read `.loop/manifest.yaml` for `system.id` and the signal's canonical `term`.

   Append to `.codepress/loop-events/{YYYY-MM-DD}.jsonl`:
   ```
   {"id":"<uuid>","type":"signal_published","source_system":"codepress","source_loop":"<galley-id>","ts":"<ISO-8601>","payload":{"id":"<uuid>","source_system":"codepress","source_loop":"<galley-id>","name":"observation","term":"<canonical-term-from-manifest>","value":"<the observation text>","unit":"score","ts":"<ISO-8601>","pointer":null,"consumers":null},"pointer":null}
   ```

   One JSON object per line. Use the active galley ID as `source_loop` if available; omit otherwise.

4. No other changes. Do not open the review workflow. Do not restructure the file.

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

Then emit a `failure_logged` event envelope to the loop-events outbox:

Read `product/galleys/{active-galley}/galley.md` frontmatter for `id` if available.

Append to `.codepress/loop-events/{YYYY-MM-DD}.jsonl`:
```
{"id":"<uuid>","type":"failure_logged","source_system":"codepress","source_loop":"<galley-id or null>","ts":"<ISO-8601>","payload":{"what-failed":"<from above>","rule-changed":"<from above>"},"pointer":null}
```

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

Then emit a `signal_published` event envelope to the loop-events outbox:

Read `product/galleys/{active-galley}/galley.md` frontmatter for `id` if available.

Append to `.codepress/loop-events/{YYYY-MM-DD}.jsonl`:
```
{"id":"<uuid>","type":"signal_published","source_system":"codepress","source_loop":"<galley-id or null>","ts":"<ISO-8601>","payload":{"id":"<uuid>","source_system":"codepress","source_loop":"<galley-id or null>","name":"tokens_per_galley","term":"cost","value":<cost-estimate>,"unit":"currency","ts":"<ISO-8601>","pointer":"<slug-path>","consumers":null},"pointer":null}
```

---

**Invoke:** `/signal <observation>` — or pass the text directly when calling this skill.
