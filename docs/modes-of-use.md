---
layout: default
title: Modes of Use
---

<link rel="stylesheet" href="/codepress/assets/css/custom.css">

<div class="tab-nav">
  <a href="overview.html">Overview</a>
  <a href="faq.html">FAQs</a>
  <a href="quick-reference.html">Reference</a>
</div>
<div class="page-nav">
  <a href="index.html">Home</a>
  <a href="quick-start.html">Quick Start</a>
  <a href="structure.html">Structure</a>
  <a href="https://github.com/zylum/codepress">GitHub</a>
</div>

# Modes of Use

CodePress supports three levels of operation. Each level adds capability without breaking the one below. Start at Scaffold, level up when you need more.

---

## Feature comparison

| Feature | Scaffold | Workshop | Engine |
|---|---|---|---|
| `.codepress/` structure | ✓ | ✓ | ✓ |
| AI agent operating manual (AGENTS.md) | ✓ | ✓ | ✓ |
| Playbooks, skills, templates | ✓ | ✓ | ✓ |
| Frontmatter-driven status | ✓ | ✓ | ✓ |
| Obsidian Kanban boards | — | ✓ | ✓ |
| `codepress status` (board regeneration) | — | ✓ | ✓ |
| `codepress run` (action dispatch) | — | — | ✓ |
| Engine routing (per-stage agents) | — | — | ✓ |
| `codepress watch` (file watcher) | — | — | ✓ |
| Hermes agent (context-aware automation) | — | — | Optional |
| CLI tool required | No | Yes | Yes |
| Obsidian required | No | Yes | Yes |

---

## Level 1: Scaffold

The foundation. A `.codepress/` directory with the full system, playbooks, skills, templates, and AGENTS.md. You and your AI agent work directly with markdown files.

**Setup:** `codepress init` or clone the template.

**Workflow:**
1. Write an Initiative in `product/initiatives/`
2. Ask your AI to shape it (follows `skills/create-galley.md`)
3. Approve the Galley, split into Slugs
4. Build each Slug with your AI
5. Capture learning at galley-close

**Best for:** Getting started, evaluating CodePress, solo projects.

---

## Level 2: Workshop

Adds visual pipeline management via Obsidian Kanban boards. The CLI regenerates board views from artefact frontmatter.

**Setup:** Open `.codepress/` as an Obsidian vault. Install the Kanban plugin. Run `codepress status` to generate boards.

**Workflow:**
1. Use the Initiative Board to track ideas through the funnel
2. Use the Galley Board as a kanban — cards auto-move as statuses change
3. Run `codepress galley move <name> <status>` to update

**Best for:** Solo devs and small teams who want visual tracking without leaving markdown.

---

## Level 3: Engine

Adds automation. The CLI detects pending actions, dispatches the right skill/playbook, and optionally watches for file changes.

**Setup:** Configure `engines:` in `codepress.md`. Run `codepress run` to dispatch.

**Workflow:**
1. Mark an Initiative `approved`
2. Run `codepress run` — the engine prompts to create the Galley
3. Approve the Galley, run `codepress run` again — it splits into Slugs
4. Build Slugs with your AI, run `codepress run` at each transition
5. For fully automatic: `codepress watch` or add Hermes

**Best for:** Teams wanting CI/CD for product delivery.

---

## Level 3+: Hermes

Hermes is an optional automation agent that replaces `codepress watch` with context-aware execution. Instead of firing on any file change, Hermes reads the specific artefact, understands what changed, and executes the exact next action.

Commands: `capture`, `shape`, `split`, `build`, `review`, `learn`, `status`.

See [Hermes integration](/codepress/hermes.html) for setup and command reference.
