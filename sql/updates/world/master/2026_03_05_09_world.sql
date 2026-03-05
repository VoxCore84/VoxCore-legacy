-- 2026_03_05_09_world.sql
-- Clear LootID for 51 spawned creatures referencing non-existent creature_loot_template entries
-- Prevents DBErrors.log spam on creature death

UPDATE `creature_template_difficulty` ctd
SET ctd.`LootID` = 0
WHERE ctd.`LootID` != 0 AND ctd.`DifficultyID` = 0
AND NOT EXISTS (SELECT 1 FROM `creature_loot_template` clt WHERE clt.`Entry` = ctd.`LootID`)
AND EXISTS (SELECT 1 FROM `creature` c WHERE c.`id` = ctd.`Entry`);
