#!/usr/bin/env bash
# The whole loop, end to end, on a project made by `codepress init`:
# propose -> shape -> split -> approve -> build -> verify -> learn -> done,
# with `codepress lint` clean at every step and the gates saying no when they should.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

d=$(mktemp -d); CLEANUP+=("$d")
(cd "$d" && git init -q && git config user.email t@e.com && git config user.name Tester)

cp_run "$d" init
eq "init bootstraps a project" "$RC" "0"
assert "…including the lint engine and schema" test -f "$d/.codepress/system/lib/lint.py" -a -f "$d/.codepress/system/schema/lifecycle.yaml"
lint_run "$d"
eq "a fresh project lints clean" "$RC" "0"
(cd "$d" && git add -A && git commit -q -m "bootstrap")

status_of() { sed -n 's/^status: *//p' "$d/.codepress/product/galleys/walk/galley.md" | head -1; }
step() { # step <name> <expected-status> <args...>
  local name="$1" want="$2"; shift 2
  cp_run "$d" "$@"
  if [[ "$RC" -eq 0 && "$(status_of)" == "$want" ]]; then pass "$name"; else fail "$name"; echo "      rc=$RC status=$(status_of) want=$want"; echo "$OUT" | head -12; fi
}
refused() { # refused <name> <args...> — must fail and leave the status alone
  local name="$1"; shift
  local before; before=$(status_of)
  cp_run "$d" "$@"
  if [[ "$RC" -ne 0 && "$(status_of)" == "$before" ]]; then pass "$name"; else fail "$name"; echo "      rc=$RC status=$(status_of)"; echo "$OUT" | head -8; fi
}
lint_ok() { lint_run "$d"; if [[ "$RC" -eq 0 ]]; then pass "lint clean: $1"; else fail "lint clean: $1"; echo "$OUT" | head -15; fi; }

# propose
cp_run "$d" galley new walk
eq "galley new" "$RC" "0"
eq "…starts proposed" "$(status_of)" "proposed"
refused "an empty shape cannot be moved to shaped" galley move walk shaped

# shape
G="$d/.codepress/product/galleys/walk/galley.md"
python3 - "$G" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p).read()
for h, body in (("## Problem", "Things drift."), ("## Success", "They stop drifting."), ("## Approach", "Check them."), ):
    s = s.replace(h + "\n", h + "\n" + body + "\n", 1)
s = s.replace("## Acceptance Criteria\n", "## Acceptance Criteria\n\n- [ ] AC1 · check: true\n", 1)
open(p, "w").write(s)
PYEOF
step "shaping done: proposed -> shaped" shaped galley move walk shaped
lint_ok "shaped"

# split
SL="$d/.codepress/product/galleys/walk/slugs"
mkdir -p "$SL"
cat > "$SL/first.md" <<'EOF'
---
id: first
status: open
galley: walk
autonomy: continuous
tier: build
risk: low
---

# Slug: first

## Acceptance checklist
- [ ] AC1 · check: true

## Evidence
EOF
refused "cannot build before approval" galley move walk building
cp_run "$d" galley approve walk --by Marv
eq "a human approves the shape" "$RC" "0"
step "approved and split: shaped -> building" building galley move walk building
lint_ok "building"
(cd "$d" && git add -A && git commit -q -m "walk: shaped, approved, building")

# build
refused "cannot verify while a slug is open" galley move walk verifying
python3 - "$SL/first.md" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p).read().replace("status: open", "status: closed").replace("- [ ] AC1", "- [x] AC1").replace("## Evidence\n", "## Evidence\nran it, green\n")
open(p, "w").write(s)
PYEOF
python3 - "$G" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p).read().replace("- [ ] AC1", "- [x] AC1")
open(p, "w").write(s)
PYEOF
refused "cannot verify with no Signals captured" galley move walk verifying
R="$d/.codepress/product/galleys/walk/review.md"
python3 - "$R" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p).read().replace("## Signals\n", "## Signals\n- the gate wording mattered more than the gate\n", 1)
open(p, "w").write(s)
PYEOF
step "slugs settled, boxes ticked, signals captured: building -> verifying" verifying galley move walk verifying
(cd "$d" && git add -A && git commit -q -m "slug:first done — built it")
lint_ok "verifying"

# verify + learn
refused "done is refused with no evidence, verdict or learned.md" galley move walk done
python3 - "$R" <<'PYEOF'
import sys, re
p = sys.argv[1]
s = open(p).read()
s = re.sub(r"(?s)## Evidence\n<!--.*?-->\n", "## Evidence\n- commit above; `codepress check walk` green\n", s, count=1)
open(p, "w").write(s)
PYEOF
refused "…still refused with evidence but no independent verdict" galley move walk done
cat >> "$R" <<'EOF'

AC1: pass — ran it fresh
verified-by: reviewer-agent
verified-on: 2026-10-08
EOF
python3 - "$R" <<'PYEOF'
import sys, re
# the template keeps the Verdict example inside an HTML comment; move our lines out of it
p = sys.argv[1]
s = open(p).read()
tail = "\nAC1: pass — ran it fresh\nverified-by: reviewer-agent\nverified-on: 2026-10-08\n"
s = s.replace(tail, "\n")
s = re.sub(r"(?s)(## Verdict\n)<!--.*?-->\n?", r"\1" + tail.lstrip("\n"), s, count=1)
open(p, "w").write(s)
PYEOF
refused "…still refused with a verdict but no learned.md" galley move walk done
cp "$d/.codepress/system/templates/learned.md" "$d/.codepress/product/galleys/walk/learned.md"
refused "…and an empty learned.md template does not count" galley move walk done
printf '\n## What worked\nChecking the gates mechanically caught what review would have missed.\n' >> "$d/.codepress/product/galleys/walk/learned.md"
step "everything in place: verifying -> done" done galley move walk done
(cd "$d" && git add -A && git commit -q -m "galley:walk done")
lint_ok "done"

# terminal
refused "a done galley cannot be reopened" galley move walk building

# and the status view agrees
cp_run "$d" status --json --galleys
row=$(printf '%s' "$OUT" | python3 -c 'import json,sys; r=json.load(sys.stdin)["galleys"][0]; print(r["status"], r["needs"], r["slugs"]["closed"], r["last_activity"] is not None)')
eq "status --json --galleys reports it done, needing no one" "$row" "done none 1 True"

summary
