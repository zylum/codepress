# Hook: on-galley-complete

Fires when a Galley closes (status moves to `done`).
Emits a completion event for external consumers.

---

## When to run

At the end of `.codepress/system/skills/capture-pattern.md`, after:
- Knowledge has been updated
- Patterns have been promoted
- Galley status set to `done`

---

## Steps

### 1. Read the Galley summary

From the closed Galley's `review.md`, extract:
- What was delivered (1–2 sentences from the Retrospective)
- Signals count
- Patterns promoted (names)
- Knowledge updates made

### 2. Emit completion event

Write a structured event to `.codepress/knowledge/events/`:

File path: `YYYY-MM-DD-galley-{galley-id}-done.md`

```markdown
# Event: Galley done — {galley-id} — YYYY-MM-DD

> Type: galley.done
> Source: CodePress hook
> Timestamp: YYYY-MM-DDTHH:MM:SSZ

---
- Project: {project name from .codepress/system/codepress.md}
- Galley: {galley-id}
- Delivered: {1-sentence summary}
- Signals captured: {count}
- Patterns promoted: {list or "none"}
- Knowledge updates: {list or "none"}
```

### 3. Log completion

Append to `.codepress/knowledge/current-state.md` under `## In progress`:
- Remove the completed Galley from the list
- Add to `## Last updated` with the completion date

---

## On failure

If event emission fails:
- Log the failure in the Galley's `review.md` under a `## Sync` section
- Do not block the Galley from closing
- Retry manually when possible

---

## Notes

This hook emits events for external consumers. It does not know about
any consumer system. Consumers discover CodePress via its manifest and
derive events from the filesystem.
