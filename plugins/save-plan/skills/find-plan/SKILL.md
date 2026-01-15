---
name: find-plan
description: This skill should be used when the user asks to "resume a plan", "continue a plan", "find a plan", "pick up where I left off", "load my plan", "resume working on", "continue working on", "what plans do I have", "list plans", "show saved plans", "search .aicontext", or wants to continue previous work from a saved planning document. Helps users find and resume work on plans stored in .aicontext/ directories.
---

# Find Plan

Search for and resume work on previously saved plans from `.aicontext/` directories. Plans are searched in the current repository first, with fallback to the global `~/.aicontext/` directory.

## Workflow Overview

1. Search for plans matching user's query
2. Present matches and help select the right plan
3. Load the plan and set up progress tracking
4. Update plan items as work progresses
5. Save with updated timestamp when done

## Step 1: Search for Plans

Run the search script with the user's query (or no query to list all):

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/find-plans.sh "query terms"
```

Or list all available plans:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/find-plans.sh
```

The script searches:
1. **Repository `.aicontext/`** - Plans saved in current git repo (higher priority)
2. **Global `~/.aicontext/`** - Plans saved globally (fallback)

Both filename and content are searched. Present the matches to the user with recommendations based on:
- Recency (newer plans more likely relevant)
- Query match quality (filename matches stronger than content matches)
- Context relevance (if in a specific project, prefer repo plans)

## Step 2: Load Selected Plan

Once the user confirms which plan to resume:

1. Read the full plan file using the Read tool
2. Identify actionable items in the plan (checkboxes, numbered steps, task lists)
3. Create TodoWrite entries for trackable items to maintain visibility

## Step 3: Track Progress

As work progresses on plan items, update the plan file to reflect completion status.

### For Markdown Checkboxes

Convert unchecked to checked:
- `- [ ] Task description` becomes `- [x] Task description`

### For Non-Checkbox Items

Append status annotations:
- `1. Implement auth flow` becomes `1. Implement auth flow - COMPLETED`
- `- Design database schema` becomes `- Design database schema - IN PROGRESS`

Use the Edit tool to make these updates incrementally as each task completes.

## Step 4: Save Updated Plan

When finishing work or pausing the session, update the plan's date to reflect the latest activity:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/update-plan-date.sh ".aicontext/plan-2025-01-10-feature-name.md"
```

This renames the file with the current date while preserving the descriptive name, creating a clear timeline of work:

- `plan-2025-01-10-auth-refactor.md` → `plan-YYYY-MM-DD-auth-refactor.md` (current date)

## Example Session

User says: "I want to pick up where I left off on the auth work"

1. Run search:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/find-plans.sh "auth"
   ```

2. Script outputs matching plans with previews

3. User confirms: "Yes, the auth-session-refactor plan"

4. Read the plan file, create TodoWrite entries for remaining items

5. Work through items, updating checkboxes as completed

6. When pausing or done:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/update-plan-date.sh ".aicontext/plan-2025-12-10-auth-session-refactor.md"
   ```

## Tips

- If no query is provided, list all plans to help user identify what's available
- Recommend the most likely match based on context, but let user confirm
- Update the plan file frequently to preserve progress
- The date update at the end is important for tracking when work last occurred
- Plans in the current repo's `.aicontext/` take priority over global plans
