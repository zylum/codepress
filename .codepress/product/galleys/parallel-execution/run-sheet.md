# Run Sheet: Parallel Execution

## Order

Slugs 1 and 2 are independent — run in parallel.
Slug 3 depends on both (adds cross-references between them).
Slug 4 depends on all (integration + README update).

```yaml
parallel-groups:
  - id: A
    slugs: [1-parallel-run-skill, 2-claude-commands]
    note: "independent — different files"
  - id: B
    slugs: [3-split-skill-update]
    depends-on: [A]
  - id: C
    slugs: [4-docs-update]
    depends-on: [B]
```

## Stopping conditions
Stop if `.claude/commands/` format is unclear — check Claude Code docs before creating wrapper files.
