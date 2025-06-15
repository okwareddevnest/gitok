@echo off
REM Gitok Windows Installation Script
REM Double-click this file to install Gitok on Windows

echo.
echo ===============================================
echo    Gitok Installation for Windows
echo    by Dedan Okware
echo ===============================================
echo.

REM Check if running as administrator (optional, for better compatibility)
REM net session >nul 2>&1
REM if %errorLevel% == 0 (
REM     echo Running with administrator privileges...
REM ) else (
REM     echo Note: Some features may require administrator privileges
REM )

echo Checking system requirements...

REM Check if Git is installed
git --version >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo [ERROR] Git is not installed or not in PATH
    echo Please install Git for Windows first:
    echo https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

echo [OK] Git is installed

REM Check for WSL
wsl --status >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] WSL detected - Installing via WSL ^(Recommended^)
    wsl bash -c "curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/install.sh | bash"
    if %errorLevel% equ 0 (
        echo.
        echo [SUCCESS] Gitok installed in WSL!
        echo.
        echo To use Gitok:
        echo   wsl
        echo   gitok --version
        echo   gitcheatsheet
        echo.
        pause
        exit /b 0
    ) else (
        echo [WARNING] WSL installation failed, trying Git Bash...
    )
)

REM Check for Git Bash
set "gitBashPath="
if exist "%ProgramFiles%\Git\bin\bash.exe" (
    set "gitBashPath=%ProgramFiles%\Git\bin\bash.exe"
) else if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" (
    set "gitBashPath=%ProgramFiles(x86)%\Git\bin\bash.exe"
) else if exist "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" (
    set "gitBashPath=%LOCALAPPDATA%\Programs\Git\bin\bash.exe"
)

if defined gitBashPath (
    echo [OK] Git Bash detected - Installing via Git Bash
    
    REM Install gitok
    "%gitBashPath%" -c "curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/.gitok.sh -o ~/.gitok.sh"
    if %errorLevel% equ 0 (
        "%gitBashPath%" -c "echo 'source ~/.gitok.sh' >> ~/.bashrc"
        echo.
        echo [SUCCESS] Gitok installed for Git Bash!
        echo.
        echo To use Gitok:
        echo   1. Open Git Bash terminal
        echo   2. Run: source ~/.bashrc
        echo   3. Test: gitok --version
        echo   4. Get help: gitcheatsheet
        echo.
    ) else (
        echo [ERROR] Installation failed
        goto :error
    )
) else (
    echo [ERROR] Neither WSL nor Git Bash found
    goto :error
)

echo.
echo ===============================================
echo Installation completed successfully!
echo ===============================================
echo.
pause
exit /b 0

:error
echo.
echo ===============================================
echo Installation Requirements
echo ===============================================
echo.
echo To use Gitok on Windows, you need one of:
echo.
echo 1. Windows Subsystem for Linux ^(WSL^) - Recommended
echo    Install: wsl --install
echo    Then restart and run this installer again
echo.
echo 2. Git for Windows ^(includes Git Bash^)
echo    Download: https://git-scm.com/download/win
echo    Make sure to install Git Bash option
echo.
echo After installing either option, run this script again.
echo.
pause
exit /b 1 