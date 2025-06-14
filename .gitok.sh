#!/bin/bash
# Gitok CLI Aliases
# Created by Dedan Okware

# Gitok Configuration
GITOK_VERSION="1.0.0"
GITOK_REPO="https://raw.githubusercontent.com/okwareddevnest/gitok/main"
GITOK_SCRIPT_PATH="$HOME/.gitok.sh"

# Version and help functions
function gitok() {
  case "$1" in
    --version|-v)
      echo "Gitok v$GITOK_VERSION"
      echo "Git CLI Aliases by Dedan Okware"
      echo "Repository: https://github.com/okwareddevnest/gitok"
      ;;
    --help|-h)
      gitcheatsheet
      ;;
    --update|-u)
      gitok_update
      ;;
    *)
      echo "Gitok v$GITOK_VERSION - Git CLI Aliases"
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
  echo "🔄 Checking for Gitok updates..."
  
  # Get latest version from GitHub
  LATEST_VERSION=$(curl -s "$GITOK_REPO/VERSION" 2>/dev/null)
  
  if [ -z "$LATEST_VERSION" ]; then
    echo "❌ Failed to check for updates. Please check your internet connection."
    return 1
  fi
  
  # Remove any whitespace
  LATEST_VERSION=$(echo "$LATEST_VERSION" | tr -d '[:space:]')
  
  if [ "$LATEST_VERSION" = "$GITOK_VERSION" ]; then
    echo "✅ You already have the latest version (v$GITOK_VERSION)"
    return 0
  fi
  
  echo "🆕 New version available: v$LATEST_VERSION (current: v$GITOK_VERSION)"
  read -r -p "Do you want to update? (y/N): " confirm
  
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "📥 Downloading latest version..."
    
    # Backup current version
    cp "$GITOK_SCRIPT_PATH" "${GITOK_SCRIPT_PATH}.backup"
    
    # Download new version
    if curl -sL "$GITOK_REPO/.gitok.sh" -o "$GITOK_SCRIPT_PATH"; then
      echo "✅ Gitok updated to v$LATEST_VERSION"
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

# Display Git aliases cheatsheet
function gitcheatsheet() {
  echo ""
  echo "🚀 ==============================================="
  echo "           GITOK COMMANDS CHEATSHEET"
  echo "   Git CLI Aliases by Dedan Okware"
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
  echo "❓ HELP & INFO"
  echo "  gitcheatsheet         Show this cheatsheet"
  echo "  gitok --version       Show Gitok version"
  echo "  gitok --help          Show this cheatsheet"
  echo "  gitok --update        Update to latest version"
  echo ""
  echo "==============================================="
  echo "💡 TIP: Most commands work only in git repos"
  echo "⚠️  Commands marked dangerous require confirmation"
  echo "🔄 Use 'gitok --update' to get latest features"
  echo "==============================================="
  echo ""
}
