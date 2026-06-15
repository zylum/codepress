# CodePress v0.4.0

A compound product development operating system for the AI era.

```
Idea → Shape → Build → Learn → Compound
```

The software is the output. The growing capability of the system is the asset.

## Three pillars

| Pillar | Directory | What |
|---|---|---|
| **System** | `.codepress/system/` | How we work — skills, templates, hooks |
| **Product** | `.codepress/product/` | What we build — initiatives, galleys, slugs, releases |
| **Knowledge** | `.codepress/knowledge/` | What we know — concepts, glossary, decisions, patterns |

A **Compound Loop** (Signal → Pattern → Knowledge) continuously improves all three.

## Install

```bash
# One-liner
curl -fsSL https://raw.githubusercontent.com/zylum/codepress/main/codepress | bash -s init

# Install to PATH
curl -fsSL https://raw.githubusercontent.com/zylum/codepress/main/codepress -o /usr/local/bin/codepress && chmod +x /usr/local/bin/codepress
cd your-project && codepress init

# Update
codepress upgrade
```

## Structure

```
.codepress/
├── system/          ├── codepress.md  ├── AGENTS.md
│                    ├── skills/       └── templates/  hooks/
├── product/         ├── initiatives/  ├── galleys/    └── releases/
└── knowledge/       ├── current-state.md  ├── patterns/  └── signals/
```

## Skills

10 AI-executable skills in `.codepress/system/skills/`:
`shape` · `split` · `build` · `review` · `verify` · `release` · `bootstrap` · `status` · `signal` · `parallel-run`

## FinOps

Track token and cost budgets per Galley. Fill `budget:` in galley/slug frontmatter, capture `type: cost` signals during build, and enforce with the `cost-check` verify gate. See `docs/quick-reference.md#finops`.

## Loop Interop

CodePress participates in the cross-system loop fabric via `.loop/manifest.yaml` and a JSONL event outbox at `.codepress/loop-events/`. See `docs/interop.md`.

## Reading order (4 hops)

1. `codepress.md` — project config and conventions
2. `knowledge/current-state.md` — what exists today
3. `knowledge/patterns/` — reusable lessons
4. Active galley — the current shaped solution

## CLI

```bash
codepress init              # Bootstrap a new project
codepress upgrade           # Pull latest CodePress version
codepress status            # Show delivery board + pending actions
codepress status --json     # Machine-readable pending actions
codepress run               # Dispatch next action
codepress run --all         # Dispatch all pending actions
codepress galley new        # Create a new galley
codepress galley list       # List all galleys
codepress galley move       # Move galley to a new status
```

## License

MIT
