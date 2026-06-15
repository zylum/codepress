# Skill: Build

Execute a Galley through its Slugs.

---

## When to use
When a Galley is `delivering` and Slugs are defined.

---

## Before starting

Read:
- `galley.md` — Problem, Approach, AC, Constraints
- `run-sheet.md` — execution order and parallel groups
- Relevant `knowledge/patterns/`

Never start implementation without reading the Galley and Knowledge first.

---

## Per Slug

1. Read the Slug purpose and acceptance checklist
2. Check autonomy level: `continuous` / `confirm` / `stop`
3. Read context and dependencies
4. Read the Galley `budget:` — know the token and cost ceiling before starting
5. Implement
6. Verify against acceptance checklist
7. Record evidence in the Slug `Evidence` section
8. **Capture cost** — record token usage and estimated cost as a `type: cost` signal (see `skills/signal.md`). Add the YAML block to the slug's `## Signals` section. If exact counts are unknown, estimate and set `source: estimated`.
9. **Fill the Signals block before committing** — 2–3 bullets: what surprised you, what you'd change, any pattern emerging
10. Commit: `slug:<name> done — <summary>`

---

## Parallel execution

If the run-sheet defines parallel groups:

- Create a git worktree per group: `git worktree add ../{project}-{slug} -b slug/{name}`
- One agent per group, working independently
- Merge after all Slugs in the group complete
- Resolve conflicts in a dedicated integration Slug if needed

---

## Verification (mandatory before galley-close)

Run `skills/verify.md`. All gates defined in `codepress.md` must pass.

If any gate fails: capture a Signal, resolve, re-verify. Do not proceed until gates pass or a human explicitly waives them.

---

## Galley-close (mandatory)

When all Slugs are done and verification passes, run `skills/review.md`.

---

## The rule

> A Galley is not done until `review.md` is complete.
> Shipping without capturing learning is not done. It is debt.
