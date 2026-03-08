# LoreWalker TDB Import — Claude Code Task Prompt

> **Copy everything below this line into a new Claude Code tab opened in `C:\Users\atayl\VoxCore\`**

---

## Task: Build and Execute LoreWalker TDB Selective Import Pipeline

You are working on VoxCore, a TrinityCore-based WoW private server. A new LoreWalker TDB dump (March 6 2026, build 66102) has been loaded into `lorewalker_world` on the same MySQL instance as our production `world` database.

### Connection Info
- MySQL: `"C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe" -u root -padmin`
- Source DB: `lorewalker_world` (935MB, 250 tables, freshly imported reference)
- Target DB: `world` (our production world database)
- SQL output dir: `sql/updates/world/master/` (naming: `YYYY_MM_DD_NN_world.sql`)
- Today's date: 2026-03-08

### What Was Already Analyzed (6-agent sweep, all confirmed)

**Schema**: Perfect match. All 253 LW tables exist in our world DB. Only 4 extra columns on our side (creature.size, gameobject.size, gameobject.visibility, npc_vendor.OverrideGoldCost) — all have defaults. No translation needed. Same engines, same PKs.

**Collisions**: NONE with our custom systems. Our custom ranges (creature_template 400000+, companions 500001-500005, spells 1900003+, portal GOs 620001-620011) have zero overlap with LW data.

**Data Quality Issues in LW to FILTER OUT**:
- 41,911 gameobject rows with corrupt GUIDs >= 1,913,720,832,000 (seasonal import artifacts)
- 226 creature/gameobject spawns at position (0,0,0)
- 950 orphan spawns referencing non-existent templates (258 creature, 692 gameobject)
- LW custom range 9,100,000+ (creatures, quests) — their housing/plot system, skip entirely

**Critical Gaps (LW has, we don't)**:
| Category | Missing Rows | Impact |
|---|---|---|
| phase_area | 662 | HIGHEST — invisible NPCs/objects |
| SmartAI (creature, source_type=0) | 169,464 | NPC behavior |
| SmartAI (timed actionlists, source_type=9) | 946 | NPC scripted sequences |
| Creature spawns (open world) | ~10,890 | World population |
| Creature spawns (instances) | ~92,000 | Dungeon/raid population |
| Gameobject spawns | 43,986 | World objects |
| Gameobject loot templates | 58,641 | Loot tables |
| Quest template addon | 57,699 | Quest metadata |
| Waypoint path nodes | 50,925 | NPC movement |
| Creature addon | 16,598 | NPC visual data |
| Scene templates | 194 | Cutscene data |
| Quest templates | 306 (187 retail) | Quests |
| Vendor data | 3,910 rows / 233 NPCs | Shop items |
| Waypoint paths | 61 | Patrol definitions |

**Where WE lead (do NOT overwrite)**:
- creature_loot_template: we have 50K more rows (raidbots imports)
- spell_script_names: we have 1,928 more (custom script bindings)
- creature_template: we have 251 more (custom NPCs)
- trainer/trainer_spell: we have more (custom trainers)
- npc_vendor: we have 4,326 more total rows
- creature_queststarter/questender: we have more

### Strategy: Direct Cross-Database SQL

Since both DBs are on the same MySQL instance, use `INSERT IGNORE INTO world.X SELECT * FROM lorewalker_world.X` with LEFT JOIN exclusion filters. This avoids Python entirely — produces clean, auditable, idempotent SQL files.

### Execution Plan — 5 SQL Files

Generate these as separate SQL update files using the project's naming convention (`sql/updates/world/master/2026_03_08_NN_world.sql`). Check what sequence numbers already exist and use the next available ones.

**IMPORTANT RULES**:
- Every file must start with a comment block explaining what it does
- Use INSERT IGNORE everywhere (idempotent, safe to re-run)
- For UPDATE operations (CT backfill), use UPDATE...JOIN with WHERE to only touch rows that need it
- NEVER delete or overwrite data in tables where we lead (creature_loot_template, spell_script_names, trainer, etc.)
- Filter out LW custom range (entry/ID >= 9,100,000) from all imports
- Filter out corrupt GO GUIDs >= 1,913,720,832,000
- Filter out spawns at position (0,0,0)
- Filter out orphan spawns (spawns referencing non-existent templates in OUR world DB)
- Do NOT import SmartAI source_type=5 (337K rows — LW custom scene extension we don't support)
- All imported rows should have VerifiedBuild set to 0 (marks as custom/imported)

---

#### FILE 1: Phase Area + Phase Name (Quick Win — Highest Impact)
Sequence: next available after existing _08_xx files.

```sql
-- Import phase_area entries from LoreWalker that we're missing
INSERT IGNORE INTO world.phase_area (AreaId, PhaseId, Comment)
SELECT l.AreaId, l.PhaseId, l.Comment
FROM lorewalker_world.phase_area l
LEFT JOIN world.phase_area w ON l.AreaId = w.AreaId AND l.PhaseId = w.PhaseId
WHERE w.AreaId IS NULL;

