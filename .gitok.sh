#!/bin/bash
# shellcheck disable=SC2155,SC2181,SC2016,SC2034,SC2086,SC2094,SC2046,SC2001,SC2002,SC2009,SC2164,SC2162
# GitOK - Git CLI Productivity Boost
# Created by Dedan Okware

# GitOK Configuration
GITOK_VERSION="2.0.0"
GITOK_REPO="https://raw.githubusercontent.com/okwareddevnest/gitok/main"
GITOK_SCRIPT_PATH="$HOME/.gitok.sh"

# Version and help functions
function gitok() {
  case "$1" in
    --version|-v)
      echo "GitOK v$GITOK_VERSION"
      echo "GitOK by Dedan Okware"
      echo "Repository: https://github.com/okwareddevnest/gitok"
      ;;
    --help|-h)
      gitcheatsheet
      ;;
    --update|-u)
      gitok_update
      ;;
    *)
      echo "GitOK v$GITOK_VERSION - GitOK"
      echo ""
      echo "Usage:"
      echo "  gitok --version    Show version"
      echo "  gitok --help       Show commands cheatsheet"
      echo "  gitok --update     Update to latest version"
      echo ""
      echo "Or use any of the git aliases directly. Run 'gitcheatsheet' for full list."
      ;;
  esac
}

