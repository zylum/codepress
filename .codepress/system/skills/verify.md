# Skill: Verify

Run verification gates before a Galley status transition.

The trust boundary is the compiler, not the model.

---

## When to use

Before advancing `delivering → review` or `review → done`.
Also run when any Slug completes to catch regressions early.

---

## Steps

1. Read `codepress.md` for globally defined gates:
   ```yaml
   verify:
     test: pytest
     typecheck: tsc --noEmit
   ```
2. Read the Galley frontmatter for which gates apply: `verify: [test]`
3. If neither defines gates, no automatic verification — stop here.
4. Run each gate.

**All pass:** proceed with the status transition.

**Any fail:**
- Stop the transition immediately
- Add a Signal to `review.md` describing the failure
- Report to human. Do not proceed until resolved or explicitly waived.

**Waiving a gate** — add to Galley frontmatter:
```yaml
verify-waived: [lint]
```
Waived gates are still run; failure is recorded but does not block.

---

## The rule

> Do not ship code that has not been verified.
> "I think it works" is not the same as "It passes `pytest`."
