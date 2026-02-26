# Task: Review & Validate 12.x Transmog Outfit System

## Your Role
You are a **second set of eyes** reviewing the transmog outfit implementation for a TrinityCore-based WoW server targeting the **12.x / Midnight** client. The primary developer (Claude Code) has been iterating on fixes. Your job is to:

1. **Validate** the current slot mapping against the packet evidence
2. **Identify** any remaining bugs or logical errors
3. **Suggest** fixes if you find problems
4. **Do NOT blindly trust** the existing code or comments — verify everything against the raw packet data

## Background: What Happened

The transmog outfit system lets players save and apply transmog appearances via the Wardrobe UI. The 12.x client sends `CMSG_TRANSMOG_OUTFIT_UPDATE_SLOTS` packets containing slot entries, and the server must map those to the correct equipment slots.

### Timeline of Issues

1. **Stock TrinityCore** had a 0-based slot mapping (0=Head, 1=Shoulder, 2=SecShoulder, 3=Back, 4=Chest...). This was inherited from an older client version.

2. **First fix attempt** swapped slots 3/4 (Chest before Back) and inserted a new slot 6, shifting everything after. Result: items floated in wrong positions.

3. **Second fix attempt** (current) changed to 1-based mapping after analyzing raw packet hex data. The packet data shows the client starts slot indices at 1, not 0.

4. **SetVisibleItemSlot ItemID issue**: An earlier attempt forced `ItemID = base item entry` when transmog was active (theory: base item for skeleton, IMAID for visual). This was wrong — it prevented transmog visuals from showing. Reverted to stock TC behavior: `GetVisibleEntry()` returns the transmog source's ItemID.

5. **DB2 data was missing**: The server's `ItemModifiedAppearance.db2` and `ItemAppearance.db2` files are WDC5 format with data (156K and 63K records respectively). Additionally, 218K+ rows were imported into the hotfixes DB tables from Wago CSVs.

## Current State (Pending Test)

The latest changes have been made but **NOT yet tested**. The user is rebuilding now.

### The Corrected 1-Based Slot Mapping

Evidence from **raw packet hex dumps** (multiple packets analyzed):

| Byte 15 (SlotIndex) | IMAID in packet | Resolved Item | Item InventoryType | Slot Meaning |
|---|---|---|---|---|
| 1 | 77344 | Hidden Helm | Head (1) | **HEAD** |
| 1 | 184599 | Lionguard Greathelm | Head (1) | **HEAD** |
| 1 | 301643 | South Guard's Facemask | Head (1) | **HEAD** |
| 2 | 114080 | Monster Mantle | Shoulder (3) | **SHOULDER** |
| 2 | 184602 | Lionguard Pauldrons | Shoulder (3) | **SHOULDER** |
| 2 | 301644 | South Guard's Mantle | Shoulder (3) | **SHOULDER** |
| 3 | 114080 | Monster Mantle | Shoulder (3) | **SEC SHOULDER** |
| 3 | 184602 | Lionguard Pauldrons | Shoulder (3) | **SEC SHOULDER** |
| 3 | 301644 | South Guard's Mantle | Shoulder (3) | **SEC SHOULDER** |
| 4 | 108785 | Hidden Cloak | Back (16) | **BACK** |
| 4 | 77345 | Hidden Cloak | Back (16) | **BACK** |
| 4 | 302942 | Shawl of Collapsed Star | Back (16) | **BACK** |
| 5 | 184604 | Lionguard Chestplate | Chest (5) | **CHEST** |
| 5 | 184605 | Lionguard Chestplate (alt) | Chest (5) | **CHEST** |
| 5 | 302550 | Carrot Dunecloth Vest | Chest (5) | **CHEST** |
| 7 | 83203 | Hidden Tabard | InvType 19 (Tabard) | **TABARD** |

**No slot 0 ever appears in any packet.** Slot indices start at 1.

Slots 8-16 were not captured in the hex preview truncation but follow the same pattern by elimination.

### Current Mapping Code

