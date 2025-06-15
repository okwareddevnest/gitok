# Gitok for Windows Users

## 🪟 Windows Installation Guide

Gitok fully supports Windows through multiple installation methods. Choose the one that works best for your setup.

## 📋 Prerequisites

**Required:** Git must be installed on your system
- Download: [Git for Windows](https://git-scm.com/download/win)
- Make sure to include "Git Bash" during installation

## 🚀 Installation Methods

### Method 1: WSL (Windows Subsystem for Linux) - Recommended ⭐

**Why WSL?**
- ✅ Full Linux compatibility
- ✅ Best performance
- ✅ Native bash environment
- ✅ Seamless integration with VS Code

**Installation:**
```powershell
# 1. Install WSL (requires restart)
wsl --install

# 2. Restart your computer

# 3. Install Gitok in WSL
wsl bash -c "curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/install.sh | bash"

# 4. Test installation
wsl gitok --version
```

**Usage in WSL:**
```bash
# Enter WSL environment
wsl

# Use Gitok normally
gitok --version
gitcheatsheet
commit "your message"
pushall
```

### Method 2: Git Bash - Easy Setup

**Installation:**
```bash
# Open Git Bash terminal
# Paste this command:
bash <(curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/install.sh)

# Restart Git Bash or run:
source ~/.bashrc
```

**Usage in Git Bash:**
- Open Git Bash terminal
- Use all Gitok commands normally
- Works in any directory with Git repositories

### Method 3: Automated Windows Installer

**PowerShell Installation:**
```powershell
# Run PowerShell as Administrator
# Paste this command:
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/okwareddevnest/gitok/main/install-windows.ps1'))
```

**Batch File Installation:**
1. Download: [install-windows.bat](https://raw.githubusercontent.com/okwareddevnest/gitok/main/install-windows.bat)
2. Right-click → "Run as administrator"
3. Follow the on-screen instructions

## 🎯 Which Method Should I Choose?

| Method | Best For | Pros | Cons |
|--------|----------|------|------|
| **WSL** | Developers using Linux tools | Full compatibility, best performance | Requires Windows 10+, initial setup |
| **Git Bash** | Quick setup, occasional use | Easy installation, familiar to Git users | Limited bash environment |
| **Automated** | Non-technical users | GUI installation, auto-detection | Requires admin privileges |

## 🔧 Troubleshooting

### "WSL not found"
```powershell
# Enable WSL feature
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Install WSL
wsl --install

# Restart computer
```

### "Git not found"
1. Install [Git for Windows](https://git-scm.com/download/win)
2. Make sure Git is added to PATH during installation
3. Restart terminal and try again

### "curl not found" in Git Bash
- Update Git for Windows to latest version
- Curl is included in recent Git for Windows installations

### Commands not working in PowerShell/CMD
- Gitok is designed for bash environments
- Use WSL or Git Bash for best experience
- PowerShell equivalents may be added in future versions

## 💡 Windows-Specific Tips

### VS Code Integration
```bash
# In WSL terminal
code .  # Opens current directory in VS Code

# Use Gitok commands in VS Code terminal
commit "VS Code integration working"
push
```

### File Path Considerations
- WSL: Use Linux-style paths (`/home/user/project`)
- Git Bash: Use Windows or Unix-style paths (`C:/Users/user/project` or `/c/Users/user/project`)

### Performance Tips
- **WSL2**: Significantly faster than WSL1
- **Git Bash**: Keep repositories on the same drive for better performance
- **Windows Defender**: Add Git directories to exclusions for faster operations

## 🚀 Getting Started on Windows

1. **Install using your preferred method**
2. **Open your terminal** (WSL, Git Bash, or PowerShell)
3. **Navigate to a Git repository**
4. **Test Gitok:**
   ```bash
   gitok --version
   gitcheatsheet
   status
   ```
5. **Start using shortcuts:**
   ```bash
   commit "first commit with gitok"
   push
   ```

## 🔄 Updating Gitok on Windows

```bash
# Works in all environments
gitok --update

# Manual update (if auto-update fails)
curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/.gitok.sh -o ~/.gitok.sh
source ~/.bashrc
```

## 🆘 Need Help?

- 📖 **Full documentation**: Check the main [README.md](README.md)
- 🐛 **Issues**: [GitHub Issues](https://github.com/okwareddevnest/gitok/issues)
- 💬 **Questions**: Create a discussion on GitHub
- 📧 **Contact**: softengdedan@gmail.com

## 🎉 Windows-Specific Features

- **Auto-detection** of WSL vs Git Bash
- **Path compatibility** across Windows and Unix-style paths  
- **Windows Terminal** integration
- **VS Code** terminal support
- **PowerShell** installation scripts

---

**Made with ❤️ for Windows developers by Dedan Okware** 