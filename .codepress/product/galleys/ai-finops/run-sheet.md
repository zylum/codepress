# Run Sheet: AI FinOps v1

## Overview

Six slugs, strictly sequential. Each layer depends on the one before it.

1. `cost-signal-format` — extend signal skill with `type: cost`
2. `budget-templates` — update galley/slug templates with budget guidance
3. `build-cost-capture` — add cost capture step to build skill
4. `verify-gate` — add cost-check gate to codepress.md + status detection
5. `cost-compounding` — enhance review skill for cost aggregation
6. `knowledge-seed` — update concepts, glossary, current-state

## Parallel plan

| Slug | Depends on | Parallel with |
|---|---|---|
| 1. cost-signal-format | — | — |
| 2. budget-templates | — | 1 |
| 3. build-cost-capture | 1 | — |
| 4. verify-gate | 1 | 3 |
| 5. cost-compounding | 1, 3, 4 | — |
| 6. knowledge-seed | 1, 2 | 3, 4, 5 |

Slugs 1 and 2 can start in parallel (both touch different files). Slug 3 and 4 can also run in parallel after slug 1 completes, since they modify different files.

## Execution order (recommended)

1. **cost-signal-format** (`continuous`) — small, self-contained, unlocks everything downstream
2. **budget-templates** (`continuous`) — also small, no code dependencies on slug 1
3. **build-cost-capture** (`continuous`) — references the cost signal format
4. **verify-gate** (`continuous`) — references the cost signal format
5. **cost-compounding** (`confirm`) — depends on slugs 3+4; human reviews the cost flow
6. **knowledge-seed** (`continuous`) — final housekeeping

## Notes for the executor

- The `type: cost` signal format must exactly mirror the existing `type: failure` pattern — structured YAML frontmatter, same storage path (`knowledge/signals/`), same promotion logic
- The `cost-check` verify gate is a bash command that parses YAML frontmatter. Keep it simple — `grep -A` or `yq` if available, fallback to `awk`
- Self-reported cost is v0. Do not add provider API calls or wrapper infrastructure
- All changes are additive. Existing workflows must continue working identically without FinOps fields filled
