# Skill: Status

Regenerate the delivery board from Galley frontmatter.

---

## When to use
- `views/galley-board.md` is out of sync with actual Galley statuses
- After bulk status changes
- As part of a weekly review

---

## Steps

1. Scan all `product/galleys/*/galley.md` files
2. Read the `status` and `id` frontmatter fields from each
3. Read `title` from the first H1 heading in each file
4. Read `initiative` and `release` frontmatter if present
5. Group Galleys by status: `shaping` | `approved` | `delivering` | `review` | `done`
6. Regenerate `views/galley-board.md` using the format below

---

## Output format

```markdown
---
kanban-plugin: board
---

## Shaping
- [ ] [[product/galleys/{id}/galley|{title}]]

## Approved
- [ ] [[product/galleys/{id}/galley|{title}]]

## Delivering
- [ ] [[product/galleys/{id}/galley|{title}]]

## Review
- [ ] [[product/galleys/{id}/galley|{title}]]

## Done
- [x] [[product/galleys/{id}/galley|{title}]]

%% kanban:settings
{"kanban-plugin":"board","list-collapse":[false,false,false,false,false]}
%%
```

---

## Notes

Do not edit `views/galley-board.md` manually between regenerations — it will drift.
The source of truth for status is always the `galley.md` frontmatter.
This skill regenerates the board view; it does not change any Galley statuses.
