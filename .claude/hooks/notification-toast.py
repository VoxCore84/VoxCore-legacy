#!/usr/bin/env python3
"""Windows toast notification via BurntToast when Claude needs attention.

Install: Install-Module BurntToast -Scope CurrentUser
Fallback: raw System.Windows.Forms if BurntToast not available.
"""
import json
import sys
import subprocess

def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    # Build message from hook context
    hook_event = data.get("hook_event_name", "Notification")
    tool_name = data.get("tool_name", "")
    message = "Claude Code needs your attention"

    if "permission" in hook_event.lower() or "permission" in str(data).lower():
        message = f"Permission needed: {tool_name}" if tool_name else "Permission needed"
    elif hook_event == "Stop":
        message = "Claude Code finished working"
    elif "idle" in str(data).lower():
        message = "Claude Code is waiting for input"

    # Try BurntToast first (best UX), fallback to raw Forms
    burnttoast_cmd = (
        f'New-BurntToastNotification -Text "Claude Code", "{message}" '
        f'-AppLogo $null -ExpirationTime ([datetime]::Now.AddSeconds(10))'
    )
    fallback_cmd = (
        f'Add-Type -AssemblyName System.Windows.Forms; '
        f'$n = New-Object System.Windows.Forms.NotifyIcon; '
        f'$n.Icon = [System.Drawing.SystemIcons]::Information; '
        f'$n.Visible = $true; '
        f'$n.ShowBalloonTip(5000, "Claude Code", "{message}", '
        f'[System.Windows.Forms.ToolTipIcon]::Info); '
        f'Start-Sleep -Seconds 6; $n.Dispose()'
    )

    # Try BurntToast, fall back silently
    ps_cmd = f'try {{ {burnttoast_cmd} }} catch {{ {fallback_cmd} }}'

    subprocess.Popen(
        ["powershell.exe", "-NoProfile", "-Command", ps_cmd],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        creationflags=0x00000008  # DETACHED_PROCESS
    )

if __name__ == "__main__":
    main()
