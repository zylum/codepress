---
layout: default
title: Structure
---

# Structure

## Three pillars

CodePress is organised around three pillars, with a compound loop running across all three.

### System (`system/`)

The operating system — how work happens.

| Path | Purpose |
|---|---|
| `system/codepress.md` | Project name, release theme, working conventions |
| `system/AGENTS.md` | Agent operating manual — reading order, rules, autonomy levels |
| `system/playbooks/` | Workflow guides: shape, split, build, review, release, compound |
| `system/skills/` | AI-executable behaviours: bootstrap, create-galley, split-galley, etc. |
| `system/templates/` | Artefact templates: initiative, galley, slug, release, pattern, decision |
| `system/hooks/` | Automation triggers: on-galley-complete, on-release, on-pattern |

### Product (`product/`)

The product factory — what we build.

| Path | Purpose |
|---|---|
| `product/initiatives/` | Ideas and problems worth solving (free-form) |
| `product/galleys/{name}/` | Shaped solutions with galley.md, run-sheet.md, slugs/, review.md |
| `product/galleys/{name}/galley.md` | The shaped solution artefact |
| `product/galleys/{name}/run-sheet.md` | Execution plan — slug order, parallel options |
| `product/galleys/{name}/slugs/` | Atomic delivery units |
| `product/galleys/{name}/review.md` | Learning capture at galley-close |
| `product/releases/` | Release notes |

### Knowledge (`knowledge/`)

Shared understanding — what we know.

| Path | Purpose |
|---|---|
| `knowledge/concepts.md` | Core entities and their descriptions |
| `knowledge/glossary.md` | Terminology and definitions |
| `knowledge/current-state.md` | What exists today — capabilities, limitations |
| `knowledge/decisions/` | Architectural and product decisions |
| `knowledge/signals/` | Raw observations from delivery (staging area) |
| `knowledge/patterns/` | Reusable lessons promoted from signals |

### Views (`views/`)

Helper views for at-a-glance status.

| Path | Purpose |
|---|---|
| `views/initiative-board.md` | Overview of all initiatives |
| `views/galley-board.md` | Galley delivery board (kanban) |
| `views/release-board.md` | Release overview |
| `views/roadmap.md` | Strategic timeline |
| `views/dashboard.md` | At-a-glance metrics |
| `views/knowledge-map.md` | Map of all knowledge artefacts |

## The Compound Loop

```
Signal → Pattern → Knowledge
```

Signals are captured during delivery, promoted to Patterns when validated, and update Knowledge when the system changes. This loop ensures every cycle leaves the organisation smarter.
