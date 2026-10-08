#!/usr/bin/env bash
# codepress lint — status vocabulary, terminal gates, transitions against git,
# version marker, drift, slug/signal schemas, plan-change log, waivers.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# ── baseline ──────────────────────────────────────────────────────────────────

d=$(mk_project)
mk_galley "$d" alpha shaped
lint_run "$d" --base none
eq "a well-formed shaped galley lints clean" "$RC" "0"
has "…and says PASS" "$OUT" "PASS"

d=$(mk_project)
lint_run "$d" --base none
eq "an empty project lints clean" "$RC" "0"

# ── status vocabulary ─────────────────────────────────────────────────────────

d=$(mk_project)
mk_galley "$d" alpha review
lint_run "$d" --base none
eq "a retired status fails lint" "$RC" "1"
has "…naming the retired value" "$OUT" "retired galley status 'review'"
has "…and what to use instead" "$OUT" "use 'verifying'"

d=$(mk_project)
mk_galley "$d" alpha ready
lint_run "$d" --base none
has "a retired status that implied approval says so" "$OUT" "set approved_by"

d=$(mk_project)
mk_galley "$d" alpha archived
lint_run "$d" --base none
has "archived maps to killed" "$OUT" "use 'killed'"

d=$(mk_project)
mk_galley "$d" alpha complete
lint_run "$d" --base none
has "complete maps to done and grandfathers" "$OUT" "set legacy: true"

d=$(mk_project)
mk_galley "$d" alpha bogus
lint_run "$d" --base none
eq "an unknown status fails" "$RC" "1"
has "…listing the valid ones" "$OUT" "proposed|shaped|building|verifying|done|killed|superseded"

d=$(mk_project)
mkdir -p "$d/.codepress/product/galleys/alpha"
printf -- '---\nid: alpha\ncreated: 2026-10-01\n---\n# Galley: alpha\n' > "$d/.codepress/product/galleys/alpha/galley.md"
lint_run "$d" --base none
eq "a galley with no status fails" "$RC" "1"
has "…saying so" "$OUT" "missing required field 'status'"

d=$(mk_project)
mkdir -p "$d/.codepress/product/galleys/alpha"
printf -- '# Galley: alpha\n' > "$d/.codepress/product/galleys/alpha/galley.md"
lint_run "$d" --base none
has "a galley with no frontmatter fails" "$OUT" "no frontmatter"

d=$(mk_project)
mkdir -p "$d/.codepress/product/galleys/alpha"
printf -- '---\nid: alpha\nstatus: shaped\n\tbad: tab\n---\n' > "$d/.codepress/product/galleys/alpha/galley.md"
lint_run "$d" --base none
has "unparseable frontmatter is reported, not a crash" "$OUT" "cannot parse frontmatter"

# ── galley schema ─────────────────────────────────────────────────────────────

d=$(mk_project)
mk_galley "$d" alpha shaped "created: yesterday"
lint_run "$d" --base none
has "a malformed date is rejected" "$OUT" "'created' must be a date YYYY-MM-DD"

d=$(mk_project)
mk_galley "$d" alpha shaped "holdout: maybe"
lint_run "$d" --base none
has "a non-boolean holdout is rejected" "$OUT" "'holdout' must be true or false"

d=$(mk_project)
mk_galley "$d" alpha shaped "related: [a, b]"$'\n'"custom_field: anything"
lint_run "$d" --base none
eq "unknown fields are allowed" "$RC" "0"

# ── terminal gates: done needs everything ─────────────────────────────────────

d=$(mk_project)
mk_complete_galley "$d" alpha done
lint_run "$d" --base none
eq "a fully evidenced done galley passes" "$RC" "0"

d=$(mk_project)
mk_complete_galley "$d" alpha done
mk_review "$d" alpha "- sig" "" "$VERDICT_OK"
lint_run "$d" --base none
eq "done without evidence fails" "$RC" "1"
has "…naming the evidence gate" "$OUT" "needs evidence"

d=$(mk_project)
mk_complete_galley "$d" alpha done
mk_review "$d" alpha "- sig" "- proof" ""
lint_run "$d" --base none
eq "done without a review verdict fails" "$RC" "1"
has "…naming independent_review" "$OUT" "needs independent_review"

