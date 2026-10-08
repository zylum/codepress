#!/usr/bin/env bash
# `codepress galley new|approve|move` against the lifecycle: allowed edges,
# gates as data, killed/superseded reasons, waivers, and legacy compatibility.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

status_of() { sed -n 's/^status: *//p' "$1/.codepress/product/galleys/$2/galley.md" | head -1; }
field_of()  { sed -n "s/^$3: *//p" "$1/.codepress/product/galleys/$2/galley.md" | head -1; }

# ── galley new ────────────────────────────────────────────────────────────────

d=$(mk_project)
cp -r "$REPO_ROOT/.codepress/system/templates" "$d/.codepress/system/templates"
cp_run "$d" galley new alpha
eq "galley new starts at proposed" "$(status_of "$d" alpha)" "proposed"
eq "…stamping the created date" "$(field_of "$d" alpha created)" "$(date +%Y-%m-%d)"
eq "…and the id" "$(field_of "$d" alpha id)" "alpha"
has "…review.md has Signals, Evidence and Verdict sections" "$(cat "$d/.codepress/product/galleys/alpha/review.md")" "## Evidence"
lint_run "$d" --base none
eq "a freshly scaffolded galley lints clean" "$RC" "0"

d=$(mk_project)
cp_run "$d" galley new beta
eq "galley new works without templates (fallback scaffold)" "$(status_of "$d" beta)" "proposed"
has "…with the four shape sections" "$(cat "$d/.codepress/product/galleys/beta/galley.md")" "## Acceptance Criteria"

# ── allowed edges ─────────────────────────────────────────────────────────────

d=$(mk_project)
mk_galley "$d" alpha proposed
cp_run "$d" galley move alpha building
eq "proposed -> building is refused" "$RC" "1"
has "…naming the illegal transition" "$OUT" "illegal transition proposed -> building"
has "…and what is allowed" "$OUT" "allowed from proposed: shaped, killed, superseded"
eq "…leaving the status untouched" "$(status_of "$d" alpha)" "proposed"

d=$(mk_project)
mk_galley "$d" alpha proposed
cp_run "$d" galley move alpha shaped
eq "proposed -> shaped succeeds when the shape is complete" "$RC" "0"
eq "…and writes the new status" "$(status_of "$d" alpha)" "shaped"

d=$(mk_project)
mkdir -p "$d/.codepress/product/galleys/alpha"
printf -- '---\nid: alpha\nstatus: proposed\ncreated: 2026-10-01\n---\n\n# Galley: alpha\n\n## Problem\nx\n' > "$d/.codepress/product/galleys/alpha/galley.md"
cp_run "$d" galley move alpha shaped
eq "proposed -> shaped is refused while sections are missing" "$RC" "1"
has "…naming them" "$OUT" "lacks sections: Success, Approach, Acceptance Criteria"

d=$(mk_project)
mk_galley "$d" alpha shaped
cp_run "$d" galley move alpha shaped
eq "moving to the current status is a no-op, not an error" "$RC" "0"

d=$(mk_project)
mk_galley "$d" alpha shaped
cp_run "$d" galley move alpha bogus
eq "an unknown target status is refused" "$RC" "1"
has "…listing valid ones" "$OUT" "proposed shaped building verifying done killed superseded"

d=$(mk_project)
mk_galley "$d" alpha shaped
cp_run "$d" galley move alpha review
eq "a retired target on a canonical galley is refused" "$RC" "1"
has "…with the canonical replacement" "$OUT" "use 'verifying'"

# ── approve ───────────────────────────────────────────────────────────────────

d=$(mk_project)
mk_galley "$d" alpha proposed
cp_run "$d" galley approve alpha
eq "approving an unshaped galley is refused" "$RC" "1"
has "…telling you to shape first" "$OUT" "Shape it first"

d=$(mk_project)
mkdir -p "$d/.codepress/product/galleys/alpha"
printf -- '---\nid: alpha\nstatus: shaped\ncreated: 2026-10-01\n---\n\n# Galley: alpha\n' > "$d/.codepress/product/galleys/alpha/galley.md"
cp_run "$d" galley approve alpha
eq "approving an incomplete shape is refused" "$RC" "1"

d=$(mk_project)
mk_galley "$d" alpha shaped
cp_run "$d" galley approve alpha --by "Marv G"
eq "approve succeeds on a shaped galley" "$RC" "0"
eq "…recording who" "$(field_of "$d" alpha approved_by)" "Marv G"
eq "…and when" "$(field_of "$d" alpha approved_on)" "$(date +%Y-%m-%d)"
eq "…without changing status (approval is a gate, not a status)" "$(status_of "$d" alpha)" "shaped"

