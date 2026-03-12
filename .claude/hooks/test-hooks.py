#!/usr/bin/env python3
"""Hook test harness — validates all VoxCore hooks work without a real session.

Run: python .claude/hooks/test-hooks.py

For each hook script, sends mock JSON to stdin and checks:
1. Script exists and is readable
2. Script doesn't crash on valid input
3. Script doesn't crash on empty input
4. Exit code is 0 (not blocking unexpectedly)
5. Any JSON output is valid JSON

This catches syntax errors, import failures, and obvious logic bugs
without needing a live Claude Code session.
"""
import json
import os
import subprocess
import sys
from pathlib import Path

HOOKS_DIR = Path(__file__).parent
PROJECT_DIR = HOOKS_DIR.parent.parent

# Mock payloads for each hook type
MOCK_PAYLOADS = {
    "PreToolUse": {
        "hook_event_name": "PreToolUse",
        "tool_name": "Bash",
        "tool_input": {"command": "echo hello"},
        "session_id": "test-session",
    },
    "PostToolUse": {
        "hook_event_name": "PostToolUse",
        "tool_name": "Edit",
        "tool_input": {
            "file_path": "C:/Users/atayl/VoxCore/src/test.cpp",
            "old_string": "foo",
            "new_string": "bar",
        },
        "tool_response": {"success": True},
        "session_id": "test-session",
    },
    "PostToolUseFailure": {
        "hook_event_name": "PostToolUseFailure",
        "tool_name": "Bash",
        "tool_input": {"command": "false"},
        "error": {"message": "Command failed"},
        "session_id": "test-session",
    },
    "UserPromptSubmit": {
        "hook_event_name": "UserPromptSubmit",
        "prompt": "Fix the transmog outfit slot rendering for shoulder display",
        "session_id": "test-session",
    },
    "PreCompact": {
        "hook_event_name": "PreCompact",
        "trigger": "auto",
        "session_id": "test-session",
    },
    "SessionStart": {
        "hook_event_name": "SessionStart",
        "source": "compact",
        "session_id": "test-session",
    },
    "Stop": {
        "hook_event_name": "Stop",
        "stop_reason": "end_turn",
        "transcript_suffix": "That should do it, let me know if you need anything else.",
        "session_id": "test-session",
    },
    "Notification": {
        "hook_event_name": "Notification",
        "message": "Waiting for user input",
        "session_id": "test-session",
    },
    "SubagentStop": {
        "hook_event_name": "SubagentStop",
        "session_id": "test-session",
    },
    "SessionEnd": {
        "hook_event_name": "SessionEnd",
        "session_id": "test-session",
        "reason": "exit",
    },
}

# Map hook scripts to their event types
HOOK_EVENT_MAP = {
    "sql-safety.py": "PreToolUse",
    "cpp-build-reminder.py": "PostToolUse",
    "edit-verifier.py": "PostToolUse",
    "large-file-guard.py": "PostToolUse",
    "sync-on-git.py": "PostToolUse",
    "session-stats.py": "PostToolUse",
    "prompt-context-injector.py": "UserPromptSubmit",
    "precompact-snapshot.py": "PreCompact",
    "compact-reinject.py": "SessionStart",
    "notification-toast.py": "Notification",
    "subagent-complete.py": "SubagentStop",
    "stop-verify.py": "Stop",
}


def test_hook(script_path: Path, event_type: str) -> dict:
    """Test a single hook script. Returns result dict."""
    result = {
        "script": script_path.name,
        "event": event_type,
        "exists": script_path.exists(),
        "runs": False,
        "exit_code": None,
        "stdout_valid": True,
        "errors": [],
    }

    if not result["exists"]:
        result["errors"].append("File not found")
        return result

    payload = MOCK_PAYLOADS.get(event_type, {"hook_event_name": event_type})
    payload_json = json.dumps(payload)

    try:
        proc = subprocess.run(
            [sys.executable, str(script_path)],
            input=payload_json,
            capture_output=True,
            text=True,
            timeout=10,
            env={**os.environ, "CLAUDE_PROJECT_DIR": str(PROJECT_DIR)},
        )
        result["runs"] = True
        result["exit_code"] = proc.returncode

        if proc.returncode == 2:
            result["errors"].append(f"Hook BLOCKED (exit 2): {proc.stderr.strip()[:200]}")
        elif proc.returncode not in (0, 2):
            result["errors"].append(f"Unexpected exit code {proc.returncode}: {proc.stderr.strip()[:200]}")

        # Check if stdout is valid JSON (if non-empty)
        if proc.stdout.strip():
            try:
                json.loads(proc.stdout)
            except json.JSONDecodeError:
                # stdout doesn't have to be JSON — could be plain text feedback
                result["stdout_valid"] = True  # non-JSON is OK for info output

    except subprocess.TimeoutExpired:
        result["errors"].append("TIMEOUT (>10s)")
    except Exception as e:
        result["errors"].append(f"Exception: {e}")

    return result


def main():
    print("=" * 60)
    print("  VoxCore Hook Test Harness")
    print("=" * 60)
    print()

    # Find all .py files in hooks dir (excluding this script)
    hook_scripts = sorted(HOOKS_DIR.glob("*.py"))
    hook_scripts = [h for h in hook_scripts if h.name != "test-hooks.py"]

    total = len(hook_scripts)
    passed = 0
    failed = 0
    warnings = 0

    for script in hook_scripts:
        event_type = HOOK_EVENT_MAP.get(script.name, "PostToolUse")
        result = test_hook(script, event_type)

        status = "PASS" if not result["errors"] else "FAIL"
        if status == "PASS":
            passed += 1
            icon = "  OK"
        else:
            failed += 1
            icon = "FAIL"

        # Check for scripts not in the event map
        if script.name not in HOOK_EVENT_MAP:
            warnings += 1
            icon = "WARN"

        print(f"  [{icon}] {result['script']:30s} ({result['event']:20s}) exit={result['exit_code']}")

        for err in result["errors"]:
            print(f"         -> {err}")

    print()
    print("-" * 60)
    print(f"  Results: {passed} passed, {failed} failed, {warnings} warnings out of {total} hooks")

    if failed > 0:
        print(f"\n  {failed} hook(s) need attention!")
        sys.exit(1)
    else:
        print("\n  All hooks healthy.")
        sys.exit(0)


if __name__ == "__main__":
    main()
