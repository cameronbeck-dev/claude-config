# Session Memory

Handles reading and writing the shared session log synced via the claude-config repo.

## Session Start

1. Check whether `~/.claude/config/` exists
   - If not, skip — the setup-check will handle cloning it
2. Run: `git -C ~/.claude/config pull --rebase`
3. Read the 10 most recent entries from `~/.claude/config/memory/session-log.md`
4. Use these as passive context only — do not summarise them to the user unless asked

## After Commit and Push

After the project commit and push are complete, write a new session log entry.

**Entry format:**
```
## YYYY-MM-DD HH:MM — [project-name] ([absolute-working-directory])
[One paragraph. What was worked on, what changed, what was committed. Specific enough to be useful months later.]
```

**Steps:**
1. Prepend the new entry directly below the `---` separator in `~/.claude/config/memory/session-log.md`
2. Run: `git -C ~/.claude/config pull --rebase`
3. Run: `git -C ~/.claude/config add memory/session-log.md`
4. Run: `git -C ~/.claude/config commit -m "session: [project-name] [YYYY-MM-DD]"`
5. Run: `git -C ~/.claude/config push`

If the push fails due to a conflict that rebase didn't resolve, report it to the user briefly rather than silently failing.
