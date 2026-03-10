@echo off
setlocal enabledelayedexpansion
echo ========================================================
echo   AI Studio Manager
echo   Scraping Desktop\Excluded for new ChatGPT documents...
echo ========================================================
echo.

:: Resolve VoxCore root by stepping up two directories from tools/shortcuts/
set "ROOT=%~dp0..\.."
for %%i in ("%ROOT%") do set "ROOT=%%~fi"

set "EXCLUDED=%USERPROFILE%\OneDrive\Desktop\Excluded"
set "STUDIO=%ROOT%\AI_Studio"
set "INBOX=%STUDIO%\1_Inbox"

if not exist "%INBOX%" mkdir "%INBOX%"

set /a count=0
for %%e in (*.md *.txt *.json *.csv *.sql *.lua) do (
    if exist "%EXCLUDED%\%%e" (
        move /Y "%EXCLUDED%\%%e" "%INBOX%\" >nul 2>&1
        set /a count+=1
    )
)

if !count! GTR 0 (
    echo [SUCCESS] Moved project files to AI_Studio\1_Inbox
) else (
    echo [INFO] No relevant AI project files found in Excluded folder.
)

echo.
echo Opening AI Studio...
explorer "%STUDIO%"
endlocal
exit
