# Playbook: Shape

Shape transforms an Initiative into a Galley ready for delivery.

---

## When to run
When an Initiative has been reviewed and is worth building.

---

## Steps

### 1. Read before shaping

- `system/codepress.md` — project context and release theme
- `knowledge/concepts.md` and `knowledge/current-state.md`
- Relevant `knowledge/patterns/` for this area
- The Initiative file

### 2. Answer the six questions

Work through the Galley template (`system/templates/galley.md`):

- **Problem** — specific and observable. What breaks or what is missing?
- **Users** — concrete. Who? Doing what?
- **Success** — how do we measure or verify it? What is the minimum acceptable?
- **Constraints** — what is explicitly out of scope? (time, technical, scope)
- **Approach** — direction and key decisions, not a spec. Enough for someone else to build without asking questions.
- **Acceptance Criteria** — what does done look like from outside?

### 3. Check against Knowledge

Before finalising:

- Does the approach conflict with any decision in `knowledge/decisions/`?
- Does the Galley assume capabilities that do not exist yet?
- Are there new domain concepts being introduced that should be added to `knowledge/concepts.md`?

### 4. Review and approve

Human reviews the Galley. Status moves: `shaping` → `approved`.

### 5. Split

Run `system/skills/split-galley.md` to decompose into Slugs.

---

## Output
A complete `galley.md` in `product/galleys/{name}/` with status `approved`.

---

## Common mistakes

- Writing an Approach that is too detailed (becomes a spec, not a shape)
- Skipping Knowledge check (leads to conflicts mid-delivery)
- Acceptance Criteria that cannot be verified from the outside
- Shaping without knowing what already exists
