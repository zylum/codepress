# Current State

What this system can do today.

> Seed this file using `skills/bootstrap.md` or fill in manually.
> Update whenever a Galley significantly changes capabilities.

---

## Core capabilities
What the system currently does.

- Galley and Slug lifecycle management (proposed → shaped → building → verifying → done)
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

- Lifecycle as data (`system/schema/lifecycle.yaml`): seven galley statuses, four slug statuses, allowed
  transitions, a gate catalogue (static vs dynamic), and the mapping from every retired status value. Field
  schemas for galleys, slugs (`domain`, `tier`, `risk`, `needs_review`, `escalate_after`, `autonomy`) and
  structured signals. See `docs/lifecycle.md`.
- `codepress lint` — the single enforcement point (stdlib Python, `system/lib/lint.py`): retired statuses,
  illegal transitions against a base ref, terminal gates, drift between `slug:<x> done` commits and unticked
  boxes, schema violations, plan-change log shape, structured signals, version-marker disagreement.
  Waivers (`--force --reason`) downgrade failures so `--no-verify` is never needed.
- `codepress galley approve|move` — approval is a gate; moves run the lifecycle's gates; `migrate-status`
  plans moving an older project onto the vocabulary.
- `codepress hook install|run` — pre-commit lint + verify gates, with environment discovery for fresh git
  worktrees (`CODEPRESS_ENV`, `hook-env:`, main-worktree venv).
- `codepress status --json --galleys` — per-galley state: slug progress, last activity (commits naming the
  galley count), stalled flag, next action, and who it needs.
- One source of truth for the version: the marker in `system/codepress.md`; the CLI derives its version from it.

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
