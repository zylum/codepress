---
layout: default
title: CodePress
---

<link rel="stylesheet" href="/codepress/assets/css/custom.css">

<div class="tab-nav">
  <a href="overview.html">Overview</a>
  <a href="faq.html">FAQs</a>
  <a href="quick-reference.html">Reference</a>
</div>
<div class="page-nav">
  <a class="primary-nav" href="index.html">Home</a>
  <a href="quick-start.html">Quick Start</a>
  <a href="structure.html">Structure</a>
  <a href="https://github.com/zylum/codepress">GitHub</a>
</div>

<div class="codepress-hero">

# Shape Ideas. Build in Parallel. Compound Knowledge.

<div class="sub">
CodePress helps teams turn initiatives into shippable software while capturing everything they learn along the way.
</div>

<div class="tagline">
Shape once. Build many. Learn forever.
</div>

</div>

---

## Three pillars

<div class="pillar-cards">
  <div class="pillar-card">
    <h3>⚙️ System</h3>
    <div class="q">How do we work?</div>
    <ul>
      <li>Skills (10)</li>
      <li>Templates</li>
      <li>Hooks</li>
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

## How it works

The CodePress pipeline turns ideas into delivered value while capturing everything learned along the way.

```text
Initiative ──→ Galley ──→ Slugs ──→ Release ──→ Signals ──→ Patterns ──→ Knowledge
  (shape)      (split)    (build)   (deliver)   (capture)   (promote)    (update)
```

| Stage | What it is | Action |
|---|---|---|
| **Initiative** | An opportunity worth exploring — captured in `.codepress/product/initiatives/` | Shape |
| **Galley** | A shaped solution ready for implementation — Problem, Users, Success, Constraints, Approach, Acceptance Criteria | Create / Split |
| **Slugs** | Atomic delivery units built independently and in parallel. Each has a purpose, checklist, and autonomy level | Build |
| **Release** | Delivered value | Release |
| **Signals** | What we learned during delivery — raw observations recorded at galley-close | Capture |
| **Patterns** | Reusable lessons extracted from signals and validated across multiple deliveries | Promote |
| **Knowledge** | Shared understanding that improves future work — concepts, glossary, decisions, current-state | Update |

Each step links to a playbook or skill in `.codepress/system/`. See [Quick Reference](quick-reference.html) for commands and lifecycle.

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

## Get started

<div class="ctas" style="margin: 1rem 0 1.5rem;">
  <a class="primary" href="quick-start.html">Quick Start →</a>
  <a class="secondary" href="structure.html">View Structure</a>
  <a class="secondary" href="overview.html">View Diagram</a>
  <a class="secondary" href="https://github.com/zylum/codepress">GitHub</a>
</div>

---

## Learn more

| Page | Description |
|---|---|---|
| [Quick Start](quick-start.html) | Install and first steps |
| [Modes of Use](modes-of-use.html) | Scaffold → Workshop → Engine — choose your level |
| [Quick Reference](quick-reference.html) | Commands, structure, and workflow at a glance |
| [Structure](structure.html) | Full folder layout and artefact reference |
| [Core Concepts](core-concepts.html) | Initiative, Galley, Slug, Signal, Pattern explained |
| [Overview](overview.html) | Pipeline diagram and lifecycle visual |
| [Hermes Integration](hermes.html) | Optional automation agent for context-aware execution |
| [FAQ](faq.html) | Frequently asked questions |
| [References](references.html) | Inspiration and related work |
