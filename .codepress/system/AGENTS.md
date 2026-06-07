# CodePress — Agent Operating Manual

CodePress is a compound product development system built on three pillars:
- **System** — how we work
- **Product** — what we build
- **Knowledge** — what we know

A compound loop runs across all three, continuously improving them.

---

## Modes of use

CodePress supports three levels of operation:

| Level | Name | What's available |
|---|---|---|
| 1 | Scaffold | `.codepress/` structure + AGENTS.md + templates. Human and AI work directly with markdown files. No tooling required. |
| 2 | Workshop | Scaffold + Obsidian Kanban boards. `codepress status` regenerates views. Visual pipeline management. |
| 3 | Engine | Workshop + automation. `codepress run` dispatches skills. Watch mode or Hermes auto-triggers workflows. |

---

## Reading order

Before any work, read in this order:

1. `system/codepress.md` — project name, pace, conventions
2. `knowledge/concepts.md` — core entities and what they do
3. `knowledge/current-state.md` — what exists today
4. Relevant `knowledge/patterns/` — reusable lessons for this area
5. Active galley in `product/galleys/` — what you are working on

Never start implementation without reading Knowledge first.

---

## Artefacts

| Artefact | Location | Purpose |
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

## Status model

### Initiative lifecycle

`inbox → research → candidate → approved → shaping → galley-ready → archived`

| Status | Meaning |
|---|---|
| `inbox` | Raw idea captured, no evaluation yet |
| `research` | Being explored — gathering context, feasibility |
| `candidate` | Looks promising, needs shaping |
| `approved` | Greenlit — ready to shape into a Galley |
| `shaping` | Galley being drafted |
| `galley-ready` | Galley exists and is approved |
| `archived` | Not moving forward — reason recorded |

### Galley lifecycle

`draft → ready → building → review → released → learned`

| Status | Meaning |
|---|---|
| `draft` | Being written |
| `ready` | Shaped and approved, ready for split |
| `building` | Slugs in progress |
| `review` | All slugs done, learning capture |
| `released` | Shipped |
| `learned` | Signals captured, patterns promoted, knowledge updated |

---

## Operating rules

**Shape before build.**
Read the Galley fully before touching code.

**Read Knowledge first.**
Check `knowledge/` before planning. Do not re-discover what already exists.

**Update Knowledge.**
When you encounter a concept, decision or capability not in `knowledge/`, add it. Prefer a 5-line stub over nothing.

**Capture Signals.**
When you observe something interesting during delivery — a discovery, unexpected behaviour, a better approach — record it in `review.md` under Signals.

**Galley-close is mandatory.**
Before marking a Galley `learned`, complete `review.md`, promote Signals to Patterns, and update Knowledge.

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

## Playbooks

- `playbooks/shape.md` — shape an Initiative into a Galley
- `playbooks/split.md` — decompose a Galley into Slugs
- `playbooks/build.md` — execute a Galley through Slugs
- `playbooks/review.md` — Galley-close learning capture
- `playbooks/learn.md` — Signals → Patterns → Knowledge
- `playbooks/verify.md` — run verification gates before status transitions
- `playbooks/release.md` — cut a release

---

## Skills

- `skills/bootstrap.md` — seed Knowledge from an existing codebase
- `skills/create-galley.md` — shape an Initiative into a Galley
- `skills/split-galley.md` — decompose a Galley into Slugs
- `skills/capture-pattern.md` — Galley-close learning step
- `skills/generate-release.md` — create a release note
- `skills/status.md` — regenerate the delivery board
