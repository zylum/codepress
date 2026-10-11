# Adapters

CodePress core is tool- and model-agnostic. Anything specific to one agent runtime,
model or automation tool lives here, one file per adapter, and nothing outside this
directory may depend on it.

| Adapter | What it covers |
|---|---|
| `hermes.md` | An optional automation agent that replaces `codepress watch` with context-aware execution |

A new adapter is a markdown file describing how that tool reads CodePress artefacts,
which skills it follows, and what it must never do (become the source of truth).
`codepress lint` and the lifecycle in `schema/lifecycle.yaml` are the contract every
adapter works against.
