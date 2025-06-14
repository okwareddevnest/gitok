#!/bin/bash
# Gitok CLI Aliases
# Created by Dedan Okware

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
  read -p "Are you sure? Type 'yes' to continue: " confirm
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
  git reset --soft HEAD~$count
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
