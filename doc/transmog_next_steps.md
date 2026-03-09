# Transmog Next Steps — Session 110+

> Written March 8, 2026 at end of session 110 (Transmog Master Tab).
> Read this when resuming transmog work after a build+test cycle.

---

## What Was Done (Session 110)

8 bugs fixed, 3 QA passes completed, all code changes ready for build:

| Bug | Fix | File(s) |
|-----|-----|---------|
| **BUG-G** (CRITICAL) | Modular residue name parser replaces backward ASCII scan. Handles 0x80 pad byte correctly. | `TransmogrificationPackets.cpp` ~L174-229 |
| **BUG-H1** (HIGH) | `ClearDynamicUpdateFieldValues` before `fillOutfitData` prevents Slots accumulation 30→60→90 | `Player.cpp` ~L18344-18345 |
| **BUG-M6** (HIGH) | Added `216696` (Hidden Pants) to both `hiddenItemIDs[]` and `hiddenAppearanceItems[]` | `Player.cpp` ~L18056, `CollectionMgr.cpp` ~L560 |
| **BUG-M9** (HIGH) | `!isStored &&` gate prevents illusion bootstrap leaking into stored outfits | `Player.cpp` ~L18274 |
| **BUG-M1** (HIGH) | Invalid enchants zeroed instead of rejecting entire outfit | `TransmogrificationHandler.cpp` ~L175-185 |
| **BUG-M5** (HIGH) | Weapon option parsed from byte[1] AND merged in handler | `TransmogrificationPackets.cpp` ~L267, L303-306; `TransmogrificationHandler.cpp` ~L843-847 |
| **BUG-M2** (HIGH) | `bridgeIllusionOverriddenMask` decouples illusion from appearance tracking | `TransmogrificationHandler.cpp` ~L907, L998, L1006, L1056 |
| **BUG-UNICODE** | Resolved by BUG-G fix (no longer uses ASCII scan as primary) | same as BUG-G |

QA Pass 2 also found and fixed:
- BUG-M5 handler merge was missing (parser stored options but handler never copied them to `updatedSet`)
- Stale comments in BUG-G section still described old approach

---

## Investigations Completed (no action needed)

| Item | Finding |
|------|---------|
| **DT 12 gap** | Already mapped (`case 12: return EQUIPMENT_SLOT_MAINHAND` — ranged weapons). Validator report was stale (pre-dates fix). |
| **DT 14 gap** | Already mapped (`case 14: return EQUIPMENT_SLOT_OFFHAND`). Same — stale report. |
| **72 placeholder IMAIDs** | All are unreleased/placeholder DB2 entries (TransmogSetItem rows referencing non-existent IMAIDs). Players can't collect or transmog them. No action needed. |
| **validate_transmog.py** | Report clean: 0 errors, 2 stale warnings, 0 repair SQL needed. Was run against build 66220 — consider re-running against 66263 for freshness. |
| **transmog_repair.sql** | Empty — no fixable mismatches found. |

---

## Step 1: BUILD AND TEST (blocking — human required)

Build in VS IDE, restart worldserver, then test these scenarios IN ORDER:

### Test A: Outfit Create (validates BUG-G fix)
1. Open transmog NPC, create a NEW outfit with an ASCII name (e.g., "TestOutfit1")
2. **Expected**: Outfit creates successfully, name displays correctly
3. **If it fails**: Check `Server.log` for `CMSG_TRANSMOG_OUTFIT_NEW` parse errors — the name parser logs detailed diagnostics

### Test B: Outfit Re-Apply (validates BUG-F)
1. Apply the outfit you just created
2. Close transmog UI completely
3. Reopen transmog UI, apply the SAME outfit again
4. **Expected**: No "Unknown set id" error, outfit applies cleanly both times
5. **If it fails**: BUG-F has an independent root cause beyond BUG-G — check diagnostic dump at `TransmogrificationHandler.cpp` ~L755-760

### Test C: Slots Not Growing (validates BUG-H1)
1. Apply outfit, close UI, reopen, apply again — repeat 3 times
2. **Expected**: No lag, no growing packet sizes. Slots array stays at 30 entries.
3. **How to verify**: Check `Server.log` for `_SyncTransmogOutfitsToActivePlayerData` debug messages — slot count should be constant

### Test D: Individual Slot Transmog (validates BUG-H)
1. With an outfit active, click a single slot (e.g., Head) and change its appearance
2. **Expected**: Appearance changes via `CMSG_TRANSMOG_OUTFIT_UPDATE_SLOTS`
3. **If nothing happens**: BUG-H has an independent cause — check if `CommitAndApplyAllPending` fires (requires TransmogSpy addon or packet sniffer)

### Test E: Hidden Pants (validates BUG-M6)
1. Open transmog UI, go to Legs slot
2. Select "Hidden" appearance for pants
3. **Expected**: Pants visually hidden (ADT=3, IMA=198608)

### Test F: Enchant Illusion (validates BUG-M2 + BUG-M9)
1. Create outfit with a weapon enchant illusion (e.g., Mongoose)
2. Apply outfit
3. Close UI, reopen, apply again
4. **Expected**: Enchant illusion persists after re-apply. Stored outfits do NOT inherit illusions from currently-equipped weapons.

