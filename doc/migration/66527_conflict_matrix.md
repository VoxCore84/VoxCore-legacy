# Conflict Matrix — Build 66527 Migration

## Classification Key
- **PRESERVE**: VoxCore-only file, keep as-is
- **DROP**: Remove after merge
- **RECONCILE**: Exists in both repos, manual merge needed
- **ACCEPT-UPSTREAM**: Take upstream version

## High-Risk Shared Files

| File | Classification | Priority | Notes |
|------|---------------|----------|-------|
| DatabaseEnv* | RECONCILE | 1-CRITICAL | DB initialization |
| DatabaseLoader* | RECONCILE | 1-CRITICAL | DB loading |
| DBUpdater.cpp | RECONCILE | 1-CRITICAL | Roleplay base path |
| RoleplayDatabase.cpp/.h | RECONCILE | 1-CRITICAL | 5th DB integration |
| Main.cpp | RECONCILE | 1-CRITICAL | Startup sequence |
| World.cpp | RECONCILE | 2-HIGH | Init hooks |
| ObjectMgr.cpp/.h | RECONCILE | 2-HIGH | Load hooks |
| Creature.cpp/.h | RECONCILE | 2-HIGH | CreatureOutfit hooks |
| Player.cpp/.h | RECONCILE | 2-HIGH | Custom hooks + flying |
| DB2LoadInfo.h | RECONCILE | 3-MEDIUM | Additive structures |
| DB2Stores.cpp/.h | RECONCILE | 3-MEDIUM | Additive stores |
| DB2Structure.h | RECONCILE | 3-MEDIUM | Additive structures |
| RBAC.h | RECONCILE | 3-MEDIUM | 4 custom ranges |
| worldserver.conf.dist | RECONCILE | 3-MEDIUM | Custom config keys |
| custom_script_loader.cpp | RECONCILE | 2-HIGH | Registration entry point |
| Custom/CMakeLists.txt | RECONCILE | 3-MEDIUM | Custom build config |
| spell_dragonriding.cpp | RECONCILE | 2-HIGH | Skyriding merge |
| CreatureOutfit.cpp/.h | RECONCILE | 3-MEDIUM | Shared ancestry |
| FunctionProcessor.cpp/.h | RECONCILE | 4-LOW | Shared utility |

## Drop Targets

| File/Dir | Classification | Notes |
|----------|---------------|-------|
| TransmogrificationUtils.cpp/.h | DROP | Legacy transmog (Entities/Player/) |
| TransmogOutfitSystem.md | DROP | Obsolete doc (Handlers/) |
| CoreExtended/ | DROP | ArkCORE/Ashamane, 9 files |
| DarkmoonIsland/ | DROP | Defer, 15 files |

_Updated as conflicts are discovered during merge._
