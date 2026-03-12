@echo off
title BestiaryForge - Creature Intelligence Pipeline
echo.
echo ============================================================
echo   BestiaryForge - Creature Intelligence Pipeline
echo ============================================================
echo.

REM Check Python
where python >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH.
    echo Download from https://python.org/downloads/
    echo.
    pause
    exit /b 1
)

REM Check pymysql
python -c "import pymysql" >nul 2>&1
if errorlevel 1 (
    echo Installing pymysql dependency...
    pip install pymysql
    if errorlevel 1 (
        echo.
        echo ERROR: Could not install pymysql.
        echo Try manually: pip install pymysql
        pause
        exit /b 1
    )
    echo.
)

cd /d "%~dp0"
python forge.py %*
exit /b %errorlevel%
