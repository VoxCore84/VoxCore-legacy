USE `world`;
SELECT DATABASE() AS current_database;

SET @OLD_SQL_SAFE_UPDATES := @@SQL_SAFE_UPDATES;
SET @OLD_FOREIGN_KEY_CHECKS := @@FOREIGN_KEY_CHECKS;
SET @OLD_UNIQUE_CHECKS := @@UNIQUE_CHECKS;
SET @OLD_AUTOCOMMIT := @@AUTOCOMMIT;
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;
START TRANSACTION;

DROP TEMPORARY TABLE IF EXISTS tmp_missing_quest_cleanup_summary;
CREATE TEMPORARY TABLE tmp_missing_quest_cleanup_summary (
    table_name VARCHAR(128) NOT NULL,
    orphan_count_before BIGINT NULL,
    deleted_rows BIGINT NOT NULL DEFAULT 0,
    orphan_count_after BIGINT NULL,
    note VARCHAR(255) NULL
);

SELECT COUNT(*) INTO @qt_exists FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'quest_template';
SELECT c.COLUMN_NAME INTO @qt_col
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = DATABASE()
  AND c.TABLE_NAME = 'quest_template'
  AND c.COLUMN_NAME IN ('ID','Id','entry','QuestId','QuestID')
ORDER BY CASE c.COLUMN_NAME WHEN 'ID' THEN 1 WHEN 'Id' THEN 2 WHEN 'entry' THEN 3 WHEN 'QuestId' THEN 4 WHEN 'QuestID' THEN 5 ELSE 100 END
LIMIT 1;
SET @qt_ready := IF(@qt_exists = 1 AND @qt_col IS NOT NULL, 1, 0);
SELECT CASE
  WHEN @qt_exists = 0 THEN 'SKIP: quest_template missing'
  WHEN @qt_col IS NULL THEN 'SKIP: quest_template quest-id column not found'
  ELSE CONCAT('INFO: quest_template detected, quest id column = ', @qt_col)
END AS note;

SET @table_name := 'quest_template_addon';
SET @quest_col := NULL;
SET @tbl_exists := 0;
SELECT COUNT(*) INTO @tbl_exists FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @table_name;
SELECT c.COLUMN_NAME INTO @quest_col
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = DATABASE()
  AND c.TABLE_NAME = @table_name
  AND c.COLUMN_NAME IN ('ID','QuestID','QuestId','Id')
ORDER BY CASE c.COLUMN_NAME WHEN 'ID' THEN 1 WHEN 'QuestID' THEN 2 WHEN 'QuestId' THEN 3 WHEN 'Id' THEN 4 ELSE 100 END
LIMIT 1;
SET @can_process := IF(@tbl_exists = 1 AND @quest_col IS NOT NULL AND @qt_ready = 1, 1, 0);
SET @skip_note := CASE
  WHEN @tbl_exists = 0 THEN CONCAT('SKIP: ', @table_name, ' missing')
  WHEN @quest_col IS NULL THEN CONCAT('SKIP: ', @table_name, ' quest-id column not found')
  WHEN @qt_ready = 0 THEN CONCAT('SKIP: ', @table_name, ' not modified (quest_template missing or quest id column missing)')
  ELSE 'processed' END;
