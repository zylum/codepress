---
id: af-v1-s2
status: complete
galley: af-v1
autonomy: continuous
budget:
  tokens: 2000
  cost: 0.10
---

# Slug: budget-templates

## Purpose

Update `templates/galley.md` and `templates/slug.md` so the `budget:` fields are no longer blank stubs — they include doc comments, usage guidance, and realistic examples that make them natural to fill.

## Acceptance checklist

- [ ] `templates/galley.md` `budget:` fields have inline comments showing example values (e.g. `tokens: 25000  # expected total tokens for this galley`)
- [ ] `templates/slug.md` `budget:` fields have inline comments showing example values (e.g. `tokens: 5000  # expected tokens for this slug`)
- [ ] Both templates include a comment explaining that budgets feed the `cost-check` verify gate
- [ ] YAML structure preserved — fields remain optional at the YAML level but are no longer blank

## Context

The `budget:` field already exists in both templates:
- `galley.md` line 9-12
- `slug.md` line 6-9

Current state is blank YAML keys with no guidance. This slug turns them into documented fields that the build process and verify gates can meaningfully use.

## Dependencies

None. This modifies only template files.

## Evidence

- `templates/galley.md` budget fields updated with inline YAML comments: wall-clock (optional, planning), tokens (feeds cost-check), cost (feeds cost-check) — all with example values
- `templates/slug.md` budget fields updated with inline YAML comments: wall-clock (duration), tokens (feeds cost-check), cost (feeds cost-check) — all with example values
- Both templates include comments explaining that tokens and cost feed the cost-check verify gate
- YAML structure preserved — fields remain optional at the parser level but no longer blank stubs

---

## Signals

```yaml
---
type: cost
slug: af-v1-s2
tokens-in: 2000
tokens-out: 400
model: deepseek-v4-flash-free
cost-estimate: 0.00
source: self-reported
---
```

- 2026-06-15: Inline YAML comments work fine for human readers but are stripped by most YAML parsers — the cost-check gate reads the value, not the comment, so this is safe.
- 2026-06-15: The pattern of "optional field with example comment" is a good template convention — visible but not enforced.
