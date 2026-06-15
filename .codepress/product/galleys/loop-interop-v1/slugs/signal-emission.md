---
id: li-v1-s2
status: open
galley: li-v1
autonomy: confirm
---

# Slug: signal-emission

## Purpose
At slug/galley close, emit `signal_published` (and `failure_logged`) event envelopes to a local outbox a connector can read — in addition to the existing `knowledge/signals/` write.

## Acceptance checklist
- [ ] Close step writes a valid `signal_published` envelope (per `loop-spec/events.md`) to `.codepress/loop-events/`
- [ ] Envelope carries `source_system`, `source_loop`, `name`, `term`, `value`, `unit`, `ts`
- [ ] Failure signals emit a `failure_logged` event carrying `rule-changed`
- [ ] Outbox format is append-only and connector-friendly (one event per file or JSONL)
- [ ] Existing `knowledge/signals/` behaviour unchanged (additive only)
- [ ] No consumer named in any envelope

## Context
Reuse the existing signal-capture in `skills/signal.md` / galley-close in `skills/review.md`. Map the local signal to its canonical `term` using the manifest from s1. Envelope shape and event types are in `/Users/marv/code/loop-spec/events.md` §1–2.

## Dependencies
li-v1-s1 (manifest-adopt) — needs the local→canonical term mapping.

## Evidence
(Filled at completion)

---

## Signals
<!-- did the envelope shape fit cleanly into the close hook? -->
