#!/bin/bash
# check-version-bump.sh - Analyze plugin changes and recommend version bumps
# Called by Stop hook to remind about versioning when plugins are modified

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
VERSION_BUMPS="$REPO_ROOT/.claude-plugin/.version-bumps"

# Get current branch
BRANCH=$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [[ -z "$BRANCH" || "$BRANCH" == "HEAD" ]]; then
    exit 0  # Not on a branch, skip
fi

# Skip if on main
if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
    exit 0
fi

# Check if main branch exists for comparison
if ! git -C "$REPO_ROOT" rev-parse main &>/dev/null; then
    exit 0  # No main branch to compare against
fi

# Get list of modified plugins (comparing to main)
MODIFIED_PLUGINS=$(git -C "$REPO_ROOT" diff main...HEAD --name-only -- plugins/ 2>/dev/null | \
    grep -oE 'plugins/[^/]+' | sort -u | sed 's|plugins/||')

if [[ -z "$MODIFIED_PLUGINS" ]]; then
    exit 0  # No plugin changes
fi

OUTPUT=""

for PLUGIN in $MODIFIED_PLUGINS; do
    PLUGIN_DIR="$REPO_ROOT/plugins/$PLUGIN"

    # Skip if not a valid plugin directory
    if [[ ! -d "$PLUGIN_DIR/.claude-plugin" ]]; then
        continue
    fi

    # Get diff stats for this plugin
    DIFF_OUTPUT=$(git -C "$REPO_ROOT" diff main...HEAD --shortstat -- "plugins/$PLUGIN/" 2>/dev/null)

    # Parse stats: "X files changed, Y insertions(+), Z deletions(-)"
    FILES_CHANGED=$(echo "$DIFF_OUTPUT" | grep -oE '[0-9]+ file' | grep -oE '[0-9]+' || echo "0")
    INSERTIONS=$(echo "$DIFF_OUTPUT" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
    DELETIONS=$(echo "$DIFF_OUTPUT" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo "0")
    TOTAL_LINES=$((INSERTIONS + DELETIONS))

    # Determine recommended bump type based on change size
    if [[ $FILES_CHANGED -gt 20 || $TOTAL_LINES -gt 500 ]]; then
        RECOMMENDED="major"
        JUSTIFICATION="Large-scale changes (${FILES_CHANGED} files, +${INSERTIONS}/-${DELETIONS} lines) suggest breaking changes or major rewrite"
    elif [[ $FILES_CHANGED -ge 5 || $TOTAL_LINES -ge 100 ]]; then
        RECOMMENDED="minor"
        JUSTIFICATION="Significant changes (${FILES_CHANGED} files, +${INSERTIONS}/-${DELETIONS} lines) suggest new functionality"
    else
        RECOMMENDED="patch"
        JUSTIFICATION="Small changes (${FILES_CHANGED} files, +${INSERTIONS}/-${DELETIONS} lines) suggest bug fixes or minor tweaks"
    fi

    # Check if already bumped on this branch
    EXISTING_BUMP=""
    if [[ -f "$VERSION_BUMPS" ]]; then
        EXISTING_BUMP=$(grep "^$BRANCH:$PLUGIN:" "$VERSION_BUMPS" 2>/dev/null | tail -1)
    fi

    if [[ -n "$EXISTING_BUMP" ]]; then
        # Parse existing bump info
        PREV_TYPE=$(echo "$EXISTING_BUMP" | cut -d: -f3)
        PREV_COMMIT=$(echo "$EXISTING_BUMP" | cut -d: -f4)
        PREV_STATS=$(echo "$EXISTING_BUMP" | cut -d: -f5-)

        # Determine if upgrade is justified
        UPGRADE_NEEDED=""
        if [[ "$PREV_TYPE" == "patch" && ("$RECOMMENDED" == "minor" || "$RECOMMENDED" == "major") ]]; then
            UPGRADE_NEEDED="$RECOMMENDED"
        elif [[ "$PREV_TYPE" == "minor" && "$RECOMMENDED" == "major" ]]; then
            UPGRADE_NEEDED="major"
        fi

        if [[ -n "$UPGRADE_NEEDED" ]]; then
            OUTPUT+="Plugin '$PLUGIN' was bumped to $PREV_TYPE at commit $PREV_COMMIT.
Current diff vs main: ${FILES_CHANGED} files, +${INSERTIONS}/-${DELETIONS} lines.
Changes may justify upgrading to $UPGRADE_NEEDED. Consider: task bump:$PLUGIN:$UPGRADE_NEEDED

"
        fi
        # If no upgrade needed, stay silent (already versioned appropriately)
    else
        # No existing bump - recommend one
        OUTPUT+="Plugin '$PLUGIN' modified (${FILES_CHANGED} files, +${INSERTIONS}/-${DELETIONS} vs main).
No version bump recorded for branch '$BRANCH'.
Recommendation: task bump:$PLUGIN:$RECOMMENDED
Justification: $JUSTIFICATION

"
    fi
done

if [[ -n "$OUTPUT" ]]; then
    echo "---"
    echo "VERSION BUMP REMINDER"
    echo "---"
    echo "$OUTPUT"
fi
