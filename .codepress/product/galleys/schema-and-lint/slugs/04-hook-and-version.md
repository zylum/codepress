---
id: hook-and-version
status: closed
galley: schema-and-lint
autonomy: continuous
tier: build
risk: low
---

# Slug: hook-and-version

## Purpose
Pre-commit hook with environment discovery; one version source; upgrade keeps one marker.

## Acceptance checklist
- [x] AC1 · check: bash tests/test_hook.sh
- [x] AC2 · check: bash tests/test_version.sh

## Evidence
Tests green in the final full run (see review.md).
