---
id: ee-v1-s1
status: complete
galley: ee-v1
autonomy: continuous
---

# Slug: status-detector

## Purpose

Parse artefact frontmatter across the project and determine what actions are pending next.

## Acceptance checklist

- [ ] Reads all Initiative frontmatter — detects initiatives with `status: shaping` that don't have a corresponding Galley
- [ ] Reads all Galley frontmatter — detects approved galleys without slugs, delivering galleys with complete slugs, review-ready galleys
- [ ] Reads all Slug frontmatter — detects open/ready slugs
- [ ] Outputs a machine-readable list of pending actions (action type + target artefact)
- [ ] Integrates with `codepress status` so it shows "Pending: create-galley for ee-001" not just file counts

## Context

The key insight: artefact status + existence of downstream artefacts = pending action. For example:

- Initiative `status: shaping` + no galley folder exists with matching name → `create-galley`
- Galley `status: approved` + no slugs exist → `split-galley`
- Galley `status: delivering` + all slugs `status: complete` → `review`
- All slugs complete + review done → `generate-release` + `capture-pattern`

See `.codepress/system/skills/status.md` for the current board-generation approach.

## Dependencies

None.

## Evidence

- `detect_pending_actions()` function added to `codepress` CLI (lines ~400-494)
- Reads all Initiative frontmatter, matches against Galley `initiative:` references
- Detects: `create-galley` (initiative without galley), `split-galley` (approved without slugs), `review` (all slugs complete), `release+capture` (review done)
- Outputs both human-readable (text) and machine-readable (pipe-delimited json) formats
- Integrated into `codepress status` — shows "Pending actions:" section
- `codepress run` and `codepress run --all` commands implemented
- All artefact frontmatter remains the single source of truth (no separate state files)

