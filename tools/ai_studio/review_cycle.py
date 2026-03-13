"""
5-Round Review Cycle — Orchestrates ChatGPT, Gemini, and Claude API reviews.

Pipeline:
  Round 1: ChatGPT  — architecture/design review
  Round 2: Gemini   — correctness audit, edge cases
  Round 3: Claude   — cold-read, implementation bias detection
  Round 4: ChatGPT  — verify fixes, design coherence
  Round 5: Gemini   — final seal (strictest auditor gets last word)

Each round's feedback feeds into the next. Saves all reviews to
AI_Studio/Reports/Audits/ and prints a final summary.

Usage:
    python review_cycle.py --file path/to/artifact.md
    python review_cycle.py --file path/to/artifact.md --rounds 3
    python review_cycle.py --file path/to/artifact.md --skip-claude
    python review_cycle.py --test
"""
import os
import sys
import argparse
import time
from pathlib import Path
from datetime import datetime

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
REPORTS_DIR = PROJECT_ROOT / "AI_Studio" / "Reports" / "Audits"

# Import the three reviewer modules
sys.path.insert(0, str(SCRIPT_DIR))

# Models — strongest available for each provider
MODELS = {
    "chatgpt": os.environ.get("REVIEW_MODEL_CHATGPT", "gpt-5.4"),
    "gemini": os.environ.get("REVIEW_MODEL_GEMINI", "gemini-2.5-pro"),
    "claude": os.environ.get("REVIEW_MODEL_CLAUDE", "claude-sonnet-4-6"),
}

# Round definitions: (reviewer_name, module, role_description)
ROUND_PLAN = [
    ("ChatGPT",  "chatgpt", "architecture/design review"),
    ("Gemini",   "gemini",  "correctness audit, edge cases, security"),
    ("Claude",   "claude",  "cold-read, implementation bias detection"),
    ("ChatGPT",  "chatgpt", "verify fixes from rounds 2-3, design coherence"),
    ("Gemini",   "gemini",  "final seal — strictest auditor gets last word"),
]


def call_chatgpt(artifact: str, round_num: int, prior_feedback: str,
                 role: str, model: str) -> str:
    """Call ChatGPT via OpenAI API."""
    from call_chatgpt_review import review
    return review(artifact, round_num, prior_feedback, role, model)


def call_gemini(artifact: str, round_num: int, prior_feedback: str,
                role: str, model: str) -> str:
    """Call Gemini via google-genai."""
    from call_gemini import review
    return review(artifact, round_num, prior_feedback, role, model)


def call_claude(artifact: str, round_num: int, prior_feedback: str,
                role: str, model: str) -> str:
    """Call Claude via Anthropic API."""
    from call_claude import review
    return review(artifact, round_num, prior_feedback, role, model)


DISPATCHERS = {
    "chatgpt": call_chatgpt,
    "gemini": call_gemini,
    "claude": call_claude,
}


def save_round_review(artifact_name: str, round_num: int, reviewer: str,
                      review_text: str, model: str, elapsed: float) -> Path:
    """Save a single round's review to disk."""
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    stem = Path(artifact_name).stem
    filename = f"{timestamp}__REVIEW_R{round_num}_{reviewer}_{stem}.md"
    out_path = REPORTS_DIR / filename

    header = (
        f"---\n"
        f"artifact: {artifact_name}\n"
        f"round: {round_num}\n"
        f"reviewer: {reviewer}\n"
        f"model: {model}\n"
        f"date: {datetime.now().isoformat()}\n"
        f"elapsed_seconds: {elapsed:.1f}\n"
        f"---\n\n"
    )

    out_path.write_text(header + review_text, encoding="utf-8")
    return out_path


def save_cycle_summary(artifact_name: str, rounds_completed: list,
                       final_verdict: str) -> Path:
    """Save a summary of the full review cycle."""
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    stem = Path(artifact_name).stem
    filename = f"{timestamp}__REVIEW_SUMMARY_{stem}.md"
    out_path = REPORTS_DIR / filename

    lines = [
        f"# Review Cycle Summary: {artifact_name}\n",
        f"**Date**: {datetime.now().isoformat()}\n",
        f"**Rounds completed**: {len(rounds_completed)}\n",
        f"**Final verdict**: {final_verdict}\n",
        "",
        "## Round Results\n",
    ]

    for r in rounds_completed:
        verdict_marker = "PASS" if "pass" in r["verdict"].lower() else "FAIL"
        lines.append(
            f"| R{r['round']} | {r['reviewer']} | {r['model']} | "
            f"{r['elapsed']:.1f}s | {verdict_marker} |"
        )

    lines.insert(6, "| Round | Reviewer | Model | Time | Verdict |")
    lines.insert(7, "|-------|----------|-------|------|---------|")

    lines.append("")
    lines.append("## Per-Round Reviews\n")
    for r in rounds_completed:
        lines.append(f"### Round {r['round']}: {r['reviewer']}\n")
        lines.append(r["review_text"])
        lines.append("\n---\n")

    out_path.write_text("\n".join(lines), encoding="utf-8")
    return out_path


def extract_verdict(review_text: str) -> str:
    """Extract PASS/FAIL verdict from review text."""
    upper = review_text.upper()
    # Look for explicit verdict line
    for line in upper.split("\n"):
        if "VERDICT" in line:
            if "FAIL" in line:
                return "FAIL"
            if "PASS" in line:
                return "PASS"
    # Fallback: count severities
    critical = upper.count("CRITICAL")
    high = upper.count("[HIGH]")
    if critical > 0 or high > 0:
        return "FAIL"
    return "PASS"


