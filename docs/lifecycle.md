---
layout: default
title: Lifecycle
---

<link rel="stylesheet" href="/codepress/assets/css/custom.css">

<div class="tab-nav">
  <a href="overview.html">Overview</a>
  <a href="faq.html">FAQs</a>
  <a href="quick-reference.html">Reference</a>
</div>
<div class="page-nav">
  <a href="index.html">Home</a>
  <a href="quick-start.html">Quick Start</a>
  <a href="structure.html">Structure</a>
  <a class="primary-nav" href="lifecycle.html">Lifecycle</a>
  <a href="https://github.com/zylum/codepress">GitHub</a>
</div>

# Lifecycle, gates and lint

A **galley** is any bounded task with a contract (its acceptance criteria), gates, and a record of how it went. It does not have to be code.

The rules for how a galley moves are **data**, not prose: `.codepress/system/schema/lifecycle.yaml`. `codepress lint` reads that file and is the single enforcement point — for the pre-commit hook, for CI, and for `codepress galley move`. The pages in `system/skills/` describe the workflow; when they disagree with the schema, the schema wins.

## The lifecycle

```
proposed ──► shaped ──► building ──► verifying ──► done
    │           │  ▲        │  ▲          │
    │           │  └────────┘  └──────────┘      (replan / rework — logged)
    └───────────┴────────┴────────┴──► killed | superseded
```

| Status | Meaning |
|---|---|
| `proposed` | An idea or problem worth shaping. No contract yet. |
| `shaped` | The contract is written (problem, success, approach, acceptance criteria). Slugs are split here. Waiting for approval. |
| `building` | Approved, and being delivered slug by slug. |
| `verifying` | All slugs settled. An independent verifier is judging the result. |
| `done` | Delivered, verified by someone other than the builder, and learned from. **Terminal.** |
| `killed` | Deliberately stopped; `closed_reason` says why. **Terminal.** |
| `superseded` | Replaced by another galley (`superseded_by`). **Terminal.** |

Approval is a **gate**, not a status: a human runs `codepress galley approve <galley>`, which records `approved_by` and `approved_on`, and `shaped → building` requires them.

A terminal galley is never reopened. If done work turns out wrong, open a new galley. History stays readable.

## Transitions and what each requires

| Transition | Requires |
|---|---|
| `proposed → shaped` | `shape_complete` |
| `shaped → building` | `approved`, `slugs_exist` |
| `building → verifying` | `slugs_settled`, `acs_ticked`, `signals_present`, `ac_check` |
| `verifying → done` | `evidence`, `independent_review`, `learned_md`, `ac_check` |
| `shaped → proposed` | — |
| `building → shaped` | `plan_change_logged` |
| `verifying → building` | `plan_change_logged` |
| any open status → `killed` | `reason` |
| any open status → `superseded` | `superseded_by` |

A galley sitting at a status must satisfy the requirements of every step on the way to it — a `verifying` galley that lost its approval is as wrong as a `building` one.

## Gates

Each gate is either **static** (decidable from files; `codepress lint` evaluates it) or **dynamic** (needs running something; `codepress check` and `galley move` evaluate it). Lint never runs your tests, which is why it is safe in a git hook.

| Gate | Kind | Satisfied when |
|---|---|---|
| `shape_complete` | static | galley.md has Problem, Success, Approach and Acceptance Criteria sections |
| `approved` | static | `approved_by` and `approved_on` are set |
| `slugs_exist` | static | the galley has been split into at least one slug |
| `slugs_settled` | static | every slug is `closed` or `dropped` |
| `acs_ticked` | static | every acceptance box is ticked — `manual:` steps excepted, a human attests those in the Verdict |
| `signals_present` | static | review.md has captured Signals |
| `ac_check` | dynamic | every bound acceptance criterion passes `codepress check` |
| `evidence` | static | review.md has an `## Evidence` section citing proof (commits, test runs, links) |
| `independent_review` | static | review.md has a complete `## Verdict` by a verifier other than the builder (`engines.build`) |
| `learned_md` | static | `learned.md` exists and says something |
| `plan_change_logged` | static | `plan-changes.md` has at least one well-formed entry |
| `reason` | static | `closed_reason` is set |
| `superseded_by` | static | `superseded_by` names another galley in the project |
| `slug_acs_ticked` | static | (slug) every acceptance box in the slug is ticked |

To override a gate on purpose: `codepress galley move <g> <status> --force --reason "..."`. That appends a dated `> waived:` line to review.md; lint downgrades the matching failures to warnings. A recorded exception never needs `git commit --no-verify`.

