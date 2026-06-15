---
id: docs-refresh
status: done
initiative: 
release: 
created: 2026-06-13
verify: []
---

# Galley: Docs Refresh + GitHub Pages

## Problem
The docs site (`docs/`) and README are stale. They don't reflect v0.3.0 changes: merged skills (no more `playbooks/`), the new reading order, the Signals block in slugs, or the `codepress run` and `codepress status` commands. New users or agents reading the docs get incorrect information. GitHub Pages is set up but the content doesn't match the current system.

## Users
New agents bootstrapping a project from the docs site. Existing users running `codepress upgrade`. Anyone reading the GitHub Pages site.

## Success
- README reflects the current structure: 8 skills, no playbooks, correct reading order
- `docs/quick-reference.md` has accurate `codepress status`, `codepress run`, `codepress galley` commands
- `docs/overview.md` or equivalent accurately describes the 3-pillar model and learning loop
- `docs/structure.md` reflects that `system/` has `skills/` only (no `playbooks/`)
- GitHub Pages deploys cleanly from the `docs/` directory
- Version 0.3.0 is mentioned

## Constraints
- docs/ is Jekyll-based — keep the existing Jekyll setup, don't switch generators
- Don't add pages beyond what exists — update existing pages only
- README stays concise — no more than 80 lines

## Approach
Two parallel streams:
1. README update — accurate feature list, correct structure, current commands, v0.3.0
2. Docs site update — update each existing page for Phase 1 changes (skills merge, reading order, Signals block)

## Acceptance Criteria
- [x] README accurately describes the current 3-pillar structure and 8 skills
- [x] README lists correct CLI commands: `init`, `upgrade`, `status`, `run`, `galley`
- [x] `docs/quick-reference.md` updated with `run` and `status` commands
- [x] `docs/structure.md` updated: `system/skills/` only, no `playbooks/`
- [x] `docs/overview.md` updated: reading order is 4 hops, not 5
- [x] `docs/core-concepts.md` updated: Signals block in slug template mentioned
- [x] GitHub Pages deploys without errors
