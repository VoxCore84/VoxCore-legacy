-- RoleplayCore — Stormwind Wizard's Sanctum portal room cleanup
-- Removes duplicate portals (old 500xxx series superseded by 620xxx retail entries),
-- LW import artifacts, stale Z=29 spawns, and redundant Valdrakken portal.
--
-- IMPORTANT: Guids 500391 (Caverns of Time) and 500398 (Shattrath) are KEPT —
-- they have no 620xxx replacements and are the only copies of those destinations.

-- ============================================================
-- Part 1: Delete old 500xxx portal series (only those with 620xxx replacements)
-- Dependency: gameobject_addon rows exist for these guids — delete first.
-- Verified: no game_event_gameobject, conditions, or pool_members references.
-- ============================================================

-- 500392 = Portal to Stormshield (replaced by 10001987 / entry 620479)
-- 500393 = Portal to Azsuna (replaced by 10001979 / entry 620477)
-- 500394 = Portal to Dalaran Crystalsong (replaced by 10001982 / entry 620475)
-- 500395 = Portal to Exodar (replaced by 10001981 / entry 620473)
-- 500396 = Portal to Jade Forest (replaced by 10001978 / entry 620467)
-- 500397 = Portal to Boralus (replaced by 10001985 / entry 620465)
-- 500400 = Portal to Oribos (replaced by 10001988 / entry 620464)

DELETE FROM `gameobject_addon` WHERE `guid` IN (500392, 500393, 500394, 500395, 500396, 500397, 500400);
DELETE FROM `gameobject` WHERE `guid` IN (500392, 500393, 500394, 500395, 500396, 500397, 500400);

-- ============================================================
-- Part 2: Delete redundant Valdrakken portal (guid 700011, entry 383582)
-- Superseded by guid 10001980 (entry 620458) at near-identical coords.
-- ============================================================

DELETE FROM `gameobject_addon` WHERE `guid` = 700011;
DELETE FROM `gameobject` WHERE `guid` = 700011;

-- ============================================================
-- Part 3: Delete Jade Forest triple-spawn extra (LW import artifact)
-- guid 990000000101162025 (entry 323844, spawntimesecs=300)
-- 500396 already deleted above. Remaining: 10001978 (entry 620467) — correct.
-- ============================================================

DELETE FROM `gameobject` WHERE `guid` = 990000000101162025;

-- ============================================================
-- Part 4: Delete Founder's Point duplicate (LW import artifact)
-- guid 990000000101160470 (entry 543407) — no gameobject_addon, wrong orientation
-- Correct spawn: guid 10001986 with AIAnimKitID 24311
-- ============================================================

DELETE FROM `gameobject` WHERE `guid` = 990000000101160470 AND `id` = 543407;

-- ============================================================
-- Part 5: Delete misplaced Bel'ameth "Arena Exit" GO on map 0
-- guid 400000000011150859 (entry 420914, type 10) stacked on correct
-- type-22 portal (guid 10001990, entry 620476, spell 433049)
-- ============================================================

DELETE FROM `gameobject` WHERE `guid` = 400000000011150859 AND `map` = 0;

-- ============================================================
-- Part 6: Delete stale Z=29 Larimaine Purdue spawn
-- guid 313822 at Z=29.70 (old Sanctum floor, beneath modern room)
-- Correct spawn: guid 850200 at Z=66.24 confirmed present
-- ============================================================

DELETE FROM `creature` WHERE `guid` = 313822;

-- ============================================================
-- Part 7: Raise Hellfire Peninsula portal from old floor to modern floor
-- guid 219963 (entry 195141) at Z=29.62 — no 620xxx replacement exists.
-- This is the only Hellfire portal in the Sanctum.
-- New Z=68.18 matches Valdrakken/Dornogal corridor floor level.
-- ============================================================

UPDATE `gameobject` SET `position_z` = 68.18 WHERE `guid` = 219963;
