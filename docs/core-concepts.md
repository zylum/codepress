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

**Failure Signal** — a structured Signal variant for when something breaks:

```yaml
type: failure
what-failed: "<gate or criterion>"
why: "<root cause>"
rule-changed: "<generalizable lesson>"
```

`rule-changed` is mandatory. A failure without a lesson is an incident log. A failure with a rule is a Pattern candidate.

## Pattern

A validated, reusable lesson extracted from one or more Signals. A Signal becomes a Pattern when it appears across multiple Galleys independently, or when it is immediately generalizable. Patterns live in `.codepress/knowledge/patterns/`.

## Knowledge

Shared understanding of the product — concepts, terminology, decisions, current capabilities, and patterns. Lives in `.codepress/knowledge/`. This is what makes the compound loop work: every delivery updates it, and every future delivery benefits from it.

## Verifier

The agent responsible for evaluating a Galley's output against its acceptance criteria. The verifier runs in a **fresh session** — it has not seen the build process, only the Galley spec and the artefacts. This separation prevents motivated reasoning: an agent that built the code will rationalise edge cases; an independent verifier evaluates against what was promised.

Set `verifier:` in the engines block of `codepress.md` to define which agent handles this role. If `holdout: true` is set on the Galley, the reviewer holds additional criteria not visible to the builder — the verifier evaluates these at review time.

## Budget

First-class constraints on a Galley or Slug. Set in frontmatter:

```yaml
budget:
  wall-clock: 4h
  tokens: 200k
  cost: $2.00
```

Hooks emit a warning Signal when 80% is consumed and halt the Slug at 100%.

## The compound loop

```text
Signal → Pattern → Knowledge
```

The feedback loop that connects delivery to organisational learning. Signals are captured during delivery, promoted to Patterns when they prove reusable, and update Knowledge when the system changes.

**Entropy check** — the loop-closing question asked at every galley review:

> Did we improve the system, or just deliver a feature? What rule did this Galley discover? Did we plateau? What would make the next Galley 20% cheaper?

Without this question, the system delivers but never compounds.
