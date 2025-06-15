@echo off
REM Gitok Windows Installation Script
REM Double-click this file to install Gitok on Windows

setlocal enabledelayedexpansion

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

echo [INFO] Checking system requirements...

REM Check if Git is installed
git --version >nul 2>&1
if !errorLevel! neq 0 (
    echo.
    echo [ERROR] Git is not installed or not in PATH
    echo Please install Git for Windows first:
    echo https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

echo [OK] Git is installed

REM Initialize variables
set "installationSuccess=false"
set "profilesUpdated=0"

REM Check for WSL
echo [INFO] Checking for WSL...
wsl --status >nul 2>&1
if !errorLevel! equ 0 (
    echo [OK] WSL detected - Installing via WSL ^(Recommended^)
    
    REM Test if WSL is working
    wsl echo test >nul 2>&1
    if !errorLevel! equ 0 (
        echo [INFO] Installing Gitok in WSL...
        wsl bash -c "curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/install.sh | bash"
        if !errorLevel! equ 0 (
            echo [SUCCESS] Gitok installed in WSL!
            
            REM Test WSL installation
            for /f "delims=" %%i in ('wsl bash -c "source ~/.gitok.sh && gitok --version" 2^>nul') do set "wslVersion=%%i"
            if defined wslVersion (
                echo [SUCCESS] WSL installation successful!
                echo Version: !wslVersion!
                set "installationSuccess=true"
            )
        ) else (
            echo [WARNING] WSL installation encountered issues, trying Git Bash...
        )
    ) else (
        echo [WARNING] WSL not properly configured, trying Git Bash...
    )
) else (
    echo [INFO] WSL not available, checking Git Bash...
)

REM Check for Git Bash
echo [INFO] Checking for Git Bash...
set "gitBashPath="
if exist "%ProgramFiles%\Git\bin\bash.exe" (
    set "gitBashPath=%ProgramFiles%\Git\bin\bash.exe"
) else if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" (
    set "gitBashPath=%ProgramFiles(x86)%\Git\bin\bash.exe"
) else if exist "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" (
    set "gitBashPath=%LOCALAPPDATA%\Programs\Git\bin\bash.exe"
)

if defined gitBashPath (
    echo [OK] Git Bash detected at: !gitBashPath!
    
    REM Download gitok
    echo [INFO] Downloading Gitok...
    "!gitBashPath!" -c "curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/.gitok.sh -o ~/.gitok.sh && chmod +x ~/.gitok.sh"
    if !errorLevel! equ 0 (
        echo [SUCCESS] Gitok downloaded successfully
        
        REM Configure shell profiles
        echo [INFO] Configuring shell profiles...
        for %%p in (.bashrc .bash_profile .profile) do (
            for /f "delims=" %%r in ('"!gitBashPath!" -c "
                profile=~/%%p
                if [[ ! -f $profile ]]; then 
                    touch $profile
                    echo 'Created %%p'
                elif ! grep -q 'source.*\.gitok\.sh' $profile; then
                    echo '' >> $profile
                    echo '# Gitok - Git CLI Aliases' >> $profile
                    echo 'source ~/.gitok.sh' >> $profile
                    echo 'Added to %%p'
                else
                    echo 'Already configured in %%p'
                fi
            "') do (
                if "%%r"=="Created %%p" (
                    echo [INFO] Created %%p profile
                ) else if "%%r"=="Added to %%p" (
                    echo [SUCCESS] Configured %%p
                    set /a profilesUpdated+=1
                ) else if "%%r"=="Already configured in %%p" (
                    echo [INFO] Already configured in %%p
                )
            )
        )
        
        REM Test installation
        echo [INFO] Testing installation...
        for /f "delims=" %%v in ('"!gitBashPath!" -c "source ~/.gitok.sh && gitok --version" 2^>nul') do set "gitBashVersion=%%v"
        if defined gitBashVersion (
            echo [SUCCESS] Git Bash installation successful!
            echo Version: !gitBashVersion!
            set "installationSuccess=true"
        )
    ) else (
        echo [ERROR] Failed to download Gitok
    )
) else (
    echo [WARNING] Git Bash not found
)

REM Display results
echo.
echo ===============================================
if "!installationSuccess!"=="true" (
    echo Installation completed successfully!
    echo ===============================================
    echo.
    echo [SUCCESS] Gitok is now installed and configured!
    echo.
    echo How to use Gitok:
    echo.
    
    REM Check what's available and show appropriate instructions
    wsl --status >nul 2>&1
    if !errorLevel! equ 0 (
        wsl echo test >nul 2>&1
        if !errorLevel! equ 0 (
            echo   WSL ^(Recommended^):
            echo     1. Type: wsl
            echo     2. Run: gitok --version
            echo     3. Run: gitcheatsheet
            echo.
        )
    )
    
    if defined gitBashPath (
        echo   Git Bash:
        echo     1. Open Git Bash terminal
        echo     2. Run: gitok --version
        echo     3. Run: gitcheatsheet
        echo.
    )
    
    echo Quick Commands:
    echo   gitok --version      - Check version
    echo   gitcheatsheet        - View all commands
    echo   gitok --help         - Get help
    echo   gitok --update       - Update Gitok
    echo.
    echo Profiles updated: !profilesUpdated!
    
) else (
    echo Installation failed
    echo ===============================================
    echo.
    echo [ERROR] Could not install Gitok
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
)

echo.
echo Documentation: https://github.com/okwareddevnest/gitok
echo Support: https://github.com/okwareddevnest/gitok/issues
echo.
pause

if "!installationSuccess!"=="true" (
    exit /b 0
) else (
    exit /b 1
) 