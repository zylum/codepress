# Capabilities

Every CodePress project must provide these capabilities. Implementation varies.

---

## 1. Automated Verification

**What:** Every change is checked by automated tools before merge.

**Required:**
- Linting (code quality checks)
- Type checking (if applicable)
- Testing (if applicable)

**Implementation varies:**
- Python: ruff, mypy, pytest (or flake8, pyright, unittest)
- TypeScript: eslint, tsc, vitest (or biome, ts-node, jest)
- Rust: clippy, cargo check, cargo test
- Go: golangci-lint, go vet, go test

**Configuration:**
Define in `codepress.md` under `verify:`:
```yaml
verify:
  lint: ruff check
  typecheck: mypy
  test: pytest
```

Or inherit from project defaults.

---

## 2. Evidence Capture

**What:** Proof that acceptance criteria are met.

**Required:**
- Each acceptance criterion has corresponding evidence
- Evidence is recorded in the Slug's Evidence section
- Evidence is machine-verifiable where possible

**Implementation varies:**
- Test output: `pytest -v` shows which tests pass
- Command output: `curl localhost:3000/health` returns 200
- Manual verification: screenshot, log output, observed behavior

**Example:**
```markdown
## Acceptance checklist
- [ ] User cannot login with invalid password
  Evidence: test_invalid_password() passes
- [ ] Rate limiting blocks brute force
  Evidence: test_rate_limit() passes
```

---

## 3. Independent Review

**What:** Someone other than the builder reviews the work.

**Required:**
- Reviewer is not the builder
- Reviewer checks acceptance criteria against evidence
- Reviewer can approve or request changes

**Implementation varies:**
- AI reviewer: configured in `codepress.md` under `engines.verifier`
- Human reviewer: team member reviews PR
- Hybrid: AI initial review, human sign-off

**Configuration:**
```yaml
engines:
  verifier: claude  # or opencode, gemini, human
```

---

## 4. Decision Documentation

**What:** Important decisions are recorded with context and rationale.

**Required:**
- Architecture decisions documented
- Rationale captured (why, not just what)
- Decisions are findable

**Implementation varies:**
- ADRs in `docs/adr/`
- Knowledge entries in `knowledge/decisions/`
- Galley constraints section
- Pattern promotion at review

**Location:**
- `knowledge/decisions/` — permanent decisions
- `knowledge/patterns/` — reusable lessons
- Galley `constraints` — decision scope

---

## 5. Branch Protection

**What:** Main branch is protected from direct changes.

**Required:**
- Changes go through review before merge
- Verification passes before merge
- History is preserved (no force pushes)

**Implementation varies:**
- GitHub: branch protection rules
- GitLab: merge request approvals
- Local: team convention + CI enforcement

**Recommendation:**
- PR required for all changes
- CI must pass
- At least one review required
- No direct pushes to main

---

## 6. Project Identity

**What:** The project has a clear manifest.

**Required:**
- Project name and description
- Technology stack documented
- Team and roles defined
- Working style configured

**Location:**
- `.codepress/system/codepress.md` — project config
- `.codepress/system/dod.md` — Definition of Done
- `.codepress/system/principles.md` — Core rules (read-only)
