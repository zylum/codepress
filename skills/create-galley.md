# Skill: Create Galley

Shape an Initiative into a Galley ready for delivery.

---

## Input
An Initiative file from `01-initiatives/` or a problem statement.

---

## Steps

1. Read `codepress.md` — project context and release theme
2. Read `05-domain/index.md` and `05-domain/current-state.md`
3. Read relevant `04-patterns/patterns/` for this area
4. Read the Initiative file (or capture the problem statement)
5. Draft the Galley using `02-product/_templates/galley.md`
6. Work through each section deliberately:
   - **Problem** — specific and observable
   - **Users** — concrete and named if possible
   - **Success** — measurable or clearly verifiable
   - **Constraints** — explicit boundaries and out-of-scope
   - **Approach** — direction + key decisions (not a full spec)
   - **Acceptance Criteria** — verifiable from the outside
7. Check against Domain Memory — does this conflict with any existing decision or assume something that doesn't exist?
8. Create the folder: `02-product/{galley-id}/`
9. Save the Galley as `02-product/{galley-id}/galley.md`
10. Set frontmatter: `status: shaping`
11. Add the Galley to `03-delivery/board.md` under Shaping

---

## Output
`02-product/{galley-id}/galley.md` with status `shaping`

---

## Handoff
Human reviews and approves → status moves to `approved`
Then run `skills/split-galley.md`
