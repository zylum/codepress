---
id: af-v1
status: delivering
initiative: af-001
release:
created: 2026-06-15
verify: [cost-check]
holdout: false
budget:
  wall-clock: 2d
  tokens: 40000
  cost: 2.00
---

# Galley: AI FinOps v1

## Problem

CodePress budgets for nothing. Budget frontmatter fields exist in Galley and Slug templates but are never populated, never checked, and never compounded into cost Patterns. After any Galley completes, there is zero visibility into token consumption, which slugs were expensive, or whether costs are trending.

This means the system cannot answer: "Did this galley cost what we expected?" or "What would make the next one cheaper?" — even though the review skill already asks the second question.

## Users

Any CodePress user who cares about cost efficiency — which is every team running AI delivery loops against paid API endpoints.

## Success

AI FinOps operationalised as a first-class CodePress concern. By galley-close, the system will have: captured cost per slug as a structured Signal, compared actual vs budget at verify gates, and promoted any cost Patterns to Knowledge. The "what would make the next galley 20% cheaper?" entropy question will be answerable from real data, not guesswork.

Minimum acceptable: `type: cost` signals exist in the Signal skill, the build skill captures cost per slug, and a verify gate checks budget before allowing `delivering → review`.

## Constraints

- **No CLI changes.** All FinOps logic lives in skills, templates, YAML frontmatter, and verify gates. The `codepress` bash script is not modified.
- **Provider-agnostic.** The cost capture mechanism must work with any AI agent. No hardcoded API calls to OpenAI, Anthropic, etc.
- **Additive only.** Existing Signals, build, and review workflows continue working unchanged. FinOps adds optional depth, not required overhead.
- **Self-reported v0.** Cost data is captured by the builder after each slug, not by a wrapper or provider API. This is trust-based and approximate — accept that.

## Approach

Five layers, built in dependency order:

1. **Cost signal type** — extend `skills/signal.md` with `type: cost` structured YAML (mirrors existing `type: failure`). This is the data format.
2. **Budget templates** — update `templates/galley.md` and `templates/slug.md` with mandatory budget-field guidance and realistic examples. This is the declaration format.
3. **Build cost capture** — add a cost-capture step to `skills/build.md` so every slug records its token usage and estimated cost before committing. This is the collection layer.
4. **Budget verify gate** — add `cost-check` to `codepress.md`'s `verify:` section. A shell gate that reads galley frontmatter budget, sums cost Signals from completed slugs, and fails if over budget. Extend `skills/status.md` to flag budget overruns as pending actions. This is the enforcement layer.
5. **Cost compounding at review** — enhance `skills/review.md` to aggregate cost Signals, compare vs budget, and promote cost Patterns to Knowledge. This is the learning layer.

The `.loop/manifest.yaml` mapping `tokens_per_galley → cost` already exists — this galley makes the pipeline real.

## Acceptance Criteria

- [ ] `skills/signal.md` documents a `type: cost` YAML variant with fields: slug, tokens-in, tokens-out, model, cost-estimate, source
- [ ] `templates/galley.md` and `templates/slug.md` have budget fields with doc guidance and examples — not just blank YAML keys
- [ ] `skills/build.md` includes a cost-capture step (between implementation and Signals block) that records token/model/cost in the slug's Signals section
- [ ] `codepress.md` has a `cost-check` verify gate that reads galley `budget.tokens` + `budget.cost`, sums cost signals from completed slugs, and fails on overrun
- [ ] `skills/status.md` detects cost overruns (actual > budget) as pending actions
- [ ] `skills/review.md` aggregates cost signals at galley-close, compares against budget, and proposes cost Patterns
- [ ] FinOps concepts seeded in `knowledge/concepts.md`, `knowledge/glossary.md`, `knowledge/current-state.md`
- [ ] `tokens_per_galley → cost` mapping in `.loop/manifest.yaml` preserved and annotated
- [ ] Existing `type: failure` signal behaviour unchanged
