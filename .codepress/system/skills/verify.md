# Skill: Verify

Run verification gates before a Galley status transition.

The trust boundary is the compiler, not the model.

---

## The verifier principle

**The verifier must not be the builder.**

An agent that built the code has motivated reasoning — it will interpret ambiguous tests charitably and find workarounds that "technically pass." Verification is only trustworthy when run in a fresh context that has not seen the build process.

If you are the agent that built this Galley: hand off to the `verifier` engine defined in `codepress.md`. Do not self-verify.

If you are the verifier: read only the Galley spec, acceptance criteria, and the artefacts. Do not read build history, builder commentary, or slug files. Evaluate against what was promised, not what was attempted.

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
3. Check `holdout: true` — if set, ask the reviewer for additional criteria before starting.
4. If no gates defined, no automatic verification — stop here.
5. Run each gate.

**All pass:** proceed with the status transition.

**Any fail:**
- Stop the transition immediately
- Add a failure Signal to `review.md` using the structured format:
  ```yaml
  type: failure
  what-failed: "<gate or criterion>"
  why: "<root cause>"
  rule-changed: "<generalizable lesson>"
  ```
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
