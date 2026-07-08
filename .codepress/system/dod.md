# Definition of Done

Global standards that apply to every Galley unless explicitly overridden.

---

## Galley Done means

1. **Acceptance criteria met** — Every criterion in the Galley has corresponding evidence that exercises the real path (no mock-theatre)
2. **Verification passes** — All defined verification gates pass (lint, typecheck, test)
3. **Review completed** — Independent review approved the work
4. **Knowledge updated** — Signals captured, Patterns promoted where warranted
5. **Wired end-to-end** — Every new function, tool, or route has a caller; grepped and confirmed
6. **Set status to `review`, not `done`** — The builder sets `status: review`; an independent reviewer promotes to `done` or flips to `rework`
7. **Ready for merge** — Code is ready to ship

---

## Slug Done means

1. **Purpose delivered** — The Slug's stated purpose is achieved
2. **Acceptance checklist complete** — Every item has evidence
3. **Verification passes** — Relevant gates pass
4. **Signals captured** — Observations recorded before commit
5. **No regressions** — Existing functionality unchanged

---

## Evidence requirements

Every acceptance criterion needs:
- **What** was verified (the criterion)
- **How** it was verified (test, command, observation)
- **Proof** it passed (test output, command output, screenshot)

### Test quality

Tests must exercise the real path — never mock the unit under test. A galley's regression test must drive actual code end-to-end (fetch → parse → store → retrieve), not assert that a mock's return value was passed through. Mocking the boundary under test produces theatre: the gate goes green while the feature is broken.

Example:
```markdown
## Acceptance checklist
- [x] API returns 404 for non-existent user
  Evidence: test_user_not_found() — pytest output shows PASS
- [x] Rate limiting applied after 10 requests
  Evidence: test_rate_limit() — output shows 429 after 11th request
```

---

## Verification inheritance

Galleys inherit verification requirements from:

1. **Galley-specific** — `verify:` in galley.md frontmatter
2. **Project defaults** — `verify:` in codepress.md
3. **Capability requirements** — Lint must exist, typecheck if applicable, tests if applicable

If a Galley defines `verify: [test]`, only test runs. If it defines nothing, project defaults apply. If project defaults are empty, capability requirements apply.

---

## Overrides

A Galley can override the global DoD by adding to its frontmatter:

```yaml
dod-overrides:
  evidence: optional  # Don't require evidence for this Galley
  review: self-review  # Allow self-review (not recommended)
```

Overrides must be explicit and justified. The default is strict adherence.

---

## What "done" does NOT mean

- "It compiles"
- "I think it works"
- "It passed on my machine"
- "Looks good"
- "No obvious problems"

Done means evidence exists that the work meets the definition.
