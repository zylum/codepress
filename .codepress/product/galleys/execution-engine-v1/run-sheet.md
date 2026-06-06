# Run Sheet: Execution Engine v1

## Overview

Six slugs across two tracks:

**Track A — engine core:**
1. `status-detector` — detect pending actions from artefact frontmatter
2. `codepress-run` — implement `codepress run` command
3. `watch-mode` — `codepress watch` file watcher + auto-trigger (aspirational)

**Track B — integration:**
4. `engine-config` — dispatch routing config in codepress.md
5. `board-regeneration` — wire status skill into CLI output
6. `test-and-docs` — tests + documentation updates

## Parallel plan

| Slug | Depends on | Parallel with |
|---|---|---|
| 1. status-detector | — | 4 |
| 2. codepress-run | 1, 4 | 5 |
| 3. watch-mode | 2 | — |
| 4. engine-config | — | 1 |
| 5. board-regeneration | — | 2 |
| 6. test-and-docs | 1, 2, 4, 5 | — |

## Execution order

1. **status-detector** (`continuous`) — parallel with engine-config
2. **engine-config** (`continuous`) — parallel with status-detector
3. **codepress-run** (`confirm`) — depends on 1 + 2; human reviews before proceeding
4. **board-regeneration** (`continuous`) — can overlap with 3
5. **watch-mode** (`stop`) — depends on 3; defer if complex
6. **test-and-docs** (`confirm`) — depends on all; human reviews before closing
