---
id: claude-commands
status: done
galley: parallel-execution
autonomy: continuous
---

# Slug: Claude Commands

## Purpose
Create `.claude/commands/` wrapper files that make CodePress skills accessible as Claude Code slash commands.

## Acceptance checklist
- [ ] `.claude/commands/shape.md` created — loads `skills/shape.md`
- [ ] `.claude/commands/split.md` created — loads `skills/split.md`
- [ ] `.claude/commands/build.md` created — loads `skills/build.md`
- [ ] `.claude/commands/learn.md` created — loads `skills/review.md`
- [ ] Each wrapper is ≤5 lines: a description line + instruction to read and follow the skill
- [ ] `.claude/` directory included in `codepress init` scaffold

## Context
Claude Code custom commands live in `.claude/commands/*.md`. When a user types `/shape`, Claude reads the command file and executes it. The wrapper content should be: "Read `.codepress/system/skills/shape.md` and follow the steps." No content duplication.

Format for each command file:
```markdown
---
description: Shape an Initiative into a Galley
---
Read `.codepress/system/skills/shape.md` and follow all steps.
```

## Dependencies
None (can run in parallel with parallel-run-skill).

## Evidence

`.claude/commands/` created with four files: `shape.md`, `split.md`, `build.md`, `learn.md`. Each is ≤5 lines with a frontmatter description and a single instruction to read the target skill. `codepress init` `cmd_init()` updated to `mkdir -p .claude/commands` alongside the other scaffold directories.

---

## Signals

- Wrapper format is minimal by design — description + one line; no content duplication with the skill files
- `shape.md` and `split.md` were partially pre-created; `build.md` and `learn.md` added in this slug
- Adding `.claude/commands` to `cmd_init()` ensures all new projects get slash command support without manual setup
