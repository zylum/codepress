# Skill: Capture Pattern

Run the Galley-close learning step.

---

## When to use
When all Slugs in a Galley are done, before marking the Galley complete.
This step is mandatory. A Galley is not done until it runs.

---

## Steps

### 1. Review Signals

Read all Signals in `02-product/{galley}/review.md`.
Scan Signals from recent related Galleys in `04-patterns/signals/`.

### 2. Identify Pattern candidates

A Signal becomes a Pattern when:
- It appears in 2+ Galleys independently, **or**
- It is immediately generalizable and saves significant future effort

Do not force it. A Signal that doesn't graduate is still valuable — it stays in `04-patterns/signals/`.

### 3. Write or update Patterns

For each Pattern candidate:
- Check `04-patterns/patterns/` for an existing Pattern that covers this
- If yes: add the new Signal as additional evidence, update as needed
- If no: create `04-patterns/patterns/{name}.md` using the template

### 4. Update Domain Memory

For each Domain update noted in `review.md`:
- New concept → `05-domain/concepts.md`
- Architectural decision → `05-domain/decisions/{date}-{name}.md`
- State change → `05-domain/current-state.md`

### 5. Promote Signals

Copy new Signals from `review.md` to `04-patterns/signals/`.
File name: `{YYYY-MM-DD}_{galley-id}_{short-description}.md`

### 6. Close the Galley

- Update `review.md` to note Patterns promoted and Domain updates made
- Update Galley frontmatter: `status: done`
- Update `03-delivery/board.md` — move card to Done
- Commit: `galley:{name} done`

---

## Output
- Signals in `04-patterns/signals/`
- Patterns created or updated in `04-patterns/patterns/`
- Domain Memory updated in `05-domain/`
- Galley marked `done`
- Board updated