d=$(mk_project)
mk_galley "$d" alpha shaped
(cd "$d" && git init -q && git config user.name "Git Person" && git config user.email g@p.test)
cp_run "$d" galley approve alpha
eq "without --by the approver is git's user.name" "$(field_of "$d" alpha approved_by)" "Git Person"

d=$(mk_project)
mk_galley "$d" alpha shaped
cp_run "$d" galley approve alpha --by "odd: name # here"
lint_run "$d" --base none
eq "a name with YAML-significant characters is quoted and still lints" "$RC" "0"

# ── shaped -> building ────────────────────────────────────────────────────────

d=$(mk_project)
mk_galley "$d" alpha shaped
cp_run "$d" galley move alpha building
eq "shaped -> building is refused without approval" "$RC" "1"
has "…naming the approved gate" "$OUT" "approved: not approved"
has "…and the missing split" "$OUT" "slugs_exist: no slugs"
has "…with the fix" "$OUT" "codepress galley approve"

d=$(mk_project)
mk_galley "$d" alpha shaped
mk_slug "$d" alpha s1 open
cp_run "$d" galley approve alpha --by m
cp_run "$d" galley move alpha building
eq "approved + split: shaped -> building succeeds" "$RC" "0"
eq "…status written" "$(status_of "$d" alpha)" "building"
has "…and the board regenerates" "$OUT" "Boards regenerated"
has "…placing the galley in the Delivering column" "$(cat "$d/.codepress/views/galley-board.md")" "alpha"

# ── building -> verifying (static + dynamic gates) ───────────────────────────

d=$(mk_project)
mk_complete_galley "$d" alpha building
mk_slug "$d" alpha s2 building "" "- [ ] AC1 · check: true" ""
cp_run "$d" galley move alpha verifying
eq "building -> verifying is refused while a slug is open" "$RC" "1"
has "…naming it" "$OUT" "s2 (building)"

d=$(mk_project)
mk_complete_galley "$d" alpha building
mk_review "$d" alpha "" "" ""
cp_run "$d" galley move alpha verifying
eq "building -> verifying is refused with no signals" "$RC" "1"
has "…saying why" "$OUT" "no captured Signals"

d=$(mk_project)
mk_complete_galley "$d" alpha building
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02' "- [x] AC1 · check: false"
cp_run "$d" galley move alpha verifying
eq "the dynamic ac_check gate runs: a failing check refuses the move" "$RC" "1"
has "…showing the failing criterion" "$OUT" "AC1"
eq "…status unchanged" "$(status_of "$d" alpha)" "building"

d=$(mk_project)
mk_complete_galley "$d" alpha building
cp_run "$d" galley move alpha verifying
eq "all gates met: building -> verifying succeeds" "$RC" "0"
eq "…status written" "$(status_of "$d" alpha)" "verifying"

# ── verifying -> done ─────────────────────────────────────────────────────────

d=$(mk_project)
mk_complete_galley "$d" alpha verifying
rm "$d/.codepress/product/galleys/alpha/learned.md"
cp_run "$d" galley move alpha done
eq "verifying -> done is refused without learned.md" "$RC" "1"
has "…naming it" "$OUT" "learned.md is missing"

d=$(mk_project)
mk_complete_galley "$d" alpha verifying
mk_review "$d" alpha "- sig" "- proof" $'AC1: pass — ok\nverified-by: opencode\nverified-on: 2026-10-08'
cp_run "$d" galley move alpha done
eq "verifying -> done is refused when the builder verdicts its own work" "$RC" "1"
has "…naming the rule" "$OUT" "equals engines.build"

d=$(mk_project)
mk_complete_galley "$d" alpha verifying
cp_run "$d" galley move alpha done
eq "verifying -> done succeeds with evidence, independent verdict and learned.md" "$RC" "0"
eq "…status written" "$(status_of "$d" alpha)" "done"
lint_run "$d" --base none
eq "…and the result lints clean" "$RC" "0"

d=$(mk_project)
mk_complete_galley "$d" alpha done
cp_run "$d" galley move alpha building
eq "done is terminal: nothing leaves it" "$RC" "1"
has "…saying so" "$OUT" "(none — terminal)"

# ── killed / superseded ───────────────────────────────────────────────────────