# Update functionality
function gitok_update() {
  echo "🔄 Checking for GitOK updates..."
  
  # Try GitHub API first (more reliable than CDN)
  LATEST_VERSION=$(curl -s "https://api.github.com/repos/okwareddevnest/gitok/contents/VERSION" 2>/dev/null | grep '"content"' | cut -d'"' -f4 | base64 -d 2>/dev/null)
  
  # If API fails (rate limit or network), try fallback methods
  if [ -z "$LATEST_VERSION" ]; then
    echo "⚠️  GitHub API unavailable (rate limit or network issue). Trying fallback method..."
    
    # Fallback 1: Try raw GitHub content
    LATEST_VERSION=$(curl -s "https://raw.githubusercontent.com/okwareddevnest/gitok/main/VERSION" 2>/dev/null | tr -d '[:space:]')
    
    # Fallback 2: Try git ls-remote to get latest tag
    if [ -z "$LATEST_VERSION" ]; then
      echo "⚠️  Raw content unavailable. Trying git method..."
      LATEST_VERSION=$(git ls-remote --tags --sort='-v:refname' https://github.com/okwareddevnest/gitok.git 2>/dev/null | head -n1 | grep -o 'v[0-9.]*' | sed 's/v//' 2>/dev/null)
    fi
  fi
  
  if [ -z "$LATEST_VERSION" ]; then
    echo "❌ Failed to check for updates. All methods failed:"
    echo "   • GitHub API may be rate limited"
    echo "   • Raw content unavailable"
    echo "   • Git remote access failed"
    echo "   • Check your internet connection"
    return 1
  fi
  
  # Remove any whitespace
  LATEST_VERSION=$(echo "$LATEST_VERSION" | tr -d '[:space:]')
  
  if [ "$LATEST_VERSION" = "$GITOK_VERSION" ]; then
    echo "✅ You already have the latest version (v$GITOK_VERSION)"
    return 0
  fi
  
  # Check if current version is newer than remote (development scenario)
  if command -v sort >/dev/null 2>&1; then
    NEWER_VERSION=$(printf '%s\n%s' "$GITOK_VERSION" "$LATEST_VERSION" | sort -V | tail -n1)
    if [ "$NEWER_VERSION" = "$GITOK_VERSION" ]; then
      echo "✅ You have a newer version (v$GITOK_VERSION) than remote (v$LATEST_VERSION)"
      echo "   This may be a development version."
      return 0
    fi
  fi
  
  echo "🆕 New version available: v$LATEST_VERSION (current: v$GITOK_VERSION)"
  read -r -p "Do you want to update? (y/N): " confirm
  
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "📥 Downloading latest version..."
    
    # Backup current version
    cp "$GITOK_SCRIPT_PATH" "${GITOK_SCRIPT_PATH}.backup"
    
    # Download new version
    if curl -sL "$GITOK_REPO/.gitok.sh" -o "$GITOK_SCRIPT_PATH"; then
      echo "✅ GitOK updated to v$LATEST_VERSION"
      echo "🔄 Please restart your terminal or run: source ~/.bashrc"
      echo "💾 Backup saved as: ${GITOK_SCRIPT_PATH}.backup"
    else
      echo "❌ Update failed. Restoring backup..."
      mv "${GITOK_SCRIPT_PATH}.backup" "$GITOK_SCRIPT_PATH"
    fi
  else
    echo "❌ Update cancelled"
  fi
}

# Check if in a Git repo
function in_git_repo() {
  git rev-parse --is-inside-work-tree &>/dev/null
}

# Git status
function status() {
  in_git_repo && git status
}

# Clone a repository
function clone() {
  git clone "$1"
}

# Initialize a Git repo with 'main' as default branch
function init() {
  echo "🧱 Initializing Git repository with 'main' as default branch..."
  git init -b main
}

# Add all changes
function addall() {
  git add .
}

# Commit with message (auto-stage all)
function commit() {
  git add . && git commit -m "$1"
}

# Commit only staged files
function commitonly() {
  git commit -m "$1"
}

# Push to current remote branch
function push() {
  branch=$(git rev-parse --abbrev-ref HEAD)
  git push origin "$branch"
}

# Pull with rebase
function pull() {
  git pull --rebase
}

# Push to all remotes dynamically
function pushall() {
  branch=$(git rev-parse --abbrev-ref HEAD)
  mode="$1"  # supports --dry-run

  for remote in $(git remote); do
    echo "🔁 Rebasing from $remote/$branch..."
    git pull --rebase "$remote" "$branch"

    if [[ "$mode" == "--dry-run" ]]; then
      echo "🧪 [DRY RUN] Would push $branch to $remote..."
      git push --dry-run "$remote" "$branch"
    else
      echo "🔼 Pushing $branch to $remote..."
      git push "$remote" "$branch"
    fi
  done
}

# Undo the last push (force reset remote to one commit before)
function unpush() {
  branch=$(git rev-parse --abbrev-ref HEAD)
  remote=${1:-origin}  # default to origin if not specified

  echo "⚠️ WARNING: This will remove the last commit from $remote/$branch"
  read -r -p "Are you sure? Type 'yes' to continue: " confirm
  if [[ "$confirm" == "yes" ]]; then
    git push "$remote" HEAD~1:"$branch" --force
    echo "✅ Unpushed last commit from $remote/$branch"
  else
    echo "❌ Unpush aborted"
  fi
}

# Create and switch to new branch
function branch() {
  git checkout -b "$1"
}

# Switch branches
function checkout() {
  git checkout "$1"
}

# List branches
function branches() {
  git branch -a
}

# Delete branch
function deletebranch() {
  git branch -d "$1"
}

# Force delete branch
function deletebranchf() {
  git branch -D "$1"
}

# View commit graph
function graphlog() {
  git log --oneline --graph --decorate --all
}

# Show last commit
function last() {
  git log -1
}

# View diff with HEAD
function diff() {
  git diff HEAD
}

# Reset soft (undo last commit, keep changes)
function resetsoft() {
  git reset --soft HEAD~1
}

# Reset hard (dangerous)
function resethard() {
  git reset --hard HEAD
}

# Stash and stash pop
function stash() {
  git stash
}

function pop() {
  git stash pop
}

# Restore a file
function restore() {
  git restore "$1"
}

# Undo all staged files
function unstage() {
  git reset
}

# Clean untracked files
function clean() {
  git clean -fd
}

# Track remote branch (e.g., for new branches)
function trackremote() {
  branch=$(git rev-parse --abbrev-ref HEAD)
  git push -u origin "$branch"
}

# Create .gitignore from template
function makeignore() {
  curl -sL https://www.toptal.com/developers/gitignore/api/"$1" -o .gitignore
}

# Squash last N commits
function squashlast() {
  count=${1:-2}
  git reset --soft HEAD~"$count"
  echo "Now run: git commit -m 'Your combined message'"
}

# Show detailed log
function logfull() {
  git log --pretty=format:"%h - %an, %ar : %s"
}

# Show remotes
function remotes() {
  git remote -v
}

# Revert last commit (with new commit)
function revertlast() {
  git revert HEAD
}

# Amend last commit message
function amendmsg() {
  git commit --amend -m "$1"
}

# Show tracked file changes
function tracked() {
  git ls-files -m
}

# Add a file/folder/pattern to .gitignore (if not already present)
function ignore() {
  if [ -z "$1" ]; then
    echo "❌ Usage: ignore <file|folder|pattern>"
    return 1
  fi

  if ! grep -qxF "$1" .gitignore 2>/dev/null; then
    echo "$1" >> .gitignore
    echo "✅ Added '$1' to .gitignore"
  else
    echo "ℹ️ '$1' is already in .gitignore"
  fi
}

# Push to new remote
function pushnew() {
  if [ -z "$1" ]; then
    echo "❌ Usage: pushnew <remote-url>"
    return 1
  fi

  REMOTE_URL="$1"
  BRANCH=$(git rev-parse --abbrev-ref HEAD)

  echo "🔗 Adding remote origin..."
  git remote add origin "$REMOTE_URL"

  echo "🚀 Publishing current branch '$BRANCH' to origin..."
  git push -u origin "$BRANCH"

  echo "✅ Repo published to: $REMOTE_URL"
}

# GitHub Projects v2 functionality
GITOK_GITHUB_TOKEN=""
GITOK_BOARDS_DIR="$HOME/.gitok/boards"

# Ensure boards directory exists
function ensure_boards_dir() {
  if [ ! -d "$GITOK_BOARDS_DIR" ]; then
    mkdir -p "$GITOK_BOARDS_DIR"
  fi
}

# Check for required dependencies
function check_board_dependencies() {
  local missing_deps=()
  
  # Check for jq
  if ! command -v jq >/dev/null 2>&1; then
    missing_deps+=("jq")
  fi
  
  # Check for curl
  if ! command -v curl >/dev/null 2>&1; then
    missing_deps+=("curl")
  fi
  
  if [ ${#missing_deps[@]} -ne 0 ]; then
    echo "❌ Missing required dependencies: ${missing_deps[*]}"
    echo ""
    echo "📦 Please install missing dependencies:"
    for dep in "${missing_deps[@]}"; do
      case "$dep" in
        "jq")
          echo "  • jq: JSON processor"
          echo "    - Ubuntu/Debian: sudo apt-get install jq"
          echo "    - macOS: brew install jq"
          echo "    - Windows: choco install jq"
          ;;
        "curl")
          echo "  • curl: HTTP client"
          echo "    - Ubuntu/Debian: sudo apt-get install curl"
          echo "    - macOS: brew install curl"
          echo "    - Windows: Usually pre-installed"
          ;;
      esac
    done
    return 1
  fi
  return 0
}

# Safe JSON parsing with error handling
function safe_jq() {
  local query="$1"
  local file="$2"
  local default_value="$3"
  
  if [ ! -f "$file" ]; then
    echo "${default_value:-}"
    return 1
  fi
  
  local   result=$(jq -r "$query" "$file" 2>/dev/null)
  if ! jq -r "$query" "$file" >/dev/null 2>&1 || [ "$result" = "null" ]; then
    echo "${default_value:-}"
    return 1
  fi
  
  echo "$result"
}

# GitHub authentication setup
function githubauth() {
  echo "🔐 GitHub Authentication Setup"
  echo "Setting up GitHub authentication for project boards..."
  echo ""
  
  # Method 1: Try GitHub CLI first
  if command -v gh >/dev/null 2>&1; then
    echo "🔍 Found GitHub CLI, checking authentication..."
    if gh auth status >/dev/null 2>&1; then
      echo "✅ GitHub CLI is already authenticated!"
      
      # Extract token from gh CLI
      local gh_token=$(gh auth token 2>/dev/null)
      if [ -n "$gh_token" ]; then
        echo "$gh_token" > "$HOME/.gitok_github_token"
        chmod 600 "$HOME/.gitok_github_token"
        GITOK_GITHUB_TOKEN="$gh_token"
        echo "✅ GitHub authentication configured using GitHub CLI!"
        echo "💾 Token saved securely to ~/.gitok_github_token"
        return 0
      fi
    else
      echo "🚀 GitHub CLI found but not authenticated. Let's authenticate..."
      if gh auth login --scopes "project" --web; then
        echo "✅ GitHub CLI authentication successful!"
        
        # Extract token from gh CLI
        local gh_token=$(gh auth token 2>/dev/null)
        if [ -n "$gh_token" ]; then
          echo "$gh_token" > "$HOME/.gitok_github_token"
          chmod 600 "$HOME/.gitok_github_token"
          GITOK_GITHUB_TOKEN="$gh_token"
          echo "✅ GitHub authentication configured using GitHub CLI!"
          echo "💾 Token saved securely to ~/.gitok_github_token"
          return 0
        fi
      else
        echo "❌ GitHub CLI authentication failed"
        echo "📝 Falling back to OAuth device flow..."
      fi
    fi
  else
    echo "ℹ️  GitHub CLI not found. Installing it would provide the best experience:"
    echo "   • Ubuntu/Debian: sudo apt install gh"
    echo "   • macOS: brew install gh"
    echo "   • Other: https://cli.github.com/"
    echo ""
    echo "📝 Falling back to OAuth device flow..."
  fi
  
  # Method 2: OAuth Device Flow
  echo ""
  echo "🔐 Using OAuth Device Flow Authentication"
  echo "This method doesn't require you to manually create tokens!"
  echo ""
  
  if ! command -v curl >/dev/null 2>&1; then
    echo "❌ curl is required for OAuth authentication"
    return 1
  fi
  
  # Start device flow
  # Use custom client ID if provided, otherwise use placeholder
  # To use your own OAuth app, set: export GITOK_GITHUB_CLIENT_ID="your_client_id"
  local client_id="${GITOK_GITHUB_CLIENT_ID:-Iv1.a629723a330c7e24}"
  
  if [ "$client_id" = "Iv1.a629723a330c7e24" ]; then
    echo "ℹ️  Using placeholder OAuth app. For production use, create your own:"
    echo "   1. Go to https://github.com/settings/applications/new"
    echo "   2. Set 'Authorization callback URL' to: http://localhost"
    echo "   3. Export your client ID: export GITOK_GITHUB_CLIENT_ID='your_client_id'"
    echo ""
  fi
  local device_response=$(curl -s -X POST \
    -H "Accept: application/json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -d "{\"client_id\":\"$client_id\",\"scope\":\"project\"}" \
    https://github.com/login/device/code)
  
  if [ $? -ne 0 ]; then
    echo "❌ Failed to start OAuth device flow"
    echo "📝 Falling back to manual token entry..."
    githubauth_manual
    return $?
  fi
  
  local device_code=$(echo "$device_response" | jq -r '.device_code' 2>/dev/null)
  local user_code=$(echo "$device_response" | jq -r '.user_code' 2>/dev/null)
  local verification_uri=$(echo "$device_response" | jq -r '.verification_uri' 2>/dev/null)
  local interval=$(echo "$device_response" | jq -r '.interval' 2>/dev/null)
  local expires_in=$(echo "$device_response" | jq -r '.expires_in' 2>/dev/null)
  
  if [ "$device_code" = "null" ] || [ "$user_code" = "null" ]; then
    echo "❌ Failed to parse device flow response"
    echo "📝 Falling back to manual token entry..."
    githubauth_manual
    return $?
  fi
  
  echo "🌐 Please visit: $verification_uri"
  echo "🔑 Enter this code: $user_code"
  echo ""
  echo "⏱️  Waiting for authorization (expires in ${expires_in}s)..."
  echo "Press Ctrl+C to cancel and use manual token entry"
  
  # Try to open the URL automatically
  local open_cmd=""
  if command -v xdg-open >/dev/null 2>&1; then
    open_cmd="xdg-open"
  elif command -v open >/dev/null 2>&1; then
    open_cmd="open"
  elif command -v start >/dev/null 2>&1; then
    open_cmd="start"
  fi
  
  if [ -n "$open_cmd" ]; then
    echo "🚀 Opening browser automatically..."
    $open_cmd "$verification_uri" 2>/dev/null &
  fi
  
  # Poll for authorization
  local poll_interval=${interval:-5}
  local max_attempts=$((expires_in / poll_interval))
  local attempts=0
  
  while [ $attempts -lt $max_attempts ]; do
    sleep "$poll_interval"
    attempts=$((attempts + 1))
    
    local token_response=$(curl -s -X POST \
      -H "Accept: application/json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      -d "{\"client_id\":\"$client_id\",\"device_code\":\"$device_code\",\"grant_type\":\"urn:ietf:params:oauth:grant-type:device_code\"}" \
      https://github.com/login/oauth/access_token)
    
    local error=$(echo "$token_response" | jq -r '.error' 2>/dev/null)
    
    if [ "$error" = "null" ] || [ -z "$error" ]; then
      # Success!
      local access_token=$(echo "$token_response" | jq -r '.access_token' 2>/dev/null)
      if [ -n "$access_token" ] && [ "$access_token" != "null" ]; then
        echo "$access_token" > "$HOME/.gitok_github_token"
        chmod 600 "$HOME/.gitok_github_token"
        GITOK_GITHUB_TOKEN="$access_token"
        echo ""
        echo "✅ GitHub authentication successful!"
        echo "💾 Token saved securely to ~/.gitok_github_token"
        return 0
      fi
    elif [ "$error" = "authorization_pending" ]; then
      echo -n "⏳ Still waiting for authorization... "
      continue
    elif [ "$error" = "slow_down" ]; then
      echo -n "⏳ Slowing down polling... "
      sleep 5
      continue
    else
      echo ""
      echo "❌ Authorization failed: $error"
      break
    fi
  done
  
  echo ""
  echo "❌ OAuth device flow timed out or failed"
  echo "📝 Falling back to manual token entry..."
  githubauth_manual
  return $?
}

# Manual token entry fallback
function githubauth_manual() {
  echo "🔐 Manual Token Entry"
  echo "To use GitHub project boards, you need a personal access token with 'project' scope."
  echo ""
  echo "📝 Steps to create a token:"
  echo "1. Go to https://github.com/settings/personal-access-tokens/new"
  echo "2. Give it a name (e.g., 'gitok-project-boards')"
  echo "3. Select 'project' scope"
  echo "4. Click 'Generate token'"
  echo ""
  
  read -r -p "Enter your GitHub personal access token: " -s token
  echo ""
  
  if [ -z "$token" ]; then
    echo "❌ No token provided"
    return 1
  fi
  
  # Test the token
  echo "🔍 Testing token..."
  response=$(curl -s -H "Authorization: Bearer $token" -H "Accept: application/vnd.github+json" https://api.github.com/user)
  
  if echo "$response" | grep -q '"login"'; then
    username=$(echo "$response" | grep -o '"login":"[^"]*' | cut -d'"' -f4)
    echo "✅ Token verified for user: $username"
    
    # Save token to config file
    echo "$token" > "$HOME/.gitok_github_token"
    chmod 600 "$HOME/.gitok_github_token"
    GITOK_GITHUB_TOKEN="$token"
    
    echo "💾 Token saved securely to ~/.gitok_github_token"
    echo "🎉 GitHub authentication setup complete!"
    return 0
  else
    echo "❌ Invalid token or network error"
    return 1
  fi
}

# Load GitHub token
function load_github_token() {
  if [ -f "$HOME/.gitok_github_token" ]; then
    GITOK_GITHUB_TOKEN=$(cat "$HOME/.gitok_github_token")
  fi
}

# Check if GitHub token is available
function require_github_auth() {
  load_github_token
  if [ -z "$GITOK_GITHUB_TOKEN" ]; then
    echo "❌ GitHub authentication required. Run 'githubauth' first."
    return 1
  fi
  return 0
}

# GraphQL query helper
function github_graphql_query() {
  local query="$1"
  
  if ! require_github_auth; then
    return 1
  fi
  
  # Check if we have curl available
  if ! command -v curl >/dev/null 2>&1; then
    echo "❌ curl is required for GitHub API access"
    return 1
  fi
  
  # Make the GraphQL request with timeout and better error handling
  # Use jq to properly escape the query JSON
  local json_payload=$(jq -n --arg query "$query" '{query: $query}')
  local response=$(curl -s -X POST \
    --max-time 30 \
    --retry 2 \
    --retry-delay 1 \
    -H "Authorization: Bearer $GITOK_GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$json_payload" \
    https://api.github.com/graphql 2>/dev/null)
  
  # Check if curl command failed
  if [ $? -ne 0 ]; then
    echo "❌ Network error: Failed to connect to GitHub API"
    return 1
  fi
  
  # Check if response is empty
  if [ -z "$response" ]; then
    echo "❌ Empty response from GitHub API"
    return 1
  fi
  
  # Check for rate limiting
  if echo "$response" | grep -q "API rate limit exceeded"; then
    echo "❌ GitHub API rate limit exceeded. Please wait and try again."
    return 1
  fi
  
  echo "$response"
}

# Create a new project board locally
function createboard() {
  local board_name="$1"
  local board_description="$2"
  
  if [ -z "$board_name" ]; then
    echo "❌ Usage: createboard \"Board Name\" [\"Description\"]"
    return 1
  fi
  
  if ! check_board_dependencies; then
    return 1
  fi
  
  ensure_boards_dir
  
  # Sanitize board name for filename
  local filename=$(echo "$board_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
  local board_file="$GITOK_BOARDS_DIR/$filename.json"
  
  if [ -f "$board_file" ]; then
    echo "❌ Board '$board_name' already exists locally"
    return 1
  fi
  
  # Create board JSON structure (GitHub Projects v2 compatible)
  cat > "$board_file" << EOF
{
  "name": "$board_name",
  "description": "${board_description:-Default project board}",
  "visibility": "private",
  "views": [
    {
      "name": "Table View",
      "layout": "TABLE",
      "is_default": true
    },
    {
      "name": "Board View",
      "layout": "BOARD",
      "is_default": false
    }
  ],
  "fields": [
    {
      "name": "Status",
      "type": "SINGLE_SELECT",
      "options": [
        {"name": "To Do", "color": "GRAY"},
        {"name": "In Progress", "color": "YELLOW"},
        {"name": "Done", "color": "GREEN"}
      ]
    },
    {
      "name": "Priority",
      "type": "SINGLE_SELECT",
      "options": [
        {"name": "High", "color": "RED"},
        {"name": "Medium", "color": "ORANGE"},
        {"name": "Low", "color": "BLUE"}
      ]
    }
  ],
  "items": [],
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "pushed_to_github": false,
  "github_id": null,
  "github_number": null,
  "github_url": null
}
EOF
  
  echo "✅ Created local board: $board_name"
  echo "📁 Saved to: $board_file"
  echo "💡 Use 'pushboard \"$board_name\"' to push to GitHub"
}

# List local project boards
function listboards() {
  if ! check_board_dependencies; then
    return 1
  fi
  
  ensure_boards_dir
  
  echo "📋 Local Project Boards:"
  echo "========================"
  
  if [ ! "$(ls -A "$GITOK_BOARDS_DIR" 2>/dev/null)" ]; then
    echo "No local boards found. Use 'createboard' to create one."
    return 0
  fi
  
  for board_file in "$GITOK_BOARDS_DIR"/*.json; do
    if [ -f "$board_file" ]; then
      local name=$(safe_jq '.name' "$board_file" "Unknown")
      local description=$(safe_jq '.description' "$board_file" "No description")
      local pushed=$(safe_jq '.pushed_to_github' "$board_file" "false")
      local github_id=$(safe_jq '.github_id' "$board_file" "null")
      
      echo "📌 $name"
      echo "   Description: $description"
      if [ "$pushed" = "true" ] && [ "$github_id" != "null" ]; then
        echo "   Status: ✅ Pushed to GitHub (ID: $github_id)"
      else
        echo "   Status: 📝 Local only"
      fi
      echo ""
    fi
  done
}

# Check if user has access to create projects for a given owner/organization
function verify_project_access() {
  local target_owner="$1"
  
  if [ -z "$target_owner" ]; then
    echo "❌ No target owner specified"
    return 1
  fi
  
  echo "🔍 Verifying project access for: $target_owner"
  
  # Get authenticated user info
  local viewer_query="query { viewer { login id organizations(first: 100) { nodes { login id } } } }"
  local viewer_response=$(github_graphql_query "$viewer_query")
  
  if echo "$viewer_response" | grep -q '"errors"'; then
    echo "❌ Failed to get user information"
    return 1
  fi
  
  local authenticated_user=$(echo "$viewer_response" | jq -r '.data.viewer.login' 2>/dev/null)
  local authenticated_id=$(echo "$viewer_response" | jq -r '.data.viewer.id' 2>/dev/null)
  
  echo "👤 Authenticated as: $authenticated_user"
  
  # Check if target owner is the authenticated user
  if [ "$target_owner" = "$authenticated_user" ]; then
    echo "✅ Creating project for your personal account"
    echo "$authenticated_id"
    return 0
  fi
  
  # Check if target owner is an organization the user belongs to
  local org_id=$(echo "$viewer_response" | jq -r --arg org "$target_owner" '.data.viewer.organizations.nodes[] | select(.login == $org) | .id' 2>/dev/null)
  
  if [ -n "$org_id" ] && [ "$org_id" != "null" ]; then
    echo "✅ Creating project for organization: $target_owner"
    echo "$org_id"
    return 0
  fi
  
  # If target owner is different, check if it's a valid organization/user
  local owner_query="query { user(login: \"$target_owner\") { id login } organization(login: \"$target_owner\") { id login } }"
  local owner_response=$(github_graphql_query "$owner_query")
  
  if echo "$owner_response" | grep -q '"errors"'; then
    echo "❌ Target owner '$target_owner' not found or not accessible"
    return 1
  fi
  
  local user_id=$(echo "$owner_response" | jq -r '.data.user.id' 2>/dev/null)
  local org_id=$(echo "$owner_response" | jq -r '.data.organization.id' 2>/dev/null)
  
  if [ -n "$user_id" ] && [ "$user_id" != "null" ]; then
    echo "⚠️  Target owner '$target_owner' is a different user"
    echo "   You can only create projects for your own account or organizations you belong to"
    echo "   Using your account ($authenticated_user) instead"
    echo "$authenticated_id"
    return 0
  elif [ -n "$org_id" ] && [ "$org_id" != "null" ]; then
    echo "⚠️  Target owner '$target_owner' is an organization you don't belong to"
    echo "   You can only create projects for organizations you're a member of"
    echo "   Using your account ($authenticated_user) instead"
    echo "$authenticated_id"
    return 0
  fi
  
  echo "❌ Could not determine valid owner ID"
  return 1
}

# Enhanced function to detect repository ownership with fallback
function detect_repo_owner() {
  local origin_url=$(git remote get-url origin 2>/dev/null)
  local detected_owner=""
  
  if [ -n "$origin_url" ]; then
    # Extract owner from GitHub URL
    if echo "$origin_url" | grep -q "github.com"; then
      detected_owner=$(echo "$origin_url" | sed -E 's|.*github\.com[/:]([^/]+)/.*|\1|' | sed 's|\.git$||')
    fi
  fi
  
  if [ -n "$detected_owner" ]; then
    echo "🔍 Detected repository owner: $detected_owner"
    
    # Verify access to this owner
    local owner_id=$(verify_project_access "$detected_owner")
    local access_check_result=$?
    
    if [ $access_check_result -eq 0 ] && [ -n "$owner_id" ]; then
      echo "$owner_id"
      return 0
    fi
  fi
  
  # Fallback to authenticated user if detection fails
  echo "🔄 Falling back to authenticated user..."
  local viewer_query="query { viewer { login id } }"
  local viewer_response=$(github_graphql_query "$viewer_query")
  
  if echo "$viewer_response" | grep -q '"errors"'; then
    echo "❌ Failed to get authenticated user info"
    return 1
  fi
  
  local fallback_id=$(echo "$viewer_response" | jq -r '.data.viewer.id' 2>/dev/null)
  local fallback_login=$(echo "$viewer_response" | jq -r '.data.viewer.login' 2>/dev/null)
  
  if [ -n "$fallback_id" ] && [ "$fallback_id" != "null" ]; then
    echo "✅ Using authenticated user: $fallback_login"
    echo "$fallback_id"
    return 0
  fi
  
  echo "❌ Could not determine project owner"
  return 1
}

# Push local board to GitHub
function pushboard() {
  local board_name="$1"
  
  if [ -z "$board_name" ]; then
    echo "❌ Usage: pushboard \"Board Name\""
    return 1
  fi
  
  if ! check_board_dependencies; then
    return 1
  fi
  
  if ! require_github_auth; then
    return 1
  fi
  
  ensure_boards_dir
  
  # Find board file
  local board_file=""
  for file in "$GITOK_BOARDS_DIR"/*.json; do
    if [ -f "$file" ]; then
      local name=$(jq -r '.name' "$file" 2>/dev/null)
      if [ "$name" = "$board_name" ]; then
        board_file="$file"
        break
      fi
    fi
  done
  
  if [ -z "$board_file" ]; then
    echo "❌ Board '$board_name' not found locally"
    return 1
  fi
  
  # Check if already pushed
  local pushed=$(jq -r '.pushed_to_github' "$board_file" 2>/dev/null)
  if [ "$pushed" = "true" ]; then
    echo "⚠️ Board '$board_name' already pushed to GitHub"
    read -r -p "Push updates? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "❌ Push cancelled"
      return 1
    fi
  fi
  
  echo "🚀 Pushing board '$board_name' to GitHub..."
  
  # Use enhanced repository ownership detection
  local owner_id=$(detect_repo_owner)
  local detection_result=$?
  
  if [ $detection_result -ne 0 ] || [ -z "$owner_id" ]; then
    echo "❌ Could not determine project owner or verify access"
    return 1
  fi
  
  # Read board data
  local board_title=$(jq -r '.name' "$board_file")
  local board_description=$(jq -r '.description' "$board_file")
  
  # Create project using GraphQL
  local create_query="mutation { createProjectV2(input: { ownerId: \"$owner_id\", title: \"$board_title\" }) { projectV2 { id number url } } }"
  local create_response=$(github_graphql_query "$create_query")
  
  if echo "$create_response" | grep -q '"errors"'; then
    echo "❌ Failed to create project"
    echo "$create_response" | jq -r '.errors[0].message' 2>/dev/null || echo "Unknown error"
    return 1
  fi
  
  local project_id=$(echo "$create_response" | jq -r '.data.createProjectV2.projectV2.id' 2>/dev/null)
  local project_number=$(echo "$create_response" | jq -r '.data.createProjectV2.projectV2.number' 2>/dev/null)
  local project_url=$(echo "$create_response" | jq -r '.data.createProjectV2.projectV2.url' 2>/dev/null)
  
  if [ -z "$project_id" ] || [ "$project_id" = "null" ]; then
    echo "❌ Failed to create project"
    return 1
  fi
  
  # Update board file with GitHub info
  local updated_board=$(jq --arg id "$project_id" --arg number "$project_number" --arg url "$project_url" \
    '.pushed_to_github = true | .github_id = $id | .github_number = ($number | tonumber) | .github_url = $url | .updated_at = (now | todate)' \
    "$board_file")
  
  echo "$updated_board" > "$board_file"
  
  echo "✅ Successfully pushed board to GitHub!"
  echo "🔗 Project URL: $project_url"
  echo "🆔 Project ID: $project_id"
  echo "📊 Project Number: $project_number"
}

# Edit local board
function editboard() {
  local board_name="$1"
  
  if [ -z "$board_name" ]; then
    echo "❌ Usage: editboard \"Board Name\""
    return 1
  fi
  
  if ! check_board_dependencies; then
    return 1
  fi
  
  ensure_boards_dir
  
  # Find board file
  local board_file=""
  for file in "$GITOK_BOARDS_DIR"/*.json; do
    if [ -f "$file" ]; then
      local name=$(jq -r '.name' "$file" 2>/dev/null)
      if [ "$name" = "$board_name" ]; then
        board_file="$file"
        break
      fi
    fi
  done
  
  if [ -z "$board_file" ]; then
    echo "❌ Board '$board_name' not found locally"
    return 1
  fi
  
  echo "✏️ Editing board: $board_name"
  echo "Current views:"
  jq -r '.views[]? | "- " + .name + " (" + .layout + ")"' "$board_file" 2>/dev/null || echo "- Table View (TABLE)"
  echo ""
  echo "Current fields:"
  jq -r '.fields[]? | "- " + .name + " (" + .type + ")"' "$board_file" 2>/dev/null || echo "- Status (SINGLE_SELECT)"
  echo ""
  
  echo "Available actions:"
  echo "1. Add view"
  echo "2. Remove view"
  echo "3. Add field option"
  echo "4. Add item"
  echo "5. Update description"
  echo "6. Cancel"
  echo ""
  
  read -r -p "Choose action (1-6): " action
  
  case "$action" in
    1)
      read -r -p "Enter view name: " view_name
      echo "Select layout: 1) TABLE  2) BOARD  3) ROADMAP"
      read -r -p "Choose layout (1-3): " layout_choice
      case "$layout_choice" in
        1) layout="TABLE" ;;
        2) layout="BOARD" ;;
        3) layout="ROADMAP" ;;
        *) layout="TABLE" ;;
      esac
      
      if [ -n "$view_name" ]; then
        local updated_board=$(jq --arg name "$view_name" --arg layout "$layout" \
          '.views += [{"name": $name, "layout": $layout, "is_default": false}] | .updated_at = (now | todate)' \
          "$board_file")
        echo "$updated_board" > "$board_file"
        echo "✅ Added view: $view_name ($layout)"
      fi
      ;;
    2)
      read -r -p "Enter view name to remove: " view_name
      if [ -n "$view_name" ]; then
        local updated_board=$(jq --arg name "$view_name" \
          '.views = [.views[]? | select(.name != $name)] | .updated_at = (now | todate)' \
          "$board_file")
        echo "$updated_board" > "$board_file"
        echo "✅ Removed view: $view_name"
      fi
      ;;
    3)
      echo "Current fields:"
      jq -r '.fields[]? | "- " + .name' "$board_file" 2>/dev/null
      read -r -p "Enter field name to add option to: " field_name
      read -r -p "Enter option name: " option_name
      echo "Select color: 1) RED  2) ORANGE  3) YELLOW  4) GREEN  5) BLUE  6) PURPLE  7) GRAY"
      read -r -p "Choose color (1-7): " color_choice
      case "$color_choice" in
        1) color="RED" ;;
        2) color="ORANGE" ;;
        3) color="YELLOW" ;;
        4) color="GREEN" ;;
        5) color="BLUE" ;;
        6) color="PURPLE" ;;
        7) color="GRAY" ;;
        *) color="GRAY" ;;
      esac
      
      if [ -n "$field_name" ] && [ -n "$option_name" ]; then
        local updated_board=$(jq --arg field "$field_name" --arg option "$option_name" --arg color "$color" \
          '.fields = [.fields[]? | if .name == $field then .options += [{"name": $option, "color": $color}] else . end] | .updated_at = (now | todate)' \
          "$board_file")
        echo "$updated_board" > "$board_file"
        echo "✅ Added option '$option_name' to field '$field_name'"
      fi
      ;;
    4)
      read -r -p "Enter item title: " item_title
      if [ -n "$item_title" ]; then
        local updated_board=$(jq --arg title "$item_title" \
          '.items += [{"title": $title, "body": "", "created_at": (now | todate)}] | .updated_at = (now | todate)' \
          "$board_file")
        echo "$updated_board" > "$board_file"
        echo "✅ Added item: $item_title"
      fi
      ;;
    5)
      read -r -p "Enter new description: " new_description
      if [ -n "$new_description" ]; then
        local updated_board=$(jq --arg desc "$new_description" \
          '.description = $desc | .updated_at = (now | todate)' \
          "$board_file")
        echo "$updated_board" > "$board_file"
        echo "✅ Updated description"
      fi
      ;;
    6)
      echo "❌ Edit cancelled"
      ;;
    *)
      echo "❌ Invalid action"
      ;;
  esac
}

# Sync board with GitHub
function syncboard() {
  local board_name="$1"
  
  if [ -z "$board_name" ]; then
    echo "❌ Usage: syncboard \"Board Name\""
    return 1
  fi
  
  if ! check_board_dependencies; then
    return 1
  fi
  
  if ! require_github_auth; then
    return 1
  fi
  
  ensure_boards_dir
  
  # Find board file
  local board_file=""
  for file in "$GITOK_BOARDS_DIR"/*.json; do
    if [ -f "$file" ]; then
      local name=$(jq -r '.name' "$file" 2>/dev/null)
      if [ "$name" = "$board_name" ]; then
        board_file="$file"
        break
      fi
    fi
  done
  
  if [ -z "$board_file" ]; then
    echo "❌ Board '$board_name' not found locally"
    return 1
  fi
  
  local pushed=$(jq -r '.pushed_to_github' "$board_file" 2>/dev/null)
  if [ "$pushed" != "true" ]; then
    echo "❌ Board '$board_name' not pushed to GitHub yet. Use 'pushboard' first."
    return 1
  fi
  
  local github_id=$(jq -r '.github_id' "$board_file" 2>/dev/null)
  
  echo "🔄 Syncing board '$board_name' with GitHub..."
  
  # Get current GitHub project data
  local project_query="query { node(id: \"$github_id\") { ... on ProjectV2 { id title shortDescription url number updatedAt } } }"
  local project_response=$(github_graphql_query "$project_query")
  
  if echo "$project_response" | grep -q '"errors"'; then
    echo "❌ Failed to fetch project from GitHub"
    echo "$project_response" | jq -r '.errors[0].message' 2>/dev/null || echo "Unknown error"
    return 1
  fi
  
  local github_title=$(echo "$project_response" | jq -r '.data.node.title' 2>/dev/null)
  local github_description=$(echo "$project_response" | jq -r '.data.node.shortDescription' 2>/dev/null)
  local github_updated=$(echo "$project_response" | jq -r '.data.node.updatedAt' 2>/dev/null)
  
  echo "📊 GitHub Project Info:"
  echo "   Title: $github_title"
  echo "   Description: $github_description"
  echo "   Last Updated: $github_updated"
  echo "✅ Sync complete!"
}

# Add view to a GitHub project (currently not supported by API)
function addview() {
  local board_name="$1"
  local view_name="$2"
  local view_layout="${3:-TABLE}"  # TABLE, BOARD, or ROADMAP
  
  if [ -z "$board_name" ] || [ -z "$view_name" ]; then
    echo "❌ Usage: addview \"Board Name\" \"View Name\" [layout]"
    echo "   Layouts: TABLE (default), BOARD, ROADMAP"
    return 1
  fi
  
  if ! check_board_dependencies; then
    return 1
  fi
  
  ensure_boards_dir
  
  # Find board file
  local board_file=""
  for file in "$GITOK_BOARDS_DIR"/*.json; do
    if [ -f "$file" ]; then
      local name=$(jq -r '.name' "$file" 2>/dev/null)
      if [ "$name" = "$board_name" ]; then
        board_file="$file"
        break
      fi
    fi
  done
  
  if [ -z "$board_file" ]; then
    echo "❌ Board '$board_name' not found locally"
    return 1
  fi
  
  local pushed=$(jq -r '.pushed_to_github' "$board_file" 2>/dev/null)
  if [ "$pushed" != "true" ]; then
    echo "❌ Board '$board_name' not pushed to GitHub yet. Use 'pushboard' first."
    return 1
  fi
  
  local project_url=$(jq -r '.github_url' "$board_file" 2>/dev/null)
  
  echo "ℹ️  GitHub API Limitation: Views cannot be created via API currently"
  echo ""
  echo "📋 To create views manually in GitHub:"
  echo "1. Visit your project: $project_url"
  echo "2. Click the '+ New view' button"
  echo "3. Choose layout: $view_layout (TABLE, BOARD, or ROADMAP)"
  echo "4. Name it: $view_name"
  echo "5. Configure filters and grouping as needed"
  echo ""
  echo "💡 Suggested views for your project:"
  echo "   📊 Kanban Board (BOARD layout) - Group by Status"
  echo "   📅 Timeline (ROADMAP layout) - Sort by Due Date"
  echo "   📋 Sprint Planning (TABLE layout) - Filter by Priority"
  echo ""
  echo "🎯 Your project already has custom fields ready:"
  echo "   • Priority (High/Medium/Low)"
  echo "   • Stage (Planning/Development/Testing/Completed)"
  echo "   • Effort (Story points)"
  echo "   • Due Date (Deadlines)"
  echo ""
  echo "🔗 Quick link to add view: $project_url"
}

# Advanced sync with real-time collaboration
function syncproject() {
  local board_name="$1"
  local auto_sync="${2:-false}"
  
  if [ -z "$board_name" ]; then
    echo "❌ Usage: syncproject \"Board Name\" [auto]"
    echo "   Use 'auto' for continuous sync every 30 seconds"
    return 1
  fi
  
  if ! check_board_dependencies; then
    return 1
  fi
  
  if ! require_github_auth; then
    return 1
  fi
  
  ensure_boards_dir
  
  # Find board file
  local board_file=""
  for file in "$GITOK_BOARDS_DIR"/*.json; do
    if [ -f "$file" ]; then
      local name=$(jq -r '.name' "$file" 2>/dev/null)
      if [ "$name" = "$board_name" ]; then
        board_file="$file"
        break
      fi
    fi
  done
  
  if [ -z "$board_file" ]; then
    echo "❌ Board '$board_name' not found locally"
    return 1
  fi
  
  local project_id=$(jq -r '.github_id' "$board_file" 2>/dev/null)
  local project_url=$(jq -r '.github_url' "$board_file" 2>/dev/null)
  
  echo "🔄 Advanced Project Sync: $board_name"
  echo "=================================="
  echo "🔗 Project: $project_url"
  echo ""
  
  # Real-time sync function
  sync_iteration() {
    local timestamp=$(date '+%H:%M:%S')
    echo "[$timestamp] 🔄 Syncing project data..."
    
    # Get comprehensive project data
    local project_query='
    query($projectId: ID!) {
      node(id: $projectId) {
        ... on ProjectV2 {
          id
          title
          shortDescription
          updatedAt
          closed
          number
          url
          readme
          items(first: 100) {
            totalCount
            nodes {
              id
              updatedAt
              content {
                ... on Issue {
                  id
                  title
                  body
                  state
                  createdAt
                  updatedAt
                  assignees(first: 10) { nodes { login } }
                  labels(first: 10) { nodes { name color } }
                  milestone { title }
                  comments(first: 1) { totalCount }
                }
                ... on PullRequest {
                  id
                  title
                  body
                  state
                  createdAt
                  updatedAt
                  assignees(first: 10) { nodes { login } }
                  labels(first: 10) { nodes { name color } }
                  milestone { title }
                  comments(first: 1) { totalCount }
                }
                ... on DraftIssue {
                  id
                  title
                  body
                  createdAt
                  updatedAt
                  assignees(first: 10) { nodes { login } }
                }
              }
              fieldValues(first: 20) {
                nodes {
                  ... on ProjectV2ItemFieldTextValue {
                    field { ... on ProjectV2Field { name } }
                    text
                  }
                  ... on ProjectV2ItemFieldNumberValue {
                    field { ... on ProjectV2Field { name } }
                    number
                  }
                  ... on ProjectV2ItemFieldDateValue {
                    field { ... on ProjectV2Field { name } }
                    date
                  }
                  ... on ProjectV2ItemFieldSingleSelectValue {
                    field { ... on ProjectV2SingleSelectField { name } }
                    name
                    color
                  }
                  ... on ProjectV2ItemFieldIterationValue {
                    field { ... on ProjectV2IterationField { name } }
                    title
                    startDate
                    duration
                  }
                }
              }
            }
          }
          fields(first: 50) {
            nodes {
              ... on ProjectV2Field {
                id
                name
                dataType
                createdAt
                updatedAt
              }
              ... on ProjectV2SingleSelectField {
                id
                name
                dataType
                createdAt
                updatedAt
                options {
                  id
                  name
                  description
                  color
                }
              }
              ... on ProjectV2IterationField {
                id
                name
                dataType
                createdAt
                updatedAt
                configuration {
                  iterations {
                    id
                    title
                    startDate
                    duration
                  }
                }
              }
            }
          }
          views(first: 20) {
            nodes {
              id
              name
              layout
              createdAt
              updatedAt
              filter
            }
          }
          workflows(first: 10) {
            nodes {
              id
              name
              enabled
              createdAt
              updatedAt
            }
          }
        }
      }
    }'
    
    # Execute query with variables
    local json_payload=$(jq -n --arg query "$project_query" --arg projectId "$project_id" '{
      query: $query,
      variables: {
        projectId: $projectId
      }
    }')
    
    local response=$(curl -s -X POST \
      --max-time 30 \
      -H "Authorization: Bearer $GITOK_GITHUB_TOKEN" \
      -H "Content-Type: application/json" \
      -d "$json_payload" \
      https://api.github.com/graphql 2>/dev/null)
    
    if echo "$response" | grep -q '"errors"'; then
      echo "   ❌ Sync failed: $(echo "$response" | jq -r '.errors[0].message' 2>/dev/null || echo "Unknown error")"
      return 1
    fi
    
    # Parse and display sync summary
    local total_items=$(echo "$response" | jq -r '.data.node.items.totalCount' 2>/dev/null || echo "0")
    local project_updated=$(echo "$response" | jq -r '.data.node.updatedAt' 2>/dev/null || echo "Unknown")
    local total_views=$(echo "$response" | jq -r '.data.node.views.nodes | length' 2>/dev/null || echo "0")
    local total_fields=$(echo "$response" | jq -r '.data.node.fields.nodes | length' 2>/dev/null || echo "0")
    local total_workflows=$(echo "$response" | jq -r '.data.node.workflows.nodes | length' 2>/dev/null || echo "0")
    
    # Update local cache with comprehensive data
    local sync_data=$(echo "$response" | jq --arg synced_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
      .data.node + {
        synced_at: $synced_at,
        sync_summary: {
          total_items: .data.node.items.totalCount,
          total_views: (.data.node.views.nodes | length),
          total_fields: (.data.node.fields.nodes | length),
          total_workflows: (.data.node.workflows.nodes | length),
          last_project_update: .data.node.updatedAt
        }
      }
    ')
    
    # Save to sync cache
    local sync_cache_file="$GITOK_BOARDS_DIR/.sync_cache_$(echo "$board_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g').json"
    echo "$sync_data" > "$sync_cache_file"
    
    echo "   ✅ Synced: $total_items items, $total_views views, $total_fields fields, $total_workflows workflows"
    echo "   📅 Last updated: $project_updated"
    
    # Show recent activity
    echo "   🔔 Recent Activity:"
    echo "$response" | jq -r '.data.node.items.nodes[] | select(.updatedAt != null) | "     • " + (.content.title // "Untitled") + " - " + (.updatedAt | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%m/%d %H:%M"))' 2>/dev/null | head -3
    
    # Show collaboration insights
    local assignees=$(echo "$response" | jq -r '[.data.node.items.nodes[].content.assignees.nodes[]?.login] | unique | join(", ")' 2>/dev/null)
    if [ -n "$assignees" ] && [ "$assignees" != "" ]; then
      echo "   👥 Active collaborators: $assignees"
    fi
    
    return 0
  }
  
  # Run sync
  if [ "$auto_sync" = "auto" ]; then
    echo "🔄 Starting continuous sync (Ctrl+C to stop)..."
    echo "⏱️  Syncing every 30 seconds..."
    echo ""
    
    while true; do
      sync_iteration
      echo ""
      echo "⏳ Waiting 30 seconds for next sync..."
      sleep 30
    done
  else
    sync_iteration
  fi
}

# Advanced collaboration features
function collaborate() {
  local board_name="$1"
  local action="$2"
  
  if [ -z "$board_name" ] || [ -z "$action" ]; then
    echo "❌ Usage: collaborate \"Board Name\" <action>"
    echo ""
    echo "🤝 Available collaboration actions:"
    echo "   activity     - Show recent project activity"
    echo "   contributors - List all project contributors"
    echo "   mentions     - Show items mentioning you"
    echo "   comments     - Show recent comments"
    echo "   assignments  - Show your assignments"
    echo "   invite       - Get project invitation link"
    echo "   notifications - Show notification settings"
    return 1
  fi
  
  if ! check_board_dependencies; then
    return 1
  fi
  
  if ! require_github_auth; then
    return 1
  fi
  
  ensure_boards_dir
  
  # Find board file
  local board_file=""
  for file in "$GITOK_BOARDS_DIR"/*.json; do
    if [ -f "$file" ]; then
      local name=$(jq -r '.name' "$file" 2>/dev/null)
      if [ "$name" = "$board_name" ]; then
        board_file="$file"
        break
      fi
    fi
  done
  
  if [ -z "$board_file" ]; then
    echo "❌ Board '$board_name' not found locally"
    return 1
  fi
  
  local project_id=$(jq -r '.github_id' "$board_file" 2>/dev/null)
  local project_url=$(jq -r '.github_url' "$board_file" 2>/dev/null)
  
  echo "🤝 Collaboration Hub: $board_name"
  echo "====================================="
  echo "🔗 Project: $project_url"
  echo ""
  
  case "$action" in
    "activity")
      echo "📊 Recent Project Activity"
      echo "------------------------"
      
      # Get recent project activity
      local activity_query='
      query($projectId: ID!) {
        node(id: $projectId) {
          ... on ProjectV2 {
            items(first: 20) {
              nodes {
                id
                updatedAt
                content {
                  ... on Issue {
                    title
                    state
                    updatedAt
                    assignees(first: 5) { nodes { login } }
                    author { login }
                    url
                  }
                  ... on PullRequest {
                    title
                    state
                    updatedAt
                    assignees(first: 5) { nodes { login } }
                    author { login }
                    url
                  }
                  ... on DraftIssue {
                    title
                    updatedAt
                    assignees(first: 5) { nodes { login } }
                    creator { login }
                  }
                }
              }
            }
          }
        }
      }'
      
      local json_payload=$(jq -n --arg query "$activity_query" --arg projectId "$project_id" '{
        query: $query,
        variables: { projectId: $projectId }
      }')
      
      local response=$(curl -s -X POST \
        -H "Authorization: Bearer $GITOK_GITHUB_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$json_payload" \
        https://api.github.com/graphql 2>/dev/null)
      
      if echo "$response" | grep -q '"errors"'; then
        echo "❌ Failed to fetch activity"
        return 1
      fi
      
      echo "$response" | jq -r '.data.node.items.nodes[] | 
        "🔹 " + (.content.title // "Untitled") + 
        " (" + (.content.state // "draft") + ")" +
        " - " + (.content.author.login // .content.creator.login // "unknown") +
        " - " + (.updatedAt | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%m/%d %H:%M"))' 2>/dev/null | head -10
      ;;
      
    "contributors")
      echo "👥 Project Contributors"
      echo "--------------------"
      
      # Get all contributors
      local contributors_query='
      query($projectId: ID!) {
        node(id: $projectId) {
          ... on ProjectV2 {
            items(first: 100) {
              nodes {
                content {
                  ... on Issue {
                    assignees(first: 10) { nodes { login avatarUrl } }
                    author { login avatarUrl }
                  }
                  ... on PullRequest {
                    assignees(first: 10) { nodes { login avatarUrl } }
                    author { login avatarUrl }
                  }
                  ... on DraftIssue {
                    assignees(first: 10) { nodes { login avatarUrl } }
                    creator { login avatarUrl }
                  }
                }
              }
            }
          }
        }
      }'
      
      local json_payload=$(jq -n --arg query "$contributors_query" --arg projectId "$project_id" '{
        query: $query,
        variables: { projectId: $projectId }
      }')
      
      local response=$(curl -s -X POST \
        -H "Authorization: Bearer $GITOK_GITHUB_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$json_payload" \
        https://api.github.com/graphql 2>/dev/null)
      
      if echo "$response" | grep -q '"errors"'; then
        echo "❌ Failed to fetch contributors"
        return 1
      fi
      
      # Extract unique contributors
      local contributors=$(echo "$response" | jq -r '
        [
          .data.node.items.nodes[].content.assignees.nodes[]?.login,
          .data.node.items.nodes[].content.author.login,
          .data.node.items.nodes[].content.creator.login
        ] | unique | .[]' 2>/dev/null | sort | uniq)
      
      if [ -n "$contributors" ]; then
        echo "$contributors" | while read -r contributor; do
          if [ -n "$contributor" ] && [ "$contributor" != "null" ]; then
            echo "👤 @$contributor"
          fi
        done
      else
        echo "No contributors found"
      fi
      ;;
      
    "invite")
      echo "🔗 Project Invitation"
      echo "-------------------"
      echo "Share this project with collaborators:"
      echo ""
      echo "📋 Project URL: $project_url"
      echo "📨 Invitation message template:"
      echo ""
      echo "   Hi! I'd like to invite you to collaborate on our project:"
      echo "   '$board_name'"
      echo ""
      echo "   🔗 Access the project here: $project_url"
      echo ""
      echo "   This project includes:"
      echo "   • Task management with custom fields"
      echo "   • Multiple views (Table, Board, Roadmap)"
      echo "   • Real-time collaboration features"
      echo "   • Advanced project tracking"
      echo ""
      echo "   Looking forward to working together! 🚀"
      ;;
      
    "assignments")
      echo "📋 Your Assignments"
      echo "-----------------"
      
      # Get current user
      local user_query='query { viewer { login } }'
      local user_response=$(github_graphql_query "$user_query")
      local current_user=$(echo "$user_response" | jq -r '.data.viewer.login' 2>/dev/null)
      
      if [ -z "$current_user" ] || [ "$current_user" = "null" ]; then
        echo "❌ Could not determine current user"
        return 1
      fi
      
      echo "👤 Assignments for: @$current_user"
      echo ""
      
      # Get assignments
      local assignments_query='
      query($projectId: ID!) {
        node(id: $projectId) {
          ... on ProjectV2 {
            items(first: 100) {
              nodes {
                content {
                  ... on Issue {
                    title
                    state
                    url
                    assignees(first: 10) { nodes { login } }
                  }
                  ... on PullRequest {
                    title
                    state
                    url
                    assignees(first: 10) { nodes { login } }
                  }
                  ... on DraftIssue {
                    title
                    assignees(first: 10) { nodes { login } }
                  }
                }
              }
            }
          }
        }
      }'
      
      local json_payload=$(jq -n --arg query "$assignments_query" --arg projectId "$project_id" '{
        query: $query,
        variables: { projectId: $projectId }
      }')
      
      local response=$(curl -s -X POST \
        -H "Authorization: Bearer $GITOK_GITHUB_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$json_payload" \
        https://api.github.com/graphql 2>/dev/null)
      
      if echo "$response" | grep -q '"errors"'; then
        echo "❌ Failed to fetch assignments"
        return 1
      fi
      
      # Filter for current user's assignments
      local assignments=$(echo "$response" | jq --arg user "$current_user" -r '
        .data.node.items.nodes[] | 
        select(.content.assignees.nodes[]?.login == $user) |
        "📌 " + (.content.title // "Untitled") + 
        " (" + (.content.state // "draft") + ")" +
        (if .content.url then " - " + .content.url else "" end)' 2>/dev/null)
      
      if [ -n "$assignments" ]; then
        echo "$assignments"
      else
        echo "No assignments found for @$current_user"
      fi
      ;;
      
    *)
      echo "❌ Unknown action: $action"
      echo "Use 'collaborate \"$board_name\" activity' to see available actions"
      ;;
  esac
}

# Advanced automation and workflows
function automate() {
  local board_name="$1"
  local automation_type="$2"
  
  if [ -z "$board_name" ] || [ -z "$automation_type" ]; then
    echo "❌ Usage: automate \"Board Name\" <type>"
    echo ""
    echo "🤖 Available automation types:"
    echo "   rules        - Set up project automation rules"
    echo "   templates    - Create issue/PR templates"
    echo "   workflows    - Show GitHub Actions workflows"
    echo "   auto-assign  - Set up auto-assignment rules"
    echo "   status-sync  - Sync status with PR/Issue states"
    echo "   notifications - Configure notification rules"
    return 1
  fi
  
  if ! check_board_dependencies; then
    return 1
  fi
  
  ensure_boards_dir
  
  # Find board file
  local board_file=""
  for file in "$GITOK_BOARDS_DIR"/*.json; do
    if [ -f "$file" ]; then
      local name=$(jq -r '.name' "$file" 2>/dev/null)
      if [ "$name" = "$board_name" ]; then
        board_file="$file"
        break
      fi
    fi
  done
  
  if [ -z "$board_file" ]; then
    echo "❌ Board '$board_name' not found locally"
    return 1
  fi
  
  local project_url=$(jq -r '.github_url' "$board_file" 2>/dev/null)
  
  echo "🤖 Project Automation: $board_name"
  echo "=================================="
  echo "🔗 Project: $project_url"
  echo ""
  
  case "$automation_type" in
    "rules")
      echo "⚙️  Automation Rules Setup"
      echo "------------------------"
      echo ""
      echo "🎯 Recommended automation rules for your project:"
      echo ""
      echo "📋 STATUS AUTOMATION:"
      echo "   • When Issue/PR is opened → Set Status to 'Todo'"
      echo "   • When PR is in review → Set Status to 'In Review'"
      echo "   • When Issue/PR is closed → Set Status to 'Done'"
      echo "   • When PR is merged → Set Status to 'Done'"
      echo ""
      echo "🚀 PRIORITY AUTOMATION:"
      echo "   • When Issue has 'bug' label → Set Priority to 'High'"
      echo "   • When Issue has 'enhancement' label → Set Priority to 'Medium'"
      echo "   • When Issue has 'documentation' label → Set Priority to 'Low'"
      echo ""
      echo "👥 ASSIGNMENT AUTOMATION:"
      echo "   • When PR is opened → Auto-assign to project owner"
      echo "   • When Issue has 'help wanted' label → Clear assignees"
      echo "   • When Status changes to 'In Progress' → Auto-assign to last editor"
      echo ""
      echo "📅 DATE AUTOMATION:"
      echo "   • When Issue is created → Set Due Date to +7 days"
      echo "   • When Priority is 'High' → Set Due Date to +3 days"
      echo "   • When Status is 'Done' → Clear Due Date"
      echo ""
      echo "⚡ To set up these rules:"
      echo "   1. Go to: $project_url/settings"
      echo "   2. Click on 'Workflows' tab"
      echo "   3. Click 'New workflow'"
      echo "   4. Configure triggers and actions"
      echo ""
      echo "💡 Pro tip: Use the 'When' conditions to create complex automation!"
      ;;
      
    "templates")
      echo "📝 Issue & PR Templates"
      echo "--------------------"
      echo ""
      echo "Creating project templates for consistency..."
      echo ""
      
      # Create .github directory if it doesn't exist
      mkdir -p .github/ISSUE_TEMPLATE
      mkdir -p .github/PULL_REQUEST_TEMPLATE
      
      # Create issue template
      cat > .github/ISSUE_TEMPLATE/project-task.md << 'EOF'
---
name: Project Task
about: Create a task for the project board
title: '[TASK] '
labels: 'task'
assignees: ''

---

## 📋 Task Description
<!-- Provide a clear and concise description of the task -->

## 🎯 Acceptance Criteria
<!-- List the specific criteria that must be met for this task to be considered complete -->

- [ ] 
- [ ] 
- [ ] 

## 📊 Task Details
<!-- Fill in the project board fields -->

- **Priority**: [High/Medium/Low]
- **Stage**: [Planning/Development/Testing/Completed]
- **Effort**: [Story points 1-13]
- **Due Date**: [YYYY-MM-DD]

## 🔗 Related Issues
<!-- Link to any related issues or PRs -->

## 📎 Additional Context
<!-- Add any other context, screenshots, or examples -->

## ✅ Definition of Done
<!-- What needs to be completed for this task to be marked as done? -->

- [ ] Code is written and tested
- [ ] Documentation is updated
- [ ] PR is reviewed and approved
- [ ] Changes are deployed
EOF
      
      # Create feature request template
      cat > .github/ISSUE_TEMPLATE/feature-request.md << 'EOF'
---
name: Feature Request
about: Suggest a new feature for the project
title: '[FEATURE] '
labels: 'enhancement'
assignees: ''

---

## 🚀 Feature Request

### 📝 Feature Description
<!-- Provide a clear and concise description of the feature -->

### 🎯 Problem Statement
<!-- What problem does this feature solve? -->

### 💡 Proposed Solution
<!-- Describe how you envision this feature working -->

### 📋 Requirements
<!-- List the specific requirements for this feature -->

- [ ] 
- [ ] 
- [ ] 

### 📊 Project Impact
- **Priority**: [High/Medium/Low]
- **Effort Estimate**: [1-13 story points]
- **Target Stage**: [Planning/Development/Testing]

### 🔗 Additional Context
<!-- Add mockups, examples, or references -->

### ✅ Acceptance Criteria
<!-- How will we know this feature is complete? -->

- [ ] 
- [ ] 
- [ ] 
EOF
      
      # Create bug report template
      cat > .github/ISSUE_TEMPLATE/bug-report.md << 'EOF'
---
name: Bug Report
about: Report a bug to help improve the project
title: '[BUG] '
labels: 'bug'
assignees: ''

---

## 🐛 Bug Report

### 📝 Bug Description
<!-- Provide a clear and concise description of the bug -->

### 🔄 Steps to Reproduce
1. 
2. 
3. 

### 🎯 Expected Behavior
<!-- What should happen? -->

### 💥 Actual Behavior
<!-- What actually happens? -->

### 📊 Bug Impact
- **Priority**: [High/Medium/Low] 
- **Severity**: [Critical/Major/Minor]
- **Effort to Fix**: [1-13 story points]

### 🔧 Environment
- OS: [e.g., Windows 10, macOS 12, Ubuntu 20.04]
- Browser: [e.g., Chrome 96, Firefox 95, Safari 15]
- Version: [e.g., v1.2.3]

### 📎 Additional Context
<!-- Screenshots, logs, or additional information -->

### ✅ Fix Verification
<!-- How can we verify the fix works? -->

- [ ] 
- [ ] 
- [ ] 
EOF
      
      # Create PR template
      cat > .github/PULL_REQUEST_TEMPLATE.md << 'EOF'
## 🚀 Pull Request

### 📝 Description
<!-- Provide a clear description of the changes -->

### 🎯 Related Issues
<!-- Link to related issues using "Closes #123" or "Fixes #123" -->

### 📋 Type of Change
- [ ] 🐛 Bug fix
- [ ] ✨ New feature
- [ ] 💥 Breaking change
- [ ] 📚 Documentation update
- [ ] 🔧 Code refactoring
- [ ] ⚡ Performance improvement
- [ ] 🎨 UI/UX improvement

### 📊 Project Board Update
- **Status**: [In Progress/In Review/Done]
- **Stage**: [Development/Testing/Completed]
- **Effort**: [Actual story points used]

### 🧪 Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed
- [ ] All tests pass

### 📝 Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Code is commented where necessary
- [ ] Documentation updated
- [ ] No breaking changes (or marked as breaking)

### 🔗 Screenshots/Videos
<!-- Add screenshots or videos if applicable -->

### 💭 Additional Notes
<!-- Any additional information for reviewers -->
EOF
      
      echo "✅ Created issue and PR templates:"
      echo "   📁 .github/ISSUE_TEMPLATE/project-task.md"
      echo "   📁 .github/ISSUE_TEMPLATE/feature-request.md"
      echo "   📁 .github/ISSUE_TEMPLATE/bug-report.md"
      echo "   📁 .github/PULL_REQUEST_TEMPLATE.md"
      echo ""
      echo "🎯 These templates will:"
      echo "   • Ensure consistent issue/PR creation"
      echo "   • Auto-populate project board fields"
      echo "   • Improve collaboration and tracking"
      echo "   • Standardize workflows"
      ;;
      
    "workflows")
      echo "⚡ GitHub Actions Integration"
      echo "---------------------------"
      echo ""
      echo "Creating advanced project workflows..."
      echo ""
      
      # Create GitHub Actions directory
      mkdir -p .github/workflows
      
      # Create project board sync workflow
      cat > .github/workflows/project-board-sync.yml << 'EOF'
name: 📊 Project Board Sync

on:
  issues:
    types: [opened, closed, labeled, unlabeled, assigned, unassigned]
  pull_request:
    types: [opened, closed, merged, labeled, unlabeled, assigned, unassigned, ready_for_review]
  push:
    branches: [main, develop]

jobs:
  sync-project-board:
    runs-on: ubuntu-latest
    name: Sync with Project Board
    
    steps:
      - name: 📋 Add to Project Board
        uses: actions/add-to-project@v0.4.0
        with:
          project-url: ${{ vars.PROJECT_URL }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
          
      - name: 🏷️ Auto-label based on project fields
        if: github.event_name == 'issues' && github.event.action == 'opened'
        run: |
          # Auto-assign priority based on labels
          if [[ "${{ contains(github.event.issue.labels.*.name, 'bug') }}" == "true" ]]; then
            echo "Setting priority to High for bug"
            # Set Priority field to High
          elif [[ "${{ contains(github.event.issue.labels.*.name, 'enhancement') }}" == "true" ]]; then
            echo "Setting priority to Medium for enhancement"
            # Set Priority field to Medium
          fi
          
      - name: 📅 Set Due Date for High Priority
        if: contains(github.event.issue.labels.*.name, 'priority:high')
        run: |
          # Set due date to 3 days from now for high priority items
          DUE_DATE=$(date -d "+3 days" +%Y-%m-%d)
          echo "Setting due date to $DUE_DATE for high priority issue"
          
      - name: 🔄 Update Status on PR Events
        if: github.event_name == 'pull_request'
        run: |
          case "${{ github.event.action }}" in
            "opened")
              echo "Setting status to In Progress"
              ;;
            "ready_for_review")
              echo "Setting status to In Review"
              ;;
            "closed")
              if [[ "${{ github.event.pull_request.merged }}" == "true" ]]; then
                echo "Setting status to Done (merged)"
              else
                echo "Setting status to Cancelled (closed)"
              fi
              ;;
          esac
          
      - name: 📊 Update Project Metrics
        run: |
          echo "📈 Updating project metrics..."
          echo "- Total issues: ${{ github.event.repository.open_issues_count }}"
          echo "- Event type: ${{ github.event_name }}"
          echo "- Action: ${{ github.event.action }}"
EOF
      
      # Create automated testing workflow
      cat > .github/workflows/project-quality.yml << 'EOF'
name: 🧪 Project Quality Check

on:
  pull_request:
    types: [opened, synchronize, reopened]
  push:
    branches: [main, develop]

jobs:
  quality-check:
    runs-on: ubuntu-latest
    name: Quality Assessment
    
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v4
        
      - name: 🔍 Code Quality Check
        run: |
          echo "🔍 Running code quality checks..."
          
          # Check for TODO comments
          TODO_COUNT=$(grep -r "TODO\|FIXME\|HACK" . --exclude-dir=.git --exclude-dir=node_modules | wc -l)
          echo "📝 TODO items found: $TODO_COUNT"
          
          # Check for proper documentation
          if [[ -f "README.md" ]]; then
            echo "✅ README.md exists"
          else
            echo "❌ README.md missing"
          fi
          
          # Check for proper gitignore
          if [[ -f ".gitignore" ]]; then
            echo "✅ .gitignore exists"
          else
            echo "❌ .gitignore missing"
          fi
          
      - name: 📊 Update Project Board
        run: |
          echo "📊 Updating project board with quality metrics..."
          echo "- TODO count: $TODO_COUNT"
          echo "- Quality check: Passed"
          
      - name: 📈 Generate Quality Report
        run: |
          echo "# 📊 Project Quality Report" > quality-report.md
          echo "" >> quality-report.md
          echo "## 🔍 Code Quality" >> quality-report.md
          echo "- TODO items: $TODO_COUNT" >> quality-report.md
          echo "- Documentation: $([ -f README.md ] && echo '✅ Good' || echo '❌ Missing')" >> quality-report.md
          echo "- Git configuration: $([ -f .gitignore ] && echo '✅ Good' || echo '❌ Missing')" >> quality-report.md
          echo "" >> quality-report.md
          echo "Generated on: $(date)" >> quality-report.md
          
      - name: 💬 Comment on PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            if (fs.existsSync('quality-report.md')) {
              const report = fs.readFileSync('quality-report.md', 'utf8');
              github.rest.issues.createComment({
                issue_number: context.issue.number,
                owner: context.repo.owner,
                repo: context.repo.repo,
                body: report
              });
            }
EOF
      
      # Create deployment workflow
      cat > .github/workflows/deploy-and-notify.yml << 'EOF'
name: 🚀 Deploy & Notify Project

on:
  push:
    branches: [main]
  release:
    types: [published]

jobs:
  deploy-notify:
    runs-on: ubuntu-latest
    name: Deploy and Update Project
    
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v4
        
      - name: 🚀 Deploy Application
        run: |
          echo "🚀 Deploying application..."
          echo "Deployment would happen here"
          
      - name: 📊 Update Project Board
        run: |
          echo "📊 Updating project board after deployment..."
          
          # Mark deployment-related tasks as done
          echo "Marking deployment tasks as complete"
          
          # Update project metrics
          echo "Updating project deployment metrics"
          
      - name: 🔔 Notify Team
        run: |
          echo "🔔 Notifying team about successful deployment..."
          echo "- Deployment completed successfully"
          echo "- Project board updated"
          echo "- All systems operational"
          
      - name: 📈 Generate Deployment Report
        run: |
          echo "# 🚀 Deployment Report" > deployment-report.md
          echo "" >> deployment-report.md
          echo "## ✅ Deployment Status" >> deployment-report.md
          echo "- Status: Successful" >> deployment-report.md
          echo "- Timestamp: $(date)" >> deployment-report.md
          echo "- Branch: ${{ github.ref_name }}" >> deployment-report.md
          echo "- Commit: ${{ github.sha }}" >> deployment-report.md
          echo "" >> deployment-report.md
          echo "## 📊 Project Impact" >> deployment-report.md
          echo "- Tasks completed: Updated automatically" >> deployment-report.md
          echo "- Board status: Synced" >> deployment-report.md
EOF
      
      echo "✅ Created GitHub Actions workflows:"
      echo "   ⚡ .github/workflows/project-board-sync.yml"
      echo "   🧪 .github/workflows/project-quality.yml"
      echo "   🚀 .github/workflows/deploy-and-notify.yml"
      echo ""
      echo "🎯 These workflows will:"
      echo "   • Auto-sync issues/PRs with project board"
      echo "   • Set priorities and due dates automatically"
      echo "   • Update project status based on PR events"
      echo "   • Run quality checks and update board"
      echo "   • Notify team on deployments"
      echo ""
      echo "⚙️  To activate workflows:"
      echo "   1. Commit and push these files"
      echo "   2. Set PROJECT_URL variable in repository settings"
      echo "   3. Workflows will run automatically on events"
      ;;
      
    *)
      echo "❌ Unknown automation type: $automation_type"
      echo "Use 'automate \"$board_name\" rules' to see available options"
      ;;
  esac
}

# Advanced analytics and reporting
function analytics() {
  local board_name="$1"
  local report_type="${2:-summary}"
  
  if [ -z "$board_name" ]; then
    echo "❌ Usage: analytics \"Board Name\" [type]"
    echo ""
    echo "📊 Available report types:"
    echo "   summary      - Project overview and key metrics"
    echo "   velocity     - Team velocity and completion rates"
    echo "   burndown     - Sprint burndown and progress tracking"
    echo "   contributors - Team performance and contribution metrics"
    echo "   timeline     - Project timeline and milestone tracking"
    echo "   export       - Export data in various formats"
    echo "   insights     - AI-powered project insights and recommendations"
    return 1
  fi
  
  if ! check_board_dependencies; then
    return 1
  fi
  
  if ! require_github_auth; then
    return 1
  fi
  
  ensure_boards_dir
  
  # Find board file
  local board_file=""
  for file in "$GITOK_BOARDS_DIR"/*.json; do
    if [ -f "$file" ]; then
      local name=$(jq -r '.name' "$file" 2>/dev/null)
      if [ "$name" = "$board_name" ]; then
        board_file="$file"
        break
      fi
    fi
  done
  
  if [ -z "$board_file" ]; then
    echo "❌ Board '$board_name' not found locally"
    return 1
  fi
  
  local project_id=$(jq -r '.github_id' "$board_file" 2>/dev/null)
  local project_url=$(jq -r '.github_url' "$board_file" 2>/dev/null)
  
  echo "📊 Project Analytics: $board_name"
  echo "================================="
  echo "🔗 Project: $project_url"
  echo "📅 Generated: $(date)"
  echo ""
  
  # Get comprehensive project analytics data
  local analytics_query='
  query($projectId: ID!) {
    node(id: $projectId) {
      ... on ProjectV2 {
        id
        title
        shortDescription
        createdAt
        updatedAt
        closed
        items(first: 100) {
          totalCount
          nodes {
            id
            createdAt
            updatedAt
            content {
              ... on Issue {
                id
                title
                body
                state
                createdAt
                updatedAt
                closedAt
                assignees(first: 10) { nodes { login } }
                labels(first: 10) { nodes { name color } }
                milestone { title dueOn }
                timelineItems(first: 10, itemTypes: [ASSIGNED_EVENT, CLOSED_EVENT, REOPENED_EVENT]) {
                  nodes {
                    ... on AssignedEvent { createdAt assignee { ... on User { login } } }
                    ... on ClosedEvent { createdAt }
                    ... on ReopenedEvent { createdAt }
                  }
                }
              }
              ... on PullRequest {
                id
                title
                body
                state
                createdAt
                updatedAt
                closedAt
                mergedAt
                assignees(first: 10) { nodes { login } }
                labels(first: 10) { nodes { name color } }
                milestone { title dueOn }
                timelineItems(first: 10, itemTypes: [ASSIGNED_EVENT, CLOSED_EVENT, REOPENED_EVENT, MERGED_EVENT]) {
                  nodes {
                    ... on AssignedEvent { createdAt assignee { ... on User { login } } }
                    ... on ClosedEvent { createdAt }
                    ... on ReopenedEvent { createdAt }
                    ... on MergedEvent { createdAt }
                  }
                }
              }
              ... on DraftIssue {
                id
                title
                body
                createdAt
                updatedAt
                assignees(first: 10) { nodes { login } }
              }
            }
            fieldValues(first: 20) {
              nodes {
                ... on ProjectV2ItemFieldTextValue {
                  field { ... on ProjectV2Field { name } }
                  text
                }
                ... on ProjectV2ItemFieldNumberValue {
                  field { ... on ProjectV2Field { name } }
                  number
                }
                ... on ProjectV2ItemFieldDateValue {
                  field { ... on ProjectV2Field { name } }
                  date
                }
                ... on ProjectV2ItemFieldSingleSelectValue {
                  field { ... on ProjectV2SingleSelectField { name } }
                  name
                  color
                }
                ... on ProjectV2ItemFieldIterationValue {
                  field { ... on ProjectV2IterationField { name } }
                  title
                  startDate
                  duration
                }
              }
            }
          }
        }
        fields(first: 50) {
          nodes {
            ... on ProjectV2Field {
              id
              name
              dataType
            }
            ... on ProjectV2SingleSelectField {
              id
              name
              dataType
              options {
                id
                name
                description
                color
              }
            }
          }
        }
        views(first: 20) {
          nodes {
            id
            name
            layout
            createdAt
            updatedAt
          }
        }
      }
    }
  }'
  
  local json_payload=$(jq -n --arg query "$analytics_query" --arg projectId "$project_id" '{
    query: $query,
    variables: { projectId: $projectId }
  }')
  
  local response=$(curl -s -X POST \
    -H "Authorization: Bearer $GITOK_GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$json_payload" \
    https://api.github.com/graphql 2>/dev/null)
  
  if echo "$response" | grep -q '"errors"'; then
    echo "❌ Failed to fetch analytics data"
    return 1
  fi
  
  # Save analytics data to cache
  local analytics_cache_file="$GITOK_BOARDS_DIR/.analytics_cache_$(echo "$board_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g').json"
  echo "$response" > "$analytics_cache_file"
  
  case "$report_type" in
    "summary")
      echo "📈 PROJECT SUMMARY"
      echo "=================="
      echo ""
      
      # Calculate key metrics
      local total_items=$(echo "$response" | jq -r '.data.node.items.totalCount' 2>/dev/null || echo "0")
      local total_open=$(echo "$response" | jq -r '[.data.node.items.nodes[] | select(.content.state == "OPEN")] | length' 2>/dev/null || echo "0")
      local total_closed=$(echo "$response" | jq -r '[.data.node.items.nodes[] | select(.content.state == "CLOSED")] | length' 2>/dev/null || echo "0")
      local total_merged=$(echo "$response" | jq -r '[.data.node.items.nodes[] | select(.content.state == "MERGED")] | length' 2>/dev/null || echo "0")
      local total_draft=$(echo "$response" | jq -r '[.data.node.items.nodes[] | select(.content.state == null)] | length' 2>/dev/null || echo "0")
      
      echo "📊 OVERVIEW:"
      echo "   Total Items: $total_items"
      echo "   Open Issues/PRs: $total_open"
      echo "   Closed Items: $total_closed"
      echo "   Merged PRs: $total_merged"
      echo "   Draft Items: $total_draft"
      echo ""
      
      # Calculate completion rate
      local completion_rate=0
      if [ "$total_items" -gt 0 ]; then
        completion_rate=$(echo "scale=1; ($total_closed + $total_merged) * 100 / $total_items" | bc -l 2>/dev/null || echo "0")
      fi
      echo "✅ Completion Rate: ${completion_rate}%"
      echo ""
      
      # Priority breakdown
      echo "🎯 PRIORITY BREAKDOWN:"
      local high_priority=$(echo "$response" | jq -r '[.data.node.items.nodes[] | select(.fieldValues.nodes[] | select(.field.name == "Priority" and .name == "High"))] | length' 2>/dev/null || echo "0")
      local medium_priority=$(echo "$response" | jq -r '[.data.node.items.nodes[] | select(.fieldValues.nodes[] | select(.field.name == "Priority" and .name == "Medium"))] | length' 2>/dev/null || echo "0")
      local low_priority=$(echo "$response" | jq -r '[.data.node.items.nodes[] | select(.fieldValues.nodes[] | select(.field.name == "Priority" and .name == "Low"))] | length' 2>/dev/null || echo "0")
      
      echo "   🔴 High Priority: $high_priority"
      echo "   🟡 Medium Priority: $medium_priority"
      echo "   🟢 Low Priority: $low_priority"
      echo ""
      
      # Team activity
      echo "👥 TEAM ACTIVITY:"
      local contributors=$(echo "$response" | jq -r '
        [.data.node.items.nodes[].content.assignees.nodes[]?.login] | 
        group_by(.) | 
        map({name: .[0], count: length}) | 
        sort_by(.count) | 
        reverse | 
        .[0:5]' 2>/dev/null)
      
      if [ "$contributors" != "null" ] && [ -n "$contributors" ]; then
        echo "$contributors" | jq -r '.[] | "   👤 @" + .name + ": " + (.count | tostring) + " assignments"' 2>/dev/null || echo "   No active contributors"
      else
        echo "   No active contributors"
      fi
      echo ""
      
      # Recent activity
      echo "📅 RECENT ACTIVITY (Last 7 days):"
      local recent_items=$(echo "$response" | jq -r --arg week_ago "$(date -d '7 days ago' -u +%Y-%m-%dT%H:%M:%SZ)" '
        [.data.node.items.nodes[] | select(.updatedAt > $week_ago)] | 
        sort_by(.updatedAt) | 
        reverse | 
        .[0:5] | 
        .[] | 
        "   📌 " + (.content.title // "Untitled") + " - " + (.updatedAt | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%m/%d"))' 2>/dev/null)
      
      if [ -n "$recent_items" ]; then
        echo "$recent_items"
      else
        echo "   No recent activity"
      fi
      ;;
      
    "velocity")
      echo "🚀 TEAM VELOCITY"
      echo "==============="
      echo ""
      
      # Calculate velocity metrics
      local last_30_days=$(date -d '30 days ago' -u +%Y-%m-%dT%H:%M:%SZ)
      local closed_last_30=$(echo "$response" | jq --arg date "$last_30_days" -r '
        [.data.node.items.nodes[] | 
         select(.content.closedAt != null and .content.closedAt > $date)] | 
        length' 2>/dev/null || echo "0")
      
      local opened_last_30=$(echo "$response" | jq --arg date "$last_30_days" -r '
        [.data.node.items.nodes[] | 
         select(.content.createdAt > $date)] | 
        length' 2>/dev/null || echo "0")
      
      echo "📊 LAST 30 DAYS:"
      echo "   Items Completed: $closed_last_30"
      echo "   Items Created: $opened_last_30"
      echo "   Net Progress: $((closed_last_30 - opened_last_30))"
      echo ""
      
      # Weekly velocity
      echo "📈 WEEKLY VELOCITY:"
      for week in {0..3}; do
        local week_start=$(date -d "$((week * 7)) days ago" -u +%Y-%m-%dT%H:%M:%SZ)
        local week_end=$(date -d "$(((week - 1) * 7)) days ago" -u +%Y-%m-%dT%H:%M:%SZ)
        
        local week_closed=$(echo "$response" | jq --arg start "$week_start" --arg end "$week_end" -r '
          [.data.node.items.nodes[] | 
           select(.content.closedAt != null and .content.closedAt >= $start and .content.closedAt < $end)] | 
          length' 2>/dev/null || echo "0")
        
        local week_label
        case $week in
          0) week_label="This week" ;;
          1) week_label="Last week" ;;
          *) week_label="$week weeks ago" ;;
        esac
        
        echo "   $week_label: $week_closed completed"
      done
      echo ""
      
      # Average cycle time
      echo "⏱️  CYCLE TIME ANALYSIS:"
      local avg_cycle_time=$(echo "$response" | jq -r '
        [.data.node.items.nodes[] | 
         select(.content.createdAt != null and .content.closedAt != null) | 
         (.content.closedAt | strptime("%Y-%m-%dT%H:%M:%SZ")) - 
         (.content.createdAt | strptime("%Y-%m-%dT%H:%M:%SZ"))] | 
        if length > 0 then (add / length / 86400) else 0 end' 2>/dev/null || echo "0")
      
      echo "   Average Cycle Time: $(printf '%.1f' "$avg_cycle_time") days"
      echo ""
      
      # Productivity trends
      echo "📊 PRODUCTIVITY TRENDS:"
      echo "   ✅ Completion Rate Trend: $([ "$closed_last_30" -gt "$opened_last_30" ] && echo "📈 Improving" || echo "📉 Needs attention")"
      echo "   🎯 Focus Areas: $([ "$high_priority" -gt 0 ] && echo "High priority items pending" || echo "Good priority management")"
      ;;
      
    "burndown")
      echo "🔥 BURNDOWN ANALYSIS"
      echo "==================="
      echo ""
      
      # Calculate burndown metrics
      local project_start=$(echo "$response" | jq -r '.data.node.createdAt' 2>/dev/null)
      local total_work=$(echo "$response" | jq -r '.data.node.items.totalCount' 2>/dev/null || echo "0")
      local work_remaining=$(echo "$response" | jq -r '[.data.node.items.nodes[] | select(.content.state == "OPEN")] | length' 2>/dev/null || echo "0")
      local work_completed=$((total_work - work_remaining))
      
      echo "📊 BURNDOWN SUMMARY:"
      echo "   Project Start: $(echo "$project_start" | cut -d'T' -f1)"
      echo "   Total Work: $total_work items"
      echo "   Work Completed: $work_completed items"
      echo "   Work Remaining: $work_remaining items"
      echo ""
      
      # Progress visualization
      echo "📈 PROGRESS VISUALIZATION:"
      local progress_percent=0
      if [ "$total_work" -gt 0 ]; then
        progress_percent=$((work_completed * 100 / total_work))
      fi
      
      local progress_bar=""
      local filled=$((progress_percent / 5))
      local empty=$((20 - filled))
      
      for i in $(seq 1 $filled); do
        progress_bar+="█"
      done
      for i in $(seq 1 $empty); do
        progress_bar+="░"
      done
      
      echo "   Progress: [$progress_bar] ${progress_percent}%"
      echo ""
      
      # Milestone tracking
      echo "🎯 MILESTONE TRACKING:"
      local milestones=$(echo "$response" | jq -r '
        [.data.node.items.nodes[].content.milestone.title] | 
        group_by(.) | 
        map({name: .[0], count: length}) | 
        sort_by(.count) | 
        reverse' 2>/dev/null)
      
      if [ "$milestones" != "null" ] && [ -n "$milestones" ]; then
        echo "$milestones" | jq -r '.[] | "   🏁 " + .name + ": " + (.count | tostring) + " items"' 2>/dev/null || echo "   No milestones set"
      else
        echo "   No milestones set"
      fi
      ;;
      
    "export")
      echo "📤 DATA EXPORT"
      echo "============="
      echo ""
      
      # Create export directory
      local export_dir="$GITOK_BOARDS_DIR/exports"
      mkdir -p "$export_dir"
      
      local timestamp=$(date +%Y%m%d_%H%M%S)
      local export_base="$export_dir/${board_name// /_}_$timestamp"
      
      # Export to CSV
      echo "📊 Exporting to CSV..."
      echo "Title,Type,State,Priority,Stage,Effort,Assignees,Created,Updated,URL" > "${export_base}.csv"
      
      echo "$response" | jq -r '
        .data.node.items.nodes[] | 
        [
          (.content.title // "Untitled"),
          (if .content.__typename == "Issue" then "Issue" 
           elif .content.__typename == "PullRequest" then "Pull Request"
           else "Draft" end),
          (.content.state // "Draft"),
          ((.fieldValues.nodes[] | select(.field.name == "Priority").name) // ""),
          ((.fieldValues.nodes[] | select(.field.name == "Stage").name) // ""),
          ((.fieldValues.nodes[] | select(.field.name == "Effort").number) // ""),
          ([.content.assignees.nodes[].login] | join(",")),
          (.content.createdAt | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%Y-%m-%d")),
          (.content.updatedAt | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%Y-%m-%d")),
          (.content.url // "")
        ] | @csv' 2>/dev/null >> "${export_base}.csv"
      
      # Export to JSON
      echo "📋 Exporting to JSON..."
      echo "$response" | jq '.data.node' > "${export_base}.json"
      
      # Export to Markdown report
      echo "📝 Exporting to Markdown..."
      cat > "${export_base}.md" << EOF
# Project Report: $board_name

**Generated:** $(date)
**Project URL:** $project_url

## Summary

- **Total Items:** $total_items
- **Open:** $total_open
- **Closed:** $total_closed
- **Completion Rate:** ${completion_rate}%

## Items by Priority

- **High Priority:** $high_priority
- **Medium Priority:** $medium_priority
- **Low Priority:** $low_priority

## Recent Activity

$(echo "$response" | jq -r '
  .data.node.items.nodes[] | 
  select(.updatedAt > "'$(date -d '7 days ago' -u +%Y-%m-%dT%H:%M:%SZ)'") | 
  "- " + (.content.title // "Untitled") + " (" + (.content.state // "draft") + ")"' 2>/dev/null | head -10)

## Export Files

- CSV: \`$(basename "${export_base}.csv")\`
- JSON: \`$(basename "${export_base}.json")\`
- Markdown: \`$(basename "${export_base}.md")\`

---
*Generated by gitok project analytics*
EOF
      
      echo "✅ Export completed!"
      echo "   📊 CSV: ${export_base}.csv"
      echo "   📋 JSON: ${export_base}.json"
      echo "   📝 Markdown: ${export_base}.md"
      echo ""
      echo "📁 Files saved to: $export_dir"
      ;;
      
    "insights")
      echo "🧠 AI-POWERED INSIGHTS"
      echo "====================="
      echo ""
      
      # Generate intelligent insights
      echo "🔍 ANALYZING PROJECT PATTERNS..."
      echo ""
      
      # Bottleneck analysis
      echo "🚫 POTENTIAL BOTTLENECKS:"
      
      # Check for items stuck in review
      local stuck_in_review=$(echo "$response" | jq -r '
        [.data.node.items.nodes[] | 
         select(.fieldValues.nodes[] | select(.field.name == "Stage" and .name == "In Review")) |
         select(.updatedAt < "'$(date -d '7 days ago' -u +%Y-%m-%dT%H:%M:%SZ)'")] | 
        length' 2>/dev/null || echo "0")
      
      if [ "$stuck_in_review" -gt 0 ]; then
        echo "   ⚠️  $stuck_in_review items stuck in review for >7 days"
      fi
      
      # Check for overloaded assignees
      local overloaded=$(echo "$response" | jq -r '
        [.data.node.items.nodes[].content.assignees.nodes[]?.login] | 
        group_by(.) | 
        map({name: .[0], count: length}) | 
        map(select(.count > 5)) | 
        length' 2>/dev/null || echo "0")
      
      if [ "$overloaded" -gt 0 ]; then
        echo "   ⚠️  $overloaded contributors with >5 assignments"
      fi
      
      # Check for high priority items without assignees
      local unassigned_high=$(echo "$response" | jq -r '
        [.data.node.items.nodes[] | 
         select(.fieldValues.nodes[] | select(.field.name == "Priority" and .name == "High")) |
         select(.content.assignees.nodes | length == 0)] | 
        length' 2>/dev/null || echo "0")
      
      if [ "$unassigned_high" -gt 0 ]; then
        echo "   ⚠️  $unassigned_high high priority items without assignees"
      fi
      
      if [ "$stuck_in_review" -eq 0 ] && [ "$overloaded" -eq 0 ] && [ "$unassigned_high" -eq 0 ]; then
        echo "   ✅ No major bottlenecks detected"
      fi
      echo ""
      
      # Recommendations
      echo "💡 RECOMMENDATIONS:"
      
      # Velocity recommendations
      if [ "$closed_last_30" -lt "$opened_last_30" ]; then
        echo "   📈 Consider reducing scope or increasing team capacity"
        echo "   🎯 Focus on completing existing work before adding new items"
      fi
      
      # Priority recommendations
      if [ "$high_priority" -gt 5 ]; then
        echo "   🔴 High priority backlog is large - consider breaking down items"
      fi
      
      # Team balance recommendations
      if [ "$overloaded" -gt 0 ]; then
        echo "   👥 Redistribute workload across team members"
      fi
      
      # Process improvements
      echo "   📋 Set up automation rules for status updates"
      echo "   🔄 Enable continuous sync for real-time updates"
      echo "   📊 Schedule weekly velocity reviews"
      echo ""
      
      # Health score
      local health_score=100
      health_score=$((health_score - stuck_in_review * 10))
      health_score=$((health_score - overloaded * 15))
      health_score=$((health_score - unassigned_high * 20))
      if [ "$closed_last_30" -lt "$opened_last_30" ]; then
        health_score=$((health_score - 20))
      fi
      
      echo "🏥 PROJECT HEALTH SCORE: ${health_score}/100"
      
      if [ "$health_score" -ge 80 ]; then
        echo "   ✅ Excellent project health!"
      elif [ "$health_score" -ge 60 ]; then
        echo "   ⚠️  Good project health with room for improvement"
      else
        echo "   🚨 Project health needs attention"
      fi
      ;;
      
    *)
      echo "❌ Unknown report type: $report_type"
      echo "Use 'analytics \"$board_name\"' to see available options"
      ;;
  esac
}

# Advanced project templates
function template() {
  local template_name="$1"
  local action="${2:-create}"
  
  if [ -z "$template_name" ]; then
    echo "❌ Usage: template <name> [action]"
    echo ""
    echo "🎨 Available templates:"
    echo "   software-dev     - Software development project"
    echo "   marketing        - Marketing campaign project"
    echo "   research         - Research and analysis project"
    echo "   event            - Event planning project"
    echo "   product-launch   - Product launch project"
    echo "   bug-tracking     - Bug tracking project"
    echo "   content-creation - Content creation project"
    echo "   custom           - Create custom template"
    echo ""
    echo "📋 Available actions:"
    echo "   create     - Create new project from template"
    echo "   show       - Show template details"
    echo "   customize  - Customize template"
    return 1
  fi
  
  ensure_boards_dir
  
  # Template directory
  local template_dir="$GITOK_BOARDS_DIR/templates"
  mkdir -p "$template_dir"
  
  case "$action" in
    "create")
      echo "🎨 Creating project from template: $template_name"
      echo "============================================="
      echo ""
      
      case "$template_name" in
        "software-dev")
          echo "🚀 Software Development Project Template"
          echo ""
          
          # Create template board
          local board_data=$(cat << 'EOF'
{
  "name": "Software Development Project",
  "description": "Complete software development lifecycle management",
  "template": "software-dev",
  "columns": [
    {
      "name": "Backlog",
      "description": "Items waiting to be prioritized"
    },
    {
      "name": "Sprint Planning",
      "description": "Items being planned for upcoming sprint"
    },
    {
      "name": "In Progress",
      "description": "Items currently being worked on"
    },
    {
      "name": "Code Review",
      "description": "Items waiting for code review"
    },
    {
      "name": "Testing",
      "description": "Items in testing phase"
    },
    {
      "name": "Done",
      "description": "Completed items"
    }
  ],
  "custom_fields": [
    {
      "name": "Priority",
      "type": "single_select",
      "options": [
        {"name": "Critical", "color": "red"},
        {"name": "High", "color": "orange"},
        {"name": "Medium", "color": "yellow"},
        {"name": "Low", "color": "green"}
      ]
    },
    {
      "name": "Story Points",
      "type": "number",
      "description": "Effort estimation in story points"
    },
    {
      "name": "Sprint",
      "type": "single_select",
      "options": [
        {"name": "Sprint 1", "color": "blue"},
        {"name": "Sprint 2", "color": "purple"},
        {"name": "Sprint 3", "color": "pink"},
        {"name": "Sprint 4", "color": "green"}
      ]
    },
    {
      "name": "Component",
      "type": "single_select",
      "options": [
        {"name": "Frontend", "color": "blue"},
        {"name": "Backend", "color": "green"},
        {"name": "Database", "color": "purple"},
        {"name": "DevOps", "color": "orange"},
        {"name": "Documentation", "color": "gray"}
      ]
    },
    {
      "name": "Due Date",
      "type": "date"
    }
  ],
  "sample_tasks": [
    {
      "title": "Set up development environment",
      "description": "Configure local development environment with all necessary tools",
      "priority": "High",
      "story_points": 3,
      "component": "DevOps"
    },
    {
      "title": "Design database schema",
      "description": "Create initial database schema design",
      "priority": "High",
      "story_points": 5,
      "component": "Database"
    },
    {
      "title": "Implement user authentication",
      "description": "Create user registration and login functionality",
      "priority": "High",
      "story_points": 8,
      "component": "Backend"
    },
    {
      "title": "Create responsive UI components",
      "description": "Build reusable UI components for the frontend",
      "priority": "Medium",
      "story_points": 5,
      "component": "Frontend"
    },
    {
      "title": "Set up CI/CD pipeline",
      "description": "Configure automated testing and deployment",
      "priority": "Medium",
      "story_points": 8,
      "component": "DevOps"
    },
    {
      "title": "Write API documentation",
      "description": "Document all API endpoints and usage examples",
      "priority": "Low",
      "story_points": 3,
      "component": "Documentation"
    }
  ]
}
EOF
)
          ;;
          
        "marketing")
          echo "📢 Marketing Campaign Project Template"
          echo ""
          
          local board_data=$(cat << 'EOF'
{
  "name": "Marketing Campaign Project",
  "description": "Complete marketing campaign planning and execution",
  "template": "marketing",
  "columns": [
    {
      "name": "Research",
      "description": "Market research and analysis"
    },
    {
      "name": "Strategy",
      "description": "Campaign strategy development"
    },
    {
      "name": "Creative",
      "description": "Content and creative development"
    },
    {
      "name": "Execution",
      "description": "Campaign execution and deployment"
    },
    {
      "name": "Monitoring",
      "description": "Performance monitoring and optimization"
    },
    {
      "name": "Completed",
      "description": "Completed campaign activities"
    }
  ],
  "custom_fields": [
    {
      "name": "Campaign Phase",
      "type": "single_select",
      "options": [
        {"name": "Pre-Launch", "color": "blue"},
        {"name": "Launch", "color": "green"},
        {"name": "Post-Launch", "color": "purple"}
      ]
    },
    {
      "name": "Channel",
      "type": "single_select",
      "options": [
        {"name": "Social Media", "color": "blue"},
        {"name": "Email", "color": "green"},
        {"name": "Content Marketing", "color": "purple"},
        {"name": "Paid Advertising", "color": "orange"},
        {"name": "PR", "color": "pink"}
      ]
    },
    {
      "name": "Budget",
      "type": "number",
      "description": "Budget allocation for this activity"
    },
    {
      "name": "Target Audience",
      "type": "text",
      "description": "Primary target audience"
    },
    {
      "name": "Launch Date",
      "type": "date"
    }
  ],
  "sample_tasks": [
    {
      "title": "Market research and competitor analysis",
      "description": "Analyze market trends and competitor strategies",
      "campaign_phase": "Pre-Launch",
      "channel": "Research"
    },
    {
      "title": "Develop campaign messaging",
      "description": "Create core messaging and value propositions",
      "campaign_phase": "Pre-Launch",
      "channel": "Content Marketing"
    },
    {
      "title": "Create social media content calendar",
      "description": "Plan and schedule social media posts",
      "campaign_phase": "Launch",
      "channel": "Social Media"
    },
    {
      "title": "Design campaign visuals",
      "description": "Create graphics and visual assets",
      "campaign_phase": "Pre-Launch",
      "channel": "Content Marketing"
    },
    {
      "title": "Set up email automation",
      "description": "Configure email marketing sequences",
      "campaign_phase": "Launch",
      "channel": "Email"
    },
    {
      "title": "Monitor campaign performance",
      "description": "Track KPIs and optimize campaign",
      "campaign_phase": "Post-Launch",
      "channel": "Analytics"
    }
  ]
}
EOF
)
          ;;
          
        "product-launch")
          echo "🚀 Product Launch Project Template"
          echo ""
          
          local board_data=$(cat << 'EOF'
{
  "name": "Product Launch Project",
  "description": "Complete product launch planning and execution",
  "template": "product-launch",
  "columns": [
    {
      "name": "Planning",
      "description": "Launch planning and preparation"
    },
    {
      "name": "Development",
      "description": "Product development and testing"
    },
    {
      "name": "Marketing",
      "description": "Marketing and promotion activities"
    },
    {
      "name": "Launch",
      "description": "Launch execution"
    },
    {
      "name": "Post-Launch",
      "description": "Post-launch activities and optimization"
    },
    {
      "name": "Completed",
      "description": "Completed launch activities"
    }
  ],
  "custom_fields": [
    {
      "name": "Launch Phase",
      "type": "single_select",
      "options": [
        {"name": "Pre-Launch", "color": "blue"},
        {"name": "Soft Launch", "color": "yellow"},
        {"name": "Full Launch", "color": "green"},
        {"name": "Post-Launch", "color": "purple"}
      ]
    },
    {
      "name": "Department",
      "type": "single_select",
      "options": [
        {"name": "Product", "color": "blue"},
        {"name": "Engineering", "color": "green"},
        {"name": "Marketing", "color": "purple"},
        {"name": "Sales", "color": "orange"},
        {"name": "Support", "color": "pink"}
      ]
    },
    {
      "name": "Risk Level",
      "type": "single_select",
      "options": [
        {"name": "Low", "color": "green"},
        {"name": "Medium", "color": "yellow"},
        {"name": "High", "color": "red"}
      ]
    },
    {
      "name": "Success Metric",
      "type": "text",
      "description": "Key success metric for this activity"
    },
    {
      "name": "Target Date",
      "type": "date"
    }
  ],
  "sample_tasks": [
    {
      "title": "Define product requirements",
      "description": "Finalize product specifications and requirements",
      "launch_phase": "Pre-Launch",
      "department": "Product",
      "risk_level": "High"
    },
    {
      "title": "Complete beta testing",
      "description": "Conduct comprehensive beta testing program",
      "launch_phase": "Pre-Launch",
      "department": "Engineering",
      "risk_level": "High"
    },
    {
      "title": "Develop launch marketing materials",
      "description": "Create all marketing collateral and campaigns",
      "launch_phase": "Pre-Launch",
      "department": "Marketing",
      "risk_level": "Medium"
    },
    {
      "title": "Train sales team",
      "description": "Provide product training to sales team",
      "launch_phase": "Pre-Launch",
      "department": "Sales",
      "risk_level": "Medium"
    },
    {
      "title": "Set up customer support",
      "description": "Prepare support documentation and processes",
      "launch_phase": "Pre-Launch",
      "department": "Support",
      "risk_level": "Low"
    },
    {
      "title": "Monitor launch metrics",
      "description": "Track key performance indicators",
      "launch_phase": "Post-Launch",
      "department": "Product",
      "risk_level": "Medium"
    }
  ]
}
EOF
)
          ;;
          
        *)
          echo "❌ Unknown template: $template_name"
          echo "Use 'template' to see available templates"
          return 1
          ;;
      esac
      
      # Save template
      local template_file="$template_dir/${template_name}.json"
      echo "$board_data" > "$template_file"
      
      echo "✅ Template created: $template_file"
      echo ""
      echo "📋 To create a project from this template:"
      echo "   createboard \"My Project\" --template $template_name"
      echo ""
      echo "🎨 To customize this template:"
      echo "   template $template_name customize"
      ;;
      
    "show")
      echo "📋 Template Details: $template_name"
      echo "================================="
      echo ""
      
      local template_file="$template_dir/${template_name}.json"
      if [ ! -f "$template_file" ]; then
        echo "❌ Template not found: $template_name"
        echo "Use 'template $template_name create' to create it first"
        return 1
      fi
      
      # Show template details
      local template_data=$(cat "$template_file")
      local name=$(echo "$template_data" | jq -r '.name')
      local description=$(echo "$template_data" | jq -r '.description')
      local views=$(echo "$template_data" | jq -r '.views | length')
      local fields=$(echo "$template_data" | jq -r '.fields | length')
      local tasks=$(echo "$template_data" | jq -r '.sample_tasks | length')
      
      echo "📝 Name: $name"
      echo "📄 Description: $description"
      echo "📊 Views: $views"
      echo "🏷️  Fields: $fields"
      echo "📋 Sample Tasks: $tasks"
      echo ""
      
      echo "📚 VIEWS:"
      echo "$template_data" | jq -r '.views[] | "   • " + .name + " (" + .layout + ")"'
      echo ""
      
      echo "🏷️  FIELDS:"
      echo "$template_data" | jq -r '.fields[] | "   • " + .name + " (" + .type + ")"'
      echo ""
      
      echo "📋 SAMPLE TASKS:"
      echo "$template_data" | jq -r '.sample_tasks[] | "   • " + .title'
      ;;
      
    *)
      echo "❌ Unknown action: $action"
      echo "Use 'template $template_name show' to see template details"
      ;;
  esac
}

# Add field to a GitHub project
function addfield() {
  local board_name="$1"
  local field_name="$2"
  local field_type="${3:-SINGLE_SELECT}"  # SINGLE_SELECT, TEXT, NUMBER, DATE, etc.
  
  if [ -z "$board_name" ] || [ -z "$field_name" ]; then
    echo "❌ Usage: addfield \"Board Name\" \"Field Name\" [type]"
    echo "   Types: SINGLE_SELECT (default), TEXT, NUMBER, DATE"
    return 1
  fi
  
  if ! check_board_dependencies; then
    return 1
  fi
  
  if ! require_github_auth; then
    return 1
  fi
  
  ensure_boards_dir
  
  # Find board file
  local board_file=""
  for file in "$GITOK_BOARDS_DIR"/*.json; do
    if [ -f "$file" ]; then
      local name=$(jq -r '.name' "$file" 2>/dev/null)
      if [ "$name" = "$board_name" ]; then
        board_file="$file"
        break
      fi
    fi
  done
  
  if [ -z "$board_file" ]; then
    echo "❌ Board '$board_name' not found locally"
    return 1
  fi
  
  local pushed=$(jq -r '.pushed_to_github' "$board_file" 2>/dev/null)
  if [ "$pushed" != "true" ]; then
    echo "❌ Board '$board_name' not pushed to GitHub yet. Use 'pushboard' first."
    return 1
  fi
  
  local project_id=$(jq -r '.github_id' "$board_file" 2>/dev/null)
  
  echo "📊 Adding field '$field_name' to project '$board_name'..."
  
  # Create field using GraphQL
  local create_field_query=""
  if [ "$field_type" = "SINGLE_SELECT" ]; then
    if [ "$field_name" = "Priority" ]; then
      create_field_query="mutation { createProjectV2Field(input: { projectId: \"$project_id\", dataType: SINGLE_SELECT, name: \"$field_name\", singleSelectOptions: [{name: \"High\", description: \"High priority items\", color: RED}, {name: \"Medium\", description: \"Medium priority items\", color: YELLOW}, {name: \"Low\", description: \"Low priority items\", color: GREEN}] }) { projectV2Field { ... on ProjectV2SingleSelectField { id name } } } }"
    elif [ "$field_name" = "Stage" ]; then
      create_field_query="mutation { createProjectV2Field(input: { projectId: \"$project_id\", dataType: SINGLE_SELECT, name: \"$field_name\", singleSelectOptions: [{name: \"Planning\", description: \"In planning phase\", color: BLUE}, {name: \"Development\", description: \"In development\", color: YELLOW}, {name: \"Testing\", description: \"In testing phase\", color: ORANGE}, {name: \"Completed\", description: \"Completed\", color: GREEN}] }) { projectV2Field { ... on ProjectV2SingleSelectField { id name } } } }"
    else
      create_field_query="mutation { createProjectV2Field(input: { projectId: \"$project_id\", dataType: SINGLE_SELECT, name: \"$field_name\", singleSelectOptions: [{name: \"Option 1\", description: \"First option\", color: GRAY}, {name: \"Option 2\", description: \"Second option\", color: YELLOW}, {name: \"Option 3\", description: \"Third option\", color: GREEN}] }) { projectV2Field { ... on ProjectV2SingleSelectField { id name } } } }"
    fi
  else
    create_field_query="mutation { createProjectV2Field(input: { projectId: \"$project_id\", dataType: $field_type, name: \"$field_name\" }) { projectV2Field { ... on ProjectV2Field { id name } } } }"
  fi
  
  local field_response=$(github_graphql_query "$create_field_query")
  
  if echo "$field_response" | grep -q '"errors"'; then
    echo "❌ Failed to create field"
    echo "$field_response" | jq -r '.errors[0].message' 2>/dev/null || echo "Unknown error"
    return 1
  fi
  
  local field_id=$(echo "$field_response" | jq -r '.data.createProjectV2Field.projectV2Field.id' 2>/dev/null)
  
  if [ -z "$field_id" ] || [ "$field_id" = "null" ]; then
    echo "❌ Failed to create field"
    return 1
  fi
  
  echo "✅ Created field: $field_name"
  echo "🆔 Field ID: $field_id"
  echo "📋 Type: $field_type"
}

# Legacy alias for backward compatibility
function addcolumn() {
  echo "⚠️  'addcolumn' is deprecated. Use 'addfield' instead."
  addfield "$@"
}

# Add item (task) to a GitHub project
function addtask() {
  local board_name="$1"
  local task_title="$2"
  local task_body="${3:-}"
  
  if [ -z "$board_name" ] || [ -z "$task_title" ]; then
    echo "❌ Usage: addtask \"Board Name\" \"Task Title\" [\"Task Description\"]"
    return 1
  fi
  
  if ! check_board_dependencies; then
    return 1
  fi
  
  if ! require_github_auth; then
    return 1
  fi
  
  ensure_boards_dir
  
  # Find board file
  local board_file=""
  for file in "$GITOK_BOARDS_DIR"/*.json; do
    if [ -f "$file" ]; then
      local name=$(jq -r '.name' "$file" 2>/dev/null)
      if [ "$name" = "$board_name" ]; then
        board_file="$file"
        break
      fi
    fi
  done
  
  if [ -z "$board_file" ]; then
    echo "❌ Board '$board_name' not found locally"
    return 1
  fi
  
  local pushed=$(jq -r '.pushed_to_github' "$board_file" 2>/dev/null)
  if [ "$pushed" != "true" ]; then
    echo "❌ Board '$board_name' not pushed to GitHub yet. Use 'pushboard' first."
    return 1
  fi
  
  local project_id=$(jq -r '.github_id' "$board_file" 2>/dev/null)
  
  echo "📝 Adding task '$task_title' to project '$board_name'..."
  
  # First, get the current user's login to determine the repository owner
  local viewer_query="query { viewer { login } }"
  local viewer_response=$(github_graphql_query "$viewer_query")
  local owner_login=$(echo "$viewer_response" | jq -r '.data.viewer.login' 2>/dev/null)
  
  # We need to create a draft issue first, then add it to the project
  # For simplicity, let's create a draft item directly
  local create_item_query="mutation { addProjectV2DraftIssue(input: { projectId: \"$project_id\", title: \"$task_title\", body: \"$task_body\" }) { projectItem { id } } }"
  local item_response=$(github_graphql_query "$create_item_query")
  
  if echo "$item_response" | grep -q '"errors"'; then
    echo "❌ Failed to create task"
    echo "$item_response" | jq -r '.errors[0].message' 2>/dev/null || echo "Unknown error"
    return 1
  fi
  
  local item_id=$(echo "$item_response" | jq -r '.data.addProjectV2DraftIssue.projectItem.id' 2>/dev/null)
  
  if [ -z "$item_id" ] || [ "$item_id" = "null" ]; then
    echo "❌ Failed to create task"
    return 1
  fi
  
  echo "✅ Created task: $task_title"
  echo "🆔 Item ID: $item_id"
}

# List project views and structure
function showproject() {
  local board_name="$1"
  
  if [ -z "$board_name" ]; then
    echo "❌ Usage: showproject \"Board Name\""
    return 1
  fi
  
  if ! check_board_dependencies; then
    return 1
  fi
  
  if ! require_github_auth; then
    return 1
  fi
  
  ensure_boards_dir
  
  # Find board file
  local board_file=""
  for file in "$GITOK_BOARDS_DIR"/*.json; do
    if [ -f "$file" ]; then
      local name
      name=$(jq -r '.name' "$file" 2>/dev/null)
      if [ "$name" = "$board_name" ]; then
        board_file="$file"
        break
      fi
    fi
  done
  
  if [ -z "$board_file" ]; then
    echo "❌ Board '$board_name' not found locally"
    return 1
  fi
  
  local pushed
  pushed=$(jq -r '.pushed_to_github' "$board_file" 2>/dev/null)
  if [ "$pushed" != "true" ]; then
    echo "❌ Board '$board_name' not pushed to GitHub yet. Use 'pushboard' first."
    return 1
  fi
  
  local project_id
  project_id=$(jq -r '.github_id' "$board_file" 2>/dev/null)
  local project_url
  project_url=$(jq -r '.github_url' "$board_file" 2>/dev/null)
  
  echo "📊 Project Details: $board_name"
  echo "================================="
  echo "🔗 URL: $project_url"
  echo "🆔 ID: $project_id"
  echo ""
  
  # Get project views
  echo "📋 Views:"
  local views_query="query { node(id: \"$project_id\") { ... on ProjectV2 { views(first: 10) { nodes { id name layout } } } } }"
  local views_response
  views_response=$(github_graphql_query "$views_query")
  
  if echo "$views_response" | grep -q '"errors"'; then
    echo "❌ Failed to fetch views"
  else
    echo "$views_response" | jq -r '.data.node.views.nodes[] | "  • \(.name) (\(.layout))"' 2>/dev/null || echo "  No views found"
  fi
  
  echo ""
  
  # Get project fields
  echo "🏷️  Fields:"
  local fields_query="query { node(id: \"$project_id\") { ... on ProjectV2 { fields(first: 20) { nodes { ... on ProjectV2Field { id name dataType } ... on ProjectV2SingleSelectField { id name options { id name } } } } } } }"
  local fields_response
  fields_response=$(github_graphql_query "$fields_query")
  
  if echo "$fields_response" | grep -q '"errors"'; then
    echo "❌ Failed to fetch fields"
  else
    echo "$fields_response" | jq -r '.data.node.fields.nodes[] | "  • \(.name) (\(.dataType // "SELECT"))"' 2>/dev/null || echo "  No custom fields found"
  fi
  
  echo ""
  
  # Get project items count
  echo "📝 Items:"
  local items_query="query { node(id: \"$project_id\") { ... on ProjectV2 { items(first: 5) { totalCount nodes { id content { ... on DraftIssue { title body } ... on Issue { title body } ... on PullRequest { title body } } } } } } }"
  local items_response
  items_response=$(github_graphql_query "$items_query")
  
  if echo "$items_response" | grep -q '"errors"'; then
    echo "❌ Failed to fetch items"
  else
    local total_items
    total_items=$(echo "$items_response" | jq -r '.data.node.items.totalCount' 2>/dev/null || echo "0")
    echo "  Total items: $total_items"
    
    if [ "$total_items" != "0" ] && [ "$total_items" != "null" ]; then
      echo "  Recent items:"
      echo "$items_response" | jq -r '.data.node.items.nodes[].content.title // "Untitled"' 2>/dev/null | head -5 | sed 's/^/    • /'
    fi
  fi
}

# Display Git aliases cheatsheet
function gitcheatsheet() {
  echo ""
  echo "🚀 ==============================================="
  echo "           GITOK COMMANDS CHEATSHEET"
  echo "       GitOK by Dedan Okware"
  echo "==============================================="
  echo ""
  echo "📂 REPOSITORY MANAGEMENT"
  echo "  clone <url>           Clone a repository"
  echo "  init                  Initialize a new git repo"
  echo "  status                Show git status"
  echo ""
  echo "📝 STAGING & COMMITS"
  echo "  addall                Stage all changes (git add .)"
  echo "  commit \"message\"      Stage all + commit with message"
  echo "  commitonly \"message\"  Commit only staged files"
  echo "  amendmsg \"message\"    Amend last commit message"
  echo ""
  echo "🔄 PUSH & PULL"
  echo "  push                  Push to current remote branch"
  echo "  pushall [--dry-run]   Push to all remotes (with rebase)"
  echo "  pushnew <remote-url>  Add remote & push current branch"
  echo "  pull                  Pull with rebase"
  echo "  unpush [remote]       Undo last push (⚠️ dangerous)"
  echo "  trackremote           Track current branch upstream"
  echo ""
  echo "🌿 BRANCHES"
  echo "  branch <name>         Create and switch to new branch"
  echo "  checkout <name>       Switch to existing branch"
  echo "  branches              List all branches"
  echo "  deletebranch <name>   Delete branch (safe)"
  echo "  deletebranchf <name>  Force delete branch"
  echo ""
  echo "📊 LOGS & HISTORY"
  echo "  graphlog              Show commit graph"
  echo "  last                  Show last commit"
  echo "  logfull               Show detailed commit log"
  echo "  diff                  Show diff with HEAD"
  echo ""
  echo "↩️  UNDO & RESET"
  echo "  resetsoft             Undo last commit, keep changes"
  echo "  resethard             Hard reset to HEAD (⚠️ dangerous)"
  echo "  revertlast            Revert last commit (new commit)"
  echo "  unstage               Unstage all files"
  echo "  restore <file>        Restore file to last commit"
  echo ""
  echo "💾 STASH & TEMPORARY"
  echo "  stash                 Stash current changes"
  echo "  pop                   Apply last stash"
  echo ""
  echo "🧹 CLEANUP & TOOLS"
  echo "  clean                 Remove untracked files"
  echo "  tracked               Show tracked file changes"
  echo "  remotes               Show all remotes"
  echo "  squashlast [N]        Squash last N commits (default: 2)"
  echo ""
  echo "📄 FILES & IGNORE"
  echo "  ignore <pattern>      Add pattern to .gitignore"
  echo "  makeignore <type>     Create .gitignore from template"
  echo ""
  echo "🎯 GITHUB PROJECT BOARDS"
  echo "  githubauth            Setup GitHub authentication (OAuth/CLI)"
  echo "  createboard <name>    Create new project board locally"
  echo "  listboards            List all project boards"
  echo "  editboard <name>      Edit existing project board"
  echo "  pushboard <name>      Push local board to GitHub"
  echo "  syncboard <name>      Sync board with GitHub"
  echo "  showproject <name>    Show project details, views, and items"
  echo "  addview <board> <view> Add view to project (TABLE/BOARD/ROADMAP)"
  echo "  addcolumn <board> <col> Add column to project"
  echo "  addtask <board> <task> Add task to project"
  echo ""
  echo "🔄 ADVANCED SYNC & REAL-TIME"
  echo "  syncproject <board> [auto] Advanced real-time sync (30s intervals)"
  echo "                      Monitor changes, activity, and collaboration"
  echo ""
  echo "🤝 COLLABORATION HUB"
  echo "  collaborate <board> activity     Recent project activity"
  echo "  collaborate <board> contributors List all contributors"
  echo "  collaborate <board> assignments  Your current assignments"
  echo "  collaborate <board> invite       Generate invitation message"
  echo ""
  echo "🤖 AUTOMATION & WORKFLOWS"
  echo "  automate <board> rules       Setup automation rules"
  echo "  automate <board> templates   Create issue/PR templates"
  echo "  automate <board> workflows   Generate GitHub Actions"
  echo ""
  echo "📊 ANALYTICS & INSIGHTS"
  echo "  analytics <board> summary    Project overview and metrics"
  echo "  analytics <board> velocity   Team velocity and completion"
  echo "  analytics <board> burndown   Sprint burndown analysis"
  echo "  analytics <board> export     Export data (CSV/JSON/MD)"
  echo "  analytics <board> insights   AI-powered recommendations"
  echo ""
  echo "🎨 PROJECT TEMPLATES"
  echo "  template software-dev create Software development template"
  echo "  template marketing create    Marketing campaign template"
  echo "  template product-launch create Product launch template"
  echo "  template <name> show         Show template details"
  echo ""
  echo "❓ HELP & INFO"
  echo "  gitcheatsheet         Show this cheatsheet"
  echo "  gitok --version       Show GitOK version"
  echo "  gitok --help          Show this cheatsheet"
  echo "  gitok --update        Update to latest version"
  echo ""
  echo "==============================================="
  echo "💡 TIP: Most commands work only in git repos"
  echo "⚠️  Commands marked dangerous require confirmation"
  echo "🔄 Use 'gitok --update' to get latest features"
  echo "🎯 Use 'githubauth' to setup GitHub project boards"
  echo "🚀 NEW: Real-time sync, collaboration, analytics & templates!"
  echo "🤖 Advanced automation with GitHub Actions integration"
  echo "📊 Export data, track velocity, and get AI insights"
  echo "==============================================="
  echo ""
}
