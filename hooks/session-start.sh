#!/usr/bin/env bash
# SessionStart hook: validates that the orchestrator model matches the policy.
# Stdout is injected into Claude's context. If everything is fine, stay silent.

set -u

settings="$HOME/.claude/settings.json"
expected="claude-haiku-4-5-20251001"

# Silent if we can't find settings — don't spam every session
if [[ ! -f "$settings" ]]; then
  exit 0
fi

# Pull model field with grep to avoid jq dependency on Windows/Git Bash
current=$(grep -oE '"model"[[:space:]]*:[[:space:]]*"[^"]*"' "$settings" 2>/dev/null \
          | head -1 \
          | sed -E 's/.*"model"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')

if [[ -z "${current:-}" || "$current" != "$expected" ]]; then
  cat <<EOF
[orchestration setup check]
Default model is currently "${current:-not set}". This config expects "$expected" (Haiku 4.5) as the orchestrator so that token-cheap routing decisions stay token-cheap. Running the orchestrator on a larger model defeats the purpose of the pipeline.

To fix: run "/model haiku" or edit ~/.claude/settings.json and set "model": "$expected".
EOF
fi

exit 0
