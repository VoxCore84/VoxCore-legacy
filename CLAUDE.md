# RoleplayCore — Project Guide

## P0 — USE THE TRIAD (do not brute-force)
**You have live API access to ChatGPT (gpt-5.4) and Gemini (gemini-3.1-pro). USE THEM.**

### The Pipeline
```
1. DESIGN  → ChatGPT generates spec    → lands in AI_Studio/1_Inbox/
2. REVIEW  → ChatGPT reviews spec      → approved specs move to AI_Studio/2_Active_Specs/
3. BUILD   → Claude Code implements     → code/SQL/config written
4. REVIEW CYCLE (5-round, 3 reviewers):
   4a. ChatGPT reviews   → architecture/design      → fix issues
   4b. Gemini reviews    → correctness/edge cases   → fix issues
   4c. Claude API reviews → cold-read, impl bias    → fix issues
   4d. ChatGPT reviews   → verify fixes, coherence  → fix issues
   4e. Gemini reviews    → final seal (strictest)
5. USER    → human review of final artifact
```

### When to Call Each
| Trigger | Who | Command |
|---------|-----|---------|
| New feature / subsystem / architecture | ChatGPT | `python tools/api_architect/run_architect.py --prompt "..."` |
| Spec in inbox needs review before implementing | ChatGPT | `python tools/ai_studio/chatgpt_bridge.py --file SPEC.md` |
| Implementation done, non-trivial changes | Gemini | `python tools/ai_studio/orchestrator.py` |
| Unsure about an architecture decision | ChatGPT | Same as row 1 — ask before deciding |

### How Handoffs Work
- **ChatGPT → Claude Code**: Spec `.md` file lands in `AI_Studio/1_Inbox/`. Read it, claim it in Central Brain, implement it
- **Claude Code → Gemini**: After implementation, run orchestrator. It sends your diff + context to Gemini, gets back approval or rejection with specific issues
- **Gemini → Claude Code**: If rejected, fix the cited issues and re-run the audit. If approved, write handoff to `AI_Studio/Reports/Audits/`
- **Coordination**: Update `AI_Studio/0_Central_Brain.md` when starting/finishing work. Update `doc/session_state.md` for multi-tab coordination

### Exceptions (no API call needed)
Localized bug fixes, log parsing, build-loop, file cleanup, simple CLI ops, git operations.

### Self-Check
Before completing any session with non-trivial work, ask: *"Did I use the Triad, or did I brute-force this?"*

## THE TRIAD EVOLUTION DIRECTIVE (Core Philosophy)
At every step, ask: *"What would I do differently if I knew I had nearly unlimited potential to run AIs?"* You have agent swarms, subagents, custom skills, ChatGPT API, Gemini API, Cowork scheduled tasks, and massive parallel compute. Claude Code is the primary terminal — all other AIs are API endpoints. Never accept a standard approach if you can think of a smarter, faster, cheaper, or better way to leverage the swarm.

## THE "DIG DEEPER" MANDATE (3x Iteration Rule)
**ALWAYS try to "dig deeper" at least 3 times before reporting back.** Iterate, research, and push analysis 3 levels deep. If reports are massive, write to `AI_Studio/Reports/`.

## What This Is
TrinityCore-based WoW private server targeting **12.x / Midnight** client, specialized for **roleplay**. Custom systems, 5 databases (auth, characters, world, hotfixes, roleplay).

## CRITICAL RULES (Claude gets these wrong without them)
- **Building from Claude Code is allowed** — use `ninja -j32` via Bash (VS IDE also works)
- **DESCRIBE tables before writing SQL** — verify column names and count
- **No `item_template`** — use `hotfixes.item` / `hotfixes.item_sparse`
- **No `broadcast_text` in world** — use `hotfixes.broadcast_text`
- **`creature_template`**: column is `faction` (not FactionID), `npcflag` (bigint)
- Spells in `creature_template_spell` (cols: `CreatureID`, `Index`, `Spell`)

## Session Start — MANDATORY
See `.claude/rules/session-start.md`. In brief: Read `AI_Studio/0_Central_Brain.md` + `doc/session_state.md` + `todo.md` BEFORE responding. EXTRACT actionable items and show to user. Never silently drop items.

## Proactive Skill Reminders — MANDATORY
See `.claude/rules/skill-reminders.md`. The user should NEVER have to remember a slash command. Key: `/wrap-up` at end of session, `/check-logs` on crash/restart, `/lookup-*` for names without IDs.

## Work Style
**MANDATORY**: Always default to parallel execution. Hardware is not a constraint (16C/32T, 128GB DDR5, NVMe).
1. **2+ independent parts → parallel agents** — just do it
2. **2+ searches → fan out Explore agents** — never sequential
3. **Multiple errors → one agent per error category**
4. **Builds, long queries, server restarts → always background**

## Debugging — MANDATORY PIPELINE
See `.claude/rules/debugging.md`. 4-gate pipeline. No hypothesis without data. Never combine fixes.

## Completion Integrity — MANDATORY
See `.claude/rules/completion-integrity.md`. Never claim completion without tool output proving it.

## Multi-Tab Delegation — BLOCKING OBLIGATION
See `.claude/rules/multi-tab.md`. If task touches 2+ independent subsystems, MUST suggest tab split.

## Compaction Instructions
When compacting, ALWAYS preserve: (1) files modified this session, (2) current task/goal, (3) pending SQL or build actions, (4) spawned agents and findings. Drop: exploration results, failed approaches, verbose tool output.

## Release Gate — MANDATORY for Shipping
Before shipping any addon, tool, or app: run `/pre-ship <path>`. It runs automated checks (naming, non-ASCII, TOC, versions, docs, secrets) then spawns 3 adversarial review agents (noob, bully, security) in parallel. Writes `.claude/release-gate-status.json` which enforcement hooks read — `git push --tags` and `gh release create` are BLOCKED when gate != PASS. Full checklist: `memory/addon-building-checklist.md` (16 phases, ~130 items).

## Reference (loaded on-demand from `.claude/rules/`)
- **Project structure, build, DBs, systems, key files, tools** → `project-reference.md`
- **C++ coding conventions** → `coding-conventions.md`
