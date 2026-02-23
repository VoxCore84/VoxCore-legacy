-- Genre 3A warning cleanup script (HeidiSQL-safe, idempotent, MySQL 8/9)

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

SET @deleted_spell_group := 0;
SET @deleted_spell_proc := 0;
SET @deleted_spell_pet_auras := 0;
SET @deleted_spell_linked_spell := 0;
SET @deleted_spell_group_stack_rules := 0;

SET @spell_group_col := NULL;
SET @spell_proc_col := NULL;
SET @spell_pet_auras_col := NULL;
SET @linked_trigger_col := NULL;
SET @linked_effect_col := NULL;
SET @group_col := NULL;

DROP TEMPORARY TABLE IF EXISTS tmp_bad_spells;
CREATE TEMPORARY TABLE tmp_bad_spells (
  spellId BIGINT PRIMARY KEY
) ENGINE=Memory;

INSERT IGNORE INTO tmp_bad_spells (spellId) VALUES
(2380),(17629),(42735),(62380),(67016),(67017),(67018),
(20784),(33127),(42770),(79577),(115768),(262507),(370783),(370818),(373835),(383192),(383394),(383958),(383977),(386034),(392303),(408575),(470053),(470058),
(41637),(42965),(47960),(54501),(59907),(63230),(73015),(77767),(191840),(396719),
(20895);

DROP TEMPORARY TABLE IF EXISTS tmp_bad_linked_pairs;
CREATE TEMPORARY TABLE tmp_bad_linked_pairs (
  triggerId BIGINT NOT NULL,
  effectId BIGINT NOT NULL,
  PRIMARY KEY (triggerId, effectId)
) ENGINE=Memory;

INSERT IGNORE INTO tmp_bad_linked_pairs (triggerId, effectId) VALUES
(92237,92237),
(364343,364343),
(383762,383762);

DROP TEMPORARY TABLE IF EXISTS tmp_bad_group_ids;
CREATE TEMPORARY TABLE tmp_bad_group_ids (
  groupId BIGINT PRIMARY KEY
) ENGINE=Memory;

INSERT IGNORE INTO tmp_bad_group_ids (groupId) VALUES (2500);

-- spell_group cleanup
SET @spell_group_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_group'
);
SELECT IF(@spell_group_exists = 0, 'SKIP: spell_group missing', 'OK: spell_group found') AS note;

SET @spell_group_col := (
  SELECT COLUMN_NAME
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'spell_group'
    AND COLUMN_NAME IN ('spell_id','spellId','spell','SpellID','SpellId')
  ORDER BY FIELD(COLUMN_NAME,'spell_id','spellId','spell','SpellID','SpellId')
  LIMIT 1
);
SELECT IF(@spell_group_exists = 1 AND @spell_group_col IS NULL, 'SKIP: spell_group spell-id column missing', CONCAT('OK: spell_group spell column = ', @spell_group_col)) AS note;
SET @can_spell_group := IF(@spell_group_exists = 1 AND @spell_group_col IS NOT NULL, 1, 0);

