# Review: Docs Refresh

## Signals

- `hermes.md` held the densest cluster of stale references — old skill names in both a prose principle and a status-detection table. It was not in the original slug 2 checklist, but the verify grep caught it. Pattern: always run a broad grep verify pass, not just targeted edits.
- `modes-of-use.md` had stale text inside a feature comparison table row ("Playbooks, skills, templates") — easy to miss in a visual scan, found cleanly by grep.
- `quick-start.md` referenced `create-galley` in a step description. Also missed in the initial checklist, caught by verify.
- README 80-line constraint forced a structural choice: collapsed the directory tree to a compact inline representation. The full tree belongs in `docs/structure.md`, not the README.
- 4 hops reading order added to `docs/overview.md` as a new section — it was completely absent from the docs site before this galley.

## Surprises

- 9 files exist in `system/skills/` (shape, split, build, review, verify, release, bootstrap, status, signal) but the task spec listed 8. `signal.md` is the extra. README and docs use the 8-skill list from the spec.
- `docs/hermes.md` referenced `playbooks/learn.md` which doesn't exist in the current system — another stale artefact cleaned up.

## Pattern candidates

- **Verify greps should be broader than the edit checklist** — slug 2 listed 7 files but 2 more had stale references. A project-wide grep is always the right final step.
- **README line budgets force information hierarchy decisions** — the constraint of ≤80 lines surfaced where detail belongs (docs/ vs README).

## Knowledge updates

- `docs/overview.md` now documents the 4-hop reading order — previously undocumented in the docs site.
- All docs pages now consistently use "skills" (not "playbooks").
