#!/bin/bash
# Discovers available tasks from Taskfile.yml and outputs them for Claude context

set -e

# Check if task is installed
if ! command -v task &> /dev/null; then
    echo "Task runner not found. Install with: brew install go-task"
    exit 0
fi

# Check if Taskfile exists
if [[ ! -f "Taskfile.yml" && ! -f "Taskfile.yaml" ]]; then
    exit 0
fi

echo "## Available Tasks"
echo ""
echo "Run tasks with \`task <name>\`. Available tasks:"
echo ""

# Get task list and format as markdown
# Format is: "* taskname:               Description"
task --list 2>/dev/null | tail -n +2 | while read -r line; do
    # Extract task name (everything after * until the colon before spaces)
    # and description (everything after multiple spaces)
    if [[ "$line" =~ ^\*[[:space:]]+(.+):[[:space:]]{2,}(.*)$ ]]; then
        name="${BASH_REMATCH[1]}"
        desc="${BASH_REMATCH[2]}"
        echo "- \`task $name\` - $desc"
    fi
done

echo ""
