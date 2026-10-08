---
# status: proposed | shaped | building | verifying | done | killed | superseded
id: schema-and-lint
status: verifying
initiative: 
release: 
domain:                 # optional: the area of the work; slugs inherit it
created: 2026-10-08
verify: 
holdout: false
approved_by: Marv
approved_on: 2026-10-08
budget:
  wall-clock:       # expected duration e.g. 2d — optional, for planning
  tokens:           # expected total tokens e.g. 25000 — required for cost-check gate
  cost:             # expected total USD e.g. 1.50 — required for cost-check gate
---

# Galley: [name]

## Problem
CodePress's rules for how work moves were prose. Statuses drifted into a dozen spellings (five meaning "finished"),
nothing checked that a terminal galley had evidence, an independent review or a write-up of what it taught, a slug could
land in git while its acceptance boxes stayed unticked, and the version marker could disagree with itself between two
files of one project. Learning stayed in narrative signals no gate could act on.
<!-- What are we solving, and why now? -->

## Users
<!-- Who experiences this? What are they trying to do? -->

## Success
A galley cannot reach a terminal status without all slugs settled, evidence cited, an independent review and
`learned.md` — enforced by `codepress lint`, not instruction. Illegal transitions, retired statuses, drift and a
disagreeing version marker fail lint. The hook never needs `--no-verify`, even in a fresh git worktree.
<!-- How will we know it worked? What is the minimum acceptable outcome? -->

## Constraints
<!-- What is explicitly out of bounds? (time, technical, scope) -->

## Approach
The lifecycle (statuses, transitions, gates, legacy mapping) is data in `system/schema/lifecycle.yaml`, read by a
dependency-free Python `lint.py`; the Bash CLI asks it rather than keeping a copy. Galleys on retired statuses keep the
old `galley move` gates until migrated. A galley is any bounded task — nothing in the schema assumes code.
<!-- The shaped solution. Direction and key decisions — not a spec.
     Enough clarity for someone else to build it without asking questions. -->

## Acceptance Criteria

- [x] AC1 · check: bash tests/test_lifecycle_schema.sh
- [x] AC2 · check: bash tests/test_lint.sh
- [x] AC3 · check: bash tests/test_galley_lifecycle.sh
- [x] AC4 · check: bash tests/test_hook.sh
- [x] AC5 · check: bash tests/test_version.sh
- [x] AC6 · check: bash tests/test_status_json.sh
- [x] AC7 · check: bash tests/test_migrate_status.sh
- [x] AC8 · check: ./codepress lint --base none --quiet
- [x] AC9 · check: bash tests/run_tests.sh
<!--
What does done look like from the outside?

Every criterion is ONE line, bound to evidence. Fields are separated by " · "
(space-middot-space). Three kinds — one example each (remove the comment markers
around the ones you use):

- [x] AC1 · Given a logged-in user · When the session expires · Then re-auth is required · test: tests/test_auth.sh::test_session_expiry
- [x] AC2 · check: bash tests/run_tests.sh
- [x] AC3 · manual: confirm the DNS cutover in the registrar console

Rules:
- `test:` binds a behaviour (Given/When/Then) to a named test — ref format `<path>::<name>`.
- `check:` binds a mechanical criterion to a shell command — exit 0 = pass.
- `manual:` marks a human-only step — agents NEVER tick it; `codepress check` fails if it is ticked.
- `codepress check <galley>` evaluates every bound line; unbound prose lines warn as legacy.
- Lines inside HTML comments (like these) are not criteria.

Galley-level gates still go in the `verify:` frontmatter field; per-criterion
evidence lives on the AC line itself (test:/check:/manual: bindings above).
Set `holdout: true` if the reviewer holds additional criteria not visible to the builder.
-->