SELECT @skip_note AS note;
SET @orph_before := NULL;
SET @deleted := 0;
SET @orph_after := NULL;
SET @backup_name := CONCAT(@table_name, '_backup_missing_quest');
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '`')
);
SET @sql := IF(@tbl_exists = 1, @sql, 'SELECT NULL INTO @orph_before');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS BEFORE ', @table_name, ': ', IFNULL(@orph_before, 'NULL')) AS note;
SET @sql := IF(@can_process = 1,
  CONCAT('CREATE TABLE IF NOT EXISTS `', @backup_name, '` LIKE `', @table_name, '`'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('INSERT IGNORE INTO `', @backup_name, '` SELECT t.* FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('DELETE t FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted := IF(@can_process = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;
SELECT @deleted AS deleted_rowcount;
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_after FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT NULL INTO @orph_after');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS AFTER ', @table_name, ': ', IFNULL(@orph_after, 'NULL')) AS note;
INSERT INTO tmp_missing_quest_cleanup_summary(table_name, orphan_count_before, deleted_rows, orphan_count_after, note)
VALUES(@table_name, @orph_before, @deleted, @orph_after, @skip_note);

SET @table_name := 'quest_objectives';
SET @quest_col := NULL;
SET @tbl_exists := 0;
SELECT COUNT(*) INTO @tbl_exists FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @table_name;
SELECT c.COLUMN_NAME INTO @quest_col
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = DATABASE()
  AND c.TABLE_NAME = @table_name
  AND c.COLUMN_NAME IN ('QuestID','QuestId','ID','Id')
ORDER BY CASE c.COLUMN_NAME WHEN 'QuestID' THEN 1 WHEN 'QuestId' THEN 2 WHEN 'ID' THEN 3 WHEN 'Id' THEN 4 ELSE 100 END
LIMIT 1;
SET @can_process := IF(@tbl_exists = 1 AND @quest_col IS NOT NULL AND @qt_ready = 1, 1, 0);
SET @skip_note := CASE
  WHEN @tbl_exists = 0 THEN CONCAT('SKIP: ', @table_name, ' missing')
  WHEN @quest_col IS NULL THEN CONCAT('SKIP: ', @table_name, ' quest-id column not found')
  WHEN @qt_ready = 0 THEN CONCAT('SKIP: ', @table_name, ' not modified (quest_template missing or quest id column missing)')
  ELSE 'processed' END;
SELECT @skip_note AS note;
SET @orph_before := NULL;
SET @deleted := 0;
SET @orph_after := NULL;
SET @backup_name := CONCAT(@table_name, '_backup_missing_quest');
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '`')
);
SET @sql := IF(@tbl_exists = 1, @sql, 'SELECT NULL INTO @orph_before');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS BEFORE ', @table_name, ': ', IFNULL(@orph_before, 'NULL')) AS note;
SET @sql := IF(@can_process = 1,
  CONCAT('CREATE TABLE IF NOT EXISTS `', @backup_name, '` LIKE `', @table_name, '`'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('INSERT IGNORE INTO `', @backup_name, '` SELECT t.* FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('DELETE t FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted := IF(@can_process = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;
SELECT @deleted AS deleted_rowcount;
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_after FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT NULL INTO @orph_after');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS AFTER ', @table_name, ': ', IFNULL(@orph_after, 'NULL')) AS note;
INSERT INTO tmp_missing_quest_cleanup_summary(table_name, orphan_count_before, deleted_rows, orphan_count_after, note)
VALUES(@table_name, @orph_before, @deleted, @orph_after, @skip_note);

SET @table_name := 'quest_details';
SET @quest_col := NULL;
SET @tbl_exists := 0;
SELECT COUNT(*) INTO @tbl_exists FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @table_name;
SELECT c.COLUMN_NAME INTO @quest_col
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = DATABASE()
  AND c.TABLE_NAME = @table_name
  AND c.COLUMN_NAME IN ('ID','QuestID','QuestId','Id')
ORDER BY CASE c.COLUMN_NAME WHEN 'ID' THEN 1 WHEN 'QuestID' THEN 2 WHEN 'QuestId' THEN 3 WHEN 'Id' THEN 4 ELSE 100 END
LIMIT 1;
SET @can_process := IF(@tbl_exists = 1 AND @quest_col IS NOT NULL AND @qt_ready = 1, 1, 0);
SET @skip_note := CASE
  WHEN @tbl_exists = 0 THEN CONCAT('SKIP: ', @table_name, ' missing')
  WHEN @quest_col IS NULL THEN CONCAT('SKIP: ', @table_name, ' quest-id column not found')
  WHEN @qt_ready = 0 THEN CONCAT('SKIP: ', @table_name, ' not modified (quest_template missing or quest id column missing)')
  ELSE 'processed' END;
SELECT @skip_note AS note;
SET @orph_before := NULL;
SET @deleted := 0;
SET @orph_after := NULL;
SET @backup_name := CONCAT(@table_name, '_backup_missing_quest');
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '`')
);
SET @sql := IF(@tbl_exists = 1, @sql, 'SELECT NULL INTO @orph_before');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS BEFORE ', @table_name, ': ', IFNULL(@orph_before, 'NULL')) AS note;
SET @sql := IF(@can_process = 1,
  CONCAT('CREATE TABLE IF NOT EXISTS `', @backup_name, '` LIKE `', @table_name, '`'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('INSERT IGNORE INTO `', @backup_name, '` SELECT t.* FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('DELETE t FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted := IF(@can_process = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;
SELECT @deleted AS deleted_rowcount;
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_after FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT NULL INTO @orph_after');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS AFTER ', @table_name, ': ', IFNULL(@orph_after, 'NULL')) AS note;
INSERT INTO tmp_missing_quest_cleanup_summary(table_name, orphan_count_before, deleted_rows, orphan_count_after, note)
VALUES(@table_name, @orph_before, @deleted, @orph_after, @skip_note);

SET @table_name := 'quest_offer_reward';
SET @quest_col := NULL;
SET @tbl_exists := 0;
SELECT COUNT(*) INTO @tbl_exists FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @table_name;
SELECT c.COLUMN_NAME INTO @quest_col
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = DATABASE()
  AND c.TABLE_NAME = @table_name
  AND c.COLUMN_NAME IN ('ID','QuestID','QuestId','Id')
ORDER BY CASE c.COLUMN_NAME WHEN 'ID' THEN 1 WHEN 'QuestID' THEN 2 WHEN 'QuestId' THEN 3 WHEN 'Id' THEN 4 ELSE 100 END
LIMIT 1;
SET @can_process := IF(@tbl_exists = 1 AND @quest_col IS NOT NULL AND @qt_ready = 1, 1, 0);
SET @skip_note := CASE
  WHEN @tbl_exists = 0 THEN CONCAT('SKIP: ', @table_name, ' missing')
  WHEN @quest_col IS NULL THEN CONCAT('SKIP: ', @table_name, ' quest-id column not found')
  WHEN @qt_ready = 0 THEN CONCAT('SKIP: ', @table_name, ' not modified (quest_template missing or quest id column missing)')
  ELSE 'processed' END;
SELECT @skip_note AS note;
SET @orph_before := NULL;
SET @deleted := 0;
SET @orph_after := NULL;
SET @backup_name := CONCAT(@table_name, '_backup_missing_quest');
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '`')
);
SET @sql := IF(@tbl_exists = 1, @sql, 'SELECT NULL INTO @orph_before');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS BEFORE ', @table_name, ': ', IFNULL(@orph_before, 'NULL')) AS note;
SET @sql := IF(@can_process = 1,
  CONCAT('CREATE TABLE IF NOT EXISTS `', @backup_name, '` LIKE `', @table_name, '`'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('INSERT IGNORE INTO `', @backup_name, '` SELECT t.* FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('DELETE t FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted := IF(@can_process = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;
SELECT @deleted AS deleted_rowcount;
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_after FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT NULL INTO @orph_after');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS AFTER ', @table_name, ': ', IFNULL(@orph_after, 'NULL')) AS note;
INSERT INTO tmp_missing_quest_cleanup_summary(table_name, orphan_count_before, deleted_rows, orphan_count_after, note)
VALUES(@table_name, @orph_before, @deleted, @orph_after, @skip_note);

SET @table_name := 'quest_reward_display_spell';
SET @quest_col := NULL;
SET @tbl_exists := 0;
SELECT COUNT(*) INTO @tbl_exists FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @table_name;
SELECT c.COLUMN_NAME INTO @quest_col
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = DATABASE()
  AND c.TABLE_NAME = @table_name
  AND c.COLUMN_NAME IN ('ID','QuestID','QuestId','Id')
ORDER BY CASE c.COLUMN_NAME WHEN 'ID' THEN 1 WHEN 'QuestID' THEN 2 WHEN 'QuestId' THEN 3 WHEN 'Id' THEN 4 ELSE 100 END
LIMIT 1;
SET @can_process := IF(@tbl_exists = 1 AND @quest_col IS NOT NULL AND @qt_ready = 1, 1, 0);
SET @skip_note := CASE
  WHEN @tbl_exists = 0 THEN CONCAT('SKIP: ', @table_name, ' missing')
  WHEN @quest_col IS NULL THEN CONCAT('SKIP: ', @table_name, ' quest-id column not found')
  WHEN @qt_ready = 0 THEN CONCAT('SKIP: ', @table_name, ' not modified (quest_template missing or quest id column missing)')
  ELSE 'processed' END;
SELECT @skip_note AS note;
SET @orph_before := NULL;
SET @deleted := 0;
SET @orph_after := NULL;
SET @backup_name := CONCAT(@table_name, '_backup_missing_quest');
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '`')
);
SET @sql := IF(@tbl_exists = 1, @sql, 'SELECT NULL INTO @orph_before');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS BEFORE ', @table_name, ': ', IFNULL(@orph_before, 'NULL')) AS note;
SET @sql := IF(@can_process = 1,
  CONCAT('CREATE TABLE IF NOT EXISTS `', @backup_name, '` LIKE `', @table_name, '`'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('INSERT IGNORE INTO `', @backup_name, '` SELECT t.* FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('DELETE t FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted := IF(@can_process = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;
SELECT @deleted AS deleted_rowcount;
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_after FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT NULL INTO @orph_after');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS AFTER ', @table_name, ': ', IFNULL(@orph_after, 'NULL')) AS note;
INSERT INTO tmp_missing_quest_cleanup_summary(table_name, orphan_count_before, deleted_rows, orphan_count_after, note)
VALUES(@table_name, @orph_before, @deleted, @orph_after, @skip_note);

SET @table_name := 'quest_request_items';
SET @quest_col := NULL;
SET @tbl_exists := 0;
SELECT COUNT(*) INTO @tbl_exists FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @table_name;
SELECT c.COLUMN_NAME INTO @quest_col
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = DATABASE()
  AND c.TABLE_NAME = @table_name
  AND c.COLUMN_NAME IN ('ID','QuestID','QuestId','Id')
ORDER BY CASE c.COLUMN_NAME WHEN 'ID' THEN 1 WHEN 'QuestID' THEN 2 WHEN 'QuestId' THEN 3 WHEN 'Id' THEN 4 ELSE 100 END
LIMIT 1;
SET @can_process := IF(@tbl_exists = 1 AND @quest_col IS NOT NULL AND @qt_ready = 1, 1, 0);
SET @skip_note := CASE
  WHEN @tbl_exists = 0 THEN CONCAT('SKIP: ', @table_name, ' missing')
  WHEN @quest_col IS NULL THEN CONCAT('SKIP: ', @table_name, ' quest-id column not found')
  WHEN @qt_ready = 0 THEN CONCAT('SKIP: ', @table_name, ' not modified (quest_template missing or quest id column missing)')
  ELSE 'processed' END;
SELECT @skip_note AS note;
SET @orph_before := NULL;
SET @deleted := 0;
SET @orph_after := NULL;
SET @backup_name := CONCAT(@table_name, '_backup_missing_quest');
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '`')
);
SET @sql := IF(@tbl_exists = 1, @sql, 'SELECT NULL INTO @orph_before');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS BEFORE ', @table_name, ': ', IFNULL(@orph_before, 'NULL')) AS note;
SET @sql := IF(@can_process = 1,
  CONCAT('CREATE TABLE IF NOT EXISTS `', @backup_name, '` LIKE `', @table_name, '`'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('INSERT IGNORE INTO `', @backup_name, '` SELECT t.* FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('DELETE t FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted := IF(@can_process = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;
SELECT @deleted AS deleted_rowcount;
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_after FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT NULL INTO @orph_after');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS AFTER ', @table_name, ': ', IFNULL(@orph_after, 'NULL')) AS note;
INSERT INTO tmp_missing_quest_cleanup_summary(table_name, orphan_count_before, deleted_rows, orphan_count_after, note)
VALUES(@table_name, @orph_before, @deleted, @orph_after, @skip_note);

SET @table_name := 'quest_mail_sender';
SET @quest_col := NULL;
SET @tbl_exists := 0;
SELECT COUNT(*) INTO @tbl_exists FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @table_name;
SELECT c.COLUMN_NAME INTO @quest_col
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = DATABASE()
  AND c.TABLE_NAME = @table_name
  AND c.COLUMN_NAME IN ('ID','QuestID','QuestId','Id')
ORDER BY CASE c.COLUMN_NAME WHEN 'ID' THEN 1 WHEN 'QuestID' THEN 2 WHEN 'QuestId' THEN 3 WHEN 'Id' THEN 4 ELSE 100 END
LIMIT 1;
SET @can_process := IF(@tbl_exists = 1 AND @quest_col IS NOT NULL AND @qt_ready = 1, 1, 0);
SET @skip_note := CASE
  WHEN @tbl_exists = 0 THEN CONCAT('SKIP: ', @table_name, ' missing')
  WHEN @quest_col IS NULL THEN CONCAT('SKIP: ', @table_name, ' quest-id column not found')
  WHEN @qt_ready = 0 THEN CONCAT('SKIP: ', @table_name, ' not modified (quest_template missing or quest id column missing)')
  ELSE 'processed' END;
SELECT @skip_note AS note;
SET @orph_before := NULL;
SET @deleted := 0;
SET @orph_after := NULL;
SET @backup_name := CONCAT(@table_name, '_backup_missing_quest');
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '`')
);
SET @sql := IF(@tbl_exists = 1, @sql, 'SELECT NULL INTO @orph_before');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS BEFORE ', @table_name, ': ', IFNULL(@orph_before, 'NULL')) AS note;
SET @sql := IF(@can_process = 1,
  CONCAT('CREATE TABLE IF NOT EXISTS `', @backup_name, '` LIKE `', @table_name, '`'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('INSERT IGNORE INTO `', @backup_name, '` SELECT t.* FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('DELETE t FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted := IF(@can_process = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;
SELECT @deleted AS deleted_rowcount;
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_after FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT NULL INTO @orph_after');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS AFTER ', @table_name, ': ', IFNULL(@orph_after, 'NULL')) AS note;
INSERT INTO tmp_missing_quest_cleanup_summary(table_name, orphan_count_before, deleted_rows, orphan_count_after, note)
VALUES(@table_name, @orph_before, @deleted, @orph_after, @skip_note);

SET @table_name := 'creature_queststarter';
SET @quest_col := NULL;
SET @tbl_exists := 0;
SELECT COUNT(*) INTO @tbl_exists FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @table_name;
SELECT c.COLUMN_NAME INTO @quest_col
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = DATABASE()
  AND c.TABLE_NAME = @table_name
  AND c.COLUMN_NAME IN ('quest','QuestId','QuestID','ID','Id')
ORDER BY CASE c.COLUMN_NAME WHEN 'quest' THEN 1 WHEN 'QuestId' THEN 2 WHEN 'QuestID' THEN 3 WHEN 'ID' THEN 4 WHEN 'Id' THEN 5 ELSE 100 END
LIMIT 1;
SET @can_process := IF(@tbl_exists = 1 AND @quest_col IS NOT NULL AND @qt_ready = 1, 1, 0);
SET @skip_note := CASE
  WHEN @tbl_exists = 0 THEN CONCAT('SKIP: ', @table_name, ' missing')
  WHEN @quest_col IS NULL THEN CONCAT('SKIP: ', @table_name, ' quest-id column not found')
  WHEN @qt_ready = 0 THEN CONCAT('SKIP: ', @table_name, ' not modified (quest_template missing or quest id column missing)')
  ELSE 'processed' END;
SELECT @skip_note AS note;
SET @orph_before := NULL;
SET @deleted := 0;
SET @orph_after := NULL;
SET @backup_name := CONCAT(@table_name, '_backup_missing_quest');
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '`')
);
SET @sql := IF(@tbl_exists = 1, @sql, 'SELECT NULL INTO @orph_before');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS BEFORE ', @table_name, ': ', IFNULL(@orph_before, 'NULL')) AS note;
SET @sql := IF(@can_process = 1,
  CONCAT('CREATE TABLE IF NOT EXISTS `', @backup_name, '` LIKE `', @table_name, '`'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('INSERT IGNORE INTO `', @backup_name, '` SELECT t.* FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('DELETE t FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted := IF(@can_process = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;
SELECT @deleted AS deleted_rowcount;
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_after FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT NULL INTO @orph_after');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS AFTER ', @table_name, ': ', IFNULL(@orph_after, 'NULL')) AS note;
INSERT INTO tmp_missing_quest_cleanup_summary(table_name, orphan_count_before, deleted_rows, orphan_count_after, note)
VALUES(@table_name, @orph_before, @deleted, @orph_after, @skip_note);

SET @table_name := 'creature_questender';
SET @quest_col := NULL;
SET @tbl_exists := 0;
SELECT COUNT(*) INTO @tbl_exists FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @table_name;
SELECT c.COLUMN_NAME INTO @quest_col
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = DATABASE()
  AND c.TABLE_NAME = @table_name
  AND c.COLUMN_NAME IN ('quest','QuestId','QuestID','ID','Id')
ORDER BY CASE c.COLUMN_NAME WHEN 'quest' THEN 1 WHEN 'QuestId' THEN 2 WHEN 'QuestID' THEN 3 WHEN 'ID' THEN 4 WHEN 'Id' THEN 5 ELSE 100 END
LIMIT 1;
SET @can_process := IF(@tbl_exists = 1 AND @quest_col IS NOT NULL AND @qt_ready = 1, 1, 0);
SET @skip_note := CASE
  WHEN @tbl_exists = 0 THEN CONCAT('SKIP: ', @table_name, ' missing')
  WHEN @quest_col IS NULL THEN CONCAT('SKIP: ', @table_name, ' quest-id column not found')
  WHEN @qt_ready = 0 THEN CONCAT('SKIP: ', @table_name, ' not modified (quest_template missing or quest id column missing)')
  ELSE 'processed' END;
SELECT @skip_note AS note;
SET @orph_before := NULL;
SET @deleted := 0;
SET @orph_after := NULL;
SET @backup_name := CONCAT(@table_name, '_backup_missing_quest');
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '`')
);
SET @sql := IF(@tbl_exists = 1, @sql, 'SELECT NULL INTO @orph_before');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS BEFORE ', @table_name, ': ', IFNULL(@orph_before, 'NULL')) AS note;
SET @sql := IF(@can_process = 1,
  CONCAT('CREATE TABLE IF NOT EXISTS `', @backup_name, '` LIKE `', @table_name, '`'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('INSERT IGNORE INTO `', @backup_name, '` SELECT t.* FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('DELETE t FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted := IF(@can_process = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;
SELECT @deleted AS deleted_rowcount;
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_after FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT NULL INTO @orph_after');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS AFTER ', @table_name, ': ', IFNULL(@orph_after, 'NULL')) AS note;
INSERT INTO tmp_missing_quest_cleanup_summary(table_name, orphan_count_before, deleted_rows, orphan_count_after, note)
VALUES(@table_name, @orph_before, @deleted, @orph_after, @skip_note);

SET @table_name := 'gameobject_queststarter';
SET @quest_col := NULL;
SET @tbl_exists := 0;
SELECT COUNT(*) INTO @tbl_exists FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @table_name;
SELECT c.COLUMN_NAME INTO @quest_col
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = DATABASE()
  AND c.TABLE_NAME = @table_name
  AND c.COLUMN_NAME IN ('quest','QuestId','QuestID','ID','Id')
ORDER BY CASE c.COLUMN_NAME WHEN 'quest' THEN 1 WHEN 'QuestId' THEN 2 WHEN 'QuestID' THEN 3 WHEN 'ID' THEN 4 WHEN 'Id' THEN 5 ELSE 100 END
LIMIT 1;
SET @can_process := IF(@tbl_exists = 1 AND @quest_col IS NOT NULL AND @qt_ready = 1, 1, 0);
SET @skip_note := CASE
  WHEN @tbl_exists = 0 THEN CONCAT('SKIP: ', @table_name, ' missing')
  WHEN @quest_col IS NULL THEN CONCAT('SKIP: ', @table_name, ' quest-id column not found')
  WHEN @qt_ready = 0 THEN CONCAT('SKIP: ', @table_name, ' not modified (quest_template missing or quest id column missing)')
  ELSE 'processed' END;
SELECT @skip_note AS note;
SET @orph_before := NULL;
SET @deleted := 0;
SET @orph_after := NULL;
SET @backup_name := CONCAT(@table_name, '_backup_missing_quest');
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '`')
);
SET @sql := IF(@tbl_exists = 1, @sql, 'SELECT NULL INTO @orph_before');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS BEFORE ', @table_name, ': ', IFNULL(@orph_before, 'NULL')) AS note;
SET @sql := IF(@can_process = 1,
  CONCAT('CREATE TABLE IF NOT EXISTS `', @backup_name, '` LIKE `', @table_name, '`'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('INSERT IGNORE INTO `', @backup_name, '` SELECT t.* FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('DELETE t FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted := IF(@can_process = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;
SELECT @deleted AS deleted_rowcount;
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_after FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT NULL INTO @orph_after');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS AFTER ', @table_name, ': ', IFNULL(@orph_after, 'NULL')) AS note;
INSERT INTO tmp_missing_quest_cleanup_summary(table_name, orphan_count_before, deleted_rows, orphan_count_after, note)
VALUES(@table_name, @orph_before, @deleted, @orph_after, @skip_note);

SET @table_name := 'gameobject_questender';
SET @quest_col := NULL;
SET @tbl_exists := 0;
SELECT COUNT(*) INTO @tbl_exists FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @table_name;
SELECT c.COLUMN_NAME INTO @quest_col
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = DATABASE()
  AND c.TABLE_NAME = @table_name
  AND c.COLUMN_NAME IN ('quest','QuestId','QuestID','ID','Id')
ORDER BY CASE c.COLUMN_NAME WHEN 'quest' THEN 1 WHEN 'QuestId' THEN 2 WHEN 'QuestID' THEN 3 WHEN 'ID' THEN 4 WHEN 'Id' THEN 5 ELSE 100 END
LIMIT 1;
SET @can_process := IF(@tbl_exists = 1 AND @quest_col IS NOT NULL AND @qt_ready = 1, 1, 0);
SET @skip_note := CASE
  WHEN @tbl_exists = 0 THEN CONCAT('SKIP: ', @table_name, ' missing')
  WHEN @quest_col IS NULL THEN CONCAT('SKIP: ', @table_name, ' quest-id column not found')
  WHEN @qt_ready = 0 THEN CONCAT('SKIP: ', @table_name, ' not modified (quest_template missing or quest id column missing)')
  ELSE 'processed' END;
SELECT @skip_note AS note;
SET @orph_before := NULL;
SET @deleted := 0;
SET @orph_after := NULL;
SET @backup_name := CONCAT(@table_name, '_backup_missing_quest');
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  CONCAT('SELECT COUNT(*) INTO @orph_before FROM `', @table_name, '`')
);
SET @sql := IF(@tbl_exists = 1, @sql, 'SELECT NULL INTO @orph_before');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS BEFORE ', @table_name, ': ', IFNULL(@orph_before, 'NULL')) AS note;
SET @sql := IF(@can_process = 1,
  CONCAT('CREATE TABLE IF NOT EXISTS `', @backup_name, '` LIKE `', @table_name, '`'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('INSERT IGNORE INTO `', @backup_name, '` SELECT t.* FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@can_process = 1,
  CONCAT('DELETE t FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT 0');
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted := IF(@can_process = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;
SELECT @deleted AS deleted_rowcount;
SET @sql := IF(@can_process = 1,
  CONCAT('SELECT COUNT(*) INTO @orph_after FROM `', @table_name, '` t LEFT JOIN `quest_template` qt ON t.`', @quest_col, '` = qt.`', @qt_col, '` WHERE qt.`', @qt_col, '` IS NULL'),
  'SELECT NULL INTO @orph_after');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT CONCAT('ORPHANS AFTER ', @table_name, ': ', IFNULL(@orph_after, 'NULL')) AS note;
INSERT INTO tmp_missing_quest_cleanup_summary(table_name, orphan_count_before, deleted_rows, orphan_count_after, note)
VALUES(@table_name, @orph_before, @deleted, @orph_after, @skip_note);

SELECT table_name, orphan_count_before, deleted_rows, orphan_count_after, note
FROM tmp_missing_quest_cleanup_summary
ORDER BY table_name;
COMMIT;
SET SQL_SAFE_UPDATES = @OLD_SQL_SAFE_UPDATES;
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;
SET AUTOCOMMIT = @OLD_AUTOCOMMIT;
