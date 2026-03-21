-- Bulk DB cleanup: orphan quest/creature data + faction 0 fix
-- Eliminates ~95,000 DBErrors.log entries per boot

-- 56,888 quest_template_addon rows for non-existent quest_template entries
DELETE FROM `quest_template_addon` WHERE `ID` NOT IN (SELECT `ID` FROM `quest_template`);

-- 26,066 creature_template_difficulty rows for non-existent creature_template entries
DELETE FROM `creature_template_difficulty` WHERE `Entry` NOT IN (SELECT `entry` FROM `creature_template`);

-- 12,823 creature_template entries with faction = 0 (invalid, causes "set to faction 35" log spam)
-- Faction 35 = "Friendly to all" — TC's automatic fallback anyway
UPDATE `creature_template` SET `faction` = 35 WHERE `faction` = 0;
