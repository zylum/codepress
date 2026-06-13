# Skill: Release

Cut a release — group completed Galleys into a shippable version.

---

## When to use
When a set of `done` Galleys is ready to ship together.

---

## Steps

1. Check current release theme and pool in `.codepress/system/codepress.md`
2. Pick the next unused release name (or use version number)
3. Scan `product/galleys/*/galley.md` for `status: done` — filter by `release:` frontmatter if set
4. Draft the release note using `.codepress/system/templates/release.md`
5. Save to `.codepress/product/releases/{name}.md`
6. Run hooks in `.codepress/system/hooks/on-release.md` if present
7. Tag the release in git

---

## Output
- Release note in `product/releases/{name}.md`
- Git tag on the release commit
