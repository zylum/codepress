---
id: docs-and-release
status: closed
galley: schema-and-lint
autonomy: continuous
tier: build
risk: low
---

# Slug: docs-and-release

## Purpose
Docs, skills, templates and release notes describe the lifecycle.

## Acceptance checklist
- [x] AC1 · check: ./codepress lint --base none --quiet
- [x] AC2 · check: bash tests/test_walkthrough.sh

## Evidence
Tests green in the final full run (see review.md).
