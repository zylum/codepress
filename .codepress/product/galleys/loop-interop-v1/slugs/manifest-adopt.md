---
id: li-v1-s1
status: complete
galley: li-v1
autonomy: continuous
---

# Slug: manifest-adopt

## Purpose
Author and validate a `.loop/manifest.yaml` at the CodePress repo root that declares its real loops and signals against loop-spec v0.1.

## Acceptance checklist
- [ ] `.loop/manifest.yaml` created at repo root
- [ ] Validates against `loop-spec/manifest.schema.yaml`
- [ ] Declares at least `galley-delivery` and `knowledge-learning` loops with `type`, `goal`, `verifier`, `state_pointer`
- [ ] Each signal maps a local name to a canonical `term` (latency / quality / friction / cost)
- [ ] `discovery.fingerprints` lists CodePress's real markers (`/.codepress`, etc.)
- [ ] No mention of any consumer system anywhere in the file

## Context
Start from `loop-spec/examples/codepress.loop.yaml` — it already drafts the two loops; verify each field against the actual repo (real verifier refs, real state paths). Read `loop-spec/manifest.schema.yaml` for required fields.

## Dependencies
None.

## Evidence
- `.loop/manifest.yaml` created at CodePress repo root (2026-06-14).
- Declares both real loops (`galley-delivery` reinforcing, `knowledge-learning` balancing) with `type`, `goal`, `verifier`, `state_pointer`.
- Signals mapped to canonical terms: time_to_first_value→latency, verifier_pass_rate→quality, rework_rate→friction, tokens_per_galley→cost.
- `discovery.fingerprints` set to real CodePress markers; no consumer named.
- Conforms to `loop-spec/manifest.schema.yaml` by manual check. NOTE: automated validator not yet built (loop-spec G0 task) — re-validate when it lands.

---

## Signals
- The loop-spec example was directly usable as the root manifest with only pointer tweaks — the spec is fit for purpose at v0.1.
- Open question for the standard: `signals_consumed` uses canonical terms while `signals_emitted` uses local names — slight asymmetry; fine for now, flag if it confuses connectors.
