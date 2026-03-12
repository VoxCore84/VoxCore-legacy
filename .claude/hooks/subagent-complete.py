#!/usr/bin/env python3
"""SubagentStop hook: toast notification + duration logging when subagents finish.

Uses BurntToast for a subtle, short-lived toast. Falls back silently.
Also logs completion to session-stats.jsonl for analytics.
"""
import json
import os
import sys
import subprocess
from datetime import datetime, timezone

STATS_FILE = os.path.expanduser("~/.claude/session-stats.jsonl")


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    # Log completion to stats
    entry = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "event": "SubagentStop",
        "session": data.get("session_id", ""),
    }

    try:
        with open(STATS_FILE, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry) + "\n")
    except Exception:
        pass

    # Toast notification — subtle and short-lived
    burnttoast = (
        "try { New-BurntToastNotification "
        "-Text 'Subagent Complete', 'Background agent finished' "
        "-ExpirationTime ([datetime]::Now.AddSeconds(6)) "
        "-Silent "
        "} catch { }"
    )

    try:
        subprocess.Popen(
            ["powershell.exe", "-NoProfile", "-Command", burnttoast],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            creationflags=0x00000008,  # DETACHED_PROCESS
        )
    except Exception:
        pass

    sys.exit(0)  # Never block subagent completion


if __name__ == "__main__":
    main()
