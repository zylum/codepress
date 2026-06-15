---
id: li-v1
status: done
initiative: li-001
release:
created: 2026-06-14
verify:
holdout: false
budget:
  wall-clock: 1d
  tokens:
  cost:
---

# Galley: Loop Interop v1

## Problem

CodePress runs governed loops but cannot tell anyone else about them. We need CodePress to declare its loops and emit its signals against the neutral `loop-spec`, so a connector and an awareness layer can observe it — without CodePress depending on either.

## Users

The loop fabric: a connector (discovers + syncs CodePress) and a memory/awareness layer (shows which loops exist and how they're doing). Also CodePress users who want their work visible system-wide.

## Success

A connector pointed at the CodePress repo can: (1) read a valid `.loop/manifest.yaml`, (2) discover the loops and their canonical signal terms, and (3) obtain signal observations — either derived from git history or, ideally, emitted at galley close. CodePress names no consumer anywhere.

Minimum acceptable: a committed, schema-valid `.loop/manifest.yaml` declaring CodePress's real loops with signals mapped to canonical terms.

## Constraints

- **Decoupling invariant:** the manifest and any emitted payloads name only CodePress. No reference to garner/loom/the-dreaming.
- Stay model-agnostic and dependency-light (bash + markdown). No new runtime services.
- Conform to `loop-spec` v0.1 at `/Users/marv/code/loop-spec`. If the spec needs to change, change it there and bump `spec_version` — don't fork it.
- Do not regress `loop-grade-execution` behaviour.

## Approach

Two layers, smallest first:

1. **Declare** — author `.loop/manifest.yaml` at repo root from `loop-spec/examples/codepress.loop.yaml`, adjusted to the real loops and metrics. Map each metric to a canonical term (latency / quality / friction / cost). Add a validator check.
2. **Emit** — at slug/galley close, in addition to writing `knowledge/signals/`, produce a `signal_published` event envelope (per `loop-spec/events.md`) to a local outbox (e.g. `.codepress/loop-events/`) that a connector can read. This keeps CodePress emitting without knowing who consumes.

v0 works with declare-only (connector derives events from commits). Emit is the v1 enrichment and the more valuable half — but ships second.

## Acceptance Criteria

- [x] `.loop/manifest.yaml` exists at repo root and validates against `loop-spec/manifest.schema.yaml`
- [x] Manifest declares CodePress's real loops (at least galley-delivery + knowledge-learning) with `type`, `goal`, `verifier`, `state_pointer`
- [x] Every emitted signal maps a local name to a canonical `term` from `events.md`
- [x] Galley/slug close writes a `signal_published` envelope to a local outbox (valid per `events.md`)
- [x] A `failure_logged` event carries its `rule-changed` (reusing existing failure-signal format)
- [x] No file in CodePress names garner, loom, or the-dreaming
- [x] Docs updated: how CodePress participates in the loop fabric
