---
id: af-001
status: archived
created: 2026-06-15
---

# Initiative: AI FinOps — token cost tracking across the loop

## Problem

CodePress budgets for nothing. The `budget:` fields in Galley and Slug frontmatter are optional placeholders that nobody fills. After a Galley completes, there is zero visibility into how many tokens it cost, which slugs consumed the most, or whether costs are trending up across releases.

Without cost visibility, two things happen:
1. Agents optimise toward the visible spec with no budget fence — they will use unlimited compute to pass tests (see `sig-001`: Agents Cheat Without Fences)
2. Cost surprises compound silently. A galley that costs 3x the previous one is a Pattern nobody captured.

## Context

The `loop-interop` galley already maps `tokens_per_galley → cost` as a canonical signal term in `.loop/manifest.yaml`. The `budget:` field exists in both templates. The review skill already asks "What would make the next galley 20% cheaper?" — the entropy question needs cost data to answer.

The gap is operational: nothing captures cost during delivery, nothing checks budget vs actual, and nothing compounds cost lessons into Patterns.

## Why now

The scaffolding (budget fields, manifest mapping, review question) is already committed. Without the operational layer — capture, verify, compound — the budget fields are dead metadata and the entropy question is guesswork. Adding FinOps now also proves the cost→canonical signal pipeline for loop-interop's `signal-emission` slug.

## Thoughts

- Cost signals follow the same pattern as `type: failure` signals — structured YAML frontmatter, stored in `knowledge/signals/`, promoted to Patterns in `knowledge/patterns/`
- Self-reported cost (builder estimates tokens after each slug) is the v0 capture mechanism. It's imperfect but universal — no provider-specific APIs needed
- The verify gate reads frontmatter, it doesn't call billing APIs
- All FinOps logic lives in skills and YAML — the `codepress` CLI doesn't change
- `tokens_per_galley → cost` in `.loop/manifest.yaml` is the canonical map; this galley makes it operational

## Attachments

- `knowledge/signals/2026-06-13-lfd-agents-cheat-without-fences.md` — sig-001, budget fences rationale
- `.codepress/product/galleys/loop-interop-v1/` — manifest mapping, signal emission pattern
- `.codepress/system/templates/galley.md` — existing budget field
- `.codepress/system/templates/slug.md` — existing budget field
