/* Genre 4B vendor cleanup: HeidiSQL-safe, schema-detected, idempotent, no DELIMITER/procedure required */
USE `world`;
SELECT DATABASE() AS current_database;

/* Preserve session settings */
SET @OLD_SQL_SAFE_UPDATES := @@SQL_SAFE_UPDATES;
SET @OLD_FOREIGN_KEY_CHECKS := @@FOREIGN_KEY_CHECKS;
SET @OLD_UNIQUE_CHECKS := @@UNIQUE_CHECKS;
SET @OLD_AUTOCOMMIT := @@AUTOCOMMIT;

SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;
START TRANSACTION;

DROP TEMPORARY TABLE IF EXISTS `tmp_genre4b_summary`;
CREATE TEMPORARY TABLE `tmp_genre4b_summary` (
  `action_name` VARCHAR(128) NOT NULL,
  `table_name` VARCHAR(128) NOT NULL,
  `affected_rows` BIGINT NOT NULL DEFAULT 0
);

/* Detect source tables */
SET @has_npc_vendor := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'npc_vendor'
);
SET @has_game_event_npc_vendor := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'game_event_npc_vendor'
);
SET @has_creature_template := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'creature_template'
);

/* Detect vendor columns */
SET @npc_vendor_creature_col := (
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'npc_vendor'
    AND COLUMN_NAME IN ('entry','Entry','CreatureID','creature','id')
  ORDER BY FIELD(COLUMN_NAME,'entry','Entry','CreatureID','creature','id') LIMIT 1
);
SET @npc_vendor_item_col := (
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'npc_vendor'
    AND COLUMN_NAME IN ('item','Item','itemid','ItemID')
  ORDER BY FIELD(COLUMN_NAME,'item','Item','itemid','ItemID') LIMIT 1
);
SET @npc_vendor_max_col := (
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'npc_vendor'
    AND COLUMN_NAME IN ('maxcount','MaxCount','max_count')
  ORDER BY FIELD(COLUMN_NAME,'maxcount','MaxCount','max_count') LIMIT 1
);
SET @npc_vendor_incr_col := (
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'npc_vendor'
    AND COLUMN_NAME IN ('incrtime','IncrTime','incr_time')
  ORDER BY FIELD(COLUMN_NAME,'incrtime','IncrTime','incr_time') LIMIT 1
);
SET @npc_vendor_pc_col := (
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'npc_vendor'
    AND COLUMN_NAME IN ('PlayerConditionID','playerConditionId','player_condition_id','condition_id','ConditionID')
  ORDER BY FIELD(COLUMN_NAME,'PlayerConditionID','playerConditionId','player_condition_id','condition_id','ConditionID') LIMIT 1
);

SET @ge_vendor_creature_col := (
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'game_event_npc_vendor'
    AND COLUMN_NAME IN ('entry','Entry','CreatureID','creature','id')
  ORDER BY FIELD(COLUMN_NAME,'entry','Entry','CreatureID','creature','id') LIMIT 1
);
SET @ge_vendor_item_col := (
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'game_event_npc_vendor'
    AND COLUMN_NAME IN ('item','Item','itemid','ItemID')
  ORDER BY FIELD(COLUMN_NAME,'item','Item','itemid','ItemID') LIMIT 1
);
SET @ge_vendor_max_col := (
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'game_event_npc_vendor'
    AND COLUMN_NAME IN ('maxcount','MaxCount','max_count')
  ORDER BY FIELD(COLUMN_NAME,'maxcount','MaxCount','max_count') LIMIT 1
);
SET @ge_vendor_incr_col := (
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'game_event_npc_vendor'
    AND COLUMN_NAME IN ('incrtime','IncrTime','incr_time')
  ORDER BY FIELD(COLUMN_NAME,'incrtime','IncrTime','incr_time') LIMIT 1
);
SET @ge_vendor_pc_col := (
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'game_event_npc_vendor'
    AND COLUMN_NAME IN ('PlayerConditionID','playerConditionId','player_condition_id','condition_id','ConditionID')
  ORDER BY FIELD(COLUMN_NAME,'PlayerConditionID','playerConditionId','player_condition_id','condition_id','ConditionID') LIMIT 1
);

/* Detect creature_template columns */
SET @ct_pk_col := (
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'creature_template'
    AND COLUMN_NAME IN ('entry','Entry','ID','Id')
  ORDER BY FIELD(COLUMN_NAME,'entry','Entry','ID','Id') LIMIT 1
);
SET @ct_npcflag_col := (
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'creature_template'
    AND COLUMN_NAME IN ('npcflag','npcFlag','npc_flag')
  ORDER BY FIELD(COLUMN_NAME,'npcflag','npcFlag','npc_flag') LIMIT 1
);

