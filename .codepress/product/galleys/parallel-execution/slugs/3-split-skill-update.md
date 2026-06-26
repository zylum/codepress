---
id: split-skill-update
status: done
galley: parallel-execution
autonomy: continuous
---

# Slug: Split Skill Update

## Purpose
Update `skills/split.md` to explicitly reference `skills/parallel-run.md` when parallel groups are identified.

## Acceptance checklist
- [ ] `skills/split.md` step 5 links to `skills/parallel-run.md`: "If parallel groups exist, see parallel-run.md for execution instructions"
- [ ] The `parallel-groups` YAML block in the run-sheet template is consistent with `parallel-run.md` format
- [ ] No duplicate instructions — split.md defines the structure, parallel-run.md defines the execution

## Dependencies
Depends on both slug 1 (parallel-run-skill) and slug 2 (claude-commands) completing.

## Evidence

`skills/split.md` updated: added single line after the `parallel-groups` YAML block in step 5 — "If parallel groups are present, see `skills/parallel-run.md` for execution instructions." No content duplicated between the two files.

---

## Signals

- A single cross-reference line is sufficient — split.md defines the structure, parallel-run.md defines the execution
- Placing the reference immediately after the YAML block (not at the bottom) means the agent sees it while still in context
- The `parallel-groups` YAML format in split.md matches what parallel-run.md expects — no reconciliation needed
