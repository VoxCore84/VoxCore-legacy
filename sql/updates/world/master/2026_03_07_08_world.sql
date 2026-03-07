-- ==========================================================================
-- Missing Spell Registration -- 114 spells from class/spec audit
-- Generated: 2026-03-07 07:44
-- ==========================================================================
--
-- SUMMARY:
--   Total missing spells: 114
--   DB2-present (hotfix insert only):      0  (none found in any build CSV)
--   Truly missing (need serverside_spell): 114
--
-- BREAKDOWN BY SOURCE:
--   Spec baseline spells:    14  (referenced in SpecializationSpells DB2)
--   Talent spells:            25  (referenced in TraitDefinition DB2)
--   Hero/Class trait spells:   68  (referenced in TraitDefinition DB2)
--   Triggered spells:           7  (triggered by EffectTriggerSpell of existing spells)
--
-- BREAKDOWN BY CLASS:
--   Death Knight        :   2 spells
--   Demon Hunter        :   4 spells
--   Druid               :   1 spells
--   Evoker              :   9 spells
--   Mage                :   5 spells
--   Monk                :   6 spells
--   Paladin             :   3 spells
--   Priest              :   8 spells
--   Rogue               :   7 spells
--   Shaman              :  11 spells
--   Warlock             :   1 spells
--   Warrior             :  57 spells
--
-- NOTE: All 114 spells are absent from the 12.0.1.66263 SpellName DB2.
-- They are referenced by the talent/trait system (TraitDefinition,
-- SpecializationSpells) or as EffectTriggerSpell of existing spells.
-- Many are old spell IDs removed in retail but still referenced by
-- DB2 trait data. The server needs stub entries so it can resolve
-- these IDs without errors.
--
-- All inserts use world.serverside_spell with the passive attribute
-- (0x40) where appropriate. No serverside_spell_effect rows are
-- generated since the original effect data is unavailable -- these
-- are registration stubs only. Effect implementation requires
-- per-spell C++ scripting or SmartAI/spell_proc entries.
-- ==========================================================================

-- Idempotent: INSERT IGNORE so re-running is safe

-- ==========================================================================
-- Death Knight (2 spells)
-- ==========================================================================

-- 1206: Chilled [Triggered by another spell] (Death Knight/Blood, Death Knight/Frost, Death Knight/Unholy)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (1206, 0, 0x00000040, 'Chilled');

-- 195740: Blooddrinker [Spec baseline spell] (Death Knight/Blood)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (195740, 0, 0x00000040, 'Blooddrinker');


-- ==========================================================================
-- Demon Hunter (4 spells)
-- ==========================================================================

-- 195761: Spirit Bomb [Spec baseline spell] (Demon Hunter/Vengeance)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (195761, 0, 0x00000040, 'Spirit Bomb');

-- 257191: Fel Barrage [Spec baseline spell] (Demon Hunter/Havoc)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (257191, 0, 0x00000040, 'Fel Barrage');

-- 1215546: Devourer Baseline 1 [Spec baseline spell] (Demon Hunter/Devourer)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (1215546, 0, 0x00000040, 'Devourer Baseline 1');

-- 1227110: Devourer Baseline 2 [Spec baseline spell] (Demon Hunter/Devourer)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (1227110, 0, 0x00000040, 'Devourer Baseline 2');


-- ==========================================================================
-- Druid (1 spells)
-- ==========================================================================

-- 202354: Stellar Drift [Talent] (Druid/Balance)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (202354, 0, 0, 'Stellar Drift');


-- ==========================================================================
-- Evoker (9 spells)
-- ==========================================================================

-- 368432: Empowered Spell [Hero/Class trait] (Evoker/Devastation, Evoker/Preservation)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (368432, 0, 0x00000040, 'Empowered Spell');

-- 370452: Scouring Flame [Hero/Class trait] (Evoker/Devastation, Evoker/Preservation)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (370452, 0, 0x00000040, 'Scouring Flame');

-- 370783: Tip the Scales [Hero/Class trait] (Evoker/Devastation, Evoker/Preservation)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (370783, 0, 0x00000040, 'Tip the Scales');

-- 370897: Renewing Blaze [Hero/Class trait] (Evoker/Devastation, Evoker/Preservation)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (370897, 0, 0x00000040, 'Renewing Blaze');

-- 370962: Time Spiral [Hero/Class trait] (Evoker/Devastation, Evoker/Preservation)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (370962, 0, 0x00000040, 'Time Spiral');

-- 371270: Emerald Communion [Hero/Class trait] (Evoker/Devastation, Evoker/Preservation)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (371270, 0, 0x00000040, 'Emerald Communion');

