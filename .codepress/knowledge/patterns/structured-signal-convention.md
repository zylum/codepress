---
status: proposed
source: ai-finops review
---

## Pattern: Structured signal convention

Signal types should follow the same structural convention: YAML frontmatter with required fields, documented in `skills/signal.md`.

### Problem

Each new signal type risks inventing a different format, increasing cognitive overhead for builders who must switch between formats.

### Approach

Follow the same YAML frontmatter pattern for all structured signal types:

```yaml
---
type: <signal-type>
<field-1>: <value>
<field-2>: <value>
---
```

Required fields are documented in a table in `skills/signal.md`. The pattern was established by `type: failure` and followed by `type: cost`.

### When to use

When adding a new structured signal type to `skills/signal.md`.

### When not to use

For free-text observation signals — they remain one-bullet entries. The structured format is for signals that need machine-parseable fields.

### Evidence

The `type: cost` format slotted naturally after the `type: failure` section with zero structural friction. Mirroring the existing YAML pattern made the format feel like a convention, not a new thing.
