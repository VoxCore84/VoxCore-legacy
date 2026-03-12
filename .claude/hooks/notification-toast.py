#!/usr/bin/env python3
"""Windows toast notification via BurntToast when Claude needs attention.

BurntToast provides rich toasts with custom titles, sounds, and expiration.
Falls back to System.Windows.Forms if BurntToast is not installed.

Install BurntToast: Install-Module BurntToast -Scope CurrentUser
"""
import json
import sys
import subprocess


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    hook_event = data.get("hook_event_name", "Notification")
    tool_name = data.get("tool_name", "")
    msg_raw = data.get("message", "")

    # Classify the notification and set toast parameters
    if "permission" in hook_event.lower() or "permission" in str(data).lower():
        title = "Permission Needed"
        message = f"{tool_name}" if tool_name else "Action requires approval"
        duration = 30
        sound = True
    elif hook_event == "Stop":
        title = "Task Complete"
        message = "Claude Code finished working"
        duration = 8
        sound = False
    elif hook_event == "PostToolUseFailure":
        title = "Tool Failed"
        message = f"{tool_name} encountered an error" if tool_name else "A tool encountered an error"
        duration = 15
        sound = True
    elif "idle" in str(data).lower() or "waiting" in msg_raw.lower():
        title = "Waiting for Input"
        message = "Claude Code is waiting for your response"
        duration = 20
        sound = True
    else:
        title = "Claude Code"
        message = msg_raw if msg_raw else "Needs your attention"
        duration = 10
        sound = False

    # Escape quotes for PowerShell
    title_ps = title.replace('"', '`"').replace("'", "''")
    message_ps = message.replace('"', '`"').replace("'", "''")

    # BurntToast command with optional sound
    sound_param = "" if sound else " -Silent"
    burnttoast_cmd = (
        f"New-BurntToastNotification "
        f"-Text '{title_ps}', '{message_ps}' "
        f"-ExpirationTime ([datetime]::Now.AddSeconds({duration}))"
        f"{sound_param}"
    )

    # Forms fallback (works without BurntToast)
    icon = "Warning" if sound else "Info"
    fallback_cmd = (
        f"Add-Type -AssemblyName System.Windows.Forms; "
        f"$n = New-Object System.Windows.Forms.NotifyIcon; "
        f"$n.Icon = [System.Drawing.SystemIcons]::{icon}; "
        f"$n.Visible = $true; "
        f"$n.ShowBalloonTip(5000, '{title_ps}', '{message_ps}', "
        f"[System.Windows.Forms.ToolTipIcon]::{icon}); "
        f"Start-Sleep -Seconds 6; $n.Dispose()"
    )

    ps_cmd = f"try {{ {burnttoast_cmd} }} catch {{ {fallback_cmd} }}"

    try:
        subprocess.Popen(
            ["powershell.exe", "-NoProfile", "-Command", ps_cmd],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            creationflags=0x00000008,  # DETACHED_PROCESS
        )
    except Exception:
        pass


if __name__ == "__main__":
    main()
