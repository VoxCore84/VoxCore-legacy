#!/usr/bin/env python3
"""Stop hook: remind Claude about /wrap-up if session looks like it's ending.

This is a lightweight heuristic check, not a blocking gate.
Outputs reminder text that Claude sees as hook feedback.
"""
import json
import sys

def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    # Extract the last assistant message or stop reason
    stop_reason = data.get("stop_reason", "")
    transcript = str(data.get("transcript_suffix", ""))

    # Check if we mentioned wrapping up or completing work
    wrap_indicators = [
        "that should do it", "all done", "everything is", "completed",
        "let me know if", "anything else", "good to go",
    ]

    should_remind = any(ind in transcript.lower() for ind in wrap_indicators)

    if should_remind:
        # Output reminder — Claude sees this as hook feedback
        print("Reminder: Consider running /wrap-up if the session is ending. "
              "Check if there are uncommitted changes or memory updates needed.")

    sys.exit(0)  # Never block — just advise

if __name__ == "__main__":
    main()
