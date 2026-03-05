-- 2026_03_05_08_world.sql
-- Remove 1,907 orphaned waypoint paths (30,130 nodes) not referenced by any creature_addon or creature_template_addon

DELETE wpn FROM `waypoint_path_node` wpn
WHERE NOT EXISTS (SELECT 1 FROM `creature_addon` ca WHERE ca.`PathId` = wpn.`PathId`)
AND NOT EXISTS (SELECT 1 FROM `creature_template_addon` cta WHERE cta.`PathId` = wpn.`PathId`);
