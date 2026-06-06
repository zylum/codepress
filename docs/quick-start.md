---
layout: default
title: Quick Start
---

<link rel="stylesheet" href="/codepress/assets/css/custom.css">

<div class="tab-nav">
  <a href="overview.html">Overview</a>
  <a href="faq.html">FAQs</a>
  <a href="quick-reference.html">Reference</a>
</div>
<div class="page-nav">
  <a href="index.html">Home</a>
  <a class="primary-nav" href="quick-start.html">Quick Start</a>
  <a href="structure.html">Structure</a>
  <a href="https://github.com/zylum/codepress">GitHub</a>
</div>

# Quick Start

## Install

**One-liner (any directory):**
```bash
curl -fsSL https://raw.githubusercontent.com/zylum/codepress/main/codepress | bash -s init
```

**Install to PATH (one-time, use forever):**
```bash
curl -fsSL https://raw.githubusercontent.com/zylum/codepress/main/codepress -o /usr/local/bin/codepress && chmod +x /usr/local/bin/codepress
cd your-project && codepress init
```

**Update when a new version ships:**
```bash
codepress upgrade
```

## Get started

| Step | Action |
|---|---|
| 1 | Clone the CodePress template repository |
| 2 | Run `codepress init` to bootstrap |
| 3 | Populate `.codepress/system/config.md` with your project details |
| 4 | Read `AGENTS.md` for the full operating manual |
| 5 | Capture your first Initiative in `.codepress/product/initiatives/` |
| 6 | Run the create-galley skill to shape it |

## Requirements

- **Git** — for version control and commit discipline
- **An AI agent** (Claude Code, opencode, etc.) — CodePress is designed for AI-assisted delivery
- **Optional:** A project repository to apply CodePress to

## Project structure after init

```text
your-project/
├── .codepress/
│   ├── system/           How we work
│   │   ├── config.md     Project configuration
│   │   ├── AGENTS.md     Agent operating manual
│   │   ├── playbooks/    Workflow guides
│   │   ├── skills/       AI-executable behaviours
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

## Next steps

- Read the [Core Concepts](core-concepts.html) to understand the artefacts
- Browse the [Structure](structure.html) for the full directory layout
- Check the [Quick Reference](quick-reference.html) for commands and lifecycle
