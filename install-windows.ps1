# PowerShell installation script for GitOK on Windows
# Run this in PowerShell as Administrator or with appropriate permissions

Write-Host "🔧 Installing GitOK for Windows by Dedan Okware..." -ForegroundColor Cyan

# Helper function for profile management
function Add-ToProfile {
    param(
        [string]$ProfilePath,
        [string]$ProfileName,
        [string]$Command = "source ~/.gitok.sh"
    )
    
    # Ensure profile directory exists
    $profileDir = Split-Path $ProfilePath
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
    }
    
    # Create profile if needed
    if (-not (Test-Path $ProfilePath)) {
        New-Item -ItemType File -Force -Path $ProfilePath | Out-Null
        Write-Host "📄 Created $ProfileName" -ForegroundColor Yellow
    }
    
    # Skip if already set up
    $content = Get-Content $ProfilePath -ErrorAction SilentlyContinue
    $hasGitok = $content | Where-Object { $_ -match "source.*\.gitok\.sh|\..*\.gitok\.sh" }
    
    if (-not $hasGitok) {
        Add-Content $ProfilePath "`n# GitOK - GitOK"
        Add-Content $ProfilePath $Command
        Write-Host "✅ Added GitOK to $ProfileName" -ForegroundColor Green
        return $true
    } else {
        Write-Host "⚠️  GitOK already configured in $ProfileName" -ForegroundColor Yellow
        return $false
    }
}

# Check if Git is installed
$gitInstalled = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitInstalled) {
    Write-Host "❌ Git is not installed. Please install Git for Windows first:" -ForegroundColor Red
    Write-Host "   https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Git is installed" -ForegroundColor Green

# Initialize counters
$profilesUpdated = 0
$installationSuccess = $false

# Check for WSL and install there (preferred method)
Write-Host "🔍 Checking for WSL..." -ForegroundColor Blue
$wslAvailable = Get-Command wsl -ErrorAction SilentlyContinue
if ($wslAvailable) {
    Write-Host "✅ WSL detected - Installing via WSL (Recommended)" -ForegroundColor Green
    try {
        # Check if WSL is actually working
        $wslTest = wsl echo "test" 2>$null
        if ($LASTEXITCODE -eq 0) {
            # Install in WSL
            $wslInstall = wsl bash -c "curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/install.sh | bash"
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ GitOK installed in WSL!" -ForegroundColor Green
                
                # Test WSL installation
                $wslVersion = wsl bash -c "source ~/.gitok.sh && gitok --version" 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "🎉 WSL installation successful!" -ForegroundColor Green
                    Write-Host "Version: $wslVersion" -ForegroundColor Cyan
                    $installationSuccess = $true
                }
            } else {
                Write-Host "⚠️  WSL installation encountered issues, trying Git Bash..." -ForegroundColor Yellow
            }
        } else {
            Write-Host "⚠️  WSL not properly configured, trying Git Bash..." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "⚠️  WSL installation failed: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "Trying Git Bash..." -ForegroundColor Yellow
    }
}

# Check for Git Bash and install there as fallback
Write-Host "🔍 Checking for Git Bash..." -ForegroundColor Blue
$gitBashPath = ""
$possiblePaths = @(
    "${env:ProgramFiles}\Git\bin\bash.exe",
    "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
    "${env:LOCALAPPDATA}\Programs\Git\bin\bash.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $gitBashPath = $path
        break
    }
}

