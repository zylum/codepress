#!/usr/bin/env bash
# `codepress migrate-status`: a dry-run plan from the legacy mapping, then
# --apply. Nothing is changed without --apply, judgment calls are flagged, and
# the result lints.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

d=$(mk_project)
# retired values, each with what it needs to be valid afterwards
mk_galley "$d" g-shaping shaping
mk_galley "$d" g-ready ready
mk_slug "$d" g-ready s1 pending "" "- [ ] AC1 · check: true" ""
mk_galley "$d" g-deliv delivering
mk_slug "$d" g-deliv s1 in-progress "" "- [ ] AC1 · check: true" ""
mk_galley "$d" g-rework rework
mk_slug "$d" g-rework s1 active "" "- [ ] AC1 · check: true" ""
mk_galley "$d" g-review review "" "- [x] AC1 · check: true"
mk_slug "$d" g-review s1 complete
mk_review "$d" g-review "- noticed a thing" "" ""
mk_galley "$d" g-complete complete
mk_slug "$d" g-complete s1 done "" "- [ ] AC1 · check: true"
mk_galley "$d" g-done done
mk_galley "$d" g-archived archived
mk_slug "$d" g-archived s1 skipped "" "- [ ] AC1 · check: true" ""
printf '# Plan changes: g-archived\n\n## 2026-10-02 — skipped\n- **Plan said:** a\n- **Changed:** b\n- **Why:** c\n' > "$d/.codepress/product/galleys/g-archived/plan-changes.md"
mk_git "$d"

before=$(cd "$d" && git status --porcelain | wc -l | tr -d ' ')
cp_run "$d" migrate-status
eq "the dry run exits 0" "$RC" "0"
eq "…and changes nothing" "$(cd "$d" && git status --porcelain | wc -l | tr -d ' ')" "$before"
has "…says it is a dry run" "$OUT" "Dry run"
has "review plans to become verifying" "$OUT" "review -> verifying"
has "shaping plans to become proposed" "$OUT" "shaping -> proposed"
has "archived plans to become killed" "$OUT" "archived -> killed"
has "ready plans to become shaped with legacy approval" "$OUT" "approved_by: legacy"
has "terminal galleys are grandfathered" "$OUT" "legacy: true"
has "judgment calls are flagged for a human" "$OUT" "judgment call"
has "slug statuses are planned too" "$OUT" "complete -> closed"

lint_run "$d" --base none
eq "before migrating, lint fails on the retired values" "$RC" "1"

cp_run "$d" migrate-status --apply
eq "--apply succeeds" "$RC" "0"
has "…and says what to do next" "$OUT" "Now run \`codepress lint\`"

gstatus() { sed -n 's/^status: *//p' "$d/.codepress/product/galleys/$1/galley.md" | head -1; }
gfield() { sed -n "s/^$2: *//p" "$d/.codepress/product/galleys/$1/galley.md" | head -1; }

eq "shaping -> proposed" "$(gstatus g-shaping)" "proposed"
eq "ready -> shaped" "$(gstatus g-ready)" "shaped"
eq "…with legacy approval" "$(gfield g-ready approved_by)" "legacy"
eq "…and the original recorded" "$(gfield g-ready legacy_status)" "ready"
eq "delivering -> building" "$(gstatus g-deliv)" "building"
eq "…approved by legacy (it was already past approval)" "$(gfield g-deliv approved_by)" "legacy"
eq "rework -> building" "$(gstatus g-rework)" "building"
eq "review -> verifying" "$(gstatus g-review)" "verifying"
eq "complete -> done" "$(gstatus g-complete)" "done"
eq "…grandfathered" "$(gfield g-complete legacy)" "true"
eq "done stays done" "$(gstatus g-done)" "done"
eq "…and is grandfathered too (it cannot meet gates it never had)" "$(gfield g-done legacy)" "true"
eq "archived -> killed" "$(gstatus g-archived)" "killed"
has "…with a closed_reason" "$(gfield g-archived closed_reason)" "migrated from legacy status 'archived'"
eq "slug complete -> closed" "$(sed -n 's/^status: *//p' "$d/.codepress/product/galleys/g-complete/slugs/s1.md" | head -1)" "closed"
eq "slug pending -> open" "$(sed -n 's/^status: *//p' "$d/.codepress/product/galleys/g-ready/slugs/s1.md" | head -1)" "open"
eq "slug skipped -> dropped" "$(sed -n 's/^status: *//p' "$d/.codepress/product/galleys/g-archived/slugs/s1.md" | head -1)" "dropped"
has "bodies are untouched" "$(cat "$d/.codepress/product/galleys/g-review/galley.md")" "## Acceptance Criteria"

lint_run "$d" --base none
eq "after migrating, lint passes" "$RC" "0"

cp_run "$d" migrate-status
has "a second run finds nothing to do" "$OUT" "nothing to migrate"

# a terminal galley that already satisfies every gate stays strictly gated
d=$(mk_project)
mk_complete_galley "$d" good done
mk_galley "$d" bad done
cp_run "$d" migrate-status --apply
eq "a done galley that meets its gates is not grandfathered" "$(sed -n 's/^legacy: *//p' "$d/.codepress/product/galleys/good/galley.md" | head -1)" ""
eq "…one that does not, is" "$(sed -n 's/^legacy: *//p' "$d/.codepress/product/galleys/bad/galley.md" | head -1)" "true"

# unknown statuses are reported, never guessed
d=$(mk_project)
mk_galley "$d" odd mystery
cp_run "$d" migrate-status
has "an unknown status is reported for hand resolution" "$OUT" "unknown status 'mystery'"

d=$(mk_project)
mk_galley "$d" ok shaped
cp_run "$d" migrate-status
has "an already-canonical project has nothing to migrate" "$OUT" "nothing to migrate"

summary
