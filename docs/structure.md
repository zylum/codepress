---
layout: default
title: Structure
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
  <a class="primary-nav" href="structure.html">Structure</a>
  <a href="lifecycle.html">Lifecycle</a>
  <a href="https://github.com/zylum/codepress">GitHub</a>
</div>

# Structure

## Three pillars

CodePress is organised around three pillars, with a compound loop running across all three.

### System (`.codepress/system/`)

The operating system — how work happens.

| Path | Purpose |
|---|---|
| `.codepress/system/codepress.md` | Project name, release theme, working conventions, reading order |
| `.codepress/system/AGENTS.md` | Agent operating manual — reading order, rules, autonomy levels |
| `.codepress/system/skills/` | 10 AI-executable skills: shape, split, build, review, verify, release, bootstrap, status, signal, parallel-run |
| `.codepress/system/schema/` | The lifecycle as data: statuses, transitions, gates, legacy mapping, field schemas |
| `.codepress/system/lib/` | `codepress lint` — standard-library Python, no install step |
| `.codepress/system/templates/` | Artefact templates: initiative, galley, slug, review, learned, plan-changes, signal, release, pattern, decision |
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
| `.codepress/product/galleys/{name}/review.md` | Learning capture at galley-close — Signals, Evidence, Verdict |
| `.codepress/product/galleys/{name}/learned.md` | What the galley taught us (required for `done`) |
| `.codepress/product/galleys/{name}/plan-changes.md` | What the plan said, what changed, why |
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

### Loop Fabric (`.loop/`)

Cross-system interop artefacts.

| Path | Purpose |
|---|---|
| `.loop/manifest.yaml` | Loop declarations and canonical signal mappings |

Decoupling invariant: loop fabric files name only CodePress, never a consumer system.

### Event Outbox (`.codepress/loop-events/`)

Append-only JSONL event log for connector consumption.

| Path | Purpose |
|---|---|
| `.codepress/loop-events/{date}.jsonl` | `signal_published` and `failure_logged` envelopes |

### Views (`.codepress/views/`)

Helper views for at-a-glance status.

| Path | Purpose |
|---|---|
| `.codepress/views/galley-board.md` | Delivery board (kanban) |

## The compound loop

```
Signal → Pattern → Knowledge
```

Signals are captured during delivery, promoted to Patterns when validated, and update Knowledge when the system changes. This loop ensures every cycle leaves the organisation smarter.

## Directory layout

```text
.codepress/
├── system/
│   ├── codepress.md
│   ├── AGENTS.md
│   ├── skills/
│   │   ├── shape.md
│   │   ├── split.md
│   │   ├── build.md
│   │   ├── review.md      # includes cost aggregation step 1b
│   │   ├── verify.md
│   │   ├── release.md
│   │   ├── bootstrap.md
│   │   ├── status.md      # includes budget overrun detection
│   │   ├── signal.md      # observation, failure, and cost signal types
│   │   └── parallel-run.md
│   ├── schema/            # the lifecycle as data
│   │   ├── lifecycle.yaml # statuses, transitions, gates, legacy mapping
│   │   ├── galley.schema.yaml
│   │   ├── slug.schema.yaml
│   │   └── signal.schema.yaml
│   ├── lib/               # codepress lint (stdlib Python)
│   │   ├── lint.py
│   │   └── miniyaml.py
│   ├── templates/
│   │   ├── initiative.md
│   │   ├── galley.md      # holdout + budget + approval frontmatter
│   │   ├── slug.md        # budget + delivery-field frontmatter
│   │   ├── review.md      # Signals, Evidence, Entropy, Cost, Verdict
│   │   ├── learned.md     # required for done
│   │   ├── plan-changes.md
│   │   ├── signal.md      # structured signal record
│   │   ├── release.md
│   │   ├── pattern.md
│   │   └── decision.md
│   └── hooks/
├── product/
│   ├── initiatives/
│   ├── galleys/
│   └── releases/
├── knowledge/
│   ├── concepts.md
│   ├── glossary.md
│   ├── current-state.md
│   ├── decisions/
│   ├── signals/
│   └── patterns/
├── loop-events/           # signal_published outbox (JSONL)
└── views/
    └── galley-board.md
```
