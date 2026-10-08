#!/usr/bin/env bash
# CodePress holds itself to its own rules.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

RC=0
OUT=$(cd "$REPO_ROOT" && "$CODEPRESS" lint --base none 2>&1) || RC=$?
eq "this repo passes its own lint" "$RC" "0"
lacks "…with no retired statuses anywhere" "$OUT" "retired"

assert "the schema files are self-consistent" python3 "$LINT" check-schema

# CodePress is public and tool-agnostic: the new machinery names no product,
# model or project. (Claude/Codex specifics belong in system/adapters/.)
leaks=$(grep -rniE 'loom|garner|hermes|codex|opencode|claude|gpt|openai' \
  "$REPO_ROOT/.codepress/system/lib" "$REPO_ROOT/.codepress/system/schema" \
  "$REPO_ROOT/.codepress/system/templates/learned.md" \
  "$REPO_ROOT/.codepress/system/templates/plan-changes.md" \
  "$REPO_ROOT/.codepress/system/templates/signal.md" 2>/dev/null || true)
eq "lib/, schema/ and the new templates mention no specific tool or project" "$leaks" ""

# the mapping table in docs/lifecycle.md is the one in lifecycle.yaml, verbatim
table=$(python3 "$LINT" mapping)
if grep -qF -- "$table" "$REPO_ROOT/docs/lifecycle.md"; then pass "docs/lifecycle.md embeds the current legacy mapping table verbatim"; else fail "docs/lifecycle.md embeds the current legacy mapping table verbatim (regenerate with: lint.py mapping)"; fi

# the lifecycle data and its prose cannot silently drift apart
for s in proposed shaped building verifying done killed superseded; do
  has "docs/lifecycle documents status '$s'" "$(cat "$REPO_ROOT/docs/lifecycle.md" 2>/dev/null || true)" "\`$s\`"
done
for g in $(python3 - "$REPO_ROOT" <<'PYEOF'
import os, sys
sys.path.insert(0, os.path.join(sys.argv[1], ".codepress/system/lib"))
import miniyaml
print(" ".join(miniyaml.load(os.path.join(sys.argv[1], ".codepress/system/schema/lifecycle.yaml"))["gates"]))
PYEOF
); do
  has "docs/lifecycle documents gate '$g'" "$(cat "$REPO_ROOT/docs/lifecycle.md" 2>/dev/null || true)" "\`$g\`"
done

summary
