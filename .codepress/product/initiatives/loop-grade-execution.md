---
id: lge-001
status: archived
created: 2026-06-13
---

# Initiative: Loop-Grade Execution

## Problem

CodePress functions as a prompt orchestration layer — it sequences agents, captures output, and defers quality judgment to humans. This is useful but not self-improving. Three structural gaps prevent CodePress from closing its own evaluation loop:

1. **No independent verifier** — the builder evaluates its own work. Motivated reasoning leaks through.
2. **No machine-readable DoD** — acceptance criteria is prose. The builder can satisfy the letter while missing the intent.
3. **No structured failure memory** — Signals capture observations but do not extract generalisable rules.

Without these three, every quality gate requires a human. With them, CodePress can run, evaluate, and improve without constant human input.

## Context

Two independent sources converged on this diagnosis:

**Elvis Sun's LFD (Loss Function Development):** hidden eval targets prevent gaming; budget constraints (time, tokens, $) must be first-class; instruments/harness emit structured Signals during execution; forced entropy at review prevents plateau and overfit.

**Loop-architecture analysis:** the minimum viable loop requires a Loop Controller, Worker agents, a Verifier agent in a separate context, a structured State layer, and a Skill Updater that extracts rules from failures. CodePress has Worker and State primitives. Missing: independent Verifier, machine-readable DoD, Skill Updater.

Both point at the same root cause: any optimiser will cheat toward whatever target is visible and measurable. The fix is not better prompting — it is better fences.

## Why now

The Execution Engine galley is delivering. It will produce an agent dispatch loop. If we build that loop without the verifier layer and machine-readable DoD, we will have built a faster way to produce unreliable output. The evaluation architecture must be designed before the execution architecture is complete — retrofitting it later is much harder.

## Thoughts

### 1. Verifier as separate engine

Add `verifier:` to the engines block in `codepress.md`, distinct from `build:`. The verify skill explicitly spawns a fresh agent session — not a continuation of the build context. The verifier receives: the Galley spec, the artefacts, and the verify gates. It does not receive build history or builder commentary.

```yaml
engines:
  build: opencode
  verifier: claude        # spawns fresh — no build context
  review: claude
```

### 2. Goal-native AC in galley.md

Extend the Galley template with a `goal:` frontmatter block:

```yaml
goal:
  machine-evaluable: [typecheck, test, lint]
  rubric:
    - id: ac-1
      criterion: "All documented API endpoints return 200"
      evaluator: verify-endpoints.sh
    - id: ac-2
      criterion: "P95 response time < 200ms under 100 concurrent users"
      evaluator: load-test.sh
  holdout: true   # reviewer holds additional criteria not visible during delivery
```

`holdout: true` means some criteria are set at approval and held by the reviewer — not in the repo. This is the hidden eval target. The builder cannot optimise to what it cannot see.

### 3. Budget fields in Galley and Slug

```yaml
budget:
  wall-clock: 2h
  tokens: 200k
  cost: $2.00
```

Hooks read these at Slug start and emit a warning Signal when 80% is consumed. At 100%, the Slug halts and routes to human.

### 4. Structured failure Signal format

Add `type: failure` as a Signal variant with required fields:

```yaml
---
type: failure
what-failed: "test_auth_token_expiry"
why: "assumed UTC, server returns local time"
rule-changed: "Always assert timezone explicitly in auth token tests"
---
```

`rule-changed` is the key field — it forces extraction of a generalisable lesson. Failure Signals with a populated `rule-changed` are automatically candidates for Pattern creation.

### 5. Forced entropy in review.md

Add a mandatory section to the review skill:

> **Did we improve the system or just deliver a feature?**
> - What rule did we discover that we didn't know before?
> - What would make the next galley 20% cheaper to run?
> - Any Signals that should become Patterns?

This is the loop-closing step. Without it, the system delivers but never compounds.

## Acceptance Criteria

- [x] Galley template: `holdout:` flag + `budget:` frontmatter; `verify:` covers machine-evaluable gates
- [x] `budget:` frontmatter supported in Galley and Slug templates
- [x] `verifier:` engine entry in `codepress.md` engines block
- [x] `verify.md` skill: verifier principle, separate-context rule, holdout gate, failure Signal format
- [x] `skills/signal.md`: `type: failure` format with mandatory `rule-changed` field
- [x] `skills/review.md`: step 6 entropy check + Entropy section in review.md template

## Attachments

- Signal: `knowledge/signals/2026-06-13-lfd-agents-cheat-without-fences.md`
- Signal: `knowledge/signals/2026-06-13-loop-grade-execution-three-gaps.md`
- LFD source: https://x.com/elvissun/status/2065035615800864954
