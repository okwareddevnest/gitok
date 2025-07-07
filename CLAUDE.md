# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Gitok is a Git CLI aliases project that provides 35+ custom Git commands and functions to boost developer productivity. It's a bash-based tool that adds convenient aliases and functions to Git workflows.

## Core Architecture

The project consists of:
- **`.gitok.sh`**: Main script containing all Git aliases and functions
- **`install.sh`**: Installation script for Linux/macOS/WSL
- **`install-windows.ps1`** and **`install-windows.bat`**: Windows installers
- **`scripts/`**: Version management and changelog generation utilities
- **`VERSION`**: Simple text file containing current version number

## Development Commands

### Version Management
```bash
# Bump version (patch, minor, major)
./scripts/bump-version.sh patch
./scripts/bump-version.sh minor  
./scripts/bump-version.sh major

# Generate changelog
./scripts/generate-changelog.sh changelog [version]
./scripts/generate-changelog.sh release-notes [version]
```

### Testing and Validation
```bash
# Validate shell scripts with ShellCheck
shellcheck .gitok.sh
shellcheck install.sh

# Test installation script syntax
bash -n install.sh

# Test gitok functions
source .gitok.sh
gitok --version
```

### CI/CD Operations
```bash
# Push changes and tags for release
git push origin main --tags

# Trigger GitHub Actions release (commit with [release] in message)
git commit -m "feat: new feature [release]"
```

## Project Structure

- **Version management**: Version stored in `VERSION` file and synchronized with `.gitok.sh`
- **Changelog**: Auto-generated from conventional commits using `scripts/generate-changelog.sh`
- **Installation**: Multi-platform support with shell profile auto-detection
- **Update system**: Built-in update mechanism using GitHub API
- **CI/CD**: GitHub Actions workflow for testing, version bumping, and releases

## Git Aliases Architecture

The main `.gitok.sh` script provides:
- Core Git operations (commit, push, pull, status)
- Branch management (create, switch, delete)
- Advanced features (unpush, squash, rebase helpers)
- Safety confirmations for destructive operations
- Interactive cheatsheet system

## Release Process

1. **Automated via GitHub Actions**: Triggered by workflow dispatch or `[release]` in commit messages
2. **Manual via scripts**: Use `./scripts/bump-version.sh` followed by `git push origin main --tags`
3. **Semantic versioning**: Major.Minor.Patch format with automatic changelog generation

## Important Notes

- The project uses conventional commits for changelog generation
- ShellCheck validation is enforced in CI/CD
- Cross-platform installation support (Linux, macOS, Windows WSL/Git Bash)
- Version synchronization between `VERSION` file and `.gitok.sh` script is critical
- All shell scripts must pass ShellCheck validation before merge