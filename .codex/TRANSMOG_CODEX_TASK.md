# Transmog Outfit System — Codex Task

## Branch
Create a branch named `codex/transmog-outfit-fixes` from `master`.

## Context
The 12.x / Midnight WoW client has a wardrobe outfit system that lets players save, rename, re-icon, and equip named transmog outfits via the transmogrifier NPC UI. Our server has basic implementations of all four CMSG_TRANSMOG_OUTFIT_* handlers, but there are confirmed bugs and missing features. This task addresses the **high-priority fixes** that affect actual gameplay.

---

## Task 1: Fix Secondary Shoulder Slot Mapping (BUG — Critical)

### Problem
The bug exists in **two locations**:

**Location A — Parser (`TransmogrificationPackets.cpp`):**
In `TransmogOutfitUpdateSlots::Read()`, lines 554-556 contain:
```cpp
uint8 transmogSlot = slot.GetSlotIndex();
uint8 equipSlot = TransmogOutfitSlotToEquipSlot(transmogSlot);
if (equipSlot < EQUIPMENT_SLOT_END)
    Set.Appearances[equipSlot] = int32(slot.AppearanceID);
```
When transmogSlot is 2 (ShoulderLeft), `TransmogOutfitSlotToEquipSlot` returns `EQUIPMENT_SLOT_SHOULDERS` (same as slot 1 — ShoulderRight). This means:
- Slot 1's shoulder appearance is overwritten by slot 2's appearance
- The secondary shoulder appearance is never stored in `SecondaryShoulderApparanceID`

Note: The source has a `// BUG` comment on this in the switch statement (line ~311-319). The case 2 currently returns `EQUIPMENT_SLOT_SHOULDERS` when it should return the sentinel.

**Location B — Handler (`TransmogrificationHandler.cpp`):**
If the parser is fixed to return a sentinel for slot 2, the handler loops that read `Set.Appearances[]` also need to handle the sentinel — currently they'd try to index `Appearances[20]` which is out of bounds.

### Expected Behavior
When a slot entry maps to transmogSlot 2 (ShoulderLeft), the appearance should be stored in `set.SecondaryShoulderApparanceID` (yes, the typo "Apparance" is intentional — it matches the existing field name in `EquipmentSet.h`) and `set.SecondaryShoulderSlot` should be set to `2`.

### Where to Fix

**Fix A — TransmogrificationPackets.cpp:** Change `TransmogOutfitSlotToEquipSlot()` case 2:
```cpp
case 2:  return EQUIPMENT_SLOT_END + 1; // secondary shoulder sentinel
```
Then in `TransmogOutfitUpdateSlots::Read()`, replace the simple `if (equipSlot < EQUIPMENT_SLOT_END)` block:
```cpp
uint8 transmogSlot = slot.GetSlotIndex();
uint8 equipSlot = TransmogOutfitSlotToEquipSlot(transmogSlot);
if (equipSlot == EQUIPMENT_SLOT_END + 1) // secondary shoulder sentinel
{
    Set.SecondaryShoulderApparanceID = int32(slot.AppearanceID);
    Set.SecondaryShoulderSlot = 2;
}
else if (equipSlot < EQUIPMENT_SLOT_END)
{
    Set.Appearances[equipSlot] = int32(slot.AppearanceID);
}
```

**Fix B — TransmogrificationHandler.cpp:** Apply the same sentinel check in `HandleTransmogOutfitNew()` and `HandleTransmogOutfitUpdateSlots()` wherever slot entries are applied to `set.Appearances[]`.

### Verification
After the fix, `_SyncTransmogOutfitsToActivePlayerData()` in `Player.cpp` already reads `SecondaryShoulderApparanceID` when syncing slot 2 to the client, so the left shoulder will display correctly.

### Files to Modify
- `src/server/game/Server/Packets/TransmogrificationPackets.cpp` — fix the switch case AND the parser loop
- `src/server/game/Handlers/TransmogrificationHandler.cpp` — fix handler loops

