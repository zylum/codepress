---
layout: default
title: FAQ
---

# FAQ

## What is CodePress?

CodePress is a compound product development operating system. It provides structure for building products with AI, ensuring that every delivery leaves behind reusable knowledge and capability.

## How is it different from other methodologies?

Most AI development approaches focus on `Idea → Code`. CodePress focuses on `Idea → Shape → Build → Learn → Compound`. The goal is not just to ship faster, but to get smarter with each cycle.

## What are the three pillars?

- **System** — how we work (playbooks, skills, templates, hooks)
- **Product** — what we build (initiatives, galleys, slugs, releases)
- **Knowledge** — what we know (concepts, glossary, decisions, patterns)

## What's a Galley?

A Galley is a shaped solution — the thinking artefact. It captures the problem, users, success criteria, constraints, approach, and acceptance criteria. It is built before any code is written.

## What's a Slug?

A Slug is an atomic unit of delivery. It has a clear purpose, an acceptance checklist, and produces a single coherent commit. Slugs are the smallest delegable change.

## What's the Compound Loop?

The loop that improves the entire system over time. Raw observations (Signals) become reusable lessons (Patterns) that update shared understanding (Knowledge). Every cycle leaves the organisation smarter.

## Do I need to use the CLI?

No. The CLI is a helper, not a requirement. The playbooks, skills, and templates in `.codepress/system/` contain everything you need. The CLI automates common tasks like bootstrapping and migration.

## Can I customise the structure?

Yes. The three pillars are the foundation, but you can add, remove, or reorganise within them. The system is designed to adapt to your project's needs, not the other way around.

## How do I get started?

1. Clone the CodePress template
2. Run `codepress init` to bootstrap
3. Populate `.codepress/system/codepress.md` with your project config
4. Read `.codepress/system/AGENTS.md` for the full operating manual
5. Capture your first Initiative in `.codepress/product/initiatives/`
6. Run `.codepress/system/skills/create-galley.md` to shape it
