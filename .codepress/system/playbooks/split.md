# Playbook: Split

Decompose an approved Galley into atomic Slugs.

---

## When to run
When a Galley is `approved` and ready for execution planning.

---

## Steps

### 1. Read the Galley

Understand the full shape: Problem, Approach, Acceptance Criteria, Constraints.

### 2. Identify atomic units

- Each Slug should be independently deliverable
- Each Slug should have verifiable acceptance criteria
- Make dependencies between Slugs explicit — never hidden

### 3. Identify parallel opportunities

- Which Slugs touch different domain areas and can run concurrently?
- Which must be sequential (data dependency, interface dependency)?

### 4. Create run-sheet and Slugs

Create `run-sheet.md` and individual Slug files in `.codepress/product/galleys/{id}/slugs/`.

For each Slug, set:
- Purpose (one sentence)
- Acceptance checklist (3–7 items)
- Autonomy level (`continuous` / `confirm` / `stop`)
- Dependencies (if any)

### 5. Prepare review.md

Create a blank `review.md` ready for signal capture during delivery.

### 6. Update status

- Update Galley frontmatter: `status: delivering`
- Update `.codepress/views/galley-board.md` — move card to Delivering

---

## Slug sizing guide

A well-sized Slug:
- Can be implemented in one focused session
- Has 3–7 acceptance checklist items
- Touches one primary domain area
- Produces a single coherent commit

If a Slug feels too large, split it. If it feels too small, consider merging with adjacent work.