d=$(mk_project)
mk_complete_galley "$d" alpha done
rm "$d/.codepress/product/galleys/alpha/learned.md"
lint_run "$d" --base none
eq "done without learned.md fails" "$RC" "1"
has "…naming learned_md" "$OUT" "needs learned_md: learned.md is missing"

d=$(mk_project)
mk_complete_galley "$d" alpha done
printf '# Learned: alpha\n\n<!-- nothing yet -->\n## What worked\n' > "$d/.codepress/product/galleys/alpha/learned.md"
lint_run "$d" --base none
has "an empty learned.md does not count" "$OUT" "learned.md has no content"

d=$(mk_project)
mk_complete_galley "$d" alpha done
mk_slug "$d" alpha s2 building
lint_run "$d" --base none
eq "done with an unfinished slug fails" "$RC" "1"
has "…naming the slug" "$OUT" "s2 (building)"

d=$(mk_project)
mk_complete_galley "$d" alpha done
mk_slug "$d" alpha s2 dropped
printf '# Plan changes: alpha\n\n## 2026-10-05 — dropped s2\n- **Plan said:** build s2\n- **Changed:** not building it\n- **Why:** out of scope\n' > "$d/.codepress/product/galleys/alpha/plan-changes.md"
lint_run "$d" --base none
eq "done with a dropped slug (logged) passes" "$RC" "0"

d=$(mk_project)
mk_complete_galley "$d" alpha done
mk_galley "$d" alpha done $'approved_by: marv\napproved_on: 2026-10-02' "- [ ] AC1 · check: true"
lint_run "$d" --base none
has "done with an unticked acceptance box fails" "$OUT" "1 acceptance box(es) unticked"

d=$(mk_project)
mk_complete_galley "$d" alpha done
mk_galley "$d" alpha done $'approved_by: marv\napproved_on: 2026-10-02' $'- [x] AC1 · check: true\n- [ ] AC2 · manual: confirm the DNS cutover'
lint_run "$d" --base none
has "an unticked manual step needs the verifier to attest it" "$OUT" "Verdict has no line for AC2"
mk_review "$d" alpha "- sig" "- proof" $'AC1: pass — ok\nAC2: pass — human confirmed in the registrar console\nverified-by: claude\nverified-on: 2026-10-08'
lint_run "$d" --base none
eq "…and with the attestation, an unticked manual step does not block done" "$RC" "0"

d=$(mk_project)
mk_complete_galley "$d" alpha done
mk_review "$d" alpha "- sig" "- proof" $'AC1: pass — ok\nverified-by: opencode\nverified-on: 2026-10-08'
lint_run "$d" --base none
has "a verdict by the builder engine is not independent" "$OUT" "equals engines.build"

d=$(mk_project)
mk_complete_galley "$d" alpha done
mk_review "$d" alpha "- sig" "- proof" $'AC1: fail — broke\nverified-by: claude\nverified-on: 2026-10-08'
lint_run "$d" --base none
has "a failing verdict line fails the gate" "$OUT" "AC1: fail"

d=$(mk_project)
mk_complete_galley "$d" alpha done
mk_review "$d" alpha "- sig" "- proof" $'verified-by: claude\nverified-on: 2026-10-08'
lint_run "$d" --base none
has "a verdict missing an AC line fails" "$OUT" "Verdict has no line for AC1"

d=$(mk_project)
mk_complete_galley "$d" alpha done
mk_galley "$d" alpha done $'approved_by: marv\napproved_on: 2026-10-02' "- [x] AC1 · check: true"
sed -i.bak '/^engines:/,$d' "$d/.codepress/system/codepress.md" && rm "$d/.codepress/system/codepress.md.bak"
mk_review "$d" alpha "- sig" "- proof" $'AC1: pass — ok\nverified-by: claude\nverified-on: 2026-10-08'
lint_run "$d" --base none
has "with no engines block the builder defaults to claude (as the CLI does)" "$OUT" "equals engines.build"

# state gates by status ------------------------------------------------------

