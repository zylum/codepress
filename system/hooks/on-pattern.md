# Hook: on-pattern

Fires when a new Pattern is promoted from a Signal.
Placeholder for pattern distribution or notification.

---

## When to run

After `system/skills/capture-pattern.md` creates or updates a Pattern in `knowledge/patterns/`.

---

## Steps

1. (Optional) Notify the team about the new Pattern
2. (Optional) Cross-reference with existing Patterns for conflicts or overlaps
3. (Optional) Update any downstream consumers that reference the Pattern

---

## Purpose

Patterns are the reusable lessons of the system.
This hook ensures they don't sit unnoticed in the filesystem.