### Sentinel Constant
Currently there is NO named constant for the sentinel. Define one in `TransmogrificationPackets.h` (in the `WorldPackets::Transmogrification` namespace) so both the parser and handler can use it:
```cpp
constexpr uint8 TRANSMOG_SECONDARY_SHOULDER_SLOT = EQUIPMENT_SLOT_END + 1;
```
Then include `TransmogrificationPackets.h` in the handler (it's already included).

---

## Task 2: Fix .display ResetItem Missing SPEC_5 (BUG — Medium)

### Problem
In `src/server/scripts/Custom/RolePlayFunction/Display/custom_display_handler.cpp`, `DisplayHandler::ResetItem()` clears transmog modifiers for SPEC_1 through SPEC_4 but misses SPEC_5. The 12.x client has 5 spec slots.

### Current Code (approximate)
```cpp
item->SetModifier(ITEM_MODIFIER_TRANSMOG_APPEARANCE_SPEC_1, 0);
item->SetModifier(ITEM_MODIFIER_TRANSMOG_APPEARANCE_SPEC_2, 0);
item->SetModifier(ITEM_MODIFIER_TRANSMOG_APPEARANCE_SPEC_3, 0);
item->SetModifier(ITEM_MODIFIER_TRANSMOG_APPEARANCE_SPEC_4, 0);
// Missing: SPEC_5
```

### Fix
Add the SPEC_5 modifiers. The enum values to clear are:
- `ITEM_MODIFIER_TRANSMOG_APPEARANCE_SPEC_5`
- `ITEM_MODIFIER_TRANSMOG_SECONDARY_APPEARANCE_SPEC_5`

Look at how `HandleTransmogrifyItems` in `TransmogrificationHandler.cpp` handles the SPEC_5 case for reference — it was already updated for 12.x.

Also check `ApplyModifiedAppearance()` in the same file — if it only sets SPEC_1-4, add SPEC_5 there too.

### Files to Modify
- `src/server/scripts/Custom/RolePlayFunction/Display/custom_display_handler.cpp`

---

## Task 3: Implement Situation Persistence (FEATURE — Low Priority)

### Problem
`HandleTransmogOutfitUpdateSituations()` in `TransmogrificationHandler.cpp` currently parses the situation entries and sends an ACK response, but the data is **discarded**. There's a TODO comment about this.

### What Situations Are
Situations are auto-outfit-switching rules. Each entry maps a `TransmogSituation` trigger to a spec/loadout/equipment-set. The client sends these when the player configures the "Auto-Switch" panel in the wardrobe UI.

TransmogSituation enum values (0-21):
```
0=None, 1=Spec1, 2=Spec2, 3=Spec3, 4=Spec4,
5=InCapitalCity, 6=InBattlefield, 7=OnDragonback, 8=InRaid,
9=InDungeon, 10=Swimming, 11=Mounted, 12=InCombat,
13=BearForm, 14=CatForm, 15=FlightForm, 16=MoonkinForm,
17=TreeOfLifeForm, 18=GhostWolfForm, 19=TravelForm,
20=StagForm, 21=MetamorphosisForm
```

### Implementation Plan

#### A. Database Table
Create SQL in `sql/updates/characters/master/` with the next available date sequence:
```sql
CREATE TABLE IF NOT EXISTS `character_transmog_outfit_situations` (
    `guid` BIGINT UNSIGNED NOT NULL COMMENT 'Character GUID',
    `setIndex` TINYINT UNSIGNED NOT NULL COMMENT 'Outfit index (0-19)',
    `situationID` INT UNSIGNED NOT NULL COMMENT 'TransmogSituation enum value (0-21)',
    `specID` INT UNSIGNED NOT NULL DEFAULT 0,
    `loadoutID` INT UNSIGNED NOT NULL DEFAULT 0,
    `equipmentSetID` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`guid`, `setIndex`, `situationID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

#### B. Prepared Statements
Add to `src/server/database/Database/Implementation/CharacterDatabase.cpp`:
- `CHAR_SEL_TRANSMOG_OUTFIT_SITUATIONS` — SELECT for a character (all outfits)
- `CHAR_DEL_TRANSMOG_OUTFIT_SITUATIONS` — DELETE for a specific outfit (guid + setIndex)
- `CHAR_INS_TRANSMOG_OUTFIT_SITUATION` — INSERT/REPLACE one situation entry

Add the enum values to `CharacterDatabase.h` in the `CharacterDatabaseStatements` enum.

#### C. Load at Login
In `Player.cpp`, in or near `_LoadTransmogOutfits()`, load situation data and attach it to the outfit. You'll need to extend `EquipmentSetData` in `EquipmentSet.h`:
```cpp
std::vector<TransmogOutfitSituationData> Situations; // new field
```
Where `TransmogOutfitSituationData` mirrors the `TransmogOutfitSituationEntry` packet struct.

#### D. Save/Update
In the handler, after validating, store the situations in the outfit's data and mark it as changed:
```cpp
eqSet->Data.Situations = parsedSituations;
eqSet->State = EQUIPMENT_SET_CHANGED;
```
The existing `_SaveEquipmentSets()` path will need a branch to also save situations.

#### E. Sync to Client
In `_SyncTransmogOutfitsToActivePlayerData()`, populate the `UF::TransmogOutfitSituationInfo` update fields from the stored situation data.

### Files to Modify
- `src/server/game/Entities/Player/EquipmentSet.h` — add Situations vector
- `src/server/game/Entities/Player/Player.cpp` — load, save, sync situations
- `src/server/game/Handlers/TransmogrificationHandler.cpp` — persist in handler
- `src/server/database/Database/Implementation/CharacterDatabase.h` — enum values
- `src/server/database/Database/Implementation/CharacterDatabase.cpp` — prepared statements
- New SQL file in `sql/updates/characters/master/`

### Priority
This is LOW priority for a roleplay server — players can manually switch outfits. Only implement if Tasks 1 and 2 are complete and clean.

---

## Task 4: Parse Slot Data from CMSG_TRANSMOG_OUTFIT_NEW (BUG — Medium)

### Problem
The current `TransmogOutfitNew::Read()` parser in `TransmogrificationPackets.cpp` only extracts the **name and icon** from the packet. It has a hardcoded `middleLength != 6` check that **rejects** any packet with extra bytes beyond the 6-byte fixed header.

However, the client almost certainly sends appearance slot data in CMSG_TRANSMOG_OUTFIT_NEW (since you're creating a full outfit with all its slot appearances). This data is being **silently rejected** because the parser returns `ParseError = "unexpected middle size for OUTFIT_NEW"` when middleLength > 6.

This means new outfits are saved with **no appearance data** — only a name and icon. The appearances would only populate if the client follows up with a separate CMSG_TRANSMOG_OUTFIT_UPDATE_SLOTS.

### Current Broken Code
```cpp
std::size_t middleLength = asciiStart - 2;
if (middleLength != 6)  // <-- REJECTS packets with slot data!
{
    ParseError = Trinity::StringFormat("unexpected middle size for OUTFIT_NEW (got={} expected=6)", middleLength);
    ...
    return;
}
```

### Fix Strategy
Replace the `middleLength != 6` check with:
1. Read the fixed 6-byte header (type, flags, icon) as currently done
2. Calculate `extraBytes = middleLength - 6`
3. If `extraBytes > 0 && extraBytes % 16 == 0`, parse `extraBytes / 16` slot entries (same 16-byte format as CMSG_TRANSMOG_OUTFIT_UPDATE_SLOTS: AppearanceID/RawSlotField/Reserved1/Reserved2)
4. Apply each slot entry to `Set.Appearances[]` (with the secondary shoulder sentinel fix from Task 1)
5. Build the IgnoreMask from empty slots

```cpp
std::size_t middleLength = asciiStart - 2;
if (middleLength < 6)
{
    ParseError = "middle section too short for OUTFIT_NEW";
    ...
    return;
}

// Parse optional slot data after the 6-byte fixed header
std::size_t extraBytes = middleLength - 6;
if (extraBytes > 0)
{
    if (extraBytes % 16 != 0)
    {
        TC_LOG_DEBUG("network.opcode.transmog", "CMSG_TRANSMOG_OUTFIT_NEW: {} extra middle bytes (not multiple of 16), ignoring", extraBytes);
    }
    else
    {
        std::size_t slotCount = extraBytes / 16;
        std::size_t slotDataOffset = 6; // after type(1) + flags(1) + icon(4)
        for (std::size_t i = 0; i < slotCount; ++i)
        {
            std::size_t off = slotDataOffset + i * 16;
            uint32 appearanceID = ReadLE<uint32>(remaining, off);
            uint32 rawSlotField = ReadLE<uint32>(remaining, off + 4);
            uint8 transmogSlot = uint8(rawSlotField >> 24);
            uint8 equipSlot = TransmogOutfitSlotToEquipSlot(transmogSlot);

            if (equipSlot == TRANSMOG_SECONDARY_SHOULDER_SLOT)
            {
                Set.SecondaryShoulderApparanceID = int32(appearanceID);
                Set.SecondaryShoulderSlot = 2;
            }
            else if (equipSlot < EQUIPMENT_SLOT_END)
            {
                Set.Appearances[equipSlot] = int32(appearanceID);
            }
        }

        // Build IgnoreMask from empty slots
        for (uint8 slot = EQUIPMENT_SLOT_START; slot < EQUIPMENT_SLOT_END; ++slot)
            if (!Set.Appearances[slot])
                Set.IgnoreMask |= (1u << slot);
    }
}
```

### Files to Modify
- `src/server/game/Server/Packets/TransmogrificationPackets.cpp`

### Important
This depends on Task 1 (secondary shoulder sentinel fix) being done first.

---

## Task 5: Harden Packet Parsing for NEW and UPDATE_INFO (IMPROVEMENT — Low)

### Problem
`TransmogOutfitNew::Read()` and `TransmogOutfitUpdateInfo::Read()` use **heuristic backward-scanning** for printable ASCII to find the outfit name. This approach:
1. Breaks on non-ASCII (Unicode) outfit names
2. Is fragile if Blizzard changes the wire format

### What We Know About the Wire Format
The name is stored as a trailing section: `[nameLen: u8][pad: u8][name: nameLen bytes]`

### Recommended Approach
Instead of scanning backwards for ASCII, use the length byte:
1. After reading the fixed header + slot data, the remaining bytes should be `[nameLen][pad][name]`
2. Read `nameLen` from the first byte of the remaining section
3. Skip the pad byte
4. Read `nameLen` bytes as the name (supports any UTF-8 content)

Alternatively, keep the current heuristic but extend it to handle UTF-8 by:
- Scanning backward until we find a byte that matches the count of trailing bytes (the length byte)
- Validate that `remaining[asciiStart - 1]` (the pad) is 0x00

### Files to Modify
- `src/server/game/Server/Packets/TransmogrificationPackets.cpp`

### Important
Do NOT change the wire format or break compatibility with the existing client. The parsing must still work for the same binary data the 12.x client sends. Only change how we **interpret** the bytes.

---

## Architecture Reference

### Packet Flow
```
Client (12.x)
  ├─ CMSG_TRANSMOG_OUTFIT_NEW          → HandleTransmogOutfitNew()
  ├─ CMSG_TRANSMOG_OUTFIT_UPDATE_INFO  → HandleTransmogOutfitUpdateInfo()
  ├─ CMSG_TRANSMOG_OUTFIT_UPDATE_SLOTS → HandleTransmogOutfitUpdateSlots()
  ├─ CMSG_TRANSMOG_OUTFIT_UPDATE_SITUATIONS → HandleTransmogOutfitUpdateSituations()
  │
  ├─ Spell 1247613 (effect 347)        → Spell::EffectEquipTransmogOutfit()
  │
  ├← SMSG_TRANSMOG_OUTFIT_NEW_ENTRY_ADDED     (uint32 SetID + uint64 Guid)
  ├← SMSG_TRANSMOG_OUTFIT_INFO_UPDATED        (uint32 SetID + uint64 Guid)
  ├← SMSG_TRANSMOG_OUTFIT_SLOTS_UPDATED       (uint32 SetID + uint64 Guid)
  ├← SMSG_TRANSMOG_OUTFIT_SITUATIONS_UPDATED  (uint32 SetID + uint64 Guid)
  └← SMSG_ACCOUNT_TRANSMOG_UPDATE (login)
```

### Slot Mapping (Client → Server)
```
TransmogOutfitSlot → EQUIPMENT_SLOT
 0 Head           → EQUIPMENT_SLOT_HEAD (0)
 1 ShoulderRight  → EQUIPMENT_SLOT_SHOULDERS (2)
 2 ShoulderLeft   → TRANSMOG_SECONDARY_SHOULDER_SLOT (sentinel = 20)
 3 Back           → EQUIPMENT_SLOT_BACK (14)
 4 Chest          → EQUIPMENT_SLOT_CHEST (4)
 5 Tabard         → EQUIPMENT_SLOT_TABARD (18)
 6 Body/Shirt     → EQUIPMENT_SLOT_BODY (3)
 7 Wrist          → EQUIPMENT_SLOT_WRISTS (8)
 8 Hand           → EQUIPMENT_SLOT_HANDS (9)
 9 Waist          → EQUIPMENT_SLOT_WAIST (5)
10 Legs           → EQUIPMENT_SLOT_LEGS (6)
11 Feet           → EQUIPMENT_SLOT_FEET (7)
12 MainHand       → EQUIPMENT_SLOT_MAINHAND (15)
13 OffHand        → EQUIPMENT_SLOT_OFFHAND (16)
14 Ranged         → EQUIPMENT_SLOT_RANGED (17)
```

### Data Structures
```cpp
// EquipmentSet.h
struct EquipmentSetData {
    EquipmentSetType Type;              // 0=EQUIPMENT, 1=TRANSMOG
    uint64 Guid;                        // unique ID (global auto-increment)
    uint32 SetID;                       // index 0..19 (client limit)
    uint32 IgnoreMask;                  // bitmask of slots to skip
    std::string SetName;
    std::string SetIcon;                // FileDataID as string
    std::array<ObjectGuid, 19> Pieces;  // item GUIDs (unused for TRANSMOG)
    std::array<int32, 19> Appearances;  // ItemModifiedAppearanceID per slot
    std::array<int32, 2> Enchants;      // [0]=MH, [1]=OH illusion enchant
    int32 SecondaryShoulderApparanceID; // left/secondary shoulder
    int32 SecondaryShoulderSlot;        // always 2 when used
    int32 SecondaryWeaponAppearanceID;  // unused for outfits
    int32 SecondaryWeaponSlot;          // unused for outfits
};
```

### DB2 Stores Available at Runtime
```cpp
DB2Storage<TransmogHolidayEntry>    sTransmogHolidayStore;
DB2Storage<TransmogIllusionEntry>   sTransmogIllusionStore;
DB2Storage<TransmogSetEntry>        sTransmogSetStore;
DB2Storage<TransmogSetGroupEntry>   sTransmogSetGroupStore;
DB2Storage<TransmogSetItemEntry>    sTransmogSetItemStore;
// Also: sItemModifiedAppearanceStore, sItemStore, sItemSparseStore
```

### Client-Side API (from retail UI source — read-only reference)
The client uses these Lua APIs which map to our CMSG/SMSG packets:
- `C_TransmogOutfitInfo.AddNewOutfit(name, icon)` → CMSG_TRANSMOG_OUTFIT_NEW
- `C_TransmogOutfitInfo.CommitOutfitInfo(outfitID, name, icon)` → CMSG_TRANSMOG_OUTFIT_UPDATE_INFO
- `C_TransmogOutfitInfo.CommitAndApplyAllPending()` → CMSG_TRANSMOG_OUTFIT_UPDATE_SLOTS (and CMSG_TRANSMOGRIFY_ITEMS)
- `C_TransmogOutfitInfo.CommitPendingSituations()` → CMSG_TRANSMOG_OUTFIT_UPDATE_SITUATIONS
- `C_TransmogOutfitInfo.GetOutfitsInfo()` ← reads from ActivePlayerData::TransmogOutfits update fields
- `C_TransmogOutfitInfo.ChangeDisplayedOutfit(outfitID)` → casts spell 1247613 with MiscValue=SetID

### TransmogOutfitSlotInfo DB2 (from Wago CSVs — all 14 wardrobe slots)
```
ID  Name              TransmogOutfitSlotEnum  InventorySlotID
1   HEADSLOT          0                       1
2   SHOULDERSLOT(R)   1                       3
3   SHOULDERSLOT(L)   2                       3
4   SHIRTSLOT         6                       4
5   CHESTSLOT         4                       5
6   WAISTSLOT         9                       6
7   LEGSSLOT          10                      7
8   FEETSLOT          11                      8
9   WRISTSLOT         7                       9
10  HANDSSLOT         8                       10
11  BACKSLOT          3                       15
12  TABARDSLOT        5                       19
13  MAINHANDSLOT      12                      16
14  SECONDARYHANDSLOT 13                      17
```

### TransmogOutfitEntry DB2 (outfit save slots)
```
ID  Cost        Name        Source  Notes
1   0           Default     0       system default outfit
2   0           Outfit 1    1       free slot
3   0           Outfit 2    1       free slot
4   1000000     Outfit 3    1       costs 100g (1M copper)
5   2000000     Outfit 4    1       costs 200g
...escalating costs up to ID 52
```

### TransmogOutfitSlotOption DB2 (weapon sub-options, 18 rows)
Each weapon slot (MH=ID 13, OH=ID 14) can have sub-options like:
- One-Handed Weapon, Two-Handed Weapon, Dagger, Fist Weapon
- Wand, Ranged (Bow/Gun/Crossbow)
- Shield, Held In Off-Hand
These map to `TransmogCollectionType` for the wardrobe collection panel.

---

## Acceptance Criteria

### Task 1 (Secondary Shoulder)
- [ ] `HandleTransmogOutfitNew` correctly stores slot 2 in `SecondaryShoulderApparanceID`
- [ ] `HandleTransmogOutfitUpdateSlots` correctly stores slot 2 in `SecondaryShoulderApparanceID`
- [ ] No out-of-bounds array access for `Appearances[]`
- [ ] Existing slots 0-1 and 3-14 continue to work unchanged
- [ ] Builds cleanly with no warnings

### Task 2 (SPEC_5 in .display)
- [ ] `ResetItem()` clears SPEC_5 transmog appearance and secondary appearance modifiers
- [ ] `ApplyModifiedAppearance()` sets SPEC_5 if it was missing
- [ ] No behavioral change for SPEC_1-4
- [ ] Builds cleanly

### Task 3 (Situation Persistence) — Optional
- [ ] New `character_transmog_outfit_situations` table created via SQL update
- [ ] Situations loaded at login and attached to outfit data
- [ ] Situations saved when handler receives CMSG_TRANSMOG_OUTFIT_UPDATE_SITUATIONS
- [ ] Situations synced to client via TransmogOutfitSituationInfo update fields
- [ ] Situations deleted when an outfit is deleted
- [ ] Builds cleanly

### Task 4 (Parse Slot Data from NEW)
- [ ] `TransmogOutfitNew::Read()` no longer rejects packets with extra middle bytes
- [ ] Slot entries in CMSG_TRANSMOG_OUTFIT_NEW are parsed into `Set.Appearances[]`
- [ ] Secondary shoulder slot (transmogSlot 2) is correctly routed to `SecondaryShoulderApparanceID`
- [ ] IgnoreMask is built from empty slots
- [ ] Non-16-byte-aligned extra data is logged but doesn't cause parse failure
- [ ] Builds cleanly

### Task 5 (Parser Hardening) — Optional
- [ ] `TransmogOutfitNew::Read()` uses length-byte-based name detection instead of backward ASCII scan
- [ ] `TransmogOutfitUpdateInfo::Read()` uses the same approach
- [ ] UTF-8 outfit names parse correctly
- [ ] All existing ASCII outfit names still parse correctly
- [ ] Diagnostic fields (ParseError, DiagnosticReadTrace) still populated on failure
- [ ] Builds cleanly

---

## Current Source Code (Key Sections)

Read these files in full before making changes. Here are the critical excerpts to orient you:

### TransmogOutfitSlotToEquipSlot() — the buggy switch (TransmogrificationPackets.cpp)
```cpp
// BUG: Both slot 1 AND slot 2 map to EQUIPMENT_SLOT_SHOULDERS.
// Slot 2 (ShoulderLeft) should set SecondaryShoulderApparanceID instead.
uint8 TransmogOutfitSlotToEquipSlot(uint8 transmogSlot)
{
    switch (transmogSlot)
    {
        case 0:  return EQUIPMENT_SLOT_HEAD;
        case 1:  return EQUIPMENT_SLOT_SHOULDERS;
        case 2:  return EQUIPMENT_SLOT_SHOULDERS;  // <-- BUG: should be secondary shoulder sentinel
        case 3:  return EQUIPMENT_SLOT_BACK;
        case 4:  return EQUIPMENT_SLOT_CHEST;
        case 5:  return EQUIPMENT_SLOT_TABARD;
        case 6:  return EQUIPMENT_SLOT_BODY;
        case 7:  return EQUIPMENT_SLOT_WRISTS;
        case 8:  return EQUIPMENT_SLOT_HANDS;
        case 9:  return EQUIPMENT_SLOT_WAIST;
        case 10: return EQUIPMENT_SLOT_LEGS;
        case 11: return EQUIPMENT_SLOT_FEET;
        case 12: return EQUIPMENT_SLOT_MAINHAND;
        case 13: return EQUIPMENT_SLOT_OFFHAND;
        case 14: return EQUIPMENT_SLOT_RANGED;
        default: return EQUIPMENT_SLOT_END;
    }
}
```

### TransmogOutfitUpdateSlots::Read() — slot parsing (TransmogrificationPackets.cpp)
```cpp
// Inside the slot loop:
for (TransmogOutfitSlotEntry& slot : Slots)
{
    _worldPacket >> slot.AppearanceID;
    _worldPacket >> slot.RawSlotField;
    _worldPacket >> slot.Reserved1;
    _worldPacket >> slot.Reserved2;

    uint8 transmogSlot = slot.GetSlotIndex();
    uint8 equipSlot = TransmogOutfitSlotToEquipSlot(transmogSlot);
    if (equipSlot < EQUIPMENT_SLOT_END)          // <-- silently drops slot 2 (sentinel > END)
        Set.Appearances[equipSlot] = int32(slot.AppearanceID);
    // ...
}
```

### TransmogOutfitNew::Read() — the hardcoded middle length check (TransmogrificationPackets.cpp)
```cpp
std::size_t middleLength = asciiStart - 2;
if (middleLength != 6)  // <-- REJECTS packets with slot data (middleLength > 6)
{
    ParseError = Trinity::StringFormat("unexpected middle size for OUTFIT_NEW (got={} expected=6)", middleLength);
    DiagnosticReadTrace = BuildDiagnosticReadTrace("CMSG_TRANSMOG_OUTFIT_NEW", _worldPacket);
    return;
}
```

### EffectEquipTransmogOutfit — spell handler (SpellEffects.cpp, ~line 6003)
Already handles SPEC_5 correctly:
```cpp
item->SetModifier(ITEM_MODIFIER_TRANSMOG_APPEARANCE_SPEC_5, 0);  // present
item->SetModifier(ITEM_MODIFIER_TRANSMOG_SECONDARY_APPEARANCE_SPEC_5, 0); // present for shoulders
item->SetModifier(ITEM_MODIFIER_ENCHANT_ILLUSION_SPEC_5, 0); // present for weapons
```
Use this as the reference for Task 2 (.display ResetItem fix).

### ValidateTransmogOutfitSet — validation helper (TransmogrificationHandler.cpp)
Also needs the secondary shoulder check — currently only validates `Appearances[0..18]`. If SecondaryShoulderApparanceID is populated, it should be validated against `sItemModifiedAppearanceStore` and `HasItemAppearance()` too.

---

## Build Verification
```bash
cmake --build out/build/x64-Debug --parallel 4
```
Ensure zero errors and zero warnings in modified files.

## Commit Strategy
- One commit per task
- Commit messages: `fix: <description>` for bugs, `feat: <description>` for new features
- Create a PR targeting `master` with a summary of all changes
