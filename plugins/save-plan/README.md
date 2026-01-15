# save-plan

Save and find plan mode documents for future reference and resumption.

## Features

### Save Plans (`/save-plan`)

Save the current plan mode document to `.aicontext/` with a timestamped, descriptive filename for future reference.

```bash
# Saves to: .aicontext/plan-2026-01-15-auth-session-refactor.md
```

### Find Plans (`/find-plan`)

Search for and resume work on previously saved plans. Searches both filenames and content.

- **Priority search**: Current repo's `.aicontext/` first, then global `~/.aicontext/`
- **Progress tracking**: Updates checkboxes (`- [ ]` → `- [x]`) or appends status annotations
- **Date stamping**: Renames file with current date when work is updated

## Usage

### Saving a Plan

After completing planning work in plan mode:

1. Invoke `/save-plan`
2. Provide a descriptive name (e.g., "auth-session-refactor")
3. Plan is saved to `.aicontext/plan-YYYY-MM-DD-<name>.md`

### Resuming a Plan

When you want to continue previous work:

1. Say "I want to resume working on a plan" or invoke `/find-plan`
2. Provide search terms (e.g., "auth") or list all plans
3. Select the plan to resume
4. Work through items, with progress tracked in the plan file
5. Plan date is updated when work completes

## Plan Storage

Plans are stored in `.aicontext/` directories:

- **Repository**: `<repo-root>/.aicontext/` (project-specific plans)
- **Global**: `~/.aicontext/` (cross-project plans)

## File Format

Plans use timestamped filenames:

```
plan-YYYY-MM-DD-<descriptive-name>.md
```

Example: `plan-2026-01-15-auth-session-refactor.md`
