# PowerShell installation script for Gitok on Windows
# Run this in PowerShell as Administrator or with appropriate permissions

Write-Host "🔧 Installing Gitok for Windows by Dedan Okware..." -ForegroundColor Cyan

# Check if Git is installed
$gitInstalled = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitInstalled) {
    Write-Host "❌ Git is not installed. Please install Git for Windows first:" -ForegroundColor Red
    Write-Host "   https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Determine the best installation method
$installPath = ""
$profilePath = ""

# Check for WSL
$wslAvailable = Get-Command wsl -ErrorAction SilentlyContinue
if ($wslAvailable) {
    Write-Host "✅ WSL detected - Installing via WSL (Recommended)" -ForegroundColor Green
    try {
        wsl bash -c "curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/install.sh | bash"
        Write-Host "✅ Gitok installed in WSL!" -ForegroundColor Green
        Write-Host "💡 Access via: wsl gitok --version" -ForegroundColor Yellow
        exit 0
    }
    catch {
        Write-Host "⚠️  WSL installation failed, trying Git Bash..." -ForegroundColor Yellow
    }
}

# Check for Git Bash
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
    Write-Host "✅ Git Bash detected - Installing via Git Bash" -ForegroundColor Green
    
    # Install gitok for Git Bash
    $installScript = "curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/.gitok.sh -o ~/.gitok.sh"
    $bashrcUpdate = "echo 'source ~/.gitok.sh' >> ~/.bashrc"
    
    try {
        & $gitBashPath -c $installScript
        & $gitBashPath -c $bashrcUpdate
        
        Write-Host "✅ Gitok installed for Git Bash!" -ForegroundColor Green
        Write-Host "💡 Restart Git Bash or run: source ~/.bashrc" -ForegroundColor Yellow
        Write-Host "💡 Access via Git Bash terminal" -ForegroundColor Yellow
    }
    catch {
        Write-Host "❌ Git Bash installation failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ Neither WSL nor Git Bash found" -ForegroundColor Red
    Write-Host "" -ForegroundColor White
    Write-Host "📋 To use Gitok on Windows, you need one of:" -ForegroundColor Yellow
    Write-Host "   1. Windows Subsystem for Linux (WSL) - Recommended" -ForegroundColor White
    Write-Host "      Install: wsl --install" -ForegroundColor Gray
    Write-Host "   2. Git for Windows (includes Git Bash)" -ForegroundColor White
    Write-Host "      Download: https://git-scm.com/download/win" -ForegroundColor Gray
    Write-Host "" -ForegroundColor White
    Write-Host "💡 After installation, run this script again" -ForegroundColor Cyan
    exit 1
}

Write-Host "" -ForegroundColor White
Write-Host "🎉 Installation complete!" -ForegroundColor Green
Write-Host "📖 Get started:" -ForegroundColor Cyan
Write-Host "   gitok --version" -ForegroundColor White
Write-Host "   gitcheatsheet" -ForegroundColor White
Write-Host "   gitok --help" -ForegroundColor White 