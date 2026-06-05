# Skill: Capture Pattern

Run the Galley-close learning step.

---

## When to use
When all Slugs in a Galley are done, before marking the Galley complete.
This step is mandatory. A Galley is not done until it runs.

---

## Steps

### 1. Review Signals

Read all Signals in `.codepress/product/galleys/{galley}/review.md`.
Scan Signals from recent related Galleys in `.codepress/knowledge/signals/`.

### 2. Identify Pattern candidates

A Signal becomes a Pattern when:
- It appears in 2+ Galleys independently, **or**
- It is immediately generalizable and saves significant future effort

Do not force it. A Signal that doesn't graduate is still valuable — it stays in `.codepress/knowledge/signals/`.

### 3. Write or update Patterns

For each Pattern candidate:
- Check `.codepress/knowledge/patterns/` for an existing Pattern that covers this
- If yes: add the new Signal as additional evidence, update as needed
- If no: create `.codepress/knowledge/patterns/{name}.md` using the template

### 4. Update Knowledge

For each update noted in `review.md`:
- New concept → `.codepress/knowledge/concepts.md`
- Architectural decision → `.codepress/knowledge/decisions/{date}-{name}.md`
- State change → `.codepress/knowledge/current-state.md`

### 5. Promote Signals

Copy new Signals from `review.md` to `.codepress/knowledge/signals/`.
File name: `{YYYY-MM-DD}_{galley-id}_{short-description}.md`

### 6. Close the Galley

- Update `review.md` to note Patterns promoted and Knowledge updates made
- Update Galley frontmatter: `status: done`
- Update `.codepress/views/galley-board.md` — move card to Done
- Commit: `galley:{name} done`

---

## Output
- Signals in `.codepress/knowledge/signals/`
- Patterns created or updated in `.codepress/knowledge/patterns/`
- Knowledge updated in `.codepress/knowledge/`
- Galley marked `done`
- Board updated
