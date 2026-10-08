---
id: 
status: open            # open | building | closed | dropped
galley: 
autonomy: continuous    # continuous | confirm | stop
domain:                 # optional: defaults to the galley's domain
tier: build             # plan | build | mechanical
risk: medium            # low | medium | high
needs_review: false     # an independent review of this slug before it closes
escalate_after: 2       # failed attempts before handing up a tier
budget:
  wall-clock:       # expected duration e.g. 2h
  tokens:           # expected tokens e.g. 5000 — feeds cost-check verify gate
  cost:             # expected USD e.g. 0.25 — feeds cost-check verify gate
---

# Slug: [name]

## Purpose
One sentence: what does this Slug deliver?

## Acceptance checklist
One line per criterion, bound to evidence — same " · "-separated grammar as galley ACs:
- [ ] AC1 · Given <context> · When <action> · Then <outcome> · test: tests/test_file.sh::test_name
- [ ] AC2 · check: <shell command — exit 0 = pass>
- [ ] AC3 · manual: <human-only step — an agent never ticks this>

## Context
What does the executor need to know?
Reference knowledge docs, patterns, constraints — do not repeat them.

## Dependencies
Which Slugs must complete before this one? (leave blank if none)

## Evidence
(Filled at completion — proof this Slug is done)

---

## Signals
<!-- Fill 2–3 bullets before committing: what surprised you? what would you change? any pattern emerging? -->