## Slugs

A slug is an atomic delivery unit with its own lifecycle: `open → building → closed`, or `dropped`. Dropping a slug is a plan change — say why in `plan-changes.md`.

Slug frontmatter (all but the first four are optional; absent means the default):

| Field | Values | Default | Meaning |
|---|---|---|---|
| `id`, `status`, `galley` | | | required |
| `autonomy` | `continuous` \| `confirm` \| `stop` | `continuous` | run to completion / check with a human before the next slug / halt and wait |
| `domain` | text | the galley's | the area of the work; slugs in different domains can run in parallel |
| `tier` | `plan` \| `build` \| `mechanical` | `build` | how much capability the slug deserves: judgment and design / ordinary delivery / rote, well-specified edits |
| `risk` | `low` \| `medium` \| `high` | `medium` | blast radius if it goes wrong |
| `needs_review` | `true` \| `false` | `false` | an independent review before this slug closes (treat `risk: high` as true unless set) |
| `escalate_after` | integer ≥ 0 | `2` | failed attempts before the slug is handed up a tier |
| `depends_on` | list of slug ids | | must be settled first |

Galley frontmatter: `id`, `status`, `created` are required; `initiative`, `release`, `domain`, `verify`, `holdout`, `budget`, `approved_by`, `approved_on`, `closed_reason`, `superseded_by`, `legacy`, `legacy_status` are optional. Unknown fields are allowed and ignored. The field definitions are in `schema/galley.schema.yaml` and `schema/slug.schema.yaml`.

## `codepress lint`

```bash
codepress lint                    # compare against HEAD (what a pre-commit hook wants)
codepress lint --base origin/main # compare against a base branch (what CI wants)
codepress lint --strict           # warnings fail too
codepress lint --json             # machine-readable
codepress lint --verbose          # also show legacy findings
```

Exit 0 when clean (warnings allowed), 1 on errors, 2 on usage errors.

| Code | Severity | Finds |
|---|---|---|
| `G001` / `S001` | error | unknown galley / slug status |
| `G002` / `S002` | error | a **retired** status (see the mapping below), with the replacement |
| `G004` / `S004` | error | a field that breaks its schema (bad enum, bad date, non-boolean...) |
| `R001` | error | the galley's status needs a gate that is unmet (e.g. `done` without `learned.md`) |
| `T001` | error | an **illegal transition** compared with the base ref (e.g. `shaped → done`) |
| `T003` | error | a legal transition whose own requirements are unmet |
| `T002` | warn | a new galley created mid-lifecycle |
| `V001` | error | the **version marker disagrees with itself** |
| `V002` / `V004` | warn | a duplicate marker / project behind the CLI |
| `D001` | error | a slug is `closed` but acceptance boxes are unticked |
| `D002` | error | **drift:** `slug:<x> done` landed in git but the slug's boxes are unticked |
| `D003`–`D006` | warn | drift: slug commits but still open / galley still `shaped` / boxes ticked too early / every slug settled but galley boxes unticked |
| `P001` / `P003` | error / warn | malformed plan-change entry / dropped slug never explained |
| `N001`–`N004` | error / warn | structured-signal problems |

### Drift

The costliest failure mode is work that landed but the files do not admit it: a build agent finds most acceptance criteria of a "ready" galley already built but unticked. Lint reads git for commits following the convention `slug:<name> done — ...` and compares them with the slug file. A commit that claims a slug is done while its boxes are unticked is an error.

Last activity — for the status view — counts commits that **name** the galley, not only commits that touch its folder, so active work does not look stalled.

### Legacy galleys

Galleys that predate the schema cannot meet gates they never had. Mark a **terminal** galley `legacy: true` and lint stops gating it (drift findings drop to `--verbose`). The flag is ignored on a live galley — it is not a loophole. `codepress migrate-status` sets it for you.

## Learning artefacts

**`learned.md`** — per galley, the human summary of what it taught. Required for `done`. Template: `templates/learned.md`.

**Structured signals** — one record per file in `.codepress/knowledge/signals/`, marked `record: signal`, so a machine can count recurrences and a human can act on each:

```yaml
---
record: signal
id: sig-2026-10-08-a
created: 2026-10-08
galley: my-feature
failure_class: silent-failure          # kebab-case, countable
caught_by: review                      # lint | test | typecheck | review | verifier | human | monitoring | none
should_have_been_caught_by: lint       # the gate that ought to have caught it
action: new-gate                       # new-gate | pattern | accepted-risk
status: open                           # open | resolved | dropped
---
```

