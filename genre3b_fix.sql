/* Genre 3B cleanup script: spell_area + spell_target_position */
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

/* ===== A) spell_area cleanup ===== */
SELECT COUNT(*) INTO @has_spell_area
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_area';

SELECT COUNT(*) INTO @has_quest_template
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'quest_template';

SET @sa_spell_col := NULL;
SELECT COLUMN_NAME INTO @sa_spell_col
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_area'
  AND COLUMN_NAME IN ('spell','Spell','spellId')
ORDER BY FIELD(COLUMN_NAME,'spell','Spell','spellId')
LIMIT 1;

SET @sa_qstart_col := NULL;
SELECT COLUMN_NAME INTO @sa_qstart_col
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_area'
  AND COLUMN_NAME IN ('quest_start','questStart','QuestStart')
ORDER BY FIELD(COLUMN_NAME,'quest_start','questStart','QuestStart')
LIMIT 1;

SET @sa_qend_col := NULL;
SELECT COLUMN_NAME INTO @sa_qend_col
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_area'
  AND COLUMN_NAME IN ('quest_end','questEnd','QuestEnd')
ORDER BY FIELD(COLUMN_NAME,'quest_end','questEnd','QuestEnd')
LIMIT 1;

SET @qt_qid_col := NULL;
SELECT COLUMN_NAME INTO @qt_qid_col
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'quest_template'
  AND COLUMN_NAME IN ('ID','Id','entry','QuestID','QuestId')
ORDER BY FIELD(COLUMN_NAME,'ID','Id','entry','QuestID','QuestId')
LIMIT 1;

SET @deleted_spell_area := 0;

