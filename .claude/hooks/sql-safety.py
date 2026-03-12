"""PreToolUse hook: block dangerous SQL operations unless explicitly approved.

Catches DROP TABLE, TRUNCATE, DELETE without WHERE, ALTER TABLE DROP COLUMN
in Bash commands that pipe to mysql or use mysql -e.
"""

import json
import re
import sys


DANGEROUS_PATTERNS = [
    (r'\bDROP\s+TABLE\b', "DROP TABLE"),
    (r'\bDROP\s+DATABASE\b', "DROP DATABASE"),
    (r'\bTRUNCATE\b', "TRUNCATE"),
    (r'\bDELETE\s+FROM\s+\S+\s*;', "DELETE without WHERE clause"),
    (r'\bDELETE\s+FROM\s+\S+\s*$', "DELETE without WHERE clause"),
    (r'\bALTER\s+TABLE\s+\S+\s+DROP\s+COLUMN\b', "ALTER TABLE DROP COLUMN"),
]

# Allow these specific safe patterns even if they match above
SAFE_OVERRIDES = [
    r'DROP\s+TABLE\s+IF\s+EXISTS.*CREATE\s+TABLE',  # Drop-and-recreate pattern
    r'DROP\s+TEMPORARY\s+TABLE',  # Temp tables are safe
]


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)

    if data.get("tool_name") != "Bash":
        sys.exit(0)

    cmd = data.get("tool_input", {}).get("command", "")

    # Only check commands that touch mysql
    if "mysql" not in cmd.lower() and ".sql" not in cmd.lower():
        sys.exit(0)

    # Check for safe override patterns first
    cmd_upper = cmd.upper()
    for safe_pattern in SAFE_OVERRIDES:
        if re.search(safe_pattern, cmd_upper, re.IGNORECASE | re.DOTALL):
            sys.exit(0)

    # Check for dangerous patterns
    for pattern, label in DANGEROUS_PATTERNS:
        if re.search(pattern, cmd, re.IGNORECASE):
            result = {
                "decision": "block",
                "reason": (
                    f"SQL SAFETY: Blocked dangerous operation: {label}\n"
                    f"Command: {cmd[:200]}\n\n"
                    f"If this is intentional, ask the user to confirm before proceeding."
                ),
            }
            json.dump(result, sys.stdout)
            sys.exit(0)

    # Safe — no output needed
    sys.exit(0)


if __name__ == "__main__":
    main()
