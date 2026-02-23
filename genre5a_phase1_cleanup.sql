USE `world`;
SELECT DATABASE();

SET @db := DATABASE();

SET @old_sql_safe_updates := @@SQL_SAFE_UPDATES;
SET @old_foreign_key_checks := @@FOREIGN_KEY_CHECKS;
SET @old_unique_checks := @@UNIQUE_CHECKS;
SET @old_autocommit := @@AUTOCOMMIT;

SET @deleted_creature := 0;
SET @deleted_gameobject := 0;
SET @deleted_creature_addon := 0;
SET @deleted_gameobject_addon := 0;

SET @remaining_orphan_creatures := NULL;
SET @remaining_orphan_gameobjects := NULL;
SET @remaining_orphan_creature_addon := NULL;
SET @remaining_orphan_gameobject_addon := NULL;

SET @has_creature := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = @db AND TABLE_NAME = 'creature'
);
SET @has_creature_template := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = @db AND TABLE_NAME = 'creature_template'
);
SET @has_gameobject := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = @db AND TABLE_NAME = 'gameobject'
);
SET @has_gameobject_template := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = @db AND TABLE_NAME = 'gameobject_template'
);
SET @has_creature_addon := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = @db AND TABLE_NAME = 'creature_addon'
);
SET @has_gameobject_addon := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = @db AND TABLE_NAME = 'gameobject_addon'
);

SET @creature_guid_col := (
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @db
      AND TABLE_NAME = 'creature'
      AND COLUMN_NAME IN ('guid', 'GUID')
    ORDER BY FIELD(COLUMN_NAME, 'guid', 'GUID')
    LIMIT 1
);
SET @creature_template_col := (
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @db
      AND TABLE_NAME = 'creature'
      AND COLUMN_NAME IN ('id', 'id1', 'entry', 'creatureid')
    ORDER BY FIELD(COLUMN_NAME, 'id', 'id1', 'entry', 'creatureid')
    LIMIT 1
);
SET @creature_template_pk_col := (
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @db
      AND TABLE_NAME = 'creature_template'
      AND COLUMN_NAME IN ('entry', 'Entry', 'ID', 'Id')
    ORDER BY FIELD(COLUMN_NAME, 'entry', 'Entry', 'ID', 'Id')
    LIMIT 1
);

SET @gameobject_guid_col := (
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @db
      AND TABLE_NAME = 'gameobject'
      AND COLUMN_NAME IN ('guid', 'GUID')
    ORDER BY FIELD(COLUMN_NAME, 'guid', 'GUID')
    LIMIT 1
);
SET @gameobject_template_col := (
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @db
      AND TABLE_NAME = 'gameobject'
      AND COLUMN_NAME IN ('id', 'entry', 'gameobjectid')
    ORDER BY FIELD(COLUMN_NAME, 'id', 'entry', 'gameobjectid')
    LIMIT 1
);
SET @gameobject_template_pk_col := (
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @db
      AND TABLE_NAME = 'gameobject_template'
      AND COLUMN_NAME IN ('entry', 'Entry', 'ID', 'Id')
    ORDER BY FIELD(COLUMN_NAME, 'entry', 'Entry', 'ID', 'Id')
    LIMIT 1
);

SET @creature_addon_guid_col := (
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @db
      AND TABLE_NAME = 'creature_addon'
      AND COLUMN_NAME IN ('guid', 'GUID')
    ORDER BY FIELD(COLUMN_NAME, 'guid', 'GUID')
    LIMIT 1
);
SET @gameobject_addon_guid_col := (
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @db
      AND TABLE_NAME = 'gameobject_addon'
      AND COLUMN_NAME IN ('guid', 'GUID')
    ORDER BY FIELD(COLUMN_NAME, 'guid', 'GUID')
    LIMIT 1
);

