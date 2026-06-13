---
layout: default
title: Core Concepts
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

# Core Concepts

## Initiative

An opportunity worth exploring. Free-form — a problem statement, an idea, a user need. Initiatives are the raw material for the pipeline. They live in `.codepress/product/initiatives/`.

## Galley

A shaped solution ready for delivery. The Galley captures Problem, Users, Success, Constraints, Approach, and Acceptance Criteria. Named after the linotype printing tray that held assembled type before it went to press. Galleys live in `.codepress/product/galleys/{name}/`.

**Lifecycle:** `shaping → approved → delivering → review → done`

## Slug

An atomic unit of delivery. Each Slug has a purpose, an acceptance checklist (3–7 items), and an autonomy level (`continuous`, `confirm`, or `stop`). Slugs are designed to be built independently and in parallel. They live in `.codepress/product/galleys/{name}/slugs/`.

A Slug template ends with a `## Signals` block — a place to record raw observations during delivery. These are filled in as the slug is built and become the input for the galley `review.md` at close.

## Signal

A raw observation captured during delivery. Signals are recorded in the Galley's `review.md` during the build phase and promoted to `.codepress/knowledge/signals/` at galley-close. A good Signal is specific, evidence-backed, and actionable.

## Pattern

A validated, reusable lesson extracted from one or more Signals. A Signal becomes a Pattern when it appears across multiple Galleys independently, or when it is immediately generalizable. Patterns live in `.codepress/knowledge/patterns/`.

## Knowledge

Shared understanding of the product — concepts, terminology, decisions, current capabilities, and patterns. Lives in `.codepress/knowledge/`. This is what makes the compound loop work: every delivery updates it, and every future delivery benefits from it.

## The compound loop

```text
Signal → Pattern → Knowledge
```

The feedback loop that connects delivery to organisational learning. Signals are captured during delivery, promoted to Patterns when they prove reusable, and update Knowledge when the system changes. This is what makes CodePress different from a simple project management system.
