# Loop Interop — CodePress Participation

CodePress participates in the loop fabric by declaring its loops in a standard manifest and emitting signal events at lifecycle points. It names no consumer — the fabric discovers CodePress; CodePress does not reach out.

---

## Manifest

`.loop/manifest.yaml` at the repo root declares:

| Loop | Type | Goal |
|---|---|---|
| `galley-delivery` | reinforcing | Close galleys that meet acceptance criteria with minimal rework |
| `knowledge-learning` | balancing | Turn delivery failures into rules so the same failure does not recur |

Signals are mapped to canonical terms for cross-system legibility.

---

## Signal catalogue

| Local name | Canonical term | Unit | Direction |
|---|---|---|---|
| `time_to_first_value` | `latency` | seconds | lower_better |
| `verifier_pass_rate` | `quality` | ratio | higher_better |
| `rework_rate` | `friction` | ratio | lower_better |
| `tokens_per_galley` | `cost` | count | lower_better |

---

## Outbox format

Signal events are written to `.codepress/loop-events/{YYYY-MM-DD}.jsonl` in JSONL format (one JSON object per line, append-only).

### Event types emitted

| Event | Trigger | Payload |
|---|---|---|
| `signal_published` | Signal capture (observation, cost) | `Signal` per loop-spec §1 |
| `failure_logged` | Failure capture | `what-failed` + `rule-changed` per loop-spec §2 |

### Envelope shape

```yaml
Event:
  id: uuid
  type: signal_published | failure_logged
  source_system: codepress
  source_loop: <galley-id or null>
  ts: ISO-8601
  payload: <Signal or failure payload>
  pointer: null
```

---

## Connector guide

A connector pointed at this repo:

1. **Discover:** read `.loop/manifest.yaml` — detect `discovery.fingerprints` for additional markers
2. **Sync:** `sync.strategy: git_head_diff` — poll every 5 minutes per `sync.interval`
3. **Derive or read events:**
   - From git: parse commit messages matching `slug:<name> done` / `galley:<name> done`
   - From live: read `.codepress/loop-events/` JSONL files since last poll, discard processed rows
4. **Transduce:** map local signal names to canonical `term` using the manifest's signal catalogue before forwarding to awareness layers

---

## Decoupling invariant

No file in `.codepress/` or `.loop/` names a consumer system (garner, loom, the-dreaming). CodePress declares and emits; the fabric connects. If you need to add a consumer, add it in the connector — not here.
