# Gitok – Git CLI Aliases by Dedan Okware

Gitok is a productivity boost for developers. It includes 35+ custom Git commands and functions like `commit`, `pushall`, `unpush`, `gitcheatsheet`, and now features **automatic updates** and **semantic versioning**.

## ✨ Features

- 🚀 **35+ Git aliases** for faster Git workflows
- 🔄 **Auto-update system** (`gitok --update`)
- 📋 **Interactive cheatsheet** (`gitcheatsheet`)  
- 🔒 **Safety confirmations** for destructive operations
- 📦 **Semantic versioning** with automated releases
- 🛠️ **CI/CD pipeline** with GitHub Actions
- 🪟 **Cross-platform support** (Linux, macOS, Windows WSL, Git Bash)
- ⚡ **Zero configuration** - works out of the box

## 📦 Installation

### 🐧 Linux & macOS
```bash
bash <(curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/install.sh)
```

### 🪟 Windows Users

**Option 1: Windows Subsystem for Linux (WSL) - Recommended**
```powershell
# Install WSL if not already installed
wsl --install

# After restart, install Gitok in WSL
wsl bash -c "curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/install.sh | bash"
```

**Option 2: Git Bash (comes with Git for Windows)**
1. Install [Git for Windows](https://git-scm.com/download/win) (includes Git Bash)
2. Open Git Bash terminal
3. Run: `bash <(curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/install.sh)`

**Option 3: Automated Windows Installer**
```powershell
# PowerShell (Run as Administrator)
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/okwareddevnest/gitok/main/install-windows.ps1'))

# OR download and double-click
# https://raw.githubusercontent.com/okwareddevnest/gitok/main/install-windows.bat
```

### ✅ Verify Installation
```bash
# Restart your terminal or run:
source ~/.bashrc  # or source ~/.zshrc

# Test installation
gitok --version
gitcheatsheet
```

## 🔄 Updates

### Automatic Updates
```bash
gitok --update
```

### Check Version
```bash
gitok --version
```

### Get Help
```bash
gitok --help
# or
gitcheatsheet
```

## 🚀 Quick Start

```bash
# Initialize and make first commit
init
commit "Initial commit"

# Create and switch to new branch
branch feature/new-feature
commit "Add new feature"

# Push to all remotes with rebase
pushall

# View commit history
graphlog

# See all available commands
gitcheatsheet
```

## 📋 Available Commands

Run `gitcheatsheet` for a complete list, or see key commands below:

### Core Operations
- `commit "message"` - Stage all & commit
- `push` - Push to current branch
- `pushall` - Push to all remotes (with rebase)
- `pull` - Pull with rebase
- `status` - Git status

### Branch Management
- `branch <name>` - Create & switch to branch
- `checkout <name>` - Switch to branch
- `branches` - List all branches
- `deletebranch <name>` - Safe delete branch

### Advanced Features
- `unpush` - Undo last push (⚠️ dangerous)
- `squashlast [N]` - Squash last N commits
- `pushall --dry-run` - Test push to all remotes
- `makeignore <type>` - Create .gitignore template

## 🛠️ Development

### Version Management

Bump version manually:
```bash
./scripts/bump-version.sh patch  # 1.0.0 -> 1.0.1
./scripts/bump-version.sh minor  # 1.0.1 -> 1.1.0  
./scripts/bump-version.sh major  # 1.1.0 -> 2.0.0
```

### CI/CD Pipeline

The project uses GitHub Actions for:
- ✅ **Automated testing** with ShellCheck
- 🔖 **Semantic versioning** and releases
- 🔒 **Security scanning**
- 📦 **Automated releases** on version bumps

Trigger a release:
1. Use GitHub Actions workflow dispatch
2. Or commit with `[release]` in message
3. Or use the version bump script

## 📄 License

Apache License - see [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `shellcheck .gitok.sh`
5. Submit a pull request

## 📧 Contact

Created by **Dedan Okware** - softengdedan@gmail.com

---
⭐ **Star this repo** if Gitok helps boost your Git productivity!
