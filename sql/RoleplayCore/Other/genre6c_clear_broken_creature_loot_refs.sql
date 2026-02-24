/* GENRE 6C: Clear broken creature loot references that point to missing loot templates */

SET @APPLY_FIX := 0;
SET @UPDATE_BATCH := 50000;
SET @FORCE_BATCH := 0;

USE `world`;
SELECT DATABASE() AS active_database;

SET @prev_sql_safe_updates := @@sql_safe_updates;
SET @prev_foreign_key_checks := @@foreign_key_checks;
SET @prev_unique_checks := @@unique_checks;
SET @prev_autocommit := @@autocommit;

SET SESSION sql_safe_updates = 0;
SET SESSION foreign_key_checks = 1;
SET SESSION unique_checks = 1;
SET SESSION autocommit = 0;

START TRANSACTION;

SET @ct_exists := (
    SELECT COUNT(*)
    FROM information_schema.tables
    WHERE table_schema = 'world' AND table_name = 'creature_template'
);

SET @ct_pk_col := (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'world'
      AND table_name = 'creature_template'
      AND column_name IN ('entry', 'Entry', 'ID', 'Id')
    ORDER BY CASE column_name
        WHEN 'entry' THEN 1
        WHEN 'Entry' THEN 2
        WHEN 'ID' THEN 3
        WHEN 'Id' THEN 4
        ELSE 100
    END
    LIMIT 1
);

SET @ct_loot_col := (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'world'
      AND table_name = 'creature_template'
      AND column_name IN ('lootid', 'LootId', 'lootId', 'LootID')
    ORDER BY CASE column_name
        WHEN 'lootid' THEN 1
        WHEN 'LootId' THEN 2
        WHEN 'lootId' THEN 3
        WHEN 'LootID' THEN 4
        ELSE 100
    END
    LIMIT 1
);

SET @ct_pick_col := (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'world'
      AND table_name = 'creature_template'
      AND column_name IN ('pickpocketloot', 'PickpocketLoot', 'pickpocketLoot', 'PickPocketLoot')
    ORDER BY CASE column_name
        WHEN 'pickpocketloot' THEN 1
        WHEN 'PickpocketLoot' THEN 2
        WHEN 'pickpocketLoot' THEN 3
        WHEN 'PickPocketLoot' THEN 4
        ELSE 100
    END
    LIMIT 1
);

SET @ct_skin_col := (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'world'
      AND table_name = 'creature_template'
      AND column_name IN ('skinloot', 'SkinLoot', 'skinLoot')
    ORDER BY CASE column_name
        WHEN 'skinloot' THEN 1
        WHEN 'SkinLoot' THEN 2
        WHEN 'skinLoot' THEN 3
        ELSE 100
    END
    LIMIT 1
);

SET @clt_exists := (
    SELECT COUNT(*)
    FROM information_schema.tables
    WHERE table_schema = 'world' AND table_name = 'creature_loot_template'
);
SET @clt_entry_col := (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'world'
      AND table_name = 'creature_loot_template'
      AND column_name IN ('entry', 'Entry', 'ID', 'Id')
    ORDER BY CASE column_name
        WHEN 'entry' THEN 1
        WHEN 'Entry' THEN 2
        WHEN 'ID' THEN 3
        WHEN 'Id' THEN 4
        ELSE 100
    END
    LIMIT 1
);

SET @plt_exists := (
    SELECT COUNT(*)
    FROM information_schema.tables
    WHERE table_schema = 'world' AND table_name = 'pickpocketing_loot_template'
);
SET @plt_entry_col := (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'world'
      AND table_name = 'pickpocketing_loot_template'
      AND column_name IN ('entry', 'Entry', 'ID', 'Id')
    ORDER BY CASE column_name
        WHEN 'entry' THEN 1
        WHEN 'Entry' THEN 2
        WHEN 'ID' THEN 3
        WHEN 'Id' THEN 4
        ELSE 100
    END
    LIMIT 1
);

SET @slt_exists := (
    SELECT COUNT(*)
    FROM information_schema.tables
    WHERE table_schema = 'world' AND table_name = 'skinning_loot_template'
);
SET @slt_entry_col := (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'world'
      AND table_name = 'skinning_loot_template'
      AND column_name IN ('entry', 'Entry', 'ID', 'Id')
    ORDER BY CASE column_name
        WHEN 'entry' THEN 1
        WHEN 'Entry' THEN 2
        WHEN 'ID' THEN 3
        WHEN 'Id' THEN 4
        ELSE 100
    END
    LIMIT 1
);

