---
id: parallel-run-skill
status: open
galley: parallel-execution
autonomy: continuous
---

# Slug: Parallel Run Skill

## Purpose
Create `skills/parallel-run.md` with complete, platform-agnostic instructions for running a parallel group using git worktrees.

## Acceptance checklist
- [ ] `skills/parallel-run.md` exists
- [ ] Instructions cover: create worktree per group, run slugs in each, merge back, resolve conflicts
- [ ] Claude Code-specific path called out explicitly: one agent per worktree via separate Claude Code sessions
- [ ] Merge strategy defined: PR per group branch, or `git merge --no-ff slug/{name}`
- [ ] Integration Slug pattern described: when to create a dedicated "merge" Slug

## Context
The core primitive is `git worktree add ../{project}-{group} -b slug/{group}`. Each agent works in isolation, commits its Slugs, and the branches are merged when the group completes. This is already git — no new tooling.

## Dependencies
None.

## Evidence

---

## Signals
