# Review: Loop Interop v1

## Signals

- The loop-spec example was directly usable as the root manifest with only pointer tweaks — the spec is fit for purpose at v0.1 (s1)
- Open question for the standard: `signals_consumed` uses canonical terms while `signals_emitted` uses local names — slight asymmetry; fine for now, flag if it confuses connectors (s1)
- The envelope shape fits the close hook cleanly — JSONL is the simplest append format and trivially parseable by a connector (s2)
- Observation signals carry text values (unit: `score`); cost signals carry numeric values (unit: `currency`). Both fit the `Signal` schema without coercion (s2)
- Outbox location ambiguity surfaced: `.codepress/loop-events/` vs `.loop/events/` — `.codepress/` is correct; the outbox is CodePress's own write-ahead log, the `.loop/` namespace is for the manifest only (s3)
- Consumer references exist in `system/codepress.md` (`consumer-project:`) and `system/hooks/` — these are internal sync config, not loop fabric. Audit confirmed no loop fabric file names a consumer (s3)

## Surprises

- The decoupling audit showed more consumer references in system config than expected — but all were internal hooks/config, not loop fabric declarations. The distinction between "CodePress internals" and "loop fabric" needs to be explicit in the docs.
- JSONL validation was trivial — `python3 -m json.tool` parsed the first emission cleanly. The outbox should get a schema validator in a future loop-interop iteration.

## Pattern candidates

- [x] proposed: **manifest-first pattern** — promoted to `knowledge/patterns/manifest-first.md`
- [x] proposed: **outbox-owned-by-source pattern** — promoted to `knowledge/patterns/outbox-owned-by-source.md`
- Decision recorded: outbox namespace decision in `knowledge/decisions/2026-06-15-loop-events-namespace.md`

## Cost

No cost signals captured — FinOps not active for this galley.

## Knowledge updates

- `docs/interop.md` created — CodePress loop interop documentation
- `.codepress/system/skills/signal.md` updated — signal emission hooks added
- `.codepress/system/skills/review.md` updated — galley-close emission added

## Entropy

1. **Did we improve the system, or just deliver a feature?**
   Improved the system. CodePress now participates in the loop fabric — it declares its loops and emits signals at lifecycle points. A connector can discover it and observe its state without CodePress knowing or caring which consumer is listening. The loop-events outbox is a new capability, not a feature delivered to a specific stakeholder.

2. **What rule did this Galley discover?**
   The decoupling invariant (manifest and emitted payloads name only CodePress) is harder to audit than to state, because system config (`codepress.md`, `hooks/`) legitimately references consumer paths for non-loop purposes. The audit must scope itself to loop fabric files only.

3. **Plateau detected: no**
   New domain (loop interop), first implementation, multiple design decisions made.

4. **What would make the next galley 20% cheaper?**
   The manifest-adopt slug benefited from the loop-spec example being directly usable — seed examples significantly reduce shape time. For emission: the signal.md and review.md skills were the right place to hook into; finding them was the main cost. Future loop-interop galleys should read the skill files first rather than exploring the whole system.