/* Detect player condition source (prefer world schema, then hotfixes, then any schema) */
SET @player_condition_schema := (
  SELECT TABLE_SCHEMA FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_NAME IN ('player_condition','player_conditions')
  ORDER BY
    (TABLE_SCHEMA = DATABASE()) DESC,
    (TABLE_SCHEMA = 'hotfixes') DESC,
    FIELD(TABLE_NAME,'player_condition','player_conditions'),
    TABLE_SCHEMA
  LIMIT 1
);
SET @player_condition_table := (
  SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = @player_condition_schema AND TABLE_NAME IN ('player_condition','player_conditions')
  ORDER BY FIELD(TABLE_NAME,'player_condition','player_conditions') LIMIT 1
);
SET @player_condition_pk_col := (
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = @player_condition_schema AND TABLE_NAME = @player_condition_table
    AND COLUMN_NAME IN ('ID','Id','id')
  ORDER BY FIELD(COLUMN_NAME,'ID','Id','id') LIMIT 1
);
SET @has_player_condition := IF(@player_condition_schema IS NOT NULL AND @player_condition_table IS NOT NULL AND @player_condition_pk_col IS NOT NULL,1,0);

/* Detect item source in required order */
SET @item_source_schema := NULL;
SET @item_source_table := NULL;
SET @item_source_pk_col := NULL;

SET @candidate_item_template_pk := (
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'item_template' AND COLUMN_NAME IN ('entry','ID')
  ORDER BY FIELD(COLUMN_NAME,'entry','ID') LIMIT 1
);
SET @has_item_template := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'item_template'
);
SET @item_source_schema := IF(@has_item_template > 0 AND @candidate_item_template_pk IS NOT NULL, DATABASE(), @item_source_schema);
SET @item_source_table := IF(@has_item_template > 0 AND @candidate_item_template_pk IS NOT NULL, 'item_template', @item_source_table);
SET @item_source_pk_col := IF(@has_item_template > 0 AND @candidate_item_template_pk IS NOT NULL, @candidate_item_template_pk, @item_source_pk_col);

SET @has_item_sparse_world := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'item_sparse'
);
SET @has_item_sparse_world_id := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'item_sparse' AND COLUMN_NAME = 'ID'
);
SET @item_source_schema := IF(@item_source_table IS NULL AND @has_item_sparse_world > 0 AND @has_item_sparse_world_id > 0, DATABASE(), @item_source_schema);
SET @item_source_table := IF(@item_source_table IS NULL AND @has_item_sparse_world > 0 AND @has_item_sparse_world_id > 0, 'item_sparse', @item_source_table);
SET @item_source_pk_col := IF(@item_source_table = 'item_sparse' AND @item_source_schema = DATABASE(), 'ID', @item_source_pk_col);

SET @has_hotfixes_schema := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'hotfixes'
);
SET @has_item_sparse_hotfixes := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'hotfixes' AND TABLE_NAME = 'item_sparse'
);
SET @has_item_sparse_hotfixes_id := (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'hotfixes' AND TABLE_NAME = 'item_sparse' AND COLUMN_NAME = 'ID'
);
SET @item_source_schema := IF(@item_source_table IS NULL AND @has_hotfixes_schema > 0 AND @has_item_sparse_hotfixes > 0 AND @has_item_sparse_hotfixes_id > 0, 'hotfixes', @item_source_schema);
SET @item_source_table := IF(@item_source_table IS NULL AND @has_hotfixes_schema > 0 AND @has_item_sparse_hotfixes > 0 AND @has_item_sparse_hotfixes_id > 0, 'item_sparse', @item_source_table);
SET @item_source_pk_col := IF(@item_source_table = 'item_sparse' AND @item_source_schema = 'hotfixes', 'ID', @item_source_pk_col);
SET @has_item_source := IF(@item_source_table IS NOT NULL AND @item_source_pk_col IS NOT NULL,1,0);