**File: `src/server/game/Server/Packets/TransmogrificationPackets.cpp` (line 72)**
```cpp
uint8 TransmogOutfitSlotToEquipSlot(uint8 transmogSlot)
{
    switch (transmogSlot)
    {
        case 1:  return EQUIPMENT_SLOT_HEAD;            // 0
        case 2:  return EQUIPMENT_SLOT_SHOULDERS;       // 2
        case 3:  return TRANSMOG_SECONDARY_SHOULDER_SLOT; // 20
        case 4:  return EQUIPMENT_SLOT_BACK;            // 14
        case 5:  return EQUIPMENT_SLOT_CHEST;           // 4
        case 6:  return EQUIPMENT_SLOT_END;             // new 12.x slot — skipped
        case 7:  return EQUIPMENT_SLOT_TABARD;          // 18
        case 8:  return EQUIPMENT_SLOT_BODY;            // 3
        case 9:  return EQUIPMENT_SLOT_WRISTS;          // 8
        case 10: return EQUIPMENT_SLOT_HANDS;           // 9
        case 11: return EQUIPMENT_SLOT_WAIST;           // 5
        case 12: return EQUIPMENT_SLOT_LEGS;            // 6
        case 13: return EQUIPMENT_SLOT_FEET;            // 7
        case 14: return EQUIPMENT_SLOT_MAINHAND;        // 15
        case 15: return EQUIPMENT_SLOT_OFFHAND;         // 16
        case 16: return EQUIPMENT_SLOT_RANGED;          // 17
        default: return EQUIPMENT_SLOT_END;
    }
}
```

**File: `src/server/game/Entities/Player/Player.cpp` (line ~18063)**
```cpp
// _SyncTransmogOutfitsToActivePlayerData() — sends outfits back to client
static constexpr TransmogSlotMapping slotMap[] = {
    {  1,  0 }, // Head            -> EQUIPMENT_SLOT_HEAD
    {  2,  2 }, // ShoulderRight   -> EQUIPMENT_SLOT_SHOULDERS
    {  3,  2 }, // ShoulderLeft    -> EQUIPMENT_SLOT_SHOULDERS (secondary)
    {  4, 14 }, // Back            -> EQUIPMENT_SLOT_BACK
    {  5,  4 }, // Chest           -> EQUIPMENT_SLOT_CHEST
    {  7, 18 }, // Tabard          -> EQUIPMENT_SLOT_TABARD
    {  8,  3 }, // Body (Shirt)    -> EQUIPMENT_SLOT_BODY
    {  9,  8 }, // Wrist           -> EQUIPMENT_SLOT_WRISTS
    { 10,  9 }, // Hand            -> EQUIPMENT_SLOT_HANDS
    { 11,  5 }, // Waist           -> EQUIPMENT_SLOT_WAIST
    { 12,  6 }, // Legs            -> EQUIPMENT_SLOT_LEGS
    { 13,  7 }, // Feet            -> EQUIPMENT_SLOT_FEET
    { 14, 15 }, // WeaponMainHand  -> EQUIPMENT_SLOT_MAINHAND
    { 15, 16 }, // WeaponOffHand   -> EQUIPMENT_SLOT_OFFHAND
    { 16, 17 }, // WeaponRanged    -> EQUIPMENT_SLOT_RANGED
};
```

### Equipment Slot Constants (for reference)
```cpp
EQUIPMENT_SLOT_HEAD      = 0
EQUIPMENT_SLOT_NECK      = 1
EQUIPMENT_SLOT_SHOULDERS = 2
EQUIPMENT_SLOT_BODY      = 3   // Shirt
EQUIPMENT_SLOT_CHEST     = 4
EQUIPMENT_SLOT_WAIST     = 5
EQUIPMENT_SLOT_LEGS      = 6
EQUIPMENT_SLOT_FEET      = 7
EQUIPMENT_SLOT_WRISTS    = 8
EQUIPMENT_SLOT_HANDS     = 9
EQUIPMENT_SLOT_FINGER1   = 10
EQUIPMENT_SLOT_FINGER2   = 11
EQUIPMENT_SLOT_TRINKET1  = 12
EQUIPMENT_SLOT_TRINKET2  = 13
EQUIPMENT_SLOT_BACK      = 14
EQUIPMENT_SLOT_MAINHAND  = 15
EQUIPMENT_SLOT_OFFHAND   = 16
EQUIPMENT_SLOT_RANGED    = 17
EQUIPMENT_SLOT_TABARD    = 18
EQUIPMENT_SLOT_END       = 19
TRANSMOG_SECONDARY_SHOULDER_SLOT = 20  // sentinel, not a real equip slot
```

## What To Validate

### 1. Slot Mapping Correctness (CRITICAL)

