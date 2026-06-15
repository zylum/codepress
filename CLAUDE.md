# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## What this repo is

CodePress is a compound product development operating system for AI-era teams. It ships as a Bash CLI (`codepress`) plus a `.codepress/` directory of markdown artefacts that govern the entire development lifecycle from idea to shipped feature.

The system runs on three pillars:

| Pillar | Directory | What |
|---|---|---|
| **System** | `.codepress/system/` | How we work — skills, templates, hooks |
| **Product** | `.codepress/product/` | What we build — initiatives, galleys, slugs, releases |
| **Knowledge** | `.codepress/knowledge/` | What we know — concepts, decisions, patterns |

A **Compound Loop** (Signal → Pattern → Knowledge) continuously improves all three.

---

## Commands

### Tests

```bash
bash tests/run_tests.sh          # Run all test suites
bash tests/test_status_detection.sh   # Run a single suite
bash tests/test_board_regeneration.sh
```

Tests are Bash scripts that create temporary CodePress projects, invoke `codepress status`, and assert expected pending actions appear in the output.

### CLI

The main entry point is the `codepress` Bash executable at the repo root.

```bash
./codepress init              # Bootstrap a new project
./codepress upgrade           # Pull latest version
./codepress status            # Show delivery board + pending actions
./codepress run               # Dispatch next pending action
./codepress run --all         # Dispatch all pending actions
./codepress watch [seconds]   # Watch artefact dir and auto-execute (default 2s)
./codepress galley new <name>
./codepress galley list
./codepress galley move <name> <status>
```

No build step — the CLI is a single Bash file, no compilation or package install needed.

---

## Architecture

### Pipeline flow

```
Initiative → Galley → Slugs → Build → Verify → Review → Release
                                         ↓
                                     Signals → Patterns → Knowledge
```

**Initiative** — a free-form idea or problem in `product/initiatives/`.

**Galley** — a shaped solution at `product/galleys/{name}/galley.md`. Contains: Problem, Users, Success metrics, Constraints, Approach, Acceptance Criteria, optional `holdout:` and `budget:` fields.

**Slug** — an atomic delivery unit at `product/galleys/{name}/slugs/{slug-id}.md`. Has a 3–7-item acceptance checklist, autonomy level (`continuous`/`confirm`/`stop`), and a Signals block filled before each commit.

**Run Sheet** — at `product/galleys/{name}/run-sheet.md`, defines Slug execution order and parallel groups.

**Review** — mandatory galley-close at `product/galleys/{name}/review.md`. A Galley cannot become `done` until review.md is complete, Signals are promoted, and Knowledge is updated.

### State machine

All state lives in YAML frontmatter of markdown files — no database.

Initiative lifecycle: `inbox → research → candidate → approved → shaping → galley-ready → archived`

Galley lifecycle: `shaping → approved → delivering → review → done`

`codepress status` reads frontmatter across all artefacts to detect pending actions and regenerate board views.

### Verifier

The verifier is a **separate agent** from the builder (configured in `codepress.md` under `engines.verifier`). It receives only the Galley spec and artefacts — no build history — preventing motivated reasoning. All `verify:` gates defined in `codepress.md` must pass before status advances.

### Knowledge compounding

Signals (raw observations captured per Slug during build) are promoted to Patterns at galley-close if they appear in 2+ galleys or are immediately generalizable. Patterns update `knowledge/` files.

---

## Reading order before any work

1. `system/codepress.md` — project config, pace, engines, verify gates
2. `knowledge/current-state.md` — what exists today
3. Relevant `knowledge/patterns/` — reusable lessons
4. Active galley in `product/galleys/` — what you are building

---

## Operating rules

- **Shape before build.** Read the full Galley before touching any code.
- **Capture Signals during delivery.** Fill the Signals block in each Slug *before* committing — not deferred to galley-close.
- **Galley-close is mandatory.** Complete `review.md`, promote Signals, update Knowledge before marking a Galley `done`.
- **Update Knowledge.** When you encounter a concept or decision not in `knowledge/`, add it — a 5-line stub beats nothing.

### Commit convention

```
slug:<name> done — <summary>
galley:<name> done
```

### Slash commands (Claude Code)

`.claude/commands/` provides wrappers that invoke skills directly:

| Command | Skill invoked |
|---|---|
| `/shape` | `system/skills/shape.md` |
| `/split` | `system/skills/split.md` |
| `/build` | `system/skills/build.md` |
| `/learn` | `system/skills/review.md` |
