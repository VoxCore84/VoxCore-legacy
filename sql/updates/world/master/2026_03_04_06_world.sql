-- RoleplayCore — Fix Silvermoon portal: use correct GO-click teleport spell
-- Spell 1259194 is a Mage-class portal spell (3s cast, lvl 68 req, cooldown).
-- Spell 1286187 "Portal to Silvermoon" is the correct GO-click spell (instant,
-- no level req, Effect 252 = TELEPORT_WITH_VISUAL_LOADING_SCREEN).
-- spell_effect rows for 1286187 already exist (IDs 1302843/1302844).

-- Fix the GO template to reference the correct spell
UPDATE `gameobject_template` SET `Data0` = 1286187 WHERE `entry` = 621992;

-- Add teleport destination for the correct spell (map 530, Silvermoon City)
-- Coords match existing spells 32272 / 121855 (Mage Portal/Teleport: Silvermoon)
INSERT IGNORE INTO `spell_target_position`
    (`ID`, `EffectIndex`, `OrderIndex`, `MapID`,
     `PositionX`, `PositionY`, `PositionZ`, `Orientation`, `VerifiedBuild`)
VALUES
    (1286187, 0, 0, 530,
     9998.46, -7106.55, 47.7055, 0, 66220);

-- Clean up the unnecessary spell_target_position for the wrong spell
DELETE FROM `spell_target_position` WHERE `ID` = 1259194;
