---
status: proposed
source: loop-interop-v1 review
---

## Pattern: Outbox owned by source

The event outbox belongs to the source system's private namespace, not the shared loop namespace.

### Problem

Where should signal event envelopes be written? The `.loop/` directory is the obvious shared namespace, but putting the outbox there couples the source system's write-ahead log to a shared contract.

### Approach

Use the source system's private path for the outbox (e.g. `.codepress/loop-events/` for CodePress), and use `.loop/` only for the manifest:

- `.loop/manifest.yaml` — shared contract, schema-validated, declares loops and signals
- `.codepress/loop-events/` — source's private write-ahead log, append-only JSONL, no schema required

A connector reads both: the manifest for discovery and mapping, the outbox for events. The connector never writes to either.

### When to use

Whenever adding loop fabric participation to a system that already has a private config directory.

### When not to use

If the system has no private config directory — create one rather than polluting the shared namespace with runtime data.

### Evidence

The ambiguity surfaced during interop-docs writing for CodePress. `.codepress/loop-events/` was the correct choice — it keeps the outbox as CodePress's own write-ahead log and the `.loop/` namespace as the single shared contract.
