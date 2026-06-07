---
id: ee-001
status: galley-ready
created: 2026-06-05
---

# Initiative: Execution Engine

## Problem

CodePress has a complete set of skills, playbooks, and templates, but moving through the product lifecycle is entirely manual. A human must detect when an Initiative is ready for shaping, when a Galley is approved and ready to split, when Slugs are complete and ready for review, and when it's time to capture signals and release. The system already knows what should happen next — nothing automates the chain.

## Context

The current CLI has `codepress status` (reads artefact state) and `codepress galley move` (sets status), but no `codepress run` to execute pending workflows, no watch mode, and no engine dispatch. All 7 skills and 6 playbooks exist and are ready to be wired into an automated pipeline.

The wider context: AI delivery is shifting toward agentic workflows. A status-driven engine makes CodePress programmable — CI/CD for product delivery.

## Why now

The skills and playbooks are mature enough that the bottleneck is content, not orchestration. Building the engine now means every future Galley benefits from automation. Also dogfooding — CodePress should run itself.

## Thoughts

The engine should support two modes: manual (`status` + `run`) and eventually watch. Engine dispatch (which AI agent runs which workflow) should be configurable in `codepress.md`. The engine itself must be model-agnostic — Claude today, Opencode, Codex, Gemini tomorrow.

## Attachments

- `.codepress/system/skills/` — 7 existing skills
- `.codepress/system/playbooks/` — 6 existing playbooks
- `.codepress/system/templates/` — 6 existing templates
- `codepress` — CLI tool (bash, 436 lines)
