@echo off
setlocal enabledelayedexpansion

:: MySQL Optimize — rebuilds InnoDB tables with >10MB file size and reports
:: actual disk savings by comparing .ibd file sizes before/after.
:: Run after large imports, bulk deletes, or data audits.

:: Resolve VoxCore root
set "ROOT=%~dp0.."
for %%i in ("%ROOT%") do set "ROOT=%%~fi"

set "MYSQL=%ROOT%\out\build\x64-RelWithDebInfo\bin\RelWithDebInfo\UniServerZ\core\mysql\bin\mysql.exe"
set "USER=root"
set "PASS=admin"
set "MIN_SIZE_MB=10"
set "TMPFILE=%~dp0_optimize_tmp.txt"

echo.
echo ============================================
echo   MySQL Table Optimizer (InnoDB)
echo ============================================
echo   Min table size: %MIN_SIZE_MB% MB
echo.

:: Get data directory path
for /f "usebackq tokens=2" %%d in (`"%MYSQL%" -u %USER% -p%PASS% --batch --skip-column-names -e "SELECT @@datadir;" 2^>nul`) do set "DATADIR=%%d"
if not defined DATADIR (
    for /f "usebackq tokens=*" %%d in (`"%MYSQL%" -u %USER% -p%PASS% --batch --skip-column-names -e "SELECT @@datadir;" 2^>nul`) do set "DATADIR=%%d"
)

:: Normalize path separators
set "DATADIR=%DATADIR:\=/%"

echo   Data dir: %DATADIR%
echo.

:: Find tables with .ibd files above threshold
"%MYSQL%" -u %USER% -p%PASS% --batch --skip-column-names -e "SELECT t.TABLE_SCHEMA, t.TABLE_NAME, ROUND(s.FILE_SIZE/1024/1024,1) FROM information_schema.TABLES t JOIN information_schema.INNODB_TABLESPACES s ON s.NAME = CONCAT(t.TABLE_SCHEMA, '/', t.TABLE_NAME) WHERE t.TABLE_SCHEMA IN ('world','hotfixes','characters','auth','roleplay') AND t.ENGINE = 'InnoDB' AND s.FILE_SIZE > %MIN_SIZE_MB% * 1024 * 1024 ORDER BY s.FILE_SIZE DESC;" 2>nul > "%TMPFILE%"

set "COUNT=0"
for /f "usebackq tokens=*" %%a in ("%TMPFILE%") do set /a COUNT+=1

if %COUNT%==0 (
    echo   No tables above %MIN_SIZE_MB% MB found.
    echo.
    goto :done
)

echo   Found %COUNT% table(s) above %MIN_SIZE_MB% MB:
echo   ------------------------------------------
for /f "usebackq tokens=1,2,3" %%a in ("%TMPFILE%") do (
    echo     %%a.%%b    %%c MB
)
echo.
echo   Optimizing (ALTER TABLE ... FORCE) ...
echo   ------------------------------------------
echo.

set "TOTAL_SAVED=0"
set "N=0"
for /f "usebackq tokens=1,2,3" %%a in ("%TMPFILE%") do (
    set /a N+=1
    set "SCHEMA=%%a"
    set "TABLE=%%b"
    set "BEFORE=%%c"

    echo   [!N!/%COUNT%] !SCHEMA!.!TABLE! ^(!BEFORE! MB^)

    :: Run OPTIMIZE (InnoDB does ALTER TABLE ... FORCE internally)
    "%MYSQL%" -u %USER% -p%PASS% -e "OPTIMIZE TABLE !SCHEMA!.!TABLE!;" 2>nul >nul

    :: Get new file size
    for /f "usebackq tokens=*" %%s in (`"%MYSQL%" -u %USER% -p%PASS% --batch --skip-column-names -e "SELECT ROUND(FILE_SIZE/1024/1024,1) FROM information_schema.INNODB_TABLESPACES WHERE NAME = '!SCHEMA!/!TABLE!';" 2^>nul`) do set "AFTER=%%s"

    echo            Before: !BEFORE! MB  -^>  After: !AFTER! MB
    echo.
)

echo   ============================================
echo   Done! %COUNT% table(s) processed.
echo   ============================================
echo.

:done
if exist "%TMPFILE%" del "%TMPFILE%"
endlocal
pause
