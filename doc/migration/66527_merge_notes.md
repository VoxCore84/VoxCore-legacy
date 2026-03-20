# Merge Notes — Build 66527 Migration

## Summary
- **Branch**: `migration/tc-66527-merge-v3`
- **Merge commit**: `01783f4822`
- **Source**: 92 commits from KamiliaBlow/RoleplayCore (upstream)
- **Stats**: 187 files changed, 144,252 insertions(+), 2,697 deletions(-)
- **Build**: worldserver.exe links cleanly (13/13 targets)

## Conflict Resolution Log (22 conflicts)

### TransmogrificationHandler.cpp — REPLACED
- VoxCore's 1846-line version had 98 build errors referencing custom packet members (`PayloadSize`, `PayloadPreviewHex`, `ParseSuccess`, `ParseError`, `DiagnosticReadTrace`, `Set`, `SetID`, `Guid`) not present in upstream packet classes
- Replaced entirely with upstream's 967-line version
- Added `FinalizeTransmogBridgePendingOutfit()` empty stub (called from WorldSession.cpp:570 and ChatHandler.cpp:682)
- VoxCore transmog outfit system is archived/reimplemented externally — upstream's Olcadoom-based transmog replaces it

### TransmogrificationPackets.h/.cpp — MERGED
- Accepted upstream version, then added back VoxCore-custom `AccountTransmogSetFavoritesUpdate` packet class
- Required by `CollectionMgr::SetTransmogSetIsFavorite()` and `SendTransmogSetFavorites()` (opcode `SMSG_ACCOUNT_TRANSMOG_SET_FAVORITES_UPDATE`)

### Player.h — DEDUP
- Merge created duplicate `GetEquipmentSets()` declaration (line 2535 and 3078)
- Removed second occurrence

### Spell.h — DEDUP
- Merge created duplicate `EffectEquipTransmogOutfit()` declaration (line 444 and 454)
- Removed second occurrence

### SpellEffects.cpp — DEDUP
- Merge created two `EffectEquipTransmogOutfit()` function bodies
- VoxCore version (line 6004-6031) used custom functions (`GetTransmogOutfitBySetID`, `SetActiveTransmogOutfitID`)
- Upstream version (line 6460) uses standard `GetEquipmentSets()` lookup
- Removed VoxCore version, kept upstream

### WorldSession.h — CLEANUP
- Removed dead forward declaration: `class TransmogOutfitUpdateSituations;`
- Removed dead handler declaration: `HandleTransmogOutfitUpdateSituations()` (not registered in Opcodes.cpp)

### Other 16 conflicts
- Resolved via standard merge conflict resolution (accept upstream for new code, keep VoxCore for custom systems)

## Build Issues Encountered

### PCH Stale State
- Old PCH files from March 7 caused "different version of compiler" errors
- Deleting `.pch` files without clearing `.ninja_log` and `.ninja_deps` caused dependency graph corruption
- **Fix**: Delete all three (`.pch` + `.ninja_log` + `.ninja_deps`) so ninja properly schedules PCH before source files

### Build Invocation from Bash
- `ninja` not in PATH from Claude Code's bash shell
- Direct ninja/cmake calls lack VS environment (missing system headers)
- **Working pattern**: Batch file calling `vcvarsall.bat x64`, invoked via `powershell.exe -Command "Start-Process cmd.exe -ArgumentList '/c batch.bat' -Wait -NoNewWindow"`, output redirected to file inside batch

## Merge Abort History
_No aborts — merge succeeded on first attempt._
