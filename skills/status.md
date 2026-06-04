# Skill: Status

Regenerate the delivery board from Galley frontmatter.

---

## When to use
- `03-delivery/board.md` is out of sync with actual Galley statuses
- After bulk status changes
- As part of a weekly review

---

## Steps

1. Scan all `02-product/*/galley.md` files
2. Read the `status` and `id` frontmatter fields from each
3. Read `title` from the first H1 heading in each file
4. Read `initiative` and `release` frontmatter if present
5. Group Galleys by status: `shaping` | `approved` | `delivering` | `review` | `done`
6. Regenerate `03-delivery/board.md` using the format below

---

## Output format

```markdown
---
kanban-plugin: board
---

## Shaping
- [ ] [[02-product/{id}/galley|{title}]]

## Approved
- [ ] [[02-product/{id}/galley|{title}]]

## Delivering
- [ ] [[02-product/{id}/galley|{title}]]

## Review
- [ ] [[02-product/{id}/galley|{title}]]

## Done
- [x] [[02-product/{id}/galley|{title}]]

%% kanban:settings
{"kanban-plugin":"board","list-collapse":[false,false,false,false,false]}
%%
```

---

## Notes

Do not edit `board.md` manually between regenerations — it will drift.
The source of truth for status is always the `galley.md` frontmatter.
This skill regenerates the board view; it does not change any Galley statuses.
