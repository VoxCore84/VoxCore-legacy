#!/usr/bin/env python3
"""
Release Gate Revalidation Hook — PostToolUse

After edits to files in tools/publishable/, invalidates the current
release gate status and reminds Claude to re-run /pre-ship.

Hook type: PostToolUse (Write, Edit)
Exit code: 0 always (advisory, never blocks)
"""

import json
import sys
from pathlib import Path

STATUS_FILE = Path(__file__).resolve().parent.parent / "release-gate-status.json"

WATCHED_PATHS = [
    "tools/publishable/",
]


def main():
    event = json.loads(sys.stdin.read())

    tool_name = event.get("tool_name", "")
    tool_input = event.get("tool_input", {})

    if tool_name not in ("Write", "Edit"):
        return

    file_path = tool_input.get("file_path", "")
    if not file_path:
        return

    # Normalize path separators
    normalized = file_path.replace("\\", "/")

    # Check if the edited file is in a watched path
    is_watched = any(watch in normalized for watch in WATCHED_PATHS)
    if not is_watched:
        return

    # Invalidate the current gate status
    if STATUS_FILE.exists():
        try:
            data = json.loads(STATUS_FILE.read_text(encoding="utf-8"))
            if data.get("status") == "PASS":
                data["status"] = "STALE"
                data["stale_reason"] = f"File edited after gate pass: {file_path}"
                STATUS_FILE.write_text(
                    json.dumps(data, indent=2, ensure_ascii=False),
                    encoding="utf-8",
                )
        except (json.JSONDecodeError, OSError):
            pass

    # Advisory message
    print(f"Release gate: File in publishable/ was edited. Gate status is now STALE. Re-run /pre-ship before shipping.")


if __name__ == "__main__":
    main()
