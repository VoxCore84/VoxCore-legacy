-- 2026_03_21_04_world.sql
-- Register remaining 21 spell scripts not found in TDB 1200.26021
-- Spell IDs sourced from C++ comments and Wago DB2 SpellName lookups

-- DK
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_dk_marrowrend';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(195182, 'spell_dk_marrowrend');

-- Hunter
DELETE FROM `spell_script_names` WHERE `ScriptName` IN ('spell_hun_aspect_of_the_turtle', 'spell_hun_call_pet');
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(186265, 'spell_hun_aspect_of_the_turtle'),
(83245, 'spell_hun_call_pet');

-- Monk
DELETE FROM `spell_script_names` WHERE `ScriptName` IN ('spell_monk_open_palm_strikes', 'spell_monk_chi_wave_target_selector');
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(392972, 'spell_monk_open_palm_strikes'),
(132466, 'spell_monk_chi_wave_target_selector');

-- Paladin
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_pal_fist_of_justice';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(234299, 'spell_pal_fist_of_justice');

-- Rogue: Poisons — each poison spell gets the script for remove-previous-poison logic
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_rog_poisons';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(2823,   'spell_rog_poisons'),   -- Deadly Poison
(3408,   'spell_rog_poisons'),   -- Crippling Poison
(5761,   'spell_rog_poisons'),   -- Mind-Numbing Poison
(8679,   'spell_rog_poisons'),   -- Wound Poison
(108211, 'spell_rog_poisons'),   -- Leeching Poison
(108215, 'spell_rog_poisons'),   -- Paralytic Poison
(315584, 'spell_rog_poisons');   -- Instant Poison

-- Shaman: Generic Summon Elemental — handles Fire, Earth, Storm
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_sha_generic_summon_elemental';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(192249, 'spell_sha_generic_summon_elemental'),   -- Storm Elemental
(198067, 'spell_sha_generic_summon_elemental'),   -- Fire Elemental
(198103, 'spell_sha_generic_summon_elemental');    -- Earth Elemental

-- Warlock
DELETE FROM `spell_script_names` WHERE `ScriptName` IN ('spell_warl_drain_life', 'spell_warl_darkglare_eye_laser');
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(234153, 'spell_warl_drain_life'),
(205231, 'spell_warl_darkglare_eye_laser');

-- Warrior
DELETE FROM `spell_script_names` WHERE `ScriptName` IN ('spell_warr_improved_whirlwind', 'spell_warr_rampaging_ruin', 'spell_warr_tactician', 'spell_warr_warlords_torment', 'spell_warr_bladesmasters_torment');
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(190411, 'spell_warr_improved_whirlwind'),         -- Whirlwind
(184367, 'spell_warr_rampaging_ruin'),              -- Rampage
(184783, 'spell_warr_tactician'),
(107574, 'spell_warr_warlords_torment'),            -- Avatar
(390140, 'spell_warr_warlords_torment'),            -- Warlord's Torment talent
(107574, 'spell_warr_bladesmasters_torment'),       -- Avatar
(390138, 'spell_warr_bladesmasters_torment');        -- Blademaster's Torment talent

-- Generic
DELETE FROM `spell_script_names` WHERE `ScriptName` IN ('spell_gen_nightmare_vine', 'spell_arcane_pulse', 'spell_light_judgement', 'spell_make_camp', 'spell_back_camp', 'spell_maghar_orc_racial_ancestors_call');
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(28720,  'spell_gen_nightmare_vine'),
(260364, 'spell_arcane_pulse'),                      -- Nightborne racial
(256893, 'spell_light_judgement'),                    -- Lightforged Draenei racial
(312370, 'spell_make_camp'),                          -- Vulpera racial
(312372, 'spell_back_camp'),                          -- Vulpera racial (Return to Camp)
(274738, 'spell_maghar_orc_racial_ancestors_call');   -- Mag'har Orc racial
