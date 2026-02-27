# Codex Review Task: Transmog Outfit System — Full Audit (Feb 26 2026)

## Context

We have a custom transmog outfit system for a 12.x WoW private server (TrinityCore-based). Recent changes fixed how CMSG_TRANSMOG_OUTFIT_UPDATE_SLOTS and CMSG_TRANSMOG_OUTFIT_NEW route IMAIDs (ItemModifiedAppearanceIDs) to equipment slots.

**Critical discovery (Feb 2026)**: The 16-byte slot entry wire format uses **bytes[6-7] (ItemAppearance.DisplayType)** as the routing key, NOT byte[0] (which is just a sequential ordinal 1-14). This was verified by looking up every IMAID from a WPP packet sniff in Wago DB2 CSVs:
- byte[0]=1 had IMAID 301683 "Shul'ka Shoulderspikes" (DT=1=Shoulder, NOT Head)
- byte[0]=4 had IMAID 301676 "Shul'ka Vest" (DT=3=Chest, NOT Shirt)
- byte[0]=9 had IMAID 301677 "Shul'ka Girdle" (DT=4=Waist, NOT Wrists)

## Wire Format (16 bytes per entry, verified)
```
byte[0]     = Sequential ordinal (1-14) — NOT a meaningful slot identifier
byte[1]     = Always 0 (padding)
bytes[2-5]  = AppearanceID (IMAID, uint32 LE)
bytes[6-7]  = ItemAppearance.DisplayType (uint16 LE) — THIS IS THE ROUTING KEY
bytes[8-15] = Reserved (zeros)
```

## Files to Review

1. `src/server/game/Server/Packets/TransmogrificationPackets.cpp` — Packet parsing (DisplayTypeToEquipSlot, Read() methods)
2. `src/server/game/Server/Packets/TransmogrificationPackets.h` — Struct definitions
3. `src/server/game/Handlers/TransmogrificationHandler.cpp` — All Handle* functions
4. `src/server/game/Entities/Player/TransmogrificationUtils.cpp` — ApplyTransmogOutfitToPlayer
5. `src/server/game/Entities/Player/Player.cpp` — Search for `_SyncTransmogOutfitsToActivePlayerData` and `SetVisibleItemSlot`

## Review Checklist

### A. Packet Parsing (TransmogrificationPackets.cpp)

1. **DisplayTypeToEquipSlot mapping completeness**: Verify DT→EQUIPMENT_SLOT mapping:
   - DT 0→HEAD(0), 1→SHOULDERS(2), 2→BODY/Shirt(3), 3→CHEST(4), 4→WAIST(5), 5→LEGS(6), 6→FEET(7), 7→WRISTS(8), 8→HANDS(9), 9→BACK(14), 10→TABARD(18), 11→MH(15), 13→Shield/OH(16), 15→OH(16)
   - Are DT 12 and 14 intentionally unmapped?

2. **UPDATE_SLOTS Read()**:
   - Does it correctly limit to first 14 entries as base outfit (skip iterations > 0)?
   - Is `seenPrimaryShoulder` correctly placed — first DT=1 → primary shoulder, second → SecondaryShoulderApparanceID?
   - Does it correctly read bytes[2-5] as IMAID and bytes[6-7] as WireDisplayType?

3. **NEW Read()**:
   - Same DT routing + seenPrimaryShoulder logic — is it consistent with UPDATE_SLOTS?
   - Name parsing: length-byte method vs ASCII fallback — edge cases?
   - Does it handle packets with zero slot entries?

4. **UPDATE_INFO Read()**: Does it correctly parse without slot data?

5. **UPDATE_SITUATIONS Read()**: Clean structured reads — verify format.

### B. Handler Logic (TransmogrificationHandler.cpp)

6. **HandleTransmogOutfitUpdateSlots**:
   - Per-slot merge: Does it correctly preserve HEAD/MH/OH from existing outfit?
   - Does `ApplyTransmogOutfitToPlayer` get called with the right data?

7. **HandleTransmogOutfitNew**:
   - Does it assign a valid SetID?
   - Does `ValidateTransmogOutfitSet` correctly validate appearances?

8. **HandleTransmogrifyItems** sync-back:
   - When individual transmog happens (not via outfit), does it correctly sync back?
   - Could this sync corrupt outfit data?

9. **ValidateTransmogOutfitSet**:
   - Does it set Type = TRANSMOG?
   - IgnoreMask for empty slots?
   - SecondaryShoulderApparanceID validation?

### C. Application Logic (TransmogrificationUtils.cpp)

10. **ApplyTransmogOutfitToPlayer**:
    - Iterates all EQUIPMENT_SLOTs correctly?
    - Skips ignored slots (IgnoreMask)?
    - Handles SecondaryShoulderApparanceID?
    - Gold cost calculation?

### D. Rendering Pipeline (Player.cpp)

11. **SetVisibleItemSlot**:
    - Sets HasTransmog, HasIllusion, Field_18 (DisplayType)?
    - Correct behavior when IMAID is 0?

12. **_SyncTransmogOutfitsToActivePlayerData**:
    - EQUIPMENT_SLOT → db2SlotInfoID mapping correct?
    - Looks up real DisplayType from DB2?
    - Handles SecondaryShoulderApparanceID?

### E. Cross-Cutting

13. **No stale references**: Search for `TransmogSlotToEquipSlot` — should be NONE.
14. **Compilation**: Syntax errors, missing includes, type mismatches?
15. **Thread safety**: Shared state accessed without locks?
16. **Edge cases**: No item equipped? IMAID not owned? SetID=0?

## Expected Output

For each checklist item (1-16), state **PASS** or **FAIL** with brief explanation. If FAIL, describe exactly what needs fixing with file path and line numbers.

Summary at the end: total PASS/FAIL, architectural concerns, suggested improvements.
