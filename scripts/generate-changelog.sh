#!/bin/bash
# Changelog generation script for GitOK
# Release notes and changelog generator for GitOK

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CHANGELOG_FILE="$PROJECT_ROOT/CHANGELOG.md"
VERSION_FILE="$PROJECT_ROOT/VERSION"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to get the date in YYYY-MM-DD format
get_date() {
    date +%Y-%m-%d
}

# Function to get the previous git tag
get_previous_tag() {
    git describe --tags --abbrev=0 HEAD~1 2>/dev/null || echo ""
}

# Function to get commits since last tag
get_commits_since_tag() {
    local since_tag="$1"
    if [ -n "$since_tag" ]; then
        git log --pretty=format:"%s" "$since_tag"..HEAD
    else
        git log --pretty=format:"%s"
    fi
}

# Function to categorize commit messages
categorize_commits() {
    local commits="$1"
    
    # Initialize arrays for different types
    features=()
    fixes=()
    improvements=()
    docs=()
    chores=()
    breaking=()
    other=()
    
    while IFS= read -r commit; do
        # Skip empty lines
        [ -z "$commit" ] && continue
        
        # Convert to lowercase for matching
        commit_lower=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
        
        # Categorize based on conventional commits and keywords
        if [[ "$commit_lower" =~ ^(feat|feature)(\(.*\))?!?: ]] || [[ "$commit_lower" =~ (add|new|implement|introduce) ]]; then
            features+=("$commit")
        elif [[ "$commit_lower" =~ ^(fix|bug)(\(.*\))?!?: ]] || [[ "$commit_lower" =~ (fix|resolve|correct|patch) ]]; then
            fixes+=("$commit")
        elif [[ "$commit_lower" =~ ^(improve|enhance|perf|performance|refactor)(\(.*\))?!?: ]] || [[ "$commit_lower" =~ (improve|enhance|optimize|refactor|update) ]]; then
            improvements+=("$commit")
        elif [[ "$commit_lower" =~ ^(docs|doc)(\(.*\))?!?: ]] || [[ "$commit_lower" =~ (document|readme|changelog|comment) ]]; then
            docs+=("$commit")
        elif [[ "$commit_lower" =~ ^(chore|build|ci|test)(\(.*\))?!?: ]] || [[ "$commit_lower" =~ (chore|build|test|ci|cd|deploy) ]]; then
            chores+=("$commit")
        elif [[ "$commit_lower" =~ ! ]] || [[ "$commit_lower" =~ breaking ]]; then
            breaking+=("$commit")
        else
            other+=("$commit")
        fi
    done <<< "$commits"
}

# Function to clean commit message (remove conventional commit prefixes)
clean_commit_message() {
    local msg="$1"
    # Remove conventional commit prefixes
    msg=$(echo "$msg" | sed -E 's/^(feat|fix|docs|style|refactor|test|chore|build|ci|perf|improve|enhance|add|new|implement|introduce|resolve|correct|patch|optimize|update|document)(\([^)]*\))?!?:\s*//')
    # Capitalize first letter
    msg="$(tr '[:lower:]' '[:upper:]' <<< "${msg:0:1}")${msg:1}"
    echo "$msg"
}

