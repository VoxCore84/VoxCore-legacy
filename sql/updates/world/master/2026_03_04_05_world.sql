-- RoleplayCore — Portal room follow-up fixes
-- 1) Delete old Caverns of Time portal (guid 500391, spell 466601 has NO spell_effect).
--    Replacement: guid 10001983 / entry 620455 / spell 59901 (working).
-- 2) Delete old Shattrath portal (guid 500398, duplicated by guid 10001989 / entry 620472).
-- 3) Add Silvermoon City teleport destination for spell 1259194.
--    Map 530 (Eversong Woods), classic Silvermoon City coords.
--    No Midnight-era Silvermoon map exists yet.

-- Part 1: Delete broken old Caverns of Time portal
DELETE FROM `gameobject_addon` WHERE `guid` = 500391;
DELETE FROM `gameobject` WHERE `guid` = 500391;

-- Part 2: Delete old Shattrath duplicate
DELETE FROM `gameobject_addon` WHERE `guid` = 500398;
DELETE FROM `gameobject` WHERE `guid` = 500398;

-- Part 3: Silvermoon portal destination (spell 1259194 "Portal: Silvermoon City")
-- Coords match existing spells 32272 / 121855 (Mage Portal/Teleport: Silvermoon)
INSERT INTO `spell_target_position`
    (`ID`, `EffectIndex`, `OrderIndex`, `MapID`,
     `PositionX`, `PositionY`, `PositionZ`, `Orientation`, `VerifiedBuild`)
VALUES
    (1259194, 0, 0, 530,
     9998.46, -7106.55, 47.7055, 0, 66220);
