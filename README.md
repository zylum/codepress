# CodePress

A compound product development operating system for the AI era.

```
Idea → Shape → Build → Learn → Compound
```

The software is the output. The growing capability of the system is the asset.

---

## Three pillars

| Pillar | Directory | What |
|---|---|---|
| **System** | `.codepress/system/` | How we work — playbooks, skills, templates, hooks |
| **Product** | `.codepress/product/` | What we build — initiatives, galleys, slugs, releases |
| **Knowledge** | `.codepress/knowledge/` | What we know — concepts, glossary, decisions, patterns |

A **Compound Loop** (Signal → Pattern → Knowledge) continuously improves all three.

---

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

---

## Structure

```
your-project/
├── .codepress/          All CodePress artefacts
│   ├── system/          Operating System
│   │   ├── codepress.md Project config
│   │   ├── AGENTS.md    Agent operating manual
│   │   ├── playbooks/   How CodePress operates
│   │   ├── skills/      AI-executable behaviours
│   │   ├── templates/   Artefact templates
│   │   └── hooks/       Automation hooks
│   ├── product/         Product System
│   │   ├── initiatives/ Ideas and problems
│   │   ├── galleys/     Shaped solutions
│   │   └── releases/    Release notes
│   ├── knowledge/       Knowledge System
│   │   ├── concepts.md  Core entities
│   │   ├── glossary.md  Terminology
│   │   ├── current-state.md What exists
│   │   ├── decisions/   Architecture decisions
│   │   ├── signals/     Raw observations
│   │   └── patterns/    Reusable lessons
│   └── views/           Helper views
├── src/                 Source code
├── docs/                Project documentation
├── AGENTS.md            Root pointer → .codepress/system/AGENTS.md
└── codepress            CLI tool (in PATH or at root)
```

---

## Core workflow

1. Capture an **Initiative** in `.codepress/product/initiatives/`
2. **Shape** it → `.codepress/system/skills/create-galley.md` → Galley in `.codepress/product/galleys/`
3. **Split** into Slugs → `.codepress/system/skills/split-galley.md`
4. **Build** → `.codepress/system/playbooks/build.md`
5. **Review** → `.codepress/system/skills/capture-pattern.md` → Signals → Patterns
6. **Compound** → Update `.codepress/knowledge/`

---

## References & Inspiration

- [Linotype](https://github.com/zylum/linotype) — predecessor to CodePress, CLI-based operating model
- [Compound Engineering](https://every.to/guides/compound-engineering) — the compounding approach to product building
- [BMAD Method](https://github.com/bmad-code-org/bmad-method) — build-measure-learn loop for software delivery
- [Value Over Everything](https://www.linkedin.com/newsletters/value-over-everything-7015605132717359104/) — LinkedIn newsletter on product and value

---

## License

MIT
