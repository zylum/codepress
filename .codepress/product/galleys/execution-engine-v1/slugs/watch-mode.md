---
id: ee-v1-s3
status: open
galley: ee-v1
autonomy: stop
---

# Slug: watch-mode

## Purpose

Implement `codepress watch` — a file watcher that monitors artefact files for frontmatter changes and automatically triggers the engine runner.

## Acceptance checklist

- [ ] `codepress watch` starts a persistent process watching `.codepress/product/` for changes
- [ ] On change, runs status detection to check for new pending actions
- [ ] If pending actions found, executes them automatically via the runner
- [ ] Uses `fswatch` on macOS / `inotifywait` on Linux — no new dependencies
- [ ] Graceful shutdown on SIGINT/SIGTERM
- [ ] Logs events to stderr: file changed, action detected, action executed
- [ ] `--dry-run` flag: detect and log without executing

## Context

This is aspirational for v1 — the priority is manual mode (`codepress status` + `codepress run`). Watch mode is the automation layer on top.

Implementation outline:

```bash
codepress watch() {
  local watched=".codepress/product"
  fswatch -0 "$watched" | while read -d "" event; do
    codepress status --json | detect-actions
    if has_pending; then
      codepress run --all
    fi
  done
}
```

## Dependencies

- `codepress-run` (watch mode calls the runner)

## Evidence

(Filled at completion)
