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

Before advancing `building → verifying` or `verifying → done`.
Also run when any Slug completes to catch regressions early.

---

## Steps

1. **Run the mechanical check first:**
   ```
   codepress check <galley>
   ```
   This runs the galley's `verify:` gates fresh (from `codepress.md`) and
   evaluates every bound acceptance criterion — `test:` refs via the
   `test-runner:` template, `check:` commands, ticked `manual:` rejection.
   Do not proceed to judgment without its per-AC output in hand.
2. Check `holdout: true` in the Galley frontmatter — if set, ask the reviewer for
   additional criteria before starting.
3. **Judgment checklist** — per slug, what the machine cannot see (derived from
   the operating rules):
   - **Mock audit:** does any test named in an AC mock the very unit it claims to
     verify? (dod.md test-quality rule — mock-theatre goes green while broken)
   - **Wiring grep:** does every new function, tool, or route have a real caller?
     Grep and confirm — dead code presented as done is a fail.
   - **Convention check:** were conventions and config edited at the source
     (templates, codepress.md), not shadow-copied or bypassed?
   - **Manual steps:** is any `manual:` AC ticked? It must be unticked — a human
     attests it here, in the Verdict.
4. **Write the `## Verdict` block** in the galley's `review.md`:
   ```
   AC1: pass — <one-line evidence>
   AC2: fail — <what broke>
   verified-by: <your engine name — must differ from engines.build>
   verified-on: <YYYY-MM-DD>
   ```
   One line per acceptance criterion. Evidence is what you observed, not what
   the builder reported. The `done` gate refuses an incomplete verdict, any
   `fail`, or `verified-by` equal to `engines.build`.

**All pass:** proceed with the status transition (`codepress galley move <galley> done`).

**Any fail:**
- Stop the transition immediately
- Record the fail line(s) in the Verdict block
- Add a failure Signal to `review.md` using the structured format:
  ```yaml
  type: failure
  what-failed: "<gate or criterion>"
  why: "<root cause>"
  rule-changed: "<generalizable lesson>"
  ```
- Report to human. Do not proceed until resolved or explicitly waived
  (`--force` records a waiver line in review.md).

**Waiving a gate** — add to Galley frontmatter:
```yaml
verify-waived: [lint]
```
Waived gates are still run; failure is recorded but does not block.

---

## The rule

> Do not ship code that has not been verified.
> "I think it works" is not the same as "It passes `pytest`."
