#!/usr/bin/env python3
"""Async hook: log every tool use to JSONL for session analytics."""
import json
import sys
import os
from datetime import datetime, timezone

LOG_FILE = os.path.expanduser("~/.claude/session-stats.jsonl")

def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    entry = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "event": data.get("hook_event_name", "unknown"),
        "tool": data.get("tool_name", ""),
        "session": data.get("session_id", ""),
    }

    # Extract file path if present (Edit/Write/Read)
    tool_input = data.get("tool_input", {})
    if isinstance(tool_input, dict):
        for key in ("file_path", "path", "pattern"):
            if key in tool_input:
                entry[key] = tool_input[key]
                break

    try:
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry) + "\n")
    except Exception:
        pass  # Never block Claude for logging failures

if __name__ == "__main__":
    main()
