# CodePress — Agent Operating Manual

CodePress is a compound product development system.
Every initiative is shaped before it is built.
Every delivery leaves behind reusable knowledge.

---

## Reading order

Before any work, read in this order:

1. `codepress.md` — project name, release theme, conventions
2. `05-domain/index.md` — domain map and reading guide
3. `05-domain/current-state.md` — what exists today
4. Relevant `04-patterns/patterns/` — reusable lessons for this area
5. Active galley in `02-product/` — what you are working on

Never start implementation without reading Domain Memory first.

---

## The system

```
Initiative → Galley → Slugs → Signals → Patterns → Domain Memory
```

Each layer feeds the next. Each cycle leaves the system smarter.

---

## Artefacts

| Artefact | Where | Purpose |
|---|---|---|
| Initiative | `01-initiatives/` | An idea or problem worth exploring |
| Galley | `02-product/{name}/galley.md` | A shaped solution ready for delivery |
| Run Sheet | `02-product/{name}/run-sheet.md` | Execution plan — slug order, parallel options |
| Slug | `02-product/{name}/slugs/` | An atomic unit of delivery |
| Review | `02-product/{name}/review.md` | Galley-close learning capture |
| Signal | `04-patterns/signals/` | A raw observation from delivery |
| Pattern | `04-patterns/patterns/` | A reusable lesson |
| Domain Memory | `05-domain/` | Shared understanding of the product |

---

## Operating rules

**Shape before build.**
Read the Galley fully. Understand the Problem, Users, Success criteria and Constraints before touching code.

**Read Domain Memory first.**
Check `05-domain/` before planning any work. Do not re-discover what already exists.

**Update Domain Memory.**
When you encounter a concept, decision or capability not in `05-domain/`, add it.
Prefer a 5-line stub over nothing. Do not wait for the Galley to close.

**Capture Signals.**
When you observe something interesting during delivery — a discovery, unexpected behaviour, a better approach — record it in the Galley's `review.md` under Signals.

**Galley-close is mandatory.**
Before marking a Galley done, complete `review.md`.
Promote Signals to Patterns where warranted. Update Domain Memory.
A Galley is not done until learning has been captured.

**Commit discipline.**
One commit per Slug: `slug:<name> done — <summary>`
One commit per Galley close: `galley:<name> done`

---

## Autonomy levels

Each Slug declares its autonomy level:

| Level | Meaning |
|---|---|
| `continuous` | Run to completion without checking in |
| `confirm` | Check with human before proceeding to next Slug |
| `stop` | Halt and wait for human input |

---

## Playbooks

How CodePress operates:

- `playbooks/shape.md` — shape an Initiative into a Galley
- `playbooks/build.md` — execute a Galley through Slugs
- `playbooks/learn.md` — Signals → Patterns → Domain Memory

---

## Skills

Executable AI behaviours:

- `skills/bootstrap.md` — seed Domain Memory from an existing codebase
- `skills/create-galley.md` — shape an Initiative into a Galley
- `skills/split-galley.md` — decompose a Galley into Slugs
- `skills/capture-pattern.md` — run the Galley-close learning step
- `skills/status.md` — regenerate the delivery board from galley frontmatter