/* Create backups */
SET @sql := IF(@has_npc_vendor > 0,
  'CREATE TABLE IF NOT EXISTS `npc_vendor_backup_genre4b` LIKE `npc_vendor`',
  'SELECT ''SKIP: npc_vendor table missing'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@has_game_event_npc_vendor > 0,
  'CREATE TABLE IF NOT EXISTS `game_event_npc_vendor_backup_genre4b` LIKE `game_event_npc_vendor`',
  'SELECT ''SKIP: game_event_npc_vendor table missing'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@has_creature_template > 0,
  'CREATE TABLE IF NOT EXISTS `creature_template_backup_vendorflag_genre4b` LIKE `creature_template`',
  'SELECT ''SKIP: creature_template table missing'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* Build vendor creature set */
DROP TEMPORARY TABLE IF EXISTS `tmp_vendor_creatures`;
CREATE TEMPORARY TABLE `tmp_vendor_creatures` (
  `creature_entry` BIGINT NOT NULL,
  PRIMARY KEY (`creature_entry`)
);

SET @sql := IF(@has_npc_vendor > 0 AND @npc_vendor_creature_col IS NOT NULL,
  CONCAT('INSERT IGNORE INTO `tmp_vendor_creatures` (`creature_entry`) SELECT DISTINCT `', REPLACE(@npc_vendor_creature_col,'`','``'), '` FROM `npc_vendor`'),
  'SELECT ''SKIP: npc_vendor missing creature entry column'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@has_game_event_npc_vendor > 0 AND @ge_vendor_creature_col IS NOT NULL,
  CONCAT('INSERT IGNORE INTO `tmp_vendor_creatures` (`creature_entry`) SELECT DISTINCT `', REPLACE(@ge_vendor_creature_col,'`','``'), '` FROM `game_event_npc_vendor`'),
  'SELECT ''SKIP: game_event_npc_vendor missing creature entry column'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* 1) Fix missing vendor npcflag */
SET @rows_ct_backup := 0;
SET @rows_ct_update := 0;
SET @sql := IF(@has_creature_template > 0 AND @ct_pk_col IS NOT NULL AND @ct_npcflag_col IS NOT NULL,
  CONCAT(
    'INSERT IGNORE INTO `creature_template_backup_vendorflag_genre4b` ',
    'SELECT ct.* FROM `creature_template` ct INNER JOIN `tmp_vendor_creatures` tvc ON tvc.`creature_entry` = ct.`', REPLACE(@ct_pk_col,'`','``'), '` ',
    'WHERE (ct.`', REPLACE(@ct_npcflag_col,'`','``'), '` & 128) = 0'
  ),
  'SELECT ''SKIP: creature_template missing PK or npcflag column'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @rows_ct_backup := ROW_COUNT();

SET @sql := IF(@has_creature_template > 0 AND @ct_pk_col IS NOT NULL AND @ct_npcflag_col IS NOT NULL,
  CONCAT(
    'UPDATE `creature_template` ct INNER JOIN `tmp_vendor_creatures` tvc ON tvc.`creature_entry` = ct.`', REPLACE(@ct_pk_col,'`','``'), '` ',
    'SET ct.`', REPLACE(@ct_npcflag_col,'`','``'), '` = ct.`', REPLACE(@ct_npcflag_col,'`','``'), '` | 128 ',
    'WHERE (ct.`', REPLACE(@ct_npcflag_col,'`','``'), '` & 128) = 0'
  ),
  'SELECT ''SKIP: creature_template missing PK or npcflag column'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @rows_ct_update := ROW_COUNT();
INSERT INTO `tmp_genre4b_summary` VALUES ('backup_vendor_flag_rows','creature_template',@rows_ct_backup);
INSERT INTO `tmp_genre4b_summary` VALUES ('update_vendor_flag_rows','creature_template',@rows_ct_update);

/* 2) Fix MaxCount/IncrTime mismatch */
SET @rows_npc_mismatch_backup := 0;
SET @rows_npc_mismatch_update := 0;
SET @sql := IF(@has_npc_vendor > 0 AND @npc_vendor_max_col IS NOT NULL AND @npc_vendor_incr_col IS NOT NULL,
  CONCAT(
    'INSERT IGNORE INTO `npc_vendor_backup_genre4b` SELECT v.* FROM `npc_vendor` v ',
    'WHERE (v.`', REPLACE(@npc_vendor_max_col,'`','``'), '` = 0 AND v.`', REPLACE(@npc_vendor_incr_col,'`','``'), '` > 0) ',
    'OR (v.`', REPLACE(@npc_vendor_max_col,'`','``'), '` > 0 AND v.`', REPLACE(@npc_vendor_incr_col,'`','``'), '` = 0)'
  ),
  'SELECT ''SKIP: npc_vendor missing MaxCount or IncrTime column'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @rows_npc_mismatch_backup := ROW_COUNT();

SET @sql := IF(@has_npc_vendor > 0 AND @npc_vendor_max_col IS NOT NULL AND @npc_vendor_incr_col IS NOT NULL,
  CONCAT(
    'UPDATE `npc_vendor` v SET ',
    'v.`', REPLACE(@npc_vendor_incr_col,'`','``'), '` = CASE WHEN v.`', REPLACE(@npc_vendor_max_col,'`','``'), '` = 0 AND v.`', REPLACE(@npc_vendor_incr_col,'`','``'), '` > 0 THEN 0 ELSE v.`', REPLACE(@npc_vendor_incr_col,'`','``'), '` END, ',
    'v.`', REPLACE(@npc_vendor_max_col,'`','``'), '` = CASE WHEN v.`', REPLACE(@npc_vendor_max_col,'`','``'), '` > 0 AND v.`', REPLACE(@npc_vendor_incr_col,'`','``'), '` = 0 THEN 0 ELSE v.`', REPLACE(@npc_vendor_max_col,'`','``'), '` END ',
    'WHERE (v.`', REPLACE(@npc_vendor_max_col,'`','``'), '` = 0 AND v.`', REPLACE(@npc_vendor_incr_col,'`','``'), '` > 0) ',
    'OR (v.`', REPLACE(@npc_vendor_max_col,'`','``'), '` > 0 AND v.`', REPLACE(@npc_vendor_incr_col,'`','``'), '` = 0)'
  ),
  'SELECT ''SKIP: npc_vendor missing MaxCount or IncrTime column'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @rows_npc_mismatch_update := ROW_COUNT();
INSERT INTO `tmp_genre4b_summary` VALUES ('backup_maxcount_incrtime_rows','npc_vendor',@rows_npc_mismatch_backup);
INSERT INTO `tmp_genre4b_summary` VALUES ('update_maxcount_incrtime_rows','npc_vendor',@rows_npc_mismatch_update);

SET @rows_ge_mismatch_backup := 0;
SET @rows_ge_mismatch_update := 0;
SET @sql := IF(@has_game_event_npc_vendor > 0 AND @ge_vendor_max_col IS NOT NULL AND @ge_vendor_incr_col IS NOT NULL,
  CONCAT(
    'INSERT IGNORE INTO `game_event_npc_vendor_backup_genre4b` SELECT v.* FROM `game_event_npc_vendor` v ',
    'WHERE (v.`', REPLACE(@ge_vendor_max_col,'`','``'), '` = 0 AND v.`', REPLACE(@ge_vendor_incr_col,'`','``'), '` > 0) ',
    'OR (v.`', REPLACE(@ge_vendor_max_col,'`','``'), '` > 0 AND v.`', REPLACE(@ge_vendor_incr_col,'`','``'), '` = 0)'
  ),
  'SELECT ''SKIP: game_event_npc_vendor missing MaxCount or IncrTime column'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @rows_ge_mismatch_backup := ROW_COUNT();

SET @sql := IF(@has_game_event_npc_vendor > 0 AND @ge_vendor_max_col IS NOT NULL AND @ge_vendor_incr_col IS NOT NULL,
  CONCAT(
    'UPDATE `game_event_npc_vendor` v SET ',
    'v.`', REPLACE(@ge_vendor_incr_col,'`','``'), '` = CASE WHEN v.`', REPLACE(@ge_vendor_max_col,'`','``'), '` = 0 AND v.`', REPLACE(@ge_vendor_incr_col,'`','``'), '` > 0 THEN 0 ELSE v.`', REPLACE(@ge_vendor_incr_col,'`','``'), '` END, ',
    'v.`', REPLACE(@ge_vendor_max_col,'`','``'), '` = CASE WHEN v.`', REPLACE(@ge_vendor_max_col,'`','``'), '` > 0 AND v.`', REPLACE(@ge_vendor_incr_col,'`','``'), '` = 0 THEN 0 ELSE v.`', REPLACE(@ge_vendor_max_col,'`','``'), '` END ',
    'WHERE (v.`', REPLACE(@ge_vendor_max_col,'`','``'), '` = 0 AND v.`', REPLACE(@ge_vendor_incr_col,'`','``'), '` > 0) ',
    'OR (v.`', REPLACE(@ge_vendor_max_col,'`','``'), '` > 0 AND v.`', REPLACE(@ge_vendor_incr_col,'`','``'), '` = 0)'
  ),
  'SELECT ''SKIP: game_event_npc_vendor missing MaxCount or IncrTime column'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @rows_ge_mismatch_update := ROW_COUNT();
INSERT INTO `tmp_genre4b_summary` VALUES ('backup_maxcount_incrtime_rows','game_event_npc_vendor',@rows_ge_mismatch_backup);
INSERT INTO `tmp_genre4b_summary` VALUES ('update_maxcount_incrtime_rows','game_event_npc_vendor',@rows_ge_mismatch_update);

/* 3) Fix invalid PlayerConditionID */
SET @rows_npc_pc_backup := 0;
SET @rows_npc_pc_update := 0;
SET @sql := IF(@has_npc_vendor > 0 AND @npc_vendor_pc_col IS NOT NULL AND @has_player_condition > 0,
  CONCAT(
    'INSERT IGNORE INTO `npc_vendor_backup_genre4b` SELECT v.* FROM `npc_vendor` v ',
    'WHERE v.`', REPLACE(@npc_vendor_pc_col,'`','``'), '` <> 0 ',
    'AND NOT EXISTS (SELECT 1 FROM `', REPLACE(@player_condition_schema,'`','``'), '`.`', REPLACE(@player_condition_table,'`','``'), '` pc WHERE pc.`', REPLACE(@player_condition_pk_col,'`','``'), '` = v.`', REPLACE(@npc_vendor_pc_col,'`','``'), '`)'
  ),
  'SELECT ''SKIP: npc_vendor PlayerCondition fix not applicable (missing column/table)'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @rows_npc_pc_backup := ROW_COUNT();

SET @sql := IF(@has_npc_vendor > 0 AND @npc_vendor_pc_col IS NOT NULL AND @has_player_condition > 0,
  CONCAT(
    'UPDATE `npc_vendor` v SET v.`', REPLACE(@npc_vendor_pc_col,'`','``'), '` = 0 ',
    'WHERE v.`', REPLACE(@npc_vendor_pc_col,'`','``'), '` <> 0 ',
    'AND NOT EXISTS (SELECT 1 FROM `', REPLACE(@player_condition_schema,'`','``'), '`.`', REPLACE(@player_condition_table,'`','``'), '` pc WHERE pc.`', REPLACE(@player_condition_pk_col,'`','``'), '` = v.`', REPLACE(@npc_vendor_pc_col,'`','``'), '`)'
  ),
  'SELECT ''SKIP: npc_vendor PlayerCondition fix not applicable (missing column/table)'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @rows_npc_pc_update := ROW_COUNT();
INSERT INTO `tmp_genre4b_summary` VALUES ('backup_player_condition_rows','npc_vendor',@rows_npc_pc_backup);
INSERT INTO `tmp_genre4b_summary` VALUES ('update_player_condition_rows','npc_vendor',@rows_npc_pc_update);

SET @rows_ge_pc_backup := 0;
SET @rows_ge_pc_update := 0;
SET @sql := IF(@has_game_event_npc_vendor > 0 AND @ge_vendor_pc_col IS NOT NULL AND @has_player_condition > 0,
  CONCAT(
    'INSERT IGNORE INTO `game_event_npc_vendor_backup_genre4b` SELECT v.* FROM `game_event_npc_vendor` v ',
    'WHERE v.`', REPLACE(@ge_vendor_pc_col,'`','``'), '` <> 0 ',
    'AND NOT EXISTS (SELECT 1 FROM `', REPLACE(@player_condition_schema,'`','``'), '`.`', REPLACE(@player_condition_table,'`','``'), '` pc WHERE pc.`', REPLACE(@player_condition_pk_col,'`','``'), '` = v.`', REPLACE(@ge_vendor_pc_col,'`','``'), '`)'
  ),
  'SELECT ''SKIP: game_event_npc_vendor PlayerCondition fix not applicable (missing column/table)'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @rows_ge_pc_backup := ROW_COUNT();

SET @sql := IF(@has_game_event_npc_vendor > 0 AND @ge_vendor_pc_col IS NOT NULL AND @has_player_condition > 0,
  CONCAT(
    'UPDATE `game_event_npc_vendor` v SET v.`', REPLACE(@ge_vendor_pc_col,'`','``'), '` = 0 ',
    'WHERE v.`', REPLACE(@ge_vendor_pc_col,'`','``'), '` <> 0 ',
    'AND NOT EXISTS (SELECT 1 FROM `', REPLACE(@player_condition_schema,'`','``'), '`.`', REPLACE(@player_condition_table,'`','``'), '` pc WHERE pc.`', REPLACE(@player_condition_pk_col,'`','``'), '` = v.`', REPLACE(@ge_vendor_pc_col,'`','``'), '`)'
  ),
  'SELECT ''SKIP: game_event_npc_vendor PlayerCondition fix not applicable (missing column/table)'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @rows_ge_pc_update := ROW_COUNT();
INSERT INTO `tmp_genre4b_summary` VALUES ('backup_player_condition_rows','game_event_npc_vendor',@rows_ge_pc_backup);
INSERT INTO `tmp_genre4b_summary` VALUES ('update_player_condition_rows','game_event_npc_vendor',@rows_ge_pc_update);

/* 4) Fix missing item references (delete only when provable) */
SET @rows_npc_item_backup := 0;
SET @rows_npc_item_delete := 0;
SET @sql := IF(@has_npc_vendor > 0 AND @npc_vendor_item_col IS NOT NULL AND @has_item_source > 0,
  CONCAT(
    'INSERT IGNORE INTO `npc_vendor_backup_genre4b` SELECT v.* FROM `npc_vendor` v ',
    'WHERE NOT EXISTS (SELECT 1 FROM `', REPLACE(@item_source_schema,'`','``'), '`.`', REPLACE(@item_source_table,'`','``'), '` i ',
    'WHERE i.`', REPLACE(@item_source_pk_col,'`','``'), '` = v.`', REPLACE(@npc_vendor_item_col,'`','``'), '`)'
  ),
  IF(@has_npc_vendor > 0 AND @npc_vendor_item_col IS NOT NULL,
    'SELECT ''SKIP: no item source table available for npc_vendor delete'' AS note',
    'SELECT ''SKIP: npc_vendor missing item column'' AS note'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @rows_npc_item_backup := ROW_COUNT();

SET @sql := IF(@has_npc_vendor > 0 AND @npc_vendor_item_col IS NOT NULL AND @has_item_source > 0,
  CONCAT(
    'DELETE v FROM `npc_vendor` v WHERE NOT EXISTS (SELECT 1 FROM `', REPLACE(@item_source_schema,'`','``'), '`.`', REPLACE(@item_source_table,'`','``'), '` i ',
    'WHERE i.`', REPLACE(@item_source_pk_col,'`','``'), '` = v.`', REPLACE(@npc_vendor_item_col,'`','``'), '`)'
  ),
  'SELECT ''SKIP: npc_vendor delete not executed'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @rows_npc_item_delete := ROW_COUNT();

SET @sql := IF(@has_npc_vendor > 0 AND @npc_vendor_item_col IS NOT NULL AND @has_item_source = 0,
  IF(@npc_vendor_creature_col IS NOT NULL,
    CONCAT(
      'SELECT ''SKIP: no item source table available'' AS note, v.`', REPLACE(@npc_vendor_creature_col,'`','``'), '` AS creature_entry, ',
      'v.`', REPLACE(@npc_vendor_item_col,'`','``'), '` AS item_id FROM `npc_vendor` v LIMIT 200'
    ),
    CONCAT(
      'SELECT ''SKIP: no item source table available'' AS note, NULL AS creature_entry, ',
      'v.`', REPLACE(@npc_vendor_item_col,'`','``'), '` AS item_id FROM `npc_vendor` v LIMIT 200'
    )
  ),
  'SELECT ''SKIP: npc_vendor missing item report not applicable'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
INSERT INTO `tmp_genre4b_summary` VALUES ('backup_missing_item_rows','npc_vendor',@rows_npc_item_backup);
INSERT INTO `tmp_genre4b_summary` VALUES ('delete_missing_item_rows','npc_vendor',@rows_npc_item_delete);

SET @rows_ge_item_backup := 0;
SET @rows_ge_item_delete := 0;
SET @sql := IF(@has_game_event_npc_vendor > 0 AND @ge_vendor_item_col IS NOT NULL AND @has_item_source > 0,
  CONCAT(
    'INSERT IGNORE INTO `game_event_npc_vendor_backup_genre4b` SELECT v.* FROM `game_event_npc_vendor` v ',
    'WHERE NOT EXISTS (SELECT 1 FROM `', REPLACE(@item_source_schema,'`','``'), '`.`', REPLACE(@item_source_table,'`','``'), '` i ',
    'WHERE i.`', REPLACE(@item_source_pk_col,'`','``'), '` = v.`', REPLACE(@ge_vendor_item_col,'`','``'), '`)'
  ),
  IF(@has_game_event_npc_vendor > 0 AND @ge_vendor_item_col IS NOT NULL,
    'SELECT ''SKIP: no item source table available for game_event_npc_vendor delete'' AS note',
    'SELECT ''SKIP: game_event_npc_vendor missing item column'' AS note'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @rows_ge_item_backup := ROW_COUNT();

SET @sql := IF(@has_game_event_npc_vendor > 0 AND @ge_vendor_item_col IS NOT NULL AND @has_item_source > 0,
  CONCAT(
    'DELETE v FROM `game_event_npc_vendor` v WHERE NOT EXISTS (SELECT 1 FROM `', REPLACE(@item_source_schema,'`','``'), '`.`', REPLACE(@item_source_table,'`','``'), '` i ',
    'WHERE i.`', REPLACE(@item_source_pk_col,'`','``'), '` = v.`', REPLACE(@ge_vendor_item_col,'`','``'), '`)'
  ),
  'SELECT ''SKIP: game_event_npc_vendor delete not executed'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @rows_ge_item_delete := ROW_COUNT();

SET @sql := IF(@has_game_event_npc_vendor > 0 AND @ge_vendor_item_col IS NOT NULL AND @has_item_source = 0,
  IF(@ge_vendor_creature_col IS NOT NULL,
    CONCAT(
      'SELECT ''SKIP: no item source table available'' AS note, v.`', REPLACE(@ge_vendor_creature_col,'`','``'), '` AS creature_entry, ',
      'v.`', REPLACE(@ge_vendor_item_col,'`','``'), '` AS item_id FROM `game_event_npc_vendor` v LIMIT 200'
    ),
    CONCAT(
      'SELECT ''SKIP: no item source table available'' AS note, NULL AS creature_entry, ',
      'v.`', REPLACE(@ge_vendor_item_col,'`','``'), '` AS item_id FROM `game_event_npc_vendor` v LIMIT 200'
    )
  ),
  'SELECT ''SKIP: game_event_npc_vendor missing item report not applicable'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
INSERT INTO `tmp_genre4b_summary` VALUES ('backup_missing_item_rows','game_event_npc_vendor',@rows_ge_item_backup);
INSERT INTO `tmp_genre4b_summary` VALUES ('delete_missing_item_rows','game_event_npc_vendor',@rows_ge_item_delete);

/* Verification */
SET @sql := IF(@has_creature_template > 0 AND @ct_pk_col IS NOT NULL AND @ct_npcflag_col IS NOT NULL,
  CONCAT(
    'SELECT ''verify_missing_vendor_flag'' AS check_name, COUNT(*) AS remaining_count ',
    'FROM `creature_template` ct INNER JOIN `tmp_vendor_creatures` tvc ON tvc.`creature_entry` = ct.`', REPLACE(@ct_pk_col,'`','``'), '` ',
    'WHERE (ct.`', REPLACE(@ct_npcflag_col,'`','``'), '` & 128) = 0'
  ),
  'SELECT ''verify_missing_vendor_flag'' AS check_name, NULL AS remaining_count, ''SKIP: creature_template PK/npcflag missing'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@has_npc_vendor > 0 AND @npc_vendor_max_col IS NOT NULL AND @npc_vendor_incr_col IS NOT NULL,
  CONCAT(
    'SELECT ''verify_maxcount_incrtime_npc_vendor'' AS check_name, COUNT(*) AS remaining_count FROM `npc_vendor` v ',
    'WHERE (v.`', REPLACE(@npc_vendor_max_col,'`','``'), '` = 0 AND v.`', REPLACE(@npc_vendor_incr_col,'`','``'), '` > 0) ',
    'OR (v.`', REPLACE(@npc_vendor_max_col,'`','``'), '` > 0 AND v.`', REPLACE(@npc_vendor_incr_col,'`','``'), '` = 0)'
  ),
  'SELECT ''verify_maxcount_incrtime_npc_vendor'' AS check_name, NULL AS remaining_count, ''SKIP: missing columns/table'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@has_game_event_npc_vendor > 0 AND @ge_vendor_max_col IS NOT NULL AND @ge_vendor_incr_col IS NOT NULL,
  CONCAT(
    'SELECT ''verify_maxcount_incrtime_game_event_npc_vendor'' AS check_name, COUNT(*) AS remaining_count FROM `game_event_npc_vendor` v ',
    'WHERE (v.`', REPLACE(@ge_vendor_max_col,'`','``'), '` = 0 AND v.`', REPLACE(@ge_vendor_incr_col,'`','``'), '` > 0) ',
    'OR (v.`', REPLACE(@ge_vendor_max_col,'`','``'), '` > 0 AND v.`', REPLACE(@ge_vendor_incr_col,'`','``'), '` = 0)'
  ),
  'SELECT ''verify_maxcount_incrtime_game_event_npc_vendor'' AS check_name, NULL AS remaining_count, ''SKIP: missing columns/table'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@has_npc_vendor > 0 AND @npc_vendor_pc_col IS NOT NULL AND @has_player_condition > 0,
  CONCAT(
    'SELECT ''verify_invalid_playercondition_npc_vendor'' AS check_name, COUNT(*) AS remaining_count FROM `npc_vendor` v ',
    'WHERE v.`', REPLACE(@npc_vendor_pc_col,'`','``'), '` <> 0 ',
    'AND NOT EXISTS (SELECT 1 FROM `', REPLACE(@player_condition_schema,'`','``'), '`.`', REPLACE(@player_condition_table,'`','``'), '` pc WHERE pc.`', REPLACE(@player_condition_pk_col,'`','``'), '` = v.`', REPLACE(@npc_vendor_pc_col,'`','``'), '`)'
  ),
  'SELECT ''verify_invalid_playercondition_npc_vendor'' AS check_name, NULL AS remaining_count, ''SKIP: missing columns/table'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@has_game_event_npc_vendor > 0 AND @ge_vendor_pc_col IS NOT NULL AND @has_player_condition > 0,
  CONCAT(
    'SELECT ''verify_invalid_playercondition_game_event_npc_vendor'' AS check_name, COUNT(*) AS remaining_count FROM `game_event_npc_vendor` v ',
    'WHERE v.`', REPLACE(@ge_vendor_pc_col,'`','``'), '` <> 0 ',
    'AND NOT EXISTS (SELECT 1 FROM `', REPLACE(@player_condition_schema,'`','``'), '`.`', REPLACE(@player_condition_table,'`','``'), '` pc WHERE pc.`', REPLACE(@player_condition_pk_col,'`','``'), '` = v.`', REPLACE(@ge_vendor_pc_col,'`','``'), '`)'
  ),
  'SELECT ''verify_invalid_playercondition_game_event_npc_vendor'' AS check_name, NULL AS remaining_count, ''SKIP: missing columns/table'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@has_item_source > 0 AND @has_npc_vendor > 0 AND @npc_vendor_item_col IS NOT NULL,
  CONCAT(
    'SELECT ''verify_missing_items_npc_vendor'' AS check_name, COUNT(*) AS remaining_count FROM `npc_vendor` v ',
    'WHERE NOT EXISTS (SELECT 1 FROM `', REPLACE(@item_source_schema,'`','``'), '`.`', REPLACE(@item_source_table,'`','``'), '` i WHERE i.`', REPLACE(@item_source_pk_col,'`','``'), '` = v.`', REPLACE(@npc_vendor_item_col,'`','``'), '`)'
  ),
  IF(@has_item_source = 0,
    'SELECT ''verify_missing_items_npc_vendor'' AS check_name, NULL AS remaining_count, ''SKIP: no item source table available'' AS note',
    'SELECT ''verify_missing_items_npc_vendor'' AS check_name, NULL AS remaining_count, ''SKIP: missing table/item column'' AS note'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@has_item_source > 0 AND @has_game_event_npc_vendor > 0 AND @ge_vendor_item_col IS NOT NULL,
  CONCAT(
    'SELECT ''verify_missing_items_game_event_npc_vendor'' AS check_name, COUNT(*) AS remaining_count FROM `game_event_npc_vendor` v ',
    'WHERE NOT EXISTS (SELECT 1 FROM `', REPLACE(@item_source_schema,'`','``'), '`.`', REPLACE(@item_source_table,'`','``'), '` i WHERE i.`', REPLACE(@item_source_pk_col,'`','``'), '` = v.`', REPLACE(@ge_vendor_item_col,'`','``'), '`)'
  ),
  IF(@has_item_source = 0,
    'SELECT ''verify_missing_items_game_event_npc_vendor'' AS check_name, NULL AS remaining_count, ''SKIP: no item source table available'' AS note',
    'SELECT ''verify_missing_items_game_event_npc_vendor'' AS check_name, NULL AS remaining_count, ''SKIP: missing table/item column'' AS note'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT
  IFNULL(@item_source_schema, 'none') AS item_source_schema,
  IFNULL(@item_source_table, 'none') AS item_source_table,
  IFNULL(@item_source_pk_col, 'none') AS item_source_pk_column;

SELECT `action_name`, `table_name`, SUM(`affected_rows`) AS affected_rows
FROM `tmp_genre4b_summary`
GROUP BY `action_name`, `table_name`
ORDER BY `table_name`, `action_name`;

COMMIT;

/* Restore session settings */
SET SQL_SAFE_UPDATES = @OLD_SQL_SAFE_UPDATES;
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;
SET AUTOCOMMIT = @OLD_AUTOCOMMIT;
