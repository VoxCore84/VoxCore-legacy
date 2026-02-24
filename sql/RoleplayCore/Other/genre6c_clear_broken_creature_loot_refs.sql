/* ================================================================== */
/* GENRE 6C v2 — Clear broken creature loot references                */
/* TrinityCore Midnight 12.x (TWW 11.1.7)                            */
/*                                                                    */
/* Sets lootid/pickpocketloot/skinloot → 0 on creature_template      */
/* rows whose referenced loot template entry doesn't exist.           */
/*                                                                    */
/* v2 fixes over v1:                                                  */
/*   - Removed embedded GitHub review comment (syntax error)          */
/*   - DDL (backup table) BEFORE START TRANSACTION                    */
/*   - Conditional COMMIT/ROLLBACK via @can_apply                     */
/*   - COALESCE on session variable saves/restores                    */
/*   - ROW_COUNT() gated on @can_apply (v1 captured ROW_COUNT()      */
/*     from the SKIP SELECT when @APPLY_FIX=0, reporting 1 not 0)    */
/*   - Added global cap enforcement with @FORCE_APPLY override        */
/*   - Simplified temp table creation (direct DDL, not 6× PREPARE)   */
/*                                                                    */
/* SET @APPLY_FIX := 0 for dry-run diagnostics only.                  */
/* SET @APPLY_FIX := 1 to apply mutations.                            */
/*                                                                    */
/* IMPORTANT: Run the COMPLETE file. Do not paste fragments.          */
/* ================================================================== */

SET @APPLY_FIX    := 1;
SET @MAX_UPDATE   := 50000;   /* global cap: total updates across all 3 columns */
SET @FORCE_APPLY  := 0;       /* 1 = override cap                               */

USE `world`;
SELECT DATABASE() AS active_database;

/* ── Session snapshot ────────────────────────────────────────────── */
SET @prev_sql_safe_updates   := COALESCE(@@sql_safe_updates, 1);
SET @prev_foreign_key_checks := COALESCE(@@foreign_key_checks, 1);
SET @prev_unique_checks      := COALESCE(@@unique_checks, 1);
SET @prev_autocommit         := COALESCE(@@autocommit, 1);

SET SESSION sql_safe_updates  = 0;
SET SESSION foreign_key_checks = 1;
SET SESSION unique_checks      = 1;
SET SESSION autocommit         = 0;

/* ================================================================== */
/* SCHEMA INTROSPECTION                                               */
/* ================================================================== */
SELECT 'SCHEMA INTROSPECTION' AS section;

SET @ct_exists := (SELECT COUNT(*) FROM information_schema.tables
  WHERE table_schema = 'world' AND table_name = 'creature_template');

SET @ct_pk_col := (SELECT column_name FROM information_schema.columns
  WHERE table_schema = 'world' AND table_name = 'creature_template'
    AND column_name IN ('entry', 'Entry', 'ID', 'Id')
  ORDER BY FIELD(column_name, 'entry', 'Entry', 'ID', 'Id') LIMIT 1);

SET @ct_loot_col := (SELECT column_name FROM information_schema.columns
  WHERE table_schema = 'world' AND table_name = 'creature_template'
    AND column_name IN ('lootid', 'LootId', 'lootId', 'LootID')
  ORDER BY FIELD(column_name, 'lootid', 'LootId', 'lootId', 'LootID') LIMIT 1);

SET @ct_pick_col := (SELECT column_name FROM information_schema.columns
  WHERE table_schema = 'world' AND table_name = 'creature_template'
    AND column_name IN ('pickpocketloot', 'PickpocketLoot', 'pickpocketLoot', 'PickPocketLoot')
  ORDER BY FIELD(column_name, 'pickpocketloot', 'PickpocketLoot', 'pickpocketLoot', 'PickPocketLoot') LIMIT 1);

SET @ct_skin_col := (SELECT column_name FROM information_schema.columns
  WHERE table_schema = 'world' AND table_name = 'creature_template'
    AND column_name IN ('skinloot', 'SkinLoot', 'skinLoot')
  ORDER BY FIELD(column_name, 'skinloot', 'SkinLoot', 'skinLoot') LIMIT 1);

/* Loot template tables */
SET @clt_exists := (SELECT COUNT(*) FROM information_schema.tables
  WHERE table_schema = 'world' AND table_name = 'creature_loot_template');
