#!/usr/bin/env python3
"""Hook test harness — validates all VoxCore hooks work without a real session.

Run: python .claude/hooks/test-hooks.py
     python .claude/hooks/test-hooks.py --scenarios   (also run scenario regression tests)
     python .claude/hooks/test-hooks.py --verbose      (show stdout/stderr for each test)

Phase 1: Health checks — each hook gets its event-appropriate payload, must not crash.
Phase 2: Scenario tests — targeted regression tests for known false-positive patterns.

This catches syntax errors, import failures, and logic bugs that caused real session
disruptions (session 197: release-gate cascade, sql-safety overbroad, edit-verifier
Unicode false positives).
"""
import json
import os
import subprocess
import sys
from pathlib import Path

HOOKS_DIR = Path(__file__).parent
PROJECT_DIR = HOOKS_DIR.parent.parent

# ── Mock payloads for each hook event type ────────────────────────────

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
        "transcript_suffix": "That should do it.",
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

# ── Map every hook to its event type ──────────────────────────────────

HOOK_EVENT_MAP = {
    # PreToolUse
    "sql-safety.py": "PreToolUse",
    "release-gate-enforce.py": "PreToolUse",
    "sensitive-file-guard.py": "PreToolUse",
    # PostToolUse
    "cpp-build-reminder.py": "PostToolUse",
    "edit-verifier.py": "PostToolUse",
    "large-file-guard.py": "PostToolUse",
    "sync-on-git.py": "PostToolUse",
    "session-stats.py": "PostToolUse",
    "release-gate-revalidate.py": "PostToolUse",
    # PostToolUseFailure
    "docx-auto-extract.py": "PostToolUseFailure",
    # UserPromptSubmit
    "prompt-context-injector.py": "UserPromptSubmit",
    # PreCompact
    "precompact-snapshot.py": "PreCompact",
    # SessionStart
    "compact-reinject.py": "SessionStart",
    # Notification
    "notification-toast.py": "Notification",
    # SubagentStop
    "subagent-complete.py": "SubagentStop",
    # Stop
    "stop-verify.py": "Stop",
}

# ── Scenario regression tests ─────────────────────────────────────────
# Each scenario: (hook_script, payload, expect_allow, description)
# expect_allow=True means exit 0 (no blocking). False means exit 2 (should block).

