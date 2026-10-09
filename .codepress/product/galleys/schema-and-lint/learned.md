# Learned: schema-and-lint

## What worked
Making the lifecycle data and having one engine read it meant the CLI, the hook and the status view agree by construction. Keeping retired statuses working for galleys that have not migrated made the change land without rewriting history.

## What surprised us
Gates are only as strong as their inputs: a template full of placeholder prose made "section exists" vacuous. Every gate needs a test where it says no on the untouched scaffold.

## What we would change
Verdict parsing and AC parsing each exist in Bash and Python. A later slug should retire the Bash copies in favour of one.

## Signals
- knowledge/signals/2026-10-08-vacuous-shape-gate.md — new gate: shape_complete now requires real content
- knowledge/signals/2026-10-08-marker-split-by-upgrade.md — new gate: lint V001, and upgrade moves only the marker
- knowledge/signals/2026-10-08-parser-twins-diverge.md — new gate: ac_parity test
- knowledge/signals/2026-10-09-bytecode-pollution.md — found by the independent verifier: lint now runs with -B and a test asserts it leaves nothing behind
