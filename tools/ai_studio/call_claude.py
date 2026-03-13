"""
Claude API Reviewer — Sends artifacts to a fresh Claude instance for cold-read review.

The key value: Claude Code built the artifact, so it has implementation bias.
A separate Claude API call reviews with zero context — pure fresh eyes.

Uses ANTHROPIC_API_KEY from tools/ai_studio/.env.

Usage:
    # As module (from review_cycle.py):
    from call_claude import review(artifact, round_num, prior_feedback, role)

    # Standalone test:
    python call_claude.py --test
    python call_claude.py --file path/to/artifact.md
"""
import os
import sys
import argparse
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent

DEFAULT_MODEL = "claude-sonnet-4-6"


def load_env():
    """Load ANTHROPIC_API_KEY from tools/ai_studio/.env (no dotenv dependency)."""
    for env_path in [SCRIPT_DIR / ".env", PROJECT_ROOT / "config" / "gemini.local.env"]:
        if env_path.exists():
            with open(env_path, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith("#") and "=" in line:
                        k, v = line.split("=", 1)
                        os.environ.setdefault(k.strip(), v.strip().strip('"\''))


def get_client():
    """Initialize Anthropic client."""
    load_env()
    api_key = os.environ.get("ANTHROPIC_API_KEY", "")
    if not api_key:
        print("ERROR: ANTHROPIC_API_KEY not set.")
        print(f"Edit: {SCRIPT_DIR / '.env'}")
        sys.exit(1)

    import anthropic
    return anthropic.Anthropic(api_key=api_key)


SYSTEM_PROMPT = """\
You are a cold-read reviewer in the VoxCore Triad review pipeline.

Your unique value: The implementer (Claude Code) built this artifact and has blind spots \
about their own work. You are reviewing with ZERO implementation context — pure fresh eyes. \
You have no knowledge of why decisions were made, only what the artifact says.

Your role in this review cycle:
- Find assumptions the builder took for granted but didn't validate
- Spot inconsistencies between what the code does and what comments/docs claim
- Identify missing edge cases, untested paths, and implicit dependencies
- Check naming consistency, API contract clarity, and documentation accuracy
- Flag anything that a new developer reading this cold would find confusing

Project context:
- VoxCore is a TrinityCore-based WoW private server (12.x Midnight client) for roleplay
- Tech stack: C++20, Lua (Eluna), Python, SQL (MySQL 8.0), WoW addon Lua/XML
- 5 databases: auth, characters, world, hotfixes, roleplay

Output format:
- Use markdown
- List each finding as: **[SEVERITY]** (CRITICAL/HIGH/MEDIUM/LOW/INFO) — description
- Group by category (Implementation Bias, Consistency, Edge Cases, Clarity)
- End with a VERDICT: PASS (no critical/high issues) or FAIL (has critical/high issues)
- Include a 1-paragraph summary of what changed since prior rounds (if applicable)
"""


def review(artifact: str, round_num: int = 1, prior_feedback: str = "",
           role: str = "cold-reader", model: str = DEFAULT_MODEL) -> str:
    """Send artifact to Claude API for cold-read review. Returns review text."""
    client = get_client()

    user_content = f"## Artifact to Review (Round {round_num})\n\n{artifact}"
    if prior_feedback:
        user_content += f"\n\n## Prior Review Feedback\n\n{prior_feedback}"
    user_content += "\n\nReview this artifact with completely fresh eyes. List all findings by severity."

    response = client.messages.create(
        model=model,
        max_tokens=8192,
        system=SYSTEM_PROMPT,
        messages=[{"role": "user", "content": user_content}],
        temperature=0.3,
    )

    return response.content[0].text


def test_connection():
    """Quick API connectivity test."""
    client = get_client()
    print(f"Testing connection to Claude API ({DEFAULT_MODEL})...")
    try:
        response = client.messages.create(
            model=DEFAULT_MODEL,
            max_tokens=20,
            messages=[{"role": "user", "content": "Reply with exactly: CLAUDE REVIEWER ONLINE"}],
        )
        reply = response.content[0].text.strip()
        print(f"Response: {reply}")
        if "CLAUDE" in reply.upper() or "REVIEWER" in reply.upper():
            print("Claude API reviewer bridge is operational.")
            return True
        else:
            print(f"Unexpected response: {reply}")
            return False
    except Exception as e:
        print(f"Connection failed: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(description="Claude API Reviewer")
    parser.add_argument("--test", action="store_true", help="Test API connectivity")
    parser.add_argument("--file", type=str, help="Review a specific file")
    parser.add_argument("--model", type=str, default=DEFAULT_MODEL, help="Model override")
    args = parser.parse_args()

    if args.test:
        test_connection()
        return

    if args.file:
        path = Path(args.file)
        if not path.exists():
            print(f"ERROR: File not found: {args.file}")
            sys.exit(1)
        artifact = path.read_text(encoding="utf-8")
        result = review(artifact, model=args.model)
        print(result)
        return

    print("Usage: python call_claude.py --test | --file <path>")


if __name__ == "__main__":
    main()
