"""
Hook: sensitive-file-guard
Trigger: PreToolUse (Edit, Write)
Purpose: Prevent accidentally writing sensitive case/personal files into the git-tracked VoxCore repo.
"""
import json
import sys
import os

def main():
    event = json.loads(sys.stdin.read())

    tool_name = event.get("tool_name", "")
    if tool_name not in ("Edit", "Write"):
        print(json.dumps({"decision": "approve"}))
        return

    tool_input = event.get("tool_input", {})
    file_path = tool_input.get("file_path", "")

    # Normalize path separators
    normalized = file_path.replace("\\", "/").lower()

    # Patterns that should NEVER be written inside VoxCore repo
    sensitive_patterns = [
        "case_reference/",
        "desktop/excluded/",
        "personal_data_matrix",
        "career_evidence",
        "deep_data_matrix",
        "claude_browser_final_",
    ]

    # Only block if the file is INSIDE the VoxCore repo tree
    voxcore_root = os.path.expanduser("~/VoxCore").replace("\\", "/").lower()

    if normalized.startswith(voxcore_root):
        for pattern in sensitive_patterns:
            if pattern in normalized:
                print(json.dumps({
                    "decision": "block",
                    "reason": f"Blocked: attempting to write sensitive case/personal file inside VoxCore repo. "
                              f"Pattern '{pattern}' matched in path '{file_path}'. "
                              f"These files should stay on Desktop, not in the git-tracked repo."
                }))
                return

    print(json.dumps({"decision": "approve"}))

if __name__ == "__main__":
    main()
