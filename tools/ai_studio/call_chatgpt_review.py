"""
ChatGPT Reviewer — Sends artifacts to ChatGPT for architecture/design review.

Uses OPENAI_API_KEY from tools/ai_studio/.env or config/api_architect.local.env.

Usage:
    # As module (from review_cycle.py):
    from call_chatgpt_review import review(artifact, round_num, prior_feedback, role)

    # Standalone test:
    python call_chatgpt_review.py --test
    python call_chatgpt_review.py --file path/to/artifact.md
"""
import os
import sys
import argparse
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
CONFIG_DIR = PROJECT_ROOT / "config"

DEFAULT_MODEL = "gpt-5.4"


def load_env():
    """Load OPENAI_API_KEY from .env files (no dotenv dependency)."""
    for env_path in [SCRIPT_DIR / ".env", CONFIG_DIR / "api_architect.local.env"]:
        if env_path.exists():
            with open(env_path, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith("#") and "=" in line:
                        k, v = line.split("=", 1)
                        os.environ.setdefault(k.strip(), v.strip().strip('"\''))


def get_client():
    """Initialize OpenAI client."""
    load_env()
    api_key = os.environ.get("OPENAI_API_KEY", "")
    if not api_key:
        print("ERROR: OPENAI_API_KEY not set.")
        print(f"Edit: {SCRIPT_DIR / '.env'} or {CONFIG_DIR / 'api_architect.local.env'}")
        sys.exit(1)

    from openai import OpenAI
    return OpenAI(api_key=api_key)


SYSTEM_PROMPT = """\
You are the Lead Architect reviewer in the VoxCore Triad review pipeline.

Your role in this review cycle:
- Evaluate architecture decisions, design patterns, and API contracts
- Verify the artifact follows established conventions and is internally consistent
- Check that the solution is appropriately scoped (not over-engineered, not under-engineered)
- Validate phase ordering, dependency chains, and integration points
- Identify missing components, unclear interfaces, or misaligned abstractions
- On later rounds: verify that fixes from prior rounds are correct and didn't introduce new issues

Project context:
- VoxCore is a TrinityCore-based WoW private server (12.x Midnight client) for roleplay
- Tech stack: C++20, Lua (Eluna), Python, SQL (MySQL 8.0), WoW addon Lua/XML
- 5 databases: auth, characters, world, hotfixes, roleplay
- AI Fleet: ChatGPT (you, Architect), Claude Code (Implementer), Gemini (QA), Claude API (Cold-reader)

Output format:
- Use markdown
- List each finding as: **[SEVERITY]** (CRITICAL/HIGH/MEDIUM/LOW/INFO) — description
- Group by category (Architecture, Design, Scope, Integration, Conventions)
- End with a VERDICT: PASS (no critical/high issues) or FAIL (has critical/high issues)
- Include a 1-paragraph summary of what changed since prior rounds (if applicable)
"""


def review(artifact: str, round_num: int = 1, prior_feedback: str = "",
           role: str = "architect", model: str = DEFAULT_MODEL) -> str:
    """Send artifact to ChatGPT for review. Returns review text."""
    client = get_client()

    user_content = f"## Artifact to Review (Round {round_num})\n\n{artifact}"
    if prior_feedback:
        user_content += f"\n\n## Prior Review Feedback\n\n{prior_feedback}"
    user_content += "\n\nReview this artifact thoroughly. List all findings by severity."

    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_content},
        ],
        temperature=0.3,
        max_completion_tokens=8192,
    )

    return response.choices[0].message.content


def test_connection():
    """Quick API connectivity test."""
    client = get_client()
    print(f"Testing connection to ChatGPT ({DEFAULT_MODEL})...")
    try:
        response = client.chat.completions.create(
            model=DEFAULT_MODEL,
            messages=[
                {"role": "user", "content": "Reply with exactly: CHATGPT ARCHITECT ONLINE"}
            ],
            max_completion_tokens=20,
        )
        reply = response.choices[0].message.content.strip()
        print(f"Response: {reply}")
        if "CHATGPT" in reply.upper() or "ARCHITECT" in reply.upper():
            print("ChatGPT architect reviewer bridge is operational.")
            return True
        else:
            print(f"Unexpected response: {reply}")
            return False
    except Exception as e:
        print(f"Connection failed: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(description="ChatGPT Reviewer")
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

    print("Usage: python call_chatgpt_review.py --test | --file <path>")


if __name__ == "__main__":
    main()
