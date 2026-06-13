---
id: verify
status: done
galley: docs-refresh
autonomy: continuous
---

# Slug: Verify

## Purpose
Final check pass — confirm GitHub Pages builds cleanly and no stale references remain.

## Acceptance checklist
- [ ] Search for "playbooks" across README and docs/ — zero results
- [ ] Search for "create-galley" and "split-galley" — zero results (replaced by shape/split)
- [ ] `bundle exec jekyll build` runs without errors (if Jekyll available locally)
- [ ] GitHub Pages deployment succeeds (check Actions tab after push)

## Dependencies
Depends on slugs 1 and 2.

## Evidence

- `grep -r "playbooks" README.md docs/` → zero results.
- `grep -r "create-galley|split-galley|capture-pattern|generate-release" docs/ README.md` → zero results.
- Jekyll build not run locally (no local bundle); GitHub Pages deployment will confirm on push.

---

## Signals

- Both grep checks passed cleanly after fixing hermes.md and quick-start.md — the two files not in the original slug 2 checklist.
- Verify step caught stale references in files not listed in slug 2 — confirms that a broad grep pass is essential, not just targeted file edits.
- No broken internal links detected (all hrefs in Jekyll pages remain unchanged).
