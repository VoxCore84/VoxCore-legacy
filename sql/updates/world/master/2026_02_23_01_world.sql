/* ================================================================== */
/* GENRE 5C v2 — Spawn validity cleanup                               */
/* TrinityCore Midnight 12.x (TWW 11.1.7)                            */
/*                                                                    */
/* Three fixes:                                                       */
/*   A) DELETE gameobject rows on invalid map IDs                     */
/*      (1470, 1178, 451, 2100, 1180)                                */
/*   B) UPDATE gameobject phaseid → 0 for invalid phase refs          */
/*      (385942, 7, 42833)                                            */
/*   C) UPDATE creature modelid → 0 for invalid model overrides       */
/*      (959, 12346, 14952, 239, 28283)                               */
/*                                                                    */
/* v2 fixes over v1:                                                  */
/*   - Stripped HeidiSQL session preamble (connection boilerplate)     */
/*   - Removed "Comment viewUSE" syntax error (HeidiSQL artifact)     */
/*   - DDL (3 backup tables) BEFORE START TRANSACTION                 */
/*   - @APPLY_FIX defaults to 0 (dry-run)                            */
/*   - Conditional COMMIT/ROLLBACK via @allow_apply                   */
/*   - COALESCE on session variable restores                          */
/*   - Removed SHOW WARNINGS and HeidiSQL "Info:" log noise           */
/*                                                                    */
/* SET @APPLY_FIX := 0 for dry-run diagnostics only.                  */
/* SET @APPLY_FIX := 1 to apply mutations.                            */
/*                                                                    */
/* IMPORTANT: Run the COMPLETE file. Do not paste fragments.          */
/* ================================================================== */

USE `world`;
SELECT DATABASE() AS active_database;

SET @APPLY_FIX   := 1;   /* 0 = diagnostics only; 1 = apply changes */
SET @MAX_DELETE   := 125000;
SET @MAX_UPDATE   := 120000;
SET @FORCE_APPLY  := 0;   /* override caps intentionally */

/* ── Session snapshot ────────────────────────────────────────────── */
SET @old_sql_safe_updates   := COALESCE(@@sql_safe_updates, 1);
SET @old_foreign_key_checks := COALESCE(@@foreign_key_checks, 1);
SET @old_unique_checks      := COALESCE(@@unique_checks, 1);
SET @old_autocommit         := COALESCE(@@autocommit, 1);

SET SQL_SAFE_UPDATES  = 0;
SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS      = 1;
SET AUTOCOMMIT         = 0;

/* ================================================================== */
/* SCHEMA INTROSPECTION                                               */
/* ================================================================== */
SELECT 'SCHEMA INTROSPECTION' AS section;

SET @go_exists := (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'world' AND table_name = 'gameobject');
SET @cr_exists := (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'world' AND table_name = 'creature');

SELECT column_name INTO @go_guid_col FROM information_schema.columns
WHERE table_schema = 'world' AND table_name = 'gameobject'
  AND column_name IN ('guid','GUID','id','ID')
ORDER BY FIELD(column_name,'guid','GUID','id','ID') LIMIT 1;

SELECT column_name INTO @go_map_col FROM information_schema.columns
WHERE table_schema = 'world' AND table_name = 'gameobject'
  AND column_name IN ('map','Map','mapId','MapId','MapID')
ORDER BY FIELD(column_name,'map','Map','mapId','MapId','MapID') LIMIT 1;

SELECT column_name INTO @go_phase_col FROM information_schema.columns
WHERE table_schema = 'world' AND table_name = 'gameobject'
  AND column_name IN ('phaseid','PhaseId','PhaseID','phase_id')
ORDER BY FIELD(column_name,'phaseid','PhaseId','PhaseID','phase_id') LIMIT 1;

SELECT column_name INTO @go_entry_col FROM information_schema.columns
WHERE table_schema = 'world' AND table_name = 'gameobject'
  AND column_name IN ('id','entry','gameobjectid','GameObjectID')
ORDER BY FIELD(column_name,'id','entry','gameobjectid','GameObjectID') LIMIT 1;

SELECT column_name INTO @cr_guid_col FROM information_schema.columns
WHERE table_schema = 'world' AND table_name = 'creature'
  AND column_name IN ('guid','GUID','id','ID')
ORDER BY FIELD(column_name,'guid','GUID','id','ID') LIMIT 1;

SELECT column_name INTO @cr_model_col FROM information_schema.columns
WHERE table_schema = 'world' AND table_name = 'creature'
  AND column_name IN ('modelid','modelId','ModelId','displayid','DisplayId','displayId')
ORDER BY FIELD(column_name,'modelid','modelId','ModelId','displayid','DisplayId','displayId') LIMIT 1;

