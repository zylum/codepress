# CodePress — Agent Operating Manual

CodePress is a compound product development system built on three pillars:
- **System** — how we work
- **Product** — what we build
- **Knowledge** — what we know

A Compound Loop runs across all three, continuously improving them.

---

## Reading order

Before any work, read in this order:

1. `.codepress/system/codepress.md` — project name, release theme, conventions
2. `.codepress/knowledge/concepts.md` — core entities and what they do
3. `.codepress/knowledge/current-state.md` — what exists today
4. Relevant `.codepress/knowledge/patterns/` — reusable lessons for this area
5. Active galley in `.codepress/product/galleys/` — what you are working on

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
| Initiative | `.codepress/product/initiatives/` | An idea or problem worth exploring |
| Galley | `.codepress/product/galleys/{name}/galley.md` | A shaped solution ready for delivery |
| Run Sheet | `.codepress/product/galleys/{name}/run-sheet.md` | Execution plan — slug order, parallel options |
| Slug | `.codepress/product/galleys/{name}/slugs/` | An atomic unit of delivery |
| Review | `.codepress/product/galleys/{name}/review.md` | Galley-close learning capture |
| Signal | `.codepress/knowledge/signals/` | A raw observation from delivery |
| Pattern | `.codepress/knowledge/patterns/` | A reusable lesson |
| Release | `.codepress/product/releases/` | Grouped shipped work |

---

## Operating rules

**Shape before build.**
Read the Galley fully. Understand the Problem, Users, Success criteria and Constraints before touching code.

**Read Knowledge first.**
Check `.codepress/knowledge/` before planning any work. Do not re-discover what already exists.

**Update Knowledge.**
When you encounter a concept, decision or capability not in `.codepress/knowledge/`, add it.
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

- `.codepress/system/playbooks/shape.md` — shape an Initiative into a Galley
- `.codepress/system/playbooks/split.md` — decompose a Galley into Slugs
- `.codepress/system/playbooks/build.md` — execute a Galley through Slugs
- `.codepress/system/playbooks/review.md` — Galley-close learning capture
- `.codepress/system/playbooks/release.md` — cut a release
- `.codepress/system/playbooks/compound.md` — Signals → Patterns → Knowledge

---

## Skills

Executable AI behaviours:

- `.codepress/system/skills/bootstrap.md` — seed Knowledge from an existing codebase
- `.codepress/system/skills/create-galley.md` — shape an Initiative into a Galley
- `.codepress/system/skills/split-galley.md` — decompose a Galley into Slugs
- `.codepress/system/skills/capture-pattern.md` — run the Galley-close learning step
- `.codepress/system/skills/update-domain.md` — update Knowledge artefacts
- `.codepress/system/skills/generate-release.md` — create a release note
- `.codepress/system/skills/status.md` — regenerate the delivery board