SET @clt_entry_col := (SELECT column_name FROM information_schema.columns
  WHERE table_schema = 'world' AND table_name = 'creature_loot_template'
    AND column_name IN ('entry', 'Entry', 'ID', 'Id')
  ORDER BY FIELD(column_name, 'entry', 'Entry', 'ID', 'Id') LIMIT 1);

SET @plt_exists := (SELECT COUNT(*) FROM information_schema.tables
  WHERE table_schema = 'world' AND table_name = 'pickpocketing_loot_template');
SET @plt_entry_col := (SELECT column_name FROM information_schema.columns
  WHERE table_schema = 'world' AND table_name = 'pickpocketing_loot_template'
    AND column_name IN ('entry', 'Entry', 'ID', 'Id')
  ORDER BY FIELD(column_name, 'entry', 'Entry', 'ID', 'Id') LIMIT 1);

SET @slt_exists := (SELECT COUNT(*) FROM information_schema.tables
  WHERE table_schema = 'world' AND table_name = 'skinning_loot_template');
SET @slt_entry_col := (SELECT column_name FROM information_schema.columns
  WHERE table_schema = 'world' AND table_name = 'skinning_loot_template'
    AND column_name IN ('entry', 'Entry', 'ID', 'Id')
  ORDER BY FIELD(column_name, 'entry', 'Entry', 'ID', 'Id') LIMIT 1);

/* Per-column prerequisites */
SET @can_fix_loot := IF(@ct_exists = 1 AND @ct_pk_col IS NOT NULL AND @ct_loot_col IS NOT NULL AND @clt_exists = 1 AND @clt_entry_col IS NOT NULL, 1, 0);
SET @can_fix_pick := IF(@ct_exists = 1 AND @ct_pk_col IS NOT NULL AND @ct_pick_col IS NOT NULL AND @plt_exists = 1 AND @plt_entry_col IS NOT NULL, 1, 0);
SET @can_fix_skin := IF(@ct_exists = 1 AND @ct_pk_col IS NOT NULL AND @ct_skin_col IS NOT NULL AND @slt_exists = 1 AND @slt_entry_col IS NOT NULL, 1, 0);

SELECT
  IF(@ct_exists = 1, 'OK', 'MISSING')  AS creature_template,
  COALESCE(@ct_pk_col, 'NOT FOUND')    AS ct_pk,
  COALESCE(@ct_loot_col, 'NOT FOUND')  AS ct_loot,
  COALESCE(@ct_pick_col, 'NOT FOUND')  AS ct_pick,
  COALESCE(@ct_skin_col, 'NOT FOUND')  AS ct_skin,
  IF(@clt_exists = 1, COALESCE(@clt_entry_col, '?'), 'MISSING') AS creature_loot_tpl,
  IF(@plt_exists = 1, COALESCE(@plt_entry_col, '?'), 'MISSING') AS pickpocket_loot_tpl,
  IF(@slt_exists = 1, COALESCE(@slt_entry_col, '?'), 'MISSING') AS skinning_loot_tpl,
  @can_fix_loot AS can_loot, @can_fix_pick AS can_pick, @can_fix_skin AS can_skin;

/* ================================================================== */
/* DDL PHASE — backup table (before transaction)                      */
/* ================================================================== */
SELECT 'BACKUP TABLE CREATION (DDL)' AS section;

