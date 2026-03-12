# RoleplayCore — Project Guide

## THE TRIAD EVOLUTION DIRECTIVE (Core Philosophy)
At every step, ask: *"What would I do differently if I knew I had nearly unlimited potential to run AIs?"* You have agent swarms, subagents, custom skills, ChatGPT, Antigravity, Grok Heavy, and massive parallel compute. Never accept a standard approach if you can think of a smarter, faster, cheaper, or better way to leverage the swarm.

## THE "DIG DEEPER" MANDATE (3x Iteration Rule)
**ALWAYS try to "dig deeper" at least 3 times before reporting back.** Iterate, research, and push analysis 3 levels deep. If reports are massive, write to `AI_Studio/Reports/`.

## What This Is
TrinityCore-based WoW private server targeting **12.x / Midnight** client, specialized for **roleplay**. Custom systems, 5 databases (auth, characters, world, hotfixes, roleplay).

## CRITICAL RULES (Claude gets these wrong without them)
- **NEVER build from Claude Code** — user ALWAYS builds via Visual Studio IDE
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

## Reference (loaded on-demand from `.claude/rules/`)
- **Project structure, build, DBs, systems, key files, tools** → `project-reference.md`
- **C++ coding conventions** → `coding-conventions.md`
- **Transmog rules** → `transmog.md`