d=$(mk_project)
mk_galley "$d" alpha building
lint_run "$d" --base none
eq "building without approval fails" "$RC" "1"
has "…naming approved" "$OUT" "needs approved"
lacks "…but not slugs (a single-unit galley needs none)" "$OUT" "slugs_exist"

d=$(mk_project)
mk_complete_galley "$d" alpha building
lint_run "$d" --base none
eq "building with approval and slugs passes" "$RC" "0"

d=$(mk_project)
mk_complete_galley "$d" alpha verifying
mk_review "$d" alpha "" "- proof" ""
lint_run "$d" --base none
has "verifying with no captured signals fails" "$OUT" "no captured Signals"

d=$(mk_project)
mk_galley "$d" alpha killed
lint_run "$d" --base none
has "killed without a reason fails" "$OUT" "closed_reason is not set"
d=$(mk_project)
mk_galley "$d" alpha killed 'closed_reason: "superseded by events: not needed"'
lint_run "$d" --base none
eq "killed with a (colon-bearing, quoted) reason passes" "$RC" "0"

d=$(mk_project)
mk_galley "$d" alpha superseded
lint_run "$d" --base none
has "superseded without superseded_by fails" "$OUT" "superseded_by is not set"
d=$(mk_project)
mk_galley "$d" alpha superseded "superseded_by: ghost"
lint_run "$d" --base none
has "superseded_by must name a real galley" "$OUT" "'ghost' is not another galley"
d=$(mk_project)
mk_galley "$d" alpha superseded "superseded_by: beta"
mk_galley "$d" beta shaped
lint_run "$d" --base none
eq "superseded_by naming a real galley passes" "$RC" "0"

# ── legacy (grandfathered) terminals ──────────────────────────────────────────

d=$(mk_project)
mk_galley "$d" alpha done "legacy: true"
lint_run "$d" --base none
eq "a legacy done galley is not gated retroactively" "$RC" "0"
has "…and the output says how many are exempt" "$OUT" "1 legacy galley(s) not gated"

d=$(mk_project)
mk_galley "$d" alpha building "legacy: true"
lint_run "$d" --base none
eq "legacy: true cannot exempt a live galley" "$RC" "1"
has "…it warns the flag is ignored" "$OUT" "legacy: true is only honoured on terminal galleys"

# ── transitions against git ───────────────────────────────────────────────────

d=$(mk_project)
mk_complete_galley "$d" alpha shaped
mk_git "$d"
mk_galley "$d" alpha done $'approved_by: marv\napproved_on: 2026-10-02' "- [x] AC1 · check: true"
lint_run "$d"
eq "shaped -> done in one step is an illegal transition" "$RC" "1"
has "…reported as T001" "$OUT" "[T001]"
has "…listing what was allowed" "$OUT" "Allowed from shaped: proposed, building, killed, superseded"

d=$(mk_project)
mk_complete_galley "$d" alpha shaped
mk_git "$d"
mk_complete_galley "$d" alpha building
lint_run "$d"
eq "shaped -> building with its gates met is legal" "$RC" "0"

d=$(mk_project)
mk_galley "$d" alpha shaped
mk_git "$d"
mk_galley "$d" alpha building
lint_run "$d"
eq "shaped -> building without approval fails" "$RC" "1"
has "…as an unmet transition requirement" "$OUT" "shaped -> building needs approved"

d=$(mk_project)
mk_complete_galley "$d" alpha verifying
mk_git "$d"
mk_complete_galley "$d" alpha building
lint_run "$d"
has "verifying -> building (rework) needs a plan-change entry" "$OUT" "needs plan_change_logged"
printf '# Plan changes: alpha\n\n## 2026-10-08 — rework\n- **Plan said:** done\n- **Changed:** back to building\n- **Why:** verifier found a hole\n' > "$d/.codepress/product/galleys/alpha/plan-changes.md"
lint_run "$d"
eq "…and passes once the rework is logged" "$RC" "0"

d=$(mk_project)
mk_galley "$d" alpha killed 'closed_reason: stale'
mk_git "$d"
mk_galley "$d" alpha building $'approved_by: marv\napproved_on: 2026-10-02'
lint_run "$d"
eq "reopening a killed galley is illegal (terminal)" "$RC" "1"
has "…and says there is nowhere to go" "$OUT" "(none — terminal)"

