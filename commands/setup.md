---
description: Set up Claude orchestration config — run once per machine after installing the plugin (or after a plugin upgrade)
---

Set up the orchestration configuration on this machine. Work through these steps in order and confirm completion at the end.

## Step 1: Clone or update the config repo

Check if `~/.claude/config/.git` exists.

- If not: run `git clone https://github.com/cameronbeck-dev/claude-config.git ~/.claude/config/`
- If yes: run `git -C ~/.claude/config pull --rebase`

## Step 2: Sync CLAUDE.md to the autoloaded location

The source-of-truth lives at `~/.claude/config/CLAUDE.md`. The autoloaded copy at `~/.claude/CLAUDE.md` must match it exactly:

```
cp ~/.claude/config/CLAUDE.md ~/.claude/CLAUDE.md
```

After running this, both files are identical and the policy will be loaded into every session.

## Step 3: Install subagents

The pipeline subagents are versioned in `~/.claude/config/agents/` and must be copied to `~/.claude/agents/` for Claude Code to discover them:

```
mkdir -p ~/.claude/agents
cp ~/.claude/config/agents/*.md ~/.claude/agents/
```

After this, `~/.claude/agents/` should contain: `research.md`, `planning.md`, `plan-review.md`, `implementation.md`, `impl-review.md`, `final-review.md`.

## Step 4: Install hook scripts

Hook scripts live in `~/.claude/config/hooks/`. They are referenced by absolute paths in `settings.json` (Step 5), so they only need to be executable:

```
chmod +x ~/.claude/config/hooks/*.sh
```

## Step 5: Update settings.json

Read `~/.claude/settings.json`. Ensure it contains these fields (preserve all other existing fields):

```json
{
  "model": "claude-haiku-4-5-20251001",
  "permissions": {
    "allow": [
      "Bash(*)",
      "Read(*)",
      "Write(*)",
      "Edit(*)",
      "Glob(*)",
      "Grep(*)",
      "WebFetch(*)",
      "WebSearch(*)",
      "Agent(*)",
      "NotebookEdit(*)",
      "TodoWrite(*)",
      "mcp__*__*"
    ]
  },
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "bash $HOME/.claude/config/hooks/session-start.sh" }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "bash $HOME/.claude/config/hooks/user-prompt-submit.sh" }
        ]
      }
    ]
  }
}
```

## Step 6: Confirm

Tell the user:

> Setup complete. Start a new session to activate the orchestration config.
> - `~/.claude/CLAUDE.md` synced from `~/.claude/config/CLAUDE.md`
> - Subagents installed at `~/.claude/agents/`
> - Hook scripts at `~/.claude/config/hooks/`
> - Model set to Haiku 4.5
> - Permissions and hooks configured in `~/.claude/settings.json`
>
> To update after a plugin upgrade, run `/setup` again.
