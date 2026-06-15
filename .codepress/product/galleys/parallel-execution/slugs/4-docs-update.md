---
id: docs-update
status: done
galley: parallel-execution
autonomy: continuous
---

# Slug: Docs Update

## Purpose
Update AGENTS.md and the README to mention parallel execution capability and Claude Code slash commands.

## Acceptance checklist
- [ ] AGENTS.md Skills table updated: add `skills/parallel-run.md` row
- [ ] AGENTS.md includes a note about `.claude/commands/` for Claude Code users
- [ ] `codepress init` `mkdir` updated to include `.claude/commands/` in scaffold
- [ ] README updated: parallel execution section added (3–5 lines, link to parallel-run.md)

## Dependencies
Depends on slugs 1, 2, 3.

## Evidence

`AGENTS.md` Skills table updated: added `skills/parallel-run.md` row with description "Run a parallel Slug group using git worktrees". Added note after the table: "Claude Code users: `.claude/commands/` contains slash command wrappers — type `/shape`, `/split`, `/build`, or `/learn` to invoke skills directly." `codepress init` `cmd_init()` updated with `mkdir -p .claude/commands`.

---

## Signals

- AGENTS.md is the canonical entry point for agents — adding parallel-run.md there makes it discoverable without agents needing to know about it in advance
- The Claude Code note sits outside the Skills table so it's additive and doesn't confuse non-Claude Code agents
- `codepress init` scaffold update ensures the `.claude/commands/` directory is created consistently for all new projects
