# Skill: Review

Galley-close — capture learning before marking done.

```
Signals → Patterns → Knowledge
```

Every Galley must leave the system smarter. Shipping without review is debt.

---

## When to use
When all Slugs in a Galley are complete and verification gates pass.

---

## Steps

### 1. Gather Signals

Read every Slug file in `product/galleys/{id}/slugs/` and collect all bullets from each `## Signals` block.

Then scan the git log for rework since the galley started:
```
git log --oneline --since="{galley-created-date}" | grep "^rework:"
```
Add any rework entries as additional signals.

Write everything into `product/galleys/{id}/review.md` under **Signals** and **Surprises** — no recall from memory, the Slug files are the source of truth.

### 1b. Aggregate cost

Read every Slug file in `product/galleys/{id}/slugs/` for `type: cost` YAML blocks. Sum `tokens-in`, `tokens-out`, and `cost-estimate` across all slugs.

Read the Galley frontmatter `budget.tokens` and `budget.cost`. Compute variance:

```
tokens: {actual} / {budget} ({variance}%)
cost:   {actual} / {budget} ({variance}%)
```

If actual > budget, flag the overrun in `review.md` under a **Cost** section:

```markdown
## Cost
| Metric | Budget | Actual | Variance |
|---|---|---|---|
| Tokens | {budget} | {actual} | {variance}% |
| Cost | {budget} | {actual} | {variance}% |
| Most expensive slug | {slug-id} | {cost} | |

### Per-slug breakdown
| Slug | Model | Tokens-in | Tokens-out | Cost |
|---|---|---|---|---|
```

If no cost signals exist, write: "No cost signals captured — FinOps not active for this galley." and proceed.

Propose cost Patterns when a slug-type consistently costs more or less than others (e.g. "documentation slugs average 1/5 the tokens of backend slugs").

### 2. Draft Pattern candidates — human approves

A Signal is a Pattern candidate when:
- It appears in 2+ Galleys independently, **or**
- It is immediately generalizable and saves significant future effort

Check `knowledge/patterns/` — update an existing Pattern rather than duplicate.

Write your draft candidates into `review.md` under **Pattern candidates**. Mark each:
- `[ ] proposed` — needs human approval before graduating to `knowledge/patterns/`

Do not force it. A Signal that doesn't graduate stays in `knowledge/signals/` and is still valuable.

### 3. Write or update Patterns

For each Pattern candidate the human approves, create `knowledge/patterns/{name}.md` or update an existing one.

A good Pattern answers: What problem? What approach? When to use? When not?

### 4. Promote Signals

Copy raw Signals from `review.md` to `knowledge/signals/`.
File naming: `{YYYY-MM-DD}_{galley-id}_{short-description}.md`

### 5. Update Knowledge

| What happened | Where |
|---|---|
| New concept | `knowledge/concepts.md` |
| New term | `knowledge/glossary.md` |
| Architectural decision | `knowledge/decisions/{date}-{name}.md` |
| Capabilities changed | `knowledge/current-state.md` |

A 5-line stub beats an empty file. Update incrementally.

Record each change in `review.md` under **Knowledge updates**.

### 6. Entropy check

Before closing, answer these four questions in `review.md` under **Entropy**:

1. **Did we improve the system, or just deliver a feature?**
   What does the system know now that it didn't before?

2. **What rule did this Galley discover?**
   If you can't name one, you overfitted to the visible spec.

3. **Did we plateau?**
   Same problems, same approaches, no surprises — that is a plateau. Name it if true.

4. **What would make the next galley 20% cheaper?**
   Reference the cost-per-slug data from the Cost section. Which slug type was most expensive? What knowledge, if seeded, would reduce that cost? Missing knowledge, unclear AC, wrong autonomy level — be specific.

If the Galley had `holdout: true`, review the holdout criteria now with the reviewer. Did the builder satisfy the underlying intent, or only the visible spec?

### 7. Close

- Update Galley `status: done`
- Update `.codepress/views/galley-board.md`
- Commit: `galley:{name} done`

---

## review.md structure

```markdown
## Signals
- [raw observations aggregated from Slug Signals blocks]

## Surprises
- [what didn't match expectations]

## Pattern candidates
- [ ] proposed: [signals seen in 2+ galleys or immediately generalizable — agent drafts, human approves]

## Knowledge updates
- [what changed in current-state / concepts / decisions]

## Entropy
- Did we improve the system or just deliver a feature?
- Rule discovered:
- Plateau detected: yes / no
- What would make the next galley 20% cheaper:
- Holdout verdict (if holdout: true): did builder satisfy underlying intent?
```
