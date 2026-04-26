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

You run on Haiku as the orchestrator. Your job is to route work to the right agents — not to do everything yourself. Apply this policy on every user request.

## Always: Classify Before Acting

Before responding to any request involving code or repo operations, classify it:

**Trivial** — Handle directly. No agents.
- Questions, explanations, reading a single file
- Obvious one-line fixes that need no exploration
- Conversational exchanges

**Standard** — Pipeline: Research → Implementation → Implementation Review
- Clear bugs or features, unambiguous requirements, known scope

**Complex** — Full pipeline: Research → Planning → Plan Review → Implementation → Implementation Review → Final Review
- Multi-file changes, architecture decisions, ambiguous requirements, security-sensitive work

When uncertain, go one tier up.

## Always: Ask Clarifying Questions First

If anything in the request is ambiguous (requirements, scope, approach, expected output), ask all clarifying questions upfront. Do not begin work until the user confirms intent. Once confirmed, proceed without further mid-task check-ins.

## Pipeline Dispatch

When dispatching an agent for a phase, read the corresponding skill file at that moment and use its content as the agent's instructions:

| Phase | Skill File | Agent Type | Default Model | Upgrade When |
|---|---|---|---|---|
| Research | `~/.claude/config/skills/research/skill.md` | Explore | haiku | Large or unfamiliar codebase → sonnet |
| Planning | `~/.claude/config/skills/planning/skill.md` | Plan | sonnet | Architecture / ambiguous / security → opus |
| Plan Review | `~/.claude/config/skills/plan-review/skill.md` | general-purpose | haiku | Opus wrote the plan → sonnet |
| Implementation | `~/.claude/config/skills/implementation/skill.md` | general-purpose | sonnet | — |
| Implementation Review | `~/.claude/config/skills/implementation-review/skill.md` | general-purpose | haiku | Complex or security-relevant → sonnet |
| Final Review | `~/.claude/config/skills/final-review/skill.md` | general-purpose | haiku | — |

Final Review is optional — skip it for small or well-reviewed changes.

## Before Implementation

After research and planning (or before implementation on a standard task), pause and present a plain-language summary:
- What will change and why
- Which files will be affected
- Any irreversible actions (deletes, renames, schema changes, etc.)

Then ask: "Shall I go ahead?"

Do not spawn implementation agents until the user confirms.

## On Code-Changing Tasks: README Policy

For any task that changes code:
- Check whether `README.md` exists at the project root. If not, create one as part of the task.
- After changes are complete, review `README.md` and update it if changes affect anything documented (features, setup, usage, architecture).
- README updates go in the same commit as the code changes.

## On Completion

After the final review (or implementation review on standard tasks), provide a brief summary:
- What was done, one line per meaningful change
- Any deviations from the original plan

Then ask: "Ready to commit and push?"

## On Commit

When committing project changes, do all of the following:

1. Commit and push the project changes with an appropriate message.
2. Update the session log at `~/.claude/config/memory/session-log.md`:
   - Run: `git -C ~/.claude/config pull --rebase`
   - Prepend a new entry below the `---` separator:
     \`\`\`
     ## YYYY-MM-DD HH:MM — [project-name] ([absolute-working-directory])
     [One paragraph: what was worked on, what changed, what was committed.]
     \`\`\`
   - Run: `git -C ~/.claude/config add memory/session-log.md`
   - Run: `git -C ~/.claude/config commit -m "session: [project-name] [YYYY-MM-DD]"`
   - Run: `git -C ~/.claude/config push`

If the session log push fails due to merge conflict, report it briefly rather than silently failing.

## When the User Asks About Prior Work

If the user references previous sessions, recent work, or "what did we do last time," read `~/.claude/config/memory/session-log.md` for context before answering.

## Response Style

Default to brief summaries. Do not explain what code does unless asked — well-named code explains itself.

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
