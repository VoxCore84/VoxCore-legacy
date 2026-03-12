# Reusable Audit Templates

*Absorbed from Desktop/Checks to perform.txt — two audit prompt templates from session 138.*

These are reusable templates. Adjust dates, commit hashes, and specifics for future audits.

---

## Template 1: Post-Session Verification Audit

Paste into a fresh Claude Code tab after a major session:

```
Session [N] Post-Session Verification Audit

Run a comprehensive verification of everything done in session [N]. Check every change, every config, every claim. Do NOT trust prior session summaries — verify independently.

1. System Changes (verify these took effect)
   - CPU cores: wmic cpu get NumberOfLogicalProcessors
   - Power plan: powercfg /getactivescheme
   - Services: sc query SysMain / WSearch / DiagTrack

2. Python Environment
   - python --version, where python, uv --version
   - Verify key packages: python -c "import openai, anthropic, discord, dotenv; print('ALL IMPORTS OK')"

3. API Keys & Pipelines
   - Test each pipeline end-to-end
   - Check .env has real keys (not YOUR_KEY_HERE) — don't print actual keys

4. Git State
   - git log --oneline -5 / git log --oneline origin/master -5
   - git status — check nothing critical is staged or lost

5. Model Versions in Code
   - grep -n "GenerativeModel\|model=" in orchestrator/bridge/report scripts
   - Verify models match intended versions

6. Memory Files Consistency
   - Cross-check api-credentials-map.md, ai-fleet-comms.md, 0_Central_Brain.md
   - Do model names match actual code? Do credential paths point to real files?

7. Git Hygiene
   - No .env or credential files tracked
   - .gitignore covers sensitive files
   - Remote is up to date

Deliverable: PASS/FAIL for each section with quoted evidence.
```

---

## Template 2: Full-Day Cross-Agent Audit

For days with work across multiple AI agents:

```
Full-Day Verification Audit — [DATE] (All Agents)

Today had [N] commits across [agents]. This audit verifies EVERYTHING.

1. Per-Commit Verification
   For each commit hash:
   - Verify files exist and have meaningful content (not empty/stub)
   - Check content quality against what was claimed
   - Verify external configs (MCP, .env) if referenced

2. Untracked Files Audit
   For each untracked file in git status:
   - (a) real work → commit, (b) scaffolding → delete, (c) WIP → leave

3. Cross-Agent Consistency Check
   Verify these docs agree with each other AND actual code:
   - AI_Studio/0_Central_Brain.md
   - api-credentials-map.md
   - ai-fleet-comms.md

4. Session State & Central Brain Integrity
   - session_state.md has today's entries
   - Central Brain has today's date
   - All "Completed Today" items — do referenced reports exist?
   - No stale/contradictory entries

5. Git Hygiene
   - No credential files tracked
   - .gitignore covers sensitive files
   - Remote is up to date

Deliverable: PASS/FAIL/WARNING per section. [CONTRADICTION] and [DECISION NEEDED] tags.
Save to AI_Studio/Reports/Audits/[DATE]__FULL_DAY_AUDIT.md
```
