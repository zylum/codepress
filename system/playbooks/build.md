# Playbook: Build

Build executes a Galley through its Slugs.

---

## When to run
When a Galley is `approved` and Slugs are defined.

---

## Steps

### 1. Read before building

- `galley.md` — Problem, Approach, Acceptance Criteria, Constraints
- `run-sheet.md` — execution order and stopping conditions
- `knowledge/concepts.md` — domain context
- Relevant `knowledge/patterns/`

Never start implementation without reading the Galley and Knowledge.

### 2. Execute Slugs

Follow the run-sheet order. For each Slug:

1. Read the Slug purpose and acceptance checklist
2. Check autonomy level: `continuous` / `confirm` / `stop`
3. Read context and dependencies
4. Implement
5. Verify against acceptance checklist
6. Record evidence in the Slug file
7. Commit: `slug:<name> done — <summary>`
8. Capture any Signals in `review.md` immediately — do not wait

### 3. Parallel execution

If the run-sheet identifies parallel Slugs:

- Use separate worktrees per domain
- One agent per domain area
- Merge after all parallel Slugs complete
- Resolve conflicts in a dedicated integration Slug

### 4. Galley-close step (mandatory)

Before marking the Galley done, run `system/skills/capture-pattern.md`:

1. Complete `review.md`:
   - List all Signals captured
   - Identify which warrant a Pattern
   - List Knowledge updates needed
2. Promote Signals to `knowledge/signals/`
3. Create or update Pattern files in `knowledge/patterns/`
4. Update `knowledge/` as needed
5. Update Galley frontmatter: `status: done`
6. Update `views/galley-board.md` — move card to Done
7. Commit: `galley:{name} done`

---

## Output
All Slugs complete with evidence. `review.md` filled. Knowledge updated. Board updated.

---

## The rule

> A Galley is not done until `review.md` is complete.
> Shipping without capturing learning is not done. It is debt.
