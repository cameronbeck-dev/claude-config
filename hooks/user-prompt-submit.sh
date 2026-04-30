#!/usr/bin/env bash
# UserPromptSubmit hook: keeps the orchestration policy fresh in context every turn.
# Stdout is appended to the user's prompt before Claude sees it.
# Phrased as a factual reminder, not a system command, to avoid prompt-injection defenses.

cat <<'EOF'
[orchestration policy — reminder]
Classify this request before acting:
- Trivial (single-file read, explanation, one-line fix, conversation): handle directly.
- Standard (clear, scoped change): dispatch research → implementation → impl-review subagents.
- Complex (multi-file, architectural, ambiguous, security-sensitive): full pipeline including planning and plan-review, ending with final-review.

Subagents live in ~/.claude/agents/ with the model and prompt baked into their frontmatter. Call them via the Agent tool with subagent_type set to: research, planning, plan-review, implementation, impl-review, or final-review. Pass model: only when upgrading per the table in CLAUDE.md.

When in doubt, escalate one tier. Trivial tasks never leave the orchestrator.
EOF

exit 0
