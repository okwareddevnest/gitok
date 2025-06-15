# Changelog

All notable changes to Gitok will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**🚀 This changelog is generated from git commits using our custom tooling!**

## [Unreleased]

## [1.4.0] - 2025-06-15

### ✨ Added
- Add comprehensive Windows support - PowerShell installer, batch installer, WSL support, detailed documentation

### 📝 Other Changes
- 🔖 Bump version to v1.3.0


## [1.3.0] - 2025-06-14

### ✨ Added
- Enhance Gitok with comprehensive improvements - dynamic changelog, auto-update, CI/CD pipeline, ShellCheck fixes

### 📝 Other Changes
- 🔖 Bump version to v1.2.0
- 🔖 Bump version to v1.1.0


## [1.2.0] - 2025-06-15

### ✨ Added
- Enhance Gitok with comprehensive improvements - dynamic changelog, auto-update, CI/CD pipeline, ShellCheck fixes

### 📝 Other Changes
- 🔖 Bump version to v1.1.0


## [1.1.0] - 2025-06-14

### ✨ Added
- Update CI workflow: Add permissions for contents, issues, and pull-requests; configure Git to use global settings; and implement a step to push changes to the main branch after release notes generation.
- Add .gitignore: Create a new .gitignore file to exclude common OS, editor, and temporary files. Enhance .gitok.sh with versioning and update functionality, including dynamic changelog generation. Introduce CI/CD pipeline for automated testing and release management. Update README.md and scripts documentation for clarity on new features.
- Remove .gitignore: Delete the file containing patterns for ignored files, as it is no longer needed. Add Git aliases cheatsheet to .gitok.sh for easier command reference.
- Add .gitignore: Include common OS, editor, and temporary files to be ignored by Git
- Enhance .gitok.sh: Initialize Git repo with 'main' as default branch and add pushnew function for publishing to a new remote.
- Initial commit of Gitok, a CLI tool with custom Git commands. Added main script (.gitok.sh), installation script (install.sh), license (LICENSE), and README documentation.

### 🚀 Improved
- Refactor user prompts in .gitok.sh: Update read commands to use -r flag for better handling of input and modify git reset command to quote the count variable for improved safety.
- Update README.md: Modify installation command to use curl directly for improved clarity.


### ✨ Added
- Dynamic changelog generation system
- Auto-generated release notes from git commits
- Conventional commit parsing and categorization
- Enhanced CI/CD pipeline with automated changelog updates

### 🚀 Improved
- Release process now fully automated
- Better categorization of changes in releases
- More detailed and informative changelogs

## [1.0.0] - 2025-06-14

### Added
- Initial release of Gitok
- 35+ Git aliases and shortcuts
- Interactive installation script
- Git cheatsheet functionality
- Core Git operations: commit, push, pull, branch management
- Advanced features: pushall, unpush, squashlast
- Safety confirmations for destructive operations
- Apache License
- Basic README documentation

### Features
- **Repository Management**: clone, init, status
- **Staging & Commits**: addall, commit, commitonly, amendmsg
- **Push & Pull**: push, pushall, pushnew, pull, unpush, trackremote
- **Branches**: branch, checkout, branches, deletebranch, deletebranchf
- **Logs & History**: graphlog, last, logfull, diff
- **Undo & Reset**: resetsoft, resethard, revertlast, unstage, restore
- **Stash & Temporary**: stash, pop
- **Cleanup & Tools**: clean, tracked, remotes, squashlast
- **Files & Ignore**: ignore, makeignore
- **Help**: gitcheatsheet

[Unreleased]: https://github.com/okwareddevnest/gitok/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/okwareddevnest/gitok/releases/tag/v1.0.0 