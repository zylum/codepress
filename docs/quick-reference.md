---
layout: default
title: Quick Reference
---

# Quick Reference

## Structure

```
codepress/
├── system/              Operating System
│   ├── codepress.md     Project configuration
│   ├── AGENTS.md        Agent operating manual
│   ├── playbooks/       How CodePress operates
│   ├── skills/          AI-executable behaviours
│   ├── templates/       Artefact templates
│   └── hooks/           Automation hooks
├── product/             Product System
│   ├── initiatives/     Ideas and problems worth solving
│   ├── galleys/         Shaped solutions with nested slugs
│   └── releases/        Release notes
├── knowledge/           Knowledge System
│   ├── concepts.md      Core entities and their purpose
│   ├── glossary.md      Terminology
│   ├── current-state.md What exists today
│   ├── decisions/       Architectural decisions
│   ├── signals/         Raw observations from delivery
│   └── patterns/        Reusable lessons
├── views/               Helper views
├── src/                 Source code (optional)
├── docs/                Jekyll docs site
└── codepress            CLI tool
```

## CLI commands

```bash
codepress init           # Bootstrap a new project
codepress migrate        # Migrate from old structure
codepress status         # Show delivery board
```

## Core workflow

```
1. Initiative → system/skills/create-galley.md → Galley
2. Galley     → system/skills/split-galley.md   → Slugs
3. Slugs      → system/playbooks/build.md       → Deliver
4. Done       → system/skills/capture-pattern.md → Signals → Patterns
5. Patterns   → system/playbooks/compound.md    → Knowledge update
```

## Galley lifecycle

| Status | Meaning |
|---|---|
| shaping | Being defined |
| approved | Ready for execution |
| delivering | Slugs in progress |
| review | All slugs done, learning capture |
| done | Complete |
