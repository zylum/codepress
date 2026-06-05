# CodePress — Agent Operating Manual

CodePress is a compound product development system built on three pillars:
- **System** — how we work
- **Product** — what we build
- **Knowledge** — what we know

A Compound Loop runs across all three, continuously improving them.

---

## Reading order

Before any work, read in this order:

1. `system/codepress.md` — project name, release theme, conventions
2. `knowledge/concepts.md` — core entities and what they do
3. `knowledge/current-state.md` — what exists today
4. Relevant `knowledge/patterns/` — reusable lessons for this area
5. Active galley in `product/galleys/` — what you are working on

Never start implementation without reading Knowledge first.

---

## The system

```
Initiative → Galley → Slugs → Signals → Patterns → Knowledge
```

Each layer feeds the next. Each cycle leaves the system smarter.

---

## Artefacts

| Artefact | Where | Purpose |
|---|---|---|
| Initiative | `product/initiatives/` | An idea or problem worth exploring |
| Galley | `product/galleys/{name}/galley.md` | A shaped solution ready for delivery |
| Run Sheet | `product/galleys/{name}/run-sheet.md` | Execution plan — slug order, parallel options |
| Slug | `product/galleys/{name}/slugs/` | An atomic unit of delivery |
| Review | `product/galleys/{name}/review.md` | Galley-close learning capture |
| Signal | `knowledge/signals/` | A raw observation from delivery |
| Pattern | `knowledge/patterns/` | A reusable lesson |
| Release | `product/releases/` | Grouped shipped work |

---

## Operating rules

**Shape before build.**
Read the Galley fully. Understand the Problem, Users, Success criteria and Constraints before touching code.

**Read Knowledge first.**
Check `knowledge/` before planning any work. Do not re-discover what already exists.

**Update Knowledge.**
When you encounter a concept, decision or capability not in `knowledge/`, add it.
Prefer a 5-line stub over nothing. Do not wait for the Galley to close.

**Capture Signals.**
When you observe something interesting during delivery — a discovery, unexpected behaviour, a better approach — record it in the Galley's `review.md` under Signals.

**Galley-close is mandatory.**
Before marking a Galley done, complete `review.md`.
Promote Signals to Patterns where warranted. Update Knowledge.
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

- `system/playbooks/shape.md` — shape an Initiative into a Galley
- `system/playbooks/split.md` — decompose a Galley into Slugs
- `system/playbooks/build.md` — execute a Galley through Slugs
- `system/playbooks/review.md` — Galley-close learning capture
- `system/playbooks/release.md` — cut a release
- `system/playbooks/compound.md` — Signals → Patterns → Knowledge

---

## Skills

Executable AI behaviours:

- `system/skills/bootstrap.md` — seed Knowledge from an existing codebase
- `system/skills/create-galley.md` — shape an Initiative into a Galley
- `system/skills/split-galley.md` — decompose a Galley into Slugs
- `system/skills/capture-pattern.md` — run the Galley-close learning step
- `system/skills/update-domain.md` — update Knowledge artefacts
- `system/skills/generate-release.md` — create a release note
- `system/skills/status.md` — regenerate the delivery board
