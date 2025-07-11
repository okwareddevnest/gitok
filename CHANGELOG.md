# Changelog

All notable changes to GitOK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-07

### ✨ Added
- 35+ Git aliases and shortcuts for enhanced productivity
- Interactive installation script with cross-platform support
- Auto-update system with version checking via GitHub API
- Interactive cheatsheet functionality (`gitcheatsheet`)
- Comprehensive Windows support (PowerShell, batch, WSL, Git Bash)
- Automated shell profile configuration (bash, zsh, fish)
- Safety confirmations for destructive operations
- CI/CD pipeline with GitHub Actions for automated testing and releases
- Dynamic changelog generation from conventional commits
- ShellCheck validation for code quality

### 🚀 Core Features
- **Repository Management**: `init`, `clone`, `status`
- **Staging & Commits**: `addall`, `commit`, `commitonly`, `amendmsg`
- **Push & Pull**: `push`, `pushall`, `pushnew`, `pull`, `unpush`, `trackremote`
- **Branch Management**: `branch`, `checkout`, `branches`, `deletebranch`, `deletebranchf`
- **History & Logs**: `graphlog`, `last`, `logfull`, `diff`
- **Undo & Reset**: `resetsoft`, `resethard`, `revertlast`, `unstage`, `restore`
- **Stash Operations**: `stash`, `pop`
- **Cleanup Tools**: `clean`, `tracked`, `remotes`, `squashlast`
- **File Management**: `ignore`, `makeignore`
- **Help System**: `gitcheatsheet`, `gitok --help`

### 🔧 Technical Improvements
- Enhanced error handling and user feedback
- Improved GitHub API integration for reliable version checking
- Cross-platform compatibility across Linux, macOS, and Windows
- Intelligent shell detection and configuration
- Automated installation with immediate activation
- Colorized output for better user experience

### 🛠️ Development Tools
- Version management scripts (`./scripts/bump-version.sh`)
- Automated changelog generation (`./scripts/generate-changelog.sh`)
- CI/CD pipeline for testing and releases
- ShellCheck integration for code quality assurance

[1.0.0]: https://github.com/okwareddevnest/gitok/releases/tag/v1.0.0
## [1.0.2] - 2025-07-07

### 🐛 Fixed
- Improve update mechanism with rate limit handling and fallback methods

### 📝 Other Changes
- 🔖 Bump version to v1.0.1


## [1.0.3] - 2025-07-07

### 📝 Other Changes
- Trigger: create missing v1.0.1 GitHub release [release]


## [1.0.4] - 2025-07-07

### 🐛 Fixed
- Integrate release creation into version-and-release job [release]


## [1.0.5] - 2025-07-07

### ✨ Added
- Implement dynamic release notes generation [release]


## [2.0.0] - 2025-07-11

### 📝 Other Changes
- 🚀 MAJOR RELEASE: Transform GitOK into Advanced GitHub Project Management Platform [release]