if ($gitBashPath) {
    Write-Host "✅ Git Bash detected at: $gitBashPath" -ForegroundColor Green
    
    try {
        # Download gitok to user home
        & $gitBashPath -c "curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/.gitok.sh -o ~/.gitok.sh && chmod +x ~/.gitok.sh"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ GitOK downloaded successfully" -ForegroundColor Green
            
            # Configure shell profiles in Git Bash environment
            $bashProfiles = @("~/.bashrc", "~/.bash_profile", "~/.profile")
            foreach ($profile in $bashProfiles) {
                $addResult = & $gitBashPath -c "
                    if [[ ! -f $profile ]]; then 
                        touch $profile
                        echo 'Created $profile'
                    fi
                    if ! grep -q 'source.*\.gitok\.sh' $profile; then
                        echo '' >> $profile
                        echo '# GitOK - GitOK' >> $profile
                        echo 'source ~/.gitok.sh' >> $profile
                        echo 'Added to $profile'
                    else
                        echo 'Already configured in $profile'
                    fi
                "
                
                if ($addResult -match "Added to") {
                    $profilesUpdated++
                    Write-Host "✅ Configured $(($profile -split '/')[-1])" -ForegroundColor Green
                } elseif ($addResult -match "Already configured") {
                    Write-Host "⚠️  Already configured in $(($profile -split '/')[-1])" -ForegroundColor Yellow
                }
            }
            
            # Test Git Bash installation
            $gitBashTest = & $gitBashPath -c "source ~/.gitok.sh && gitok --version" 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "🎉 Git Bash installation successful!" -ForegroundColor Green
                Write-Host "Version: $gitBashTest" -ForegroundColor Cyan
                $installationSuccess = $true
            }
        } else {
            Write-Host "❌ Failed to download GitOK for Git Bash" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ Git Bash installation failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Summary and instructions
Write-Host "" -ForegroundColor White
if ($installationSuccess) {
    Write-Host "🎉 Installation completed successfully!" -ForegroundColor Green
    Write-Host "" -ForegroundColor White
    Write-Host "📖 How to use GitOK:" -ForegroundColor Cyan
    
    if ($wslAvailable -and (wsl echo "test" 2>$null; $LASTEXITCODE -eq 0)) {
        Write-Host "   🐧 WSL (Recommended):" -ForegroundColor Blue
        Write-Host "      wsl" -ForegroundColor White
        Write-Host "      gitok --version" -ForegroundColor White
        Write-Host "      gitcheatsheet" -ForegroundColor White
    }
    
    if ($gitBashPath) {
        Write-Host "   🖥️  Git Bash:" -ForegroundColor Blue
        Write-Host "      Open Git Bash terminal" -ForegroundColor White
        Write-Host "      gitok --version" -ForegroundColor White
        Write-Host "      gitcheatsheet" -ForegroundColor White
    }
    
    Write-Host "" -ForegroundColor White
    Write-Host "🚀 Quick Commands:" -ForegroundColor Cyan
    Write-Host "   gitok --version      - Check version" -ForegroundColor White
    Write-Host "   gitcheatsheet        - View all commands" -ForegroundColor White
    Write-Host "   gitok --help         - Get help" -ForegroundColor White
    Write-Host "   gitok --update       - Update GitOK" -ForegroundColor White
    
} else {
    Write-Host "❌ Installation failed" -ForegroundColor Red
    Write-Host "" -ForegroundColor White
    Write-Host "📋 To use GitOK on Windows, you need one of:" -ForegroundColor Yellow
    Write-Host "   1. Windows Subsystem for Linux (WSL) - Recommended" -ForegroundColor White
    Write-Host "      Install: wsl --install" -ForegroundColor Gray
    Write-Host "      Then restart and run this installer again" -ForegroundColor Gray
    Write-Host "   2. Git for Windows (includes Git Bash)" -ForegroundColor White
    Write-Host "      Download: https://git-scm.com/download/win" -ForegroundColor Gray
    Write-Host "      Make sure to install Git Bash option" -ForegroundColor Gray
    
    exit 1
}

Write-Host "" -ForegroundColor White
Write-Host "🔗 Documentation: https://github.com/okwareddevnest/gitok" -ForegroundColor Cyan
Write-Host "💬 Support: https://github.com/okwareddevnest/gitok/issues" -ForegroundColor Cyan 