SET @sql := IF(@APPLY_FIX = 1 AND @ct_exists = 1,
  'CREATE TABLE IF NOT EXISTS `world`.`creature_template_backup_genre6c` LIKE `world`.`creature_template`',
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* ================================================================== */
/* DML PHASE                                                          */
/* ================================================================== */
START TRANSACTION;

/* ── Candidate counts ────────────────────────────────────────────── */
SELECT 'DIAGNOSTICS' AS section;

SET @cand_before_loot := 0;
SET @cand_before_pick := 0;
SET @cand_before_skin := 0;
SET @updated_loot     := 0;
SET @updated_pick     := 0;
SET @updated_skin     := 0;

SET @sql := IF(@can_fix_loot = 1,
  CONCAT('SELECT COUNT(*) INTO @cand_before_loot FROM `world`.`creature_template` ct WHERE ct.`', @ct_loot_col, '` > 0 AND NOT EXISTS (SELECT 1 FROM `world`.`creature_loot_template` lt WHERE lt.`', @clt_entry_col, '` = ct.`', @ct_loot_col, '`)'),
  'SELECT 0 INTO @cand_before_loot');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_fix_pick = 1,
  CONCAT('SELECT COUNT(*) INTO @cand_before_pick FROM `world`.`creature_template` ct WHERE ct.`', @ct_pick_col, '` > 0 AND NOT EXISTS (SELECT 1 FROM `world`.`pickpocketing_loot_template` lt WHERE lt.`', @plt_entry_col, '` = ct.`', @ct_pick_col, '`)'),
  'SELECT 0 INTO @cand_before_pick');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_fix_skin = 1,
  CONCAT('SELECT COUNT(*) INTO @cand_before_skin FROM `world`.`creature_template` ct WHERE ct.`', @ct_skin_col, '` > 0 AND NOT EXISTS (SELECT 1 FROM `world`.`skinning_loot_template` lt WHERE lt.`', @slt_entry_col, '` = ct.`', @ct_skin_col, '`)'),
  'SELECT 0 INTO @cand_before_skin');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT
  @cand_before_loot AS loot_candidates,
  @cand_before_pick AS pick_candidates,
  @cand_before_skin AS skin_candidates;

