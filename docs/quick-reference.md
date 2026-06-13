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
codepress status            # Show delivery board
codepress run               # Dispatch next action
codepress run --all         # Dispatch all pending actions
codepress galley new        # Create a new galley
codepress galley list       # List all galleys
codepress galley move       # Move galley to a new status
```

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
4. **Done** → `review` skill → **Signals → Patterns**
5. **Patterns** → **Knowledge update**