SET @sql := IF(@has_spell_area = 1,
  'CREATE TABLE IF NOT EXISTS `spell_area_backup_genre3b` LIKE `spell_area`',
  'SELECT ''SKIP: table world.spell_area missing'' AS note');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@has_spell_area = 0,
  'SELECT ''SKIP: spell_area cleanup not executed (spell_area missing)'' AS note',
  IF(@has_quest_template = 0,
    'SELECT ''SKIP: spell_area cleanup not executed (quest_template missing)'' AS note',
    IF(@qt_qid_col IS NULL,
      'SELECT ''SKIP: spell_area cleanup not executed (quest_template quest-id column not found)'' AS note',
      IF(@sa_spell_col IS NULL OR @sa_qstart_col IS NULL OR @sa_qend_col IS NULL,
        'SELECT ''SKIP: spell_area cleanup not executed (required spell_area column missing)'' AS note',
        CONCAT(
          'INSERT IGNORE INTO `spell_area_backup_genre3b` ',
          'SELECT sa.* FROM `spell_area` sa ',
          'LEFT JOIN `quest_template` qs ON qs.`', @qt_qid_col, '` = sa.`', @sa_qstart_col, '` ',
          'LEFT JOIN `quest_template` qe ON qe.`', @qt_qid_col, '` = sa.`', @sa_qend_col, '` ',
          'WHERE sa.`', @sa_spell_col, '` IN (102393,102395,102869,102870,102873,102874,114735) ',
          'AND (',
            '(sa.`', @sa_qstart_col, '` IN (29419,29677) AND qs.`', @qt_qid_col, '` IS NULL) ',
            'OR ',
            '(sa.`', @sa_qend_col, '` IN (29419,29677) AND qe.`', @qt_qid_col, '` IS NULL)',
          ')'
        )
      )
    )
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@has_spell_area = 0,
  'SELECT ''SKIP: spell_area delete not executed (spell_area missing)'' AS note',
  IF(@has_quest_template = 0,
    'SELECT ''SKIP: spell_area delete not executed (quest_template missing)'' AS note',
    IF(@qt_qid_col IS NULL,
      'SELECT ''SKIP: spell_area delete not executed (quest_template quest-id column not found)'' AS note',
      IF(@sa_spell_col IS NULL OR @sa_qstart_col IS NULL OR @sa_qend_col IS NULL,
        'SELECT ''SKIP: spell_area delete not executed (required spell_area column missing)'' AS note',
        CONCAT(
          'DELETE sa FROM `spell_area` sa ',
          'LEFT JOIN `quest_template` qs ON qs.`', @qt_qid_col, '` = sa.`', @sa_qstart_col, '` ',
          'LEFT JOIN `quest_template` qe ON qe.`', @qt_qid_col, '` = sa.`', @sa_qend_col, '` ',
          'WHERE sa.`', @sa_spell_col, '` IN (102393,102395,102869,102870,102873,102874,114735) ',
          'AND (',
            '(sa.`', @sa_qstart_col, '` IN (29419,29677) AND qs.`', @qt_qid_col, '` IS NULL) ',
            'OR ',
            '(sa.`', @sa_qend_col, '` IN (29419,29677) AND qe.`', @qt_qid_col, '` IS NULL)',
          ')'
        )
      )
    )
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted_spell_area := ROW_COUNT(); DEALLOCATE PREPARE stmt;

/* ===== B) spell_target_position cleanup ===== */
SELECT COUNT(*) INTO @has_stp
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_target_position';

SET @stp_spell_col := NULL;
SELECT COLUMN_NAME INTO @stp_spell_col
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_target_position'
  AND COLUMN_NAME IN ('ID','id','SpellID','SpellId')
ORDER BY FIELD(COLUMN_NAME,'ID','id','SpellID','SpellId')
LIMIT 1;

SET @stp_eff_col := NULL;
SELECT COLUMN_NAME INTO @stp_eff_col
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'spell_target_position'
  AND COLUMN_NAME IN ('EffectIndex','effectIndex','effIndex')
ORDER BY FIELD(COLUMN_NAME,'EffectIndex','effectIndex','effIndex')
LIMIT 1;

SET @deleted_stp := 0;

SET @sql := IF(@has_stp = 1,
  'CREATE TABLE IF NOT EXISTS `spell_target_position_backup_genre3b` LIKE `spell_target_position`',
  'SELECT ''SKIP: table world.spell_target_position missing'' AS note');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

DROP TEMPORARY TABLE IF EXISTS tmp_stp_bad_pairs;
CREATE TEMPORARY TABLE tmp_stp_bad_pairs (
  SpellID INT NOT NULL,
  EffectIndex INT NOT NULL,
  PRIMARY KEY (SpellID, EffectIndex)
) ENGINE=InnoDB;

DROP TEMPORARY TABLE IF EXISTS tmp_stp_bad_spells;
CREATE TEMPORARY TABLE tmp_stp_bad_spells (
  SpellID INT NOT NULL PRIMARY KEY
) ENGINE=InnoDB;

INSERT IGNORE INTO tmp_stp_bad_pairs (SpellID, EffectIndex) VALUES
(2479,0),(8606,0),(8690,0),(11012,0),(17334,0),(17609,0),(18960,0),(31687,0),(43209,0),(49097,0),
(49098,0),(51852,0),(53822,0),(54643,0),(54963,0),(57840,0),(65486,0),(66550,0),(66551,0),(67834,0),
(67835,0),(67836,0),(67837,0),(67838,0),(68081,0),(68219,0),(68228,0),(68630,0),(68639,0),(69018,0),
(69340,0),(69971,0),(69976,0),(69977,0),(69978,0),(69979,0),(69980,0),(69981,0),(69982,0),(71241,0),
(72546,0),(73655,0),(75397,0),(82960,0),(85263,0),(85264,0),(85265,0),(85266,0),(92183,0),(99511,0),
(100752,0),(102280,0),(104450,0),(105002,0),(108650,0),(108651,0),(108786,0),(108808,0),(108827,0),(108830,0),
(108845,0),(108847,0),(108857,0),(108858,0),(109335,0),(117497,0),(117597,0),(123074,0),(128446,0),(129724,0),
(130409,0),(130698,0),(130805,0),(130889,0),(130890,0),(130962,0),(130963,0),(132632,0),(134026,0),(134619,0),
(137658,0),(141313,0),(145143,0),(145149,0),(145188,0),(145501,0),(145503,0),(145749,0),(145750,0),(146114,0),
(146258,0),(146288,0),(149756,0),(150061,0),(150062,0),(150076,0),(150078,0),(151102,0),(151292,0),(151299,0),
(151356,0),(151369,0),(151687,0),(151700,0),(151713,0),(151714,0),(151715,0),(151716,0),(151743,0),(152353,0),
(152355,0),(152356,0),(153951,0),(154049,0),(154378,0),(154500,0),(156092,0),(156102,0),(156121,0),(156634,0),
(156636,0),(156791,0),(156793,0),(159326,0),(159720,0),(159904,0),(160815,0),(160855,0),(160857,0),(160859,0),
(161737,0),(161751,0),(161752,0),(161753,0),(161951,0),(161966,0),(162115,0),(162645,0),(162650,0),(163552,0),
(163593,0),(163718,0),(163873,0),(164514,0),(164520,0),(164524,0),(164824,0),(164898,0),(164900,0),(165056,0),
(165060,0),(165089,0),(165214,0),(165240,0),(165279,0),(165493,0),(165588,0),(165590,0),(166383,0),(166395,0),
(166455,0),(166486,0),(166521,0),(166527,0),(166548,0),(166580,0),(166630,0),(166647,0),(166657,0),(166696,0),
(166921,0),(166922,0),(166931,0),(167128,0),(167317,0),(167335,0),(167375,0),(167507,0),(167805,0),(167818,0),
(167996,0),(168167,0),(168530,0),(168567,0),(168875,0),(168973,0),(169953,0),(170051,0),(171732,0),(171896,0),
(172923,0),(172925,0),(172926,0),(173030,0),(173031,0),(173036,0),(173038,0),(174120,0),(177725,0),(180521,0),
(180912,0),(180957,0),(181273,0),(181278,0),(181289,0),(181673,0),(181682,0),(181727,0),(181780,0),(181873,0),
(182013,0),(182165,0),(182166,0),(182167,0),(182222,0),(182942,0),(184082,0),(184245,0),(185009,0),(185037,0),
(185622,0),(186597,0),(186698,0),(186998,0),(187307,0),(188412,0),(188954,0),(188955,0),(190557,0),(190560,0),
(190561,0),(190562,0),(190563,0),(190707,0),(190708,0),(191253,0),(191473,0),(191478,0),(192085,0),(192215,0),
(192241,0),(192293,0),(192348,0),(192465,0),(192477,0),(193334,0),(193749,0),(193940,0),(194149,0),(196288,0),
(196340,0),(196353,0),(197487,0),(197622,0),(197653,0),(197962,0),(197968,0),(197971,0),(197972,0),(197975,0),
(197977,0),(198089,0),(198090,0),(198191,0),(198205,0),(198206,0),(198276,0),(198278,0),(198509,0),(198526,0),
(198527,0),(198528,0),(198530,0),(198564,0),(198565,0),(199058,0),(199132,0),(199236,0),(199278,0),(199285,0),
(199286,0),(199295,0),(199436,0),(199437,0),(200283,0),(200584,0),(202640,0),(203189,0),(203400,0),(203675,0),
(203732,0),(203733,0),(203741,0),(203802,0),(203803,0),(203883,0),(203921,0),(203955,0),(204874,0),(204960,0),
(205553,0),(205813,0),(206723,0),(207111,0),(207620,0),(207634,0),(207796,0),(208341,0),(209868,0),(209884,0),
(210001,0),(210122,0),(210123,0),(210252,0),(210264,0),(210358,0),(210360,0),(211867,0),(212653,0),(212830,0),
(213351,0),(214189,0),(214598,0),(215151,0),(216249,0),(216250,0),(216525,0),(216532,0),(216949,0),(217082,0),
(217088,0),(217100,0),(217273,0),(217614,0),(217750,0),(217759,0),(218168,0),(218169,0),(218172,0),(218173,0),
(218187,0),(219823,0),(221228,0),(221616,0),(221758,0),(222361,0),(222531,0),(224994,0),(225115,0),(225143,0),
(225163,0),(225220,0),(225233,0),(225811,0),(226890,0),(227033,0),(227448,0),(227455,0),(227456,0),(227483,0),
(227484,0),(227485,0),(227487,0),(227488,0),(227882,0),(229500,0),(229548,0),(229575,0),(229808,0),(229889,0),
(230334,0),(230356,0),(230942,0),(231167,0),(231364,0),(232580,0),(232899,0),(233154,0),(233233,0),(233379,0),
(233804,0),(233808,0),(233947,0),(234521,0),(234670,0),(235194,0),(235557,0),(235710,0),(235715,0),(236624,0),
(236671,0),(237269,0),(237278,0),(237282,0),(237660,0),(237663,0),(237664,0),(238635,0),(239119,0),(239341,0),
(240161,0),(240684,0),(240691,0),(240693,0),(240694,0),(241227,0),(241928,0),(241999,0),(243270,0),(243967,0),
(243974,0),(243975,0),(243976,0),(243979,0),(244719,0),(245105,0),(246305,0),(247057,0),(247215,0),(250546,0),
(250798,0),(252067,0),(252791,0),(253244,0),(253646,0),(253751,0),(254062,0),(254212,0),(254899,0),(255266,0),
(255442,0),(255684,0),(255976,0),(256543,0),(256674,0),(257298,0),(257361,0),(279623,0),(285480,0),(285491,0),
(288112,0),(290662,0),(299874,0),(300293,0),(305073,0),(305074,0),(305075,0),(305086,0),(305087,0),(305088,0),
(305091,0),(305093,0),(305096,0),(305097,0),(305098,0),(305099,0),(305100,0),(305101,0),(305102,0),(332477,0),
(332489,0),(339805,0),(361616,0),(370479,0),(370494,0),(384955,0),(395287,0),(413061,0),(433013,0),
(229237,2),(68639,2);

INSERT IGNORE INTO tmp_stp_bad_spells (SpellID) VALUES
(84505),(84506),(215412),(379055);

SET @sql := IF(@has_stp = 0,
  'SELECT ''SKIP: spell_target_position cleanup not executed (table missing)'' AS note',
  IF(@stp_spell_col IS NULL OR @stp_eff_col IS NULL,
    'SELECT ''SKIP: spell_target_position cleanup not executed (required columns missing)'' AS note',
    CONCAT(
      'INSERT IGNORE INTO `spell_target_position_backup_genre3b` ',
      'SELECT stp.* FROM `spell_target_position` stp ',
      'LEFT JOIN tmp_stp_bad_pairs p ON p.SpellID = stp.`', @stp_spell_col, '` AND p.EffectIndex = stp.`', @stp_eff_col, '` ',
      'LEFT JOIN tmp_stp_bad_spells s ON s.SpellID = stp.`', @stp_spell_col, '` ',
      'WHERE p.SpellID IS NOT NULL OR s.SpellID IS NOT NULL'
    )
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@has_stp = 0,
  'SELECT ''SKIP: spell_target_position delete not executed (table missing)'' AS note',
  IF(@stp_spell_col IS NULL OR @stp_eff_col IS NULL,
    'SELECT ''SKIP: spell_target_position delete not executed (required columns missing)'' AS note',
    CONCAT(
      'DELETE stp FROM `spell_target_position` stp ',
      'LEFT JOIN tmp_stp_bad_pairs p ON p.SpellID = stp.`', @stp_spell_col, '` AND p.EffectIndex = stp.`', @stp_eff_col, '` ',
      'LEFT JOIN tmp_stp_bad_spells s ON s.SpellID = stp.`', @stp_spell_col, '` ',
      'WHERE p.SpellID IS NOT NULL OR s.SpellID IS NOT NULL'
    )
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @deleted_stp := ROW_COUNT(); DEALLOCATE PREPARE stmt;

/* Verification counts */
SET @sql := IF(@has_stp = 0,
  'SELECT ''SKIP: verification skipped (spell_target_position missing)'' AS note',
  IF(@stp_spell_col IS NULL OR @stp_eff_col IS NULL,
    'SELECT ''SKIP: verification skipped (required spell_target_position columns missing)'' AS note',
    CONCAT(
      'SELECT COUNT(*) AS remaining_bad_pairs ',
      'FROM `spell_target_position` stp ',
      'INNER JOIN tmp_stp_bad_pairs p ON p.SpellID = stp.`', @stp_spell_col, '` AND p.EffectIndex = stp.`', @stp_eff_col, '`'
    )
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(@has_stp = 0,
  'SELECT ''SKIP: verification skipped (spell_target_position missing)'' AS note',
  IF(@stp_spell_col IS NULL,
    'SELECT ''SKIP: verification skipped (spell id column missing)'' AS note',
    CONCAT(
      'SELECT COUNT(*) AS remaining_bad_spells ',
      'FROM `spell_target_position` stp ',
      'INNER JOIN tmp_stp_bad_spells s ON s.SpellID = stp.`', @stp_spell_col, '`'
    )
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* Optional sample to show table remains populated */
SET @sql := IF(@has_stp = 0,
  'SELECT ''SKIP: sample skipped (spell_target_position missing)'' AS note',
  IF(@stp_spell_col IS NULL,
    'SELECT ''SKIP: sample skipped (spell id column missing)'' AS note',
    CONCAT(
      'SELECT * FROM `spell_target_position` ',
      'WHERE `', @stp_spell_col, '` IN (68639,229237) ',
      'ORDER BY `', @stp_spell_col, '` LIMIT 50'
    )
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT @deleted_spell_area AS deleted_spell_area_rows,
       @deleted_stp AS deleted_spell_target_position_rows;

COMMIT;

SET SQL_SAFE_UPDATES = @OLD_SQL_SAFE_UPDATES;
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;
SET AUTOCOMMIT = @OLD_AUTOCOMMIT;
