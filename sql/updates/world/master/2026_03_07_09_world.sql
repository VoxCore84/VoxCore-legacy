-- ============================================================================
-- spell_proc fixes for YELLOW/RED audit spells with proc mechanics
-- Generated from audit_reports/ per-spec JSONs + SpellAuraOptions/SpellEffect CSVs
-- Date: 2026-03-07
--
-- Source data:
--   SpellAuraOptions-enUS.csv (build 66263) -> ProcTypeMask_0, ProcTypeMask_1, ProcChance, ProcCategoryRecovery
--   SpellEffect-enUS.csv (build 66263) -> Effect, EffectAura, EffectTriggerSpell
--   SpellClassOptions-enUS.csv (build 66263) -> SpellClassSet (= SpellFamilyName)
--   SpellMisc-enUS.csv (build 66263) -> SchoolMask
--
-- Notes:
--   - ProcFlags = SpellAuraOptions.ProcTypeMask_0
--   - ProcFlags2 = SpellAuraOptions.ProcTypeMask_1
--   - Chance: 101 = "use DB2 default" (server reads from SpellAuraOptions), 0 = same
--   - SpellPhaseMask: 0x2 = HIT (default for damage/heal procs), 0x1 = CAST
--   - SpellTypeMask: 0x1 = DAMAGE, 0x2 = HEAL, 0x4 = NO_DMG_HEAL, 0x7 = ALL
--   - HitMask: 0x0 = use defaults (NORMAL|CRITICAL for TAKEN, +ABSORB for DONE)
--
-- Spells EXCLUDED (need C++ scripts, not spell_proc entries):
--   236058 (Frenetic Speed) - No ProcTypeMask in SpellAuraOptions, Mage
--   441219 (Diverted Power) - No ProcTypeMask in SpellAuraOptions, Evoker
--   462368 (Elemental Resistance) - No ProcTypeMask in SpellAuraOptions, Shaman
--   433674 (Light's Deliverance) - No ProcTypeMask, has CumulativeAura=60, Paladin
--
-- Spells EXCLUDED (already have correct spell_proc entries):
--   184783 (Tactician) - Warrior, handled in 2026_02_16_02_world.sql
--   197125 (Chaos Strike) - Demon Hunter, handled in sql/old/11.x 2025_01_16_02_world.sql
-- ============================================================================

-- ============================================================
-- Class: Warrior (SpellFamilyName = 4)
-- ============================================================

-- Spell 444767 - Slayer's Dominance
-- Warrior Arms/Fury hero talent (Slayer). Procs on melee ability and harmful ability hits.
-- ProcTypeMask_0 = 0x00001010 (DEAL_MELEE_ABILITY | DEAL_HARMFUL_ABILITY)
-- ProcChance = 101 (use DB2 default), ProcCategoryRecovery = 500ms
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=15)
-- All effects are aura 42 (PROC_TRIGGER_SPELL) with no explicit TriggerSpell - needs C++ handler
-- SpellPhaseMask = 0x2 (HIT) since it triggers on dealing damage
DELETE FROM `spell_proc` WHERE `SpellId` = 444767;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(444767,0x00,4,0x00000000,0x00000000,0x00000000,0x00000000,0x00001010,0x0,0x1,0x2,0x0,0x0,0x0,0,0,500,0); -- Slayer's Dominance

-- ============================================================
-- Class: Hunter (SpellFamilyName = 9)
-- ============================================================

-- Spell 199532 - Killer Cobra
-- Hunter Beast Mastery talent. Procs on ranged auto-attack and ranged ability.
-- ProcTypeMask_0 = 0x00000140 (DEAL_RANGED_ATTACK | DEAL_RANGED_ABILITY)
-- ProcChance = 100, no cooldown
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=100)
-- Resets Kill Command cooldown while Bestial Wrath is active
DELETE FROM `spell_proc` WHERE `SpellId` = 199532;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(199532,0x00,9,0x00000000,0x00000000,0x00000000,0x00000000,0x00000140,0x0,0x1,0x2,0x0,0x0,0x0,0,100,0,0); -- Killer Cobra

-- Spell 1262409 - Lethal Calibration
-- Hunter hero talent (Dark Ranger). Procs on melee/ranged/harmful ability and harmful spell.
-- ProcTypeMask_0 = 0x00011110 (DEAL_MELEE_ABILITY | DEAL_RANGED_ABILITY | DEAL_HARMFUL_ABILITY | DEAL_HARMFUL_SPELL)
-- ProcChance = 100, no cooldown
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=2000)
-- Effect 1: APPLY_AURA DUMMY (bp=5)
DELETE FROM `spell_proc` WHERE `SpellId` = 1262409;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(1262409,0x00,9,0x00000000,0x00000000,0x00000000,0x00000000,0x00011110,0x0,0x1,0x2,0x0,0x0,0x0,0,100,0,0); -- Lethal Calibration

