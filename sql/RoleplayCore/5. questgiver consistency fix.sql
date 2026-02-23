/* HEIDISQL: Load and run this .sql file directly. If your tab contains 'diff --git' or leading '+' before SQL, stop: that is patch text, not SQL. */
/* Questgiver consistency fix for creature/gameobject templates (HeidiSQL-safe, low-warning) */
USE `world`;
SELECT DATABASE() AS current_database;

SET @OLD_SQL_SAFE_UPDATES := @@SQL_SAFE_UPDATES;
SET @OLD_FOREIGN_KEY_CHECKS := @@FOREIGN_KEY_CHECKS;
SET @OLD_UNIQUE_CHECKS := @@UNIQUE_CHECKS;
SET @OLD_AUTOCOMMIT := @@AUTOCOMMIT;
SET @OLD_SQL_NOTES := @@SQL_NOTES;

SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;
SET SQL_NOTES = 0;

START TRANSACTION;

SET @schema := DATABASE();

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_creature_questgivers (
    entry_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (entry_id)
) ENGINE=InnoDB;
TRUNCATE TABLE tmp_creature_questgivers;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_creature_to_fix (
    entry_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (entry_id)
) ENGINE=InnoDB;
TRUNCATE TABLE tmp_creature_to_fix;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_go_questgivers (
    entry_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (entry_id)
) ENGINE=InnoDB;
TRUNCATE TABLE tmp_go_questgivers;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_go_to_fix (
    entry_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (entry_id)
) ENGINE=InnoDB;
TRUNCATE TABLE tmp_go_to_fix;

SELECT COUNT(*) INTO @ct_exists
FROM information_schema.tables
WHERE table_schema = @schema
  AND table_name = 'creature_template';

SELECT COALESCE(
    (
        SELECT c.column_name
        FROM information_schema.columns c
        WHERE c.table_schema = @schema
          AND c.table_name = 'creature_template'
          AND c.column_key = 'PRI'
          AND c.column_name IN ('entry','Entry','ID','Id')
        ORDER BY FIELD(c.column_name,'entry','Entry','ID','Id'), c.ordinal_position
        LIMIT 1
    ),
    (
        SELECT c.column_name
        FROM information_schema.columns c
        WHERE c.table_schema = @schema
          AND c.table_name = 'creature_template'
          AND c.column_name IN ('entry','Entry','ID','Id')
        ORDER BY FIELD(c.column_name,'entry','Entry','ID','Id'), c.ordinal_position
        LIMIT 1
    )
) INTO @ct_pk_col;

SELECT c.column_name INTO @ct_npcflag_col
FROM information_schema.columns c
WHERE c.table_schema = @schema
  AND c.table_name = 'creature_template'
  AND c.column_name IN ('npcflag','npcflag2')
ORDER BY FIELD(c.column_name,'npcflag','npcflag2'), c.ordinal_position
LIMIT 1;

SELECT 'SKIP: creature_template missing' AS note WHERE @ct_exists = 0;
SELECT 'SKIP: creature_template primary key column missing' AS note WHERE @ct_exists = 1 AND @ct_pk_col IS NULL;
SELECT 'SKIP: creature_template npcflag column missing' AS note WHERE @ct_exists = 1 AND @ct_npcflag_col IS NULL;

SELECT COUNT(*) INTO @cqs_exists
FROM information_schema.tables
WHERE table_schema = @schema
  AND table_name = 'creature_queststarter';

SELECT c.column_name INTO @cqs_col
FROM information_schema.columns c
WHERE c.table_schema = @schema
  AND c.table_name = 'creature_queststarter'
  AND c.column_name IN ('id','creature','entry','CreatureID')
ORDER BY FIELD(c.column_name,'id','creature','entry','CreatureID'), c.ordinal_position
LIMIT 1;

SELECT COUNT(*) INTO @cqe_exists
FROM information_schema.tables
WHERE table_schema = @schema
  AND table_name = 'creature_questender';

SELECT c.column_name INTO @cqe_col
FROM information_schema.columns c
WHERE c.table_schema = @schema
  AND c.table_name = 'creature_questender'
  AND c.column_name IN ('id','creature','entry','CreatureID')
ORDER BY FIELD(c.column_name,'id','creature','entry','CreatureID'), c.ordinal_position
LIMIT 1;

