# Hook: on-galley-done

Fires when a Galley closes (status moves to `done`).
Syncs the completion event back to Garner.

---

## When to run

At the end of `skills/capture-pattern.md`, after:
- Domain Memory has been updated
- Patterns have been promoted
- Galley status set to `done`

---

## Steps

### 1. Resolve the Garner project path

Read `codepress.md` in this project root.
Find the `garner-project:` field.

If not set: skip this hook and log a warning — Garner sync not configured.

### 2. Read the Galley summary

From the closed Galley's `review.md`, extract:
- What was delivered (1–2 sentences from the Retrospective)
- Signals count
- Patterns promoted (names)
- Domain Memory updates made

### 3. Write a work grain to Garner

File path: `silos/marv/grains/work/YYYY-MM-DD-galley-{galley-id}.md`

```markdown
# Grain: Galley done — {galley-id} — YYYY-MM-DD

> Type: work.galley-done
> Source: CodePress hook
> Immutable: do not edit

---
- Project: {project name from codepress.md}
- Galley: {galley-id}
- Delivered: {1-sentence summary}
- Signals captured: {count}
- Patterns promoted: {list or "none"}
- Domain updates: {list or "none"}
```

### 4. Append log entry to Garner project file

Append to: `silos/marv/projects/{garner-project}.md`

```markdown
- {YYYY-MM-DD}: Galley `{galley-id}` done — {1-sentence summary}
```

Append under the most recent `### {Month Year}` section in the Log.
If no section exists for the current month, create one.

### 5. Update active-galley in Garner project file

Update the `active-galley:` metadata line at the top of the project file.
Set to `—` if no next Galley is in delivery, or the next Galley's id if known.

---

## Access method

**Local (preferred):** Use filesystem MCP tools directly on Garner repo at `/Users/marv/code/personal/garner`.

**Remote:** Use Loom API:
- `POST /memory/grain` — write the grain
- `POST /memory/append` — append the log entry

---

## On failure

If Garner is unreachable or the write fails:
- Log the failure in the Galley's `review.md` under a `## Sync` section
- Do not block the Galley from closing
- Retry manually when Garner is accessible
