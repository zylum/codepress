#!/usr/bin/env bash
# The lifecycle as data: statuses, transitions, gates and the legacy mapping
# (.codepress/system/schema/lifecycle.yaml), read through lib/lint.py.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

lp() { python3 "$LINT" "$@"; }

# ── self-consistency ──────────────────────────────────────────────────────────

assert "schema files are self-consistent (check-schema)" lp check-schema

# a broken copy is caught: copy the system dir, corrupt it, expect failure
tmp=$(mktemp -d); CLEANUP+=("$tmp")
cp -r "$REPO_ROOT/.codepress/system" "$tmp/system"
python3 - "$tmp/system/schema/lifecycle.yaml" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p).read()
s = s.replace("    proposed->shaped:\n      requires: [shape_complete]", "    proposed->shaped:\n      requires: [no_such_gate]", 1)
s = s.replace("    review:\n      to: verifying", "    review:\n      to: nowhere", 1)
open(p, "w").write(s)
PYEOF
out=$(python3 "$tmp/system/lib/lint.py" check-schema 2>&1) && rc=0 || rc=$?
eq "check-schema fails on a corrupted lifecycle" "$rc" "1"
has "…naming the unknown gate" "$out" "unknown gate 'no_such_gate'"
has "…and the bad legacy target" "$out" "maps to unknown status 'nowhere'"

# ── statuses ──────────────────────────────────────────────────────────────────

statuses=$(lp table | awk '$1 == "galley" && $4 !~ /retired/ { printf "%s ", $2 }')
eq "galley statuses are exactly the seven canonical ones" "$statuses" "proposed shaped building verifying done killed superseded "
slug_statuses=$(lp table | awk '$1 == "slug" && $4 !~ /retired/ { printf "%s ", $2 }')
eq "slug statuses are open building closed dropped" "$slug_statuses" "open building closed dropped "
terminals=$(lp table | awk '$1 == "galley" && $4 ~ /terminal/ { printf "%s ", $2 }')
eq "done, killed and superseded are terminal" "$terminals" "done killed superseded "

# ── transitions ───────────────────────────────────────────────────────────────

edge_ok()  { lp requires "$1" "$2" >/dev/null 2>&1; }
edge_bad() { ! lp requires "$1" "$2" >/dev/null 2>&1; }

assert "proposed -> shaped is allowed"   edge_ok proposed shaped
assert "shaped -> building is allowed"   edge_ok shaped building
assert "building -> verifying is allowed" edge_ok building verifying
assert "verifying -> done is allowed"    edge_ok verifying done
assert "verifying -> building (rework) is allowed" edge_ok verifying building
assert "any open status can be killed"   edge_ok building killed
assert "any open status can be superseded" edge_ok proposed superseded
assert "proposed -> building skips shaping: illegal" edge_bad proposed building
assert "shaped -> verifying skips building: illegal" edge_bad shaped verifying
assert "building -> done skips verifying: illegal"   edge_bad building done
assert "done is terminal: done -> building illegal"  edge_bad done building
assert "killed is terminal: killed -> proposed illegal" edge_bad killed proposed
assert "superseded is terminal" edge_bad superseded shaped

# ── gates as data ─────────────────────────────────────────────────────────────

req_ids() { lp requires "$1" "$2" | awk '{ printf "%s ", $1 }'; }
req_of() { req_ids "$1" "$2"; }

has "shaped -> building requires approval" "$(req_of shaped building)" "approved"
lacks "a galley need not be split: shaped -> building does not require slugs" "$(req_of shaped building)" "slugs"
has "verifying -> done requires evidence" "$(req_of verifying done)" "evidence"
has "verifying -> done requires an independent review" "$(req_of verifying done)" "independent_review"
has "verifying -> done requires learned.md" "$(req_of verifying done)" "learned_md"
has "building -> verifying requires every slug settled" "$(req_of building verifying)" "slugs_settled"
has "killed requires a reason" "$(req_of building killed)" "reason"
has "superseded requires superseded_by" "$(req_of building superseded)" "superseded_by"
has "rework must be logged in plan-changes" "$(req_of verifying building)" "plan_change_logged"
eq "ac_check is dynamic (run by check, not lint)" "$(lp requires building verifying | awk '$1 == "ac_check" { print $2 }')" "dynamic"
eq "slugs_settled is static (lint can decide it)" "$(lp requires building verifying | awk '$1 == "slugs_settled" { print $2 }')" "static"

# ── legacy mapping (the table Marv approves) ──────────────────────────────────

canon() { lp canon galley "$1" 2>/dev/null || echo "?"; }
eq "draft -> proposed"        "$(canon draft)"      "proposed"
eq "proposed stays proposed"  "$(canon proposed)"   "proposed"
eq "shaping -> proposed"      "$(canon shaping)"    "proposed"
eq "shaped stays shaped"      "$(canon shaped)"     "shaped"
eq "ready -> shaped + approved" "$(canon ready)"    "shaped approved"
eq "approved -> shaped + approved" "$(canon approved)" "shaped approved"
eq "active -> building"       "$(canon active)"     "building"
eq "delivering -> building"   "$(canon delivering)" "building"
eq "rework -> building"       "$(canon rework)"     "building"
eq "review -> verifying"      "$(canon review)"     "verifying"
eq "complete -> done (legacy)" "$(canon complete)"  "done legacy"
eq "delivered -> done (legacy)" "$(canon delivered)" "done legacy"
eq "released -> done (legacy)" "$(canon released)"  "done legacy"
eq "learned -> done (legacy)" "$(canon learned)"    "done legacy"
eq "archived -> killed"       "$(canon archived)"   "killed"
eq "done stays done"          "$(canon done)"       "done"
eq "an unknown value has no canonical form" "$(canon bogus)" "?"

slugc() { lp canon slug "$1" 2>/dev/null || echo "?"; }
eq "slug complete -> closed" "$(slugc complete)" "closed"
eq "slug done -> closed"     "$(slugc done)"     "closed"
eq "slug pending -> open"    "$(slugc pending)"  "open"
eq "slug in-progress -> building" "$(slugc in-progress)" "building"
eq "slug skipped -> dropped" "$(slugc skipped)"  "dropped"

table=$(lp mapping)
has "the mapping table documents review -> verifying" "$table" '| galley | `review` | `verifying` |'
has "…and flags judgment calls for a human" "$table" "**judgment call**"
has "…and marks grandfathered terminals" "$table" "legacy: true"

# ── field schemas ─────────────────────────────────────────────────────────────

for f in galley slug signal; do
  assert "$f.schema.yaml parses" python3 -c "
import sys; sys.path.insert(0, '$REPO_ROOT/.codepress/system/lib')
import miniyaml; d = miniyaml.load('$REPO_ROOT/.codepress/system/schema/$f.schema.yaml'); assert d['fields']"
done

slug_fields=$(python3 - "$REPO_ROOT" <<'PYEOF'
import os, sys
sys.path.insert(0, os.path.join(sys.argv[1], ".codepress/system/lib"))
import miniyaml
d = miniyaml.load(os.path.join(sys.argv[1], ".codepress/system/schema/slug.schema.yaml"))
print(" ".join(sorted(d["fields"])))
PYEOF
)
for f in domain tier risk needs_review escalate_after autonomy; do
  has "slug schema defines '$f'" "$slug_fields" "$f"
done

summary
