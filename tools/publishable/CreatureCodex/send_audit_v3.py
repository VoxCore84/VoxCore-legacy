#!/usr/bin/env python3
"""
Send CreatureCodex v3 distribution to ChatGPT for audit.
Embeds all file contents inline so ChatGPT can do a thorough code review.
"""
import os
import sys
from pathlib import Path
from dotenv import load_dotenv

# Load API key — script is at tools/publishable/CreatureCodex/send_audit_v3.py
VOXCORE_ROOT = Path(__file__).resolve().parent.parent.parent.parent
load_dotenv(VOXCORE_ROOT / "config" / "api_architect.local.env")
load_dotenv(VOXCORE_ROOT / "tools" / "ai_studio" / ".env")

BUILD_DIR = Path(os.path.expanduser("~")) / "AppData" / "Local" / "Temp" / "CreatureCodex-build" / "CreatureCodex"

# Files to skip embedding (vendored libs — just note they exist)
SKIP_CONTENT = {
    "CreatureCodex/Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua",
    "CreatureCodex/Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua",
    "CreatureCodex/Libs/LibDataBroker-1.1/LibDataBroker-1.1.lua",
    "CreatureCodex/Libs/LibStub/LibStub.lua",
}

SYSTEM_PROMPT = """\
You are a senior software engineer and technical writer performing a product audit.

Your job: determine whether this software distribution is ready to ship to a hostile \
technical audience (TrinityCore Discord community — experienced C++ developers who will \
tear apart any inconsistency).

Be thorough, specific, and cite exact file paths and line numbers. No hand-waving. \
If something is wrong, say exactly what and where. If it's clean, say so with evidence.

Output format: structured markdown with clear sections, verdicts, and a final ship/no-ship decision.
"""

AUDIT_PROMPT_HEADER = """\
# CreatureCodex v1.0.0v7 — Final Audit

## For: ChatGPT (GPT-5.4)
## From: VoxCore Development Team (Claude Code + Human Operator)
## Date: 2026-03-13
## Purpose: Final audit — verify all v6 findings addressed

---

## Background

You audited v1 through v6. v6 API audit returned NO-SHIP with 1 high (stale AGGREGATION_DB refs),
3 medium (RBAC mismatch, shell wrapper claims, revert fragility), 2 low (Export.lua comment, version badges).

This is v7. Here's what changed since v6:

### Changes Since v6

1. **All stale `AGGREGATION_DB` references removed** — READMEs EN/DE/RU and `sql/codex_aggregated.sql`
   now say the table must exist in the `characters` database. No mention of the removed config variable.
2. **Export.lua HP comment fixed** — "Spell only seen at low HP" → "Spell seen below 40% HP at least once"
3. **RBAC docs aligned to shipped SQL** — All 3 READMEs now match `sql/auth_rbac_creature_codex.sql`
   (using `rbac_linked_permissions` + `INSERT IGNORE`, not `rbac_default_permissions` + `DELETE/INSERT`)
4. **`AR` protocol message documented** — All 3 README protocol tables now include the `AR|entry|OK`
   aggregation acknowledgement (S->C direction)
5. **Version/badge consistency** — DE/RU READMEs now show `# CreatureCodex v1.0.0` and `label=v1.0.0`
   matching the EN README
6. **`--revert` caveat added** — `_GUIDE/02_Server_Setup.md` now documents `--revert` as best-effort
   with a note to verify via `git diff`

### Cumulative fixes (v2 through v7)

All v1-v6 issues addressed. v7 adds 6 fixes (items above).

---

## Your Tasks for v7

### Task 1: Verify Every v7 Fix
Go through each of the 6 items above. Check the actual file contents below. Confirm or deny each fix.

### Task 2: Cross-Reference Integrity
Check that every file path, function name, column name, and command referenced in documentation
matches what's in the actual code files.

### Task 3: Fresh Adversarial Walkthroughs
Walk through as both personas:
- **Noob**: Never installed an addon, ChromieCraft repack, no Python
- **TC Bully**: Experienced C++ dev who will mock any inconsistency

### Task 4: Find NEW Issues
The fixes may have introduced new problems. Check for:
- Broken references from changes
- Inconsistencies between the three READMEs
- New documentation gaps
- Code issues in the addon/server scripts

### Task 5: Grep Audit
Confirm ZERO matches for these stale patterns in the shipped files:
- `bestiary` (old name)
- `BestiaryForge` (old namespace)
- `1.1.0` (old version)
- `string:trim` (wrong API)
- `Sync Sniff` (removed UI button)
- `AGGREGATION_DB` (removed config)
- `only seen below 40` (old wording)

### Task 6: Is This Ready to Ship?
Give a clear YES/NO. If NO, list remaining blockers with severity.

---

## Complete Distribution Contents

36 files total. Every non-library file is embedded below.

"""


