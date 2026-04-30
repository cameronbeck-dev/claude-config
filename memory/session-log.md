# Session Log

Entries are newest first. Each entry is written automatically after a commit and push.

---

## 2026-04-30 19:31 — claude-config (/c/Users/GGPC/.claude/config)
Reviewed and rebuilt the orchestration setup after the user reported the policy wasn't being followed unless explicitly requested. Root causes: settings.json had model=opus instead of haiku (Opus's autonomous-task instinct fights orchestration), the setup-check skill never auto-triggered, the orchestrator was reinventing subagents by referencing skill files by path, and CLAUDE.md was duplicated with no sync. Replaced the indirection with first-class subagents at ~/.claude/agents/ (research, planning, plan-review, implementation, impl-review, final-review) each with model and system prompt baked into frontmatter. Added SessionStart and UserPromptSubmit hooks in hooks/ to enforce the policy deterministically (model check + per-turn classifier reminder). Rewrote CLAUDE.md with factual tone and classification rules top-loaded, made config/CLAUDE.md the source of truth, rewrote /setup to copy from the repo rather than heredoc, added .gitattributes to keep shell scripts LF on Windows, and added a README. New-machine setup is now: clone config repo, run /setup. Committed and pushed as 2af6f64.

## 2026-04-26 — claude-config (/c/Users/GGPC/Documents/programming/claude-config)
Initial build of the claude-config plugin and claude-marketplace repo. Set up Haiku as orchestrator with three-tier task classification (trivial/standard/complex) and a six-phase multi-agent pipeline routing tasks to Haiku/Sonnet/Opus based on complexity. Added behavioral preferences: clarifying-questions-first, pre-implementation plan confirmation, post-completion commit prompt, brief response style. Extended setup-check to verify model and permissions on each new machine. Added session memory with cross-machine sync via this repo.