SELECT
    @ct_exists AS creature_template_exists,
    @ct_pk_col AS ct_pk_col,
    @ct_loot_col AS ct_loot_col,
    @ct_pick_col AS ct_pick_col,
    @ct_skin_col AS ct_skin_col,
    @clt_exists AS creature_loot_template_exists,
    @clt_entry_col AS creature_loot_entry_col,
    @plt_exists AS pickpocketing_loot_template_exists,
    @plt_entry_col AS pickpocketing_loot_entry_col,
    @slt_exists AS skinning_loot_template_exists,
    @slt_entry_col AS skinning_loot_entry_col;

SET @cand_before_loot := 0;
SET @cand_before_pick := 0;
SET @cand_before_skin := 0;
SET @cand_after_loot := 0;
SET @cand_after_pick := 0;
SET @cand_after_skin := 0;
SET @updated_loot := 0;
SET @updated_pick := 0;
SET @updated_skin := 0;

SET @can_fix_loot := IF(@ct_exists = 1 AND @ct_pk_col IS NOT NULL AND @ct_loot_col IS NOT NULL AND @clt_exists = 1 AND @clt_entry_col IS NOT NULL, 1, 0);
SET @can_fix_pick := IF(@ct_exists = 1 AND @ct_pk_col IS NOT NULL AND @ct_pick_col IS NOT NULL AND @plt_exists = 1 AND @plt_entry_col IS NOT NULL, 1, 0);
SET @can_fix_skin := IF(@ct_exists = 1 AND @ct_pk_col IS NOT NULL AND @ct_skin_col IS NOT NULL AND @slt_exists = 1 AND @slt_entry_col IS NOT NULL, 1, 0);

