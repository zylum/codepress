# Principles

Core rules that apply to every CodePress project. These are never configurable.

---

## 1. Builder cannot self-certify

The agent that implements work may not decide work is complete.

Completion requires independent verification. The verifier must not be the builder.

This is a trust boundary. An agent that built the code has motivated reasoning — it will interpret ambiguous tests charitably and find workarounds that "technically pass." Verification is only trustworthy when run in a fresh context that has not seen the build process.

---

## 2. Verification is mandatory

Every change must pass automated verification before merge.

No exceptions. No "looks good to me." No "it works on my machine."

If verification cannot run (no test framework, no type system), that must be explicitly acknowledged and documented — not ignored.

---

## 3. Evidence required

Every acceptance criterion needs evidence.

Not:
```
✓ login works
```

Instead:
```
User cannot login with invalid password
Evidence: test_invalid_password()
```

Claims without evidence are not acceptance criteria. They are hopes.

---

## 4. Definition of Done is global

Every Galley inherits the project-wide Definition of Done unless explicitly overridden.

The DoD is not a suggestion. It is the minimum bar for all work.

---

## 5. Changes merge only after verification and review

No code reaches main without:
1. Automated verification passing
2. Independent review completed
3. Acceptance criteria satisfied with evidence

This applies to all changes — features, fixes, refactors, documentation.

---

## 6. Tooling is interchangeable; quality expectations are not

Use Ruff or Flake8. Use MyPy or Pyright. Use Pytest or Unittest.

The tools don't matter. The capabilities do:
- Linting exists
- Type checking exists (if applicable)
- Tests exist
- Verification is automated

"The project shall provide automated linting" — not "Use Ruff."

---

## 7. Knowledge compounds

Every project captures what it learns.

Signals (raw observations) become Patterns (reusable lessons) become Knowledge (project understanding).

This loop never stops. It is not optional.