-- ============================================================
-- Class: Paladin (SpellFamilyName = 10)
-- ============================================================

-- Spell 402912 - Righteous Cause
-- Paladin trait. Procs on CAST_SUCCESSFUL (ProcFlags2 = 0x4).
-- ProcTypeMask_0 = 0, ProcTypeMask_1 = 4 (PROC_FLAG_2_CAST_SUCCESSFUL)
-- ProcChance = 100, ProcCategoryRecovery = 1000ms
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=6)
DELETE FROM `spell_proc` WHERE `SpellId` = 402912;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(402912,0x00,10,0x00000000,0x00000000,0x00000000,0x00000000,0x0,0x4,0x0,0x1,0x0,0x0,0x0,0,100,1000,0); -- Righteous Cause

-- Spell 403530 - Punishment
-- Paladin trait. Procs on melee/ranged/harmful ability and harmful spell hits.
-- ProcTypeMask_0 = 0x00011110 (DEAL_MELEE_ABILITY | DEAL_RANGED_ABILITY | DEAL_HARMFUL_ABILITY | DEAL_HARMFUL_SPELL)
-- ProcChance = 100, no cooldown
-- Effect 0: ENERGIZE (type 35, not APPLY_AURA)
-- Effect 1: APPLY_AURA PROC_TRIGGER_SPELL (bp=0)
-- Note: 2026_02_25_57_world.sql has an UPDATE setting SpellPhaseMask=0x4 but there may
-- be no base row. This INSERT ensures the row exists with correct flags.
DELETE FROM `spell_proc` WHERE `SpellId` = 403530;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(403530,0x00,10,0x00000000,0x00000000,0x00000000,0x00000000,0x00011110,0x0,0x1,0x2,0x0,0x0,0x0,0,100,0,0); -- Punishment

-- Spell 404357 - Guided Prayer
-- Paladin Holy trait. Procs when TAKING damage (melee, ranged, spell, periodic).
-- ProcTypeMask_0 = 0x800A22A8 (TAKE_MELEE_SWING | TAKE_MELEE_ABILITY | TAKE_RANGED_ATTACK |
--   TAKE_RANGED_ABILITY | TAKE_HARMFUL_ABILITY | TAKE_HARMFUL_SPELL | TAKE_HARMFUL_PERIODIC |
--   TAKE_HELPFUL_PERIODIC)
-- ProcChance = 100, ProcCategoryRecovery = 60000ms (60s ICD)
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=25)
-- Effect 1: APPLY_AURA DUMMY (bp=60)
DELETE FROM `spell_proc` WHERE `SpellId` = 404357;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(404357,0x00,10,0x00000000,0x00000000,0x00000000,0x00000000,0x800A22A8,0x0,0x1,0x2,0x0,0x0,0x0,0,100,60000,0); -- Guided Prayer

-- Spell 431533 - Shake the Heavens
-- Paladin trait. Procs on CAST_SUCCESSFUL (ProcFlags2 = 0x4).
-- ProcTypeMask_0 = 0, ProcTypeMask_1 = 4
-- ProcChance = 100, no cooldown
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=1, stacking counter)
DELETE FROM `spell_proc` WHERE `SpellId` = 431533;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(431533,0x00,10,0x00000000,0x00000000,0x00000000,0x00000000,0x0,0x4,0x0,0x1,0x0,0x0,0x0,0,100,0,0); -- Shake the Heavens

-- Spell 431551 - Wrathful Descent
-- Paladin trait. Procs on melee ability (DEAL_MELEE_ABILITY).
-- ProcTypeMask_0 = 0x00000010 (DEAL_MELEE_ABILITY)
-- ProcChance = 100, no cooldown
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=50)
-- Effect 1: APPLY_AURA DUMMY (bp=50)
-- Effect 2: APPLY_AURA DUMMY (bp=20)
DELETE FROM `spell_proc` WHERE `SpellId` = 431551;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(431551,0x00,10,0x00000000,0x00000000,0x00000000,0x00000000,0x00000010,0x0,0x1,0x2,0x0,0x0,0x0,0,100,0,0); -- Wrathful Descent

