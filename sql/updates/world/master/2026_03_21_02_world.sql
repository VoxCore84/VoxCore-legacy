-- 2026_03_21_02_world.sql
-- Clean up orphan npc_vendor entries for non-existent creature templates
-- and fix invalid creature model entry (from DBErrors.log analysis)

-- Remove vendor data for creatures that don't exist in creature_template
DELETE FROM `npc_vendor` WHERE `entry` IN (500511, 500537, 500542, 54943);

-- Fix creature 233278 invalid model 123746 — remove the bad model row
DELETE FROM `creature_template_model` WHERE `CreatureID` = 233278 AND `CreatureDisplayID` = 123746;