d=$(mk_project)
mk_galley "$d" alpha review
mk_git "$d"
mk_complete_galley "$d" alpha verifying
lint_run "$d"
has "migrating a retired status to its canonical form is not a transition" "$OUT" "PASS"
lacks "…no T001 for the migration" "$OUT" "T001"

d=$(mk_project)
mk_galley "$d" alpha shaped
mk_git "$d"
mk_galley "$d" brand-new building $'approved_by: m\napproved_on: 2026-10-02'
lint_run "$d"
has "a new galley created mid-lifecycle draws a warning" "$OUT" "created at 'building', skipping the lifecycle"

d=$(mk_project)
mk_galley "$d" alpha shaped
lint_run "$d" --base nonexistent-ref
eq "an unknown --base ref is a usage error" "$RC" "2"

d=$(mk_project)
mk_galley "$d" alpha shaped
lint_run "$d"
eq "a non-git project lints fine without transition checks" "$RC" "0"

# waivers ----------------------------------------------------------------------

d=$(mk_project)
mk_galley "$d" alpha shaped
mk_git "$d"
mk_galley "$d" alpha done
printf '\n> waived: 2026-10-08 shaped→done by human — emergency fix, reviewed live\n' >> "$d/.codepress/product/galleys/alpha/review.md"
lint_run "$d"
eq "a recorded waiver downgrades the gate failures to warnings" "$RC" "0"
has "…and the output says waived" "$OUT" "(waived)"

# ── version marker ────────────────────────────────────────────────────────────

d=$(mk_project)
echo "codepress-version: 0.1.0" > "$d/.codepress/system/config.md"
echo "codepress-version: 0.2.0" > "$d/.codepress/system/codepress.md"
lint_run "$d" --base none
eq "a marker that disagrees with itself fails" "$RC" "1"
has "…naming both files and versions" "$OUT" "config.md says 0.1.0"
has "…and the other" "$OUT" "codepress.md says 0.2.0"
has "…as V001" "$OUT" "[V001]"

d=$(mk_project)
echo "codepress-version: $CP_VERSION" > "$d/.codepress/system/config.md"
lint_run "$d" --base none
has "the same marker in two files warns about the duplicate" "$OUT" "[V002]"
eq "…but does not fail" "$RC" "0"

d=$(mk_project)
echo "codepress-version: banana" > "$d/.codepress/system/codepress.md"
lint_run "$d" --base none
has "a marker that is not a version fails" "$OUT" "[V003]"

d=$(mk_project)
echo "codepress-version: 0.0.1" > "$d/.codepress/system/codepress.md"
lint_run "$d" --base none
has "a project behind the CLI is told to upgrade" "$OUT" "Run \`codepress upgrade\`"
eq "…as a warning, not a failure" "$RC" "0"

d=$(mk_project)
lint_run "$d" --base none
lacks "a project on the CLI's version gets no version noise" "$OUT" "V00"

# ── drift ─────────────────────────────────────────────────────────────────────

d=$(mk_project)
mk_complete_galley "$d" alpha building
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
mk_slug "$d" alpha s1 open "" "- [ ] AC1 · check: true" ""
mk_git "$d"
commit_all "$d" "slug:s1 done — shipped it"
lint_run "$d"
eq "a slug commit with unticked boxes is drift (error)" "$RC" "1"
has "…reported as D002 with the commit" "$OUT" "[D002]"
has "…naming the slug" "$OUT" "slug:s1 done landed"

d=$(mk_project)
mk_complete_galley "$d" alpha building
mk_slug "$d" alpha s1 closed "" "- [ ] AC1 · check: true"
mk_git "$d"
lint_run "$d" --base none
eq "a closed slug with unticked boxes fails" "$RC" "1"
has "…as D001" "$OUT" "[D001]"

d=$(mk_project)
mk_complete_galley "$d" alpha building
mk_slug "$d" alpha s1 open "" "- [x] AC1 · check: true" ""
mk_git "$d"
commit_all "$d" "slug:s1 done — shipped it"
lint_run "$d"
has "a slug commit on a fully ticked but still-open slug asks to close it" "$OUT" "[D003]"
eq "…as a warning" "$RC" "0"

