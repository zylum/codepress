# Definition of Done

Global standards that apply to every Galley unless explicitly overridden.

---

## Galley Done means

1. **Acceptance criteria met** — Every criterion in the Galley has corresponding evidence
2. **Verification passes** — All defined verification gates pass (lint, typecheck, test)
3. **Review completed** — Independent review approved the work
4. **Knowledge updated** — Signals captured, Patterns promoted where warranted
5. **Ready for merge** — Code is ready to ship

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
