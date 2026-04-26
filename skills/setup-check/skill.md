# Setup Check

Run this once at the start of each new session, before responding to the user's first message.

## Steps

1. Read `~/.claude/settings.json`
2. Check the value of the `model` field

**If `model` is `claude-haiku-4-5-20251001`:** Pass silently. Do not mention this check to the user.

**If `model` is missing or set to any other value:** Notify the user before proceeding:

> Your default model is currently `[model value, or "not set"]`. This config is designed to use Haiku (`claude-haiku-4-5-20251001`) as the orchestrator to save tokens on routine tasks. Would you like me to update your settings?

**If the user says yes:**
- Write `~/.claude/settings.json`, setting `"model": "claude-haiku-4-5-20251001"` (preserve any other existing fields)
- Confirm the change with a short message, then proceed with their request

**If the user says no:**
- Acknowledge their preference
- Locate this file using Glob: search for `**/setup-check/skill.md` within `~/.claude/`
- Delete it using Bash
- Say: "Got it — I won't ask again. Reinstall the plugin on a new machine to restore this check."
- Proceed with their request
