-- Fix zoneId=0 for creatures and gameobjects in Stormwind (map 0)
-- Coordinate box: position_x BETWEEN -9800 AND -8200, position_y BETWEEN -100 AND 1400
-- Sets all affected spawns to zoneId 1519 (Stormwind City) for query/indexing purposes.
-- Sub-areas (Harbor 4411, Lake 5314, Cemetery 5346, Outskirts 5398, Keep 6292, Embassy 9171)
-- are resolved at runtime from terrain data.

UPDATE world.creature
    SET zoneId = 1519
    WHERE map = 0
      AND zoneId = 0
      AND position_x BETWEEN -9800 AND -8200
      AND position_y BETWEEN -100 AND 1400;

UPDATE world.gameobject
    SET zoneId = 1519
    WHERE map = 0
      AND zoneId = 0
      AND position_x BETWEEN -9800 AND -8200
      AND position_y BETWEEN -100 AND 1400;

-- Upstream TrinityCore: Warrior Keep Your Feet on the Ground
DELETE FROM `spell_proc` WHERE `SpellId` IN (438590);

DELETE FROM `spell_script_names` WHERE `ScriptName` IN ('spell_warr_keep_your_feet_on_the_ground');
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(438590, 'spell_warr_keep_your_feet_on_the_ground');
