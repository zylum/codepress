#!/usr/bin/env bash
# `codepress status --json --galleys`: per-galley state for views and other
# tools — canonical status, slug progress, last activity (commits that NAME the
# galley count), stalled flag, next action, and who it needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# jq-less field access: gj <json> <galley-dir> <python-expr over row r>
gj() {
  printf '%s' "$1" | python3 -c '
import json, sys
rows = {r["dir"]: r for r in json.load(sys.stdin)["galleys"]}
r = rows[sys.argv[1]]
print(eval(sys.argv[2]))' "$2" "$3"
}

d=$(mk_project)
mk_galley "$d" g-shaped shaped
mk_galley "$d" g-shaped-split shaped
mk_slug "$d" g-shaped-split s1 open
mk_galley "$d" g-confirm building $'approved_by: m\napproved_on: 2026-10-02'
mk_slug "$d" g-confirm s1 open "autonomy: confirm" "- [ ] AC1 · check: true" ""
mk_galley "$d" g-auto building $'approved_by: m\napproved_on: 2026-10-02'
mk_slug "$d" g-auto s1 open "autonomy: continuous" "- [ ] AC1 · check: true" ""
mk_slug "$d" g-auto s2 closed
mk_complete_galley "$d" g-settled building
mk_complete_galley "$d" g-verify verifying
mk_review "$d" g-verify "- sig" "- proof" ""
mk_galley "$d" g-done done "legacy: true"
mk_galley "$d" g-old delivering
mk_git "$d"