d=$(mk_project)
mk_galley "$d" alpha shaped
mk_slug "$d" alpha s1 open "" "- [ ] AC1 · check: true" ""
mk_git "$d"
commit_all "$d" "slug:s1 done — shipped it"
lint_run "$d"
has "slug commits on a still-shaped galley: status is lying" "$OUT" "[D004]"

d=$(mk_project)
mk_galley "$d" alpha shaped "" "- [x] AC1 · check: true"
lint_run "$d" --base none
has "ticked boxes on a still-shaped galley are noticed" "$OUT" "[D005]"

d=$(mk_project)
mk_complete_galley "$d" alpha building
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02' "- [ ] AC1 · check: true"
lint_run "$d" --base none
has "every slug settled but galley boxes unticked: D006" "$OUT" "[D006]"

d=$(mk_project)
mk_galley "$d" alpha done "legacy: true"
mk_slug "$d" alpha s1 closed "" "- [ ] AC1 · check: true"
lint_run "$d" --base none
eq "legacy galleys' drift never fails lint" "$RC" "0"
lint_run "$d" --base none --verbose
has "…but --verbose shows it" "$OUT" "slug is closed but 1 acceptance box(es) unticked"

# ── slugs ─────────────────────────────────────────────────────────────────────

d=$(mk_project)
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
mk_slug "$d" alpha s1 open $'domain: billing\ntier: mechanical\nrisk: low\nneeds_review: true\nescalate_after: 3\nautonomy: confirm\ndepends_on: []'
lint_run "$d" --base none
eq "a slug using every delegation field validly passes" "$RC" "0"

for bad in "tier: genius" "risk: extreme" "needs_review: sometimes" "escalate_after: -1" "escalate_after: many" "autonomy: yolo"; do
  d=$(mk_project)
  mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
  mk_slug "$d" alpha s1 open "$bad"
  lint_run "$d" --base none
  if [[ "$RC" -eq 1 ]] && echo "$OUT" | grep -q "S004"; then pass "slug field rejected: $bad"; else fail "slug field rejected: $bad"; echo "$OUT"; fi
done

d=$(mk_project)
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
mk_slug "$d" alpha s1 complete
lint_run "$d" --base none
has "a retired slug status fails" "$OUT" "retired slug status 'complete' — use 'closed'"

d=$(mk_project)
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
mk_slug "$d" alpha s1 open
mk_slug "$d" other s9 open 2>/dev/null || { mkdir -p "$d/.codepress/product/galleys/alpha/slugs"; }
sed -i.bak 's/^galley: alpha/galley: elsewhere/' "$d/.codepress/product/galleys/alpha/slugs/s1.md" && rm "$d/.codepress/product/galleys/alpha/slugs/s1.md.bak"
lint_run "$d" --base none
has "a slug claiming a different galley fails" "$OUT" "galley: 'elsewhere' but the slug lives in alpha"

d=$(mk_project)
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
mk_slug "$d" alpha s1 open
cp "$d/.codepress/product/galleys/alpha/slugs/s1.md" "$d/.codepress/product/galleys/alpha/slugs/s1-copy.md"
lint_run "$d" --base none
has "duplicate slug ids fail" "$OUT" "duplicate slug id 's1'"

d=$(mk_project)
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
mk_slug "$d" alpha s1 open "depends_on: [ghost]"
lint_run "$d" --base none
has "depends_on naming a missing slug fails" "$OUT" "depends_on names unknown slug 'ghost'"

d=$(mk_project)
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
mk_slug "$d" alpha s1 closed "" "- [x] AC1 · check: true" ""
lint_run "$d" --base none
has "a closed slug with no Evidence draws a warning" "$OUT" "slug is closed but has no Evidence"

