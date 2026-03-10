@echo off
setlocal

:: Resolve the VoxCore root dynamically (up one level from shortcuts)
set "VOXCORE_ROOT=%~dp0.."
pushd "%VOXCORE_ROOT%"
set "VOXCORE_ROOT=%CD%"
popd

echo ==============================================
echo  TRIAD COMMAND CENTER
echo ==============================================
echo Starting local web operator surface...
echo Press CTRL+C to stop the Command Center.
echo.

python "%VOXCORE_ROOT%\tools\command_center\app.py"

pause
