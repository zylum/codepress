# Skill: Generate Release

Create a release note from completed Galleys.

---

## When to use
When a set of Galleys is ready to ship as a release.

---

## Steps

1. Check current release theme and pool in `system/codepress.md`
2. Pick the next unused release name from the pool (or use version number)
3. Scan all `product/galleys/*/galley.md` files with `status: done`
4. Filter by the `release:` frontmatter field (if set)
5. Draft the release note using `system/templates/release.md`
6. Save to `product/releases/{name}.md`
7. Update `views/release-board.md`

---

## Output
Release note in `product/releases/{name}.md`