`resolved` needs `resolved_by`; `accepted-risk` needs `risk_note`. A pattern that is not a gate does not stop the failure — `action` forces the choice. Prose notes in the same directory are left alone. Template: `templates/signal.md`.

**Plan-change log** — `plan-changes.md` per galley: what the plan said, what changed on contact with reality, and why.

```markdown
## 2026-10-08 — Short title
- **Plan said:** what we intended
- **Changed:** what we did instead
- **Why:** what reality taught us
- **Affects:** slug-a, slug-b          (optional)
```

Required to send a galley back (`verifying → building`, `building → shaped`); lint checks the shape.

## The version marker

One source of truth: `codepress-version:` in `.codepress/system/codepress.md`. The CLI derives its own version from the marker bundled with it — there is no second copy to forget. `codepress upgrade` never overwrites `codepress.md` (it is project configuration); it moves the marker. If any other file in `.codepress/system/` still carries a marker (a leftover `config.md`), lint reports a duplicate (`V002`), and an outright disagreement (`V001`) is an error.

## Git hook

```bash
codepress hook install     # writes .git/hooks/pre-commit
```

The hook runs `codepress hook run`: `codepress lint`, then every verify gate in `codepress.md` (the `test` gate by default). It is built so nobody needs `--no-verify`:

- A fresh git worktree has no virtualenv, so the gates would fail with "command not found". The hook finds a tool environment: `CODEPRESS_ENV=<dir>` (a venv root with `bin/`), else `hook-env:` in `codepress.md`, else `./.venv` / `./venv`, else the same names in the **main worktree**.
- `CODEPRESS_HOOK_GATES="lint"` narrows one commit to lint alone — the sanctioned alternative when an environment truly is absent.
- A real override is `codepress galley move --force --reason ...`, which leaves a waiver lint understands.

In CI:

```bash
codepress lint --base origin/main --strict
```

## Per-galley state for views and other tools

```bash
codepress status --json --galleys
```

One row per galley: canonical `status`, `raw_status`, slug counts, acceptance counts, `last_activity` (commits that name the galley count), `days_since_activity`, `stalled`, `next_action`, **`needs`** (`human` | `agent` | `verifier` | `none`), and `blocked_by` (the unmet gates of the next transition).

## Migrating older statuses

`codepress migrate-status` plans the move (dry run), and `--apply` writes it. The mapping below lives in `lifecycle.yaml` under `legacy:`; **judgment calls** are the ones worth a human glance first.

| Kind | Legacy value | Becomes | Also | Note |
|---|---|---|---|---|
| galley | `draft` | `proposed` |  |  |
| galley | `shaping` | `proposed` |  | Being shaped is not yet shaped. |
| galley | `ready` | `shaped` | approved_by: legacy; **judgment call** | Shaped and cleared to build. |
| galley | `approved` | `shaped` | approved_by: legacy | Approval is now a gate on shaped->building, not a status of its own. |
| galley | `active` | `building` |  |  |
| galley | `delivering` | `building` |  |  |
| galley | `rework` | `building` | **judgment call** | Record the reason in plan-changes.md. |
| galley | `review` | `verifying` |  | The builder's hand-off to an independent verifier. |
| galley | `complete` | `done` | legacy: true; **judgment call** | Finished, but evidence, review and learned.md were never required. |
| galley | `delivered` | `done` | legacy: true; **judgment call** |  |
| galley | `released` | `done` | legacy: true |  |
| galley | `learned` | `done` | legacy: true |  |
| galley | `archived` | `killed` | **judgment call** | Parked or abandoned. Set closed_reason when migrating. |
| slug | `pending` | `open` |  |  |
| slug | `todo` | `open` |  |  |
| slug | `ready` | `open` |  |  |
| slug | `active` | `building` |  |  |
| slug | `in-progress` | `building` |  |  |
| slug | `wip` | `building` |  |  |
| slug | `complete` | `closed` |  |  |
| slug | `completed` | `closed` |  |  |
| slug | `done` | `closed` |  |  |
| slug | `delivered` | `closed` |  |  |
| slug | `skipped` | `dropped` |  |  |
| slug | `cancelled` | `dropped` |  |  |
| slug | `killed` | `dropped` |  |  |
| slug | `archived` | `dropped` | **judgment call** | Shelved. Record why in plan-changes.md. |

`approved` and `ready` become `shaped` plus `approved_by: legacy`. Terminal values are marked `legacy: true` unless they already satisfy every gate. Nothing else in the file is touched.
