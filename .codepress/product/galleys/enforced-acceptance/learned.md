# Learned: enforced-acceptance

## What worked
Converting three declared controls into mechanical ones at the single state mutator (`galley move`) made the trust boundary real: criteria bound to a test or command, manual steps agents cannot tick, and a Verdict that must come from a different engine than the builder. Dogfooding — the galley's own criteria in its own grammar — kept the design honest.

## What surprised us
The grammar needed no per-galley opt-in: bound versus unbound is decidable per line, so legacy prose criteria simply warn. And the galley itself drifted: it was complete and verified but its status and boxes never advanced, which is exactly what `codepress lint` now reports.

## What we would change
Status transitions should have been data from the start; the later lifecycle schema (schema-and-lint) fixes that.

## Signals
- "textual fences do not constrain agents" — promoted as the reason the two hard lines are enforced by the CLI, not prose.