SCENARIOS = [
    # ── release-gate-enforce.py regressions (session 197) ──

    # Archiving a backup dir should NOT be blocked
    ("release-gate-enforce.py", {
        "hook_event_name": "PreToolUse",
        "tool_name": "Bash",
        "tool_input": {"command": '7z a -t7z -mx=9 "/c/Users/atayl/Desktop/backup.7z" "/c/Users/atayl/Desktop/Excluded/Case_Reference - backup/"'},
    }, True, "7z backup to Desktop should NOT trigger release gate"),

    # Archiving publishable/ SHOULD be blocked (when gate != PASS)
    ("release-gate-enforce.py", {
        "hook_event_name": "PreToolUse",
        "tool_name": "Bash",
        "tool_input": {"command": 'zip -r tools/publishable/CreatureCodex.zip tools/publishable/CreatureCodex/'},
    }, False, "zip of publishable/ SHOULD trigger release gate"),

    # Normal git push (no tags) should NOT be blocked
    ("release-gate-enforce.py", {
        "hook_event_name": "PreToolUse",
        "tool_name": "Bash",
        "tool_input": {"command": "git push origin HEAD"},
    }, True, "git push (no tags) should NOT trigger release gate"),

    # git push --tags SHOULD be blocked
    ("release-gate-enforce.py", {
        "hook_event_name": "PreToolUse",
        "tool_name": "Bash",
        "tool_input": {"command": "git push origin HEAD --tags"},
    }, False, "git push --tags SHOULD trigger release gate"),

    # gh release create SHOULD be blocked
    ("release-gate-enforce.py", {
        "hook_event_name": "PreToolUse",
        "tool_name": "Bash",
        "tool_input": {"command": 'gh release create v1.0.0 --title "Release"'},
    }, False, "gh release create SHOULD trigger release gate"),

    # tar for a non-publishable dir should NOT be blocked
    ("release-gate-enforce.py", {
        "hook_event_name": "PreToolUse",
        "tool_name": "Bash",
        "tool_input": {"command": "tar czf /tmp/backup.tar.gz /c/Users/atayl/Desktop/stuff/"},
    }, True, "tar of Desktop dir should NOT trigger release gate"),

    # Non-Bash tool should always pass
    ("release-gate-enforce.py", {
        "hook_event_name": "PreToolUse",
        "tool_name": "Read",
        "tool_input": {"file_path": "C:/Users/atayl/VoxCore/README.md"},
    }, True, "Read tool should never trigger release gate"),

    # ── sql-safety.py regressions (session 197) ──

    # Command that just mentions .sql filename should NOT trigger
    ("sql-safety.py", {
        "hook_event_name": "PreToolUse",
        "tool_name": "Bash",
        "tool_input": {"command": "ls sql/updates/world/master/2026_03_10_00_world.sql"},
    }, True, "ls of .sql file should NOT trigger sql-safety"),

    # Command that mentions .sql in git diff should NOT trigger
    ("sql-safety.py", {
        "hook_event_name": "PreToolUse",
        "tool_name": "Bash",
        "tool_input": {"command": "git diff --stat -- sql/updates/"},
    }, True, "git diff of sql dir should NOT trigger sql-safety"),

    # Actual mysql command should be checked (but allowed for safe ops)
    ("sql-safety.py", {
        "hook_event_name": "PreToolUse",
        "tool_name": "Bash",
        "tool_input": {"command": 'mysql -u root -padmin world -e "SELECT COUNT(*) FROM creature_template"'},
    }, True, "mysql SELECT should be allowed by sql-safety"),

    # ── edit-verifier.py regressions (sessions 196-198) ──

    # Edit to .md file — verifier should use advisory-only mode (warn, not block)
    # Uses CLAUDE.md which always exists. The "new_string" won't be found in the
    # file, but for .md files this should produce "warn" not "block".
    ("edit-verifier.py", {
        "hook_event_name": "PostToolUse",
        "tool_name": "Edit",
        "tool_input": {
            "file_path": "C:/Users/atayl/VoxCore/CLAUDE.md",
            "old_string": "foo",
            "new_string": "bar \u2014 baz \u2018quoted\u2019",
        },
        "tool_response": {"success": True},
    }, True, ".md edit with em dashes should be advisory-only (not block)"),

    # Edit to .json file — should also be advisory-only
    ("edit-verifier.py", {
        "hook_event_name": "PostToolUse",
        "tool_name": "Edit",
        "tool_input": {
            "file_path": "C:/Users/atayl/VoxCore/.claude/settings.local.json",
            "old_string": "foo",
            "new_string": "bar_changed_value",
        },
        "tool_response": {"success": True},
    }, True, ".json edit should be advisory-only (not block)"),

    # Non-existent .cpp file — verifier correctly blocks (file can't be read)
    ("edit-verifier.py", {
        "hook_event_name": "PostToolUse",
        "tool_name": "Edit",
        "tool_input": {
            "file_path": "C:/Users/atayl/VoxCore/src/nonexistent.cpp",
            "old_string": "int x = 1;",
            "new_string": "int x = 2;",
        },
        "tool_response": {"success": True},
    }, False, ".cpp edit on non-existent file SHOULD block (can't verify)"),

    # ── sensitive-file-guard.py ──

    # Editing a file inside VoxCore should be allowed
    ("sensitive-file-guard.py", {
        "hook_event_name": "PreToolUse",
        "tool_name": "Edit",
        "tool_input": {
            "file_path": "C:/Users/atayl/VoxCore/src/server/game/RolePlay/RolePlay.cpp",
            "old_string": "foo",
            "new_string": "bar",
        },
    }, True, "Edit inside VoxCore should be allowed"),

    # Writing case reference files into VoxCore should be blocked
    ("sensitive-file-guard.py", {
        "hook_event_name": "PreToolUse",
        "tool_name": "Write",
        "tool_input": {
            "file_path": "C:/Users/atayl/VoxCore/case_evidence.pdf",
            "content": "sensitive legal data",
        },
    }, True, "sensitive-file-guard only blocks case paths, not content"),

    # ── release-gate-revalidate.py regressions (session 197) ──

    # Editing a Custom/ script should NOT invalidate the gate
    ("release-gate-revalidate.py", {
        "hook_event_name": "PostToolUse",
        "tool_name": "Edit",
        "tool_input": {
            "file_path": "C:/Users/atayl/VoxCore/src/server/scripts/Custom/free_share_scripts.cpp",
            "old_string": "foo",
            "new_string": "bar",
        },
        "tool_response": {"success": True},
    }, True, "Custom/ script edit should NOT invalidate release gate"),

    # Editing publishable/ SHOULD invalidate the gate
    ("release-gate-revalidate.py", {
        "hook_event_name": "PostToolUse",
        "tool_name": "Edit",
        "tool_input": {
            "file_path": "C:/Users/atayl/VoxCore/tools/publishable/VoxGM/VoxGM.lua",
            "old_string": "foo",
            "new_string": "bar",
        },
        "tool_response": {"success": True},
    }, True, "publishable/ edit sets gate STALE (still exits 0, writes file)"),
]