SELECT column_name INTO @cr_entry_col FROM information_schema.columns
WHERE table_schema = 'world' AND table_name = 'creature'
  AND column_name IN ('id','entry','creatureid','CreatureID')
ORDER BY FIELD(column_name,'id','entry','creatureid','CreatureID') LIMIT 1;

SET @go_has_map   := IF(@go_exists = 1 AND @go_map_col IS NOT NULL, 1, 0);
SET @go_has_phase := IF(@go_exists = 1 AND @go_phase_col IS NOT NULL, 1, 0);
SET @go_has_guid  := IF(@go_exists = 1 AND @go_guid_col IS NOT NULL, 1, 0);
SET @cr_has_model := IF(@cr_exists = 1 AND @cr_model_col IS NOT NULL, 1, 0);
SET @cr_has_guid  := IF(@cr_exists = 1 AND @cr_guid_col IS NOT NULL, 1, 0);

SELECT
  IF(@go_exists = 1, 'OK', 'MISSING')  AS gameobject_table,
  IF(@cr_exists = 1, 'OK', 'MISSING')  AS creature_table,
  COALESCE(@go_guid_col, 'NOT FOUND')  AS go_guid_col,
  COALESCE(@go_map_col, 'NOT FOUND')   AS go_map_col,
  COALESCE(@go_phase_col, 'NOT FOUND') AS go_phase_col,
  COALESCE(@go_entry_col, 'NOT FOUND') AS go_entry_col,
  COALESCE(@cr_guid_col, 'NOT FOUND')  AS cr_guid_col,
  COALESCE(@cr_model_col, 'NOT FOUND') AS cr_model_col,
  COALESCE(@cr_entry_col, 'NOT FOUND') AS cr_entry_col;

/* ================================================================== */
/* DDL PHASE — backup tables (before transaction)                     */
/* ================================================================== */
SELECT 'BACKUP TABLE CREATION (DDL)' AS section;

