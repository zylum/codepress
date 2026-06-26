# Skill: Bootstrap Project

Set up a new project with CodePress. This skill creates the foundation that all future Galleys inherit.

Run this once when starting a new project, or when adding CodePress to an existing project.

---

## Phase 1: Detect project type

Scan the repository to identify:
- Language and framework
- Existing tooling (linters, type checkers, test frameworks)
- Package manager and dependencies
- Existing CI configuration

**Detection signals:**
| Signal | Project type |
|---|---|
| `pyproject.toml`, `setup.py`, `requirements.txt` | Python |
| `package.json`, `tsconfig.json` | TypeScript/JavaScript |
| `Cargo.toml` | Rust |
| `go.mod` | Go |
| `Gemfile` | Ruby |
| `pom.xml`, `build.gradle` | Java |
| `*.csproj` | .NET |

**Tooling detection:**
| File | Tool |
|---|---|
| `.flake8`, `ruff.toml`, `pyproject.toml [tool.ruff]` | Python linter |
| `mypy.ini`, `pyproject.toml [tool.mypy]` | Python type checker |
| `pytest.ini`, `pyproject.toml [tool.pytest]` | Python test framework |
| `.eslintrc*`, `eslint.config.*` | JavaScript/TypeScript linter |
| `tsconfig.json` | TypeScript type checker |
| `vitest.config.*`, `jest.config.*` | JavaScript/TypeScript test framework |

Output: `Detected: {language} project with {tooling}`

---

## Phase 2: Configure verification

Based on detected project type, configure verification commands.

**Default mappings:**
| Language | lint | typecheck | test |
|---|---|---|---|
| Python | `ruff check` | `mypy` | `pytest` |
| TypeScript | `eslint .` | `tsc --noEmit` | `vitest` |
| Rust | `cargo clippy` | `cargo check` | `cargo test` |
| Go | `golangci-lint run` | `go vet` | `go test ./...` |

**Ask user:**
> "I detected {language} project. Recommended verification:
> - lint: {command}
> - typecheck: {command}
> - test: {command}
>
> Use these commands, or specify alternatives?"

Write to `.codepress/system/codepress.md` under `verify:` section.

---

## Phase 3: Define Definition of Done

Present the global Definition of Done from `.codepress/system/dod.md`.

**Ask user:**
> "Every Galley must meet these standards:
> 1. Acceptance criteria met with evidence
> 2. Verification passes (lint, typecheck, test)
> 3. Review completed
> 4. Knowledge updated
> 5. Ready for merge
>
> Accept these defaults, or customize?"

If customize, update `.codepress/system/dod.md` with project-specific additions.

---

## Phase 4: Configure working style

**Ask user:**
> "How do you want to work on this project?
>
> **fast** — move quickly, iterate, minimal checkpoints. Good for prototypes.
> **balanced** — human approves Galley shape before delivery starts.
> **careful** — frequent checkpoints, human reviews each stage.
>
> Which fits best?"

Populate `.codepress/system/codepress.md` with:
- `pace:` setting
- `default-autonomy:` based on pace
- Human approval gates

---

## Phase 5: Configure team and roles

**Ask user:**
> "Is this a solo project, or are others involved?
> If there's a team, what roles exist?"

Populate `.codepress/system/codepress.md` with:
- `team-size:`
- `Roles:` list

---

## Phase 6: Configure engines

**Ask user:**
> "Which AI agent should handle each workflow stage?
> Options: claude, opencode, gemini, or custom names.
>
> Default: all stages use claude."

Populate `.codepress/system/codepress.md` under `engines:` section.

---

## Phase 7: Create project skeleton

Create required directories:
```bash
mkdir -p .codepress/system/{skills,templates,hooks}
mkdir -p .codepress/product/{initiatives,galleys,releases}
mkdir -p .codepress/knowledge/{decisions,signals,patterns}
mkdir -p .codepress/views
mkdir -p docs
mkdir -p tests
```

Create optional directories based on project type:
- Python: `src/`, `tests/`
- TypeScript: `src/`, `tests/`
- Rust: `src/`, `tests/`
- Go: `cmd/`, `internal/`, `pkg/`

---

## Phase 8: Recommend branch protection

**Recommend (not mandatory):**
> "For professional projects, I recommend:
> - PR required for all changes
> - CI must pass before merge
> - At least one review required
> - No direct pushes to main
>
> Enable these on your Git host (GitHub, GitLab, etc.)"

Document recommendation in `.codepress/system/codepress.md` under PR policy.

---

## Phase 9: Run verification dry run

Execute the configured verification commands to verify they work:

```bash
# Run each configured command
{lint_command}
{typecheck_command}
{test_command}
```

**Report results:**
```
✓ lint: passes
✓ typecheck: passes
✓ test: passes (42 tests)

Verification dry run complete.
```

If any command fails, report the failure and suggest fixes before proceeding.

---

## Phase 10: Create project manifest

Create `.codepress/system/manifest.md`:

```markdown
# Project Manifest

## Identity
name: {project_name}
description: {description}
created: {date}
codepress-version: 0.4.1

## Technology
language: {language}
framework: {framework}
package-manager: {package_manager}

## Verification
lint: {command}
typecheck: {command}
test: {command}

## Working Style
pace: {pace}
default-autonomy: {autonomy}
team-size: {team_size}

## Engines
shaping: {engine}
build: {engine}
verifier: {engine}
review: {engine}
```

---

## Phase 11: Seed knowledge (optional)

If existing codebase, run `skills/bootstrap.md` to seed knowledge from code.

If new project, create stub knowledge files:
- `.codepress/knowledge/concepts.md` — empty, to be populated
- `.codepress/knowledge/glossary.md` — empty, to be populated
- `.codepress/knowledge/current-state.md` — "New project, no code yet."

---

## Phase 12: Final report

Summarize what was configured:

```
Bootstrap complete.

Project: {name}
Type: {language}
Verification: {commands}
Working style: {pace}
Team: {team_size}

Next steps:
1. Review .codepress/system/codepress.md
2. Adjust verification commands if needed
3. Start your first Galley with: codepress galley new {name}
```

---

## Output

- `.codepress/system/codepress.md` — project config
- `.codepress/system/dod.md` — Definition of Done (possibly customized)
- `.codepress/system/manifest.md` — project identity
- `.codepress/knowledge/` — seeded knowledge (if existing codebase)
- Verification commands tested and working

---

## Notes

- Phase 1-6 must complete before Phase 7-12
- This skill is distinct from `skills/bootstrap.md` which seeds knowledge from existing code
- The bootstrap creates a minimal foundation; Galleys add detail
- All configurations can be adjusted later in `.codepress/system/codepress.md`