def run_hook(script_path: Path, payload: dict, verbose: bool = False) -> tuple:
    """Run a hook with a payload. Returns (exit_code, stdout, stderr)."""
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
        if verbose:
            if proc.stdout.strip():
                print(f"         stdout: {proc.stdout.strip()[:200]}")
            if proc.stderr.strip():
                print(f"         stderr: {proc.stderr.strip()[:200]}")
        return proc.returncode, proc.stdout, proc.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "TIMEOUT"
    except Exception as e:
        return -1, "", str(e)


def run_health_checks(verbose: bool = False) -> tuple:
    """Phase 1: Basic health checks for all hooks."""
    print("=" * 64)
    print("  Phase 1: Hook Health Checks")
    print("=" * 64)
    print()

    hook_scripts = sorted(HOOKS_DIR.glob("*.py"))
    hook_scripts = [h for h in hook_scripts if h.name != "test-hooks.py"]

    total = len(hook_scripts)
    passed = 0
    failed = 0
    unmapped = 0

    for script in hook_scripts:
        event_type = HOOK_EVENT_MAP.get(script.name)
        if event_type is None:
            unmapped += 1
            print(f"  [WARN] {script.name:30s} (unmapped — not in HOOK_EVENT_MAP)")
            continue

        payload = MOCK_PAYLOADS.get(event_type, {"hook_event_name": event_type})
        exit_code, stdout, stderr = run_hook(script, payload, verbose)

        if exit_code == 0:
            passed += 1
            print(f"  [  OK] {script.name:30s} ({event_type:20s}) exit={exit_code}")
        elif exit_code == 2:
            # Some hooks legitimately block on mock data (e.g., release gate when STALE)
            passed += 1
            print(f"  [GATE] {script.name:30s} ({event_type:20s}) exit={exit_code} (expected block)")
        else:
            failed += 1
            print(f"  [FAIL] {script.name:30s} ({event_type:20s}) exit={exit_code}")
            if stderr.strip():
                print(f"         -> {stderr.strip()[:200]}")

    print()
    print(f"  Health: {passed} ok, {failed} failed, {unmapped} unmapped / {total} hooks")
    return passed, failed, unmapped


def run_scenario_tests(verbose: bool = False) -> tuple:
    """Phase 2: Scenario regression tests for known false-positive patterns."""
    print()
    print("=" * 64)
    print("  Phase 2: Scenario Regression Tests")
    print("=" * 64)
    print()

    passed = 0
    failed = 0

    for hook_name, payload, expect_allow, description in SCENARIOS:
        script_path = HOOKS_DIR / hook_name
        if not script_path.exists():
            failed += 1
            print(f"  [MISS] {description}")
            print(f"         -> {hook_name} not found")
            continue

        exit_code, stdout, stderr = run_hook(script_path, payload, verbose)

        # Check if stdout contains a "block" decision (JSON output hooks)
        blocked_by_json = False
        if stdout.strip():
            try:
                result = json.loads(stdout)
                if result.get("decision") == "block":
                    blocked_by_json = True
            except json.JSONDecodeError:
                pass

        actually_allowed = (exit_code == 0) and not blocked_by_json

        if actually_allowed == expect_allow:
            passed += 1
            print(f"  [  OK] {description}")
        else:
            failed += 1
            action = "allowed" if actually_allowed else "blocked"
            expected = "allow" if expect_allow else "block"
            print(f"  [FAIL] {description}")
            print(f"         -> Expected {expected}, got {action} (exit={exit_code})")
            if stderr.strip():
                print(f"         -> stderr: {stderr.strip()[:200]}")
            if stdout.strip():
                print(f"         -> stdout: {stdout.strip()[:200]}")

    print()
    print(f"  Scenarios: {passed} passed, {failed} failed / {len(SCENARIOS)} tests")
    return passed, failed


def main():
    verbose = "--verbose" in sys.argv or "-v" in sys.argv
    run_scenarios = "--scenarios" in sys.argv or "-s" in sys.argv or "--all" in sys.argv

    h_passed, h_failed, h_unmapped = run_health_checks(verbose)

    s_passed = 0
    s_failed = 0
    if run_scenarios:
        s_passed, s_failed = run_scenario_tests(verbose)

    total_failed = h_failed + s_failed
    print()
    print("=" * 64)
    if run_scenarios:
        print(f"  TOTAL: Health {h_passed}ok/{h_failed}fail  |  Scenarios {s_passed}ok/{s_failed}fail")
    else:
        print(f"  TOTAL: Health {h_passed}ok/{h_failed}fail  (run with --scenarios for regression tests)")

    if total_failed > 0:
        print(f"\n  {total_failed} test(s) FAILED!")
        sys.exit(1)
    else:
        print("\n  All tests passed.")
        sys.exit(0)


if __name__ == "__main__":
    main()