Verify the 1-based mapping against ALL available packet data. Key questions:
- Is the mapping for slots 8-16 correct? We only have direct packet evidence for 1-5 and 7.
- Could slots 8-16 follow a different order than what we assumed (sequential Body, Wrists, Hands, Waist, Legs, Feet, MH, OH, Ranged)?
- The 15-slot packet had `slotCount=15` but the hex only showed entries with slots 1-7 in the preview. The 120-slot and 255-slot packets also existed — are these valid or malformed?

### 2. SetVisibleItemSlot Field Values

Current code sets:
```cpp
ItemID                          = GetVisibleEntry(this)    // transmog source's item entry
SecondaryItemModifiedAppearanceID = GetVisibleSecondaryModifiedAppearanceId(this)
ItemAppearanceModID             = GetVisibleAppearanceModId(this)
ItemVisual                      = GetVisibleItemVisual(this)
ItemModifiedAppearanceID        = GetVisibleModifiedAppearanceId(this)
HasTransmog                     = (transmogAppearance != 0)
HasIllusion                     = (illusionEnchant != 0)
Field_18                        = displayType from ItemAppearance DB2
```

Questions:
- Is `Field_18 = displayType` correct? Or should it be something else (InventoryType override? Always 0?)?
- Should `HasTransmog` and `HasIllusion` be set at all? Stock TC never sets them. Maybe the client doesn't expect them and they cause rendering issues?
- Is `ConditionalItemAppearanceID` (never set, always 0) needed for anything?

### 3. The "unknown transmog set id" Rejection

Log shows:
```
CMSG_TRANSMOG_OUTFIT_UPDATE_SLOTS rejected: unknown transmog set id 1
CMSG_TRANSMOG_OUTFIT_UPDATE_SITUATIONS rejected: unknown transmog set id 1
```

This happens when `GetTransmogOutfitBySetID(1)` returns null. The function searches `_equipmentSets` for a TRANSMOG type entry with matching SetID. Possible causes:
- The outfit was saved under the old (wrong) slot mapping and the data is now incompatible
- The outfit wasn't loaded from DB on login
- The outfit was deleted/corrupted

The packets with `slotCount=255` and `slotCount=120` seem abnormal — a normal outfit has 15-16 slots max. Could these be wardrobe/collection updates that use a different packet format?

### 4. Data Flow Integrity

Trace the full path:
1. Client sends `CMSG_TRANSMOG_OUTFIT_UPDATE_SLOTS` with 16-byte entries
2. Each entry has `SlotIndex` at byte 15 (1-based)
3. `TransmogOutfitSlotToEquipSlot()` maps to server equipment slot
4. `Set.Appearances[equipSlot] = AppearanceID` stores the IMAID
5. `IgnoreMask` is built from unset slots: `if (!Set.Appearances[slot]) IgnoreMask |= (1u << slot)`
6. Handler calls `ApplyTransmogOutfitToPlayer()` which iterates equipment slots, sets item modifiers, calls `SetVisibleItemSlot()`
7. `_SyncTransmogOutfitsToActivePlayerData()` sends outfit data back to client using inverse mapping

Verify there are no off-by-one errors or missing slots in this chain.

### 5. IgnoreMask Bits

`IgnoreMask` uses equipment slot indices as bit positions. With the 1-based mapping, verify:
- Slots that the client sends data for correctly clear their IgnoreMask bit
- Slots the client doesn't send (slot 0, slot 6) correctly remain in IgnoreMask
- The mask doesn't accidentally ignore valid slots

## Key Files to Read

| File | Lines | What |
|------|-------|------|
| `src/server/game/Server/Packets/TransmogrificationPackets.cpp` | 72-98 | `TransmogOutfitSlotToEquipSlot()` — the mapping function |
| `src/server/game/Server/Packets/TransmogrificationPackets.cpp` | 363-454 | `TransmogOutfitUpdateSlots::Read()` — packet parsing |
| `src/server/game/Entities/Player/Player.cpp` | 12138-12197 | `SetVisibleItemSlot()` — update field setter |
| `src/server/game/Entities/Player/Player.cpp` | ~18023-18102 | `_SyncTransmogOutfitsToActivePlayerData()` — outfit sync |
| `src/server/game/Entities/Player/TransmogrificationUtils.cpp` | 1-119 | `ApplyTransmogOutfitToPlayer()` — outfit application |
| `src/server/game/Handlers/TransmogrificationHandler.cpp` | 553-595 | `HandleTransmogOutfitUpdateSlots()` — handler |
| `src/server/game/Entities/Player/EquipmentSet.h` | 54-72 | `EquipmentSetData` struct |
| `src/server/game/Entities/Object/Updates/UpdateFields.h` | 255-271 | `VisibleItem` struct |
| `src/server/game/Entities/Object/Updates/UpdateFields.cpp` | 877-943 | `VisibleItem` serialization |
| `src/server/game/Entities/Item/Item.cpp` | 2585-2649 | `GetVisibleEntry()` and related functions |

