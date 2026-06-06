---
id: ee-v1-s2
status: complete
galley: ee-v1
autonomy: confirm
---

# Slug: codepress-run

## Purpose

Implement `codepress run [--all]` that reads pending actions from the status detector and executes the matching skill or playbook.

## Acceptance checklist

- [ ] `codepress run` shows pending actions and prompts which to execute (or executes the highest-priority one)
- [ ] `codepress run --all` executes all pending actions in dependency order
- [ ] Each action invokes the correct skill or playbook from `.codepress/system/skills/` or `.codepress/system/playbooks/`
- [ ] Exit codes: 0 = success, 1 = no pending actions, 2 = execution failure
- [ ] Output log shows what was executed and the result
- [ ] Non-destructive — running `codepress run` with no pending actions is a no-op
- [ ] Integration with engine dispatch (engine-config slug) — routes to configured agent

## Context

Action → Skill mapping:

| Detection | Execute |
|---|---|
| Initiative `shaping`, no galley | `system/skills/create-galley.md` |
| Galley `approved`, no slugs | `system/skills/split-galley.md` |
| Galley `delivering`, slugs all complete | `system/playbooks/review.md` |
| Galley `review` complete, no release | `system/skills/generate-release.md` |
| Release done, signals not captured | `system/skills/capture-pattern.md` |
| Signals exist, patterns not promoted | `system/playbooks/compound.md` |

## Dependencies

- `status-detector` (provides pending action list)
- `engine-config` (provides dispatch routing)

## Evidence

- `cmd_run()` shows next pending action with description and engine dispatch info
- `cmd_run --all` iterates all pending actions, confirming each before execution
- `execute_action()` reads and displays the appropriate skill or playbook file for each action type
- `resolve_engine()` + `dispatch_skill_for()` route each action to the configured engine from codepress.md
- Exit codes: 0 (no pending), 1 (not used), 2 (execution failure on missing skill file)
- Non-destructive: no pending = no-op with clear message
- All integration with status-detector and engine-config is wired

