---
id: ee-v1-s4
status: complete
galley: ee-v1
autonomy: continuous
---

# Slug: engine-config

## Purpose

Define the engine configuration schema in `codepress.md` and implement dispatch routing so each workflow stage can be assigned to a different AI agent.

## Acceptance checklist

- [ ] `codepress.md` gains an `engines:` section that maps workflow stages to agent names
- [ ] Dispatch logic reads the config and delegates execution to the configured agent
- [ ] Default config is auto-generated if section is missing (all stages → `claude`)
- [ ] Config supports at minimum: `shaping`, `split`, `build`, `review`, `release`, `capture`, `compound`
- [ ] Engine is model-agnostic — dispatch by agent name, not hardcoded tool
- [ ] Backward compatible — existing `codepress.md` files without engine config work as before

## Context

The config should sit in `codepress.md` alongside existing fields. Example:

```yaml
engines:
  shaping: claude
  build: opencode
  review: claude
  capture: claude
  compound: claude
```

Dispatch means: when the runner needs to execute a workflow, it checks which agent is configured, then hands off appropriately. For CLI-based agents (opencode), this might mean printing instructions. For MCP-aware agents, this might mean invoking via a subprocess.

This slug can run in parallel with `status-detector`.

## Dependencies

None.

## Evidence

- `engines:` section added to `.codepress/system/codepress.md` with stages: shaping, split, build, review, release, capture, compound
- `resolve_engine()` function reads engine config per stage, defaults to `claude` if section missing
- `dispatch_skill_for()` resolves action type → stage → engine and shows which agent handles each workflow
- `cmd_run()` and `cmd_run --all` both show engine dispatch alongside each pending action
- Backward compatible — config section is optional, missing config defaults to `claude`
- Model-agnostic by design — engine names are strings, not hardcoded tool paths

