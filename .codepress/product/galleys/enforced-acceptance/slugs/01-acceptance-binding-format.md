---
id: acceptance-binding-format
status: closed
galley: enforced-acceptance
autonomy: continuous
budget:
  wall-clock: 2h
  tokens:
  cost:
---

# Slug: acceptance-binding-format

## Purpose
One grep-parseable line format that binds every acceptance criterion to machine
evidence — behaviours to a named test, mechanics to a shell command, human steps to
an untickable-by-agents marker.

## Acceptance checklist
- [x] AC line grammar decided and documented in `system/templates/galley.md`:
      `- [ ] <id> · Given … · When … · Then … · test: <ref>` |
      `- [ ] <id> · check: <command>` | `- [ ] <id> · manual: <step>` —
      ` · ` (space-middot-space) as separator, markers `test:` / `check:` /
      `manual:` extractable with a single grep -oE each
- [x] `system/templates/slug.md` acceptance checklist updated with the same
      convention (+ one example of each kind)
- [x] `system/skills/shape.md` and `system/skills/split.md` instruct writing ACs in
      this format: behaviours → GWT+test, mechanics → check, human/infra → manual
      (never GWT-ify a deletion; never check-ify a behaviour)
- [x] `system/dod.md` item 1 references the binding ("every criterion carries a
      `test:`, `check:`, or `manual:` binding")
- [x] A parsing helper exists in the CLI (`extract_acs <galley.md>` emitting
      `id|kind|payload|ticked` lines) with a bash test proving it parses all three
      kinds plus legacy unbound lines (kind=legacy) · test: tests/test_ac_parsing.sh

## Context
Read `.codepress/system/templates/galley.md` (current Acceptance section + the
"machine-evaluable → verify:" comment, which this supersedes for per-AC evidence),
`templates/slug.md`, and `codepress` CLI's `fm()` helper for the house parsing
style. The format must survive the CLI's grep/sed/awk toolchain — no nested YAML.
The galley for this work (`enforced-acceptance/galley.md`) is itself written in the
new format; use it as the fixture.

## Dependencies
None — this slug is the foundation.

## Evidence
- Grammar documented with one example of each kind in `system/templates/galley.md`
  (Acceptance Criteria section) and `system/templates/slug.md` (Acceptance checklist).
- `system/skills/shape.md` gained a "Writing acceptance criteria" section
  (behaviours → GWT+test, mechanics → check, human/infra → manual; never GWT-ify a
  deletion, never check-ify a behaviour); `system/skills/split.md` step 7 references it.
- `system/dod.md` item 1 now reads "Every criterion carries a `test:`, `check:`, or
  `manual:` binding".
- `extract_acs` lives in the `codepress` CLI (emits `id|kind|payload|ticked`),
  reachable for tests via the internal `codepress __extract-acs <file>` plumbing.
- `bash tests/test_ac_parsing.sh` — 8 passed, 0 failed (all three kinds, legacy
  unbound → kind=legacy, ticked detection, slug-section parsing, missing-file error).
- Dogfood parse of this galley's own ACs: 8 lines, AC1–AC7 kind=test, AC8 kind=check.

---

## Signals
- The " · " middot separator survives BSD and GNU awk as a plain byte literal —
  no locale handling needed; the grammar fits the existing grep/sed/awk toolchain.
- The CLI has no shared frontmatter helper (`fm()` was folklore) — inline parsing
  per call site is the house style, so extract_acs is one self-contained awk program.
- Galley "Acceptance Criteria" and slug "Acceptance checklist" share the
  `^## Acceptance` prefix — one parser covers both artefacts for free.
