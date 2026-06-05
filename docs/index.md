---
layout: default
title: CodePress
---

<link rel="stylesheet" href="/codepress/assets/css/custom.css">

<div class="codepress-hero">

# Shape Ideas. Build in Parallel. Compound Knowledge.

<div class="sub">
CodePress helps teams turn initiatives into shippable software while capturing everything they learn along the way.
</div>

<div class="tagline">
Shape once. Build many. Learn forever.
</div>

<div class="ctas">
  <a class="primary" href="#quick-start">Quick Start</a>
  <a class="secondary" href="structure.html">View Structure</a>
  <a class="secondary" href="https://github.com/zylum/codepress">GitHub</a>
</div>

</div>

---

## What problem does CodePress solve?

Most teams work like this:

```text
Idea → Backlog → Sprint → Ship → Forget
```

Knowledge gets lost. The same mistakes are repeated. AI accelerates delivery but does not improve how the organisation learns.

CodePress changes the loop:

```text
Idea → Shape → Build → Learn → Compound
```

Every delivery improves future delivery. The software is the output. The growing capability of the system is the asset.

---

## How it works

```text
Initiative
    ↓
Galley
    ↓
Slugs
    ↓
Release
    ↓
Signals
    ↓
Patterns
    ↓
Knowledge
```

| Stage | What it is |
|---|---|
| **Initiative** | An opportunity worth exploring |
| **Galley** | A shaped solution ready for implementation |
| **Slugs** | Atomic delivery units built independently |
| **Release** | Delivered value |
| **Signals** | What we learned during delivery |
| **Patterns** | Reusable lessons extracted from signals |
| **Knowledge** | Shared understanding that improves future work |

---

## Three pillars

<div class="pillar-cards">
  <div class="pillar-card">
    <h3>⚙️ System</h3>
    <div class="q">How do we work?</div>
    <ul>
      <li>Playbooks</li>
      <li>Skills</li>
      <li>Templates</li>
      <li>Configuration</li>
    </ul>
  </div>
  <div class="pillar-card">
    <h3>📦 Product</h3>
    <div class="q">What are we building?</div>
    <ul>
      <li>Initiatives</li>
      <li>Galleys</li>
      <li>Slugs</li>
      <li>Releases</li>
    </ul>
  </div>
  <div class="pillar-card">
    <h3>📖 Knowledge</h3>
    <div class="q">What have we learned?</div>
    <ul>
      <li>Signals</li>
      <li>Patterns</li>
      <li>Decisions</li>
      <li>Concepts</li>
    </ul>
  </div>
</div>

A **compound loop** runs across all three, continuously improving them as each delivery cycles through System → Product → Knowledge.

---

## Repository structure

```text
codepress/
├── system/        How we work — playbooks, skills, templates, hooks
├── product/       What we build — initiatives, galleys, slugs, releases
├── knowledge/     What we know — concepts, decisions, patterns, signals
├── views/         Helper views for at-a-glance status
├── src/           Source code
└── docs/          Project documentation
```

Each directory maps to a pillar. See full details on the [Structure page](structure.html).

---

## Core workflow

```text
Capture Initiative
        ↓
    Create Galley
        ↓
  Split into Slugs
        ↓
       Build
        ↓
      Release
        ↓
 Capture Signals
        ↓
Promote Patterns
        ↓
Update Knowledge
```

Each step links to a playbook or skill in `.codepress/system/`.

---

## How it compares

| Approach | Primary focus |
|---|---|
| Jira | Work tracking |
| Shape Up | Product shaping |
| Compound Engineering | AI delivery |
| BMAD | Build, measure, learn |
| **CodePress** | Product + delivery + knowledge |

<div class="compound-note">
<strong>📌 CodePress is not a replacement for Compound Engineering.</strong>
Compound Engineering helps build software faster. CodePress helps decide what to build, shape it into deliverable work, capture what was learned, and compound capability over time. They work together.
</div>

---

## Quick start

| Step | Action |
|---|---|
| 1 | Clone the CodePress template repository |
| 2 | Run `codepress init` to bootstrap |
| 3 | Populate `.codepress/system/config.md` with your project details |
| 4 | Read `AGENTS.md` for the full operating manual |
| 5 | Capture your first Initiative in `.codepress/product/initiatives/` |
| 6 | Run the create-galley skill to shape it |

---

## Learn more

| Page | Description |
|---|---|
| [Quick Reference](quick-reference.html) | Commands, structure, and workflow at a glance |
| [Structure](structure.html) | Full folder layout and artefact reference |
| [Core Concepts](core-concepts.html) | Initiative, Galley, Slug, Signal, Pattern explained |
| [FAQ](faq.html) | Frequently asked questions |
| [References](references.html) | Inspiration and related work |

---

## References & inspiration

| Resource | Description |
|---|---|
| [Linotype](https://github.com/zylum/linotype) | Predecessor to CodePress |
| [Compound Engineering](https://every.to/guides/compound-engineering) | The compounding approach |
| [BMAD Method](https://github.com/bmad-code-org/bmad-method) | Build-measure-learn for software |
| [Shape Up](https://basecamp.com/shapeup) | Basecamp's product shaping methodology |
| [Value Over Everything](https://www.linkedin.com/newsletters/value-over-everything-7015605132717359104/) | Product and value newsletter |