# Function to generate changelog section
generate_changelog_section() {
    local version="$1"
    local date="$2"
    local previous_tag="$3"
    
    echo ""
    echo "## [$version] - $date"
    echo ""
    
    # Get commits since last tag
    local commits
    commits=$(get_commits_since_tag "$previous_tag")
    
    if [ -z "$commits" ]; then
        echo "### Changed"
        echo "- Minor improvements and bug fixes"
        echo ""
        return
    fi
    
    # Categorize commits
    categorize_commits "$commits"
    
    # Generate sections based on what we found
    if [ ${#breaking[@]} -gt 0 ]; then
        echo "### ⚠️ BREAKING CHANGES"
        for commit in "${breaking[@]}"; do
            echo "- $(clean_commit_message "$commit")"
        done
        echo ""
    fi
    
    if [ ${#features[@]} -gt 0 ]; then
        echo "### ✨ Added"
        for commit in "${features[@]}"; do
            echo "- $(clean_commit_message "$commit")"
        done
        echo ""
    fi
    
    if [ ${#improvements[@]} -gt 0 ]; then
        echo "### 🚀 Improved"
        for commit in "${improvements[@]}"; do
            echo "- $(clean_commit_message "$commit")"
        done
        echo ""
    fi
    
    if [ ${#fixes[@]} -gt 0 ]; then
        echo "### 🐛 Fixed"
        for commit in "${fixes[@]}"; do
            echo "- $(clean_commit_message "$commit")"
        done
        echo ""
    fi
    
    if [ ${#docs[@]} -gt 0 ]; then
        echo "### 📚 Documentation"
        for commit in "${docs[@]}"; do
            echo "- $(clean_commit_message "$commit")"
        done
        echo ""
    fi
    
    if [ ${#chores[@]} -gt 0 ]; then
        echo "### 🔧 Technical"
        for commit in "${chores[@]}"; do
            echo "- $(clean_commit_message "$commit")"
        done
        echo ""
    fi
    
    if [ ${#other[@]} -gt 0 ]; then
        echo "### 📝 Other Changes"
        for commit in "${other[@]}"; do
            echo "- $(clean_commit_message "$commit")"
        done
        echo ""
    fi
}

# Function to update changelog
update_changelog() {
    local version="$1"
    local date="$2"
    
    if [ ! -f "$CHANGELOG_FILE" ]; then
        echo -e "${RED}❌ Error: CHANGELOG.md not found${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📝 Generating changelog for version $version...${NC}"
    
    # Get previous tag
    local previous_tag
    previous_tag=$(get_previous_tag)
    
    if [ -n "$previous_tag" ]; then
        echo -e "${CYAN}📋 Comparing changes since $previous_tag${NC}"
    else
        echo -e "${CYAN}📋 Generating initial changelog${NC}"
    fi
    
    # Create temporary file with new content
    local temp_file="/tmp/changelog_temp.md"
    
    # Read current changelog and insert new version
    {
        # Copy header until [Unreleased] section
        sed '/## \[Unreleased\]/q' "$CHANGELOG_FILE"
        
        # Generate new version section
        generate_changelog_section "$version" "$date" "$previous_tag"
        
        # Copy rest of changelog, skipping the [Unreleased] line
        sed '1,/## \[Unreleased\]/d' "$CHANGELOG_FILE"
        
    } > "$temp_file"
    
    # Replace original changelog
    mv "$temp_file" "$CHANGELOG_FILE"
    
    echo -e "${GREEN}✅ Changelog updated successfully${NC}"
}

# Function to generate release notes for GitHub
generate_release_notes() {
    local version="$1"
    local previous_tag="$2"
    
    echo "## 🚀 GitOK $version"
    echo ""
    
    # Get commits since last tag
    local commits
    commits=$(get_commits_since_tag "$previous_tag")
    
    if [ -z "$commits" ]; then
        echo "### What's Changed"
        echo "- Minor improvements and bug fixes"
        echo ""
        echo "### 📦 Installation"
        echo '```bash'
        echo "bash <(curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/install.sh)"
        echo '```'
        echo ""
        echo "### 🔄 Update Existing Installation"
        echo '```bash'
        echo "gitok --update"
        echo '```'
        return
    fi
    
    # Categorize commits
    categorize_commits "$commits"
    
    # Generate release notes sections
    local has_content=false
    
    if [ ${#breaking[@]} -gt 0 ]; then
        echo "### ⚠️ BREAKING CHANGES"
        for commit in "${breaking[@]}"; do
            echo "- $(clean_commit_message "$commit")"
        done
        echo ""
        has_content=true
    fi
    
    if [ ${#features[@]} -gt 0 ]; then
        echo "### ✨ New Features"
        for commit in "${features[@]}"; do
            echo "- $(clean_commit_message "$commit")"
        done
        echo ""
        has_content=true
    fi
    
    if [ ${#improvements[@]} -gt 0 ]; then
        echo "### 🚀 Improvements"
        for commit in "${improvements[@]}"; do
            echo "- $(clean_commit_message "$commit")"
        done
        echo ""
        has_content=true
    fi
    
    if [ ${#fixes[@]} -gt 0 ]; then
        echo "### 🐛 Bug Fixes"
        for commit in "${fixes[@]}"; do
            echo "- $(clean_commit_message "$commit")"
        done
        echo ""
        has_content=true
    fi
    
    if [ ${#docs[@]} -gt 0 ]; then
        echo "### 📚 Documentation"
        for commit in "${docs[@]}"; do
            echo "- $(clean_commit_message "$commit")"
        done
        echo ""
        has_content=true
    fi
    
    if [ ${#other[@]} -gt 0 ]; then
        echo "### 📝 Other Changes"
        for commit in "${other[@]}"; do
            echo "- $(clean_commit_message "$commit")"
        done
        echo ""
        has_content=true
    fi
    
    if [ "$has_content" = false ]; then
        echo "### What's Changed"
        echo "- Minor improvements and bug fixes"
        echo ""
    fi
    
    echo "### 📦 Installation"
    echo '```bash'
    echo "bash <(curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/install.sh)"
    echo '```'
    echo ""
    echo "### 🔄 Update Existing Installation"
    echo '```bash'
    echo "gitok --update"
    echo '```'
    echo ""
    
    if [ -n "$previous_tag" ]; then
        echo "**Full Changelog**: https://github.com/okwareddevnest/gitok/compare/$previous_tag...v$version"
    fi
}

# Main function
main() {
    local mode="$1"
    local version="$2"
    
    case "$mode" in
        "changelog")
            if [ -z "$version" ]; then
                version=$(cat "$VERSION_FILE" 2>/dev/null || echo "1.0.0")
            fi
            update_changelog "$version" "$(get_date)"
            ;;
        "release-notes")
            if [ -z "$version" ]; then
                version=$(cat "$VERSION_FILE" 2>/dev/null || echo "1.0.0")
            fi
            previous_tag=$(get_previous_tag)
            generate_release_notes "$version" "$previous_tag"
            ;;
        *)
            echo "Usage: $0 [changelog|release-notes] [version]"
            echo ""
            echo "Examples:"
            echo "  $0 changelog 1.1.0"
            echo "  $0 release-notes 1.1.0"
            exit 1
            ;;
    esac
}

# Initialize arrays (needed for some bash versions)
features=()
fixes=()
improvements=()
docs=()
chores=()
breaking=()
other=()

# Run main function
main "$@" 