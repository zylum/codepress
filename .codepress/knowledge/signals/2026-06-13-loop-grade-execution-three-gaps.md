---
id: sig-002
created: 2026-06-13
source: internal-analysis
type: synthesis
tags: [ai-loops, architecture, verifier, goal-native, loop-controller]
related-signals: [sig-001]
---

# Signal: Loop-Grade Execution — Three Structural Gaps

What separates a coding workflow tool from a genuinely self-improving execution system.

## Observation

Most AI coding tools (including current CodePress) function as prompt orchestration layers: they sequence agents, capture output, and defer quality judgment to humans. A loop-grade system is different — it can evaluate its own output, decide whether to continue or stop, and improve its own skills from failures without human input on every cycle.

The difference is structural, not conceptual. Three components are missing.

## Gap 1: Verifier as separate agent (separate context window)

**Current state:** the builder runs verify gates (shell commands) in the same context window it used to build.

**Required:** verifier runs in a fresh context with no access to build history — only the spec, the artefacts, and the acceptance criteria.

Why this matters: an agent that built the code has motivated reasoning. It will interpret ambiguous tests charitably, rationalise edge cases, and find workarounds that "technically pass." A separate verifier with only the spec and the output has no motivated reasoning. This is the same principle as code review — the reviewer should not be the author.

**Minimum CodePress addition:** `verifier:` engine entry in the engines block, distinct from `build:`. The verify skill explicitly spawns a fresh session rather than continuing inline.

## Gap 2: Structured failure memory

**Current state:** Signals are free-form observations.

**Required:** structured failure log: `what-failed`, `why`, `rule-changed`.

The `rule-changed` field is the critical one. It forces extraction of a generalisable lesson from each failure — not "this broke" but "the rule is now X." This feeds directly into Pattern creation. Without it, the system accumulates incidents but never learns a rule.

**Minimum format:**
```yaml
type: failure
what-failed: "test_auth_token_expiry"
why: "assumed UTC, server returns local time"
rule-changed: "Always assert timezone explicitly in auth token tests"
```

## Gap 3: Goal-native definition of done that survives execution

**Current state:** Galley acceptance criteria is prose. The builder can modify or reinterpret it during delivery.

**Required:** machine-evaluable DoD set at Galley approval that is read-only during delivery.

Shell-command gates (`verify:`) already solve this for technical criteria. The gap is behavioural criteria — rubric scoring by a separate evaluator agent, not builder self-assessment.

The key property: **the DoD is frozen at approval**. If the builder cannot change what "done" means, they cannot game it.

## The minimum viable loop architecture

```
Loop Controller  →  defines goal + constraints, decides continue/stop
Worker agents    →  code generation, research, refactor
Verifier agent   →  separate context, evaluates against rubric only
State layer      →  persistent memory: what failed, why, rule changed
Skill updater    →  extracts rules from failures, updates patterns
```

CodePress already has Worker + State layer primitives. Missing: Loop Controller, independent Verifier, Skill Updater.

## Candidate actions

- Add `verifier:` to the engines block (separate from `build:`)
- Add `goal:` block to galley.md with `machine-evaluable` and `rubric` sub-keys
- Add `holdout: true` flag — some rubric criteria visible only to verifier/reviewer
- Add structured failure Signal format as a `type: failure` Signal variant
- Add Skill Updater step to `review.md`: extract rules, propose Pattern updates

## Source

Loop-architecture analysis synthesised from LFD methodology (sig-001) and independent review. 2026-06-13.
