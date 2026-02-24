/* ================================================================== */
/* GENRE 3A v2 — Spell table warning cleanup                          */
/* TrinityCore Midnight 12.x (TWW 11.1.7)                            */
/*                                                                    */
/* Removes invalid spell references from:                             */
/*   spell_group, spell_proc, spell_pet_auras,                       */
/*   spell_linked_spell, spell_group_stack_rules                     */
/*                                                                    */
/* v2 fixes:                                                          */
/*   - Removed embedded GitHub review comment (syntax error)          */
/*   - DDL (backup tables) BEFORE START TRANSACTION                   */
/*   - Added @APPLY_FIX dry-run support                               */
/*   - COALESCE on session variable restores                          */
/*   - ROW_COUNT() captured before DEALLOCATE PREPARE                 */
/*                                                                    */
/* SET @APPLY_FIX := 0 for dry-run diagnostics only.                  */
/* SET @APPLY_FIX := 1 to apply mutations.                            */
/*                                                                    */
/* IMPORTANT: Run the COMPLETE file. Do not paste fragments.          */
/* ================================================================== */

USE `world`;
SELECT DATABASE() AS active_database;

SET @APPLY_FIX := 1;

/* ── Session snapshot ────────────────────────────────────────────── */
SET @OLD_SQL_SAFE_UPDATES   := COALESCE(@@SQL_SAFE_UPDATES, 1);
SET @OLD_FOREIGN_KEY_CHECKS := COALESCE(@@FOREIGN_KEY_CHECKS, 1);
SET @OLD_UNIQUE_CHECKS      := COALESCE(@@UNIQUE_CHECKS, 1);
SET @OLD_AUTOCOMMIT         := COALESCE(@@AUTOCOMMIT, 1);

SET SQL_SAFE_UPDATES  = 0;
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS      = 0;
SET AUTOCOMMIT         = 0;

/* ================================================================== */
/* BAD SPELL / PAIR / GROUP LISTS                                     */
/* ================================================================== */
SELECT 'LOADING BAD SPELL LISTS' AS section;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_bad_spells (
  spellId BIGINT PRIMARY KEY
) ENGINE=Memory;
TRUNCATE TABLE tmp_bad_spells;

INSERT IGNORE INTO tmp_bad_spells (spellId) VALUES
(2380),(17629),(42735),(62380),(67016),(67017),(67018),
(20784),(33127),(42770),(79577),(115768),(262507),(370783),(370818),(373835),(383192),(383394),(383958),(383977),(386034),(392303),(408575),(470053),(470058),
(41637),(42965),(47960),(54501),(59907),(63230),(73015),(77767),(191840),(396719),
(20895);

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_bad_linked_pairs (
  triggerId BIGINT NOT NULL,
  effectId BIGINT NOT NULL,
  PRIMARY KEY (triggerId, effectId)
) ENGINE=Memory;
TRUNCATE TABLE tmp_bad_linked_pairs;

INSERT IGNORE INTO tmp_bad_linked_pairs (triggerId, effectId) VALUES
(92237,92237),
(364343,364343),
(383762,383762);

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_bad_group_ids (
  groupId BIGINT PRIMARY KEY
) ENGINE=Memory;
TRUNCATE TABLE tmp_bad_group_ids;

INSERT IGNORE INTO tmp_bad_group_ids (groupId) VALUES (2500);

/* ================================================================== */
/* PREREQUISITES — detect tables + columns                            */
/* ================================================================== */
SELECT 'PREREQUISITES' AS section;

/* ── spell_group ─────────────────────────────────────────────────── */
SET @spell_group_exists := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_group');

SET @spell_group_col := NULL;
SET @sql := IF(@spell_group_exists = 1,
  "SELECT COLUMN_NAME INTO @spell_group_col FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_group'
     AND COLUMN_NAME IN ('spell_id','spellId','spell','SpellID','SpellId')
   ORDER BY FIELD(COLUMN_NAME,'spell_id','spellId','spell','SpellID','SpellId') LIMIT 1",
  "SET @spell_group_col := NULL");
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @can_spell_group := IF(@spell_group_exists = 1 AND @spell_group_col IS NOT NULL, 1, 0);

/* ── spell_proc ──────────────────────────────────────────────────── */
SET @spell_proc_exists := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_proc');

