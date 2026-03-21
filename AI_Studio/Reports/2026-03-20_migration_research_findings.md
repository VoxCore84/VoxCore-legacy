# VoxCore Migration Research Findings — Session 193
**Date**: 2026-03-20
**Status**: IN PROGRESS — spec V1 failed review, V2 intake needed

## 1. Problem Statement
VoxCore needs to purge accumulated cruft (~15K commits of do/undo/redo) and rebuild on fresh TrinityCore master (build 66527). Driving issues:
- Missing GameObjects in Stormwind (ships, king's death monument)
- 101K NPCs bulk-imported without proper phasing → NPC clustering
- 50 upstream TC commits missing including build bumps
- WoW client updated to build 66527, need new CASC/wago data
- 15K+ commits of learning/experimental code

## 2. Triad Pipeline Results

### 2a. ChatGPT Architect (gpt-5.4) — Spec V1
- **File**: `AI_Studio/1_Inbox/2026-03-20__TRIAD-VOXCORE-MIGRATION-V1__voxcore_fresh_trinitycore_master_migration_to_build_66527.md`
- **Intake**: `AI_Studio/1_Inbox/migration_intake.md`
- **Result**: 400-line comprehensive spec with 10 phases, 10 architectural decisions
- **Macro structure praised**: phased approach, drop manifest, append-only constraint, phase gates

### 2b. 5-Round Review Cycle — UNANIMOUS FAIL (5/5)
- **Wall time**: 461.7s | **CPU saved**: 129s via parallelism
- **Reports**: `AI_Studio/Reports/Audits/2026-03-20_14*MIGRATION*`

#### CRITICAL Issues (2)
1. No mechanism to find the upstream TC commit for build 66527 (TC doesn't tag by client build number)
2. "26 custom scripts" and "8 custom columns" asserted but never enumerated (actual: 20 script entrypoints, 6 confirmed columns)

#### HIGH Issues (10)
3. Proposed `VoxCore/TrinityCore/` nested layout wrong — VoxCore IS the TC root
4. CompanionMgr dependency graph wrong — doesn't depend on Hoff/Craft
5. Eluna treated as future integration — already fully integrated (~35 files)
6. Skyriding treated as simple external patch — already spans scripts, SpellMgr, Player.cpp, SQL
7. RoleplayDB treated as future port — already live in Main.cpp, DatabaseEnv, DBUpdater, World.cpp
8. No database rollback strategy (ALTER TABLE isn't git-reversible)
9. No character data migration plan
10. No handling if fresh TC baseline fails to build
11. No mandated security audit for DB code
12. SQL paths use `3.3.5/` convention instead of retail `master/`

#### MEDIUM Issues (8)
- `advanced_flying_pr_30199/` in file structure but never in spec body
- BalticCoresTDB approval criteria undefined
- Transmog placeholder strategy ambiguous
- Eluna tc-retail branch compatibility with 66527 unvalidated
- verify_required_columns.sql has no pass/fail criteria
- "Append-only RBAC" never defined
- Hoff system never described
- Roleplay/ consolidation hides refactor cost

## 3. Deep Search Findings — TC Retail Ecosystem

### TIER 1: HIGH-VALUE

#### KamiliaBlow/RoleplayCore — THE major community retail TC fork
- **URL**: github.com/KamiliaBlow/RoleplayCore
- **Stars**: 26 | **Forks**: 16 | **Updated**: 2026-03-20 (today)
- **Target**: master = 12.0.1.66527 (Midnight)
- **VoxCore is a fork of this repo** (not directly of TrinityCore)
- **Recent commits** (last 7 days):
  - `Implement 12.0.0 transmog system` (from Olcadoom — same code TC rejected as "AI garbage" from PRs #31720/#31721)
  - Massparsed 11.x-12.x creature/quest data
  - 12.0.1 quest POI data, locales, WDB template data
  - Druid advanced flying support
  - Guild Mobile Banking
  - Game events, worldstates, hotfix data
  - `free_share_scripts.cpp` updates (Mar 16)
- **Key contributors**: Shauren (6,529), Vincent-Michael (1,769), Aokromes (1,609), KamiliaBlow (1,334)
- **NOTE**: Some content in KamiliaBlow's fork originally came from VoxCore/user contributions

#### BalticCoresTDB 12.0.1
- **Source**: github.com/coreretail6/RetailCore-Database-for-TrinityCore- (releases)
- **Release**: BalticCoreTDB12.0.1 (Feb 26, 2026)
- **Assets**: dev-enviroment.rar (1.78 GB) + LoreWalkerTDB.rar (196 MB)
- **CaptainCore**: User has CaptainCore as Discord friend, can request up-to-date TDB

### TIER 2: Notable KamiliaBlow Forks
| Fork | Build | Updated | Notes |
|------|-------|---------|-------|
| DemonicWow/RoleplayCore | 66527 | 2026-03-20 | Active |
| HordeXL/RoleplayCore | 64877 | 2026-03-19 | Active |
| wowshub/wowshubDragonEluna | 66220 | 2026-03-20 | +Eluna |
| rozalba-ng/NobleCore | 65727 | 2026-02-05 | Renamed |
| Olcadoom/RoleplayCore | 66337 | 2026-03-14 | Transmog author |
| Sicalicious/Draconic-WoW | 64502 | 2025-11-19 | DraconicWoW |

### TIER 3: Alternative Emulators (C#, not directly useful)
- CypherCore (421 stars) — C# emulator
- ForgedWoW/ForgedCore (33 stars) — CypherCore fork, has WowheadParser tool
- DeKaDeNcE/WoWCore — older, limited

### TIER 4: Community Hubs
- RetailCore Discord: discord.gg/qF5xPSR34d
- DraconicWoW Discord: discord.com/invite/EXhScSUG3h
- EmuDevs: app.emudevs.gg (TWW repack)
- EmuCoach: multi-expansion thread, RetailCore/BalticCore discussion
- OwnedCore: RetailCore repack announcements

### TIER 5: TC Ecosystem Tools (mostly already known)
- WowPacketParser (497 stars), ymir (75 stars), WPPSniffStorage
- BAndysc/WoWDatabaseEditor (531 stars) — SmartAI IDE
- Shauren/wow-tools, WowClientDB2MySQLTableGenerator
- MaxtorCoder/WDBXEditor2, MultiConverter
- Marlamin tools (wow.tools.local, DBC2CSV, Hotfixes)

### TIER 6: Data Infrastructure (wowdev org)
- WoWDBDefs (296 stars) — DB2 definitions, updated daily
- wow-listfile (192 stars) — CASC file listings
- TACTKeys — auto-synced encryption keys
- mdX7/ribbit_data, ngdp_data, tact_configs — all updated daily

### Firestorm / Pay-to-Play Analysis
- Firestorm: Largest retail private server (2,500-4,000 online), TWW 11.1.0
  - NOT TC-based — proprietary fork
  - Does NOT publish databases or source code
  - Represents years of manual scripting + sniffing
  - **Status**: Need further investigation for any public leaks, tools, or data
- Luntares: TWW + MoP, proprietary
- Key insight: "RetailCore and DraconicWow are playable but you sometimes hit brick walls with quest progression"

## 4. Key Strategic Insight — Lineage Discovery

```
TrinityCore/TrinityCore (upstream)
  └── KamiliaBlow/RoleplayCore (dominant public fork)
        ├── VoxCore84/VoxCore (US — we are a fork of Kamilia, not directly of TC)
        ├── Olcadoom/RoleplayCore (transmog system author)
        ├── Sicalicious/Draconic-WoW
        └── ... 12 more forks
```

This changes the migration strategy. Instead of:
> Clone fresh upstream TC → manually reapply everything (V1 spec)

We should consider:
> Rebase from KamiliaBlow (already at 66527) → cherry-pick our unique systems → layer BalticCoresTDB

## 5. VoxCore Custom Systems Inventory (verified from source)

### Custom Code (must preserve)
| System | Location | Lines | Status |
|--------|----------|-------|--------|
| sRoleplay singleton | src/server/game/RolePlay/ | 1,723 | ACTIVE |
| sCompanionMgr | src/server/game/Companion/ | 609 | IN PROGRESS |
| CreatureOutfit | src/server/game/Entities/Creature/CreatureOutfit.* | 100 | ACTIVE |
| RoleplayDatabase | src/server/database/Database/Implementation/Roleplay* | 124 | ACTIVE |
| Hoff utility | src/server/game/Hoff/ | 174 | ACTIVE |
| Craft system | src/server/game/Craft/ | 295 | ACTIVE |
| Custom scripts | src/server/scripts/Custom/ | 6,240 (26 files) | ACTIVE |
| cs_customnpc | src/server/scripts/Commands/cs_customnpc.cpp | 802 | ACTIVE |
| Eluna Lua scripts | runtime/lua_scripts/ | 921 (5 files) | ACTIVE |

### Custom Script Entrypoints (from custom_script_loader.cpp — 20 registered)
Need exact enumeration — Codex found 20, intake claimed 26.

### Custom DB Columns (verified 6, intake claimed 8)
| Column | Table | Database |
|--------|-------|----------|
| size | creature | world |
| size | gameobject | world |
| visibility | gameobject | world |
| OverrideGoldCost | npc_vendor | world |
| craftingModifiedStat1 | item_instance_modifiers | characters |
| craftingModifiedStat2 | item_instance_modifiers | characters |

Need to verify: are there really 2 more, or was the intake wrong?

### Modified TC Core Files (~55 total)
- RoleplayDatabase wiring: 10 files
- CreatureOutfit hooks: 7 files
- Roleplay singleton: 4 files
- Transmog (ARCHIVED): 9+ files
- Eluna `#ifdef ELUNA`: ~35 files
- RBAC.h: ~75 custom permissions
- worldserver.conf.dist: Roleplay config keys

### Deferred / Drop Candidates
| System | Location | Lines | Decision |
|--------|----------|-------|----------|
| DarkmoonIsland | src/server/scripts/DarkmoonIsland/ | 4,507 (15 files) | DEFER |
| CoreExtended | src/server/scripts/CoreExtended/ | 16,853 (9 files) | DROP — ArkCORE/Ashamane, known-broken |
| Old transmog | various (9+ files) | ~1,200 | DROP — use Olcadoom's from KamiliaBlow |

## 6. Pending Actions
- [x] Fetch KamiliaBlow remote and diff against upstream TC — DONE (377 files, 92K insertions)
- [x] Diff KamiliaBlow against VoxCore — DONE (92 commits behind, 378 ahead, 390 conflict files)
- [ ] Download BalticCoresTDB 12.0.1 (196 MB) and inspect
- [x] Search for Firestorm leaked/public data — DONE (see section 8)
- [ ] Ask CaptainCore (Discord friend) for up-to-date TDB
- [x] Enumerate exact custom script list — DONE (20 entrypoints, 23 unique src/ files)
- [x] Verify custom column count — DONE (6 confirmed, V1's "8" was wrong)
- [x] Write V2 intake with all verified data — DONE
- [x] Send V2 through ChatGPT architect — DONE (spec generated)
- [x] Re-run 5-round review cycle on V2 spec — DONE (FAIL: 2/3 Phase 1 PASS, 3 CRITICAL remaining)
- [x] Write V3 intake with surgical corrections — DONE (420 lines, all V2 failures fixed)
- [x] Send V3 through ChatGPT architect — DONE (spec: TRIAD-VOXCORE-TC-MIGRATION-V3, 501 lines)
- [ ] Re-run 5-round review cycle on V3 spec — IN PROGRESS
- [ ] Build 66527 data refresh: new wago CSVs, CASC extraction, hotfix repair

## 6a. V3 Corrections Applied (from V2 review failures)
- Corrected ALL file paths (TransmogrificationUtils → Entities/Player/, spell_dragonriding → Custom/, etc.)
- Roleplay_database.sql elevated to MANDATORY BLOCKING fix
- Security audit expanded to include runtime/lua_scripts/ (5 Lua files)
- 23 unique files enumerated with correct paths IN the spec body
- Client version verification gate added (Phase 0 precondition)
- Build bump scope expanded: ~30 files across wago/, tools/, scripts/, hotfix_audit/
- Merge abort procedure with `git merge --abort` added
- Security severity taxonomy defined (CRITICAL/HIGH/MEDIUM/INFO)
- Known unsafe SQL patterns stated upfront (npc_copy_command, RolePlay.cpp, 4 Lua scripts)
- Roleplay DB explicitly handled in Phase 6 (PRESERVE via snapshot/restore)
- Per-database refresh strategy clarified (auth=update, characters=fresh, world/hotfixes=recreate, roleplay=preserve)
- RBAC ranges corrected: 4 non-contiguous ranges (1002-1022, 1360-1589, 2004-2116, 3000-3012)
- CMake clean reconfigure mandated after merge
- All current tables verified InnoDB (--single-transaction safe, but verify as precondition)
- FunctionProcessor located (src/common/Utilities/)
- CoreExtended/DarkmoonIsland confirmed with exact paths and file counts

## 7. Build 66527 Requirements
- New wago CSVs (download from wago.tools)
- CASC extraction from retail client
- DBC2CSV runs for all DB2 tables
- Hotfix repair pipeline (same as session 143 for 66337)
- Update `wago_common.py` CURRENT_BUILD
- New extractors from TC master for map/vmap/mmap data

## 8. Firestorm / External Server Research (completed)

### Firestorm — DEAD END
- Only leak: WoD (6.2.3) from 2017, 10+ years old architecturally
- GitHub org (wow-firestorm): only macOS addon updater + website code
- No Legion, BFA, Shadowlands, Dragonflight, or TWW source/data leaked
- Current Firestorm (TWW 11.1.0) is proprietary, NOT TC-based

### High-Value External Data Sources

| Source | URL | Value | Notes |
|--------|-----|-------|-------|
| RetailCoreDB archive | github.com/qyh214/TrinityCore-Dragonflight-Databases | HIGH | Community standard TC world DB, older releases archived |
| DragonCore DB | github.com/TheGhostGroup/DragonCore (releases) | HIGH | TC derivative, Dragonflight 10.2.7 DB + data files |
| mdX7 massparse gists | TC issues #26299, #22848 | HIGH | Sniff-derived creature SQL through 9.0.2 |
| DJScias/WowheadParser | github.com/DJScias/WowheadParser | HIGH | Canonical Wowhead-to-SQL tool (C#) |
| DekkCore | github.com/devovh/Dragonflight_Dekk-Core | MOD-HIGH | Full DB at sql/full_DB for Dragonflight/Shadowlands |
| AshamaneCore ADB | github.com/AshamaneProject/AshamaneCore | MOD | Old-world zone spawns (Cata-Legion), TC-compatible |
| SimC dbc_extract | github.com/simulationcraft/simc | MOD | Python spell/item data extraction from DB2s |
| TACTSharp | github.com/wowdev/TACTSharp | MOD | Memory-mapped CASC, lower RAM than CascLib |

### Confirmed Non-Existent Publicly
- No Firestorm source beyond WoD 6.x
- No Warmane, Stormforge/Tauri, WoWCircle, Luntares source or DB
- No massparse data beyond 9.0.2 (Shadowlands launch)
- No standalone WPPSniffStorage repo
- No dedicated 12.x creature SQL dump on GitHub
- Pay-to-play servers (Firestorm, Luntares) keep everything proprietary

### Key Insight
**The publicly available 12.x data ecosystem consists of exactly 3 sources:**
1. TrinityCore official TDB 1200.26021
2. KamiliaBlow/RoleplayCore (massparsed 12.x data, quest POIs, locales)
3. BalticCoresTDB 12.0.1 (coreretail6, 196 MB)

Everything else is Dragonflight (10.x) or older. For 12.0.1 (Midnight), these 3 + your own sniffing/scraping are all that exist.
