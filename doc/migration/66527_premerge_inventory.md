# Pre-Merge Inventory — Build 66527 Migration

## Branch State
- **Migration branch**: `migration/tc-66527-merge-v3`
- **Base commit**: `dd6ad436f55358a7348cdd8e80a09b3bd540c969` (master)
- **Upstream remote**: `https://github.com/KamiliaBlow/RoleplayCore.git`
- **Ahead/Behind**: 379 ahead, 92 behind upstream/master
- **Target commit**: `bac150b8bc` ("Core: Updated allowed build to 12.0.1.66527")
- **Date**: 2026-03-20

## Client Build
- **Path**: `C:\WoW\.build.info`
- **Version**: 12.0.1.66527 (confirmed)
- **CASC extraction**: Ready (no fallback needed)

## Storage Engines
- auth: all InnoDB
- characters: all InnoDB
- hotfixes: all InnoDB
- roleplay: all InnoDB
- **world: 7 MyISAM tables** (access_requirement, achievement_dbc, achievement_reward, creature_template_sparring, player_factionchange_items, player_racestats, scrapping_loot_template)
- **Snapshot mode**: `--lock-all-tables` (not --single-transaction)

## VoxCore-Unique Source Files (24 verified)

| # | File | Path | Status |
|---|------|------|--------|
| 1 | CompanionDefines.h | src/server/game/Companion/ | PRESERVE |
| 2 | CompanionMgr.cpp | src/server/game/Companion/ | PRESERVE |
| 3 | CompanionMgr.h | src/server/game/Companion/ | PRESERVE |
| 4 | CompanionAI.cpp | src/server/scripts/Custom/Companion/ | PRESERVE |
| 5 | CompanionAI.h | src/server/scripts/Custom/Companion/ | PRESERVE |
| 6 | companion_commands.cpp | src/server/scripts/Custom/Companion/ | PRESERVE |
| 7 | companion_scripts.cpp | src/server/scripts/Custom/Companion/ | PRESERVE |
| 8 | TransmogrificationUtils.cpp | src/server/game/Entities/Player/ | DROP |
| 9 | TransmogrificationUtils.h | src/server/game/Entities/Player/ | DROP |
| 10 | TransmogOutfitSystem.md | src/server/game/Handlers/ | DROP |
| 11 | creature_codex_sniffer.cpp | src/server/scripts/Custom/ | PRESERVE |
| 12 | cs_creature_codex.cpp | src/server/scripts/Custom/ | PRESERVE |
| 13 | cs_maxachieve.cpp | src/server/scripts/Custom/ | PRESERVE |
| 14 | cs_maxrep.cpp | src/server/scripts/Custom/ | PRESERVE |
| 15 | cs_maxtitles.cpp | src/server/scripts/Custom/ | PRESERVE |
| 16 | npc_copy_command.cpp | src/server/scripts/Custom/ | PRESERVE (audit) |
| 17 | player_morph_scripts.cpp | src/server/scripts/Custom/ | PRESERVE |
| 18 | spell_arcane_waygate.cpp | src/server/scripts/Custom/ | PRESERVE |
| 19 | spell_clear_transmog.cpp | src/server/scripts/Custom/ | PRESERVE |
| 20 | spell_dragonriding.cpp | src/server/scripts/Custom/ | RECONCILE |
| 21 | spell_wormhole_generators.cpp | src/server/scripts/Custom/ | PRESERVE |
| 22 | voxplacer_commands.cpp | src/server/scripts/Custom/ | PRESERVE |
| 23 | Live_Acceptance_Test.cpp | src/server/scripts/Custom/ | PRESERVE |
| 24 | CMakeLists.txt | src/server/scripts/Custom/ | RECONCILE |

Note: custom_script_loader.cpp is shared ancestry (exists in both repos), tracked separately as RECONCILE.

## Upstream Dragonriding/Flying Changes (from 92 commits)
- `a21272fc4d` — Core/Spell - Druid advfly support part 1
- `198e3f4cc4` — Core/Spell - improve advfly
- `96d5f705fd` — Core/Spell - Druid advfly support part 1 (duplicate?)
- `725fe2233f` — Core/Spell - improve advfly (duplicate?)
- `6fd4204228` — misc fly changes
- `595a689334` — AdvFlight fix 3
- `a52e8af6c0` — Update spell_dragonriding.cpp

These touch spell_dragonriding.cpp and potentially Player.cpp/SpellMgr files. Must be reconciled additively.

## Known Implementation Notes (from V3 review — accepted with fixes)
1. **CompanionAI path**: spec says game/Companion/ but actual is scripts/Custom/Companion/ — use actual
2. **RolePlay.cpp:716,1396**: NOT injection issues — 716 is static SQL, 1396 uses prepared stmt. Remove from audit hotspot list
3. **Roleplay_database.sql content**: Reverse-engineer from live DB via `mysqldump roleplay --no-data`; use `CREATE TABLE IF NOT EXISTS` for idempotency
4. **Roleplay DB Phase 5 ordering**: Base file is idempotent, applied first to establish schema for fresh installs; snapshot restore overlays on top
5. **sql/RoleplayCore/ ordering**: Apply files in alphabetical/numbered order as they appear in the directory
6. **Phase numbering**: Follow Section 8 implementation order (Phase 5 = DB refresh, Phase 6 = security audit)
