-- 2026_03_05_01_world.sql
-- Clear AIName for creatures with AIName='SmartAI' but no smart_scripts rows
-- These generate DB errors on every server startup and fall back to default AI anyway
-- NOTE: Must check BOTH entry-based scripts (entryorguid > 0) AND GUID-based scripts
-- (entryorguid < 0, referencing spawned creature GUIDs) to avoid clearing per-spawn AI.

UPDATE `creature_template` ct
SET ct.`AIName` = ''
WHERE ct.`AIName` = 'SmartAI'
AND NOT EXISTS (
    SELECT 1 FROM `smart_scripts` ss
    WHERE ss.`entryorguid` = ct.`entry` AND ss.`source_type` = 0
)
AND NOT EXISTS (
    SELECT 1 FROM `creature` c
    JOIN `smart_scripts` ss ON ss.`entryorguid` = -(CAST(c.`guid` AS SIGNED)) AND ss.`source_type` = 0
    WHERE c.`id` = ct.`entry`
);

-- Upstream TrinityCore: Warrior Whirlwind (updated proc)
DELETE FROM `spell_proc` WHERE `SpellId` IN (85739);
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(85739,0x00,4,0x00300002,0x00202700,0x00000120,0x00900000,0x0,0x0,0x0,0x4,0x0,0x10,0x0,0,0,0,0); -- Whirlwind
