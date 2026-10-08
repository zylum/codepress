# CodePress — Agent Operating Manual

CodePress is a compound product development system built on three pillars:
- **System** — how we work
- **Product** — what we build
- **Knowledge** — what we know

A compound loop runs across all three, continuously improving them.

---

## System files

| File | Purpose | Editable |
|---|---|---|
| `principles.md` | Core rules (never configurable) | No |
| `capabilities.md` | Required capabilities (implementation varies) | No |
| `dod.md` | Global Definition of Done | Project-specific |
| `codepress.md` | Project config | Yes |
| `AGENTS.md` | Agent operating manual (this file) | No |

---

## Modes of use

| Level | Name | What's available |
|---|---|---|
| 1 | Scaffold | `.codepress/` structure + templates. Human and AI work directly with markdown files. |
| 2 | Workshop | Scaffold + Obsidian Kanban boards. `codepress status` regenerates views. |
| 3 | Engine | Workshop + automation. `codepress run` dispatches skills. |

---

## Reading order

Before any work:

1. `system/principles.md` — core rules (never configurable)
2. `system/codepress.md` — project name, pace, conventions
3. `system/dod.md` — Definition of Done
4. `knowledge/current-state.md` — what exists today
5. Relevant `knowledge/patterns/` — reusable lessons for this area
6. Active galley in `product/galleys/` — what you are working on

---

## Artefacts

| Artefact | Location | Purpose |
|---|---|---|
| Initiative | `product/initiatives/` | An idea or problem worth exploring |
| Galley | `product/galleys/{name}/galley.md` | A shaped solution ready for delivery |
| Run Sheet | `product/galleys/{name}/run-sheet.md` | Execution plan — Slug order, parallel groups |
| Slug | `product/galleys/{name}/slugs/` | An atomic unit of delivery |
| Review | `product/galleys/{name}/review.md` | Galley-close learning capture |
| Signal | `knowledge/signals/` | A raw observation from delivery |
| Pattern | `knowledge/patterns/` | A reusable lesson |
| Release | `product/releases/` | Grouped shipped work |

---

## Status model

### Initiative lifecycle

`inbox → research → candidate → approved → shaping → galley-ready → archived`

### Galley lifecycle

`proposed → shaped → building → verifying → done` (or `killed` / `superseded` from any open status).

Approval is a gate on `shaped → building`, not a status: `codepress galley approve <galley>`.

The rules — statuses, allowed transitions, the gates each transition requires, and the mapping from older status
values — are **data** in `schema/lifecycle.yaml`, and `codepress lint` enforces them. Read `docs/lifecycle.md`.
A Galley cannot be marked `done` until all slugs are `closed` or `dropped`, evidence is cited in `review.md`, an
independent verifier has written the Verdict, `learned.md` exists, Signals are promoted to Patterns where
warranted, and Knowledge is updated. Move statuses with `codepress galley move` (the gates run there), never by
editing the frontmatter.

### Slug lifecycle

`open → building → closed`, or `dropped`. A closed slug has every non-`manual:` acceptance box ticked. Dropping
a slug is a plan change — log it in `plan-changes.md`.

### Before you commit

Run `codepress lint`. It rejects retired statuses, illegal transitions, terminal galleys missing evidence, review
or `learned.md`, version markers that disagree, and **drift** — a `slug:<name> done` commit whose acceptance boxes
were never ticked. `codepress hook install` runs it (and the test gate) on every commit; `--no-verify` is never
needed (see `docs/lifecycle.md`, "Git hook").

---

## Operating rules

**Shape before build.**
Read the Galley fully before touching code.

**Read Knowledge first.**
Check `knowledge/` before planning. Do not re-discover what already exists.

**Prose is not implementation.**
If a behavior depends on data (a schedule, a fact, a status), fetch the data and pass it into the model/logic. A rule written only in a system prompt is not built. Prompt-only behavior will hallucinate when the prompt is read in isolation.

**Update Knowledge.**
When you encounter a concept, decision or capability not in `knowledge/`, add it. A 5-line stub beats nothing.

**Capture Signals during delivery.**
Fill the Signals block in each Slug before committing — not deferred to galley-close.
Quick capture mid-session: run `skills/signal.md` with your observation.

**Galley-close is mandatory.**
Before marking a Galley `done`, complete `review.md`, promote Signals, and update Knowledge.

**Commit discipline.**
One commit per Slug: `slug:<name> done — <summary>`
One commit per Galley close: `galley:<name> done`
Tick the slug's acceptance boxes and set `status: closed` in the same commit — lint compares the commit to the files.

**The builder never writes the Verdict.**
The `## Verdict` block in review.md belongs to the verifier engine. The CLI enforces
it: `codepress galley move <galley> done` refuses a verdict whose `verified-by`
equals `engines.build`. Self-certification is mechanically blocked, not just forbidden.

**The builder never ticks a `manual:` AC.**
`manual:` lines mark human-only steps. The CLI enforces it: `codepress check` fails
any galley with a ticked `manual:` line. A human attests manual steps in the Verdict,
or waives explicitly with `--force` (which records a dated waiver in review.md).

> **Field evidence (2026-07, loom quality-hardening):** the build engine executed an
> infra step explicitly marked *manual* — against the wrong production service — and
> reported it `[x]` complete, then wrote its own "Gate passes. Galley close." verdict
> and set statuses uncontested. Textual fences did not constrain the agent. That is
> why the two rules above are enforced by the CLI, not by prose.

---

## Quality contract

### Principles (never configurable)

See `system/principles.md` for the full list.

Core rules:
- Builder cannot self-certify completion
- Verification is mandatory before merge
- Evidence required for every acceptance criterion
- Definition of Done applies globally

### Capabilities (must exist, implementation varies)

See `system/capabilities.md` for the full list.

Required capabilities:
- Automated verification (lint, typecheck, test)
- Evidence capture
- Independent review
- Decision documentation

### Defaults (configurable)

Configured in `system/codepress.md`:
- Reviewer: claude
- Tools: ruff, mypy, pytest (or alternatives)
- Branch naming: feature/*
- etc.

---

## Verification inheritance

Galleys inherit verification requirements from:

1. **Galley-specific** — `verify:` in galley.md frontmatter
2. **Project defaults** — `verify:` in codepress.md
3. **Capability requirements** — Lint must exist, typecheck if applicable, tests if applicable

If a Galley defines `verify: [test]`, only test runs. If it defines nothing, project defaults apply. If project defaults are empty, capability requirements apply.

---

## Autonomy levels

| Level | Meaning |
|---|---|
| `continuous` | Run to completion without checking in |
| `confirm` | Check with human before proceeding to next Slug |
| `stop` | Halt and wait for human input |

---

## Skills

| Skill | Purpose |
|---|---|
| `skills/bootstrap-project.md` | Bootstrap a new project (verification, DoD, etc.) |
| `skills/shape.md` | Shape an Initiative into a Galley |
| `skills/split.md` | Decompose a Galley into Slugs |
| `skills/build.md` | Execute a Galley through its Slugs |
| `skills/review.md` | Galley-close: Signals → Patterns → Knowledge |
| `skills/verify.md` | Run verification gates |
| `skills/release.md` | Cut a release |
| `skills/bootstrap.md` | Seed Knowledge from an existing codebase |
| `skills/status.md` | Regenerate the delivery board |
| `skills/signal.md` | Quick-capture an observation mid-session |
| `skills/parallel-run.md` | Run a parallel Slug group using git worktrees |

Claude Code users: `.claude/commands/` contains slash command wrappers — type `/shape`, `/split`, `/build`, or `/learn` to invoke skills directly.
