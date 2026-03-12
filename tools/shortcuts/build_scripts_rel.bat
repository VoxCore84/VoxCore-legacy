@echo off
setlocal

:: Resolve VoxCore root and VS toolchain dynamically
set "ROOT=%~dp0..\.."
for %%i in ("%ROOT%") do set "ROOT=%%~fi"

:: Use vswhere to find VS installation dynamically
for /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath 2^>nul`) do set "VS_PATH=%%i"

if not defined VS_PATH (
    echo ERROR: Visual Studio not found via vswhere.
    exit /b 1
)

call "%VS_PATH%\VC\Auxiliary\Build\vcvarsall.bat" x64 >nul 2>&1

cd /d "%ROOT%\out\build\x64-RelWithDebInfo"
echo === Building scripts (RelWithDebInfo) ===
ninja -j32 scripts
if errorlevel 1 (
    echo.
    echo BUILD FAILED
) else (
    echo.
    echo === Scripts built successfully ===
)
