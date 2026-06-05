# Skill: Create Galley

Shape an Initiative into a Galley ready for delivery.

---

## Input
An Initiative file from `product/initiatives/` or a problem statement.

---

## Steps

1. Read `system/codepress.md` — project context and release theme
2. Read `knowledge/concepts.md` and `knowledge/current-state.md`
3. Read relevant `knowledge/patterns/` for this area
4. Read the Initiative file (or capture the problem statement)
5. Draft the Galley using `system/templates/galley.md`
6. Work through each section deliberately:
   - **Problem** — specific and observable
   - **Users** — concrete and named if possible
   - **Success** — measurable or clearly verifiable
   - **Constraints** — explicit boundaries and out-of-scope
   - **Approach** — direction + key decisions (not a full spec)
   - **Acceptance Criteria** — verifiable from the outside
7. Check against Knowledge — does this conflict with any existing decision or assume something that doesn't exist?
8. Create the folder: `product/galleys/{galley-id}/`
9. Save the Galley as `product/galleys/{galley-id}/galley.md`
10. Set frontmatter: `status: shaping`
11. Add the Galley to `views/galley-board.md` under Shaping

---

## Output
`product/galleys/{galley-id}/galley.md` with status `shaping`

---

## Handoff
Human reviews and approves → status moves to `approved`
Then run `system/skills/split-galley.md`