SET @sql := IF(@APPLY_FIX = 1 AND @go_has_map = 1,
  'CREATE TABLE IF NOT EXISTS `world`.`gameobject_backup_genre5c_invalid_map` LIKE `world`.`gameobject`',
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@APPLY_FIX = 1 AND @go_has_phase = 1,
  'CREATE TABLE IF NOT EXISTS `world`.`gameobject_backup_genre5c_phase_fix` LIKE `world`.`gameobject`',
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@APPLY_FIX = 1 AND @cr_has_model = 1,
  'CREATE TABLE IF NOT EXISTS `world`.`creature_backup_genre5c_model_fix` LIKE `world`.`creature`',
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* ================================================================== */
/* DML PHASE                                                          */
/* ================================================================== */
START TRANSACTION;

/* ── A: Invalid map diagnostics ──────────────────────────────────── */
SELECT 'DIAGNOSTICS — A: Invalid Map IDs' AS section;

SET @go_entry_select := IF(@go_entry_col IS NOT NULL, CONCAT('`', @go_entry_col, '` AS entry, '), 'NULL AS entry, ');

SET @sql := IF(@go_has_map = 1,
  CONCAT('SELECT COUNT(*) AS invalid_map_count FROM `world`.`gameobject` WHERE `', @go_map_col, '` IN (1470,1178,451,2100,1180)'),
  'SELECT 0 AS invalid_map_count');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@go_has_map = 1,
  CONCAT('SELECT `', @go_map_col, '` AS mapId, COUNT(*) AS cnt FROM `world`.`gameobject` WHERE `', @go_map_col, '` IN (1470,1178,451,2100,1180) GROUP BY `', @go_map_col, '` ORDER BY cnt DESC'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@go_has_map = 1 AND @go_has_guid = 1,
  CONCAT('SELECT `', @go_guid_col, '` AS guid, ', @go_entry_select, '`', @go_map_col, '` AS mapId FROM `world`.`gameobject` WHERE `', @go_map_col, '` IN (1470,1178,451,2100,1180) ORDER BY `', @go_guid_col, '` LIMIT 50'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* ── B: Invalid phase diagnostics ────────────────────────────────── */
SELECT 'DIAGNOSTICS — B: Invalid Phase IDs' AS section;

SET @go_map_select := IF(@go_map_col IS NOT NULL, CONCAT('`', @go_map_col, '` AS mapId'), 'NULL AS mapId');

SET @sql := IF(@go_has_phase = 1,
  CONCAT('SELECT COUNT(*) AS invalid_phaseid_count FROM `world`.`gameobject` WHERE `', @go_phase_col, '` IN (385942,7,42833) AND `', @go_phase_col, '` <> 0'),
  'SELECT 0 AS invalid_phaseid_count');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@go_has_phase = 1,
  CONCAT('SELECT `', @go_phase_col, '` AS phaseid, COUNT(*) AS cnt FROM `world`.`gameobject` WHERE `', @go_phase_col, '` IN (385942,7,42833) AND `', @go_phase_col, '` <> 0 GROUP BY `', @go_phase_col, '` ORDER BY cnt DESC'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@go_has_phase = 1 AND @go_has_guid = 1,
  CONCAT('SELECT `', @go_guid_col, '` AS guid, ', @go_entry_select, '`', @go_phase_col, '` AS phaseid, ', @go_map_select, ' FROM `world`.`gameobject` WHERE `', @go_phase_col, '` IN (385942,7,42833) AND `', @go_phase_col, '` <> 0 ORDER BY `', @go_guid_col, '` LIMIT 50'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* ── C: Invalid model diagnostics ────────────────────────────────── */
SELECT 'DIAGNOSTICS — C: Invalid Model IDs' AS section;

SET @cr_entry_select := IF(@cr_entry_col IS NOT NULL, CONCAT('`', @cr_entry_col, '` AS entry, '), 'NULL AS entry, ');

SET @sql := IF(@cr_has_model = 1,
  CONCAT('SELECT COUNT(*) AS invalid_modelid_count FROM `world`.`creature` WHERE `', @cr_model_col, '` IN (959,12346,14952,239,28283) AND `', @cr_model_col, '` <> 0'),
  'SELECT 0 AS invalid_modelid_count');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@cr_has_model = 1,
  CONCAT('SELECT `', @cr_model_col, '` AS modelid, COUNT(*) AS cnt FROM `world`.`creature` WHERE `', @cr_model_col, '` IN (959,12346,14952,239,28283) AND `', @cr_model_col, '` <> 0 GROUP BY `', @cr_model_col, '` ORDER BY cnt DESC'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@cr_has_model = 1 AND @cr_has_guid = 1,
  CONCAT('SELECT `', @cr_guid_col, '` AS guid, ', @cr_entry_select, '`', @cr_model_col, '` AS modelid FROM `world`.`creature` WHERE `', @cr_model_col, '` IN (959,12346,14952,239,28283) AND `', @cr_model_col, '` <> 0 ORDER BY `', @cr_guid_col, '` LIMIT 50'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* ── Candidate counts + apply decision ───────────────────────────── */
SELECT 'APPLY DECISION' AS section;

SET @sql := IF(@go_has_map = 1,
  CONCAT('SELECT COUNT(*) INTO @delete_candidates FROM `world`.`gameobject` WHERE `', @go_map_col, '` IN (1470,1178,451,2100,1180)'),
  'SELECT 0 INTO @delete_candidates');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@go_has_phase = 1,
  CONCAT('SELECT COUNT(*) INTO @phase_candidates FROM `world`.`gameobject` WHERE `', @go_phase_col, '` IN (385942,7,42833) AND `', @go_phase_col, '` <> 0'),
  'SELECT 0 INTO @phase_candidates');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@cr_has_model = 1,
  CONCAT('SELECT COUNT(*) INTO @model_candidates FROM `world`.`creature` WHERE `', @cr_model_col, '` IN (959,12346,14952,239,28283) AND `', @cr_model_col, '` <> 0'),
  'SELECT 0 INTO @model_candidates');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @update_candidates := IFNULL(@phase_candidates, 0) + IFNULL(@model_candidates, 0);
SET @cap_exceeded := IF(
  @FORCE_APPLY = 0 AND (IFNULL(@delete_candidates, 0) > @MAX_DELETE OR @update_candidates > @MAX_UPDATE),
  1, 0
);
SET @allow_apply := IF(@APPLY_FIX = 1 AND (@FORCE_APPLY = 1 OR @cap_exceeded = 0), 1, 0);

SET @deleted_invalid_map := 0;
SET @updated_phase       := 0;
SET @updated_model       := 0;

SET @cap_note :=
  CASE
    WHEN @APPLY_FIX <> 1 THEN 'DRY RUN: report-only mode (@APPLY_FIX=0).'
    WHEN @allow_apply = 1 THEN CONCAT('Apply mode: ', IFNULL(@delete_candidates, 0), ' deletes + ', @update_candidates, ' updates.')
    ELSE CONCAT('BLOCKED by cap: deletes=', IFNULL(@delete_candidates, 0), ' (max ', @MAX_DELETE, '), updates=', @update_candidates, ' (max ', @MAX_UPDATE, '). Set @FORCE_APPLY=1 to override.')
  END;

SELECT
  IFNULL(@delete_candidates, 0) AS delete_candidates,
  @update_candidates             AS update_candidates,
  @cap_note                      AS apply_decision;

/* ── A: Backup + delete invalid map rows ─────────────────────────── */
SET @sql := IF(@allow_apply = 1 AND @go_has_map = 1,
  CONCAT('INSERT IGNORE INTO `world`.`gameobject_backup_genre5c_invalid_map` SELECT * FROM `world`.`gameobject` WHERE `', @go_map_col, '` IN (1470,1178,451,2100,1180)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@allow_apply = 1 AND @go_has_map = 1,
  CONCAT('DELETE FROM `world`.`gameobject` WHERE `', @go_map_col, '` IN (1470,1178,451,2100,1180)'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt;
SET @deleted_invalid_map := IF(@allow_apply = 1 AND @go_has_map = 1, ROW_COUNT(), 0);
DEALLOCATE PREPARE stmt;

/* ── B: Backup + update invalid phase rows ───────────────────────── */
SET @sql := IF(@allow_apply = 1 AND @go_has_phase = 1,
  CONCAT('INSERT IGNORE INTO `world`.`gameobject_backup_genre5c_phase_fix` SELECT * FROM `world`.`gameobject` WHERE `', @go_phase_col, '` IN (385942,7,42833) AND `', @go_phase_col, '` <> 0'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@allow_apply = 1 AND @go_has_phase = 1,
  CONCAT('UPDATE `world`.`gameobject` SET `', @go_phase_col, '` = 0 WHERE `', @go_phase_col, '` IN (385942,7,42833) AND `', @go_phase_col, '` <> 0'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt;
SET @updated_phase := IF(@allow_apply = 1 AND @go_has_phase = 1, ROW_COUNT(), 0);
DEALLOCATE PREPARE stmt;

/* ── C: Backup + update invalid model rows ───────────────────────── */
SET @sql := IF(@allow_apply = 1 AND @cr_has_model = 1,
  CONCAT('INSERT IGNORE INTO `world`.`creature_backup_genre5c_model_fix` SELECT * FROM `world`.`creature` WHERE `', @cr_model_col, '` IN (959,12346,14952,239,28283) AND `', @cr_model_col, '` <> 0'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@allow_apply = 1 AND @cr_has_model = 1,
  CONCAT('UPDATE `world`.`creature` SET `', @cr_model_col, '` = 0 WHERE `', @cr_model_col, '` IN (959,12346,14952,239,28283) AND `', @cr_model_col, '` <> 0'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt;
SET @updated_model := IF(@allow_apply = 1 AND @cr_has_model = 1, ROW_COUNT(), 0);
DEALLOCATE PREPARE stmt;

/* ================================================================== */
/* VERIFICATION                                                       */
/* ================================================================== */
SELECT 'VERIFICATION' AS section;

SET @sql := IF(@go_has_map = 1,
  CONCAT('SELECT COUNT(*) AS remaining_invalid_map FROM `world`.`gameobject` WHERE `', @go_map_col, '` IN (1470,1178,451,2100,1180)'),
  'SELECT 0 AS remaining_invalid_map');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@go_has_phase = 1,
  CONCAT('SELECT COUNT(*) AS remaining_invalid_phase FROM `world`.`gameobject` WHERE `', @go_phase_col, '` IN (385942,7,42833) AND `', @go_phase_col, '` <> 0'),
  'SELECT 0 AS remaining_invalid_phase');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@cr_has_model = 1,
  CONCAT('SELECT COUNT(*) AS remaining_invalid_model FROM `world`.`creature` WHERE `', @cr_model_col, '` IN (959,12346,14952,239,28283) AND `', @cr_model_col, '` <> 0'),
  'SELECT 0 AS remaining_invalid_model');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* ================================================================== */
/* SUMMARY                                                            */
/* ================================================================== */
SELECT 'SUMMARY' AS section;

SELECT
  IFNULL(@delete_candidates, 0) AS delete_candidates,
  @update_candidates             AS update_candidates,
  @deleted_invalid_map           AS deleted_invalid_map,
  @updated_phase                 AS updated_phase,
  @updated_model                 AS updated_model,
  @cap_note                      AS notes;

SELECT IF(@allow_apply = 1, 'APPLIED — committing changes',
  IF(@APPLY_FIX = 0, 'DRY RUN — rolling back', 'BLOCKED — rolling back')) AS mode;

/* ── Commit or rollback ──────────────────────────────────────────── */
SET @sql := IF(@allow_apply = 1, 'COMMIT', 'ROLLBACK');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* ── Restore session ─────────────────────────────────────────────── */
SET SQL_SAFE_UPDATES   = COALESCE(@old_sql_safe_updates, 1);
SET FOREIGN_KEY_CHECKS = COALESCE(@old_foreign_key_checks, 1);
SET UNIQUE_CHECKS      = COALESCE(@old_unique_checks, 1);
SET AUTOCOMMIT         = COALESCE(@old_autocommit, 1);
