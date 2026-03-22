# Fork Comparison Audit — TC Master vs KamiliaBlow vs coreretail6

**Date**: 2026-03-22
**Purpose**: Determine merge strategy for new VoxCore fork

---

## Executive Summary

| Repo | Total src/server diffs vs TC | New files | Modified files | Outside src/ diffs |
|------|-----|-----------|----------------|-------------------|
| **KamiliaBlow/RoleplayCore** | 209 | 15 dirs/files | 193 | cmake, dep (Eluna), sql, contrib |
| **coreretail6/TrinityCore** | 38 | 0 | 37 | sql base schemas only |

**Critical finding**: coreretail6 is a PURE SUBSET of KamiliaBlow. Every file coreretail6 modifies, KamiliaBlow also modifies. coreretail6 has zero unique changes.

**Critical finding**: TC master recently added `game/Transmog/TransmogMgr.cpp/.h` — a proper Transmog subsystem refactor. NEITHER fork has this. Both forks predate the refactor and keep transmog in the old handler location. Starting from TC master gets this for free.

---

## Overlap Analysis

| Category | Count |
|----------|-------|
| Files ONLY KamiliaBlow modifies | **156** |
| Files ONLY coreretail6 modifies | **0** |
| Files BOTH forks modify | **37** |
| New files ONLY in KamiliaBlow | **15** |
| New files ONLY in coreretail6 | **0** |

### The 37 Overlap Files (both forks modify)

All 37 of coreretail6's changes also appear in KamiliaBlow. For each file, KamiliaBlow's diff is LARGER (more extensive changes). This means KamiliaBlow includes everything coreretail6 does, plus more.

| File | KB diff lines | CR6 diff lines | Nature |
|------|:---:|:---:|--------|
| TransmogrificationHandler.cpp | 915 | 284 | KB has more transmog features |
| Player.cpp | 1890 | 805 | KB adds roleplay hooks + CR6's changes |
| SpellEffects.cpp | 723 | 32 | CR6 adds EquipTransmogOutfit; KB adds that + many more |
| Opcodes.cpp | 108 | 20 | KB adds more opcodes |
| DB2Structure.h | large | large | Both add transmog DB2 structures |
| CollectionMgr.cpp/.h | moderate | moderate | Transmog collection work |
| WorldSession.cpp/.h | large | small | KB adds more session handlers |
| UpdateFields.cpp/.h | large | moderate | Both update field structures |
| *...33 more files* | larger | smaller | Same pattern |

### Conclusion on Overlap

Since coreretail6 has NO unique changes, and KamiliaBlow is a superset, **coreretail6 adds no value that KamiliaBlow doesn't already provide**. However, coreretail6's changes are *cleaner and more focused* (smaller diffs, fewer side effects), making them easier to review and port.

---

## KamiliaBlow — What It Adds

### New Files/Directories (15)

| Path | What | VoxCore needs? |
|------|------|:-:|
| `database/.../RoleplayDatabase.cpp/.h` | 5th database connection | YES — VoxCore's foundation |
| `game/RolePlay/` | sRoleplay singleton | YES — core RP system |
| `game/Craft/` | Crafting system | YES |
| `game/Hoff/` | Utility class | YES |
| `game/Entities/Creature/CreatureOutfit.cpp/.h` | NPC appearance overlay | YES |
| `game/LuaEngine/` | Eluna integration | YES |
| `scripts/Commands/cs_customnpc.cpp` | .cnpc commands | YES |
| `scripts/Custom/RolePlayFunction/` | .display + .effect commands | YES |
| `scripts/Custom/free_share_scripts.cpp` | Free share features | YES |
| `scripts/Custom/item_toy_scripts.cpp` | Custom toy items | YES |
| `scripts/Custom/spell_dragonriding.cpp` | Dragonriding fixes | YES |
| `scripts/CoreExtended/` | Extended core scripts | REVIEW |
| `scripts/DarkmoonIsland/` | Darkmoon Faire scripts | REVIEW |

### Modified Files by Subsystem (193)

| Subsystem | Files | Nature of Changes |
|-----------|:-----:|-------------------|
| Entities (Player, Creature, Item, Object, GO) | 31 | RP hooks, outfit overlays, custom NPC support, UpdateFields |
| Server/Protocol | 26 | Session handlers, opcodes, packets for RP features + transmog |
| Handlers | 22 | Character, transmog, chat, misc packet handlers |
| Spells | 17 | Custom spell effects, aura handlers, spell scripts |
| Database | 15 | 5th DB connection, query definitions, schema |
| Scripts/Spells | 14 | Spell script implementations |
| Commands | 8 | GM commands (.npc, .go, .modify, etc.) |
| AI | 6 | Creature AI modifications |
| DataStores/DB2 | 5 | Additional DB2 structure definitions |
| Maps/DungeonFinding/BGs | 12 | Instance/map/BG modifications |
| Other (Chat, Loot, Guilds, etc.) | 37 | Various systems |

