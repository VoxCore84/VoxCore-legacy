@echo off
call "C:\Program Files\Microsoft Visual Studio\2026\Community\VC\Auxiliary\Build\vcvarsall.bat" x64 >nul 2>&1

:: Resolve VoxCore root by stepping up two directories from tools/shortcuts/
set "ROOT=%~dp0..\.."
for %%i in ("%ROOT%") do set "ROOT=%%~fi"

cd /d "%ROOT%\out\build\x64-RelWithDebInfo"
echo === Building scripts (RelWithDebInfo) ===
ninja -j20 scripts
if errorlevel 1 (
    echo.
    echo BUILD FAILED
) else (
    echo.
    echo === Scripts built successfully ===
)