-- Import phase_name entries from LoreWalker that we're missing
INSERT IGNORE INTO world.phase_name (ID, Name)
SELECT l.ID, l.Name
FROM lorewalker_world.phase_name l
LEFT JOIN world.phase_name w ON l.ID = w.ID
WHERE w.ID IS NULL;
```

Before writing the file, DESCRIBE both tables to verify column names match exactly. Run a SELECT COUNT first to confirm expected row counts.

---

#### FILE 2: Templates (creature_template, creature_template_difficulty, gameobject_template, quest_template + addons)

Import NEW templates only (not updates to existing ones). Filter out LW custom range (>= 9,100,000).

Key tables:
- creature_template (36 missing, exclude >= 9100000)
- creature_template_difficulty (for those 36 new templates)
- creature_template_model (for those 36 new templates)
- gameobject_template (2,191 missing)
- gameobject_template_addon (for new GO templates)
- quest_template (187 retail quests, exclude >= 9100000)
- quest_template_addon (join against quest_template to only add addons for quests that exist)
- quest_objectives (for new quests)
- quest_details, quest_offer_reward, quest_request_items (for new quests)

DESCRIBE every table before writing INSERT statements. The column lists must be explicit (no SELECT *) for tables where we have extra columns.

For creature and gameobject tables where we have extra columns (size, visibility, OverrideGoldCost), you MUST list columns explicitly in the INSERT to avoid column count mismatches.

---

#### FILE 3: Spawn Data (creatures + gameobjects)

This is the biggest file. Import creature and gameobject spawns that exist in LW but not in our world DB.

```sql
-- Creature spawns: INSERT IGNORE, filter corrupt/broken data
INSERT IGNORE INTO world.creature (guid, id, map, zoneId, areaId, ...all columns except 'size'...)
SELECT l.guid, l.id, l.map, l.zoneId, l.areaId, ...
FROM lorewalker_world.creature l
LEFT JOIN world.creature w ON l.guid = w.guid
WHERE w.guid IS NULL
  AND l.id < 9100000                    -- exclude LW custom creatures
  AND NOT (l.position_x = 0 AND l.position_y = 0 AND l.position_z = 0)  -- exclude origin
  AND l.id IN (SELECT entry FROM world.creature_template)  -- template must exist in our DB
;
```

For gameobjects, add the additional corrupt GUID filter:
```sql
  AND l.guid < 1913720832000            -- exclude corrupt seasonal GUIDs