-- 376210: Stasis [Hero/Class trait] (Evoker/Devastation, Evoker/Preservation)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (376210, 0, 0x00000040, 'Stasis');

-- 386336: Chrono Flame [Hero/Class trait] (Evoker/Devastation, Evoker/Preservation)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (386336, 0, 0x00000040, 'Chrono Flame');

-- 386342: Chrono Loop [Hero/Class trait] (Evoker/Devastation, Evoker/Preservation)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (386342, 0, 0x00000040, 'Chrono Loop');


-- ==========================================================================
-- Mage (5 spells)
-- ==========================================================================

-- 6117: Mage Armor [Spec baseline spell] (Mage/Arcane)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (6117, 0, 0x00000040, 'Mage Armor');

-- 30482: Molten Armor [Spec baseline spell] (Mage/Fire)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (30482, 0, 0x00000040, 'Molten Armor');

-- 35009: Invisibility (Triggered) [Triggered by another spell] (Mage/Arcane, Mage/Fire, Mage/Frost)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (35009, 0, 0x00000040, 'Invisibility (Triggered)');

-- 114664: Incantation of Swiftness [Spec baseline spell] (Mage/Arcane)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (114664, 0, 0x00000040, 'Incantation of Swiftness');

-- 257190: Arcane Missiles! [Spec baseline spell] (Mage/Arcane, Mage/Fire)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (257190, 0, 0x00000040, 'Arcane Missiles!');


-- ==========================================================================
-- Monk (6 spells)
-- ==========================================================================

-- 152173: Serenity [Hero/Class trait] (Monk/Brewmaster, Monk/Mistweaver, Monk/Windwalker)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (152173, 0, 0x00000040, 'Serenity');

-- 191837: Essence Font [Hero/Class trait] (Monk/Brewmaster, Monk/Mistweaver, Monk/Windwalker)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (191837, 0, 0x00000040, 'Essence Font');

-- 210802: Spirit of the Crane [Talent] (Monk/Mistweaver)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (210802, 0, 0, 'Spirit of the Crane');

-- 314486: Invoke Chi-Ji (Triggered) [Triggered by another spell] (Monk/Brewmaster, Monk/Mistweaver, Monk/Windwalker)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (314486, 0, 0x00000040, 'Invoke Chi-Ji (Triggered)');

-- 388047: Blackout Combo [Hero/Class trait] (Monk/Brewmaster, Monk/Mistweaver, Monk/Windwalker)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (388047, 0, 0x00000040, 'Blackout Combo');

-- 388686: Attenuation [Hero/Class trait] (Monk/Brewmaster, Monk/Mistweaver, Monk/Windwalker)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (388686, 0, 0x00000040, 'Attenuation');


-- ==========================================================================
-- Paladin (3 spells)
-- ==========================================================================

-- 152262: Seraphim [Talent] (Paladin/Holy, Paladin/Protection, Paladin/Retribution)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (152262, 0, 0, 'Seraphim');

