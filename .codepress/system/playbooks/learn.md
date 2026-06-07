# Playbook: Learn

Convert raw delivery observations into reusable capability.
This is the compound loop — every galley leaves the system smarter.

```
Signal → Pattern → Knowledge
```

---

## When to run

At every Galley-close, before marking a Galley `learned`.

---

## 1. Promote Signals

Signals are captured in `product/galleys/{name}/review.md` during delivery.

At galley-close, promote raw Signals to `knowledge/signals/`.

A good Signal is:
- **Specific** — what happened, not a vague feeling
- **Tied to evidence** — a commit, a PR, a test result
- **Actionable** — someone could learn from it

File naming: `{YYYY-MM-DD}_{galley-id}_{short-description}.md`

---

## 2. Extract Patterns

A Signal becomes a Pattern when:

- It has appeared in 2+ Galleys independently, **or**
- It is immediately generalizable and would save significant future effort

A Pattern answers:
- What problem does this solve?
- What is the reusable approach?
- When should you use it? When not?

Save to `knowledge/patterns/` using the pattern template.

---

## 3. Update Knowledge

Changes propagate to `knowledge/`:

| What happened | Where |
|---|---|
| New concept introduced | `knowledge/concepts.md` |
| New term needs defining | `knowledge/glossary.md` |
| Architectural decision made | `knowledge/decisions/` |
| Capabilities changed | `knowledge/current-state.md` |

A 5-line stub beats an empty file. Update incrementally.

---

## The principle

> Every cycle leaves the organisation smarter than before.
> The software is the output. The growing capability of the system is the asset.
