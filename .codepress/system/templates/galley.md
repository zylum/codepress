---
# status: proposed | shaped | building | verifying | done | killed | superseded
id: 
status: proposed
initiative: 
release: 
domain:                 # optional: the area of the work; slugs inherit it
created: 
verify: 
holdout: false
approved_by:            # set by `codepress galley approve` — required to start building
approved_on:
budget:
  wall-clock:       # expected duration e.g. 2d — optional, for planning
  tokens:           # expected total tokens e.g. 25000 — required for cost-check gate
  cost:             # expected total USD e.g. 1.50 — required for cost-check gate
---

# Galley: [name]

## Problem
<!-- What are we solving, and why now? -->

## Users
<!-- Who experiences this? What are they trying to do? -->

## Success
<!-- How will we know it worked? What is the minimum acceptable outcome? -->

## Constraints
<!-- What is explicitly out of bounds? (time, technical, scope) -->

## Approach
<!-- The shaped solution. Direction and key decisions — not a spec.
     Enough clarity for someone else to build it without asking questions. -->

## Acceptance Criteria
<!--
What does done look like from the outside?

Every criterion is ONE line, bound to evidence. Fields are separated by " · "
(space-middot-space). Three kinds — one example each (remove the comment markers
around the ones you use):

- [ ] AC1 · Given a logged-in user · When the session expires · Then re-auth is required · test: tests/test_auth.sh::test_session_expiry
- [ ] AC2 · check: bash tests/run_tests.sh
- [ ] AC3 · manual: confirm the DNS cutover in the registrar console

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
