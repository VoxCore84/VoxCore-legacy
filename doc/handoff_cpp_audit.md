# Handoff: C++ Custom Code Audit — Session 210

**Date**: 2026-03-22
**Commit**: `3274d30362` — `fix: resolve 11 HIGH severity bugs across custom C++ systems`
**Build**: x64-Debug, 725/725 targets, zero errors
**CMake preset configured**: `x64-Debug` at `out/build/x64-Debug/` (freshly configured this session)

---

## What Was Done

A full audit of all custom `.h` and `.cpp` files in VoxCore was performed using 4 parallel researcher agents scanning ~40 files across these areas:

1. **RolePlay/ + Hoff/** — `sRoleplay` singleton, utility class
2. **Companion/** — `sCompanionMgr` + CompanionAI + commands + scripts
3. **Custom scripts/** — display, effects, morphs, dragonriding, toys, wormholes, free_share, etc.
4. **CreatureOutfit + Craft + cs_customnpc** — outfit overlay, crafting system, `.cnpc` commands

### HIGH Severity Issues Fixed (11 total, all in commit `3274d30362`)

| # | File | Fix |
|---|------|-----|
| 1 | `RolePlay.cpp:1088-1112` | Removed 3 self-move-assignment UB lines (`std::move(cTemplate)` into same map slot the reference points to) |
| 2 | `RolePlay.cpp:1246-1248` | Added `if (!player) continue;` null check in `SaveNpcCreatureTemplateToDb` session broadcast loop |
| 3a | `Crafting.cpp:155-156` | Added `if (totalReagentWeigth == 0) return skillValue;` — prevents div-by-zero |
| 3b | `Crafting.cpp:46-47` | Added `if (craftingDifficulty == 0) return SPELL_FAILED_ERROR;` — prevents div-by-zero |
| 4 | `custom_effects_handler.h:43` + `.cpp` | Replaced raw `Unit* UnitPtr` with `ObjectGuid UnitGuid`, resolve via `ObjectAccessor::GetUnit()` at execute-time — prevents dangling pointer on 2s-delayed event |
| 5 | `free_share_scripts.cpp:403,449,502` | Added `if (!cId) return false;` after `extractKeyFromLink` in 3 NPC commands |
| 7 | `spell_dragonriding.cpp:75,99,125` | Added null check on `GetCaster()` before `->ToPlayer()` in 3 spell scripts |
| 8 | `custom_effects_commands.cpp` | Changed all 10 `Console::Yes` to `Console::No` — prevents crash from remote admin console |
| 9 | `CompanionAI.cpp:225-253` | Fixed ranged/caster oscillation — `AttackStart` only when victim changes, removed from else branch |
| 10 | `CompanionAI.cpp:374-375` | Added `UNIT_STATE_FOLLOW` guard + `ChaseAngle(M_PI)` to healer kite — stops MoveFollow spam every 500ms |
| 11 | `RolePlay.cpp:1088` | Changed un-tameable type from `0` (CREATURE_TYPE_NONE) to `CREATURE_TYPE_HUMANOID` |

### False Positive Dropped
- **SaveStaticTimeToDB** — the agent reported it deletes ALL `server_settings` rows, but the prepared statement already has `WHERE setting_name IN (...)`. Not an issue.

---

## WHAT THE NEXT TAB NEEDS TO DO

### 1. VERIFY THE FIXES (Priority)
Pull the latest commit and verify:
```
git log --oneline -1
# Should show: 3274d30362 fix: resolve 11 HIGH severity bugs across custom C++ systems
```
Then build to confirm it still compiles:
```
# Use _build_ps.ps1 or VS IDE
powershell -ExecutionPolicy Bypass -File _build_ps.ps1
```

### 2. MEDIUM Severity Issues to Fix (14 remaining)

**Performance (most impactful):**
| # | File | Line(s) | Issue |
|---|------|---------|-------|
| 13 | `RolePlay.h:122` | `GetCustomNpcContainer()` returns full `unordered_map` by value — should return `const&` |
| 14 | `cs_customnpc.cpp:325-331` + `RolePlay.cpp:783-789` | O(100K) linear scan of `sItemModifiedAppearanceStore` — use `sDB2Manager.GetItemModifiedAppearance(itemId, 0)` for O(1) |
| 15 | `RolePlay.h:156` | `_playerExtraDataStore` never cleaned on logout — unbounded memory growth |
| 26 | `RolePlay.cpp:318-323` | `CreatureSetModifyHistory` copies struct out, modifies copy, writes back — use reference |

**Correctness:**
| # | File | Line(s) | Issue |
|---|------|---------|-------|
| 16 | `RolePlay.cpp:702` | `std::string` passed to `%s` in `TC_LOG_DEBUG` — use `.c_str()` |
| 17 | `Crafting.cpp:114` | Secondary div-by-zero risk if `craftingDifficulty` from DB2 is 0 (already guarded by fix 3b, so this is now safe) |
| 18 | `custom_display_handler.cpp:68` | `m_item_slots.at(type)` can throw `std::out_of_range` — use `find()` |
| 19 | `free_share_scripts.cpp:291-308` | `HandleBarberCommand` accepts `featureMask` but hardcodes `0` — use `*featureMask` |
| 20 | `free_share_scripts.cpp:566-569` | Player login calls `LoadStaticTimeFromDB()` which broadcasts to ALL players — send only to new player |

**Companion gameplay:**
| # | File | Line(s) | Issue |
|---|------|---------|-------|
| 21 | `CompanionAI.cpp:190-207` | Tank/Melee call `MoveChase+AttackStart` every 500ms — guard with `if (me->GetVictim() != target)` |
| 22 | `CompanionAI.cpp:96-132` | `SelectAssistTarget` skips `IsValidAttackTarget()` check — could target immune/GM units |
| 23 | `CompanionAI.cpp:465-484` | `JustDied` erases from `state->active` while `DismissSquad` may iterate it |
| 24 | `CompanionMgr.cpp:167-182` | No duplicate companion check — same entry assignable to multiple slots (5x tank stacking) |
| 25 | `Hoff.cpp:7` | `GetTargetFollowPosition` doesn't null-check `ParentUnit` |

### 3. LOW Severity Issues (20+, optional)

Key items worth doing if time allows:
- **Unused code cleanup**: `UpdateFormationPositions()` never called, `spell3`/`cooldown3` fields dead, `EDungeonCategories`/`EDungeonGroups` enums dead, `Live_Acceptance_Test.cpp` empty stub
- **Performance nits**: triple hash lookups in `CreatureSetModel`, `std::max_element` lambdas take pairs by value (atomic refcount churn on `shared_ptr`)
- **Style**: duplicate `#include "Log.h"` in RolePlay.cpp, `};` after namespace close, typo `totalReagentWeigth`, typo `GetMarketLocationForPlayer` (should be Marker)
- **Duplicate code**: `IsReputationAchievement` function identical in `cs_maxachieve.cpp` and `cs_maxtitles.cpp`; creature-clone logic duplicated between `npc_copy_command.cpp` and `voxplacer_commands.cpp`

### 4. Build Environment Note
The x64-Debug CMake preset was freshly configured this session. The `_build_ps.ps1` script in the repo root handles MSVC environment setup + build. The old `build/` directory at repo root has a stale CMakeCache.txt from pre-migration — it can be deleted.

---

## Files Modified This Session
```
src/server/game/Craft/Crafting.cpp
src/server/game/RolePlay/RolePlay.cpp
src/server/scripts/Custom/Companion/CompanionAI.cpp
src/server/scripts/Custom/RolePlayFunction/Effect/custom_effects_commands.cpp
src/server/scripts/Custom/RolePlayFunction/Effect/custom_effects_handler.cpp
src/server/scripts/Custom/RolePlayFunction/Effect/custom_effects_handler.h
src/server/scripts/Custom/free_share_scripts.cpp
src/server/scripts/Custom/spell_dragonriding.cpp
```
