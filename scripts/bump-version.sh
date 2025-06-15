#!/bin/bash
# Version management script for Gitok
# Usage: ./scripts/bump-version.sh [major|minor|patch]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$PROJECT_ROOT/VERSION"
GITOK_SCRIPT="$PROJECT_ROOT/.gitok.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [major|minor|patch]"
    echo ""
    echo "Examples:"
    echo "  $0 patch    # 1.0.0 -> 1.0.1"
    echo "  $0 minor    # 1.0.1 -> 1.1.0"
    echo "  $0 major    # 1.1.0 -> 2.0.0"
    exit 1
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  Warning: You have uncommitted changes${NC}"
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting..."
        exit 1
    fi
fi

# Get bump type
BUMP_TYPE=${1:-patch}

if [[ ! "$BUMP_TYPE" =~ ^(major|minor|patch)$ ]]; then
    echo -e "${RED}❌ Error: Invalid bump type '$BUMP_TYPE'${NC}"
    usage
fi

# Read current version
if [ ! -f "$VERSION_FILE" ]; then
    echo -e "${RED}❌ Error: VERSION file not found${NC}"
    exit 1
fi

CURRENT_VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
echo -e "${BLUE}📋 Current version: $CURRENT_VERSION${NC}"

# Parse version parts
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Bump version based on type
case $BUMP_TYPE in
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
echo -e "${GREEN}🚀 New version: $NEW_VERSION${NC}"

# Confirm the change
read -p "Do you want to bump version from $CURRENT_VERSION to $NEW_VERSION? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting..."
    exit 1
fi

# Update VERSION file
echo "$NEW_VERSION" > "$VERSION_FILE"
echo -e "${GREEN}✅ Updated VERSION file${NC}"

# Update version in .gitok.sh
sed -i "s/GITOK_VERSION=\".*\"/GITOK_VERSION=\"$NEW_VERSION\"/" "$GITOK_SCRIPT"
echo -e "${GREEN}✅ Updated version in .gitok.sh${NC}"

# Generate dynamic changelog
echo -e "${BLUE}📝 Generating dynamic changelog...${NC}"
"$SCRIPT_DIR/generate-changelog.sh" changelog "$NEW_VERSION"
echo -e "${GREEN}✅ Updated CHANGELOG.md${NC}"

# Git operations
echo -e "${BLUE}📝 Creating git commit...${NC}"
git add "$VERSION_FILE" "$GITOK_SCRIPT" "$PROJECT_ROOT/CHANGELOG.md"
git commit -m "🔖 Bump version to v$NEW_VERSION

- Updated version in core script  
        - Changelog from commits
- Ready for release"

echo -e "${BLUE}🏷️  Creating git tag...${NC}"
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"

echo -e "${GREEN}✅ Version bumped successfully!${NC}"
echo ""
echo "To push the changes and tag:"
echo "  git push origin main"
echo "  git push origin v$NEW_VERSION"
echo ""
echo "Or push everything at once:"
echo "  git push origin main --tags" 