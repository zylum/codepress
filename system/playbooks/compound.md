# Playbook: Compound

The Compound Loop converts raw observations into reusable capability.
This is the engine that grows the entire system.

---

## The flow

```
Signal → Pattern → Knowledge
```

- **Signal** — a raw observation made during delivery
- **Pattern** — a validated, reusable lesson extracted from Signals
- **Knowledge** — the shared understanding of the product; updated when structure changes

---

## When to run

**Lightweight version:** at every Galley-close (see `system/playbooks/build.md`).
**Full version:** periodically — after a release, or when Patterns feel inconsistent across Galleys.

---

## Signals

Signals are captured in `product/galleys/{galley}/review.md` during delivery.
After Galley-close, raw Signals are promoted to `knowledge/signals/`.

A good Signal is:
- **Specific** — what happened, not a vague feeling
- **Tied to evidence** — a commit, a PR, a test result, a user reaction
- **Actionable** — someone could learn from it

File naming: `{YYYY-MM-DD}_{galley-id}_{short-description}.md`

---

## Promoting a Signal to a Pattern

A Signal becomes a Pattern when:

- It has appeared in 2+ Galleys independently, **or**
- It is immediately generalizable and would save significant future effort

Use `system/skills/capture-pattern.md` to run this step.

A Pattern answers:
- What problem does this solve?
- What is the reusable approach?
- When should you use it?
- When should you not?

---

## Updating Knowledge

`knowledge/` changes when:

| What happened | Where to update |
|---|---|
| New concept introduced | `knowledge/concepts.md` |
| New term needs defining | `knowledge/glossary.md` |
| Architectural decision made | `knowledge/decisions/` |
| Capabilities meaningfully changed | `knowledge/current-state.md` |

Knowledge does not need to be perfect. It needs to be useful.
A 5-line stub beats an empty file. Update incrementally.

---

## The principle

> Every cycle leaves the organisation smarter than before.
> The software is the output. The growing capability of the system is the asset.
