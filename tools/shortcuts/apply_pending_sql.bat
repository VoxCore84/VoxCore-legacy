@echo off
setlocal enabledelayedexpansion

:: Resolve VoxCore root
set "ROOT=%~dp0..\.."
for %%i in ("%ROOT%") do set "ROOT=%%~fi"

set "MYSQL_DIR=%ROOT%\out\build\x64-RelWithDebInfo\bin\RelWithDebInfo\UniServerZ\core\mysql"
set "PENDING_DIR=%ROOT%\sql\updates\pending"
set "APPLIED_DIR=%ROOT%\sql\updates\applied"

if not exist "%PENDING_DIR%" mkdir "%PENDING_DIR%"
if not exist "%APPLIED_DIR%" mkdir "%APPLIED_DIR%"

set count=0
for %%f in ("%PENDING_DIR%\*.sql") do (
    set /a count+=1
)

if !count!==0 (
    echo        No pending SQL updates found.
    goto :EOF
)

echo        Found !count! pending SQL update(s) in %PENDING_DIR%.
choice /C YN /M "Execute and apply these updates now?" /T 15 /D N
if !ERRORLEVEL! NEQ 1 (
    echo        Skipping pending SQL updates.
    goto :EOF
)

set applied=0
for %%f in ("%PENDING_DIR%\*.sql") do (
    set "FNAME=%%~nf"
    set "DB=world"

    :: Parse DB name from filename convention: YYYY_MM_DD_NN_<db>.sql
    :: Extract everything after the 4th underscore
    for /f "tokens=5 delims=_" %%d in ("!FNAME!") do set "DB=%%d"

    :: Validate known databases, default to world
    if /i "!DB!"=="auth" (set "DB=auth"
    ) else if /i "!DB!"=="characters" (set "DB=characters"
    ) else if /i "!DB!"=="hotfixes" (set "DB=hotfixes"
    ) else if /i "!DB!"=="roleplay" (set "DB=roleplay"
    ) else (set "DB=world")

    echo        Applying %%~nxf to [!DB!]...
    "%MYSQL_DIR%\bin\mysql.exe" -uroot -padmin -h127.0.0.1 -P3306 !DB! < "%%f"
    if !ERRORLEVEL!==0 (
        move "%%f" "%APPLIED_DIR%\" >nul
        set /a applied+=1
    ) else (
        echo        ERROR: Failed to apply %%~nxf
    )
)

if !applied! GTR 0 (
    echo        Successfully applied !applied! of !count! SQL updates.
) else (
    echo        WARNING: No SQL updates applied successfully.
)
endlocal
