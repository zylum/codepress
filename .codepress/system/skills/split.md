# Skill: Split

Decompose an approved Galley into atomic Slugs.

---

## When to use
When a Galley is `approved` and ready for execution planning.

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
5. Create `run-sheet.md` with ordered Slug list. Mark parallel groups explicitly:
   ```yaml
   parallel-groups:
     - id: A
       slugs: [slug-1, slug-3]
       note: "independent — no shared files"
     - id: B
       slugs: [slug-2]
       depends-on: [A]
   ```
6. Create each Slug at `slugs/{id}-{name}.md` using `.codepress/system/templates/slug.md`
7. For each Slug set:
   - Purpose (one sentence)
   - Acceptance checklist (3–7 items)
   - Autonomy level (`continuous` / `confirm` / `stop`)
   - Dependencies (if any)
8. Create `review.md` (blank, ready for signal capture during delivery)
9. Update Galley `status: delivering`
10. Update `.codepress/views/galley-board.md`

---

## Slug sizing guide

A well-sized Slug:
- Can be implemented in one focused session
- Has 3–7 acceptance checklist items
- Touches one primary domain area
- Produces a single coherent commit

If a Slug feels too large, split it. If too small, merge with adjacent work.

---

## Output
- `run-sheet.md` with Slug order and parallel groups
- `slugs/{id}-{name}.md` for each Slug
- `review.md` ready (blank)
- Galley `status: delivering`
