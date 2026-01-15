#!/bin/bash
# version-plugin.sh - Bump plugin version in both plugin.json and marketplace.json
# Usage: version-plugin.sh <plugin-name> <bump-type>
# bump-type: major | minor | patch

set -e

PLUGIN_NAME="$1"
BUMP_TYPE="$2"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_JSON="$REPO_ROOT/plugins/$PLUGIN_NAME/.claude-plugin/plugin.json"
MARKETPLACE_JSON="$REPO_ROOT/.claude-plugin/marketplace.json"
VERSION_BUMPS="$REPO_ROOT/.claude-plugin/.version-bumps"

# Validate arguments
if [[ -z "$PLUGIN_NAME" || -z "$BUMP_TYPE" ]]; then
    echo "Usage: version-plugin.sh <plugin-name> <major|minor|patch>" >&2
    exit 1
fi

if [[ ! "$BUMP_TYPE" =~ ^(major|minor|patch)$ ]]; then
    echo "Error: bump-type must be major, minor, or patch" >&2
    exit 1
fi

if [[ ! -f "$PLUGIN_JSON" ]]; then
    echo "Error: Plugin '$PLUGIN_NAME' not found at $PLUGIN_JSON" >&2
    exit 1
fi

# Get current version
CURRENT_VERSION=$(jq -r '.version' "$PLUGIN_JSON")

if [[ -z "$CURRENT_VERSION" || "$CURRENT_VERSION" == "null" ]]; then
    echo "Error: Could not read version from $PLUGIN_JSON" >&2
    exit 1
fi

# Parse semver
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Bump version
case "$BUMP_TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Update plugin.json
jq --arg version "$NEW_VERSION" '.version = $version' "$PLUGIN_JSON" > "$PLUGIN_JSON.tmp"
mv "$PLUGIN_JSON.tmp" "$PLUGIN_JSON"

# Update marketplace.json
jq --arg name "$PLUGIN_NAME" --arg version "$NEW_VERSION" \
    '(.plugins[] | select(.name == $name)).version = $version' \
    "$MARKETPLACE_JSON" > "$MARKETPLACE_JSON.tmp"
mv "$MARKETPLACE_JSON.tmp" "$MARKETPLACE_JSON"

# Record the bump for branch tracking
BRANCH=$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
COMMIT=$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")
DIFF_STATS=$(git -C "$REPO_ROOT" diff main...HEAD --shortstat -- "plugins/$PLUGIN_NAME/" 2>/dev/null || echo "unknown")

# Ensure version-bumps file exists
mkdir -p "$(dirname "$VERSION_BUMPS")"
touch "$VERSION_BUMPS"

# Remove any existing entry for this branch+plugin, then add new one
grep -v "^$BRANCH:$PLUGIN_NAME:" "$VERSION_BUMPS" > "$VERSION_BUMPS.tmp" 2>/dev/null || true
echo "$BRANCH:$PLUGIN_NAME:$BUMP_TYPE:$COMMIT:$DIFF_STATS" >> "$VERSION_BUMPS.tmp"
mv "$VERSION_BUMPS.tmp" "$VERSION_BUMPS"

echo "$PLUGIN_NAME: $CURRENT_VERSION → $NEW_VERSION ($BUMP_TYPE)"
