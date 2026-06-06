---
id: ee-v1-s5
status: complete
galley: ee-v1
autonomy: continuous
---

# Slug: board-regeneration

## Purpose

Wire the existing `status.md` board-regeneration skill into the CLI so `codepress status` and `codepress run` automatically update the galley-board, initiative-board, and release-board views after each action.

## Acceptance checklist

- [ ] `codepress status` triggers regeneration of `galley-board.md` after showing output
- [ ] `codepress run` triggers board regeneration after each executed action
- [ ] `codepress galley move <n> <s>` triggers board regeneration after status change
- [ ] Board views reflect current state from artefact frontmatter (single source of truth)
- [ ] CLI output includes "Board updated" confirmation
- [ ] Performance is acceptable (board regeneration should be < 1s)

## Context

The `status.md` skill already defines how to regenerate the board — it scans galley.md frontmatter and rebuilds the kanban. The current CLI (`cmd_status()`) counts files but doesn't call the skill. This slug connects them.

The board regeneration logic:

1. Scan `.codepress/product/galleys/*/galley.md`
2. Read `status`, `id`, `title` from frontmatter
3. Group by status (shaping / approved / delivering / review / done)
4. Rewrite `.codepress/views/galley-board.md`
5. Same pattern for initiative-board and release-board

## Dependencies

None — can overlap with `codepress-run`.

## Evidence

- `regenerate_boards()` function added to CLI
- Scans all galley.md frontmatter, groups by status, writes kanban-format board
- Scans initiative.md files, populates Active/Backlog/Completed sections
- Release board template generated (empty until releases exist)
- Wired into `cmd_status()` — runs after showing output
- Wired into `cmd_run()` — runs after each executed action
- Wired into `cmd_galley_move()` — runs after status change
- Source of truth remains galley.md frontmatter at all times
- Regeneration completes in < 0.5s
