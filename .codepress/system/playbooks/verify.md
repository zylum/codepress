# Playbook: Verify

Verification gates that must pass before a Galley status transitions. The trust boundary is the compiler, not the model.

---

## When to run

Before advancing a Galley from `building → review` or `review → released`. Also run when any Slug is marked complete to catch regressions early.

---

## Steps

### 1. Read the verify gates

Check `codepress.md` for globally defined gates:

```yaml
verify:
  typecheck: tsc --noEmit
  test: pytest
  lint: ruff check
```

Check the Galley frontmatter for which gates apply:

```yaml
verify: [typecheck, test]
```

If neither defines gates, stop here — no automatic verification configured.

### 2. Run each gate

For each gate in the Galley's `verify:` list, look up the command from `codepress.md` and execute it.

```bash
# Example: typecheck gate
tsc --noEmit
```

```bash
# Example: test gate
pytest
```

### 3. Handle results

All pass:
- No further action. Proceed with status transition.

Any fail:
- Stop the transition immediately.
- Open `review.md` and add a Signal describing the failure.
- If a Pattern exists for this class of failure, link it. If not, consider creating one.
- Report to the human. Do not proceed until the failure is resolved or explicitly waived.

### 4. Waive a gate (explicit override)

A human may waive a specific gate for a Galley by adding to the frontmatter:

```yaml
verify: [typecheck, test]
verify-waived: [lint]
```

Waived gates are informational only — still run, but failure does not block the transition. The result is recorded in `review.md`.

---

## The rule

> Do not ship code that has not been verified.
> If you don't know whether it passes, it doesn't.

---

## How verification shifts trust

| Before | After |
|---|---|
| Trust the model's claim | Trust the compiler's output |
| "I think it works" | "It passes `tsc --noEmit`" |
| Fix bugs in production | Fix bugs before transition |
| Signals are optional | Failures become Signals automatically |