SET @spell_proc_col := NULL;
SET @sql := IF(@spell_proc_exists = 1,
  "SELECT COLUMN_NAME INTO @spell_proc_col FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_proc'
     AND COLUMN_NAME IN ('SpellId','SpellID','spell_id','spellId','spell')
   ORDER BY FIELD(COLUMN_NAME,'SpellId','SpellID','spell_id','spellId','spell') LIMIT 1",
  "SET @spell_proc_col := NULL");
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @can_spell_proc := IF(@spell_proc_exists = 1 AND @spell_proc_col IS NOT NULL, 1, 0);

/* ── spell_pet_auras ─────────────────────────────────────────────── */
SET @spell_pet_auras_exists := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_pet_auras');

SET @spell_pet_auras_col := NULL;
SET @sql := IF(@spell_pet_auras_exists = 1,
  "SELECT COLUMN_NAME INTO @spell_pet_auras_col FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_pet_auras'
     AND COLUMN_NAME IN ('spell','spellId','spell_id','SpellID','SpellId')
   ORDER BY FIELD(COLUMN_NAME,'spell','spellId','spell_id','SpellID','SpellId') LIMIT 1",
  "SET @spell_pet_auras_col := NULL");
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @can_spell_pet_auras := IF(@spell_pet_auras_exists = 1 AND @spell_pet_auras_col IS NOT NULL, 1, 0);

/* ── spell_linked_spell ──────────────────────────────────────────── */
SET @spell_linked_spell_exists := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell');

SET @linked_trigger_col := NULL;
SET @linked_effect_col := NULL;
SET @pair_choice := NULL;
SET @sql := IF(@spell_linked_spell_exists = 1,
  "SELECT CASE
     WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_linked_spell' AND COLUMN_NAME='spell_trigger')
      AND EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_linked_spell' AND COLUMN_NAME='spell_effect')
     THEN 'spell_trigger|spell_effect'
     WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_linked_spell' AND COLUMN_NAME='spellTrigger')
      AND EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_linked_spell' AND COLUMN_NAME='spellEffect')
     THEN 'spellTrigger|spellEffect'
     WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_linked_spell' AND COLUMN_NAME='trigger_spell')
      AND EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_linked_spell' AND COLUMN_NAME='effect_spell')
     THEN 'trigger_spell|effect_spell'
     WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_linked_spell' AND COLUMN_NAME='spell')
      AND EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_linked_spell' AND COLUMN_NAME='aura')
     THEN 'spell|aura'
     WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_linked_spell' AND COLUMN_NAME='spell')
      AND EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_linked_spell' AND COLUMN_NAME='linked_spell')
     THEN 'spell|linked_spell'
     WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_linked_spell' AND COLUMN_NAME='spell_id')
      AND EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_linked_spell' AND COLUMN_NAME='linked_spell')
     THEN 'spell_id|linked_spell'
     WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_linked_spell' AND COLUMN_NAME='spell_id')
      AND EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_linked_spell' AND COLUMN_NAME='aura')
     THEN 'spell_id|aura'
     ELSE NULL END INTO @pair_choice",
  "SET @pair_choice := NULL");
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @linked_trigger_col := IF(@pair_choice IS NULL, NULL, SUBSTRING_INDEX(@pair_choice, '|', 1));
SET @linked_effect_col  := IF(@pair_choice IS NULL, NULL, SUBSTRING_INDEX(@pair_choice, '|', -1));
SET @can_spell_linked_spell := IF(@spell_linked_spell_exists = 1 AND @linked_trigger_col IS NOT NULL AND @linked_effect_col IS NOT NULL, 1, 0);

/* ── spell_group_stack_rules ─────────────────────────────────────── */
SET @spell_group_stack_rules_exists := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_group_stack_rules');

SET @group_col := NULL;
SET @sql := IF(@spell_group_stack_rules_exists = 1,
  "SELECT COLUMN_NAME INTO @group_col FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_group_stack_rules'
     AND COLUMN_NAME IN ('group_id','groupId','groupID','id','Id')
   ORDER BY FIELD(COLUMN_NAME,'group_id','groupId','groupID','id','Id') LIMIT 1",
  "SET @group_col := NULL");
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @can_spell_group_stack_rules := IF(@spell_group_stack_rules_exists = 1 AND @group_col IS NOT NULL, 1, 0);

