"""PostToolUse hook: warn when a Read consumed a very large file.

Fires after Read tool completes. If the file was over a threshold,
injects a warning so Claude knows to use offset/limit next time.
This prevents token waste from reading massive files in full.
"""

import json
import os
import sys

# Warn if file is larger than this many lines
WARN_THRESHOLD_LINES = 3000

# Known large files that are expected (suppress warnings for these)
KNOWN_LARGE = {
    "CLAUDE.md",
    "worldserver.conf.dist",
    "worldserver.conf",
}


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)

    if data.get("tool_name") != "Read":
        sys.exit(0)

    file_path = data.get("tool_input", {}).get("file_path", "")
    if not file_path:
        sys.exit(0)

    # Skip known-large files
    basename = os.path.basename(file_path)
    if basename in KNOWN_LARGE:
        sys.exit(0)

    # Skip if offset/limit was already used (user was being smart)
    if data.get("tool_input", {}).get("offset") or data.get("tool_input", {}).get("limit"):
        sys.exit(0)

    # Check actual file size
    try:
        with open(file_path, "r", encoding="utf-8", errors="replace") as f:
            line_count = sum(1 for _ in f)
    except (FileNotFoundError, PermissionError, OSError):
        sys.exit(0)

    if line_count > WARN_THRESHOLD_LINES:
        print(
            f"[hook] Large file read: {basename} has {line_count} lines. "
            f"Consider using offset/limit parameters to read specific sections "
            f"and save context tokens.",
            file=sys.stderr,
        )

    sys.exit(0)


if __name__ == "__main__":
    main()
