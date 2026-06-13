---
id: docs-site
status: done
galley: docs-refresh
autonomy: continuous
---

# Slug: Docs Site Update

## Purpose
Update the Jekyll docs pages to reflect Phase 1 changes.

## Acceptance checklist
- [ ] `docs/quick-reference.md`: add `codepress status` and `codepress run [--all]` commands
- [ ] `docs/structure.md`: `system/` shows `skills/` only — no `playbooks/` entry
- [ ] `docs/overview.md`: reading order updated to 4 hops; compound loop description current
- [ ] `docs/core-concepts.md`: Slug template section mentions the Signals block
- [ ] `docs/faq.md`: any references to "playbooks" updated to "skills"
- [ ] All internal links still resolve (no 404s from renamed sections)

## Dependencies
None (can run in parallel with README).

## Evidence

- `docs/quick-reference.md`: structure tree updated (no playbooks/), CLI section now has `run`, `run --all`, `upgrade`, `galley move`; core workflow uses new skill names.
- `docs/structure.md`: system/ table row replaced (no playbooks/ row), directory tree rewritten with 8 named skills; config.md renamed to codepress.md.
- `docs/overview.md`: new "Reading order (4 hops)" section added with all 4 hops described.
- `docs/core-concepts.md`: Slug section extended with Signals block explanation.
- `docs/faq.md`: "All playbooks and skills" → "All skills".
- `docs/modes-of-use.md`: feature table and Level 1 description updated; create-galley → shape.md.
- `docs/quick-start.md`: structure tree updated (no playbooks/), step 6 uses `shape` skill.
- `docs/hermes.md`: design principle 3 and status detection rules updated to new skill names.

---

## Signals

- `hermes.md` held the most stale references — it had old skill names in both prose and a table, making it a useful test case for the verify step.
- `modes-of-use.md` had a feature table row "Playbooks, skills, templates" that needed surgical fixing — good example of how stale text hides in tables.
- Updating docs/ in one pass revealed that `quick-start.md` and `hermes.md` were not in the original slug checklist but both contained stale references — the verify grep caught them correctly.
