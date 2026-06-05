# Playbook: Review

The Galley-close review — capture learning before marking done.

---

## When to run
When all Slugs in a Galley are complete, before final close.

---

## Steps

### 1. Gather Signals

Read through all Slugs. Collect observations:
- What surprised you?
- What was harder or easier than expected?
- What would you do differently next time?

Record in `.codepress/product/galleys/{id}/review.md`.

### 2. Identify Pattern candidates

Review new Signals against existing Patterns in `.codepress/knowledge/patterns/`.
A Signal becomes a Pattern when it appears in 2+ Galleys or is immediately generalizable.

### 3. Update Knowledge

Update `.codepress/knowledge/` to reflect any new concepts, decisions, or state changes introduced by this Galley.

### 4. Close

- Update Galley frontmatter: `status: done`
- Update `.codepress/views/galley-board.md`
- Commit: `galley:{name} done`

---

## The rule

> A Galley is not done until learning has been captured.
> Shipping without review is debt.