def run_cycle(artifact_path: Path, max_rounds: int = 5, skip_claude: bool = False):
    """Run the full N-round review cycle."""
    artifact_name = artifact_path.name
    artifact_text = artifact_path.read_text(encoding="utf-8")

    plan = ROUND_PLAN[:max_rounds]

    if skip_claude:
        plan = [(name, mod, role) for name, mod, role in plan if mod != "claude"]
        plan = plan[:max_rounds]

    print(f"\n{'='*70}")
    print(f"  REVIEW CYCLE: {artifact_name}")
    print(f"  Rounds: {len(plan)} | Models: {', '.join(set(MODELS[p[1]] for p in plan))}")
    print(f"{'='*70}\n")

    rounds_completed = []
    cumulative_feedback = ""

    for i, (reviewer_name, module_key, role_desc) in enumerate(plan, 1):
        model = MODELS[module_key]
        print(f"  Round {i}/{len(plan)}: {reviewer_name} ({model}) — {role_desc}")

        dispatcher = DISPATCHERS[module_key]
        start = time.time()

        try:
            review_text = dispatcher(
                artifact=artifact_text,
                round_num=i,
                prior_feedback=cumulative_feedback,
                role=role_desc,
                model=model,
            )
        except Exception as e:
            review_text = f"**ERROR**: {reviewer_name} API call failed: {e}"
            print(f"    ERROR: {e}")

        elapsed = time.time() - start
        verdict = extract_verdict(review_text)

        # Save individual round
        review_path = save_round_review(artifact_name, i, reviewer_name,
                                        review_text, model, elapsed)
        print(f"    Verdict: {verdict} | {elapsed:.1f}s | Saved: {review_path.name}")

        rounds_completed.append({
            "round": i,
            "reviewer": reviewer_name,
            "model": model,
            "elapsed": elapsed,
            "verdict": verdict,
            "review_text": review_text,
            "review_path": str(review_path),
        })

        # Accumulate feedback for next round
        cumulative_feedback += (
            f"\n\n### Round {i} ({reviewer_name}, {model}):\n"
            f"Verdict: {verdict}\n\n{review_text}"
        )

    # Final verdict = last round's verdict
    final_verdict = rounds_completed[-1]["verdict"] if rounds_completed else "UNKNOWN"

    # Save cycle summary
    summary_path = save_cycle_summary(artifact_name, rounds_completed, final_verdict)

    print(f"\n{'='*70}")
    print(f"  CYCLE COMPLETE: {final_verdict}")
    print(f"  Summary: {summary_path}")
    print(f"  Total time: {sum(r['elapsed'] for r in rounds_completed):.1f}s")
    print(f"{'='*70}\n")

    return {
        "final_verdict": final_verdict,
        "rounds": rounds_completed,
        "summary_path": str(summary_path),
    }


def test_all():
    """Test connectivity to all 3 APIs."""
    print("Testing all 3 reviewer APIs...\n")
    results = {}

    # ChatGPT
    print("1. ChatGPT...")
    try:
        from call_chatgpt_review import test_connection as test_chatgpt
        results["ChatGPT"] = test_chatgpt()
    except Exception as e:
        print(f"   FAILED: {e}")
        results["ChatGPT"] = False

    # Gemini
    print("\n2. Gemini...")
    try:
        from call_gemini import test_connection as test_gemini
        results["Gemini"] = test_gemini()
    except Exception as e:
        print(f"   FAILED: {e}")
        results["Gemini"] = False

    # Claude
    print("\n3. Claude API...")
    try:
        from call_claude import test_connection as test_claude
        results["Claude"] = test_claude()
    except Exception as e:
        print(f"   FAILED: {e}")
        results["Claude"] = False

    print(f"\n{'='*40}")
    for name, ok in results.items():
        status = "OK" if ok else "FAILED"
        print(f"  {name}: {status}")
    print(f"{'='*40}")

    all_ok = all(results.values())
    if all_ok:
        print("\nAll 3 APIs operational. Review cycle ready.")
    else:
        failed = [k for k, v in results.items() if not v]
        print(f"\nFailed: {', '.join(failed)}. Fix before running review cycle.")

    return all_ok


def main():
    parser = argparse.ArgumentParser(
        description="5-Round Review Cycle — ChatGPT, Gemini, Claude API"
    )
    parser.add_argument("--test", action="store_true",
                        help="Test connectivity to all 3 APIs")
    parser.add_argument("--file", type=str,
                        help="Path to artifact to review")
    parser.add_argument("--rounds", type=int, default=5,
                        help="Number of review rounds (1-5, default: 5)")
    parser.add_argument("--skip-claude", action="store_true",
                        help="Skip Claude API rounds (use only ChatGPT + Gemini)")
    args = parser.parse_args()

    if args.test:
        sys.exit(0 if test_all() else 1)

    if args.file:
        path = Path(args.file)
        if not path.exists():
            print(f"ERROR: File not found: {args.file}")
            sys.exit(1)
        result = run_cycle(path, max_rounds=args.rounds, skip_claude=args.skip_claude)
        sys.exit(0 if result["final_verdict"] == "PASS" else 1)

    parser.print_help()


if __name__ == "__main__":
    main()