d=$(mk_project)
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
mk_slug "$d" alpha s1 closed
mk_git "$d"
mk_slug "$d" alpha s1 building
lint_run "$d"
eq "closed -> building for a slug is a legal reopen" "$RC" "0"
mk_slug "$d" alpha s1 open
mk_git "$d" 2>/dev/null || true
commit_all "$d" "x"
mk_slug "$d" alpha s1 closed
commit_all "$d" "y"
mk_slug "$d" alpha s1 dropped
lint_run "$d"
has "closed -> dropped for a slug is illegal" "$OUT" "[T004]"

# ── plan-change log ───────────────────────────────────────────────────────────

d=$(mk_project)
mk_galley "$d" alpha shaped
printf '# Plan changes: alpha\n\n## 2026-10-08 — thing\n- **Plan said:** a\n- **Changed:** b\n' > "$d/.codepress/product/galleys/alpha/plan-changes.md"
lint_run "$d" --base none
eq "a plan-change entry missing Why fails" "$RC" "1"
has "…saying what is missing" "$OUT" "is missing: Why"

d=$(mk_project)
mk_galley "$d" alpha shaped
printf '# Plan changes: alpha\n\n## 2026-10 — vague date\n- **Plan said:** a\n' > "$d/.codepress/product/galleys/alpha/plan-changes.md"
lint_run "$d" --base none
has "a malformed entry heading fails" "$OUT" "malformed entry heading"

d=$(mk_project)
mk_galley "$d" alpha shaped
printf '# Plan changes: alpha\n\nNotes.\n\n## Background\njust prose\n\n## 2026-10-08 — real\n- **Plan said:** a\n  continued on the next line\n- **Changed:** b\n- Why: c\n- **Affects:** s1\n' > "$d/.codepress/product/galleys/alpha/plan-changes.md"
lint_run "$d" --base none
eq "well-formed entries (wrapped lines, bare labels, other headings) pass" "$RC" "0"

d=$(mk_project)
mk_galley "$d" alpha shaped
printf '# Plan changes: alpha\n\n<!--\n## 2026-10-08 — example in a comment\n- **Plan said:** x\n-->\n' > "$d/.codepress/product/galleys/alpha/plan-changes.md"
lint_run "$d" --base none
eq "the template's commented example is not parsed as an entry" "$RC" "0"

d=$(mk_project)
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
mk_slug "$d" alpha s1 dropped
lint_run "$d" --base none
has "dropping a slug without logging why draws a warning" "$OUT" "[P003]"
printf '# Plan changes: alpha\n\n## 2026-10-08 — dropped s1\n- **Plan said:** build it\n- **Changed:** no\n- **Why:** not needed\n' > "$d/.codepress/product/galleys/alpha/plan-changes.md"
lint_run "$d" --base none
lacks "…and not once it is logged" "$OUT" "P003"

# ── structured signals ────────────────────────────────────────────────────────

sig() {
  # sig <dir> <file> <frontmatter-lines>
  mkdir -p "$1/.codepress/knowledge/signals"
  { echo "---"; echo "record: signal"; printf '%s\n' "$3"; echo "---"; echo "# Signal"; } > "$1/.codepress/knowledge/signals/$2"
}
SIG_OK=$'id: sig-1\ncreated: 2026-10-08\nfailure_class: silent-failure\ncaught_by: review\nshould_have_been_caught_by: lint\naction: new-gate\nstatus: open'

d=$(mk_project)
sig "$d" "2026-10-08-a.md" "$SIG_OK"
lint_run "$d" --base none
eq "a complete structured signal passes" "$RC" "0"
has "…and is counted" "$OUT" "1 structured signals"

d=$(mk_project)
sig "$d" "2026-10-08-a.md" $'id: sig-1\ncreated: 2026-10-08\nstatus: open'
lint_run "$d" --base none
eq "a signal missing failure_class/caught_by/etc fails" "$RC" "1"
has "…naming failure_class" "$OUT" "missing required field 'failure_class'"
has "…and should_have_been_caught_by" "$OUT" "missing required field 'should_have_been_caught_by'"
has "…and action" "$OUT" "missing required field 'action'"

d=$(mk_project)
sig "$d" "2026-10-08-a.md" "${SIG_OK/new-gate/ignore}"
lint_run "$d" --base none
has "an action outside new-gate|pattern|accepted-risk fails" "$OUT" "must be one of new-gate|pattern|accepted-risk"

