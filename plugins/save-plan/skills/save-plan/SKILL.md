---
name: save-plan
description: Use when finishing plan mode and you want to preserve the planning document in the repository for future reference
---

# Save Plan

Saves the current plan mode document to `.aicontext/` in the repository root with a timestamped, descriptive filename.

## When to Use

- After completing a plan in plan mode
- When you want to preserve planning context for future sessions
- Before exiting plan mode if the plan contains valuable architectural decisions

## Steps

1. **Get the plan file path** from plan mode context (shown in system message)
2. **Read the plan content** to understand what it covers
3. **Generate a descriptive name** (max 5 words, kebab-case) summarizing the plan
4. **Run the script:**

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/save-plan.sh "<descriptive-name>" "<plan-file-path>"
```

## Example

Given plan file at `~/.claude/plans/iterative-yawning-dahl.md` about refactoring authentication:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/save-plan.sh "auth-session-refactor" ~/.claude/plans/iterative-yawning-dahl.md
```

Output: `Saved to .aicontext/plan-2026-01-14-auth-session-refactor.md`
