#!/usr/bin/env python3
"""
Release Gate Enforcement Hook — PreToolUse

Blocks git push, git tag, gh release create, and zip creation
when the release gate has not passed.

Reads .claude/release-gate-status.json for current gate state.
If the file doesn't exist or status != "PASS", blocked actions
are rejected with an explanation.

Hook type: PreToolUse (Bash)
Exit code: 0 = allow, 2 = block with message on stderr
"""

import json
import sys
from pathlib import Path

# Actions that require a passing release gate
GATED_PATTERNS = [
    "git push",
    "git tag",
    "gh release",
    "zip ",
    "7z ",
    "tar ",
    "Compress-Archive",
]

# Actions that are always allowed even without a gate pass
ALWAYS_ALLOWED = [
    "git push origin master",  # regular dev pushes are fine
    "git push origin main",
]

STATUS_FILE = Path(__file__).resolve().parent.parent / "release-gate-status.json"


def read_gate_status():
    """Read the release gate status file. Returns (status, blockers)."""
    if not STATUS_FILE.exists():
        return "UNKNOWN", ["No release gate audit has been run. Use /pre-ship first."]
    try:
        data = json.loads(STATUS_FILE.read_text(encoding="utf-8"))
        return data.get("status", "UNKNOWN"), data.get("blockers", [])
    except (json.JSONDecodeError, OSError):
        return "ERROR", ["Could not read release-gate-status.json"]


def extract_command_line(command: str) -> str:
    """Extract only the first line / actual command, ignoring heredoc bodies.

    Heredoc content (between <<'EOF' and EOF) can contain trigger words
    like 'git push --tags' in commit messages. We must not match those.
    """
    # If there's a heredoc marker, only check the command before <<
    for marker in ("<<'EOF'", '<<"EOF"', "<<EOF", "<<-'EOF'"):
        if marker in command:
            return command[:command.index(marker)]
    # Otherwise check only the first line (multi-line commands via &&)
    return command.split("\n")[0]


def is_release_action(command: str) -> bool:
    """Check if the command is a release-gated action."""
    cmd_line = extract_command_line(command).lower().strip()

    # Always-allowed exceptions
    for allowed in ALWAYS_ALLOWED:
        if cmd_line.startswith(allowed):
            return False

    # Check if this is a gated action
    for pattern in GATED_PATTERNS:
        if pattern in cmd_line:
            # Only gate pushes to tags or release branches
            if pattern == "git push":
                return "--tags" in cmd_line or "refs/tags" in cmd_line
            return True

    return False


def main():
    event = json.loads(sys.stdin.read())

    tool_name = event.get("tool_name", "")
    tool_input = event.get("tool_input", {})

    # Only check Bash commands
    if tool_name != "Bash":
        return

    command = tool_input.get("command", "")
    if not command:
        return

    if not is_release_action(command):
        return

    status, blockers = read_gate_status()

    if status == "PASS":
        return  # Gate passed, allow the action

    # Block the action
    msg = f"RELEASE GATE: {status}\n"
    msg += "This action is blocked because the release gate has not passed.\n"
    if blockers:
        msg += "Open blockers:\n"
        for b in blockers[:5]:
            msg += f"  - {b}\n"
        if len(blockers) > 5:
            msg += f"  ... and {len(blockers) - 5} more\n"
    msg += "\nRun /pre-ship to audit, fix blockers, then retry."

    print(msg, file=sys.stderr)
    sys.exit(2)


if __name__ == "__main__":
    main()
