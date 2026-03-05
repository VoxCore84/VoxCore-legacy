-- 2026_03_05_12_world.sql
-- Fix all Silvermoon teleport/portal spells and game_tele to target new Midnight Silvermoon (Map 0) instead of old BC Silvermoon (Map 530)

-- New Midnight Silvermoon portal room on Map 0: (8555, -4810, 45.685)
-- Old BC Silvermoon was on Map 530: (9998, -7106, 47)

-- ============================================================================
-- 1) Fix existing spell_target_position (Stormwind portal room GO 621992)
-- ============================================================================
UPDATE `spell_target_position`
SET `MapID` = 0,
    `PositionX` = 8555,
    `PositionY` = -4810,
    `PositionZ` = 45.685,
    `Orientation` = 4.17
WHERE `ID` = 1286187 AND `EffectIndex` = 0;

-- ============================================================================
-- 2) Add missing spell_target_position for all new Midnight Silvermoon spells
--    All have SPELL_EFFECT_TELEPORT_UNITS (Effect 15) at EffectIndex 0
-- ============================================================================
DELETE FROM `spell_target_position` WHERE `ID` IN (1224058, 1225676, 1258128, 1259190, 1262778, 1263937, 1264716, 1271884, 1278017);
INSERT INTO `spell_target_position` (`ID`, `EffectIndex`, `OrderIndex`, `MapID`, `PositionX`, `PositionY`, `PositionZ`, `Orientation`, `VerifiedBuild`) VALUES
(1224058, 0, 0, 0, 8555, -4810, 45.685, 4.17, 66220), -- Portal: Silvermoon
(1225676, 0, 0, 0, 8555, -4810, 45.685, 4.17, 66220), -- Portal: Silvermoon
(1258128, 0, 0, 0, 8555, -4810, 45.685, 4.17, 66220), -- Portal to Silvermoon
(1259190, 0, 0, 0, 8555, -4810, 45.685, 4.17, 66220), -- Teleport: Silvermoon City (mage teleport)
(1262778, 0, 0, 0, 8555, -4810, 45.685, 4.17, 66220), -- Portal to Silvermoon
(1263937, 0, 0, 0, 8555, -4810, 45.685, 4.17, 66220), -- Teleport to Silvermoon City
(1264716, 0, 0, 0, 8555, -4810, 45.685, 4.17, 66220), -- Teleport: Silvermoon
(1271884, 0, 0, 0, 8555, -4810, 45.685, 4.17, 66220), -- [DNT] Port to Silvermoon
(1278017, 0, 0, 0, 8555, -4810, 45.685, 4.17, 66220); -- Portal to Silvermoon

-- ============================================================================
-- 3) Update game_tele to point .tele SilvermoonCity to new Silvermoon
-- ============================================================================
UPDATE `game_tele`
SET `position_x` = 8444.32,
    `position_y` = -4765.72,
    `position_z` = 49.001,
    `orientation` = 0,
    `map` = 0
WHERE `id` = 869;

-- ============================================================================
-- 4) Fix invisible Silvermoon portal in Stormwind Wizard's Sanctum
--    displayId 114258 (exp11 model) doesn't render — use 8fx_portalroom_silvermoon.m2 (55666)
-- ============================================================================
UPDATE `gameobject_template` SET `displayId` = 55666 WHERE `entry` = 621992;