-- Spell 431687 - Higher Calling
-- Paladin trait. Procs on CAST_SUCCESSFUL (ProcFlags2 = 0x4).
-- ProcTypeMask_0 = 0, ProcTypeMask_1 = 4
-- ProcChance = 100, no cooldown
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=1, stacking counter)
DELETE FROM `spell_proc` WHERE `SpellId` = 431687;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(431687,0x00,10,0x00000000,0x00000000,0x00000000,0x00000000,0x0,0x4,0x0,0x1,0x0,0x0,0x0,0,100,0,0); -- Higher Calling

-- Spell 432463 - Hammerfall
-- Paladin trait. Procs on melee/helpful/harmful ability and helpful/harmful spell.
-- ProcTypeMask_0 = 0x00015410 (DEAL_MELEE_ABILITY | DEAL_HELPFUL_ABILITY | DEAL_HARMFUL_ABILITY |
--   DEAL_HELPFUL_SPELL | DEAL_HARMFUL_SPELL)
-- ProcChance = 100, ProcCategoryRecovery = 100ms
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=0)
DELETE FROM `spell_proc` WHERE `SpellId` = 432463;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(432463,0x00,10,0x00000000,0x00000000,0x00000000,0x00000000,0x00015410,0x0,0x7,0x2,0x0,0x0,0x0,0,100,100,0); -- Hammerfall

-- Spell 432977 - Sanctification
-- Paladin trait. Procs on CAST_SUCCESSFUL (ProcFlags2 = 0x4).
-- ProcTypeMask_0 = 0, ProcTypeMask_1 = 4
-- ProcChance = 101 (use DB2 default), no cooldown
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=0)
DELETE FROM `spell_proc` WHERE `SpellId` = 432977;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(432977,0x00,10,0x00000000,0x00000000,0x00000000,0x00000000,0x0,0x4,0x0,0x1,0x0,0x0,0x0,0,0,0,0); -- Sanctification

-- Spell 1241358 - Empyrean Legacy
-- Paladin Retribution hero talent (Templar). Procs on melee/harmful ability and harmful spell.
-- ProcTypeMask_0 = 0x00011010 (DEAL_MELEE_ABILITY | DEAL_HARMFUL_ABILITY | DEAL_HARMFUL_SPELL)
-- ProcChance = 100, no cooldown
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=0)
-- Effect 1: TRIGGER_SPELL (bp=30)
DELETE FROM `spell_proc` WHERE `SpellId` = 1241358;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(1241358,0x00,10,0x00000000,0x00000000,0x00000000,0x00000000,0x00011010,0x0,0x1,0x2,0x0,0x0,0x0,0,100,0,0); -- Empyrean Legacy

-- ============================================================
-- Class: Priest (SpellFamilyName = 6)
-- ============================================================

-- Spell 390972 - Twist of Fate
-- Priest talent (all specs). Procs on dealing any damage/healing (broad mask).
-- ProcTypeMask_0 = 0x00255554 (DEAL_MELEE_SWING | DEAL_MELEE_ABILITY | DEAL_RANGED_ATTACK |
--   DEAL_RANGED_ABILITY | DEAL_HELPFUL_ABILITY | DEAL_HARMFUL_ABILITY | DEAL_HELPFUL_SPELL |
--   DEAL_HARMFUL_SPELL | DEAL_HARMFUL_PERIODIC | DEAL_HELPFUL_PERIODIC)
-- ProcChance = 101 (use DB2 default), ProcCategoryRecovery = 500ms
-- Effect 0: APPLY_AURA MOD_HEALING_DONE_PCT (bp=5, school=3/Holy)
-- Effect 1: APPLY_AURA MOD_HEALING_DONE_PCT (bp=5, school=12/Nature+Arcane)
-- Effect 2: APPLY_AURA PROC_TRIGGER_SPELL (bp=35)
-- Effect 3: nothing (bp=35)
-- Triggers on dealing damage/healing to targets below 35% health
DELETE FROM `spell_proc` WHERE `SpellId` = 390972;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(390972,0x00,6,0x00000000,0x00000000,0x00000000,0x00000000,0x00255554,0x0,0x3,0x2,0x0,0x0,0x0,0,0,500,0); -- Twist of Fate

-- ============================================================
-- Class: Shaman (SpellFamilyName = 11)
-- ============================================================