/* ── Status display ──────────────────────────────────────────────── */
SELECT
  IF(@can_spell_group = 1, CONCAT('OK (', @spell_group_col, ')'), 'SKIP') AS spell_group,
  IF(@can_spell_proc = 1, CONCAT('OK (', @spell_proc_col, ')'), 'SKIP') AS spell_proc,
  IF(@can_spell_pet_auras = 1, CONCAT('OK (', @spell_pet_auras_col, ')'), 'SKIP') AS spell_pet_auras,
  IF(@can_spell_linked_spell = 1, CONCAT('OK (', @pair_choice, ')'), 'SKIP') AS spell_linked_spell,
  IF(@can_spell_group_stack_rules = 1, CONCAT('OK (', @group_col, ')'), 'SKIP') AS spell_group_stack_rules;

/* ================================================================== */
/* DDL PHASE — backup tables (before transaction)                     */
/* ================================================================== */
SELECT 'BACKUP TABLE CREATION (DDL)' AS section;

SET @sql := IF(@APPLY_FIX = 1 AND @can_spell_group = 1,
  'CREATE TABLE IF NOT EXISTS `spell_group_bak_genre3a` LIKE `spell_group`',
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@APPLY_FIX = 1 AND @can_spell_proc = 1,
  'CREATE TABLE IF NOT EXISTS `spell_proc_bak_genre3a` LIKE `spell_proc`',
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@APPLY_FIX = 1 AND @can_spell_pet_auras = 1,
  'CREATE TABLE IF NOT EXISTS `spell_pet_auras_bak_genre3a` LIKE `spell_pet_auras`',
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@APPLY_FIX = 1 AND @can_spell_linked_spell = 1,
  'CREATE TABLE IF NOT EXISTS `spell_linked_spell_bak_genre3a` LIKE `spell_linked_spell`',
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@APPLY_FIX = 1 AND @can_spell_group_stack_rules = 1,
  'CREATE TABLE IF NOT EXISTS `spell_group_stack_rules_bak_genre3a` LIKE `spell_group_stack_rules`',
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* ================================================================== */
/* DML PHASE                                                          */
/* ================================================================== */
START TRANSACTION;

SET @deleted_spell_group := 0;
SET @deleted_spell_proc := 0;
SET @deleted_spell_pet_auras := 0;
SET @deleted_spell_linked_spell := 0;
SET @deleted_spell_group_stack_rules := 0;

/* ── 1) spell_group ──────────────────────────────────────────────── */
SELECT 'SPELL_GROUP CLEANUP' AS section;

SET @sg_before := 0;
SET @sql := IF(@can_spell_group = 1,
  CONCAT('SELECT COUNT(*) INTO @sg_before FROM `spell_group` WHERE `', @spell_group_col, '` IN (SELECT spellId FROM tmp_bad_spells)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_group = 1 AND @APPLY_FIX = 1 AND @sg_before > 0,
  CONCAT('INSERT IGNORE INTO `spell_group_bak_genre3a` SELECT * FROM `spell_group` WHERE `', @spell_group_col, '` IN (SELECT spellId FROM tmp_bad_spells)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_group = 1 AND @APPLY_FIX = 1 AND @sg_before > 0,
  CONCAT('DELETE FROM `spell_group` WHERE `', @spell_group_col, '` IN (SELECT spellId FROM tmp_bad_spells)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted_spell_group := IF(@can_spell_group = 1 AND @APPLY_FIX = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;

/* ── 2) spell_proc ───────────────────────────────────────────────── */
SELECT 'SPELL_PROC CLEANUP' AS section;

SET @sp_before := 0;
SET @sql := IF(@can_spell_proc = 1,
  CONCAT('SELECT COUNT(*) INTO @sp_before FROM `spell_proc` WHERE `', @spell_proc_col, '` IN (SELECT spellId FROM tmp_bad_spells)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_proc = 1 AND @APPLY_FIX = 1 AND @sp_before > 0,
  CONCAT('INSERT IGNORE INTO `spell_proc_bak_genre3a` SELECT * FROM `spell_proc` WHERE `', @spell_proc_col, '` IN (SELECT spellId FROM tmp_bad_spells)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_proc = 1 AND @APPLY_FIX = 1 AND @sp_before > 0,
  CONCAT('DELETE FROM `spell_proc` WHERE `', @spell_proc_col, '` IN (SELECT spellId FROM tmp_bad_spells)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted_spell_proc := IF(@can_spell_proc = 1 AND @APPLY_FIX = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;

/* ── 3) spell_pet_auras ──────────────────────────────────────────── */
SELECT 'SPELL_PET_AURAS CLEANUP' AS section;

SET @spa_before := 0;
SET @sql := IF(@can_spell_pet_auras = 1,
  CONCAT('SELECT COUNT(*) INTO @spa_before FROM `spell_pet_auras` WHERE `', @spell_pet_auras_col, '` IN (SELECT spellId FROM tmp_bad_spells)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_pet_auras = 1 AND @APPLY_FIX = 1 AND @spa_before > 0,
  CONCAT('INSERT IGNORE INTO `spell_pet_auras_bak_genre3a` SELECT * FROM `spell_pet_auras` WHERE `', @spell_pet_auras_col, '` IN (SELECT spellId FROM tmp_bad_spells)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_pet_auras = 1 AND @APPLY_FIX = 1 AND @spa_before > 0,
  CONCAT('DELETE FROM `spell_pet_auras` WHERE `', @spell_pet_auras_col, '` IN (SELECT spellId FROM tmp_bad_spells)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted_spell_pet_auras := IF(@can_spell_pet_auras = 1 AND @APPLY_FIX = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;

/* ── 4) spell_linked_spell ───────────────────────────────────────── */
SELECT 'SPELL_LINKED_SPELL CLEANUP' AS section;

SET @sls_before := 0;
SET @sql := IF(@can_spell_linked_spell = 1,
  CONCAT('SELECT COUNT(*) INTO @sls_before FROM `spell_linked_spell` s
          LEFT JOIN tmp_bad_spells b ON (b.spellId = s.`', @linked_trigger_col, '` OR b.spellId = s.`', @linked_effect_col, '`)
          LEFT JOIN tmp_bad_linked_pairs p ON s.`', @linked_trigger_col, '` = p.triggerId AND s.`', @linked_effect_col, '` = p.effectId
          WHERE b.spellId IS NOT NULL OR p.triggerId IS NOT NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_linked_spell = 1 AND @APPLY_FIX = 1 AND @sls_before > 0,
  CONCAT('INSERT IGNORE INTO `spell_linked_spell_bak_genre3a`
          SELECT s.* FROM `spell_linked_spell` s
          LEFT JOIN tmp_bad_spells b ON (b.spellId = s.`', @linked_trigger_col, '` OR b.spellId = s.`', @linked_effect_col, '`)
          LEFT JOIN tmp_bad_linked_pairs p ON s.`', @linked_trigger_col, '` = p.triggerId AND s.`', @linked_effect_col, '` = p.effectId
          WHERE b.spellId IS NOT NULL OR p.triggerId IS NOT NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_linked_spell = 1 AND @APPLY_FIX = 1 AND @sls_before > 0,
  CONCAT('DELETE s FROM `spell_linked_spell` s
          LEFT JOIN tmp_bad_spells b ON (b.spellId = s.`', @linked_trigger_col, '` OR b.spellId = s.`', @linked_effect_col, '`)
          LEFT JOIN tmp_bad_linked_pairs p ON s.`', @linked_trigger_col, '` = p.triggerId AND s.`', @linked_effect_col, '` = p.effectId
          WHERE b.spellId IS NOT NULL OR p.triggerId IS NOT NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted_spell_linked_spell := IF(@can_spell_linked_spell = 1 AND @APPLY_FIX = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;

/* ── 5) spell_group_stack_rules ──────────────────────────────────── */
SELECT 'SPELL_GROUP_STACK_RULES CLEANUP' AS section;

SET @sgsr_before := 0;
SET @sql := IF(@can_spell_group_stack_rules = 1,
  CONCAT('SELECT COUNT(*) INTO @sgsr_before FROM `spell_group_stack_rules` WHERE `', @group_col, '` IN (SELECT groupId FROM tmp_bad_group_ids)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_group_stack_rules = 1 AND @APPLY_FIX = 1 AND @sgsr_before > 0,
  CONCAT('INSERT IGNORE INTO `spell_group_stack_rules_bak_genre3a` SELECT * FROM `spell_group_stack_rules` WHERE `', @group_col, '` IN (SELECT groupId FROM tmp_bad_group_ids)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_group_stack_rules = 1 AND @APPLY_FIX = 1 AND @sgsr_before > 0,
  CONCAT('DELETE FROM `spell_group_stack_rules` WHERE `', @group_col, '` IN (SELECT groupId FROM tmp_bad_group_ids)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted_spell_group_stack_rules := IF(@can_spell_group_stack_rules = 1 AND @APPLY_FIX = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;


/* ================================================================== */
/* VERIFICATION                                                       */
/* ================================================================== */
SELECT 'VERIFICATION' AS section;

SET @sg_after := 0;
SET @sql := IF(@can_spell_group = 1,
  CONCAT('SELECT COUNT(*) INTO @sg_after FROM `spell_group` WHERE `', @spell_group_col, '` IN (SELECT spellId FROM tmp_bad_spells)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sp_after := 0;
SET @sql := IF(@can_spell_proc = 1,
  CONCAT('SELECT COUNT(*) INTO @sp_after FROM `spell_proc` WHERE `', @spell_proc_col, '` IN (SELECT spellId FROM tmp_bad_spells)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @spa_after := 0;
SET @sql := IF(@can_spell_pet_auras = 1,
  CONCAT('SELECT COUNT(*) INTO @spa_after FROM `spell_pet_auras` WHERE `', @spell_pet_auras_col, '` IN (SELECT spellId FROM tmp_bad_spells)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sls_after := 0;
SET @sql := IF(@can_spell_linked_spell = 1,
  CONCAT('SELECT COUNT(*) INTO @sls_after FROM `spell_linked_spell` s
          LEFT JOIN tmp_bad_spells b ON (b.spellId = s.`', @linked_trigger_col, '` OR b.spellId = s.`', @linked_effect_col, '`)
          LEFT JOIN tmp_bad_linked_pairs p ON s.`', @linked_trigger_col, '` = p.triggerId AND s.`', @linked_effect_col, '` = p.effectId
          WHERE b.spellId IS NOT NULL OR p.triggerId IS NOT NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sls_selfloops := 0;
SET @sql := IF(@can_spell_linked_spell = 1,
  CONCAT('SELECT COUNT(*) INTO @sls_selfloops FROM `spell_linked_spell`
          WHERE `', @linked_trigger_col, '` = `', @linked_effect_col, '`
          AND `', @linked_trigger_col, '` IN (92237,364343,383762)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sgsr_after := 0;
SET @sql := IF(@can_spell_group_stack_rules = 1,
  CONCAT('SELECT COUNT(*) INTO @sgsr_after FROM `spell_group_stack_rules` WHERE `', @group_col, '` IN (SELECT groupId FROM tmp_bad_group_ids)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* ================================================================== */
/* SUMMARY                                                            */
/* ================================================================== */
SELECT 'SUMMARY' AS section;

SELECT
  'spell_group'            AS table_name, @sg_before   AS bad_before, @deleted_spell_group            AS deleted, @sg_after   AS bad_after
UNION ALL SELECT
  'spell_proc',                           @sp_before,                 @deleted_spell_proc,                        @sp_after
UNION ALL SELECT
  'spell_pet_auras',                      @spa_before,                @deleted_spell_pet_auras,                   @spa_after
UNION ALL SELECT
  'spell_linked_spell',                   @sls_before,                @deleted_spell_linked_spell,                @sls_after
UNION ALL SELECT
  'spell_group_stack_rules',              @sgsr_before,               @deleted_spell_group_stack_rules,            @sgsr_after;

SELECT @sls_selfloops AS remaining_self_loops_targeted;

SELECT IF(@APPLY_FIX = 1, 'APPLIED — committing changes', 'DRY RUN — rolling back') AS mode;

/* ── Commit or rollback ──────────────────────────────────────────── */
SET @sql := IF(@APPLY_FIX = 1, 'COMMIT', 'ROLLBACK');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* ── Cleanup ─────────────────────────────────────────────────────── */
DROP TEMPORARY TABLE IF EXISTS tmp_bad_spells;
DROP TEMPORARY TABLE IF EXISTS tmp_bad_linked_pairs;
DROP TEMPORARY TABLE IF EXISTS tmp_bad_group_ids;

/* ── Restore session ─────────────────────────────────────────────── */
SET SQL_SAFE_UPDATES   = COALESCE(@OLD_SQL_SAFE_UPDATES, 1);
SET FOREIGN_KEY_CHECKS = COALESCE(@OLD_FOREIGN_KEY_CHECKS, 1);
SET UNIQUE_CHECKS      = COALESCE(@OLD_UNIQUE_CHECKS, 1);
SET AUTOCOMMIT         = COALESCE(@OLD_AUTOCOMMIT, 1);
