# RoleplayCore — Codex Instructions

## Project Overview
TrinityCore-based WoW private server targeting the **12.x / Midnight** client, specialized for **roleplay**.
Built on top of stock TrinityCore with custom systems (sRoleplay singleton, CreatureOutfit, .display/.effect/.cnpc commands).

## Build
- **Generator**: Ninja, **Compiler**: clang++ (Linux container)
- **Build type**: Debug
- **Build directory**: `out/build/x64-Debug/`
- **Build command**: `cmake --build out/build/x64-Debug --parallel 4`
- **Reconfigure**: already done by `setup.sh`
- **Key CMake options**: `SCRIPTS=static`, `ELUNA=ON`, `TOOLS=ON`

## Coding Conventions
- **C++ standard**: C++20 (structured bindings, `contains()`, `string_view`, `<span>`, etc.)
- **Header guards**: `#pragma once` for new files, keep existing `#ifndef` in stock TC files
- **Indent**: 4 spaces (see `.editorconfig`)
- **Max line length**: 160
- **Visibility**: `TC_GAME_API` on classes in `src/server/game/`
- **Singletons**: Static local instance, exposed via `sFoo` macro
- **Script pattern**: Inherit from `CommandScript`/`PlayerScript`/`WorldScript`/`SpellScript`/`AuraScript`
- **Script registration**: `void AddSC_<name>()` free function, registered in loader `.cpp`
- **Namespaces**: `RoleplayCore::` for display, `Noblegarden::` for effects
- **Includes**: `#include "..."` for TC headers, `#include <...>` for system

## Key File Locations
| File | Purpose |
|---|---|
| `src/server/game/Handlers/TransmogrificationHandler.cpp` | All CMSG_TRANSMOG_OUTFIT_* handlers |
| `src/server/game/Server/Packets/TransmogrificationPackets.h` | Packet class declarations |
| `src/server/game/Server/Packets/TransmogrificationPackets.cpp` | Read()/Write(), TransmogOutfitSlotToEquipSlot() |
| `src/server/game/Entities/Player/EquipmentSet.h` | EquipmentSetData struct |
| `src/server/game/Entities/Player/Player.h` | GetTransmogOutfitBySetID() declaration |
| `src/server/game/Entities/Player/Player.cpp` | _LoadTransmogOutfits, _SyncTransmogOutfitsToActivePlayerData, _SaveEquipmentSets |
| `src/server/game/Spells/SpellEffects.cpp` | EffectEquipTransmogOutfit (~line 6003) |
| `src/server/game/Entities/Player/CollectionMgr.cpp` | SendFavoriteAppearances, HasItemAppearance |
| `src/server/game/DataStores/DB2Stores.h` | sTransmogSetStore, sTransmogIllusionStore |
| `src/server/game/DataStores/DB2Structure.h` | TransmogSetEntry, TransmogSetItemEntry, TransmogIllusionEntry |
| `src/server/game/Entities/Object/Updates/UpdateFields.h` | UF::TransmogOutfitData/SlotData/DataInfo/SituationInfo/Metadata |
| `src/server/game/Miscellaneous/SharedDefines.h` | SPELL_EFFECT_EQUIP_TRANSMOG_OUTFIT=347 |
| `src/server/game/Entities/Item/Item.cpp` | ItemTransmogrificationSlots[], CanTransmogrifyItemWithItem() |
| `src/server/scripts/Custom/RolePlayFunction/Display/` | .display command system |
| `src/server/database/Database/Implementation/CharacterDatabase.cpp` | CHAR_SEL/INS/UPD/DEL_TRANSMOG_OUTFIT SQL |