SET @sql := IF(
    @can_fix_loot = 1,
    CONCAT(
        'SELECT COUNT(*) INTO @cand_before_loot FROM `world`.`creature_template` ct ',
        'WHERE ct.`', @ct_loot_col, '` > 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `world`.`creature_loot_template` lt WHERE lt.`', @clt_entry_col, '` = ct.`', @ct_loot_col, '`)' 
    ),
    'SELECT 0 INTO @cand_before_loot'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_fix_pick = 1,
    CONCAT(
        'SELECT COUNT(*) INTO @cand_before_pick FROM `world`.`creature_template` ct ',
        'WHERE ct.`', @ct_pick_col, '` > 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `world`.`pickpocketing_loot_template` lt WHERE lt.`', @plt_entry_col, '` = ct.`', @ct_pick_col, '`)' 
    ),
    'SELECT 0 INTO @cand_before_pick'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_fix_skin = 1,
    CONCAT(
        'SELECT COUNT(*) INTO @cand_before_skin FROM `world`.`creature_template` ct ',
        'WHERE ct.`', @ct_skin_col, '` > 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `world`.`skinning_loot_template` lt WHERE lt.`', @slt_entry_col, '` = ct.`', @ct_skin_col, '`)' 
    ),
    'SELECT 0 INTO @cand_before_skin'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_fix_loot = 1,
    CONCAT(
        'SELECT ct.`', @ct_pk_col, '` AS ct_pk, ct.`', @ct_loot_col, '` AS missing_lootid ',
        'FROM `world`.`creature_template` ct ',
        'WHERE ct.`', @ct_loot_col, '` > 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `world`.`creature_loot_template` lt WHERE lt.`', @clt_entry_col, '` = ct.`', @ct_loot_col, '`) ',
        'ORDER BY ct.`', @ct_pk_col, '` LIMIT 50'
    ),
    'SELECT ''SKIP: lootid diagnostics unavailable (missing table/column prerequisites)'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_fix_pick = 1,
    CONCAT(
        'SELECT ct.`', @ct_pk_col, '` AS ct_pk, ct.`', @ct_pick_col, '` AS missing_pickpocketloot ',
        'FROM `world`.`creature_template` ct ',
        'WHERE ct.`', @ct_pick_col, '` > 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `world`.`pickpocketing_loot_template` lt WHERE lt.`', @plt_entry_col, '` = ct.`', @ct_pick_col, '`) ',
        'ORDER BY ct.`', @ct_pk_col, '` LIMIT 50'
    ),
    'SELECT ''SKIP: pickpocketloot diagnostics unavailable (missing table/column prerequisites)'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_fix_skin = 1,
    CONCAT(
        'SELECT ct.`', @ct_pk_col, '` AS ct_pk, ct.`', @ct_skin_col, '` AS missing_skinloot ',
        'FROM `world`.`creature_template` ct ',
        'WHERE ct.`', @ct_skin_col, '` > 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `world`.`skinning_loot_template` lt WHERE lt.`', @slt_entry_col, '` = ct.`', @ct_skin_col, '`) ',
        'ORDER BY ct.`', @ct_pk_col, '` LIMIT 50'
    ),
    'SELECT ''SKIP: skinloot diagnostics unavailable (missing table/column prerequisites)'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @ct_exists = 1,
    'CREATE TABLE IF NOT EXISTS `world`.`creature_template_backup_genre6c` LIKE `world`.`creature_template`',
    'SELECT ''SKIP: backup table creation not requested (diagnostics mode or missing creature_template)'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @limit_clause := IF(@FORCE_BATCH = 1, '', CONCAT(' LIMIT ', @UPDATE_BATCH));

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_loot = 1,
    'DROP TEMPORARY TABLE IF EXISTS `tmp_fix_loot`',
    'SELECT ''SKIP: lootid apply phase not executed'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_loot = 1,
    'CREATE TEMPORARY TABLE `tmp_fix_loot` (`pk` BIGINT UNSIGNED PRIMARY KEY)',
    'SELECT ''SKIP: lootid temp table not created'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_loot = 1,
    CONCAT(
        'INSERT INTO `tmp_fix_loot` (`pk`) ',
        'SELECT ct.`', @ct_pk_col, '` ',
        'FROM `world`.`creature_template` ct ',
        'WHERE ct.`', @ct_loot_col, '` > 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `world`.`creature_loot_template` lt WHERE lt.`', @clt_entry_col, '` = ct.`', @ct_loot_col, '`) ',
        'ORDER BY ct.`', @ct_pk_col, '`',
        @limit_clause
    ),
    'SELECT ''SKIP: lootid temp rows not populated'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_loot = 1,
    CONCAT(
        'INSERT IGNORE INTO `world`.`creature_template_backup_genre6c` ',
        'SELECT ct.* FROM `world`.`creature_template` ct INNER JOIN `tmp_fix_loot` t ON t.`pk` = ct.`', @ct_pk_col, '`'
    ),
    'SELECT ''SKIP: lootid backup insert not executed'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_loot = 1,
    CONCAT(
        'UPDATE `world`.`creature_template` ct INNER JOIN `tmp_fix_loot` t ON t.`pk` = ct.`', @ct_pk_col, '` ',
        'SET ct.`', @ct_loot_col, '` = 0 '
    ),
    'SELECT ''SKIP: lootid update not executed'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
SET @updated_loot := ROW_COUNT();
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_loot = 1,
    'DROP TEMPORARY TABLE IF EXISTS `tmp_fix_loot`',
    'SELECT ''SKIP: lootid temp table cleanup not required'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_pick = 1,
    'DROP TEMPORARY TABLE IF EXISTS `tmp_fix_pick`',
    'SELECT ''SKIP: pickpocketloot apply phase not executed'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_pick = 1,
    'CREATE TEMPORARY TABLE `tmp_fix_pick` (`pk` BIGINT UNSIGNED PRIMARY KEY)',
    'SELECT ''SKIP: pickpocketloot temp table not created'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_pick = 1,
    CONCAT(
        'INSERT INTO `tmp_fix_pick` (`pk`) ',
        'SELECT ct.`', @ct_pk_col, '` ',
        'FROM `world`.`creature_template` ct ',
        'WHERE ct.`', @ct_pick_col, '` > 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `world`.`pickpocketing_loot_template` lt WHERE lt.`', @plt_entry_col, '` = ct.`', @ct_pick_col, '`) ',
        'ORDER BY ct.`', @ct_pk_col, '`',
        @limit_clause
    ),
    'SELECT ''SKIP: pickpocketloot temp rows not populated'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_pick = 1,
    CONCAT(
        'INSERT IGNORE INTO `world`.`creature_template_backup_genre6c` ',
        'SELECT ct.* FROM `world`.`creature_template` ct INNER JOIN `tmp_fix_pick` t ON t.`pk` = ct.`', @ct_pk_col, '`'
    ),
    'SELECT ''SKIP: pickpocketloot backup insert not executed'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_pick = 1,
    CONCAT(
        'UPDATE `world`.`creature_template` ct INNER JOIN `tmp_fix_pick` t ON t.`pk` = ct.`', @ct_pk_col, '` ',
        'SET ct.`', @ct_pick_col, '` = 0 '
    ),
    'SELECT ''SKIP: pickpocketloot update not executed'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
SET @updated_pick := ROW_COUNT();
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_pick = 1,
    'DROP TEMPORARY TABLE IF EXISTS `tmp_fix_pick`',
    'SELECT ''SKIP: pickpocketloot temp table cleanup not required'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_skin = 1,
    'DROP TEMPORARY TABLE IF EXISTS `tmp_fix_skin`',
    'SELECT ''SKIP: skinloot apply phase not executed'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_skin = 1,
    'CREATE TEMPORARY TABLE `tmp_fix_skin` (`pk` BIGINT UNSIGNED PRIMARY KEY)',
    'SELECT ''SKIP: skinloot temp table not created'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_skin = 1,
    CONCAT(
        'INSERT INTO `tmp_fix_skin` (`pk`) ',
        'SELECT ct.`', @ct_pk_col, '` ',
        'FROM `world`.`creature_template` ct ',
        'WHERE ct.`', @ct_skin_col, '` > 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `world`.`skinning_loot_template` lt WHERE lt.`', @slt_entry_col, '` = ct.`', @ct_skin_col, '`) ',
        'ORDER BY ct.`', @ct_pk_col, '`',
        @limit_clause
    ),
    'SELECT ''SKIP: skinloot temp rows not populated'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_skin = 1,
    CONCAT(
        'INSERT IGNORE INTO `world`.`creature_template_backup_genre6c` ',
        'SELECT ct.* FROM `world`.`creature_template` ct INNER JOIN `tmp_fix_skin` t ON t.`pk` = ct.`', @ct_pk_col, '`'
    ),
    'SELECT ''SKIP: skinloot backup insert not executed'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_skin = 1,
    CONCAT(
        'UPDATE `world`.`creature_template` ct INNER JOIN `tmp_fix_skin` t ON t.`pk` = ct.`', @ct_pk_col, '` ',
        'SET ct.`', @ct_skin_col, '` = 0 '
    ),
    'SELECT ''SKIP: skinloot update not executed'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
SET @updated_skin := ROW_COUNT();
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @APPLY_FIX = 1 AND @can_fix_skin = 1,
    'DROP TEMPORARY TABLE IF EXISTS `tmp_fix_skin`',
    'SELECT ''SKIP: skinloot temp table cleanup not required'' AS note'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_fix_loot = 1,
    CONCAT(
        'SELECT COUNT(*) INTO @cand_after_loot FROM `world`.`creature_template` ct ',
        'WHERE ct.`', @ct_loot_col, '` > 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `world`.`creature_loot_template` lt WHERE lt.`', @clt_entry_col, '` = ct.`', @ct_loot_col, '`)' 
    ),
    'SELECT 0 INTO @cand_after_loot'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_fix_pick = 1,
    CONCAT(
        'SELECT COUNT(*) INTO @cand_after_pick FROM `world`.`creature_template` ct ',
        'WHERE ct.`', @ct_pick_col, '` > 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `world`.`pickpocketing_loot_template` lt WHERE lt.`', @plt_entry_col, '` = ct.`', @ct_pick_col, '`)' 
    ),
    'SELECT 0 INTO @cand_after_pick'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_fix_skin = 1,
    CONCAT(
        'SELECT COUNT(*) INTO @cand_after_skin FROM `world`.`creature_template` ct ',
        'WHERE ct.`', @ct_skin_col, '` > 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `world`.`skinning_loot_template` lt WHERE lt.`', @slt_entry_col, '` = ct.`', @ct_skin_col, '`)' 
    ),
    'SELECT 0 INTO @cand_after_skin'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT
    @cand_before_loot AS candidates_before_lootid,
    @updated_loot AS updated_rows_lootid,
    @cand_after_loot AS candidates_after_lootid,
    @cand_before_pick AS candidates_before_pickpocketloot,
    @updated_pick AS updated_rows_pickpocketloot,
    @cand_after_pick AS candidates_after_pickpocketloot,
    @cand_before_skin AS candidates_before_skinloot,
    @updated_skin AS updated_rows_skinloot,
    @cand_after_skin AS candidates_after_skinloot,
    'Re-run with APPLY_FIX=1 until all candidates_after_* are 0. Keep APPLY_FIX=0 for diagnostics only.' AS note;

COMMIT;

SET SESSION sql_safe_updates = @prev_sql_safe_updates;
SET SESSION foreign_key_checks = @prev_foreign_key_checks;
SET SESSION unique_checks = @prev_unique_checks;
SET SESSION autocommit = @prev_autocommit;
