# Run Sheet: Docs Refresh

## Order

Slugs 1 and 2 are independent — run in parallel.
Slug 3 is a final check pass.

```yaml
parallel-groups:
  - id: A
    slugs: [1-readme]
    note: "README.md only"
  - id: B
    slugs: [2-docs-site]
    note: "docs/ Jekyll pages"
  - id: C
    slugs: [3-verify]
    depends-on: [A, B]
```
