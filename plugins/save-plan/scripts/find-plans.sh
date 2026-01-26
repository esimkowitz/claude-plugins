#!/usr/bin/env bash
set -eu

# Search for plans matching a query in .aicontext/ directories
# Usage: find-plans.sh [query]
# If no query provided, lists all plans

QUERY="${1:-}"

# Find git repository root, fall back to empty
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")

# Define search locations
REPO_AICONTEXT=""
if [ -n "$REPO_ROOT" ]; then
    REPO_AICONTEXT="$REPO_ROOT/.aicontext"
fi
GLOBAL_AICONTEXT="$HOME/.aicontext"

# Function to search plans in a directory
search_plans() {
    local dir="$1"
    local label="$2"
    local found=0

    if [ ! -d "$dir" ]; then
        return 0
    fi

    # Find all plan files
    local plan_files
    plan_files=$(find "$dir" -maxdepth 1 -name "plan-*.md" -type f 2>/dev/null | sort -r)

    if [ -z "$plan_files" ]; then
        return 0
    fi

    echo "=== $label: $dir ==="
    echo ""

    echo "$plan_files" | while IFS= read -r file; do
        local filename
        filename=$(basename "$file")
        local matched=0
        local match_reason=""

        if [ -z "$QUERY" ]; then
            # No query - list all plans
            matched=1
            match_reason="(listing all)"
        else
            # Check filename match (case insensitive)
            if echo "$filename" | grep -qi "$QUERY"; then
                matched=1
                match_reason="filename matches '$QUERY'"
            fi

            # Check content match if not already matched
            if [ "$matched" -eq 0 ]; then
                if grep -qi "$QUERY" "$file" 2>/dev/null; then
                    matched=1
                    match_reason="content matches '$QUERY'"
                fi
            fi
        fi

        if [ "$matched" -eq 1 ]; then
            found=1
            echo "FILE: $file"
            echo "NAME: $filename"
            if [ -n "$match_reason" ]; then
                echo "MATCH: $match_reason"
            fi

            # Extract date from filename (plan-YYYY-MM-DD-name.md)
            local date_part
            date_part=$(echo "$filename" | sed 's/plan-\([0-9][0-9]*-[0-9][0-9]*-[0-9][0-9]*\)-.*/\1/')
            echo "DATE: $date_part"

            # Show first few lines as preview (skip frontmatter if present)
            echo "PREVIEW:"
            head -n 10 "$file" | sed 's/^/  /'
            echo ""
            echo "---"
            echo ""
        fi
    done

    return $found
}

# Track if we found any plans
found_in_repo=0
found_in_global=0

# Search in repo .aicontext first (higher priority)
if [ -n "$REPO_AICONTEXT" ]; then
    if search_plans "$REPO_AICONTEXT" "REPO"; then
        found_in_repo=1
    fi
fi

# Search in global .aicontext (fallback/additional)
if search_plans "$GLOBAL_AICONTEXT" "GLOBAL"; then
    found_in_global=1
fi

# Report if nothing found
if [ "$found_in_repo" -eq 0 ] && [ "$found_in_global" -eq 0 ]; then
    if [ -z "$QUERY" ]; then
        echo "No plans found in .aicontext directories."
    else
        echo "No plans matching '$QUERY' found."
    fi
    echo ""
    echo "Searched locations:"
    if [ -n "$REPO_AICONTEXT" ]; then
        echo "  - $REPO_AICONTEXT"
    fi
    echo "  - $GLOBAL_AICONTEXT"
    exit 1
fi
