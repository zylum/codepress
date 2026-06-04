# Skill: Bootstrap

Seed CodePress Domain Memory from an existing codebase.

---

## When to use

- First-time setup of CodePress in an existing project
- After a long period of development without CodePress
- When Domain Memory feels stale or significantly incomplete

---

## Steps

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
Write to `05-domain/concepts.md`.

### 3. Seed glossary.md

Extract terminology used in the codebase that needs defining:
- Domain-specific terms
- Abbreviations and acronyms
- Internal naming conventions
Write to `05-domain/glossary.md`.

### 4. Seed current-state.md

Describe what the system currently does:
- Core capabilities (what it can do today)
- What is live / in production
- What is actively in progress
- Known limitations or gaps
Write to `05-domain/current-state.md`.

### 5. Update domain index

Add discovered modules to the module map in `05-domain/index.md`.

### 6. Suggest first Initiatives

Based on what you found, draft 1–2 starting Initiatives in `01-initiatives/`.
Focus on: obvious gaps, known pain points, the next logical step.

### 7. Report

Summarise what was seeded and what still needs human review or correction.

---

## Output

- `05-domain/concepts.md` populated
- `05-domain/glossary.md` populated
- `05-domain/current-state.md` populated
- `05-domain/index.md` module map updated
- 1–2 draft Initiatives in `01-initiatives/`

---

## Notes

This is a first pass. Domain Memory will be imperfect.
Flag anything uncertain — do not invent facts about the codebase.
Prefer a useful stub over waiting for perfection.
