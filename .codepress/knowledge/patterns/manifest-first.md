---
status: proposed
source: loop-interop-v1 review
---

## Pattern: Manifest-first

When adding loop interop to a system, author the manifest from a spec example before writing any emission code.

### Problem

It's tempting to start with the fun part (emitting signals), but without a clear manifest you don't know what to emit or how to name it.

### Approach

1. Read the loop-spec example for your system type
2. Author `.loop/manifest.yaml` first: loops, signals, canonical term mappings
3. Validate against the manifest schema
4. Only then write emission code — you now know exactly what signals to emit and what terms they map to

### When to use

When adding loop fabric participation to any new system.

### When not to use

When the system already has a manifest from a previous interop iteration — update it, don't start from scratch.

### Evidence

The loop-spec example was directly usable as the root manifest with only pointer tweaks. The example forced clarity on signal names, canonical terms, and loop structure before any implementation.