## Raw Packet Hex Data (for independent verification)

### 15-slot packet (first successful outfit apply)
```
Full preview (128 bytes from offset 0):
010000000F00000003A6140798C40420FCFD0000000000000000
17D102000100000000000000000001   <- entry: appear=184599 slot=1
1AD102000100000000000000000002   <- entry: appear=184602 slot=2
1AD102000100000000000000000003   <- entry: appear=184602 slot=3
212E01000300000000000000000004   <- entry: appear=77345  slot=4
1DD102000100000000000000000005   <- entry: appear=184605 slot=5
03450100030000000000000000000?   <- entry: appear=83203  slot=7
29D102000100                     <- (truncated at 128 bytes)
```

Entry wire format (16 bytes each):
```
Byte  0: 0x00 (padding)
Bytes 1-4: AppearanceID (uint32 LE)
Byte  5: Flags
Bytes 6-14: reserved/zero
Byte  15: SlotIndex
```

### 255-slot packet (rejected — "unknown transmog set id 1")
```
Full preview:
01000000FF00000003A6140798C40420A0A10000000000000000
202E01000300000000000000000001   <- appear=77344  slot=1 (Hidden Helm)
A0BD01000300000000000000000002   <- appear=114080 slot=2 (Monster Mantle)
A0BD01000300000000000000000003   <- appear=114080 slot=3 (Monster Mantle)
F1A801000300000000000000000004   <- appear=108785 slot=4 (Hidden Cloak)
1CD102000100000000000000000005   <- appear=184604 slot=5 (Lionguard Chestplate)
034501000300000000000000000007   <- appear=83203  slot=7 (Hidden Tabard)
28D102000100                     <- (truncated)
```

### 120-slot packet (successful apply)
```
Full preview:
010000007800000003A6140798C40420B8B80000000000000000
4B9A04000100000000000000000001   <- appear=301643 slot=1 (South Guard's Facemask, Head)
4C9A04000100000000000000000002   <- appear=301644 slot=2 (South Guard's Mantle, Shoulder)
4C9A04000100000000000000000003   <- appear=301644 slot=3 (South Guard's Mantle, SecShoulder)
5E9F04000100000000000000000004   <- appear=302942 slot=4 (Shawl, Back)
D69D04000100000000000000000005   <- appear=302550 slot=5 (Dunecloth Vest, Chest)
109A04000100000000000000000007   <- appear=301584 slot=7 (Mageweave Vestments, Chest InvType)
034501000100                     <- (truncated)
```

## Acceptance Criteria

1. Transmogged items render at the correct skeleton attachment points (no floating)
2. The slot mapping correctly maps ALL 12.x client transmog slots to server equipment slots
3. No regressions — non-transmogged items render correctly
4. Outfit save/load works (SetEquipmentSet -> DB -> _LoadTransmogOutfits -> Sync)
5. `IgnoreMask` correctly identifies slots without appearances
6. Secondary shoulder appearance is handled separately (TRANSMOG_SECONDARY_SHOULDER_SLOT sentinel)

## Build & Test

- **Build type**: RelWithDebInfo (or Debug)
- **Build command**: Build in Visual Studio 2022 (don't use ninja from CLI)
- **CMake presets**: `x64-Debug` and `x64-RelWithDebInfo`
- **Key CMake options**: `SCRIPTS=static`, `ELUNA=ON`, `TOOLS=ON`
- **C++ standard**: C++20
- **Test**: Start worldserver, log in, open Transmog NPC, apply outfit, observe character model

## Coding Conventions

- 4 spaces indent, max 160 chars per line
- `#pragma once` for new headers
- `TC_GAME_API` on game classes
- `#include "..."` for TC headers, `#include <...>` for system
- Use `TC_LOG_DEBUG("network.opcode.transmog", ...)` for transmog debug logging