-- Spell 382309 - Ancestral Awakening
-- Shaman Restoration trait. Procs on dealing helpful ability and helpful spell (healing).
-- ProcTypeMask_0 = 0x00004400 (DEAL_HELPFUL_ABILITY | DEAL_HELPFUL_SPELL)
-- ProcChance = 100, no cooldown
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=15)
-- Effect 1: APPLY_AURA DUMMY (bp=30)
-- Effect 2: APPLY_AURA DUMMY (bp=60)
-- When a healing spell critically hits, triggers Ancestral Awakening heal
DELETE FROM `spell_proc` WHERE `SpellId` = 382309;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(382309,0x00,11,0x00000000,0x00000000,0x00000000,0x00000000,0x00004400,0x0,0x2,0x2,0x2,0x0,0x0,0,100,0,0); -- Ancestral Awakening (HitMask=CRITICAL)

-- ============================================================
-- Class: Death Knight (SpellFamilyName = 15)
-- ============================================================

-- Spell 433901 - Vampiric Strike
-- Death Knight hero talent (San'layn). Procs on melee ability and harmful spell.
-- ProcTypeMask_0 = 0x00010010 (DEAL_MELEE_ABILITY | DEAL_HARMFUL_SPELL)
-- ProcChance = 100, no cooldown
-- SchoolMask = 0x20 (Shadow)
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=25)
DELETE FROM `spell_proc` WHERE `SpellId` = 433901;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(433901,0x00,15,0x00000000,0x00000000,0x00000000,0x00000000,0x00010010,0x0,0x1,0x2,0x0,0x0,0x0,0,100,0,0); -- Vampiric Strike

-- Spell 434143 - Infliction of Sorrow
-- Death Knight hero talent (San'layn). Procs on melee ability.
-- ProcTypeMask_0 = 0x00000010 (DEAL_MELEE_ABILITY)
-- ProcChance = 100, no cooldown
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=100)
-- Effect 1: APPLY_AURA DUMMY (bp=10)
-- Effect 2: APPLY_AURA DUMMY (bp=3000)
-- Effect 3: APPLY_AURA PROC_TRIGGER_SPELL (bp=50)
-- Effect 4: APPLY_AURA DUMMY (bp=3000)
-- Effect 5: APPLY_AURA DUMMY (bp=30)
DELETE FROM `spell_proc` WHERE `SpellId` = 434143;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(434143,0x00,15,0x00000000,0x00000000,0x00000000,0x00000000,0x00000010,0x0,0x1,0x2,0x0,0x0,0x0,0,100,0,0); -- Infliction of Sorrow

-- Spell 434260 - The Blood is Life
-- Death Knight hero talent (San'layn). Procs on CAST_SUCCESSFUL (ProcFlags2 = 0x4).
-- ProcTypeMask_0 = 0, ProcTypeMask_1 = 4 (PROC_FLAG_2_CAST_SUCCESSFUL)
-- ProcChance = 101 (use DB2 default), ProcCategoryRecovery = 1000ms
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=25)
-- Effect 1: APPLY_AURA DUMMY (bp=15)
-- Effect 2: TRIGGER_SPELL (bp=8)
DELETE FROM `spell_proc` WHERE `SpellId` = 434260;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(434260,0x00,15,0x00000000,0x00000000,0x00000000,0x00000000,0x0,0x4,0x0,0x1,0x0,0x0,0x0,0,0,1000,0); -- The Blood is Life

-- Spell 435010 - Icy Death Torrent
-- Death Knight hero talent (Rider of the Apocalypse). Procs on melee auto-attack.
-- ProcTypeMask_0 = 0x00000004 (DEAL_MELEE_SWING)
-- ProcChance = 100, no cooldown
-- SchoolMask = 0x10 (Frost)
-- Effect 0: APPLY_AURA PROC_TRIGGER_SPELL (bp=20)
DELETE FROM `spell_proc` WHERE `SpellId` = 435010;
INSERT INTO `spell_proc` (`SpellId`,`SchoolMask`,`SpellFamilyName`,`SpellFamilyMask0`,`SpellFamilyMask1`,`SpellFamilyMask2`,`SpellFamilyMask3`,`ProcFlags`,`ProcFlags2`,`SpellTypeMask`,`SpellPhaseMask`,`HitMask`,`AttributesMask`,`DisableEffectsMask`,`ProcsPerMinute`,`Chance`,`Cooldown`,`Charges`) VALUES
(435010,0x00,15,0x00000000,0x00000000,0x00000000,0x00000000,0x00000004,0x0,0x1,0x2,0x0,0x0,0x0,0,100,0,0); -- Icy Death Torrent
