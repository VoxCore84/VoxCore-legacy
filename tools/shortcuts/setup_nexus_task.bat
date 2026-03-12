@echo off
echo Setting up VoxCore Nexus Report Nightly Scheduled Task...

schtasks /create /tn "VoxCore Nexus Report" /tr "C:\Python314\python.exe C:\Users\atayl\VoxCore\tools\log_tools\generate_nexus_report.py" /sc daily /st 23:59 /rl highest /f

echo.
echo Scheduled task created! The Nexus Report will now generate automatically at 11:59PM every night.
pause
