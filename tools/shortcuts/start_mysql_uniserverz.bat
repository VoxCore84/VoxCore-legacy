@echo off
title UniServerZ MySQL 9.5.0
set MYSQL_DIR=C:\Users\atayl\VoxCore\out\build\x64-RelWithDebInfo\bin\RelWithDebInfo\UniServerZ\core\mysql

echo === Starting UniServerZ MySQL 9.5.0 ===
echo Data dir: %MYSQL_DIR%\data
echo Port: 3306

:: Check if something is already on port 3306
netstat -ano | findstr ":3306 " | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo.
    echo WARNING: Port 3306 is already in use!
    echo Stop MySQL80 service first: net stop MySQL80
    echo.
    pause
    exit /b 1
)

start "UniServerZ MySQL" "%MYSQL_DIR%\bin\mysqld_z.exe" ^
    "--defaults-file=%MYSQL_DIR%\my.ini" ^
    "--basedir=%MYSQL_DIR%" ^
    "--datadir=%MYSQL_DIR%\data" ^
    --port=3306 ^
    --console

%SYSTEMROOT%\system32\timeout.exe /t 5 /nobreak >nul
echo.
echo Checking connection...
"%MYSQL_DIR%\bin\mysql.exe" -u root -padmin -h 127.0.0.1 -P 3306 -e "SELECT 'MySQL ready!' AS status, VERSION() AS version;" 2>nul
if errorlevel 1 (
    echo Connection test failed - server may still be starting.
) else (
    echo.
    echo === UniServerZ MySQL is running ===
)
echo.
pause
