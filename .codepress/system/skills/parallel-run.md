# Skill: Parallel Run

Execute a parallel group of Slugs using git worktrees. Platform-agnostic — requires only `git`.

---

## When to use

When a `run-sheet.md` contains a `parallel-groups` block and two or more Slugs in a group are ready to execute.

---

## Core primitive

```
git worktree add ../{project}-{group} -b slug/{group}
```

Each group gets its own worktree and branch. Agents work in isolation. Branches merge back when the group completes.

---

## Steps

### 1. Identify the parallel group

Read `run-sheet.md`. Find the next group whose `depends-on` groups are all complete. Note the group `id` and `slugs` list.

### 2. Create a worktree per group member

For each Slug in the group, create a worktree:

```bash
# From the repo root
git worktree add ../{project}-{slug-name} -b slug/{slug-name}
```

Example — group A has slugs `parallel-run-skill` and `claude-commands`:

```bash
git worktree add ../myproject-parallel-run-skill -b slug/parallel-run-skill
git worktree add ../myproject-claude-commands    -b slug/claude-commands
```

Each worktree is a full checkout at the current HEAD. Changes in one do not affect the other.

### 3. Run Slugs in each worktree

Open a separate agent session in each worktree directory. Each agent:

1. Reads the Slug file at `{galley}/slugs/{slug}.md`
2. Executes the Slug steps
3. Commits: `slug:{name} done — {summary}`

**Claude Code specifically:** open a separate Claude Code session (`claude`) pointed at the worktree directory. One session per worktree. Do not share sessions across worktrees — each session has independent file context.

```bash
# Terminal 1
cd ../myproject-parallel-run-skill
claude

# Terminal 2
cd ../myproject-claude-commands
claude
```

### 4. Wait for all group members to complete

All Slugs in the group must reach `status: done` before merging. Coordinate via the run-sheet or manually confirm each session has committed.

### 5. Merge back

From the repo root, merge each branch in turn:

```bash
git merge --no-ff slug/parallel-run-skill -m "merge: slug/parallel-run-skill"
git merge --no-ff slug/claude-commands    -m "merge: slug/claude-commands"
```

`--no-ff` preserves the parallel work history.

Resolve any conflicts (see step 6). Then remove the worktrees:

```bash
git worktree remove ../myproject-parallel-run-skill
git worktree remove ../myproject-claude-commands
git branch -d slug/parallel-run-skill
git branch -d slug/claude-commands
```

### 6. Resolve conflicts

Most parallel groups touch different files and merge cleanly. If conflicts arise:

- **Mechanical conflicts** (e.g., both branches added a row to the same table): resolve by hand, keeping both changes.
- **Semantic conflicts** (e.g., two branches changed the same function in incompatible ways): create an integration Slug (see below).

### 7. Proceed to the next group

Mark the parallel group complete in your tracking. Check `run-sheet.md` for the next group whose `depends-on` is now satisfied, then repeat.

---

## Integration Slug

Create a dedicated integration Slug when:

- Two or more Slug branches modify the **same file** and the merge cannot be resolved mechanically
- Branches establish an **API contract** (function signatures, schema columns, config keys) that both sides depend on — the contract must be agreed before parallel work starts, or reconciled after
- Branches both modify a **DB schema** — migrations must run in order; verify combined migration is valid

Integration Slug template:

```markdown
---
id: {group-id}-integration
status: open
galley: {galley}
autonomy: confirm
---

# Slug: {Group} Integration

## Purpose
Reconcile outputs of parallel group {group-id}: resolve conflicts, verify contracts, confirm combined state is consistent.

## Acceptance checklist
- [ ] All merge conflicts resolved
- [ ] Shared interfaces consistent across merged branches
- [ ] Tests / verification pass on merged state
- [ ] Combined commit history is clean

## Dependencies
Depends on: all Slugs in group {group-id}
```

Add this Slug to `run-sheet.md` as a sequential step after the parallel group.

---

## When not to use worktrees

- Slugs that share a **config file edited by both** — sequence them instead
- Slugs where one's output is the other's input — these have a data dependency; they are not truly parallel
- Very small groups (2 Slugs, <30 min total) — overhead of worktree setup may exceed the time saved; sequential is fine

---

## Output

- Merged commits from all group Slug branches on main/base branch
- Worktrees and group branches removed
- All Slug statuses set to `done`
- `run-sheet.md` group marked complete