### Test G: Bad Enchant Graceful (validates BUG-M1)
1. This is hard to test without a crafted packet. Just verify that outfits with valid enchants work normally.
2. Check `Server.log` for any "zeroing slot" messages — they indicate the fix triggered.

### Test H: Weapon Options (validates BUG-M5)
1. Create outfit, equip a 1H sword + shield
2. Save outfit
3. Log out and back in (or `/reload`)
4. Re-apply outfit
5. **Expected**: Weapon type selection preserved (1H+Shield, not defaulting to 2H)

---

## Step 2: After Testing — Update Bug Tracker

Based on test results, update `memory/transmog-bugtracker.md`:
- Tests pass → move bug status to `VERIFIED`
- Tests fail → note what happened, move back to `INVESTIGATING` with new data

---

## Step 3: Remaining Bugs (after all above pass)

### MEDIUM priority (implement when ready)
- **BUG-M3**: HandleTransmogOutfitNew missing bridge defer — needs client verification
- **BUG-M7**: EffectEquipTransmogOutfit return value ignored — `SpellEffects.cpp`
- **BUG-M8**: Missing SMSG response after EffectEquipTransmogOutfit — `SpellEffects.cpp`
- **BUG-M10**: UpdateSlots parser uses heuristic skip — `TransmogrificationPackets.cpp`

### LOW priority (cosmetic / cleanup)
- **BUG-L1**: Dead HandleTransmogrifyItems handler (~400 lines) — add early return or remove
- **BUG-L4**: spell_clear_transmog doesn't zero all auxiliary fields

### Feature gap (not a bug)
- **Situations system**: 3 DB2 tables exist (`transmogsituation`, `transmogsituationgroup`, `transmogsituationtrigger`), CMSG/SMSG opcodes registered, but no behavioral implementation. Spec-swap/location-based outfit auto-switching is a whole feature.

---

## Step 4: Optional — Re-run Validator

The `validate_transmog.py` report is from build 66220, project is now on 66263. Re-running would confirm clean status:

```bash
cd ~/VoxCore/wago
python validate_transmog.py --sql-out
```

Requires wow.tools.local running on `localhost:5000`.

---

## Step 5: Future Sniff Session

Next retail Ymir sniffer capture should cover these uncaptured operations:
- Outfit **create** (CMSG_TRANSMOG_OUTFIT_NEW in the wild)
- Outfit **delete**
- Outfit **rename**
- **Single-item** transmog (to confirm CMSG_TRANSMOGRIFY_ITEMS is truly dead in 12.x)
- **Situations** (spec-swap outfit auto-switching)

---

## Resource Audit Results (from Resource Tab — session 110)

Full report: `doc/transmog_resource_audit.md`

### Key Findings

1. **Bridge v3 spec is HISTORICAL** — all 7 checklist items are fully implemented in current code (`ChatHandler.cpp:597`, `TransmogrificationHandler.cpp:877-896`, etc.). The spec doc is not a TODO. Should be annotated.
2. **transmog_lookup.py has WRONG DT labels** — its `DISPLAY_TYPE_MAP` uses TransmogOutfitSlotEnum values, not ItemAppearance.DisplayType. DT 2 shows as "SHOULDERS_2ND" when it's actually Shirt/Body. Every `imaid` lookup shows misleading slot labels.
3. **DT mapping gaps differ per tool** — server has all (12, 14, 15), validate_transmog.py is missing 12+14, debug is missing 12+14, lookup is missing 14+15.
4. **Enriched CSVs are 3 builds stale** — only 66192, project on 66263. Fix: `python wago_enrich.py --major 12 --build 12.0.1.66263`
5. **Situations system IS partially implemented** — storage/relay/persistence works. Only auto-switch evaluation is missing (client-driven, correct behavior).
6. **~150 lines of duplicated code** across 3 tools (CSV loading, IMAID resolution, DT maps).

### Recommended Actions (post-build, when time allows)

| Priority | Action | Effort |
|----------|--------|--------|
| 1 | Create `wago/transmog_common_maps.py` — canonical DT mapping shared by all 3 tools | 30 min |
| 2 | Run `wago_enrich.py` for build 66263 | 5 min |
| 3 | Annotate `ExtTools/docs/build-transmog-bridge-v3.md` as IMPLEMENTED | 2 min |
| 4 | Build `/transmog-qa` slash command (orchestrates all 3 tools in one pass) | 1 hr |
| 5 | Add `--json` output to debug + lookup tools | 30 min |

---

## Key Learnings (Session 110)

1. **0x80 pad byte** is the real wire format between nameLen and name — not 0x00
2. **Weapon option parsing ≠ weapon option usage** — parser stores, handler must merge (two-site fix)
3. **Illusions are independent of appearances** in bridge — separate override masks needed
4. **BUG-F and BUG-H are likely symptoms of BUG-G** — name parsing failure prevents outfit creation, cascading into "unknown SetID" and blocked individual slots
5. **No corruption path exists** in `_equipmentSets` — exhaustive audit of all modify paths confirmed data integrity

---

*Last updated: March 8, 2026 — Session 110*
