# Skill: Bootstrap

Set up CodePress for a project — configure working style, then seed Knowledge.

Run this once when adding CodePress to an existing project, or to a new project before the first Galley.

---

## Phase 1: Configure — populate .codepress/system/codepress.md

Ask the following questions before touching the codebase.
Populate `.codepress/.codepress/system/codepress.md` from the answers.

---

### Q1 — Project identity

> "What is this project? Give it a name and a one-line description."

Populate:
```
## Project
name: {answer}
description: {answer}
```

---

### Q2 — Release theme

> "Do you want to give each release a themed codename?
> Examples: 80s movies, Miyazaki films, jazz albums, space missions, Bowie albums.
> Or skip if you prefer plain version numbers."

If yes, ask for the theme name and a pool of 8–10 names.
Populate:
```
## Release Theme
Each release is named after {theme}.
Pool: {names}
```

If skipped, remove the Release Theme section from `.codepress/.codepress/system/codepress.md`.

---

### Q3 — Working pace

> "How do you want to work on this project?
>
> **fast** — move quickly, iterate, minimal checkpoints. Good for prototypes and early exploration.
> **balanced** — human approves Galley shape before delivery starts. Review at key boundaries.
> **careful** — frequent checkpoints, human reviews each stage. Good for production-critical or regulated work.
>
> Which fits best — fast, balanced, or careful?"

Populate:
```
pace: {answer}
```

Then infer sensible defaults based on pace:

| Pace | Default autonomy | Suggested approval gates |
|---|---|---|
| fast | continuous | none required |
| balanced | continuous | shaping → approved |
| careful | confirm | shaping → approved, review → done |

Ask: *"Are these defaults right, or do you want to adjust them?"*

Populate approval gates and default-autonomy accordingly.

---

### Q4 — Team and roles

> "Is this a solo project, or are others involved?
> If there's a team, what roles exist? (e.g. human shaper + AI builder, full team with reviewers, etc.)"

Populate:
```
team-size: {solo | small-team | team}
Roles:
- {list}
```

---

### Q5 — Quality bar

> "Two quick questions about standards:
>
> 1. Testing: what does 'done' require? (e.g. unit tests for logic, E2E for journeys, none for now)
> 2. PR policy: should code go through a PR before merging, or commit directly?"

Populate the Testing expectations and PR policy sections.

---

### Q6 — Any conventions?

> "Anything specific about how this project works that AI agents should know?
> For example: naming conventions, folder patterns, things to always or never do."

Populate the Conventions section, or leave blank if nothing to add.

---

### Confirm before continuing

Show the populated `.codepress/.codepress/system/codepress.md` and ask:
*"Does this look right? I'll use this to guide how I work on this project."*

Apply any corrections, then proceed to Phase 2.

---

## Phase 2: Seed Knowledge

Scan the codebase and populate `.codepress/knowledge/`.

### 1. Scan the codebase

Read the repository structure. Identify:
- Key directories and what they contain
- Core entities, models, and concepts
- Main entry points and APIs
- Technology stack and key dependencies
- Existing documentation or README files

### 2. Seed concepts.md

Extract the 10–15 most important concepts in the codebase.
For each: name, one-sentence description, where it lives in the repo.
Write to `.codepress/knowledge/concepts.md`.

### 3. Seed glossary.md

Extract terminology used in the codebase that needs defining:
- Domain-specific terms
- Abbreviations and acronyms
- Internal naming conventions
Write to `.codepress/knowledge/glossary.md`.

### 4. Seed current-state.md

Describe what the system currently does:
- Core capabilities (what it can do today)
- What is live / in production
- What is actively in progress
- Known limitations or gaps
Write to `.codepress/knowledge/current-state.md`.

### 5. Suggest first Initiatives

Based on what you found, draft 1–2 starting Initiatives in `.codepress/product/initiatives/`.
Focus on: obvious gaps, known pain points, the next logical step.

### 6. Report

Summarise what was configured and what was seeded.
Flag anything uncertain — do not invent facts about the codebase.

---

## Output

- `.codepress/.codepress/system/codepress.md` fully populated
- `.codepress/knowledge/concepts.md` seeded
- `.codepress/knowledge/glossary.md` seeded
- `.codepress/knowledge/current-state.md` seeded
- 1–2 draft Initiatives in `.codepress/product/initiatives/`

---

## Notes

Phase 1 must complete before Phase 2.
`.codepress/.codepress/system/codepress.md` sets the working style that all agents will follow — get it right first.
Knowledge is a first pass. It will be imperfect. Prefer a useful stub over waiting for perfection.