SELECT 'SKIP: creature_queststarter missing' AS note WHERE @cqs_exists = 0;
SELECT 'SKIP: creature_queststarter entry column missing' AS note WHERE @cqs_exists = 1 AND @cqs_col IS NULL;
SELECT 'SKIP: creature_questender missing' AS note WHERE @cqe_exists = 0;
SELECT 'SKIP: creature_questender entry column missing' AS note WHERE @cqe_exists = 1 AND @cqe_col IS NULL;

SET @sql := IF(
    @cqs_exists = 1 AND @cqs_col IS NOT NULL,
    CONCAT(
        'INSERT IGNORE INTO tmp_creature_questgivers (entry_id) ',
        'SELECT DISTINCT CAST(s.`', REPLACE(@cqs_col,'`','``'), '` AS UNSIGNED) ',
        'FROM `creature_queststarter` s ',
        'WHERE s.`', REPLACE(@cqs_col,'`','``'), '` IS NOT NULL'
    ),
    "SELECT 'SKIP: creature_queststarter unavailable for load' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @cqe_exists = 1 AND @cqe_col IS NOT NULL,
    CONCAT(
        'INSERT IGNORE INTO tmp_creature_questgivers (entry_id) ',
        'SELECT DISTINCT CAST(s.`', REPLACE(@cqe_col,'`','``'), '` AS UNSIGNED) ',
        'FROM `creature_questender` s ',
        'WHERE s.`', REPLACE(@cqe_col,'`','``'), '` IS NOT NULL'
    ),
    "SELECT 'SKIP: creature_questender unavailable for load' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @ct_exists = 1 AND @ct_pk_col IS NOT NULL AND @ct_npcflag_col IS NOT NULL,
    CONCAT(
        'INSERT INTO tmp_creature_to_fix (entry_id) ',
        'SELECT tq.entry_id ',
        'FROM tmp_creature_questgivers tq ',
        'JOIN `creature_template` ct ON ct.`', REPLACE(@ct_pk_col,'`','``'), '` = tq.entry_id ',
        'WHERE (ct.`', REPLACE(@ct_npcflag_col,'`','``'), '` & 2) = 0'
    ),
    "SELECT 'SKIP: creature_template update unavailable' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @ct_exists = 1,
    'CREATE TABLE IF NOT EXISTS `creature_template_backup_questgiverflag` LIKE `creature_template`',
    "SELECT 'SKIP: creature_template_backup_questgiverflag not created (creature_template missing)' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @ct_exists = 1 AND @ct_pk_col IS NOT NULL,
    CONCAT(
        'INSERT INTO `creature_template_backup_questgiverflag` ',
        'SELECT ct.* FROM `creature_template` ct ',
        'JOIN tmp_creature_to_fix tf ON tf.entry_id = ct.`', REPLACE(@ct_pk_col,'`','``'), '` ',
        'LEFT JOIN `creature_template_backup_questgiverflag` b ON b.`', REPLACE(@ct_pk_col,'`','``'), '` = ct.`', REPLACE(@ct_pk_col,'`','``'), '` ',
        'WHERE b.`', REPLACE(@ct_pk_col,'`','``'), '` IS NULL'
    ),
    "SELECT 'SKIP: creature backup rows unavailable' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @ct_exists = 1 AND @ct_pk_col IS NOT NULL AND @ct_npcflag_col IS NOT NULL,
    CONCAT(
        'UPDATE `creature_template` ct ',
        'JOIN tmp_creature_to_fix tf ON tf.entry_id = ct.`', REPLACE(@ct_pk_col,'`','``'), '` ',
        'SET ct.`', REPLACE(@ct_npcflag_col,'`','``'), '` = (ct.`', REPLACE(@ct_npcflag_col,'`','``'), '` | 2)'
    ),
    "SELECT 'SKIP: creature update unavailable' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT COUNT(*) INTO @got_exists
FROM information_schema.tables
WHERE table_schema = @schema
  AND table_name = 'gameobject_template';

SELECT COALESCE(
    (
        SELECT c.column_name
        FROM information_schema.columns c
        WHERE c.table_schema = @schema
          AND c.table_name = 'gameobject_template'
          AND c.column_key = 'PRI'
          AND c.column_name IN ('entry','Entry','ID','Id')
        ORDER BY FIELD(c.column_name,'entry','Entry','ID','Id'), c.ordinal_position
        LIMIT 1
    ),
    (
        SELECT c.column_name
        FROM information_schema.columns c
        WHERE c.table_schema = @schema
          AND c.table_name = 'gameobject_template'
          AND c.column_name IN ('entry','Entry','ID','Id')
        ORDER BY FIELD(c.column_name,'entry','Entry','ID','Id'), c.ordinal_position
        LIMIT 1
    )
) INTO @got_pk_col;

SELECT c.column_name INTO @got_type_col
FROM information_schema.columns c
WHERE c.table_schema = @schema
  AND c.table_name = 'gameobject_template'
  AND c.column_name = 'type'
ORDER BY c.ordinal_position
LIMIT 1;

SELECT 'SKIP: gameobject_template missing' AS note WHERE @got_exists = 0;
SELECT 'SKIP: gameobject_template primary key column missing' AS note WHERE @got_exists = 1 AND @got_pk_col IS NULL;
SELECT 'SKIP: gameobject_template type column missing' AS note WHERE @got_exists = 1 AND @got_type_col IS NULL;

SELECT COUNT(*) INTO @gqs_exists
FROM information_schema.tables
WHERE table_schema = @schema
  AND table_name = 'gameobject_queststarter';

SELECT c.column_name INTO @gqs_col
FROM information_schema.columns c
WHERE c.table_schema = @schema
  AND c.table_name = 'gameobject_queststarter'
  AND c.column_name IN ('id','gameobject','entry')
ORDER BY FIELD(c.column_name,'id','gameobject','entry'), c.ordinal_position
LIMIT 1;

SELECT COUNT(*) INTO @gqe_exists
FROM information_schema.tables
WHERE table_schema = @schema
  AND table_name = 'gameobject_questender';

SELECT c.column_name INTO @gqe_col
FROM information_schema.columns c
WHERE c.table_schema = @schema
  AND c.table_name = 'gameobject_questender'
  AND c.column_name IN ('id','gameobject','entry')
ORDER BY FIELD(c.column_name,'id','gameobject','entry'), c.ordinal_position
LIMIT 1;

SELECT 'SKIP: gameobject_queststarter missing' AS note WHERE @gqs_exists = 0;
SELECT 'SKIP: gameobject_queststarter entry column missing' AS note WHERE @gqs_exists = 1 AND @gqs_col IS NULL;
SELECT 'SKIP: gameobject_questender missing' AS note WHERE @gqe_exists = 0;
SELECT 'SKIP: gameobject_questender entry column missing' AS note WHERE @gqe_exists = 1 AND @gqe_col IS NULL;

SET @sql := IF(
    @gqs_exists = 1 AND @gqs_col IS NOT NULL,
    CONCAT(
        'INSERT IGNORE INTO tmp_go_questgivers (entry_id) ',
        'SELECT DISTINCT CAST(s.`', REPLACE(@gqs_col,'`','``'), '` AS UNSIGNED) ',
        'FROM `gameobject_queststarter` s ',
        'WHERE s.`', REPLACE(@gqs_col,'`','``'), '` IS NOT NULL'
    ),
    "SELECT 'SKIP: gameobject_queststarter unavailable for load' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @gqe_exists = 1 AND @gqe_col IS NOT NULL,
    CONCAT(
        'INSERT IGNORE INTO tmp_go_questgivers (entry_id) ',
        'SELECT DISTINCT CAST(s.`', REPLACE(@gqe_col,'`','``'), '` AS UNSIGNED) ',
        'FROM `gameobject_questender` s ',
        'WHERE s.`', REPLACE(@gqe_col,'`','``'), '` IS NOT NULL'
    ),
    "SELECT 'SKIP: gameobject_questender unavailable for load' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @got_exists = 1 AND @got_pk_col IS NOT NULL AND @got_type_col IS NOT NULL,
    CONCAT(
        'INSERT INTO tmp_go_to_fix (entry_id) ',
        'SELECT tq.entry_id ',
        'FROM tmp_go_questgivers tq ',
        'JOIN `gameobject_template` gt ON gt.`', REPLACE(@got_pk_col,'`','``'), '` = tq.entry_id ',
        'WHERE gt.`', REPLACE(@got_type_col,'`','``'), '` <> 2'
    ),
    "SELECT 'SKIP: gameobject_template update unavailable' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @got_exists = 1,
    'CREATE TABLE IF NOT EXISTS `gameobject_template_backup_questgiver` LIKE `gameobject_template`',
    "SELECT 'SKIP: gameobject_template_backup_questgiver not created (gameobject_template missing)' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @got_exists = 1 AND @got_pk_col IS NOT NULL,
    CONCAT(
        'INSERT INTO `gameobject_template_backup_questgiver` ',
        'SELECT gt.* FROM `gameobject_template` gt ',
        'JOIN tmp_go_to_fix tf ON tf.entry_id = gt.`', REPLACE(@got_pk_col,'`','``'), '` ',
        'LEFT JOIN `gameobject_template_backup_questgiver` b ON b.`', REPLACE(@got_pk_col,'`','``'), '` = gt.`', REPLACE(@got_pk_col,'`','``'), '` ',
        'WHERE b.`', REPLACE(@got_pk_col,'`','``'), '` IS NULL'
    ),
    "SELECT 'SKIP: gameobject backup rows unavailable' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @got_exists = 1 AND @got_pk_col IS NOT NULL AND @got_type_col IS NOT NULL,
    CONCAT(
        'UPDATE `gameobject_template` gt ',
        'JOIN tmp_go_to_fix tf ON tf.entry_id = gt.`', REPLACE(@got_pk_col,'`','``'), '` ',
        'SET gt.`', REPLACE(@got_type_col,'`','``'), '` = 2'
    ),
    "SELECT 'SKIP: gameobject update unavailable' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @ct_exists = 1 AND @ct_pk_col IS NOT NULL AND @ct_npcflag_col IS NOT NULL,
    CONCAT(
        'SELECT COUNT(*) AS remaining_creatures_missing_questgiver_bit ',
        'FROM tmp_creature_questgivers tq ',
        'JOIN `creature_template` ct ON ct.`', REPLACE(@ct_pk_col,'`','``'), '` = tq.entry_id ',
        'WHERE (ct.`', REPLACE(@ct_npcflag_col,'`','``'), '` & 2) = 0'
    ),
    "SELECT 'SKIP: creature verification unavailable' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @ct_exists = 1 AND @ct_pk_col IS NOT NULL AND @ct_npcflag_col IS NOT NULL,
    CONCAT(
        'SELECT tf.entry_id AS creature_entry, ct.`', REPLACE(@ct_npcflag_col,'`','``'), '` AS final_npcflag ',
        'FROM tmp_creature_to_fix tf ',
        'JOIN `creature_template` ct ON ct.`', REPLACE(@ct_pk_col,'`','``'), '` = tf.entry_id ',
        'ORDER BY tf.entry_id LIMIT 50'
    ),
    "SELECT 'SKIP: creature sample unavailable' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @got_exists = 1 AND @got_pk_col IS NOT NULL AND @got_type_col IS NOT NULL,
    CONCAT(
        'SELECT COUNT(*) AS remaining_gameobjects_not_questgiver_type ',
        'FROM tmp_go_questgivers tq ',
        'JOIN `gameobject_template` gt ON gt.`', REPLACE(@got_pk_col,'`','``'), '` = tq.entry_id ',
        'WHERE gt.`', REPLACE(@got_type_col,'`','``'), '` <> 2'
    ),
    "SELECT 'SKIP: gameobject verification unavailable' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @got_exists = 1 AND @got_pk_col IS NOT NULL AND @got_type_col IS NOT NULL,
    CONCAT(
        'SELECT tf.entry_id AS gameobject_entry, gt.`', REPLACE(@got_type_col,'`','``'), '` AS final_type ',
        'FROM tmp_go_to_fix tf ',
        'JOIN `gameobject_template` gt ON gt.`', REPLACE(@got_pk_col,'`','``'), '` = tf.entry_id ',
        'ORDER BY tf.entry_id LIMIT 50'
    ),
    "SELECT 'SKIP: gameobject sample unavailable' AS note"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

COMMIT;

SET SQL_SAFE_UPDATES = @OLD_SQL_SAFE_UPDATES;
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;
SET AUTOCOMMIT = @OLD_AUTOCOMMIT;
SET SQL_NOTES = @OLD_SQL_NOTES;
