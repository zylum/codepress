---
id: review-skill-update
status: done
galley: learning-loop
autonomy: continuous
---

# Slug: Review Skill Update

## Purpose
Update `skills/review.md` so step 1 collects Signals from Slug files first, and step 2 *drafts* Pattern candidates rather than asking the agent to identify them from scratch.

## Acceptance checklist
- [x] `skills/review.md` step 1 instructs: read Slug Signals blocks, then synthesise into review.md
- [x] Step 2 says "draft pattern candidates — human approves" not "identify patterns"
- [x] The skill references the new review.md four-section structure
- [x] Rework detection added: scan git log for `rework:` prefix in commit messages since galley started

## Context
The key insight: by the time galley-close happens, all the Signals are already in the Slug files. The review skill should aggregate them, not ask for fresh recall. This removes the biggest friction point — having to remember everything at the end.

## Dependencies
Depends on `review-template` (slug 2).

## Evidence

`system/skills/review.md` updated: step 1 now reads Slug Signals blocks explicitly and includes a `git log --grep="^rework:"` command. Step 2 renamed to "Draft Pattern candidates — human approves" with `[ ] proposed` markers. The review.md structure block at the end updated to match the four-section template.

---

## Signals
- 2026-06-13: The old step 1 asked the agent to recall observations from delivery — the new version reads them from files, removing the single biggest friction point at galley-close.
- 2026-06-13: Adding `[ ] proposed` markers to pattern candidates makes the human-approval gate explicit in the file rather than in the agent's head.
- 2026-06-13: The rework detection git command needs a `--since` date anchored to galley creation — without it the scan would cover the entire repo history.
