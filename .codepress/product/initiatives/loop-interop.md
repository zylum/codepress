---
id: li-001
status: galley-ready
created: 2026-06-14
---

# Initiative: Loop Interop (participate in the cross-system loop fabric)

## Problem

`loop-grade-execution` (lge-001, done) gave CodePress an internal value-loop: independent verifier, machine-evaluable DoD, structured failure memory, forced-entropy review. But those signals stay **trapped inside CodePress**. Other systems (a memory/awareness layer, a console) cannot see which loops CodePress runs, how they're doing, or when one fails.

For CodePress to be System 1 in a larger loop system, it must **declare its loops and emit its signals outward** — through a neutral contract, without hard-coding any consumer.

## Context

A neutral standard now exists: `loop-spec` (`manifest.schema.yaml`, `events.md`, worked example `examples/codepress.loop.yaml`). It defines `.loop/manifest.yaml` (declare loops + signals) and a signal/event vocabulary with canonical terms (transduction).

The decoupling invariant is non-negotiable: **CodePress declares only itself. It never names any consumer.** A connector discovers CodePress via its manifest and derives events from git history (v0) or receives emitted signals (v1).

This is galley C2 in the loop programme.

## Why now

The internal loop is built and the standard is drafted. Emitting signals now — while the standard is v0.1 and CodePress is the reference participant — is what proves the standard is real and shapes it before other systems adopt it.

## Thoughts

- The manifest is mostly authored already (`loop-spec/examples/codepress.loop.yaml`) — adopting it is small.
- Map existing CodePress metrics (time-to-first-value, verifier pass rate, rework, tokens) to canonical terms (latency, quality, friction, cost).
- Emission hook belongs at slug/galley close, reusing the existing signal-capture step — emit a `signal_published` envelope rather than only writing to `knowledge/signals/`.
- v0 path needs nothing at runtime: a connector can derive events from commits. Native emission is the v1 upgrade. Build the manifest first; emission second.

## Attachments

- Standard: `loop-spec/`
- Done internal loop: `initiatives/loop-grade-execution.md`
