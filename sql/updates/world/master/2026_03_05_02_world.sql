-- 2026_03_05_02_world.sql
-- Fix: restore AIName='SmartAI' for 181 creatures that have GUID-based smart_scripts
-- but no entry-based scripts. The previous cleanup (2026_03_05_01) only checked
-- entry-based scripts (entryorguid > 0), missing per-spawn GUID scripts (entryorguid < 0).

UPDATE `creature_template` ct
SET ct.`AIName` = 'SmartAI'
WHERE ct.`AIName` = ''
AND NOT EXISTS (
    SELECT 1 FROM `smart_scripts` ss
    WHERE ss.`entryorguid` = ct.`entry` AND ss.`source_type` = 0
)
AND EXISTS (
    SELECT 1 FROM `creature` c
    JOIN `smart_scripts` ss ON ss.`entryorguid` = -(CAST(c.`guid` AS SIGNED)) AND ss.`source_type` = 0
    WHERE c.`id` = ct.`entry`
);