-- 337287: Avenging Wrath (Holy) [Spec baseline spell] (Paladin/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (337287, 0, 0x00000040, 'Avenging Wrath (Holy)');

-- 344172: Shining Light [Spec baseline spell] (Paladin/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (344172, 0, 0x00000040, 'Shining Light');


-- ==========================================================================
-- Priest (8 spells)
-- ==========================================================================

-- 41967: Focused Will (Triggered) [Triggered by another spell] (Priest/Discipline, Priest/Holy, Priest/Shadow)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (41967, 0, 0x00000040, 'Focused Will (Triggered)');

-- 129250: Power Word: Solace [Talent] (Priest/Discipline, Priest/Holy, Priest/Shadow)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (129250, 0, 0, 'Power Word: Solace');

-- 194248: Void Torrent [Spec baseline spell] (Priest/Shadow)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (194248, 0, 0x00000040, 'Void Torrent');

-- 205369: Mind Bomb [Talent] (Priest/Shadow)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (205369, 0, 0, 'Mind Bomb');

-- 205385: Shadow Crash [Talent] (Priest/Shadow)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (205385, 0, 0, 'Shadow Crash');

-- 246287: Evangelism [Talent] (Priest/Discipline)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (246287, 0, 0, 'Evangelism');

-- 319952: Surrender to Madness [Talent] (Priest/Shadow)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (319952, 0, 0, 'Surrender to Madness');

-- 341385: Damnation [Talent] (Priest/Shadow)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (341385, 0, 0, 'Damnation');


-- ==========================================================================
-- Rogue (7 spells)
-- ==========================================================================

-- 14062: Nightstalker [Talent] (Rogue/Assassination, Rogue/Outlaw, Rogue/Subtlety)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (14062, 0, 0, 'Nightstalker');

-- 121411: Crimson Tempest [Talent] (Rogue/Assassination)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (121411, 0, 0, 'Crimson Tempest');

-- 154904: Exsanguinate [Talent] (Rogue/Assassination)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (154904, 0, 0, 'Exsanguinate');

-- 196924: Ghostly Strike [Talent] (Rogue/Outlaw)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (196924, 0, 0, 'Ghostly Strike');

-- 196937: Killing Spree [Talent] (Rogue/Outlaw)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (196937, 0, 0, 'Killing Spree');

-- 200806: Exsanguinate [Talent] (Rogue/Assassination)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (200806, 0, 0, 'Exsanguinate');

-- 385835: Blade Flurry (Triggered) [Triggered by another spell] (Rogue/Outlaw)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (385835, 0, 0x00000040, 'Blade Flurry (Triggered)');


-- ==========================================================================
-- Shaman (11 spells)
-- ==========================================================================

-- 157153: Cloudburst Totem [Talent] (Shaman/Elemental, Shaman/Enhancement, Shaman/Restoration)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (157153, 0, 0, 'Cloudburst Totem');

-- 188089: Earthen Spike [Talent] (Shaman/Enhancement)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (188089, 0, 0, 'Earthen Spike');

-- 262303: Mana Tide Totem [Talent] (Shaman/Elemental, Shaman/Enhancement, Shaman/Restoration)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (262303, 0, 0, 'Mana Tide Totem');

-- 280609: Earthen Rage [Spec baseline spell] (Shaman/Elemental)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (280609, 0, 0x00000040, 'Earthen Rage');

-- 320125: Echoing Shock [Talent] (Shaman/Elemental)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (320125, 0, 0, 'Echoing Shock');

-- 342244: Surge of Power (Triggered) [Triggered by another spell] (Shaman/Elemental)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (342244, 0, 0x00000040, 'Surge of Power (Triggered)');

-- 381743: Seasoned Winds [Hero/Class trait] (Shaman/Elemental, Shaman/Enhancement, Shaman/Restoration)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (381743, 0, 0x00000040, 'Seasoned Winds');

-- 381764: Enhanced Imbues [Hero/Class trait] (Shaman/Elemental, Shaman/Enhancement, Shaman/Restoration)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (381764, 0, 0x00000040, 'Enhanced Imbues');

-- 382685: Lightning Rod [Hero/Class trait] (Shaman/Elemental, Shaman/Enhancement, Shaman/Restoration)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (382685, 0, 0x00000040, 'Lightning Rod');

-- 404015: Volcanic Surge [Hero/Class trait] (Shaman/Elemental, Shaman/Enhancement, Shaman/Restoration)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (404015, 0, 0x00000040, 'Volcanic Surge');

-- 472916: Restoration Shaman Passive [Spec baseline spell] (Shaman/Restoration)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (472916, 0, 0x00000040, 'Restoration Shaman Passive');


-- ==========================================================================
-- Warlock (1 spells)
-- ==========================================================================

-- 390173: Summon Soulkeeper [Hero/Class trait] (Warlock/Affliction, Warlock/Demonology, Warlock/Destruction)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (390173, 0, 0x00000040, 'Summon Soulkeeper');


-- ==========================================================================
-- Warrior (57 spells)
-- ==========================================================================

-- 12880: Enrage (Triggered) [Triggered by another spell] (Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (12880, 0, 0x00000040, 'Enrage (Triggered)');

-- 152277: Ravager [Talent] (Warrior/Arms)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (152277, 0, 0, 'Ravager');

-- 197690: Defensive Stance [Talent] (Warrior/Arms)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (197690, 0, 0, 'Defensive Stance');

-- 202751: Reckless Abandon [Talent] (Warrior/Fury)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (202751, 0, 0, 'Reckless Abandon');

-- 215571: Frenzy [Talent] (Warrior/Fury)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (215571, 0, 0, 'Frenzy');

-- 316733: Lord of War [Talent] (Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (316733, 0, 0, 'Lord of War');

-- 346002: Annihilator [Talent] (Warrior/Fury)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (346002, 0, 0, 'Annihilator');

-- 382461: Endurance Training [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (382461, 0, 0x00000040, 'Endurance Training');

-- 391270: Honed Reflexes [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (391270, 0, 0x00000040, 'Honed Reflexes');

-- 400321: Thunder Blast [Trait reference] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (400321, 0, 0x00000040, 'Thunder Blast');

-- 414454: Colossal Might [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (414454, 0, 0x00000040, 'Colossal Might');

-- 414455: Demolish [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (414455, 0, 0x00000040, 'Demolish');

-- 414457: Mountain of Muscle and Scars [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (414457, 0, 0x00000040, 'Mountain of Muscle and Scars');

-- 414458: Arterial Bleed [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (414458, 0, 0x00000040, 'Arterial Bleed');

-- 414479: One Against Many [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (414479, 0, 0x00000040, 'One Against Many');

-- 414497: No Stranger to Pain [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (414497, 0, 0x00000040, 'No Stranger to Pain');

-- 414516: Dominance of the Colossus [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (414516, 0, 0x00000040, 'Dominance of the Colossus');

-- 414711: Eyes of the Colossus [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (414711, 0, 0x00000040, 'Eyes of the Colossus');

-- 414809: Practiced Strikes [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (414809, 0, 0x00000040, 'Practiced Strikes');

-- 415016: Earthquaker [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (415016, 0, 0x00000040, 'Earthquaker');

-- 415021: Tide of Battle [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (415021, 0, 0x00000040, 'Tide of Battle');

-- 415157: Boneshaker [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (415157, 0, 0x00000040, 'Boneshaker');

-- 415488: Storm Bolts [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (415488, 0, 0x00000040, 'Storm Bolts');

-- 415633: Keeper of the Forge [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (415633, 0, 0x00000040, 'Keeper of the Forge');

-- 415648: Lightning Strikes [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (415648, 0, 0x00000040, 'Lightning Strikes');

-- 415835: Steadfast as the Peaks [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (415835, 0, 0x00000040, 'Steadfast as the Peaks');

-- 415883: Avatar of the Storm [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (415883, 0, 0x00000040, 'Avatar of the Storm');

-- 416133: Crashing Thunder [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (416133, 0, 0x00000040, 'Crashing Thunder');

-- 416156: Snap Induction [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (416156, 0, 0x00000040, 'Snap Induction');

-- 416166: Ground Current [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (416166, 0, 0x00000040, 'Ground Current');

-- 416170: Flashing Skies [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (416170, 0, 0x00000040, 'Flashing Skies');

-- 416210: Thorim Fury [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (416210, 0, 0x00000040, 'Thorim Fury');

-- 416326: Thunder Blast [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (416326, 0, 0x00000040, 'Thunder Blast');

-- 416788: Overwhelming Force [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (416788, 0, 0x00000040, 'Overwhelming Force');

-- 416790: Unstoppable Force [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (416790, 0, 0x00000040, 'Unstoppable Force');

-- 416792: Precise Might [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (416792, 0, 0x00000040, 'Precise Might');

-- 416881: Veteran Vitality [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (416881, 0, 0x00000040, 'Veteran Vitality');

-- 416887: Titan Reach [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (416887, 0, 0x00000040, 'Titan Reach');

-- 418107: Storm Shield [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (418107, 0, 0x00000040, 'Storm Shield');

-- 418120: Gathering Clouds [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (418120, 0, 0x00000040, 'Gathering Clouds');

-- 418129: Strength of the Mountain [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (418129, 0, 0x00000040, 'Strength of the Mountain');

-- 418158: Storm Swell [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (418158, 0, 0x00000040, 'Storm Swell');

-- 418243: Burst of Power [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (418243, 0, 0x00000040, 'Burst of Power');

-- 418244: Forge Strength [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (418244, 0, 0x00000040, 'Forge Strength');

-- 418507: Slayer Strike [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (418507, 0, 0x00000040, 'Slayer Strike');

-- 418787: Reap the Storm [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (418787, 0, 0x00000040, 'Reap the Storm');

-- 418812: Imminent Demise [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (418812, 0, 0x00000040, 'Imminent Demise');

-- 418824: Vicious Agility [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (418824, 0, 0x00000040, 'Vicious Agility');

-- 418833: Culling Cyclone [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (418833, 0, 0x00000040, 'Culling Cyclone');

-- 418857: Brutal Finish [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (418857, 0, 0x00000040, 'Brutal Finish');

-- 418962: Unrelenting Onslaught [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (418962, 0, 0x00000040, 'Unrelenting Onslaught');

-- 418975: Slayer Dominance [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (418975, 0, 0x00000040, 'Slayer Dominance');

-- 418996: Death Dealer [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (418996, 0, 0x00000040, 'Death Dealer');

-- 419051: Fierce Followthrough [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (419051, 0, 0x00000040, 'Fierce Followthrough');

-- 419068: Opportunist [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (419068, 0, 0x00000040, 'Opportunist');

-- 419071: Marked for Execution [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (419071, 0, 0x00000040, 'Marked for Execution');

-- 419072: Show No Mercy [Hero/Class trait] (Warrior/Arms, Warrior/Fury, Warrior/Protection)
INSERT IGNORE INTO `serverside_spell` (`Id`, `DifficultyID`, `Attributes`, `SpellName`) VALUES (419072, 0, 0x00000040, 'Show No Mercy');

