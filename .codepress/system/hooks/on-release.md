# Hook: on-release

Fires when a release is cut.
Placeholder for post-release automation.

---

## When to run

At the end of `.codepress/system/playbooks/release.md`, after the release note is created.

---

## Steps

1. Tag the release in git: `git tag {release-name}`
2. (Optional) Push tags to remote
3. (Optional) Trigger deployment or CI pipeline

---

## Configuration

Configure release automation settings in `.codepress/system/codepress.md` under a `[release]` section if needed.
