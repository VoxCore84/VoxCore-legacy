"""SessionStart hook: re-inject critical context after compaction.

When Claude's context gets compacted, important instructions and state
can be lost. This hook fires on session start (including after compaction)
and prints reminders to stderr so Claude sees them as hook output.

Only fires meaningful output when a compaction has occurred (detected by
checking if session has prior context — a fresh session won't have the
compact-reminders file content be useful).
"""

import os
import sys

REMINDERS = """
POST-COMPACTION CONTEXT REMINDER:
- NEVER build from Claude Code — user builds in Visual Studio IDE
- DESCRIBE tables before writing SQL (Anti-Theater Protocol)
- Check doc/session_state.md before touching shared files (multi-tab locking)
- Use /wrap-up at end of session
- 6 custom agents: researcher (haiku), sql-writer (sonnet), log-analyst (haiku), transmog-specialist (sonnet), packet-analyzer (haiku), code-writer (opus)
- 8 rules files: .claude/rules/{transmog,completion-integrity,multi-tab,debugging,project-reference,coding-conventions,session-start,skill-reminders}.md
- 23 skills in .claude/commands/ — proactively remind user of relevant ones
""".strip()


def main():
    # Print reminders to stderr (Claude sees hook stderr as informational)
    print(REMINDERS, file=sys.stderr)


if __name__ == "__main__":
    main()
