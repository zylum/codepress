# Skill: Shape

Transform an Initiative into a Galley ready for delivery.

---

## When to use
When an Initiative has been reviewed and is worth building.

---

## Steps

1. Read `.codepress/system/codepress.md` — project context and release theme
2. Read `.codepress/knowledge/current-state.md` — what exists today
3. Read relevant `.codepress/knowledge/patterns/` for this area
4. Read the Initiative file (or capture the problem statement)
5. Draft the Galley using `.codepress/system/templates/galley.md`, answering each section:
   - **Problem** — specific and observable. What breaks or what is missing?
   - **Users** — concrete. Who? Doing what?
   - **Success** — how do we measure or verify? What is the minimum acceptable?
   - **Constraints** — what is explicitly out of scope? (time, technical, scope)
   - **Approach** — direction and key decisions, not a spec. Enough for someone else to build without asking questions.
   - **Acceptance Criteria** — what does done look like from the outside?
6. Check against Knowledge:
   - Does the approach conflict with any decision in `knowledge/decisions/`?
   - Does it assume capabilities that do not exist yet?
   - Are new domain concepts introduced that should be added to `knowledge/concepts.md`?
7. Create folder: `.codepress/product/galleys/{galley-id}/`
8. Save as `.codepress/product/galleys/{galley-id}/galley.md` with `status: shaping`
9. Add to `.codepress/views/galley-board.md` under Shaping

---

## Output
`galley.md` with `status: shaping`

Human reviews and approves → status moves to `approved`
Then run `skills/split.md`

---

## Common mistakes
- Approach too detailed (becomes a spec, not a shape)
- Skipping Knowledge check (leads to conflicts mid-delivery)
- Acceptance Criteria that cannot be verified from the outside
- Shaping without knowing what already exists
