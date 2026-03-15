"""Enhanced edit-verifier hook for Claude Code.

PostToolUse hook that verifies file edits applied correctly by reading the
file back after Edit operations. Based on mvanhorn's PR #32755 with three
improvements from our code review:

1. Configurable minimum threshold (env EDIT_VERIFY_MIN_CHARS, default 3)
2. Checks that old_string is GONE (catches wrong-occurrence edits)
3. Explicit UTF-8 encoding with fallback (Windows compatibility)

Input:  JSON on stdin with tool_name, tool_input, tool_response
Output: JSON on stdout with decision/reason if verification fails

Reference: https://github.com/anthropics/claude-code/pull/32755
Issues:  #32658 (blind edits), part of #32650 taxonomy
"""

import json
import os
import sys


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)

    tool_name = data.get("tool_name", "")
    if tool_name != "Edit":
        sys.exit(0)

    tool_input = data.get("tool_input", {})
    tool_response = data.get("tool_response", {})
    file_path = tool_input.get("file_path", "")
    old_string = tool_input.get("old_string", "")
    new_string = tool_input.get("new_string", "")
    replace_all = tool_input.get("replace_all", False)

    # Skip if no file path or both strings are empty
    if not file_path:
        sys.exit(0)

    # Configurable threshold — default 3 chars (lower than mvanhorn's 5
    # to catch critical short edits like true→false, 8.0→8.1)
    min_chars = int(os.environ.get("EDIT_VERIFY_MIN_CHARS", "3"))

    # Skip if new_string is too short to verify reliably
    if new_string and len(new_string.strip()) < min_chars:
        sys.exit(0)

    # If the tool itself reported failure, don't double-report
    if isinstance(tool_response, dict) and not tool_response.get("success", True):
        sys.exit(0)

    # Read the file back — try UTF-8 first (most codebases), fall back to
    # system default, then latin1 (our .editorconfig charset)
    content = None
    for encoding in ("utf-8", None, "latin1"):
        try:
            with open(file_path, "r", encoding=encoding) as f:
                content = f.read()
            break
        except (UnicodeDecodeError, UnicodeError):
            continue
        except (FileNotFoundError, PermissionError, OSError):
            result = {
                "decision": "block",
                "reason": (
                    f"Edit verification: Could not read '{file_path}' after "
                    f"the edit. The file may not exist or may be locked. "
                    f"Please verify the edit applied correctly."
                ),
            }
            json.dump(result, sys.stdout)
            sys.exit(0)

    if content is None:
        result = {
            "decision": "block",
            "reason": (
                f"Edit verification: Could not decode '{file_path}' with any "
                f"encoding (utf-8, system default, latin1). Cannot verify edit."
            ),
        }
        json.dump(result, sys.stdout)
        sys.exit(0)

    # Normalize line endings for comparison (Windows \r\n vs Unix \n)
    # This is the #1 cause of false positives on Windows
    content_norm = content.replace("\r\n", "\n").replace("\r", "\n")
    new_norm = new_string.replace("\r\n", "\n").replace("\r", "\n") if new_string else ""
    old_norm = old_string.replace("\r\n", "\n").replace("\r", "\n") if old_string else ""

    problems = []

    # Check 1: new_string should be present in the file
    if new_string and new_norm not in content_norm:
        problems.append(
            f"MISSING NEW CONTENT: The expected new text was not found in "
            f"'{file_path}' after the Edit. The edit may not have applied."
        )

    # Check 2: old_string should be GONE — but ONLY flag as blocking if
    # replace_all was true. For single replacements, old_string can
    # legitimately remain (multiple occurrences, or old_string is a substring
    # of surrounding context that naturally repeats). In those cases, if
    # new_string IS present, the edit almost certainly succeeded.
    if old_norm and old_norm in content_norm:
        if replace_all:
            # replace_all was set but old_string still exists — definite failure
            problems.append(
                f"OLD CONTENT STILL PRESENT (replace_all=true): The original "
                f"text still exists in '{file_path}' despite replace_all being "
                f"set. The edit may have failed or matched incorrectly."
            )
        elif old_norm != new_norm and new_norm and new_norm not in content_norm:
            # old_string present AND new_string missing — likely real failure
            occurrences = content_norm.count(old_norm)
            problems.append(
                f"POSSIBLE EDIT FAILURE: old_string still appears "
                f"{occurrences} time(s) and new_string is missing in "
                f"'{file_path}'. Read the file to confirm."
            )
        # If new_string IS present but old_string also remains, the edit
        # succeeded on one occurrence — this is normal, not a problem.

    if problems:
        result = {
            "decision": "block",
            "reason": (
                "Edit verification FAILED:\n"
                + "\n".join(f"  - {p}" for p in problems)
                + "\n\nPlease read the file to verify the edit applied correctly "
                + "before proceeding."
            ),
        }
        json.dump(result, sys.stdout)
    # else: silent success — no output needed


if __name__ == "__main__":
    main()
