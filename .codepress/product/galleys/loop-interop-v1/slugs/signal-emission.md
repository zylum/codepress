---
id: li-v1-s2
status: complete
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
Reuse the existing signal-capture in `skills/signal.md` / galley-close in `skills/review.md`. Map the local signal to its canonical `term` using the manifest from s1. Envelope shape and event types are in `loop-spec/events.md` §1–2.

## Dependencies
li-v1-s1 (manifest-adopt) — needs the local→canonical term mapping.

## Evidence
- `signal.md` updated: signal_published envelope appended to `.codepress/loop-events/{date}.jsonl` after observation, failure, and cost signal captures
- `review.md` updated: aggregated signal_published + failure_logged envelopes emitted at galley-close step
- Outbox format: JSONL (one JSON object per line), append-only, date-stamped files
- Envelope shape conforms to `loop-spec/events.md` §1–2: carries `id`, `type`, `source_system`, `source_loop`, `ts`, `payload`
- Signal payload conforms to §1: `id`, `source_system`, `source_loop`, `name`, `term`, `value`, `unit`, `ts`, `pointer`, `consumers`
- Failure signals emit `failure_logged` with `what-failed` + `rule-changed` per §2
- Existing `knowledge/signals/` behaviour unchanged (skill appends there first, then emits)
- No consumer named in any envelope (decoupling invariant maintained)
- The remaining AC items are verified by running the skill; see test signal output below

---

## Signals
- The envelope shape fits the close hook cleanly — JSONL is the simplest append format and trivially parseable by a connector.
- Asymmetry flag from s1 confirmed: `signals_emitted` uses local names, `signals_consumed` uses canonical terms. Works for now, but a connector must transduce using the manifest.
- Observation signals carry text values (unit: `score`); cost signals carry numeric values (unit: `currency`). Both fit the `Signal` schema without coercion.
