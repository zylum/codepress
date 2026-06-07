# Skill: Capture Pattern

Run the Galley-close learning step. Called by `playbooks/learn.md`.

---

## When to use
When all Slugs in a Galley are in `review`, before marking the Galley `learned`.
This step is mandatory. A Galley is not done until learning is captured.

---

## Steps

### 1. Review Signals

Read all Signals in `product/galleys/{galley}/review.md`.
Scan Signals from recent related Galleys in `knowledge/signals/`.

### 2. Identify Pattern candidates

A Signal becomes a Pattern when:
- It appears in 2+ Galleys independently, **or**
- It is immediately generalizable and saves significant future effort

Do not force it. A Signal that doesn't graduate is still valuable — it stays in `knowledge/signals/`.

### 3. Write or update Patterns

For each Pattern candidate:
- Check `knowledge/patterns/` for an existing Pattern that covers this
- If yes: add the new Signal as additional evidence, update as needed
- If no: create `knowledge/patterns/{name}.md` using the template

### 4. Update Knowledge

For each update noted in `review.md`:
- New concept → `knowledge/concepts.md`
- Architectural decision → `knowledge/decisions/{date}-{name}.md`
- State change → `knowledge/current-state.md`

### 5. Promote Signals

Copy new Signals from `review.md` to `knowledge/signals/`.
File name: `{YYYY-MM-DD}_{galley-id}_{short-description}.md`

### 6. Close the Galley

- Update Galley frontmatter: `status: learned`
- Commit: `galley:{name} done`

---

## Output
- Signals in `knowledge/signals/`
- Patterns created or updated in `knowledge/patterns/`
- Knowledge updated in `knowledge/`
- Galley marked `learned`
