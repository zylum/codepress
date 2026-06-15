# Skill: Status

Regenerate the delivery board from Galley frontmatter.

---

## When to use
- `.codepress/views/galley-board.md` is out of sync with actual Galley statuses
- After bulk status changes
- As part of a weekly review

---

## Steps

1. Scan all `.codepress/.codepress/product/galleys/*/galley.md` files
2. Read the `status` and `id` frontmatter fields from each
3. Read `title` from the first H1 heading in each file
4. Read `initiative` and `release` frontmatter if present
5. Group Galleys by status: `shaping` | `approved` | `delivering` | `review` | `done`
6. **Budget check** — for each delivering/review galley, read `budget.tokens` and `budget.cost` from frontmatter. Then scan its slug files for `type: cost` YAML blocks. Sum `tokens-in` and `cost-estimate` across all slugs. If actual > budget, flag as pending action:
   - `⚠️ Budget overrun: {actual} tokens used vs {budget} budgeted in {galley-id}`
   - `⚠️ Budget overrun: ${actual} spent vs ${budget} budgeted in {galley-id}`
   Skip if no budget is set or no cost signals exist.
7. Regenerate `.codepress/views/galley-board.md` using the format below

Include detected overruns at the top of the board as a `## Alerts` section, before the status columns.

---

## Output format

```markdown
---
kanban-plugin: board
---

## Shaping
- [ ] [[.codepress/product/galleys/{id}/galley|{title}]]

## Approved
- [ ] [[.codepress/product/galleys/{id}/galley|{title}]]

## Delivering
- [ ] [[.codepress/product/galleys/{id}/galley|{title}]]

## Review
- [ ] [[.codepress/product/galleys/{id}/galley|{title}]]

## Done
- [x] [[.codepress/product/galleys/{id}/galley|{title}]]

%% kanban:settings
{"kanban-plugin":"board","list-collapse":[false,false,false,false,false]}
%%
```

---

## Notes

Do not edit `.codepress/views/galley-board.md` manually between regenerations — it will drift.
The source of truth for status is always the `galley.md` frontmatter.
This skill regenerates the board view; it does not change any Galley statuses.