SET @can_creature_cleanup := (
    @has_creature = 1
    AND @has_creature_template = 1
    AND @creature_guid_col IS NOT NULL
    AND @creature_template_col IS NOT NULL
    AND @creature_template_pk_col IS NOT NULL
);
SET @can_gameobject_cleanup := (
    @has_gameobject = 1
    AND @has_gameobject_template = 1
    AND @gameobject_guid_col IS NOT NULL
    AND @gameobject_template_col IS NOT NULL
    AND @gameobject_template_pk_col IS NOT NULL
);
SET @can_creature_addon_cleanup := (
    @has_creature_addon = 1
    AND @has_creature = 1
    AND @creature_addon_guid_col IS NOT NULL
    AND @creature_guid_col IS NOT NULL
);
SET @can_gameobject_addon_cleanup := (
    @has_gameobject_addon = 1
    AND @has_gameobject = 1
    AND @gameobject_addon_guid_col IS NOT NULL
    AND @gameobject_guid_col IS NOT NULL
);

START TRANSACTION;
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;

SET @sql := IF(
    @can_creature_cleanup,
    'CREATE TABLE IF NOT EXISTS `creature_backup_genre5a` LIKE `creature`',
    "SELECT 'SKIP: creature cleanup unavailable (missing table/column in creature or creature_template).' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_creature_cleanup,
    CONCAT(
        'INSERT IGNORE INTO `creature_backup_genre5a` ',
        'SELECT c.* FROM `creature` c ',
        'LEFT JOIN `creature_template` ct ON c.`', @creature_template_col, '` = ct.`', @creature_template_pk_col, '` ',
        'WHERE ct.`', @creature_template_pk_col, '` IS NULL'
    ),
    "SELECT 'SKIP: creature backup insert skipped.' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_creature_cleanup,
    CONCAT(
        'DELETE c FROM `creature` c ',
        'LEFT JOIN `creature_template` ct ON c.`', @creature_template_col, '` = ct.`', @creature_template_pk_col, '` ',
        'WHERE ct.`', @creature_template_pk_col, '` IS NULL'
    ),
    'SELECT 0'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
SET @deleted_creature := IF(@can_creature_cleanup, ROW_COUNT(), 0);
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_gameobject_cleanup,
    'CREATE TABLE IF NOT EXISTS `gameobject_backup_genre5a` LIKE `gameobject`',
    "SELECT 'SKIP: gameobject cleanup unavailable (missing table/column in gameobject or gameobject_template).' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_gameobject_cleanup,
    CONCAT(
        'INSERT IGNORE INTO `gameobject_backup_genre5a` ',
        'SELECT g.* FROM `gameobject` g ',
        'LEFT JOIN `gameobject_template` gt ON g.`', @gameobject_template_col, '` = gt.`', @gameobject_template_pk_col, '` ',
        'WHERE gt.`', @gameobject_template_pk_col, '` IS NULL'
    ),
    "SELECT 'SKIP: gameobject backup insert skipped.' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_gameobject_cleanup,
    CONCAT(
        'DELETE g FROM `gameobject` g ',
        'LEFT JOIN `gameobject_template` gt ON g.`', @gameobject_template_col, '` = gt.`', @gameobject_template_pk_col, '` ',
        'WHERE gt.`', @gameobject_template_pk_col, '` IS NULL'
    ),
    'SELECT 0'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
SET @deleted_gameobject := IF(@can_gameobject_cleanup, ROW_COUNT(), 0);
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_creature_addon = 1,
    IF(
        @can_creature_addon_cleanup,
        'CREATE TABLE IF NOT EXISTS `creature_addon_backup_genre5a` LIKE `creature_addon`',
        "SELECT 'SKIP: creature_addon cleanup unavailable (missing creature table/guid or creature_addon guid).' AS note"
    ),
    "SELECT 'SKIP: creature_addon table not found.' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_creature_addon_cleanup,
    CONCAT(
        'INSERT IGNORE INTO `creature_addon_backup_genre5a` ',
        'SELECT ca.* FROM `creature_addon` ca ',
        'LEFT JOIN `creature` c ON ca.`', @creature_addon_guid_col, '` = c.`', @creature_guid_col, '` ',
        'WHERE c.`', @creature_guid_col, '` IS NULL'
    ),
    "SELECT 'SKIP: creature_addon backup insert skipped.' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_creature_addon_cleanup,
    CONCAT(
        'DELETE ca FROM `creature_addon` ca ',
        'LEFT JOIN `creature` c ON ca.`', @creature_addon_guid_col, '` = c.`', @creature_guid_col, '` ',
        'WHERE c.`', @creature_guid_col, '` IS NULL'
    ),
    'SELECT 0'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
SET @deleted_creature_addon := IF(@can_creature_addon_cleanup, ROW_COUNT(), 0);
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_gameobject_addon = 1,
    IF(
        @can_gameobject_addon_cleanup,
        'CREATE TABLE IF NOT EXISTS `gameobject_addon_backup_genre5a` LIKE `gameobject_addon`',
        "SELECT 'SKIP: gameobject_addon cleanup unavailable (missing gameobject table/guid or gameobject_addon guid).' AS note"
    ),
    "SELECT 'SKIP: gameobject_addon table not found.' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_gameobject_addon_cleanup,
    CONCAT(
        'INSERT IGNORE INTO `gameobject_addon_backup_genre5a` ',
        'SELECT ga.* FROM `gameobject_addon` ga ',
        'LEFT JOIN `gameobject` g ON ga.`', @gameobject_addon_guid_col, '` = g.`', @gameobject_guid_col, '` ',
        'WHERE g.`', @gameobject_guid_col, '` IS NULL'
    ),
    "SELECT 'SKIP: gameobject_addon backup insert skipped.' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_gameobject_addon_cleanup,
    CONCAT(
        'DELETE ga FROM `gameobject_addon` ga ',
        'LEFT JOIN `gameobject` g ON ga.`', @gameobject_addon_guid_col, '` = g.`', @gameobject_guid_col, '` ',
        'WHERE g.`', @gameobject_guid_col, '` IS NULL'
    ),
    'SELECT 0'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
SET @deleted_gameobject_addon := IF(@can_gameobject_addon_cleanup, ROW_COUNT(), 0);
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_creature_cleanup,
    CONCAT(
        'SELECT COUNT(*) INTO @remaining_orphan_creatures FROM `creature` c ',
        'LEFT JOIN `creature_template` ct ON c.`', @creature_template_col, '` = ct.`', @creature_template_pk_col, '` ',
        'WHERE ct.`', @creature_template_pk_col, '` IS NULL'
    ),
    "SELECT 'SKIP: cannot verify orphan creatures (missing table/column).' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_gameobject_cleanup,
    CONCAT(
        'SELECT COUNT(*) INTO @remaining_orphan_gameobjects FROM `gameobject` g ',
        'LEFT JOIN `gameobject_template` gt ON g.`', @gameobject_template_col, '` = gt.`', @gameobject_template_pk_col, '` ',
        'WHERE gt.`', @gameobject_template_pk_col, '` IS NULL'
    ),
    "SELECT 'SKIP: cannot verify orphan gameobjects (missing table/column).' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_creature_addon_cleanup,
    CONCAT(
        'SELECT COUNT(*) INTO @remaining_orphan_creature_addon FROM `creature_addon` ca ',
        'LEFT JOIN `creature` c ON ca.`', @creature_addon_guid_col, '` = c.`', @creature_guid_col, '` ',
        'WHERE c.`', @creature_guid_col, '` IS NULL'
    ),
    "SELECT 'SKIP: cannot verify orphan creature_addon rows (missing table/column).' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @can_gameobject_addon_cleanup,
    CONCAT(
        'SELECT COUNT(*) INTO @remaining_orphan_gameobject_addon FROM `gameobject_addon` ga ',
        'LEFT JOIN `gameobject` g ON ga.`', @gameobject_addon_guid_col, '` = g.`', @gameobject_guid_col, '` ',
        'WHERE g.`', @gameobject_guid_col, '` IS NULL'
    ),
    "SELECT 'SKIP: cannot verify orphan gameobject_addon rows (missing table/column).' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

COMMIT;

SET SQL_SAFE_UPDATES = @old_sql_safe_updates;
SET FOREIGN_KEY_CHECKS = @old_foreign_key_checks;
SET UNIQUE_CHECKS = @old_unique_checks;
SET AUTOCOMMIT = @old_autocommit;

SELECT
    @deleted_creature AS deleted_creature,
    @deleted_gameobject AS deleted_gameobject,
    @deleted_creature_addon AS deleted_creature_addon,
    @deleted_gameobject_addon AS deleted_gameobject_addon,
    @remaining_orphan_creatures AS remaining_orphan_creatures,
    @remaining_orphan_gameobjects AS remaining_orphan_gameobjects,
    @remaining_orphan_creature_addon AS remaining_orphan_creature_addon,
    @remaining_orphan_gameobject_addon AS remaining_orphan_gameobject_addon;