cp_run "$d" status --json --galleys
eq "status --json --galleys exits 0" "$RC" "0"
J="$OUT"
valid=$(printf '%s' "$J" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(sorted(d))')
eq "…and is valid JSON with galleys and summary" "$valid" "['galleys', 'generated', 'summary']"

eq "a retired raw status is reported as its canonical form" "$(gj "$J" g-old 'r["status"]')" "building"
eq "…flagged as retired" "$(gj "$J" g-old 'r["retired_status"]')" "True"
eq "…keeping the raw value" "$(gj "$J" g-old 'r["raw_status"]')" "delivering"
eq "canonical statuses are not flagged" "$(gj "$J" g-shaped 'r["retired_status"]')" "False"
eq "legacy terminal galleys are marked legacy" "$(gj "$J" g-done 'r["legacy"]')" "True"

eq "slug counts: open + closed" "$(gj "$J" g-auto 'r["slugs"]["open"], r["slugs"]["closed"], r["slugs"]["total"]')" "(1, 1, 2)"
eq "acceptance counts" "$(gj "$J" g-settled 'r["acceptance"]["total"], r["acceptance"]["ticked"]')" "(1, 1)"

# who it needs --------------------------------------------------------------
eq "shaped but unapproved: a human must approve" "$(gj "$J" g-shaped 'r["needs"]')" "human"
eq "shaped, split, unapproved: a human must approve" "$(gj "$J" g-shaped-split 'r["needs"]')" "human"
has "…and the next action says which command" "$(gj "$J" g-shaped-split 'r["next_action"]')" "codepress galley approve g-shaped-split"
eq "a confirm-autonomy slug needs a human" "$(gj "$J" g-confirm 'r["needs"]')" "human"
has "…naming the slug" "$(gj "$J" g-confirm 'r["next_action"]')" "Deliver slug s1"
eq "a continuous slug needs only an agent" "$(gj "$J" g-auto 'r["needs"]')" "agent"
eq "all slugs settled: next is verifying, for an agent" "$(gj "$J" g-settled 'r["needs"]')" "agent"
has "…suggesting the check first" "$(gj "$J" g-settled 'r["next_action"]')" "codepress check g-settled"
eq "verifying without a verdict needs the verifier" "$(gj "$J" g-verify 'r["needs"]')" "verifier"
eq "terminal galleys need no one" "$(gj "$J" g-done 'r["needs"]')" "none"
eq "…and have no next action" "$(gj "$J" g-done 'r["next_action"]')" "None"
has "blocked_by lists the unmet gates of the next transition" "$(gj "$J" g-shaped 'r["blocked_by"]')" "approved"

needs=$(printf '%s' "$J" | python3 -c 'import json,sys; print(json.load(sys.stdin)["summary"]["needs_human"])')
eq "the summary counts galleys that need a human" "$needs" "3"

# last activity counts commits that NAME the galley -----------------------------
d=$(mk_project)
mk_complete_galley "$d" quiet building
mk_complete_galley "$d" named building
mk_complete_galley "$d" stale building
mk_git "$d"
commit_all "$d" "chore: old housekeeping" "2026-01-01T12:00:00"
# code commits that never touch the galley folders but name the galleys:
mkdir -p "$d/src"; echo 1 > "$d/src/a.py"
commit_all "$d" "slug:s1 done — implement named things in src (named)" ""
echo 2 > "$d/src/b.py"
commit_all "$d" "galley:named: wire things up" ""

cp_run "$d" status --json --galleys --stalled-after 14
J="$OUT"
named=$(gj "$J" named 'r["days_since_activity"]')
eq "a galley named in recent commit messages is active (0 days)" "$named" "0"
eq "…and not stalled" "$(gj "$J" named 'r["stalled"]')" "False"
# 'quiet' and 'stale' only appear in the folder-touching init commit, made today
eq "a galley only touched by today's init commit is also recent" "$(gj "$J" quiet 'r["stalled"]')" "False"

# now an old galley: backdate everything and add a commit naming only 'named'
d=$(mk_project)
mk_complete_galley "$d" named building
mk_complete_galley "$d" forgotten building
(cd "$d" && git init -q && git config user.email t@e.com && git config user.name T && git add -A && GIT_AUTHOR_DATE="2026-01-01T12:00:00" GIT_COMMITTER_DATE="2026-01-01T12:00:00" git commit -q -m "init")
mkdir -p "$d/src"; echo 1 > "$d/src/a.py"
commit_all "$d" "feature work for named: wire it" ""
cp_run "$d" status --json --galleys --stalled-after 14
J="$OUT"
eq "a galley named only in a code commit is NOT stalled" "$(gj "$J" named 'r["stalled"]')" "False"
eq "…while an untouched one is stalled" "$(gj "$J" forgotten 'r["stalled"]')" "True"
eq "…with its last activity from the old commit" "$(gj "$J" forgotten 'r["last_activity"][:10]')" "2026-01-01"
st=$(printf '%s' "$J" | python3 -c 'import json,sys; print(json.load(sys.stdin)["summary"]["stalled"])')
eq "the summary counts stalled galleys" "$st" "1"

# a bulk migration commit is not activity ---------------------------------------
d=$(mk_project)
(cd "$d" && git init -q && git config user.email t@e.com && git config user.name T)
for i in $(seq 1 12); do
  mk_complete_galley "$d" "g$i" building
  commit_all "$d" "add g$i" "2026-01-01T12:00:00"
done
for i in $(seq 1 12); do echo "" >> "$d/.codepress/product/galleys/g$i/galley.md"; done
commit_all "$d" "codepress: migrate statuses"
cp_run "$d" status --json --galleys --stalled-after 14
eq "a commit touching a dozen galleys at once is not activity" "$(gj "$OUT" g3 'r["last_activity"][:10]')" "2026-01-01"
eq "…so they still read as stalled" "$(gj "$OUT" g3 'r["stalled"]')" "True"

# the existing pending-action JSON is unchanged ---------------------------------
d=$(mk_project)
mk_galley "$d" alpha shaped $'approved_by: m\napproved_on: 2026-10-02'
cp_run "$d" status --json
eq "plain status --json keeps its action|target|message line" "$OUT" "split-galley|alpha|Galley 'alpha' is approved but has no slugs"

# non-git projects still work ---------------------------------------------------
d=$(mk_project); mk_galley "$d" alpha shaped
cp_run "$d" status --json --galleys
eq "a project without git still reports (no activity data)" "$RC" "0"
eq "…last_activity is null" "$(gj "$OUT" alpha 'r["last_activity"]')" "None"

summary
