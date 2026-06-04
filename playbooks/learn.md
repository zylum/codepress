# Playbook: Learn

Learn converts raw observations into reusable capability.

---

## The flow

```
Signal → Pattern → Domain Memory
```

- **Signal** — a raw observation made during delivery
- **Pattern** — a validated, reusable lesson extracted from Signals
- **Domain Memory** — the shared understanding of the product; updated when structure changes

---

## When to run

**Lightweight version:** at every Galley-close (see `playbooks/build.md`).
**Full version:** periodically — after a release, or when Patterns feel inconsistent across Galleys.

---

## Signals

Signals are captured in `02-product/{galley}/review.md` during delivery.
After Galley-close, raw Signals are promoted to `04-patterns/signals/`.

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

Use `skills/capture-pattern.md` to run this step.

A Pattern answers:
- What problem does this solve?
- What is the reusable approach?
- When should you use it?
- When should you not?

---

## Updating Domain Memory

`05-domain/` changes when:

| What happened | Where to update |
|---|---|
| New concept introduced | `05-domain/concepts.md` |
| New term needs defining | `05-domain/glossary.md` |
| Architectural decision made | `05-domain/decisions/` |
| Capabilities meaningfully changed | `05-domain/current-state.md` |

Domain Memory does not need to be perfect. It needs to be useful.
A 5-line stub beats an empty file. Update incrementally.

---

## The principle

> Every cycle leaves the organisation smarter than before.
> The software is the output. The growing capability of the system is the asset.
