---
id: ee-v1
status: building
initiative: ee-001
release:
created: 2026-06-05
---

# Galley: Execution Engine v1

## Problem

Moving through the CodePress lifecycle requires manual orchestration. The system knows what should happen next (Initiative shaped → create Galley, Galley approved → split into Slugs, Slugs complete → review → release → capture signals → promote patterns → update knowledge) but nothing automates the chain. Humans have to run each step by hand.

## Users

CodePress users (solo and small teams). Anyone running a CodePress project who wants the lifecycle to advance automatically based on artefact state, without manually invoking skills.

## Success

A user can:

1. Create an Initiative
2. Mark it `shaping`
3. Have the engine detect this and run `create-galley`
4. Review and approve the Galley
5. Have the engine detect `approved` and run `split-galley`
6. Build Slugs in parallel
7. Have the engine detect completion → run review → release → capture signals → promote patterns → update knowledge

...without manually triggering each step.

Minimum acceptable outcome: `codepress status` shows pending actions, `codepress run` executes them. Watch mode is aspirational for v1.

## Constraints

- Must remain model-agnostic. The engine should dispatch to any AI agent.
- Must not break existing manual workflows. Manual mode should coexist.
- The CLI is currently 436 lines of bash. If the engine adds significant complexity, consider a helper binary or a separate engine process.
- No external dependencies beyond what CodePress already requires (git, bash, an AI agent).

## Approach

The engine is a thin orchestration layer on top of existing skills and playbooks. It does not create new workflow content — it detects state and dispatches to existing content.

Three components:

1. **Status detector** — reads artefact frontmatter, determines what should happen next
2. **Runner** — `codepress run` that reads pending actions and executes the matching skill/playbook
3. **Watcher** (v1 aspirational) — `codepress watch` that filesystem-watches artefacts and auto-triggers

Engine dispatch is configured in `codepress.md`:

```yaml
engines:
  shaping: claude
  build: opencode
  review: claude
```

The engine itself should be an addition to the existing bash CLI or a small helper. Starting with `codepress status` enhancements + `codepress run`.

## Acceptance Criteria

- [ ] `codepress status` shows pending actions grouped by workflow (not just artefact counts)
- [ ] `codepress run` executes the next pending action by running the appropriate skill/playbook
- [ ] `codepress run --all` executes all pending actions in sequence
- [ ] Engine dispatch routes to configured agent per workflow stage
- [ ] Artefact frontmatter drives all detection (no separate state file)
- [ ] Manual workflows still work unchanged
- [ ] Tests exist for status detection and action execution
- [ ] Docs updated: new CLI commands, engine config, architecture
- [ ] Board views regenerate automatically after each action