SET @sql := IF(@can_spell_group = 1,
  'CREATE TABLE IF NOT EXISTS `spell_group_bak_genre3a` LIKE `spell_group`',
  'SELECT ''SKIP: spell_group backup not created'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_group = 1,
  CONCAT(
    'INSERT IGNORE INTO `spell_group_bak_genre3a` ',
    'SELECT * FROM `spell_group` WHERE `', @spell_group_col, '` IN (SELECT spellId FROM tmp_bad_spells)'
  ),
  'SELECT ''SKIP: spell_group backup rows skipped'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_group = 1,
  CONCAT(
    'DELETE FROM `spell_group` WHERE `', @spell_group_col, '` IN (SELECT spellId FROM tmp_bad_spells)'
  ),
  'SELECT ''SKIP: spell_group delete skipped'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted_spell_group := IF(@can_spell_group = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;

-- spell_proc cleanup
SET @spell_proc_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_proc'
);
SELECT IF(@spell_proc_exists = 0, 'SKIP: spell_proc missing', 'OK: spell_proc found') AS note;

SET @spell_proc_col := (
  SELECT COLUMN_NAME
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'spell_proc'
    AND COLUMN_NAME IN ('SpellId','SpellID','spell_id','spellId','spell')
  ORDER BY FIELD(COLUMN_NAME,'SpellId','SpellID','spell_id','spellId','spell')
  LIMIT 1
);
SELECT IF(@spell_proc_exists = 1 AND @spell_proc_col IS NULL, 'SKIP: spell_proc spell-id column missing', CONCAT('OK: spell_proc spell column = ', @spell_proc_col)) AS note;
SET @can_spell_proc := IF(@spell_proc_exists = 1 AND @spell_proc_col IS NOT NULL, 1, 0);

SET @sql := IF(@can_spell_proc = 1,
  'CREATE TABLE IF NOT EXISTS `spell_proc_bak_genre3a` LIKE `spell_proc`',
  'SELECT ''SKIP: spell_proc backup not created'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_proc = 1,
  CONCAT(
    'INSERT IGNORE INTO `spell_proc_bak_genre3a` ',
    'SELECT * FROM `spell_proc` WHERE `', @spell_proc_col, '` IN (SELECT spellId FROM tmp_bad_spells)'
  ),
  'SELECT ''SKIP: spell_proc backup rows skipped'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_proc = 1,
  CONCAT(
    'DELETE FROM `spell_proc` WHERE `', @spell_proc_col, '` IN (SELECT spellId FROM tmp_bad_spells)'
  ),
  'SELECT ''SKIP: spell_proc delete skipped'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted_spell_proc := IF(@can_spell_proc = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;

-- spell_pet_auras cleanup
SET @spell_pet_auras_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_pet_auras'
);
SELECT IF(@spell_pet_auras_exists = 0, 'SKIP: spell_pet_auras missing', 'OK: spell_pet_auras found') AS note;

SET @spell_pet_auras_col := (
  SELECT COLUMN_NAME
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'spell_pet_auras'
    AND COLUMN_NAME IN ('spell','spellId','spell_id','SpellID','SpellId')
  ORDER BY FIELD(COLUMN_NAME,'spell','spellId','spell_id','SpellID','SpellId')
  LIMIT 1
);
SELECT IF(@spell_pet_auras_exists = 1 AND @spell_pet_auras_col IS NULL, 'SKIP: spell_pet_auras spell-id column missing', CONCAT('OK: spell_pet_auras spell column = ', @spell_pet_auras_col)) AS note;
SET @can_spell_pet_auras := IF(@spell_pet_auras_exists = 1 AND @spell_pet_auras_col IS NOT NULL, 1, 0);

SET @sql := IF(@can_spell_pet_auras = 1,
  'CREATE TABLE IF NOT EXISTS `spell_pet_auras_bak_genre3a` LIKE `spell_pet_auras`',
  'SELECT ''SKIP: spell_pet_auras backup not created'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_pet_auras = 1,
  CONCAT(
    'INSERT IGNORE INTO `spell_pet_auras_bak_genre3a` ',
    'SELECT * FROM `spell_pet_auras` WHERE `', @spell_pet_auras_col, '` IN (SELECT spellId FROM tmp_bad_spells)'
  ),
  'SELECT ''SKIP: spell_pet_auras backup rows skipped'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_pet_auras = 1,
  CONCAT(
    'DELETE FROM `spell_pet_auras` WHERE `', @spell_pet_auras_col, '` IN (SELECT spellId FROM tmp_bad_spells)'
  ),
  'SELECT ''SKIP: spell_pet_auras delete skipped'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted_spell_pet_auras := IF(@can_spell_pet_auras = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;

-- spell_linked_spell cleanup
SET @spell_linked_spell_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell'
);
SELECT IF(@spell_linked_spell_exists = 0, 'SKIP: spell_linked_spell missing', 'OK: spell_linked_spell found') AS note;

SET @pair_choice := (
  SELECT CASE
    WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell' AND COLUMN_NAME = 'spell_trigger')
     AND EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell' AND COLUMN_NAME = 'spell_effect') THEN 'spell_trigger|spell_effect'
    WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell' AND COLUMN_NAME = 'spellTrigger')
     AND EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell' AND COLUMN_NAME = 'spellEffect') THEN 'spellTrigger|spellEffect'
    WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell' AND COLUMN_NAME = 'trigger_spell')
     AND EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell' AND COLUMN_NAME = 'effect_spell') THEN 'trigger_spell|effect_spell'
    WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell' AND COLUMN_NAME = 'spell')
     AND EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell' AND COLUMN_NAME = 'aura') THEN 'spell|aura'
    WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell' AND COLUMN_NAME = 'spell')
     AND EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell' AND COLUMN_NAME = 'linked_spell') THEN 'spell|linked_spell'
    WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell' AND COLUMN_NAME = 'spell_id')
     AND EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell' AND COLUMN_NAME = 'linked_spell') THEN 'spell_id|linked_spell'
    WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell' AND COLUMN_NAME = 'spell_id')
     AND EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_linked_spell' AND COLUMN_NAME = 'aura') THEN 'spell_id|aura'
    ELSE NULL
  END
);

SET @linked_trigger_col := IF(@pair_choice IS NULL, NULL, SUBSTRING_INDEX(@pair_choice, '|', 1));
SET @linked_effect_col := IF(@pair_choice IS NULL, NULL, SUBSTRING_INDEX(@pair_choice, '|', -1));
SELECT IF(@spell_linked_spell_exists = 1 AND @pair_choice IS NULL, 'SKIP: spell_linked_spell trigger/effect columns missing', CONCAT('OK: spell_linked_spell columns = ', @pair_choice)) AS note;
SET @can_spell_linked_spell := IF(@spell_linked_spell_exists = 1 AND @linked_trigger_col IS NOT NULL AND @linked_effect_col IS NOT NULL, 1, 0);

SET @sql := IF(@can_spell_linked_spell = 1,
  'CREATE TABLE IF NOT EXISTS `spell_linked_spell_bak_genre3a` LIKE `spell_linked_spell`',
  'SELECT ''SKIP: spell_linked_spell backup not created'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_linked_spell = 1,
  CONCAT(
    'INSERT IGNORE INTO `spell_linked_spell_bak_genre3a` ',
    'SELECT s.* FROM `spell_linked_spell` s ',
    'LEFT JOIN tmp_bad_linked_pairs p ON s.`', @linked_trigger_col, '` = p.triggerId AND s.`', @linked_effect_col, '` = p.effectId ',
    'WHERE s.`', @linked_trigger_col, '` IN (SELECT spellId FROM tmp_bad_spells) ',
    '   OR s.`', @linked_effect_col, '` IN (SELECT spellId FROM tmp_bad_spells) ',
    '   OR p.triggerId IS NOT NULL'
  ),
  'SELECT ''SKIP: spell_linked_spell backup rows skipped'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_linked_spell = 1,
  CONCAT(
    'DELETE s FROM `spell_linked_spell` s ',
    'LEFT JOIN tmp_bad_linked_pairs p ON s.`', @linked_trigger_col, '` = p.triggerId AND s.`', @linked_effect_col, '` = p.effectId ',
    'WHERE s.`', @linked_trigger_col, '` IN (SELECT spellId FROM tmp_bad_spells) ',
    '   OR s.`', @linked_effect_col, '` IN (SELECT spellId FROM tmp_bad_spells) ',
    '   OR p.triggerId IS NOT NULL'
  ),
  'SELECT ''SKIP: spell_linked_spell delete skipped'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted_spell_linked_spell := IF(@can_spell_linked_spell = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_linked_spell = 1,
  CONCAT(
    'SELECT COUNT(*) AS remaining_self_loops_targeted ',
    'FROM `spell_linked_spell` ',
    'WHERE `', @linked_trigger_col, '` = `', @linked_effect_col, '` ',
    'AND `', @linked_trigger_col, '` IN (92237,364343,383762)'
  ),
  'SELECT ''SKIP: spell_linked_spell self-loop verification skipped'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- spell_group_stack_rules cleanup
SET @spell_group_stack_rules_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_group_stack_rules'
);
SELECT IF(@spell_group_stack_rules_exists = 0, 'SKIP: spell_group_stack_rules missing', 'OK: spell_group_stack_rules found') AS note;

SET @group_col := (
  SELECT COLUMN_NAME
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'spell_group_stack_rules'
    AND COLUMN_NAME IN ('group_id','groupId','groupID','id','Id')
  ORDER BY FIELD(COLUMN_NAME,'group_id','groupId','groupID','id','Id')
  LIMIT 1
);
SELECT IF(@spell_group_stack_rules_exists = 1 AND @group_col IS NULL, 'SKIP: spell_group_stack_rules group-id column missing', CONCAT('OK: spell_group_stack_rules group column = ', @group_col)) AS note;
SET @can_spell_group_stack_rules := IF(@spell_group_stack_rules_exists = 1 AND @group_col IS NOT NULL, 1, 0);

SET @sql := IF(@can_spell_group_stack_rules = 1,
  'CREATE TABLE IF NOT EXISTS `spell_group_stack_rules_bak_genre3a` LIKE `spell_group_stack_rules`',
  'SELECT ''SKIP: spell_group_stack_rules backup not created'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_group_stack_rules = 1,
  CONCAT(
    'INSERT IGNORE INTO `spell_group_stack_rules_bak_genre3a` ',
    'SELECT * FROM `spell_group_stack_rules` WHERE `', @group_col, '` IN (SELECT groupId FROM tmp_bad_group_ids)'
  ),
  'SELECT ''SKIP: spell_group_stack_rules backup rows skipped'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_group_stack_rules = 1,
  CONCAT(
    'DELETE FROM `spell_group_stack_rules` WHERE `', @group_col, '` IN (SELECT groupId FROM tmp_bad_group_ids)'
  ),
  'SELECT ''SKIP: spell_group_stack_rules delete skipped'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted_spell_group_stack_rules := IF(@can_spell_group_stack_rules = 1, ROW_COUNT(), 0); DEALLOCATE PREPARE stmt;

COMMIT;

SET SQL_SAFE_UPDATES = @OLD_SQL_SAFE_UPDATES;
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;
SET AUTOCOMMIT = @OLD_AUTOCOMMIT;

-- End-of-script verification counts
SET @sql := IF(@can_spell_group = 1,
  CONCAT(
    'SELECT COUNT(*) AS remaining_bad_spell_refs_spell_group FROM `spell_group` WHERE `', @spell_group_col, '` IN (SELECT spellId FROM tmp_bad_spells)'
  ),
  'SELECT ''SKIP: verification spell_group unavailable'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_proc = 1,
  CONCAT(
    'SELECT COUNT(*) AS remaining_bad_spell_refs_spell_proc FROM `spell_proc` WHERE `', @spell_proc_col, '` IN (SELECT spellId FROM tmp_bad_spells)'
  ),
  'SELECT ''SKIP: verification spell_proc unavailable'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_pet_auras = 1,
  CONCAT(
    'SELECT COUNT(*) AS remaining_bad_spell_refs_spell_pet_auras FROM `spell_pet_auras` WHERE `', @spell_pet_auras_col, '` IN (SELECT spellId FROM tmp_bad_spells)'
  ),
  'SELECT ''SKIP: verification spell_pet_auras unavailable'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_linked_spell = 1,
  CONCAT(
    'SELECT COUNT(*) AS remaining_bad_spell_refs_spell_linked_spell ',
    'FROM `spell_linked_spell` WHERE `', @linked_trigger_col, '` IN (SELECT spellId FROM tmp_bad_spells) OR `', @linked_effect_col, '` IN (SELECT spellId FROM tmp_bad_spells)'
  ),
  'SELECT ''SKIP: verification spell_linked_spell unavailable'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_linked_spell = 1,
  CONCAT(
    'SELECT COUNT(*) AS remaining_targeted_self_loops_spell_linked_spell ',
    'FROM `spell_linked_spell` WHERE `', @linked_trigger_col, '` = `', @linked_effect_col, '` AND `', @linked_trigger_col, '` IN (92237,364343,383762)'
  ),
  'SELECT ''SKIP: verification spell_linked_spell self-loops unavailable'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@can_spell_group_stack_rules = 1,
  CONCAT(
    'SELECT COUNT(*) AS remaining_bad_group_refs_spell_group_stack_rules FROM `spell_group_stack_rules` WHERE `', @group_col, '` IN (SELECT groupId FROM tmp_bad_group_ids)'
  ),
  'SELECT ''SKIP: verification spell_group_stack_rules unavailable'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT 'spell_group' AS table_name, @deleted_spell_group AS deleted_rows
UNION ALL
SELECT 'spell_proc', @deleted_spell_proc
UNION ALL
SELECT 'spell_pet_auras', @deleted_spell_pet_auras
UNION ALL
SELECT 'spell_linked_spell', @deleted_spell_linked_spell
UNION ALL
SELECT 'spell_group_stack_rules', @deleted_spell_group_stack_rules;