/* ── Samples ─────────────────────────────────────────────────────── */
SET @sql := IF(@can_fix_loot = 1 AND @cand_before_loot > 0,
  CONCAT('SELECT ct.`', @ct_pk_col, '` AS ct_pk, ct.`', @ct_loot_col, '` AS missing_lootid FROM `world`.`creature_template` ct WHERE ct.`', @ct_loot_col, '` > 0 AND NOT EXISTS (SELECT 1 FROM `world`.`creature_loot_template` lt WHERE lt.`', @clt_entry_col, '` = ct.`', @ct_loot_col, '`) ORDER BY ct.`', @ct_pk_col, '` LIMIT 50'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_fix_pick = 1 AND @cand_before_pick > 0,
  CONCAT('SELECT ct.`', @ct_pk_col, '` AS ct_pk, ct.`', @ct_pick_col, '` AS missing_pickpocketloot FROM `world`.`creature_template` ct WHERE ct.`', @ct_pick_col, '` > 0 AND NOT EXISTS (SELECT 1 FROM `world`.`pickpocketing_loot_template` lt WHERE lt.`', @plt_entry_col, '` = ct.`', @ct_pick_col, '`) ORDER BY ct.`', @ct_pk_col, '` LIMIT 50'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_fix_skin = 1 AND @cand_before_skin > 0,
  CONCAT('SELECT ct.`', @ct_pk_col, '` AS ct_pk, ct.`', @ct_skin_col, '` AS missing_skinloot FROM `world`.`creature_template` ct WHERE ct.`', @ct_skin_col, '` > 0 AND NOT EXISTS (SELECT 1 FROM `world`.`skinning_loot_template` lt WHERE lt.`', @slt_entry_col, '` = ct.`', @ct_skin_col, '`) ORDER BY ct.`', @ct_pk_col, '` LIMIT 50'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* ── Apply decision ──────────────────────────────────────────────── */
SELECT 'APPLY DECISION' AS section;

SET @total_candidates := COALESCE(@cand_before_loot, 0) + COALESCE(@cand_before_pick, 0) + COALESCE(@cand_before_skin, 0);
SET @caps_exceeded := IF(@total_candidates > @MAX_UPDATE, 1, 0);

SET @can_apply := IF(
  @APPLY_FIX = 1 AND (@caps_exceeded = 0 OR @FORCE_APPLY = 1),
  1, 0
);

SET @cap_note :=
  CASE
    WHEN @APPLY_FIX <> 1 THEN 'DRY RUN: report-only mode (@APPLY_FIX=0).'
    WHEN @total_candidates = 0 THEN 'Apply mode: no candidates found.'
    WHEN @caps_exceeded = 1 AND @FORCE_APPLY = 0
      THEN CONCAT('BLOCKED by cap: ', @total_candidates, ' total candidates exceeds @MAX_UPDATE=', @MAX_UPDATE, '. Set @FORCE_APPLY=1 to override.')
    ELSE CONCAT('Apply mode: updating up to ', @total_candidates, ' rows across 3 columns.')
  END;

SELECT @total_candidates AS total_candidates, @cap_note AS apply_decision;

/* ── Temp key tables (direct DDL, no PREPARE overhead) ───────────── */
DROP TEMPORARY TABLE IF EXISTS tmp_fix_loot;
DROP TEMPORARY TABLE IF EXISTS tmp_fix_pick;
DROP TEMPORARY TABLE IF EXISTS tmp_fix_skin;

CREATE TEMPORARY TABLE tmp_fix_loot (pk BIGINT UNSIGNED PRIMARY KEY) ENGINE=InnoDB;
CREATE TEMPORARY TABLE tmp_fix_pick (pk BIGINT UNSIGNED PRIMARY KEY) ENGINE=InnoDB;
CREATE TEMPORARY TABLE tmp_fix_skin (pk BIGINT UNSIGNED PRIMARY KEY) ENGINE=InnoDB;

/* ── Collect candidate keys (capped by @MAX_UPDATE per column) ───── */
SET @sql := IF(@can_apply = 1 AND @can_fix_loot = 1 AND @cand_before_loot > 0,
  CONCAT('INSERT INTO tmp_fix_loot (pk) SELECT ct.`', @ct_pk_col, '` FROM `world`.`creature_template` ct WHERE ct.`', @ct_loot_col, '` > 0 AND NOT EXISTS (SELECT 1 FROM `world`.`creature_loot_template` lt WHERE lt.`', @clt_entry_col, '` = ct.`', @ct_loot_col, '`) ORDER BY ct.`', @ct_pk_col, '` LIMIT ', @MAX_UPDATE),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_apply = 1 AND @can_fix_pick = 1 AND @cand_before_pick > 0,
  CONCAT('INSERT INTO tmp_fix_pick (pk) SELECT ct.`', @ct_pk_col, '` FROM `world`.`creature_template` ct WHERE ct.`', @ct_pick_col, '` > 0 AND NOT EXISTS (SELECT 1 FROM `world`.`pickpocketing_loot_template` lt WHERE lt.`', @plt_entry_col, '` = ct.`', @ct_pick_col, '`) ORDER BY ct.`', @ct_pk_col, '` LIMIT ', @MAX_UPDATE),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_apply = 1 AND @can_fix_skin = 1 AND @cand_before_skin > 0,
  CONCAT('INSERT INTO tmp_fix_skin (pk) SELECT ct.`', @ct_pk_col, '` FROM `world`.`creature_template` ct WHERE ct.`', @ct_skin_col, '` > 0 AND NOT EXISTS (SELECT 1 FROM `world`.`skinning_loot_template` lt WHERE lt.`', @slt_entry_col, '` = ct.`', @ct_skin_col, '`) ORDER BY ct.`', @ct_pk_col, '` LIMIT ', @MAX_UPDATE),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* ── Loot: backup + update ───────────────────────────────────────── */
SET @sql := IF(@can_apply = 1 AND @can_fix_loot = 1,
  CONCAT('INSERT IGNORE INTO `world`.`creature_template_backup_genre6c` SELECT ct.* FROM `world`.`creature_template` ct INNER JOIN tmp_fix_loot t ON t.pk = ct.`', @ct_pk_col, '`'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_apply = 1 AND @can_fix_loot = 1,
  CONCAT('UPDATE `world`.`creature_template` ct INNER JOIN tmp_fix_loot t ON t.pk = ct.`', @ct_pk_col, '` SET ct.`', @ct_loot_col, '` = 0'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt;
SET @updated_loot := IF(@can_apply = 1, ROW_COUNT(), 0);
DEALLOCATE PREPARE stmt;

/* ── Pickpocket: backup + update ─────────────────────────────────── */
SET @sql := IF(@can_apply = 1 AND @can_fix_pick = 1,
  CONCAT('INSERT IGNORE INTO `world`.`creature_template_backup_genre6c` SELECT ct.* FROM `world`.`creature_template` ct INNER JOIN tmp_fix_pick t ON t.pk = ct.`', @ct_pk_col, '`'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_apply = 1 AND @can_fix_pick = 1,
  CONCAT('UPDATE `world`.`creature_template` ct INNER JOIN tmp_fix_pick t ON t.pk = ct.`', @ct_pk_col, '` SET ct.`', @ct_pick_col, '` = 0'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt;
SET @updated_pick := IF(@can_apply = 1, ROW_COUNT(), 0);
DEALLOCATE PREPARE stmt;

/* ── Skin: backup + update ───────────────────────────────────────── */
SET @sql := IF(@can_apply = 1 AND @can_fix_skin = 1,
  CONCAT('INSERT IGNORE INTO `world`.`creature_template_backup_genre6c` SELECT ct.* FROM `world`.`creature_template` ct INNER JOIN tmp_fix_skin t ON t.pk = ct.`', @ct_pk_col, '`'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_apply = 1 AND @can_fix_skin = 1,
  CONCAT('UPDATE `world`.`creature_template` ct INNER JOIN tmp_fix_skin t ON t.pk = ct.`', @ct_pk_col, '` SET ct.`', @ct_skin_col, '` = 0'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt;
SET @updated_skin := IF(@can_apply = 1, ROW_COUNT(), 0);
DEALLOCATE PREPARE stmt;

/* ================================================================== */
/* VERIFICATION                                                       */
/* ================================================================== */
SELECT 'VERIFICATION' AS section;

SET @cand_after_loot := 0;
SET @cand_after_pick := 0;
SET @cand_after_skin := 0;

SET @sql := IF(@can_fix_loot = 1,
  CONCAT('SELECT COUNT(*) INTO @cand_after_loot FROM `world`.`creature_template` ct WHERE ct.`', @ct_loot_col, '` > 0 AND NOT EXISTS (SELECT 1 FROM `world`.`creature_loot_template` lt WHERE lt.`', @clt_entry_col, '` = ct.`', @ct_loot_col, '`)'),
  'SELECT 0 INTO @cand_after_loot');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_fix_pick = 1,
  CONCAT('SELECT COUNT(*) INTO @cand_after_pick FROM `world`.`creature_template` ct WHERE ct.`', @ct_pick_col, '` > 0 AND NOT EXISTS (SELECT 1 FROM `world`.`pickpocketing_loot_template` lt WHERE lt.`', @plt_entry_col, '` = ct.`', @ct_pick_col, '`)'),
  'SELECT 0 INTO @cand_after_pick');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_fix_skin = 1,
  CONCAT('SELECT COUNT(*) INTO @cand_after_skin FROM `world`.`creature_template` ct WHERE ct.`', @ct_skin_col, '` > 0 AND NOT EXISTS (SELECT 1 FROM `world`.`skinning_loot_template` lt WHERE lt.`', @slt_entry_col, '` = ct.`', @ct_skin_col, '`)'),
  'SELECT 0 INTO @cand_after_skin');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* ================================================================== */
/* SUMMARY                                                            */
/* ================================================================== */
SELECT 'SUMMARY' AS section;

SELECT
  @cand_before_loot AS before_loot,   @updated_loot AS updated_loot,   @cand_after_loot AS after_loot,
  @cand_before_pick AS before_pick,   @updated_pick AS updated_pick,   @cand_after_pick AS after_pick,
  @cand_before_skin AS before_skin,   @updated_skin AS updated_skin,   @cand_after_skin AS after_skin,
  @cap_note AS notes;

SELECT IF(@can_apply = 1, 'APPLIED — committing changes',
  IF(@APPLY_FIX = 0, 'DRY RUN — rolling back', 'BLOCKED — rolling back')) AS mode;

/* ── Commit or rollback ──────────────────────────────────────────── */
SET @sql := IF(@can_apply = 1, 'COMMIT', 'ROLLBACK');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* ── Cleanup ─────────────────────────────────────────────────────── */
DROP TEMPORARY TABLE IF EXISTS tmp_fix_loot;
DROP TEMPORARY TABLE IF EXISTS tmp_fix_pick;
DROP TEMPORARY TABLE IF EXISTS tmp_fix_skin;

/* ── Restore session ─────────────────────────────────────────────── */
SET SESSION sql_safe_updates   = COALESCE(@prev_sql_safe_updates, 1);
SET SESSION foreign_key_checks = COALESCE(@prev_foreign_key_checks, 1);
SET SESSION unique_checks      = COALESCE(@prev_unique_checks, 1);
SET SESSION autocommit         = COALESCE(@prev_autocommit, 1);
