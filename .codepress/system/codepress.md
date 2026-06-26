# CodePress Config

> Populated by `skills/bootstrap-project.md`. Edit freely after that.

---

## CodePress version
codepress-version: 0.4.1
codepress-source: https://github.com/zylum/codepress

---

## System files

| File | Purpose | Editable |
|---|---|---|
| `principles.md` | Core rules (never configurable) | No |
| `capabilities.md` | Required capabilities (implementation varies) | No |
| `dod.md` | Global Definition of Done | Project-specific |
| `codepress.md` | Project config (this file) | Yes |
| `AGENTS.md` | Agent operating manual | No |

---

## Project
name: CodePress
description: Compound product development operating system for the AI era
consumer-project:     # optional: path for external consumer sync (e.g. project ID)

---

## Working Style

### Pace
<!-- fast | balanced | careful -->
pace: balanced

| Value | Meaning |
|---|---|
| `fast` | Move quickly, iterate. Minimal checkpoints. Default autonomy: continuous. |
| `balanced` | Review at Galley boundaries. Human approves shape before delivery starts. |
| `careful` | Frequent checkpoints. Human reviews each Galley stage. Suits regulated or production-critical work. |

### Default Task autonomy
<!-- continuous | confirm | stop — overrides pace for individual Tasks -->
default-autonomy: continuous

### Human approval gates
<!-- Which transitions require explicit human sign-off? -->
- [ ] Galley: shaping → approved
- [ ] Galley: delivering → review
- [ ] Galley: review → done

### Testing expectations
<!-- What does "done" require? -->
- 

### PR policy
<!-- e.g. PR required before merge, auto-merge on green CI, etc. -->
- 

---

## Team
<!-- solo | small-team | team -->
team-size: solo

Roles:
<!-- List roles active on this project, e.g. Shaper, Builder, Reviewer -->
- 

---

## Conventions
<!-- Project-specific naming, commit, or workflow conventions -->
- 

---

## Engines

Which AI agent handles each workflow stage. Model-agnostic — set to `claude`, `opencode`, `codex`, `gemini`, or any agent name your workflow supports.

```yaml
engines:
  shaping: claude
  split: claude
  build: opencode
  verifier: claude      # spawns a fresh session — no build context, spec + artefacts only
  review: claude
  release: claude
  capture: claude
  compound: claude
```

If this section is missing, all stages default to `claude`.

---

## Verify

Verification gates that a Galley must pass before its status advances. Each gate maps to a shell command. Set gates globally here and/or per-Galley in galley.md.

```yaml
verify:
  typecheck: tsc --noEmit
  test: pytest
  lint: ruff check
  build: cargo check
  cost-check: >
    budget_tokens=$(grep -A3 '^budget:' .codepress/product/galleys/*/galley.md 2>/dev/null | grep 'tokens:' | head -1 | awk '{print $2}');
    budget_cost=$(grep -A3 '^budget:' .codepress/product/galleys/*/galley.md 2>/dev/null | grep 'cost:' | head -1 | awk '{print $2}');
    if [ -z "$budget_tokens$budget_cost" ]; then exit 0; fi;
    actual_tokens=0; actual_cost=0;
    for slug in .codepress/product/galleys/*/slugs/*.md; do
      if grep -q 'type: cost' "$slug" 2>/dev/null; then
        t=$(sed -n '/type: cost/,/^---/p' "$slug" | grep 'tokens-in:' | awk '{print $2}');
        c=$(sed -n '/type: cost/,/^---/p' "$slug" | grep 'cost-estimate:' | awk '{print $2}');
        [ -n "$t" ] && actual_tokens=$((actual_tokens + t));
        actual_cost=$(echo "$actual_cost + ${c:-0}" | bc 2>/dev/null || echo "$actual_cost");
      fi;
    done;
    [ -n "$budget_tokens" ] && [ "$actual_tokens" -gt "$budget_tokens" ] && echo "FAIL: tokens $actual_tokens > $budget_tokens" && exit 1;
    [ -n "$budget_cost" ] && [ "$(echo "$actual_cost > $budget_cost" | bc 2>/dev/null || echo 0)" -eq 1 ] && echo "FAIL: cost $actual_cost > $budget_cost" && exit 1;
    exit 0;
```

A Galley declares which gates apply:

```yaml
verify: [typecheck, test]
```

The engine will block transitions — `building → review`, `review → released` — unless all listed gates pass.

**Verification inheritance:**
1. Galley-specific: `verify:` in galley.md frontmatter
2. Project defaults: `verify:` in this file (codepress.md)
3. Capability requirements: Lint must exist, typecheck if applicable, tests if applicable

Missing: no gates defined. System falls back to capability requirements (lint mandatory, typecheck/test if applicable).

---

## Example (delete when filled in)

```
## Project
name: MyProject
description: A sample project demonstrating CodePress configuration.
consumer-project: team/my-project

## Release Theme
Each release is named after an iconic 80s movie.
Pool: Back to the Future, Ghostbusters, Top Gun, Ferris Bueller's Day Off,
The Terminator, RoboCop, Beetlejuice, Die Hard, Aliens, Blade Runner

## Working Style
pace: balanced
default-autonomy: confirm

Human approval gates:
- [x] Galley: shaping → approved
- [ ] Galley: delivering → review
- [x] Galley: review → done

Testing expectations:
- Unit tests required for all business logic
- E2E tests for critical user journeys

PR policy:
- PR required before merge to main
- At least one human review for Galleys touching auth or billing

## Team
team-size: small-team
Roles:
- Shaper (human)
- Builder (AI)
- Reviewer (AI + human sign-off)
```
