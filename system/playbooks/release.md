# Playbook: Release

Cut a release — group completed Galleys into a shippable version.

---

## When to run
When a set of completed Galleys is ready to ship together.

---

## Steps

### 1. Select Galleys

Identify which done Galleys belong in this release.

### 2. Create release note

Use `system/templates/release.md` to document what shipped.
Save to `product/releases/{release-name}.md`.

### 3. Run hooks

Run `on-release` hooks in `system/hooks/on-release.md` for any post-release automation.

### 4. Tag

Tag the release in version control using the release name or version number.

---

## Output
- Release note in `product/releases/`
- Tagged release in git
