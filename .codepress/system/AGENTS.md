# CodePress — Agent Operating Manual

CodePress is a compound product development system built on three pillars:
- **System** — how we work
- **Product** — what we build
- **Knowledge** — what we know

A compound loop runs across all three, continuously improving them.

---

## Modes of use

| Level | Name | What's available |
|---|---|---|
| 1 | Scaffold | `.codepress/` structure + templates. Human and AI work directly with markdown files. |
| 2 | Workshop | Scaffold + Obsidian Kanban boards. `codepress status` regenerates views. |
| 3 | Engine | Workshop + automation. `codepress run` dispatches skills. |

---

## Reading order

Before any work:

1. `system/codepress.md` — project name, pace, conventions
2. `knowledge/current-state.md` — what exists today
3. Relevant `knowledge/patterns/` — reusable lessons for this area
4. Active galley in `product/galleys/` — what you are working on

---

## Artefacts

| Artefact | Location | Purpose |
|---|---|---|
| Initiative | `product/initiatives/` | An idea or problem worth exploring |
| Galley | `product/galleys/{name}/galley.md` | A shaped solution ready for delivery |
| Run Sheet | `product/galleys/{name}/run-sheet.md` | Execution plan — Slug order, parallel groups |
| Slug | `product/galleys/{name}/slugs/` | An atomic unit of delivery |
| Review | `product/galleys/{name}/review.md` | Galley-close learning capture |
| Signal | `knowledge/signals/` | A raw observation from delivery |
| Pattern | `knowledge/patterns/` | A reusable lesson |
| Release | `product/releases/` | Grouped shipped work |

---

## Status model

### Initiative lifecycle

`inbox → research → candidate → approved → shaping → galley-ready → archived`

### Galley lifecycle

`shaping → approved → delivering → review → done`

The compound step gates `review → done`: a Galley cannot be marked `done` until `review.md` is complete, Signals are promoted to Patterns where warranted, and Knowledge is updated.

---

## Operating rules

**Shape before build.**
Read the Galley fully before touching code.

**Read Knowledge first.**
Check `knowledge/` before planning. Do not re-discover what already exists.

**Update Knowledge.**
When you encounter a concept, decision or capability not in `knowledge/`, add it. A 5-line stub beats nothing.

**Capture Signals during delivery.**
Fill the Signals block in each Slug before committing — not deferred to galley-close.
Quick capture mid-session: run `skills/signal.md` with your observation.

**Galley-close is mandatory.**
Before marking a Galley `done`, complete `review.md`, promote Signals, and update Knowledge.

**Commit discipline.**
One commit per Slug: `slug:<name> done — <summary>`
One commit per Galley close: `galley:<name> done`

---

## Autonomy levels

| Level | Meaning |
|---|---|
| `continuous` | Run to completion without checking in |
| `confirm` | Check with human before proceeding to next Slug |
| `stop` | Halt and wait for human input |

---

## Skills

| Skill | Purpose |
|---|---|
| `skills/shape.md` | Shape an Initiative into a Galley |
| `skills/split.md` | Decompose a Galley into Slugs |
| `skills/build.md` | Execute a Galley through its Slugs |
| `skills/review.md` | Galley-close: Signals → Patterns → Knowledge |
| `skills/verify.md` | Run verification gates |
| `skills/release.md` | Cut a release |
| `skills/bootstrap.md` | Seed Knowledge from an existing codebase |
| `skills/status.md` | Regenerate the delivery board |
| `skills/signal.md` | Quick-capture an observation mid-session |
| `skills/parallel-run.md` | Run a parallel Slug group using git worktrees |

Claude Code users: `.claude/commands/` contains slash command wrappers — type `/shape`, `/split`, `/build`, or `/learn` to invoke skills directly.
