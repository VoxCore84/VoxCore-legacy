-- 2026_03_05_07_world.sql
-- Fix HealthModifier=0 for spawned combat creatures (gives them 1 HP)
-- Sets to 1.0 (default) for 11 entries across Diff0 that have DamageModifier > 0

UPDATE `creature_template_difficulty` SET `HealthModifier` = 1
WHERE `HealthModifier` = 0 AND `DifficultyID` = 0
AND `Entry` IN (25713, 168155, 168364, 170021, 171572, 171573, 171574, 172335, 172336, 175975, 216736);