```

Also import associated addon data:
- creature_addon (for newly imported creature GUIDs)
- gameobject_addon (for newly imported gameobject GUIDs)
- creature_movement_override (for newly imported creature GUIDs)

DESCRIBE `creature` and `gameobject` tables in BOTH databases first — our tables have extra columns (size, visibility) that must be excluded from the SELECT.

---

#### FILE 4: Behavioral Data (SmartAI, Waypoints, Vendors, Scenes, Gossip)

SmartAI (CRITICAL — only source_type 0 and 9):
```sql
INSERT IGNORE INTO world.smart_scripts
  (entryorguid, source_type, id, link, ...)
SELECT l.entryorguid, l.source_type, l.id, l.link, ...
FROM lorewalker_world.smart_scripts l
LEFT JOIN world.smart_scripts w
  ON l.entryorguid = w.entryorguid AND l.source_type = w.source_type AND l.id = w.id AND l.link = w.link
WHERE w.entryorguid IS NULL
  AND l.source_type IN (0, 1, 2, 9)    -- creature, gameobject, areatrigger, timed actionlist
  AND l.entryorguid NOT BETWEEN 9100000 AND 9199999  -- exclude LW custom
  AND l.entryorguid NOT BETWEEN -9199999 AND -9100000  -- exclude LW custom (negative = per-GUID)
;
```

Waypoints:
```sql
INSERT IGNORE INTO world.waypoint_path (PathId, MoveType, Flags, Comment)
SELECT l.PathId, l.MoveType, l.Flags, l.Comment
FROM lorewalker_world.waypoint_path l
LEFT JOIN world.waypoint_path w ON l.PathId = w.PathId
WHERE w.PathId IS NULL;

-- Then nodes for those new paths
INSERT IGNORE INTO world.waypoint_path_node (PathId, NodeId, PositionX, PositionY, PositionZ, Orientation, Delay)
SELECT l.PathId, l.NodeId, l.PositionX, l.PositionY, l.PositionZ, l.Orientation, l.Delay
FROM lorewalker_world.waypoint_path_node l
WHERE l.PathId IN (
    SELECT PathId FROM lorewalker_world.waypoint_path lp
    LEFT JOIN world.waypoint_path wp ON lp.PathId = wp.PathId
    WHERE wp.PathId IS NULL
);
```

Vendors, scenes, gossip — same INSERT IGNORE pattern with LEFT JOIN exclusion.

For npc_vendor, our table has an extra column `OverrideGoldCost` — list columns explicitly.

---

#### FILE 5: ContentTuningID Backfill (UPDATE, not INSERT)

Use LW's ContentTuningID values to fix our CT=0 entries. Only update rows where:
- Our CT = 0
- LW's CT != 0
- Same Entry + DifficultyID

```sql
UPDATE world.creature_template_difficulty w
JOIN lorewalker_world.creature_template_difficulty l
  ON w.Entry = l.Entry AND w.DifficultyID = l.DifficultyID
SET w.ContentTuningID = l.ContentTuningID
WHERE w.ContentTuningID = 0 AND l.ContentTuningID != 0;
```

Run a SELECT COUNT first to see how many rows this would affect.

---

### Verification Steps (after each file)

1. Run the SQL file: `/apply-sql world` (or direct mysql command)
2. Check `DBErrors.log` for any errors
3. Report: rows affected per statement

### Final Deliverable

5 SQL update files in `sql/updates/world/master/`, each with:
- Header comment explaining what it does and row counts
- Idempotent INSERT IGNORE / conditional UPDATE statements
- Explicit column lists (no SELECT * for tables with schema diffs)
- All filters applied (corrupt GUIDs, origin spawns, orphans, LW custom range)

After all 5 files are generated, provide a summary table showing total rows imported per category.

### DO NOT:
- Overwrite tables where we lead (creature_loot_template, spell_script_names, trainer*, creature_quest*)
- Import SmartAI source_type=5 (unsupported LW extension)
- Import LW custom range (9100000+)
- Use DELETE statements
- Apply the SQL files — just generate them. User will review and apply manually.
- Build any C++ code — this is purely SQL work
