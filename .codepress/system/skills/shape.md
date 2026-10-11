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
   - **Acceptance Criteria** — what does done look like from the outside? Write every
     criterion in the one-line bound format (see "Writing acceptance criteria" below).
6. Check against Knowledge:
   - Does the approach conflict with any decision in `knowledge/decisions/`?
   - Does it assume capabilities that do not exist yet?
   - Are new domain concepts introduced that should be added to `knowledge/concepts.md`?
7. Create folder: `.codepress/product/galleys/{galley-id}/`
8. Save as `.codepress/product/galleys/{galley-id}/galley.md` with `status: proposed` (`codepress galley new <name>` scaffolds it)
9. Add to `.codepress/views/galley-board.md` under Shaping

---

## Writing acceptance criteria

Every AC is one line, fields separated by " · " (space-middot-space), bound to
evidence `codepress check` can evaluate:

- **Behaviours** → `- [ ] ACn · Given <ctx> · When <act> · Then <outcome> · test: <path>::<name>`
- **Mechanics** (file exists, suite green, config valid) → `- [ ] ACn · check: <shell command>` (exit 0 = pass)
- **Human/infra steps** (DNS, key rotation, approvals) → `- [ ] ACn · manual: <step>` — agents never tick these

Choosing the kind:
- Never GWT-ify a deletion — "Given the dead code exists · When removed…" is theatre;
  bind it mechanically: `check: ! grep -r old_symbol src/`.
- Never check-ify a behaviour — a behaviour gets a real named test, not a grep.
- Anything an agent cannot safely verify itself is `manual:` — the CLI fails the
  check if an agent ticks it.

---

## Output
`galley.md` with `status: proposed`. When Problem, Success, Approach and Acceptance Criteria are all written:
`codepress galley move <galley> shaped` (the `shape_complete` gate checks the sections exist).

Then run `skills/split.md`. A human approves the shape with `codepress galley approve <galley>` —
approval is a gate on `shaped → building`, not a status of its own.

---

## Common mistakes
- Approach too detailed (becomes a spec, not a shape)
- Skipping Knowledge check (leads to conflicts mid-delivery)
- Acceptance Criteria that cannot be verified from the outside
- Shaping without knowing what already exists
