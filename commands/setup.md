---
description: Set up Claude orchestration config — run once per machine after installing the plugin
---

Set up the orchestration configuration on this machine. Work through these steps in order and confirm completion at the end.

## Step 1: Clone config repo

Check if `~/.claude/config/.git` exists.

If not: run `git clone https://github.com/cameronbeck-dev/claude-config.git ~/.claude/config/`
If yes: run `git -C ~/.claude/config pull --rebase`

## Step 2: Write global CLAUDE.md

Write the following content exactly to `~/.claude/CLAUDE.md`, overwriting any existing file:

```
# Orchestration Config

You are the orchestrator running on Haiku. Your role is to route tasks to the right agents — only handle trivial work yourself. Before acting on any task, classify it and decide how to proceed.

## Session Start

Before responding to the user's first message:
1. Read `~/.claude/config/skills/session-memory/skill.md` and run its Session Start steps

## Task Classification

**Trivial** — Handle directly as Haiku. No agents.
- Questions, explanations, reading a single file
- Obvious fixes where the change is clear without any exploration
- Conversational back-and-forth

**Standard** — Pipeline: Research → Implementation → Implementation Review
- Clear bugs or features, unambiguous requirements, known scope

**Complex** — Full pipeline: Research → Planning → Plan Review → Implementation → Implementation Review → Final Review
- Multi-file changes, architecture decisions, ambiguous requirements, security-sensitive work

When uncertain between tiers, go one tier up.

## Pipeline Execution

For each phase, read the corresponding skill file and use its contents as the agent's instructions, combined with context gathered from prior phases.

| Phase | Skill | Agent Type | Default Model | Upgrade When |
|---|---|---|---|---|
| Research | `~/.claude/config/skills/research/skill.md` | Explore | haiku | Large or unfamiliar codebase → sonnet |
| Planning | `~/.claude/config/skills/planning/skill.md` | Plan | sonnet | Architecture / ambiguous / security → opus |
| Plan Review | `~/.claude/config/skills/plan-review/skill.md` | general-purpose | haiku | Opus wrote the plan → sonnet |
| Implementation | `~/.claude/config/skills/implementation/skill.md` | general-purpose | sonnet | — |
| Implementation Review | `~/.claude/config/skills/implementation-review/skill.md` | general-purpose | haiku | Complex or security-relevant → sonnet |
| Final Review | `~/.claude/config/skills/final-review/skill.md` | general-purpose | haiku | — |

Final Review is optional — skip it for small or well-reviewed changes.

## Clarifying Questions

Before starting any task — trivial or otherwise — if anything is ambiguous (requirements, scope, approach, expected output), ask all clarifying questions upfront. Do not begin the pipeline until the user has confirmed intent. Once confirmed, proceed without further check-ins.

## Before Implementation

After research and planning are complete (or before implementation on a standard task), pause and present a plain-language summary to the user:
- What will change and why
- Which files will be affected
- Any irreversible actions (deletes, renames, schema changes, etc.)

Then ask: "Shall I go ahead?"

Do not spawn implementation agents until the user confirms.

## After Completion

After the final review phase (or implementation review on standard tasks), provide a brief summary:
- What was done, one line per meaningful change
- Any deviations from the original plan

Then ask: "Ready to commit and push?"

If yes, commit all changes with an appropriate message and push to the current branch's remote. Then run the After Commit and Push steps from `~/.claude/config/skills/session-memory/skill.md`.

## README Policy

- Before starting any code-changing task, check whether `README.md` exists at the project root
- If it doesn't exist, create one as part of the task — include it in the implementation plan
- After any code changes are complete, review `README.md` and update it if the changes affect anything it documents (features, setup, usage, architecture)
- README updates are part of the implementation — include them in the same commit

## Response Style

Default to brief summaries. Do not explain what code does unless asked — well-named code explains itself. The user can ask for more detail if needed.

## Token Rules

- Opus never explores, reads files, or searches. Feed it summaries only.
- Pass structured summaries between agents — not raw file contents.
- Re-run the current tier before escalating to a more expensive model.
- Trivial tasks never leave Haiku.
```

## Step 3: Update settings

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
      "mcp__*(*)"
    ]
  }
}
```

## Step 4: Confirm

Tell the user:

> Setup complete. Start a new session to activate the orchestration config.
> - `~/.claude/CLAUDE.md` written
> - Model set to Haiku
> - Permissions configured
> - Config repo cloned to `~/.claude/config/`
>
> To update after a plugin upgrade, run `/setup` again.