d=$(mk_project)
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
cp_run "$d" galley move alpha killed
eq "killing a galley without a reason is refused" "$RC" "1"
has "…asking for one" "$OUT" "closed_reason is not set"

d=$(mk_project)
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
cp_run "$d" galley move alpha killed --reason "customer dropped the requirement: not needed"
eq "killing with --reason succeeds" "$RC" "0"
eq "…status written" "$(status_of "$d" alpha)" "killed"
lint_run "$d" --base none
eq "…the (colon-bearing) reason is quoted and lints clean" "$RC" "0"

d=$(mk_project)
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
cp_run "$d" galley move alpha superseded
eq "superseding without superseded_by is refused" "$RC" "1"

d=$(mk_project)
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
mk_galley "$d" beta shaped
cp_run "$d" galley move alpha superseded --superseded-by beta
eq "superseding with --superseded-by succeeds" "$RC" "0"
eq "…recording the successor" "$(field_of "$d" alpha superseded_by)" "beta"
lint_run "$d" --base none
eq "…and lints clean" "$RC" "0"

d=$(mk_project)
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
cp_run "$d" galley move alpha superseded --superseded-by ghost
eq "superseding by a galley that does not exist is refused" "$RC" "1"

# ── rework and replanning leave a trace ───────────────────────────────────────

d=$(mk_project)
mk_complete_galley "$d" alpha verifying
cp_run "$d" galley move alpha building
eq "sending a galley back from verifying needs a plan-change entry" "$RC" "1"
has "…naming the gate" "$OUT" "plan-changes.md is missing"
printf '# Plan changes: alpha\n\n## 2026-10-08 — rework\n- **Plan said:** done\n- **Changed:** reopen\n- **Why:** hole found\n' > "$d/.codepress/product/galleys/alpha/plan-changes.md"
cp_run "$d" galley move alpha building
eq "…and succeeds once logged" "$RC" "0"

# ── waivers ───────────────────────────────────────────────────────────────────

d=$(mk_project)
mk_galley "$d" alpha shaped
mk_git "$d"
cp_run "$d" galley move alpha done --force --reason "hotfix, reviewed live"
eq "--force overrides an illegal, ungated move" "$RC" "0"
eq "…writing the status" "$(status_of "$d" alpha)" "done"
has "…and recording a dated waiver in review.md" "$(cat "$d/.codepress/product/galleys/alpha/review.md")" "shaped→done by human — hotfix, reviewed live"
lint_run "$d"
eq "…which lint honours: the waived gates are warnings, so the commit needs no --no-verify" "$RC" "0"
has "…and they are labelled waived" "$OUT" "(waived)"

d=$(mk_project)
mk_complete_galley "$d" alpha verifying
cp_run "$d" galley move alpha done --force
lacks "--force on a move whose gates pass leaves no waiver noise" "$(cat "$d/.codepress/product/galleys/alpha/review.md")" "waived"

# ── legacy vocabulary keeps the old gates ─────────────────────────────────────

d=$(mk_project)
mk_galley "$d" alpha delivering
cp_run "$d" galley move alpha review
eq "a galley on a retired status is governed by the legacy gates (no signals -> refused)" "$RC" "1"
has "…with the legacy message" "$OUT" "## Signals"

d=$(mk_project)
mk_galley "$d" alpha shaping
cp_run "$d" galley move alpha approved
eq "legacy moves between retired statuses stay ungated" "$RC" "0"
eq "…writing the status the user typed" "$(status_of "$d" alpha)" "approved"

# ── pending actions understand both vocabularies ──────────────────────────────

d=$(mk_project)
mk_galley "$d" alpha shaped $'approved_by: m\napproved_on: 2026-10-02'
cp_run "$d" status
has "an approved, unsplit shaped galley needs splitting" "$OUT" "split-galley"

d=$(mk_project)
mk_galley "$d" alpha shaped
cp_run "$d" status
lacks "an unapproved shaped galley does not" "$OUT" "split-galley"

d=$(mk_project)
mk_complete_galley "$d" alpha building
cp_run "$d" status
has "a building galley with every slug settled is ready for review" "$OUT" "ready for review"

d=$(mk_project)
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
mk_slug "$d" alpha s1 dropped
cp_run "$d" status
has "a dropped slug counts as settled" "$OUT" "ready for review"

d=$(mk_project)
mk_complete_galley "$d" alpha verifying
cp_run "$d" status
has "a verifying galley is ready to release and learn" "$OUT" "release+learn"

summary
