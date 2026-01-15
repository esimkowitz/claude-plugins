#!/usr/bin/env bash
set -euo pipefail

# Rename a plan file with the current date while preserving the descriptive name
# Usage: update-plan-date.sh <plan-file-path>

if [[ $# -lt 1 ]]; then
    echo "Usage: update-plan-date.sh <plan-file-path>" >&2
    echo "Example: update-plan-date.sh .aicontext/plan-2025-01-10-auth-refactor.md" >&2
    exit 1
fi

PLAN_FILE="$1"

# Validate plan file exists
if [[ ! -f "$PLAN_FILE" ]]; then
    echo "Error: Plan file not found: $PLAN_FILE" >&2
    exit 1
fi

# Get the directory and filename
DIR=$(dirname "$PLAN_FILE")
FILENAME=$(basename "$PLAN_FILE")

# Extract the descriptive name portion (everything after plan-YYYY-MM-DD-)
# Expected format: plan-YYYY-MM-DD-descriptive-name.md
if [[ ! "$FILENAME" =~ ^plan-[0-9]{4}-[0-9]{2}-[0-9]{2}-(.+)\.md$ ]]; then
    echo "Error: Filename doesn't match expected format: plan-YYYY-MM-DD-<name>.md" >&2
    echo "Got: $FILENAME" >&2
    exit 1
fi

DESCRIPTIVE_NAME="${BASH_REMATCH[1]}"

# Generate new filename with current date
NEW_DATE=$(date +%Y-%m-%d)
NEW_FILENAME="plan-${NEW_DATE}-${DESCRIPTIVE_NAME}.md"
NEW_PATH="$DIR/$NEW_FILENAME"

# If the new path is the same as old, nothing to do
if [[ "$PLAN_FILE" == "$NEW_PATH" ]]; then
    echo "Plan already has today's date: $PLAN_FILE"
    exit 0
fi

# Rename the file
mv "$PLAN_FILE" "$NEW_PATH"

echo "Updated: $NEW_PATH"
echo "(was: $FILENAME)"
