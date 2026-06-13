---
id: readme
status: done
galley: docs-refresh
autonomy: continuous
---

# Slug: README Update

## Purpose
Update README.md to reflect v0.3.0: merged skills, current reading order, correct CLI commands.

## Acceptance checklist
- [ ] Opening description accurate — 3 pillars (System/Product/Knowledge), compound loop
- [ ] Structure section: `system/skills/` listed (not `playbooks/`), 8 skills named correctly
- [ ] Reading order: 4 hops (codepress.md → current-state.md → patterns → active galley)
- [ ] CLI commands section: `init`, `upgrade`, `status`, `run [--all]`, `galley new|list|move`
- [ ] Version 0.3.0 mentioned
- [ ] ≤80 lines total

## Dependencies
None.

## Evidence

README rewritten to 72 lines (≤80 limit). All 8 skills named. 4-hop reading order present. CLI commands include `init`, `upgrade`, `status`, `run [--all]`, `galley new|list|move`. No references to "playbooks". Version 0.3.0 in title.

---

## Signals

- The structure tree in README collapsed to a single inline row — readable but compact; full tree lives in docs/structure.md which is the right place for detail.
- v0.3.0 in the `# CodePress v0.3.0` heading is a simple, scannable signal to returning users that something changed.
- 8 skills listed inline with middle-dot separators fits on one line and avoids a table or bullet list that would eat into the line budget.
