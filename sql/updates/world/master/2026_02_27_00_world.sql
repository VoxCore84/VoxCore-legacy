-- 2026_02_27_00_world.sql
-- Fix companion creature unit_class values (eliminates 5 boot warnings)

UPDATE `creature_template` SET `unit_class` = 1 WHERE `entry` = 500001; -- Warrior (Tank) - UNIT_CLASS_WARRIOR
UPDATE `creature_template` SET `unit_class` = 4 WHERE `entry` = 500002; -- Rogue (Melee) - UNIT_CLASS_ROGUE
UPDATE `creature_template` SET `unit_class` = 1 WHERE `entry` = 500003; -- Hunter (Ranged) - UNIT_CLASS_WARRIOR
UPDATE `creature_template` SET `unit_class` = 8 WHERE `entry` = 500004; -- Mage (Caster) - UNIT_CLASS_MAGE
UPDATE `creature_template` SET `unit_class` = 2 WHERE `entry` = 500005; -- Priest (Healer) - UNIT_CLASS_PALADIN (mana)
