# RoleplayCore — Open Issues & Roadmap

Prioritized list of known issues, planned work, and blocked items. Updated as items are resolved.

---

## HIGH Priority

### Transmog: 5-Bug Investigation (session 36)
**Status**: Diagnostic build deployed, awaiting testing
- **Bug A**: Paperdoll naked on 2nd UI open
- **Bug B**: Old head/shoulder persists when outfit doesn't define them
- **Bug C**: Monster Mantle ghost appearance (item 182306)
- **Bug D**: Draenei lower leg geometry loss
- **Bug E** (root cause confirmed): Single-item transmog → SetEquipmentSet → full ViewedOutfit rebuild
- 7 diagnostic logs added, not yet committed

### Transmog: Illusions + Clear Slot
- MH enchant illusions (4-field payload) — deployed, never verified in-game
- Clear single slot (transmogID=0) — deployed, never verified in-game

### Transmog: PR #760 Bugs
- **Bug F**: "Unknown set id 1" — SetID mapping destroyed after first apply
- **Bug G**: Name pad byte 0x80 — backward ASCII scan misidentifies string boundaries
- **Bug H**: CMSG_TRANSMOGRIFY_ITEMS never fires — individual slot transmog completely blocked

---

## MEDIUM Priority

### Skyriding / Dragonriding
- `spell_dragonriding.cpp:39`: `SPELL_RIDING_ABROAD = 432503` — TODO outside dragon isles
- `Player.cpp:19509`: forces legacy flight instead of proper skyriding

### Dead HandleTransmogrifyItems Handler
- `TransmogrificationHandler.cpp` lines 172-567 — 400 lines of dead code
- Client never sends `CMSG_TRANSMOGRIFY_ITEMS` in 12.x

### Melee First-Swing NotInRange Bug
- First-swing `NotInRange` errors, possibly CombatReach=0 or same-tick race
- `Unit::IsWithinMeleeRangeAt` (Unit.cpp:697)

### RolePlay.cpp Unverified TODOs
- Line 339: `// TODO: Check if this works`
- Line 397: `// TODO: This should already happen in DeleteFromDB, check this.`

### Stormwind: Class Trainers (15 entries)
- 15 trainers with TRAINER flag but no `trainer_spell` data (Cataclysm stripped class training)
- Options: strip flag, link to existing IDs, or leave as-is (retail-like)

---

## LOW Priority

### 82 Exact-Position Duplicate Creatures
- All `[DNT] Note` (entry 176436) on map 2441 — dev test NPCs, harmless

### Transmog: Unicode Outfit Names
- Backward ASCII scan breaks on non-ASCII characters

### Transmog: Outfit Delete Verification
- Assumed via `CMSG_DELETE_EQUIPMENT_SET` — unverified

### Transmog: Secondary Shoulder via Outfit Loading
- 13/14 slots work, secondary shoulder is the known gap
- PR #760 — upstream wants server-only fix without addon

### Transmog: SecondaryWeaponAppearanceID
- Not persisted — Legion artifact niche feature

### Orphan Spell 1251299
- Removed between builds but persists in hotfixes.spell_name — harmless

### Companion Squad Improvements
- Only 5 seed companions, damage doesn't scale, no visual customization, kiting AI

### Stormwind: Quest-Giver Flag Cleanup (84 NPCs)
- QUESTGIVER flag with no quest associations — cosmetic, matches retail in many cases

---

## DEFERRED / BLOCKED

### ~~Wowhead 403 Block~~ RESOLVED
- 403 expired on its own (Mar 4 2026). Scraper upgraded with curl_cffi Chrome131 TLS fingerprint

### ATT Data Import — READY TO APPLY
- AllTheThings Database parser extracts quest/NPC/vendor data from 1,576 curated Lua files
- **8,950 validated new rows**: 4,359 quest starters, 3,081 quest chain links, 1,510 vendor items
- All rows validated against TC quest_template + creature_template
- SQL generated at `att_validated.sql` in wago-tooling repo

### Missing Spawns (3,716 high-priority)
- 2,004 quest NPCs + 1,712 service NPCs
- `coord_transformer.py` built — 1,856 critical + 1,626 high spawns transformable
- **Not yet applied** — needs spot-check and in-game verification

### Service Gaps (997 vendors/trainers)
- VENDOR/TRAINER flag but zero inventory/spell data

### Equipment Gaps (~13,001 NPCs)
- Cross-reference LoreWalkerTDB `creature_equip_template` — not yet attempted

### Missing quest_offer_reward (27,328 quests) — READY TO SCRAPE
- TDB delta applied (+1,967 rows). 27,328 remaining
- Scraper hardened with curl_cffi, ~2 hours via two-phase approach
- Import pipeline: `import_quest_rewards.py` converts JSON to SQL

### Hotfix Repair Persistent Issues
- `mail_template`: 110 rows with truncated multi-line bodies
- `spell` table: 102 rows (zeroed column issue may be moot)
- ~20K missing rows from schema mismatches
- `model_file_data`/`texture_file_data`: massive gaps (client-only rendering data)

### Auth Key Self-Service Extraction
- x64dbg + WoWDumpFix or Frida method — documented, not yet attempted

---

## Code Quality Debt (session 24 audit)
- `.gitignore` for build artifacts
- Cross-faction `AllowTwoSide.*` audit
- `MinPetitionSigns=0` — verify intended
- Dead code: Hoff class, RotationAxis enum, marker system
- Non-idempotent setup SQL in `sql/RoleplayCore/`
- RelWithDebInfo `/Ob2` + LTO investigation

## Future Audit Passes
- C++ ScriptName bindings vs compiled script classes
- DBC/DB2 spell/item existence cross-ref against Wago CSVs
- Map coordinates validity (spawn positions vs map boundaries)
- Client-side rendering data coverage audit

---

*Updated March 5, 2026*
