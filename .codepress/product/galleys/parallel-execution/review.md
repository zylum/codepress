# Review: Parallel Execution

## Signals

- `git worktree` is sufficient as the sole primitive for parallel execution — no new tooling needed
- The two-layer design (structural: parallel-groups YAML + parallel-run.md; Claude Code: .claude/commands/ wrappers) kept concerns cleanly separated
- Cross-reference placement matters: adding the parallel-run.md reference immediately after the YAML block in split.md (not at the bottom) keeps agents in context
- Wrapper files for Claude Code slash commands are trivially small — description + one instruction line — avoiding content duplication entirely
- Adding `.claude/commands` to `codepress init` scaffold means all new projects get slash command support without manual setup

## Surprises

- `shape.md` and `split.md` command wrappers were pre-created; only `build.md` and `learn.md` needed creating in slug 2
- `skills/parallel-run.md` was already seeded (155 lines, comprehensive); slug 1 was effectively a verification + sign-off rather than authorship

## Pattern candidates

- **Cross-reference-not-duplicate**: when two skills divide structure from execution, a single cross-reference line beats copying instructions. Keeps the authoritative source of truth in one place.
- **Scaffold-once, discover-always**: adding tooling directories (like `.claude/commands/`) to `codepress init` is the right gate — agents and humans both find them without documentation hunting.

## Knowledge updates

- `knowledge/` should include a note that parallel-run.md is the execution companion to split.md — agents reading split.md will be directed there when parallel groups are present.
