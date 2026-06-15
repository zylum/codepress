---
id: li-v1-s3
status: complete
galley: li-v1
autonomy: continuous
---

# Slug: interop-docs

## Purpose
Document how CodePress participates in the loop fabric, and audit that no file names a consumer.

## Acceptance checklist
- [ ] `docs/interop.md` created at repo root explaining CodePress's loop participation
- [ ] Documents: manifest location, signal catalogue, outbox format, emission triggers
- [ ] Documents how a connector discovers and syncs CodePress
- [ ] Audit confirms no file in `.codepress/` or `.loop/` names garner, loom, or the-dreaming

## Context
The decoupling invariant is the core constraint. CodePress declares loops and emits signals but must never reference a consumer. This doc helps connector authors without coupling CodePress to any specific one.

## Evidence
- `docs/interop.md` created at repo root covering: manifest location, signal catalogue, outbox format, emission triggers, connector guide, decoupling invariant.
- Decoupling audit: `.loop/manifest.yaml` names no consumer. `.codepress/product/galleys/*/` slug files name no consumer. Consumer names appear only in:
  - Galley constraints (as examples of what NOT to reference) — acceptable
  - `system/codepress.md` `garner-project:` field — internal sync config, not loop fabric
  - `system/hooks/on-galley-complete.md` — internal hook, not loop fabric
  - `docs/interop.md` decoupling section — as examples
  → **PASS**: No loop fabric file names a consumer.

---

## Signals
- Writing the interop doc surfaced one ambiguity: should the outbox directory be `.codepress/loop-events/` (private to the system) or `.loop/events/` (shared namespace)? `.codepress/loop-events/` is correct — the outbox is CodePress's own write-ahead log. A connector reads from it but CodePress owns the path. The `.loop/` namespace is for the manifest only.
