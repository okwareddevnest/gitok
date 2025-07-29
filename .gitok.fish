#!/usr/bin/env fish
# GitOK - Git CLI Productivity Boost for Fish Shell
# Created by Dedan Okware

# GitOK Configuration
set -g GITOK_VERSION "2.0.4"
set -g GITOK_REPO "https://raw.githubusercontent.com/okwareddevnest/gitok/main"
set -g GITOK_SCRIPT_PATH "$HOME/.gitok.fish"

# Version and help functions
function gitok
  switch $argv[1]
    case --version -v
      echo "GitOK v$GITOK_VERSION"
      echo "GitOK by Dedan Okware (Fish Shell)"
      echo "Repository: https://github.com/okwareddevnest/gitok"
    case --help -h
      gitcheatsheet
    case --update -u
      gitok_update
    case '*'
      echo "GitOK v$GITOK_VERSION - GitOK (Fish Shell)"
      echo ""
      echo "Usage:"
      echo "  gitok --version    Show version"
      echo "  gitok --help       Show commands cheatsheet"
      echo "  gitok --update     Update to latest version"
      echo ""
      echo "Or use any of the git aliases directly. Run 'gitcheatsheet' for full list."
  end
end

# Update functionality
function gitok_update
  echo "🔄 Checking for GitOK updates..."
  
  # Try GitHub API first (more reliable than CDN)
  set LATEST_VERSION (curl -s "https://api.github.com/repos/okwareddevnest/gitok/contents/VERSION" 2>/dev/null | grep '"content"' | cut -d'"' -f4 | base64 -d 2>/dev/null)
  
  # If API fails (rate limit or network), try fallback methods
  if test -z "$LATEST_VERSION"
    echo "⚠️  GitHub API unavailable (rate limit or network issue). Trying fallback method..."
    
    # Fallback 1: Try raw GitHub content
    set LATEST_VERSION (curl -s "https://raw.githubusercontent.com/okwareddevnest/gitok/main/VERSION" 2>/dev/null | tr -d '[:space:]')
    
    # Fallback 2: Try git ls-remote to get latest tag
    if test -z "$LATEST_VERSION"
      echo "⚠️  Raw content unavailable. Trying git method..."
      set LATEST_VERSION (git ls-remote --tags --sort='-v:refname' https://github.com/okwareddevnest/gitok.git 2>/dev/null | head -n1 | grep -o 'v[0-9.]*' | sed 's/v//' 2>/dev/null)
    end
  end
  
  if test -z "$LATEST_VERSION"
    echo "❌ Failed to check for updates. All methods failed:"
    echo "   • GitHub API may be rate limited"
    echo "   • Raw content unavailable"
    echo "   • Git remote access failed"
    echo "   • Check your internet connection"
    return 1
  end
  
  # Remove any whitespace
  set LATEST_VERSION (echo "$LATEST_VERSION" | tr -d '[:space:]')
  
  if test "$LATEST_VERSION" = "$GITOK_VERSION"
    echo "✅ You already have the latest version (v$GITOK_VERSION)"
    return 0
  end
  
  # Check if current version is newer than remote (development scenario)
  if command -q sort
    set NEWER_VERSION (printf '%s\n%s' "$GITOK_VERSION" "$LATEST_VERSION" | sort -V | tail -n1)
    if test "$NEWER_VERSION" = "$GITOK_VERSION"
      echo "✅ You have a newer version (v$GITOK_VERSION) than remote (v$LATEST_VERSION)"
      echo "   This may be a development version."
      return 0
    end
  end
  
  echo "🆕 New version available: v$LATEST_VERSION (current: v$GITOK_VERSION)"
  read -l -p "Do you want to update? (y/N): " confirm
  
  if test "$confirm" = "y" -o "$confirm" = "Y"
    echo "📥 Downloading latest version..."
    
    # Backup current version
    cp "$GITOK_SCRIPT_PATH" "$GITOK_SCRIPT_PATH.backup"
    
    # Download new version
    if curl -sL "$GITOK_REPO/.gitok.fish" -o "$GITOK_SCRIPT_PATH"
      echo "✅ GitOK updated to v$LATEST_VERSION"
      echo "🔄 Please restart your terminal or run: source ~/.config/fish/config.fish"
      echo "💾 Backup saved as: $GITOK_SCRIPT_PATH.backup"
    else
      echo "❌ Update failed. Restoring backup..."
      mv "$GITOK_SCRIPT_PATH.backup" "$GITOK_SCRIPT_PATH"
    end
  else
    echo "❌ Update cancelled"
  end
end

# Check if in a Git repo
function in_git_repo
  git rev-parse --is-inside-work-tree &>/dev/null
end

# Git status
function gitstatus
  in_git_repo && git status
end

# Clone a repository
function clone
  git clone $argv[1]
end

# Initialize a Git repo with 'main' as default branch
function init
  echo "🧱 Initializing Git repository with 'main' as default branch..."
  git init -b main
end

# Add all changes
function addall
  git add .
end

# Commit with message (auto-stage all)
function commit
  git add . && git commit -m "$argv[1]"
end

# Commit only staged files
function commitonly
  git commit -m "$argv[1]"
end

# Push to current remote branch
function push
  set branch (git rev-parse --abbrev-ref HEAD)
  git push origin "$branch"
end

# Pull with rebase
function pull
  git pull --rebase
end

# Push to all remotes dynamically
function pushall
  set branch (git rev-parse --abbrev-ref HEAD)
  set mode $argv[1]  # supports --dry-run

  for remote in (git remote)
    echo "🔁 Rebasing from $remote/$branch..."
    git pull --rebase "$remote" "$branch"

    if test "$mode" = "--dry-run"
      echo "🧪 [DRY RUN] Would push $branch to $remote..."
      git push --dry-run "$remote" "$branch"
    else
      echo "🔼 Pushing $branch to $remote..."
      git push "$remote" "$branch"
    end
  end
end

# Undo the last push (force reset remote to one commit before)
function unpush
  set branch (git rev-parse --abbrev-ref HEAD)
  set remote $argv[1]  # default to origin if not specified
  if test -z "$remote"
    set remote origin
  end

  echo "⚠️ WARNING: This will remove the last commit from $remote/$branch"
  read -l -p "Are you sure? Type 'yes' to continue: " confirm
  if test "$confirm" = "yes"
    git push "$remote" HEAD~1:"$branch" --force
    echo "✅ Unpushed last commit from $remote/$branch"
  else
    echo "❌ Unpush aborted"
  end
end

# Create and switch to new branch
function branch
  git checkout -b $argv[1]
end

# Switch branches
function checkout
  git checkout $argv[1]
end

# List branches
function branches
  git branch -a
end

# Delete branch (safe)
function deletebranch
  git branch -d $argv[1]
end

# Force delete branch
function deletebranchf
  git branch -D $argv[1]
end

# Show commit graph
function graphlog
  git log --graph --oneline --all
end

# Show last commit
function last
  git log -1 --stat
end

# Show diff with HEAD
function diff
  git diff HEAD
end

# Undo last commit, keep changes
function resetsoft
  git reset --soft HEAD~1
end

# Hard reset to HEAD (⚠️ dangerous)
function resethard
  echo "⚠️ WARNING: This will permanently delete all uncommitted changes"
  read -l -p "Are you sure? Type 'yes' to continue: " confirm
  if test "$confirm" = "yes"
    git reset --hard HEAD
    echo "✅ Hard reset completed"
  else
    echo "❌ Hard reset aborted"
  end
end

# Stash current changes
function stash
  git stash
end

# Apply last stash
function pop
  git stash pop
end

# Restore file to last commit
function restore
  git restore $argv[1]
end

# Unstage all files
function unstage
  git reset HEAD
end

# Remove untracked files
function clean
  echo "⚠️ WARNING: This will remove all untracked files"
  read -l -p "Are you sure? Type 'yes' to continue: " confirm
  if test "$confirm" = "yes"
    git clean -fd
    echo "✅ Clean completed"
  else
    echo "❌ Clean aborted"
  end
end

# Track current branch upstream
function trackremote
  set branch (git rev-parse --abbrev-ref HEAD)
  git branch --set-upstream-to=origin/$branch $branch
end

# Create .gitignore from template
function makeignore
  set type $argv[1]
  if test -z "$type"
    echo "Usage: makeignore <type>"
    echo "Types: node, python, java, cpp, rust, go, php, ruby, swift, kotlin"
    return 1
  end
  
  curl -s "https://raw.githubusercontent.com/github/gitignore/master/$type.gitignore" -o .gitignore
  echo "✅ Created .gitignore for $type"
end

# Squash last N commits (default: 2)
function squashlast
  set count $argv[1]
  if test -z "$count"
    set count 2
  end
  
  echo "⚠️ WARNING: This will squash the last $count commits"
  read -l -p "Are you sure? Type 'yes' to continue: " confirm
  if test "$confirm" = "yes"
    git reset --soft HEAD~$count
    git commit -m "Squashed last $count commits"
    echo "✅ Squashed last $count commits"
  else
    echo "❌ Squash aborted"
  end
end

# Show detailed commit log
function logfull
  git log --oneline --graph --decorate --all
end

# Show all remotes
function remotes
  git remote -v
end

# Revert last commit (new commit)
function revertlast
  git revert HEAD --no-edit
end

# Amend last commit message
function amendmsg
  git commit --amend -m "$argv[1]"
end

# Show tracked file changes
function tracked
  git diff --cached
end

# Add pattern to .gitignore
function ignore
  set pattern $argv[1]
  if test -z "$pattern"
    echo "Usage: ignore <pattern>"
    echo "Example: ignore '*.log'"
    return 1
  end
  
  echo "$pattern" >> .gitignore
  echo "✅ Added '$pattern' to .gitignore"
end

# Push new remote
function pushnew
  set remote_url $argv[1]
  if test -z "$remote_url"
    echo "Usage: pushnew <remote-url>"
    return 1
  end
  
  set branch (git rev-parse --abbrev-ref HEAD)
  git remote add origin "$remote_url"
  git push -u origin "$branch"
  echo "✅ Pushed to new remote: $remote_url"
end

# Display Git aliases cheatsheet
function gitcheatsheet
  echo ""
  echo "🚀 ==============================================="
  echo "           GITOK COMMANDS CHEATSHEET"
  echo "       GitOK by Dedan Okware (Fish Shell)"
  echo "==============================================="
  echo ""
  echo "📂 REPOSITORY MANAGEMENT"
  echo "  clone <url>           Clone a repository"
  echo "  init                  Initialize a new git repo"
  echo "  gitstatus             Show git status"
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
  echo "  gitok --version       Show GitOK version"
  echo "  gitok --help          Show this cheatsheet"
  echo "  gitok --update        Update to latest version"
  echo ""
  echo "==============================================="
  echo "💡 TIP: Most commands work only in git repos"
  echo "⚠️  Commands marked dangerous require confirmation"
  echo "🔄 Use 'gitok --update' to get latest features"
  echo "🐟 Fish Shell compatible version"
  echo "==============================================="
  echo ""
end