d=$(mk_project)
sig "$d" "2026-10-08-a.md" "${SIG_OK/new-gate/accepted-risk}"
lint_run "$d" --base none
has "accepted-risk needs a risk_note" "$OUT" "'risk_note' is required when action is accepted-risk"

d=$(mk_project)
sig "$d" "2026-10-08-a.md" "${SIG_OK/status: open/status: resolved}"
lint_run "$d" --base none
has "a resolved signal needs resolved_by" "$OUT" "missing required field 'resolved_by'"

d=$(mk_project)
sig "$d" "2026-10-08-a.md" "$SIG_OK"
sig "$d" "2026-10-08-b.md" "$SIG_OK"
lint_run "$d" --base none
has "duplicate signal ids fail" "$OUT" "duplicate signal id 'sig-1'"

d=$(mk_project)
printf -- '---\nid: sig-001\ntype: external\ntags: [a]\n---\n# prose note\n' > "$d/.codepress/knowledge/signals/2026-06-13-note.md"
lint_run "$d" --base none
eq "legacy prose signal notes (no record: signal) are left alone" "$RC" "0"

d=$(mk_project)
mk_complete_galley "$d" alpha done
sig "$d" "2026-10-08-a.md" "$SIG_OK"$'\ngalley: alpha'
lint_run "$d" --base none
has "an open signal on a done galley draws a warning" "$OUT" "[N004]"

d=$(mk_project)
sig "$d" "2026-10-08-a.md" "$SIG_OK"$'\ngalley: ghost'
lint_run "$d" --base none
has "a signal naming a missing galley warns" "$OUT" "[N003]"

# ── adopting the schema on a messy project ────────────────────────────────────

d=$(mk_project)
mk_galley "$d" alpha building $'approved_by: m\napproved_on: 2026-10-02'
mkdir -p "$d/.codepress/product/galleys/alpha/slugs"
printf -- '---\nstatus: open\n---\n## Acceptance checklist\n- [ ] AC1 · check: true\n' > "$d/.codepress/product/galleys/alpha/slugs/no-id-no-galley.md"
printf -- '---\nid: x\n---\n' > "$d/.codepress/product/galleys/alpha/slugs/no-status.md"
printf -- 'just prose, no frontmatter\n' > "$d/.codepress/product/galleys/alpha/slugs/bare.md"
lint_run "$d" --base none
eq "slugs without id or galley are fine (the file and directory say it)" "$RC" "0"
has "a slug without a status is treated as open, with a warning" "$OUT" "[S003]"
has "a slug with no frontmatter at all is a warning, not an error" "$OUT" "[S009]"

d=$(mk_project)
mk_galley "$d" messy building
mk_galley "$d" tidy shaped
mk_git "$d"
mk_galley "$d" tidy shaped "created: 2026-10-02"
lint_run "$d" --changed
eq "--changed judges only the galleys this change touches" "$RC" "0"
lacks "…leaving older mess alone" "$OUT" "messy"
lint_run "$d"
eq "while the full lint still reports it" "$RC" "1"
has "…naming it" "$OUT" "messy"
mk_galley "$d" messy building "created: 2026-10-03"
lint_run "$d" --changed
eq "touching the messy galley makes it answerable" "$RC" "1"

# ── output modes ──────────────────────────────────────────────────────────────

d=$(mk_project)
mk_galley "$d" alpha shaped "" "- [x] AC1 · check: true"
lint_run "$d" --base none
eq "a warning-only project passes" "$RC" "0"
lint_run "$d" --base none --strict
eq "--strict fails on warnings" "$RC" "1"

d=$(mk_project)
mk_galley "$d" alpha review
mk_galley "$d" beta shaped
lint_run "$d" --base none --json
valid=$(printf '%s' "$OUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["ok"], len(d["findings"]) > 0, d["galleys"])')
eq "--json emits parseable JSON" "$valid" "False True 2"
lint_run "$d" --base none --galley beta
eq "--galley limits the run to the named galley" "$RC" "0"
lint_run "$d" --base none --quiet
lacks "--quiet hides warnings" "$OUT" "⚠"

summary
