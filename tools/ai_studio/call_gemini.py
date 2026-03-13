"""
Gemini Reviewer — Sends artifacts to Gemini for correctness/security auditing.

Uses the google-genai SDK with GOOGLE_API_KEY from config/gemini.local.env.

Usage:
    # As module (from review_cycle.py):
    from call_gemini import review(artifact, round_num, prior_feedback, role)

    # Standalone test:
    python call_gemini.py --test
    python call_gemini.py --file path/to/artifact.md
"""
import os
import sys
import argparse
from pathlib import Path
from datetime import datetime

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
CONFIG_DIR = PROJECT_ROOT / "config"

DEFAULT_MODEL = "gemini-2.5-pro"


def load_env():
    """Load GOOGLE_API_KEY from config/gemini.local.env (no dotenv dependency)."""
    env_path = CONFIG_DIR / "gemini.local.env"
    if env_path.exists():
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    k, v = line.split("=", 1)
                    os.environ[k.strip()] = v.strip().strip('"\'')


def get_client():
    """Initialize google-genai client."""
    load_env()
    api_key = os.environ.get("GOOGLE_API_KEY", "")
    if not api_key:
        print("ERROR: GOOGLE_API_KEY not set.")
        print(f"Edit: {CONFIG_DIR / 'gemini.local.env'}")
        sys.exit(1)

    from google import genai
    return genai.Client(api_key=api_key)


SYSTEM_PROMPT = """\
You are a rigorous code and architecture auditor in the VoxCore Triad review pipeline.

Your role in this review cycle:
- Find correctness bugs, logic errors, edge cases, and security issues
- Verify data integrity (SQL column counts, schema alignment, off-by-one errors)
- Check for OWASP top-10 vulnerabilities where applicable
- Flag incomplete implementations or missing error handling at system boundaries
- Be strict — false negatives (missed bugs) are worse than false positives

Project context:
- VoxCore is a TrinityCore-based WoW private server (12.x Midnight client) for roleplay
- Tech stack: C++20, Lua (Eluna), Python, SQL (MySQL 8.0), WoW addon Lua/XML
- 5 databases: auth, characters, world, hotfixes, roleplay

Output format:
- Use markdown
- List each finding as: **[SEVERITY]** (CRITICAL/HIGH/MEDIUM/LOW/INFO) — description
- Group by category (Correctness, Security, Performance, Style)
- End with a VERDICT: PASS (no critical/high issues) or FAIL (has critical/high issues)
- Include a 1-paragraph summary of what changed since prior rounds (if applicable)
"""


def review(artifact: str, round_num: int = 1, prior_feedback: str = "",
           role: str = "auditor", model: str = DEFAULT_MODEL) -> str:
    """Send artifact to Gemini for review. Returns review text."""
    client = get_client()

    user_content = f"## Artifact to Review (Round {round_num})\n\n{artifact}"
    if prior_feedback:
        user_content += f"\n\n## Prior Review Feedback\n\n{prior_feedback}"
    user_content += "\n\nReview this artifact thoroughly. List all findings by severity."

    response = client.models.generate_content(
        model=model,
        contents=user_content,
        config={
            "system_instruction": SYSTEM_PROMPT,
            "temperature": 0.3,
            "max_output_tokens": 8192,
        },
    )

    if response.text is None:
        # Fallback: extract from candidates
        for candidate in (response.candidates or []):
            for part in (candidate.content.parts or []):
                if hasattr(part, "text") and part.text:
                    return part.text
        return "(Gemini returned empty response)"
    return response.text


def test_connection():
    """Quick API connectivity test."""
    client = get_client()
    print(f"Testing connection to Gemini ({DEFAULT_MODEL})...")
    try:
        response = client.models.generate_content(
            model=DEFAULT_MODEL,
            contents="Reply with exactly: GEMINI AUDITOR ONLINE",
            config={"max_output_tokens": 1024},
        )
        raw = response.text
        if raw is None:
            # Extract from candidates
            for c in (response.candidates or []):
                for p in (c.content.parts or []):
                    if hasattr(p, "text") and p.text:
                        raw = p.text
                        break
        reply = (raw or "").strip()
        print(f"Response: {reply}")
        if reply and ("GEMINI" in reply.upper() or "AUDITOR" in reply.upper()):
            print("Gemini auditor bridge is operational.")
            return True
        else:
            print(f"Unexpected response: {reply}")
            return False
    except Exception as e:
        print(f"Connection failed: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(description="Gemini Reviewer")
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

    print("Usage: python call_gemini.py --test | --file <path>")


if __name__ == "__main__":
    main()
