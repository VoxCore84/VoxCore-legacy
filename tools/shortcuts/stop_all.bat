@echo off
echo ============================================
echo   VoxCore — Stopping All Servers
echo ============================================
echo.

echo [1/4] Stopping worldserver...
taskkill /IM worldserver.exe /F >nul 2>&1
if %ERRORLEVEL%==0 (echo        Stopped.) else (echo        Not running.)
echo.

echo [2/4] Stopping bnetserver...
taskkill /IM bnetserver.exe /F >nul 2>&1
if %ERRORLEVEL%==0 (echo        Stopped.) else (echo        Not running.)
echo.

echo [3/4] Stopping MySQL (UniServerZ)...
taskkill /IM mysqld_z.exe /F >nul 2>&1
if %ERRORLEVEL%==0 (echo        UniServerZ MySQL stopped.) else (echo        UniServerZ not running.)
echo.

echo [4/4] Stopping Command Center (port 5050)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5050 " ^| findstr "LISTENING"') do (
    taskkill /PID %%a /F >nul 2>&1
)
if %ERRORLEVEL%==0 (echo        Stopped.) else (echo        Not running.)
echo.

echo ============================================
echo   All servers stopped.
echo ============================================
%SYSTEMROOT%\system32\timeout.exe /t 3
