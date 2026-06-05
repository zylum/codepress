# Skill: Split Galley

Decompose an approved Galley into Slugs.

---

## Input
An approved `galley.md` — status must be `approved`.

---

## Steps

1. Read the full Galley (Problem, Approach, AC, Constraints)
2. Read `knowledge/concepts.md` for module boundaries
3. Identify atomic units of work:
   - Each Slug should be independently deliverable
   - Each Slug should have verifiable acceptance criteria
   - Make dependencies between Slugs explicit — never hidden
4. Identify parallel opportunities:
   - Which Slugs touch different domain areas and can run concurrently?
   - Which must be sequential (data dependency, interface dependency)?
5. Create `product/galleys/{galley-id}/run-sheet.md` with ordered Slug list
6. Create each Slug at `product/galleys/{galley-id}/slugs/{id}-{name}.md`
7. For each Slug, set:
   - Purpose (one sentence)
   - Acceptance checklist (3–7 items)
   - Autonomy level (`continuous` / `confirm` / `stop`)
   - Dependencies (if any)
8. Create `product/galleys/{galley-id}/review.md` from the template (blank, ready)
9. Update `views/galley-board.md` — move card from Shaping to Delivering
10. Update Galley frontmatter: `status: delivering`

---

## Slug sizing guide

A well-sized Slug:
- Can be implemented in one focused session
- Has 3–7 acceptance checklist items
- Touches one primary domain area
- Produces a single coherent commit

If a Slug feels too large, split it. If it feels too small, consider merging with adjacent work.

---

## Output
- `run-sheet.md` with ordered Slug list
- `slugs/{id}-{name}.md` for each Slug
- `review.md` ready (blank)
- Galley status updated to `delivering`
- Board updated
