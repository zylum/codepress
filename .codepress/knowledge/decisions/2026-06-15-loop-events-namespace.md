---
date: 2026-06-15
context: loop-interop-v1
status: settled
---

# Decision: Loop events outbox namespace

## Problem

Where should emitted `signal_published` and `failure_logged` event envelopes live?

## Options considered

1. `.loop/events/` — shared namespace alongside the manifest
2. `.codepress/loop-events/` — private namespace inside CodePress's own config directory
3. `.codepress/loop-events/` — correct choice

## Decision

Use `.codepress/loop-events/`. The outbox is CodePress's own write-ahead log. The `.loop/` namespace is reserved for the single shared contract (`manifest.yaml`). A connector reads both but writes to neither.

## Rationale

- Keeps the manifest (schema-validated, shared) separate from runtime data (append-only, private)
- Follows the principle that each system owns its data directory
- Prevents the shared `.loop/` namespace from becoming a dumping ground for different systems' runtime artefacts
- Consistent with how CodePress already owns `.codepress/` for all its runtime state

## Consequences

- Connectors must read two paths: `.loop/manifest.yaml` for discovery, `.codepress/loop-events/` for events
- The outbox directory is specific to CodePress — other systems in the loop fabric would use their own paths
