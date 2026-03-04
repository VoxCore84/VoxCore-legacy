-- RoleplayCore
-- Fix Silvermoon portal (entry 621992) in the Stormwind Wizard's Sanctum
-- In Midnight 12.x, Alliance has a portal to Silvermoon City.
-- The gameobject_template had data0=0 (no spell), making it non-functional.
-- Spell 1259194 "Portal: Silvermoon City" is confirmed in hotfixes.spell_name.
-- Spawn position (Z=68.1472) is correct for the modern portal room floor.

UPDATE `world`.`gameobject_template`
    SET `Data0` = 1259194
    WHERE `entry` = 621992;
