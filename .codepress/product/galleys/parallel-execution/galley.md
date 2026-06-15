---
id: parallel-execution
status: done
initiative: 
release: 
created: 2026-06-13
verify: []
---

# Galley: Parallel Execution

## Problem
Run-sheets identify parallel opportunities but provide no mechanism to actually run them. The parallel note is informational only — agents and humans still execute sequentially by default. On larger Galleys this wastes significant time.

## Users
AI agents (Claude Code, any agentic tool) building inside a CodePress project with independent Slug groups. Also humans coordinating multiple agents on the same Galley.

## Success
- run-sheet.md has a machine-readable `parallel-groups` block that tools can parse
- `skills/parallel-run.md` gives step-by-step instructions for parallel execution using git worktrees
- `skills/split.md` explicitly names parallel groups when decomposing
- Any agent can run a parallel group without extra tooling beyond git
- Claude Code-specific integration (`.claude/commands/`) makes parallel execution accessible as slash commands

## Constraints
- Core mechanism must be platform-agnostic (git worktrees, not Claude Code-specific)
- Claude Code integration is additive — `.claude/commands/` files are optional, don't break projects without Claude Code
- No new dependencies — git is assumed available
- Does not change the Slug format itself

## Approach
Two layers:

1. **Structural layer** — `run-sheet.md` gains a `parallel-groups` YAML block (already seeded in `skills/split.md` from Phase 1). The `skills/parallel-run.md` skill gives platform-agnostic instructions: create worktree per group, run slugs, merge back.

2. **Claude Code integration** — `.claude/commands/` with thin wrappers for the most-used skills: `shape`, `split`, `build`, `learn`. These make skills callable as `/shape`, `/split` etc. from within Claude Code sessions. No content in the wrappers — they simply load the skill file.

## Acceptance Criteria
- [x] `skills/parallel-run.md` exists with complete worktree-based parallel instructions
- [x] `skills/split.md` references `parallel-run.md` for parallel groups
- [x] `.claude/commands/shape.md` exists (loads `skills/shape.md`)
- [x] `.claude/commands/split.md` exists (loads `skills/split.md`)
- [x] `.claude/commands/build.md` exists (loads `skills/build.md`)
- [x] `.claude/commands/learn.md` exists (loads `skills/review.md`)
- [x] `.claude/commands/signal.md` exists (loads `skills/signal.md`) — depends on learning-loop galley
- [x] README or AGENTS.md updated to mention parallel execution capability
