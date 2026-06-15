---
layout: default
title: Quick Reference
---

<link rel="stylesheet" href="/codepress/assets/css/custom.css">

<div class="tab-nav">
  <a href="overview.html">Overview</a>
  <a href="faq.html">FAQs</a>
  <a class="active-tab" href="quick-reference.html">Reference</a>
</div>
<div class="page-nav">
  <a href="index.html">Home</a>
  <a href="quick-start.html">Quick Start</a>
  <a href="structure.html">Structure</a>
  <a href="https://github.com/zylum/codepress">GitHub</a>
</div>

# Quick Reference

## Structure

```text
your-project/
├── .codepress/
│   ├── system/           How we work
│   │   ├── codepress.md  Project config + reading order
│   │   ├── AGENTS.md     Agent operating manual
│   │   ├── skills/       AI-executable skills (8)
│   │   ├── templates/    Artefact templates
│   │   └── hooks/        Automation hooks
│   ├── product/          What we build
│   │   ├── initiatives/  Ideas and opportunities
│   │   ├── galleys/      Shaped solutions
│   │   └── releases/     Release notes
│   ├── knowledge/        What we know
│   │   ├── concepts.md   Core entities
│   │   ├── glossary.md   Terminology
│   │   ├── current-state.md Current capabilities
│   │   ├── decisions/    Architecture decisions
│   │   ├── signals/      Raw observations
│   │   └── patterns/     Reusable lessons
│   └── views/            Helper views
├── src/                  Source code
├── docs/                 Project documentation
├── AGENTS.md             Root pointer
└── codepress             CLI tool
```

## CLI commands

```bash
codepress init              # Bootstrap a new project
codepress upgrade           # Pull latest CodePress version
codepress status            # Show delivery board + pending actions
codepress run               # Dispatch next pending action
codepress run --all         # Dispatch all pending actions in sequence
codepress galley new        # Create a new galley
codepress galley list       # List all galleys
codepress galley move       # Move galley to a new status
```

### `codepress status`

Shows the current project state: galley list with statuses, knowledge counts, and — most importantly — the pending action queue. After displaying, it regenerates all board views from artefact frontmatter.

```
CodePress status

  Version:  v0.2.0

  Initiatives:  1
  Galleys:
    my-feature  [delivering]
  Releases:  0

  Knowledge:  2 patterns  |  4 signals  |  1 decisions

  Pending actions:
    review  my-feature  Galley 'my-feature' — all slugs complete, ready for review

  → Run 'codepress run' to execute the next pending action

  ✓ Boards regenerated
```

### `codepress run`

Reads the pending action queue and prompts to execute the next action. Displays the skill file for the agent, shows which engine is configured to handle it, then waits for confirmation.

```bash
codepress run          # Execute next action (interactive confirm)
codepress run --all    # Iterate all pending actions with confirm per action
```

### Engine configuration

Add an `engines:` block to `.codepress/system/codepress.md` to route each workflow stage to a different AI agent:

```yaml
engines:
  shaping: claude
  split: claude
  build: opencode
  verifier: claude      # spawns a fresh session — no build context, spec + artefacts only
  review: claude
  release: claude
  capture: claude
  compound: claude
```

If the section is absent, all stages default to `claude`. Engine names are strings — the CLI prints which agent should handle each action; actual dispatch is manual or via `codepress watch`.

The `verifier` engine is intentionally separate from `build`. The verifier receives only the Galley spec and artefacts — never the build session history. This prevents motivated reasoning from leaking through verification.

## Galley lifecycle

| Status | Meaning |
|---|---|
| shaping | Being defined |
| approved | Ready for execution |
| delivering | Slugs in progress |
| review | All slugs done, learning capture |
| done | Complete |

## Core workflow

1. **Initiative** → `shape` skill → **Galley**
2. **Galley** → `split` skill → **Slugs**
3. **Slugs** → `build` skill → **Deliver**
4. **Done** → `verify` skill (separate verifier engine) → **Gates pass**
5. **Gates pass** → `review` skill → **Signals → Patterns → Knowledge**
6. **Review** → Entropy check → **Galley done**

## Loop-grade execution

| Field | Location | Purpose |
|---|---|---|
| `holdout: true` | Galley frontmatter | Reviewer holds additional criteria not visible to builder |
| `budget:` | Galley + Slug frontmatter | Wall-clock, token, and cost ceilings |
| `verifier:` | Engines block | Fresh-context evaluation agent separate from builder |
| `type: failure` Signal | `knowledge/signals/` | Structured failure: what-failed / why / rule-changed |
| Entropy section | `review.md` | Did we improve the system or just ship a feature? |
