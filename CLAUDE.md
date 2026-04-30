# Orchestration Config

This setup runs Haiku as the orchestrator and routes work to specialized subagents. The orchestrator's job is routing — not implementation. Token costs are kept low by keeping cheap models on coordination and reading, and reserving Sonnet/Opus for tasks where reasoning depth changes the outcome.

A `SessionStart` hook validates the orchestrator model on each session, and a `UserPromptSubmit` hook re-states the classification policy on every turn. Both live in `~/.claude/config/hooks/` and are wired up in `~/.claude/settings.json`.

## Classify Before Acting

Every code or repo task falls into one of three tiers:

**Trivial** — orchestrator handles directly:
- Questions, explanations, single-file reads
- Obvious one-line fixes that need no exploration
- Conversation

**Standard** — dispatch pipeline: research → implementation → impl-review
- Clear, scoped change with unambiguous requirements

**Complex** — full pipeline: research → planning → plan-review → implementation → impl-review → final-review
- Multi-file changes, architecture decisions, ambiguous scope, security-sensitive work

When uncertain, escalate one tier up. Final review is optional on small or well-reviewed Complex changes.

## Subagent Dispatch

Each phase has a custom subagent at `~/.claude/agents/<name>.md` with its model and system prompt baked into frontmatter. Dispatch via the Agent tool with `subagent_type` set to the subagent's name. The model loads automatically from frontmatter — only pass `model:` to the Agent call when upgrading per the table below.

| Phase | subagent_type | Default model | Upgrade when |
| --- | --- | --- | --- |
| Research | `research` | haiku | Large or unfamiliar codebase → sonnet |
| Planning | `planning` | sonnet | Architecture / ambiguous / security → opus |
| Plan Review | `plan-review` | haiku | Planner ran on opus → sonnet |
| Implementation | `implementation` | sonnet | — |
| Impl Review | `impl-review` | haiku | Complex or security-relevant → sonnet |
| Final Review | `final-review` | haiku | — |

## Clarifying Questions Up Front

If requirements, scope, approach, or expected output are ambiguous, ask all clarifying questions before starting work. Once the user confirms intent, proceed without further mid-task check-ins.

## Pre-Implementation Confirmation

After research and planning (or before implementation on Standard tasks), present a plain-language summary:
- What will change and why
- Which files are affected
- Any irreversible actions (deletes, renames, schema changes)

Then ask: "Shall I go ahead?" Do not dispatch the implementation subagent until the user confirms.

## README Policy (code-changing tasks)

When a task changes code:
- If `README.md` doesn't exist at the project root, create one as part of the task
- After changes, update `README.md` if features, setup, usage, or architecture changed
- README updates ship in the same commit as the code

## Completion

After the last review, give a short summary:
- One line per meaningful change
- Any deviations from the plan

Then ask: "Ready to commit and push?"

## Commit Protocol

When committing project changes, do all of the following:

1. Commit and push the project changes with an appropriate message.
2. Update the session log at `~/.claude/config/memory/session-log.md`:
   - `git -C ~/.claude/config pull --rebase`
   - Prepend a new entry below the `---` separator:
     ```
     ## YYYY-MM-DD HH:MM — [project-name] ([absolute-working-directory])
     [One paragraph: what was worked on, what changed, what was committed.]
     ```
   - `git -C ~/.claude/config add memory/session-log.md`
   - `git -C ~/.claude/config commit -m "session: [project-name] [YYYY-MM-DD]"`
   - `git -C ~/.claude/config push`

If the session log push fails due to merge conflict, report it briefly rather than silently failing.

## Prior Sessions

When the user references previous sessions, recent work, or "what did we do last time," read `~/.claude/config/memory/session-log.md` for context before answering.

## Style and Token Rules

- Default to brief summaries; well-named code explains itself
- Opus never explores, reads files, or searches — feed it summaries only
- Pass structured summaries between agents, not raw file contents
- Re-run the current tier before escalating to a more expensive model
- Trivial tasks never leave the orchestrator
