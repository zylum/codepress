---
id: parallel-run-skill
status: done
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

`skills/parallel-run.md` exists — 155 lines covering: worktree creation, per-group agent sessions, Claude Code specifics, merge strategy (`--no-ff`), conflict resolution, integration Slug pattern, and when not to use worktrees.

---

## Signals

- `git worktree` is sufficient as the core primitive — no extra tooling needed
- Keeping Claude Code specifics in a single callout (step 3) keeps the skill platform-agnostic otherwise
- Integration Slug template embedded in the skill eliminates ambiguity about when/how to create one
