---
layout: default
title: Quick Reference
---

# Quick Reference

## Structure

```
your-project/
├── .codepress/           All CodePress artefacts
│   ├── system/           Operating System
│   │   ├── codepress.md  Project configuration
│   │   ├── AGENTS.md     Agent operating manual
│   │   ├── playbooks/    How CodePress operates
│   │   ├── skills/       AI-executable behaviours
│   │   ├── templates/    Artefact templates
│   │   └── hooks/        Automation hooks
│   ├── product/          Product System
│   │   ├── initiatives/  Ideas and problems
│   │   ├── galleys/      Shaped solutions
│   │   └── releases/     Release notes
│   ├── knowledge/        Knowledge System
│   │   ├── concepts.md   Core entities
│   │   ├── glossary.md   Terminology
│   │   ├── current-state.md What exists
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
codepress init           # Bootstrap a new project
codepress migrate        # Migrate from old structure
codepress status         # Show delivery board
```

## Core workflow

```
1. Initiative → .codepress/system/skills/create-galley.md → Galley
2. Galley     → .codepress/system/skills/split-galley.md   → Slugs
3. Slugs      → .codepress/system/playbooks/build.md       → Deliver
4. Done       → .codepress/system/skills/capture-pattern.md → Signals → Patterns
5. Patterns   → .codepress/system/playbooks/compound.md    → Knowledge update
```

## Galley lifecycle

| Status | Meaning |
|---|---|
| shaping | Being defined |
| approved | Ready for execution |
| delivering | Slugs in progress |
| review | All slugs done, learning capture |
| done | Complete |
