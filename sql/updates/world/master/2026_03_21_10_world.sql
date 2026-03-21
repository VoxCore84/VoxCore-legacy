-- Fix waypoint paths and quest giver flags
-- Eliminates ~6,600 DBErrors.log entries per boot

-- 3,510 waypoint_path entries with no nodes in waypoint_path_node
DELETE FROM `waypoint_path` WHERE `PathId` NOT IN (SELECT DISTINCT `PathId` FROM `waypoint_path_node`);

-- 3,121 creature_questender entries where creature lacks UNIT_NPC_FLAG_QUESTGIVER (0x2)
-- Add the flag so quest turn-in works properly
UPDATE `creature_template` ct
JOIN `creature_questender` cqe ON ct.`entry` = cqe.`id`
SET ct.`npcflag` = ct.`npcflag` | 2
WHERE (ct.`npcflag` & 2) = 0;
