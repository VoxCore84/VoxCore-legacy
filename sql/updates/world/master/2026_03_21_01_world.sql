-- 2026_03_21_01_world.sql
-- Register new spell scripts from upstream migration (druid, priest, warrior)
-- All C++ handlers verified in spell_{class}.cpp

-- Druid: Galactic Guardian Moonfire damage modifier (attached to 164812 Moonfire)
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_dru_galactic_guardian_moonfire';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(164812, 'spell_dru_galactic_guardian_moonfire');

-- Druid: Lunar Wrath proc filter (1253600)
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_dru_lunar_wrath';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(1253600, 'spell_dru_lunar_wrath');

-- Priest: Archangel (attached to 472433 Evangelism)
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_pri_archangel';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(472433, 'spell_pri_archangel');

-- Priest: Searing Light proc (1280131)
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_pri_searing_light';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(1280131, 'spell_pri_searing_light');

-- Warrior: Brutal Finish (attached to 446035 Bladestorm)
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_warr_brutal_finish';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(446035, 'spell_warr_brutal_finish');

-- Warrior: Keep Your Feet on the Ground proc filter (438590)
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_warr_keep_your_feet_on_the_ground';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(438590, 'spell_warr_keep_your_feet_on_the_ground');

-- Warrior: Improved Whirlwind Cleave damage modifier
-- Attached to all melee abilities that benefit from Whirlwind cleave buff
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_warr_improved_whirlwind_cleave';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(845,    'spell_warr_improved_whirlwind_cleave'),   -- Cleave
(1464,   'spell_warr_improved_whirlwind_cleave'),   -- Slam
(1715,   'spell_warr_improved_whirlwind_cleave'),   -- Hamstring
(23881,  'spell_warr_improved_whirlwind_cleave'),   -- Bloodthirst
(23922,  'spell_warr_improved_whirlwind_cleave'),   -- Shield Slam
(34428,  'spell_warr_improved_whirlwind_cleave'),   -- Victory Rush
(85384,  'spell_warr_improved_whirlwind_cleave'),   -- Raging Blow
(96103,  'spell_warr_improved_whirlwind_cleave'),   -- Raging Blow
(100130, 'spell_warr_improved_whirlwind_cleave'),   -- Furious Slash
(163558, 'spell_warr_improved_whirlwind_cleave'),   -- Execute Off-Hand
(184707, 'spell_warr_improved_whirlwind_cleave'),   -- Rampage
(184709, 'spell_warr_improved_whirlwind_cleave'),   -- Rampage
(201363, 'spell_warr_improved_whirlwind_cleave'),   -- Rampage
(201364, 'spell_warr_improved_whirlwind_cleave'),   -- Rampage
(202168, 'spell_warr_improved_whirlwind_cleave'),   -- Impending Victory
(218617, 'spell_warr_improved_whirlwind_cleave'),   -- Rampage
(260798, 'spell_warr_improved_whirlwind_cleave'),   -- Execute
(280772, 'spell_warr_improved_whirlwind_cleave'),   -- Siegebreaker
(280849, 'spell_warr_improved_whirlwind_cleave'),   -- Execute
(317483, 'spell_warr_improved_whirlwind_cleave'),   -- Condemn (Venthyr)
(317488, 'spell_warr_improved_whirlwind_cleave'),   -- Condemn (Venthyr)
(317489, 'spell_warr_improved_whirlwind_cleave'),   -- Condemn Off-Hand (Venthyr)
(335096, 'spell_warr_improved_whirlwind_cleave'),   -- Bloodbath
(335098, 'spell_warr_improved_whirlwind_cleave'),   -- Crushing Blow
(335100, 'spell_warr_improved_whirlwind_cleave'),   -- Crushing Blow
(394062, 'spell_warr_improved_whirlwind_cleave'),   -- Rend
(394063, 'spell_warr_improved_whirlwind_cleave'),   -- Rend
(396718, 'spell_warr_improved_whirlwind_cleave'),   -- Onslaught
(463815, 'spell_warr_improved_whirlwind_cleave'),   -- Arms Execute FX Test
(463816, 'spell_warr_improved_whirlwind_cleave'),   -- Fury Execute FX Test
(463817, 'spell_warr_improved_whirlwind_cleave'),   -- Fury Execute Off-Hand FX Test
(1269383,'spell_warr_improved_whirlwind_cleave');   -- Heroic Strike

-- Generic: Guild Chest / Mobile Banking (83958)
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_gen_guild_chest';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(83958, 'spell_gen_guild_chest');