### Outside src/server/

| Path | Change |
|------|--------|
| `cmake/options.cmake` + `showoptions.cmake` | Eluna + custom script options |
| `dep/lualib/` | Lua library for Eluna |
| `dep/CMakeLists.txt` | Lualib dependency |
| `contrib/protoc-bnet/` | Protoc code generator files |
| `sql/RoleplayCore/` | Custom DB setup scripts |
| `sql/DoomCore/` | Additional SQL (predecessor project?) |
| `sql/base/auth_database.sql` | Modified auth schema |
| `sql/base/characters_database.sql` | Modified characters schema |
| `.gitignore` | Additional ignores |

---

## coreretail6 — What It Adds

### Focus: Retail Transmog System

coreretail6's 37 modifications are narrowly focused on implementing the retail transmog outfit system:

**DB2 Structures** (new types in DB2Structure.h):
- `TransmogOutfitEntryEntry` — outfit catalog entries
- `TransmogOutfitSlotInfoEntry` — per-slot metadata
- `TransmogOutfitSlotOptionEntry` — slot options (weapon variants)
- `TransmogSituationEntry` — situation-based outfits
- `TransmogSituationGroupEntry` — situation grouping
- `TransmogSituationTriggerEntry` — situation triggers

**Spell Effect** (SpellEffects.cpp):
- `EffectEquipTransmogOutfit` — spell handler for outfit equip/lock/unlock

**Protocol**: Additional opcodes, WorldSession handlers, transmog packet structures

**Player/Collection**: CollectionMgr transmog collection support, Player transmog state

---

## Recommended Merge Strategy

### Why NOT to merge both forks wholesale

1. Both forks predate TC's `game/Transmog/TransmogMgr` refactor — merging either would CONFLICT with TC master's new transmog architecture
2. KamiliaBlow has 193 modified files — merging this many diffs against current TC master risks the same merge disaster as before
3. coreretail6 is a pure subset — no unique value beyond KamiliaBlow

### Recommended Approach: TC Master + Surgical Porting

**Layer 1: TC Master (base)** — gets latest upstream including TransmogMgr refactor

**Layer 2: KamiliaBlow's NEW files (clean additions, no conflicts)**
- RoleplayDatabase, RolePlay/, Craft/, Hoff/, CreatureOutfit, LuaEngine
- Custom scripts (cs_customnpc, RolePlayFunction, free_share, toys, dragonriding)
- cmake/dep changes for Eluna
- sql/RoleplayCore/ setup scripts
- These are ADDITIONS — they don't modify TC files, so no merge conflicts

**Layer 3: KamiliaBlow's MODIFICATIONS (careful, one subsystem at a time)**
- Port modifications file by file, reviewing each against TC master
- Priority order:
  1. Database (15 files) — needed for 5th DB connection
  2. Entities (31 files) — CreatureOutfit hooks, custom NPC support
  3. Server/Protocol (26 files) — session handlers, opcodes
  4. Spells (17 files) — custom spell framework
  5. Handlers (22 files) — packet handling
  6. Scripts (14 files) — spell implementations
  7. Commands (8 files) — GM tools
  8. Everything else (60 files) — AI, Maps, BGs, etc.

**Layer 4: coreretail6's transmog DB2 structures**
- Port the DB2 structure definitions (TransmogOutfitEntry, etc.) into TC's new TransmogMgr architecture
- Port EffectEquipTransmogOutfit spell handler
- These are VALUABLE but need to be adapted to TC's new layout

**Layer 5: VoxCore custom systems**
- Companion Squad, custom scripts unique to VoxCore (not in KB)
- SQL updates (288 files)
- Runtime configs, Eluna scripts

**Layer 6: Tooling & infrastructure**
- AI Studio, tools/, .claude/, docs, addons, wago
- Copy verbatim — no merge needed

### Estimated Scope

| Layer | Files | Conflict Risk | Effort |
|-------|:-----:|:---:|--------|
| 1. TC Master | 0 (fresh clone) | None | Minutes |
| 2. KB new files | ~15 dirs + cmake/sql | Low | Hours |
| 3. KB modifications | 193 files | **HIGH** | Days (multi-session) |
| 4. CR6 transmog DB2 | ~10 files | Medium | Hours |
| 5. VoxCore custom | ~50+ files | Low-Medium | Hours |
| 6. Tooling | ~500+ files | None | Minutes |

### Alternative: Skip Layer 3 Wholesale

Instead of porting all 193 KB modifications, port ONLY what VoxCore actually uses:
- Database changes (5th DB support) — **mandatory**
- Entity hooks (CreatureOutfit, custom NPC) — **mandatory**
- Opcode/session changes for RP features — **mandatory**
- Skip: AI, Maps, BGs, DungeonFinding, Loot, Guilds changes — **probably not needed**

This could reduce Layer 3 from 193 files to ~60-80 files.
