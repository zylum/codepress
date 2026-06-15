# Run Sheet: Loop Interop v1

## Overview

Three slugs. Declare before emit; emit before docs.

1. `manifest-adopt` — author + validate `.loop/manifest.yaml`
2. `signal-emission` — emit `signal_published` / `failure_logged` envelopes at close
3. `interop-docs` — document participation + decoupling audit

## Parallel plan

| Slug | Depends on | Parallel with |
|---|---|---|
| 1. manifest-adopt | — | — |
| 2. signal-emission | 1 | — |
| 3. interop-docs | 1, 2 | — |

## Execution order

1. **manifest-adopt** (`continuous`) — small; start from the loop-spec example.
2. **signal-emission** (`confirm`) — touches the close hook; human reviews the envelope shape.
3. **interop-docs** (`continuous`) — includes the "names no consumer" audit.

## Notes for the executor

- The neutral standard is at `/Users/marv/code/loop-spec`. Read `manifest.schema.yaml` and `events.md` first.
- Start from `loop-spec/examples/codepress.loop.yaml` — it already drafts CodePress's two loops.
- If you find the standard insufficient, edit it in `loop-spec` and bump `spec_version`; never hard-code around it.
