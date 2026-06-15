---
id: li-v1-s3
status: open
galley: li-v1
autonomy: continuous
---

# Slug: interop-docs

## Purpose
Document how CodePress participates in the loop fabric, and run the decoupling audit.

## Acceptance checklist
- [ ] Docs section: "CodePress as a loop participant" — the manifest, the outbox, how a connector consumes it
- [ ] States the decoupling rule explicitly: CodePress declares only itself
- [ ] Audit: grep the repo for `garner|loom|dreaming` in loop-related files — zero hits (outside this doc's explanation)
- [ ] Links to the neutral standard at `/Users/marv/code/loop-spec`
- [ ] `current-state.md` / knowledge index updated to mention loop interop

## Context
This is the loop-closing step for the galley. The audit is the important bit — it's how we keep the decoupling invariant honest over time.

## Dependencies
li-v1-s1, li-v1-s2.

## Evidence
(Filled at completion)

---

## Signals
<!-- any place the decoupling nearly leaked? -->
