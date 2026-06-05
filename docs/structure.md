---
layout: default
title: Structure
---

# Structure

## Three pillars

CodePress is organised around three pillars, with a compound loop running across all three.

### System (`.codepress/system/`)

The operating system — how work happens.

| Path | Purpose |
|---|---|
| `.codepress/system/codepress.md` | Project name, release theme, working conventions |
| `.codepress/system/AGENTS.md` | Agent operating manual — reading order, rules, autonomy levels |
| `.codepress/system/playbooks/` | Workflow guides: shape, split, build, review, release, compound |
| `.codepress/system/skills/` | AI-executable behaviours: bootstrap, create-galley, split-galley, etc. |
| `.codepress/system/templates/` | Artefact templates: initiative, galley, slug, release, pattern, decision |
| `.codepress/system/hooks/` | Automation triggers: on-galley-complete, on-release, on-pattern |

### Product (`.codepress/product/`)

The product factory — what we build.

| Path | Purpose |
|---|---|
| `.codepress/product/initiatives/` | Ideas and problems worth solving (free-form) |
| `.codepress/product/galleys/{name}/` | Shaped solutions with galley.md, run-sheet.md, slugs/, review.md |
| `.codepress/product/galleys/{name}/galley.md` | The shaped solution artefact |
| `.codepress/product/galleys/{name}/run-sheet.md` | Execution plan — slug order, parallel options |
| `.codepress/product/galleys/{name}/slugs/` | Atomic delivery units |
| `.codepress/product/galleys/{name}/review.md` | Learning capture at galley-close |
| `.codepress/product/releases/` | Release notes |

### Knowledge (`.codepress/knowledge/`)

Shared understanding — what we know.

| Path | Purpose |
|---|---|
| `.codepress/knowledge/concepts.md` | Core entities and their descriptions |
| `.codepress/knowledge/glossary.md` | Terminology and definitions |
| `.codepress/knowledge/current-state.md` | What exists today — capabilities, limitations |
| `.codepress/knowledge/decisions/` | Architectural and product decisions |
| `.codepress/knowledge/signals/` | Raw observations from delivery (staging area) |
| `.codepress/knowledge/patterns/` | Reusable lessons promoted from signals |

### Views (`.codepress/views/`)

Helper views for at-a-glance status.

| Path | Purpose |
|---|---|
| `.codepress/views/initiative-board.md` | Overview of all initiatives |
| `.codepress/views/galley-board.md` | Galley delivery board (kanban) |
| `.codepress/views/release-board.md` | Release overview |
| `.codepress/views/roadmap.md` | Strategic timeline |
| `.codepress/views/dashboard.md` | At-a-glance metrics |
| `.codepress/views/knowledge-map.md` | Map of all knowledge artefacts |

## The Compound Loop

```
Signal → Pattern → Knowledge
```

Signals are captured during delivery, promoted to Patterns when validated, and update Knowledge when the system changes. This loop ensures every cycle leaves the organisation smarter.
