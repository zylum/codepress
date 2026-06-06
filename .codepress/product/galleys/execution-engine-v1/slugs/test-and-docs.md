---
id: ee-v1-s6
status: open
galley: ee-v1
autonomy: confirm
---

# Slug: test-and-docs

## Purpose

Add tests for the execution engine (status detection, action execution, dispatch routing) and update all documentation to reflect the new commands, engine config, and architecture.

## Acceptance checklist

- [ ] Tests exist for status detection — each artefact state maps to correct pending action
- [ ] Tests exist for `codepress run` — dry-run mode, single action, --all
- [ ] Tests exist for engine dispatch — config parsing, agent routing, fallback defaults
- [ ] Tests exist for board regeneration — frontmatter → correct kanban output
- [ ] `docs/quick-reference.md` updated with `run` and `watch` commands
- [ ] `docs/index.md` or `docs/overview.md` updated with engine architecture diagram or description
- [ ] `docs/faq.md` updated if relevant
- [ ] `README.md` updated with new CLI commands and engine capabilities

## Context

Tests should be in a format consistent with the project. Since the CLI is bash, tests can be shell-based (bats, shunit2) or the project can introduce a test framework here.

The documentation site is Jekyll-based at `docs/`. The existing pages (index, quick-reference, overview, faq, core-concepts, structure) each need review for engine-related updates.

## Dependencies

- `status-detector` (what to test)
- `codepress-run` (what to test)
- `engine-config` (what to test)
- `board-regeneration` (what to test)

## Evidence

(Filled at completion)
