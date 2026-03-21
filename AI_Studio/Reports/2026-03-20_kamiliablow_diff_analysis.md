# KamiliaBlow Diff Analysis — VoxCore Migration
**Date**: 2026-03-20
**Conclusion**: This is a merge, not a rebuild

## Git Topology

```
TrinityCore/TrinityCore (trinitycore remote)
  └── KamiliaBlow/RoleplayCore (upstream remote) — 46,111 commits ahead, 0 behind TC
        └── VoxCore84/RoleplayCore (origin remote) — 378 ahead, 92 behind KamiliaBlow
```

- KamiliaBlow is **fully synced** with TC upstream (0 commits behind)
- VoxCore is **92 commits behind** KamiliaBlow
- VoxCore has **378 unique commits** KamiliaBlow doesn't have
- TC upstream has **50 commits** VoxCore doesn't have (all included in KamiliaBlow's 92)

## The 92 Missing Commits — Categorized

### Build Bumps (5)
- 66220 → 66263 → 66337 → 66384 → 66431 → **66527**

### TC Upstream Merges (18)
- PRs #763-#794 merged from TrinityCore/master

### Transmog System (3)
- `105e91f3ac` — Implement 12.0.0 transmog system (Olcadoom via PR #775)
- `367ad57861` — Core/Transmog fix
- `1f2a721670` — Core/Transmog fix

### Massparsed / World Data (4)
- `30faec2f29` — Massparsed 11.x-12.x data
- `f1b9c0a51d` — 12.0.1 quest POI data
- `ef55db705a` — 12.0.1 locales
- `ea7e0ef170` — 12.0.1 WDB template data

### New Features (KamiliaBlow original)
- `d794fe4abb` — Quest: "Midnight" implementation
- `a80df8fa83` — Tele locations for Midnight
- `a21272fc4d` + `198e3f4cc4` — Druid advanced flying
- `9fc5c2e586` — Guild Mobile Banking
- `654d967e04` — Quest campaigns implementation
- `1510fc3d4c` — QuestMgr namespace + SPELL_EFFECT_SKIP_QUESTLINE
- `9b20b8a9f8` — Experimental DB2 HotReload
- `98b033c6a2` — Twilight Ascension game event
- `566477a858` — Dungeon encounter worldstates
- `2398042453` — Currency worldstates
- `08e17f1b05` — Campaign data blob to new hotfix table

### TC Upstream Features (pass-through)
- Haranir race data + racemask updates
- Priest talents (Searing Light, Archangel)
- Warrior talents (Thunder Blast, Brutal Finish, Cleave reduction)
- Druid talent (Galactic Guardian)
- Consecration areatrigger, Judgment updates
- MaxPlayerLevel → 90, GetMaxLevelForExpansion
- SPELL_ATTR11_CAN_ASSIST_UNINTERACTIBLE
- ConditionMgr improvements
- Guild bank vault fix, guild rename UTF-8 fix
- .debug modifiertree command

### Misc
- Warlock Destro spells
- free_share_scripts.cpp update
- Compile fixes
- AreaTrigger crash fix
- Memory usage reduction (data query cache)

## VoxCore's Unique Delta (what KamiliaBlow doesn't have)

### Unique src/ Files: 23
| File | System |
|------|--------|
| CompanionDefines.h, CompanionMgr.cpp/.h | Companion Squad |
| CompanionAI.cpp/.h, companion_commands.cpp, companion_scripts.cpp | Companion Scripts |
| TransmogrificationUtils.cpp/.h | Old transmog (DROP — replaced by Olcadoom's) |
| TransmogOutfitSystem.md | Doc (DROP) |
| creature_codex_sniffer.cpp, cs_creature_codex.cpp | CreatureCodex |
| cs_maxachieve.cpp, cs_maxrep.cpp, cs_maxtitles.cpp | Unlock commands |
| npc_copy_command.cpp | NPC copy |
| player_morph_scripts.cpp | Player morph |
| spell_arcane_waygate.cpp | Arcane waygate |
| spell_clear_transmog.cpp | Clear transmog |
| spell_wormhole_generators.cpp | Wormhole generators |
| voxplacer_commands.cpp | VoxPlacer |
| Live_Acceptance_Test.cpp | Testing |
| Custom/CMakeLists.txt | Build config |

### Unique SQL Files: 235
- Companion system SQL (5 files)
- Unlock scripts (heirlooms, toys, appearances, mounts, warband scenes, reputations)
- Player morph SQL
- World DB cleanup scripts (17 files in sql/exports/cleanup/)
- Update SQL files (sql/updates/)

### Unique Non-Source Directories
- `.claude/` — entire Claude Code configuration (agents, commands, hooks, rules)
- `AI_Studio/` — Triad coordination hub
- `tools/` — voxsniffer, api_architect, ai_studio, auto_parse, discord_bot, etc.
- `config/` — Triad API keys, paths
- `cowork/` — Claude Desktop scheduler bridge
- `runtime/` — Eluna lua scripts
- `doc/` — project docs, session state
- `wago/` — scraper, CSVs
- `data/` — data files

## Potential Merge Conflicts

**390 files** have been modified by both VoxCore and KamiliaBlow since their fork point.

### High-risk conflict areas:
- **Database implementations** (12 files): Both sides modified RoleplayDatabase, WorldDatabase, CharacterDatabase, HotfixDatabase, LoginDatabase, DatabaseEnv, DatabaseLoader, DBUpdater
- **Creature/Player** (10+ files): Creature.cpp/.h, Player.cpp/.h, ObjectMgr.cpp/.h — both sides have custom hooks
- **DB2 stores** (4 files): DB2LoadInfo.h, DB2Stores.cpp/.h, DB2Structure.h — large files with many additions
- **RBAC.h**: Both sides added custom permissions
- **CMakeLists.txt** (3 files): Build system changes
- **Transmog handlers**: VoxCore has old system, KamiliaBlow has Olcadoom's new system
- **World.cpp**: Both sides added startup hooks
- **worldserver.conf.dist**: Both sides added config keys

### Low-risk (likely auto-resolve):
- Files where only one side made meaningful changes and the other just has formatting/whitespace
- SQL files (additive, rarely conflict)
- Eluna files (same source, likely identical)

## Two Strategy Options

### Option A: Merge (recommended)
```bash
git checkout -b migration/v2 master
git merge upstream/master
# Resolve ~390 conflicts
# Build and test
```
**Pros**: Preserves full history, git does most of the work, only need to resolve actual conflicts
**Cons**: 390 potential conflict files (many will auto-resolve), messy merge commit history

### Option B: Fresh Clone + Cherry-pick (original V1 approach)
```bash
# New repo from KamiliaBlow's latest
# Cherry-pick/port 378 VoxCore commits
```
**Pros**: Clean history, fresh start
**Cons**: Massive manual effort, risk of missing things, need to re-apply all 235 SQL files

### Option C: Hybrid — Squash Merge
```bash
git checkout -b migration/v2 upstream/master
git merge --squash master
# Single commit with all VoxCore changes applied on KamiliaBlow's latest
```
**Pros**: Clean single-commit merge, starts from KamiliaBlow's latest baseline
**Cons**: Loses VoxCore commit history (but it's in the old branch)

## Recommendation

**Option A (straight merge)** is the most practical. Here's why:
1. Git's 3-way merge will auto-resolve most of the 390 files
2. The shared ancestry means both sides started from the same code
3. Conflicts will be concentrated in the high-risk areas listed above (~20-30 files needing manual resolution)
4. Preserves all history for both sides
5. Can be done in a worktree for safety

The V1 spec's 10-phase migration was designed for a scenario where we had NO common ancestor with TC. But we DO — we're a fork of KamiliaBlow which is a fork of TC. Git merge is literally designed for this.
