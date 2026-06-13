---
layout: default
title: Hermes Integration
---

<link rel="stylesheet" href="/codepress/assets/css/custom.css">

<div class="tab-nav">
  <a href="overview.html">Overview</a>
  <a href="faq.html">FAQs</a>
  <a href="quick-reference.html">Reference</a>
</div>
<div class="page-nav">
  <a href="index.html">Home</a>
  <a href="modes-of-use.html">Modes of Use</a>
  <a href="structure.html">Structure</a>
  <a href="https://github.com/zylum/codepress">GitHub</a>
</div>

# Hermes Integration

> Hermes is optional. CodePress works fully at Scaffold, Workshop, and Engine levels without it. Hermes adds context-aware automation.

---

## Why Hermes over `codepress watch`

| Capability | `codepress watch` | Hermes |
|---|---|---|
| Trigger | Any file change in `product/` | Understands which artefact changed and why |
| Action | Runs full status detection | Reads the specific artefact, executes exact next action |
| Cross-galley awareness | None | Cross-references signals across galleys for pattern detection |
| Learning loop | Manual | Suggests pattern candidates from signal history |
| State | Stateless — re-scans on each event | Persistent — remembers previous states and decisions |
| Model | Bash script | Agent framework (context, memory, tool use) |

---

## Command reference

| Command | Input | Output | Files touched |
|---|---|---|---|
| `capture` | galley `review.md` | Signal files | `knowledge/signals/`, `product/galleys/*/review.md` |
| `shape` | Initiative file | `galley.md` | `product/galleys/{name}/galley.md` |
| `split` | `galley.md` | Slug files, run-sheet | `product/galleys/{name}/slugs/`, run-sheet.md |
| `build` | Slug file | Code changes | `src/` + slug status |
| `review` | Slug completion | Signals in `review.md` | `product/galleys/{name}/review.md` |
| `learn` | `review.md` | Pattern + knowledge updates | `knowledge/signals/`, `knowledge/patterns/`, `knowledge/concepts.md` |
| `status` | All artefacts | Pending actions + board | `views/` (board regeneration) |

---

## Design principles

1. **CodePress must work without Hermes.** Hermes is a layer on top, never a requirement.
2. **Hermes reads and writes CodePress artefacts.** It never becomes the source of truth — frontmatter is always the source.
3. **Hermes follows the same skills.** It does not create new workflows; it automates existing ones.
4. **Hermes dispatches to configured engines.** The `engines:` config in `codepress.md` determines which agent runs each stage.

---

## Flow

```text
Hermes watches product/ and knowledge/

  ↓

Change detected → reads artefact frontmatter
                → determines next action
                → dispatches to configured engine
                → updates artefact status
                → regenerates boards

  ↓

Compound loop: Hermes cross-references new signals
               against existing signals/patterns
               and suggests promotions
```

---

## Future: MCP + Obsidian

- **MCP tool** — Hermes could expose CodePress commands as MCP tools for any AI agent
- **Obsidian plugin** — status transitions, board refresh, and signal capture from within Obsidian
- **Notification** — Hermes could notify on blocked galleys, stalled initiatives, or pattern candidates

---

## Status detection rules (Hermes uses these)

| Artefact state | Pending action | Dispatches |
|---|---|---|
| Initiative `approved` or `shaping`, no galley | `shape` | `skills/shape.md` |
| Galley `ready`, no slugs | `split` | `skills/split.md` |
| Galley `building`, all slugs complete | `review` | `skills/review.md` |
| Galley `review` done | `release+learn` | `skills/release.md` |
