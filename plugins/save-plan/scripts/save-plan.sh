#!/usr/bin/env bash
set -euo pipefail

# Save a plan file to .aicontext/ with a timestamped, descriptive name
# Usage: save-plan.sh <descriptive-name> <plan-file-path>

if [ $# -lt 2 ]; then
    echo "Usage: save-plan.sh <descriptive-name> <plan-file-path>" >&2
    echo "Example: save-plan.sh auth-refactor ~/.claude/plans/my-plan.md" >&2
    exit 1
fi

DESCRIPTIVE_NAME="$1"
PLAN_FILE="$2"

# Validate plan file exists
if [ ! -f "$PLAN_FILE" ]; then
    echo "Error: Plan file not found: $PLAN_FILE" >&2
    exit 1
fi

# Find git repository root, fall back to home directory
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [ -z "$REPO_ROOT" ]; then
    TARGET_DIR="$HOME/.aicontext"
else
    TARGET_DIR="$REPO_ROOT/.aicontext"
fi

# Create .aicontext directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Generate timestamped filename
DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="$TARGET_DIR/plan-${DATE}-${DESCRIPTIVE_NAME}.md"

# Copy the plan file
cp "$PLAN_FILE" "$OUTPUT_FILE"

echo "Saved to $OUTPUT_FILE"