def build_audit_content() -> str:
    """Build the full audit prompt with all file contents embedded."""
    parts = [AUDIT_PROMPT_HEADER]

    for filepath in sorted(BUILD_DIR.rglob("*")):
        if not filepath.is_file():
            continue

        rel = filepath.relative_to(BUILD_DIR)
        rel_str = str(rel).replace("\\", "/")

        if rel_str in SKIP_CONTENT:
            parts.append(f"\n### `{rel_str}` (vendored library — skipped)\n")
            continue

        try:
            content = filepath.read_text(encoding="utf-8", errors="replace")
        except Exception as e:
            parts.append(f"\n### `{rel_str}` (read error: {e})\n")
            continue

        parts.append(f"\n### `{rel_str}`\n")
        # Detect language for syntax highlighting
        ext = filepath.suffix.lower()
        lang = {
            ".lua": "lua", ".py": "python", ".cpp": "cpp", ".h": "cpp",
            ".md": "markdown", ".bat": "batch", ".sh": "bash",
            ".toc": "ini", ".txt": "text", ".sql": "sql",
        }.get(ext, "")
        parts.append(f"```{lang}\n{content}\n```\n")

    return "".join(parts)


def main():
    api_key = os.getenv("OPENAI_API_KEY", "")
    if not api_key or api_key == "YOUR_KEY_HERE":
        print("ERROR: OPENAI_API_KEY not set")
        sys.exit(1)

    if not BUILD_DIR.exists():
        print(f"ERROR: Build directory not found: {BUILD_DIR}")
        print("Run the zip build first.")
        sys.exit(1)

    from openai import OpenAI
    client = OpenAI(api_key=api_key)

    content = build_audit_content()
    print(f"Audit prompt: {len(content):,} characters ({len(content.split(chr(10))):,} lines)")

    model = os.getenv("OPENAI_MODEL", "gpt-5.4")
    print(f"Sending to {model}...")

    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": content},
        ],
        temperature=0.2,
        max_completion_tokens=16384,
    )

    result = response.choices[0].message.content
    usage = response.usage

    # Save to reports
    reports_dir = VOXCORE_ROOT / "AI_Studio" / "Reports" / "Audits"
    reports_dir.mkdir(parents=True, exist_ok=True)
    out_path = reports_dir / "CreatureCodex_v7_Audit.md"

    header = (
        f"---\n"
        f"reviewed: CreatureCodex v1.0.0v7\n"
        f"reviewer: ChatGPT ({model})\n"
        f"date: 2026-03-13\n"
        f"prompt_tokens: {usage.prompt_tokens}\n"
        f"completion_tokens: {usage.completion_tokens}\n"
        f"total_tokens: {usage.total_tokens}\n"
        f"---\n\n"
    )

    out_path.write_text(header + result, encoding="utf-8")
    print(f"\nAudit saved to: {out_path}")
    print(f"Tokens: {usage.prompt_tokens:,} prompt + {usage.completion_tokens:,} completion = {usage.total_tokens:,} total")
    print(f"\n{'='*60}")
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    print(result)


if __name__ == "__main__":
    main()
