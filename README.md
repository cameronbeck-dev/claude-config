# claude-config

Personal Claude Code orchestration config: Haiku as the orchestrator, with a multi-agent pipeline that routes each phase of work to the right model.

## Layout

```
~/.claude/config/
├── CLAUDE.md              # source-of-truth orchestration policy (synced to ~/.claude/CLAUDE.md by /setup)
├── agents/                # versioned pipeline subagents (copied to ~/.claude/agents/ by /setup)
│   ├── research.md
│   ├── planning.md
│   ├── plan-review.md
│   ├── implementation.md
│   ├── impl-review.md
│   └── final-review.md
├── commands/
│   └── setup.md           # /setup slash command — run once per machine
├── hooks/
│   ├── session-start.sh   # validates orchestrator model on every session
│   └── user-prompt-submit.sh  # injects classification reminder on every turn
├── memory/
│   └── session-log.md     # cross-machine session history
└── skills/
    └── session-memory/    # session-log read/write workflow
```

Claude Code auto-discovers subagents from `~/.claude/agents/`, so they have to be copied out of the config repo to that location. `/setup` does this.

## How it works

The orchestrator (Claude running on Haiku 4.5) classifies every request as Trivial, Standard, or Complex, then dispatches to subagents accordingly:

| Phase | subagent_type | Default model |
| --- | --- | --- |
| Research | `research` | haiku |
| Planning | `planning` | sonnet |
| Plan Review | `plan-review` | haiku |
| Implementation | `implementation` | sonnet |
| Impl Review | `impl-review` | haiku |
| Final Review | `final-review` | haiku |

Each subagent has its model and system prompt baked into frontmatter, so the orchestrator just calls `Agent(subagent_type: "research")` — no file paths to read at dispatch time.

Two hooks enforce the policy without relying on the model voluntarily following instructions:
- **SessionStart** checks the configured model and warns if it isn't Haiku 4.5
- **UserPromptSubmit** injects a short classification reminder before every turn

## Install

After enabling the `claude-orchestration` plugin (via `cameronbeck-dev/claude-marketplace`), run:

```
/setup
```

That clones this repo into `~/.claude/config/`, syncs CLAUDE.md, installs the subagents, makes the hook scripts executable, and writes the required entries into `~/.claude/settings.json`.

Re-run `/setup` after any plugin upgrade to pick up changes.

## Editing the policy

Edit `~/.claude/config/CLAUDE.md` (the source of truth), then `cp ~/.claude/config/CLAUDE.md ~/.claude/CLAUDE.md` to sync the autoloaded copy. `/setup` does this for you.

## Session log

`memory/session-log.md` is appended after each commit-and-push following the protocol in CLAUDE.md. It is the cross-machine record of what was worked on and when.
