-- SmartAI orphan cleanup
-- Fix 1,196 creatures that have smart_scripts entries but AIName = '' (SmartAI never runs)
-- Excludes 10 creatures that have C++ ScriptNames (those use C++ AI, not SmartAI)
UPDATE `creature_template` SET `AIName` = 'SmartAI'
WHERE `entry` IN (SELECT DISTINCT `entryorguid` FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` > 0)
AND (`AIName` = '' OR `AIName` IS NULL)
AND (`ScriptName` = '' OR `ScriptName` IS NULL);

-- Delete 99 orphan smart_scripts rows for 37 non-existent creature_template entries
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` > 0
AND `entryorguid` NOT IN (SELECT `entry` FROM `creature_template`);
