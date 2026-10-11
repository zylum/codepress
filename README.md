# CodePress

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

## Lifecycle

```
proposed → shaped → building → verifying → done      (or killed / superseded)
```

A galley is any bounded task with a contract, gates and a record of how it went. The rules for how it moves —
statuses, transitions, the gates each transition requires — are data in `.codepress/system/schema/lifecycle.yaml`,
enforced by `codepress lint` in your git hook and CI. See [docs/lifecycle.md](docs/lifecycle.md).

## CLI

```bash
codepress init              # Bootstrap a new project
codepress upgrade           # Pull latest CodePress version
codepress status            # Show delivery board + pending actions
codepress status --json     # Machine-readable pending actions
codepress status --json --galleys  # Per-galley state: progress, activity, next action, who it needs
codepress run               # Dispatch next action
codepress run --all         # Dispatch all pending actions
codepress galley new        # Create a new galley (starts at proposed)
codepress galley list       # List all galleys
codepress galley approve    # Record human approval of a shaped galley
codepress galley move       # Move a galley along the lifecycle (gates run here)
codepress check <galley>    # Run verify gates + every bound acceptance criterion
codepress lint              # Statuses, transitions, gates, drift, version marker
codepress hook install      # Pre-commit: lint + verify gates (no --no-verify needed)
codepress migrate-status    # Plan moving older statuses onto the lifecycle
codepress version           # CLI version + this project's marker
```

## License

MIT
