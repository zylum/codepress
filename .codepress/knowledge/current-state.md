# Current State

What this system can do today.

> Seed this file using `skills/bootstrap.md` or fill in manually.
> Update whenever a Galley significantly changes capabilities.

---

## Core capabilities
What the system currently does.

- Galley and Slug lifecycle management (shaping → delivery → review → done)
- Signal capture and Pattern promotion (failure + cost types)
- Budget declaration and cost-check verification
- Self-reported cost tracking per slug via `type: cost` signals
- Bound acceptance criteria: one-line AC grammar (`test:` / `check:` / `manual:`
  bindings, " · " separated — see `system/templates/galley.md`), parsed by
  `extract_acs` in the CLI
- `codepress check <galley>` — runs `verify:` gates fresh and evaluates every
  bound AC (test refs via the `test-runner:` config template); legacy prose ACs
  warn only
- Gated status transitions: `galley move → review` requires check pass +
  non-empty review.md Signals; `→ done` additionally requires an independent
  `## Verdict` (`verified-by` ≠ `engines.build`); `--force` bypasses with a dated
  waiver appended to review.md

## Live / in production
What is deployed and being used.

- CodePress CLI v0.3

## In progress
What is actively being built (link to active Galleys).

- `product/galleys/loop-interop-v1/` — Loop interoperability: manifest adoption, signal emission, interop docs
- `product/galleys/enforced-acceptance/` — slugs delivered, awaiting independent verification (verdict gate applies to its own close)

## Known limitations
What it cannot do, or does poorly.

- Cost tracking is self-reported (v0) — no automatic wrapper or provider API integration
- No cross-galley cost trending yet (cost Patterns will enable this as galleys close)
- No budget field validation in the CLI — relies on verify gates
- Cost-check gate uses globs that could match multiple galleys — needs a target parameter for multi-galley projects

## Last updated
2026-06-15 — Galley `ai-finops` done
