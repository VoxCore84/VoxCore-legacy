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

SET @rows_gossip_menu := 0;
SET @rows_gossip_menu_option := 0;
SET @rows_npc_text := 0;
SET @rows_creature_text := 0;

SET @ver_gm_invalid_textid := 0;
SET @ver_gmo_invalid_actionmenuid := 0;
SET @ver_gmo_invalid_actionpoiid := 0;
SET @ver_npc_invalid_broadcast_refs := 0;
SET @ver_ct_invalid_broadcast := 0;
SET @ver_ct_invalid_sound := 0;
SET @ver_ct_invalid_emote := 0;
SET @ver_ct_invalid_textrange := 0;

/* A) gossip_menu -> npc_text */
SET @has_gossip_menu := (
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'gossip_menu'
);

SET @gm_menu_col := (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'gossip_menu'
      AND LOWER(c.column_name) IN ('menuid','menu_id','id')
    ORDER BY FIELD(LOWER(c.column_name),'menuid','menu_id','id')
    LIMIT 1
);

SET @gm_text_col := (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'gossip_menu'
      AND LOWER(c.column_name) IN ('textid','text_id')
    ORDER BY FIELD(LOWER(c.column_name),'textid','text_id')
    LIMIT 1
);

SET @has_npc_text := (
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'npc_text'
);

SET @npc_pk_col := (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'npc_text'
      AND LOWER(c.column_name) IN ('id','entry')
    ORDER BY FIELD(LOWER(c.column_name),'id','entry')
    LIMIT 1
);

SET @sql := IF(
    @has_gossip_menu = 1,
    'CREATE TABLE IF NOT EXISTS `gossip_menu_backup_genre4a` LIKE `gossip_menu`',
    'SELECT ''SKIP: table gossip_menu does not exist.'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_gossip_menu = 1 AND @has_npc_text = 1 AND @gm_text_col IS NOT NULL AND @npc_pk_col IS NOT NULL,
    CONCAT(
        'INSERT IGNORE INTO `gossip_menu_backup_genre4a` ',
        'SELECT gm.* FROM `gossip_menu` gm ',
        'WHERE gm.`', @gm_text_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `npc_text` nt WHERE nt.`', @npc_pk_col, '` = gm.`', @gm_text_col, '` )'
    ),
    'SELECT ''SKIP: gossip_menu fix requires gossip_menu TextID and npc_text PK.'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_gossip_menu = 1 AND @has_npc_text = 1 AND @gm_text_col IS NOT NULL AND @npc_pk_col IS NOT NULL,
    CONCAT(
        'UPDATE `gossip_menu` gm ',
        'SET gm.`', @gm_text_col, '` = 0 ',
        'WHERE gm.`', @gm_text_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `npc_text` nt WHERE nt.`', @npc_pk_col, '` = gm.`', @gm_text_col, '` )'
    ),
    'SELECT ''SKIP: gossip_menu update not executed (missing dependency).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @rows_gossip_menu := @rows_gossip_menu + ROW_COUNT(); DEALLOCATE PREPARE stmt;

/* B) gossip_menu_option */
SET @has_gmo := (
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'gossip_menu_option'
);

SET @gmo_action_menu_col := (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'gossip_menu_option'
      AND LOWER(c.column_name) IN ('actionmenuid','action_menu_id')
    ORDER BY FIELD(LOWER(c.column_name),'actionmenuid','action_menu_id')
    LIMIT 1
);

SET @gmo_action_poi_col := (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'gossip_menu_option'
      AND LOWER(c.column_name) IN ('actionpoiid','action_poi_id')
    ORDER BY FIELD(LOWER(c.column_name),'actionpoiid','action_poi_id')
    LIMIT 1
);

SET @poi_table := (
    SELECT t.table_name
    FROM information_schema.tables t
    WHERE t.table_schema = DATABASE() AND t.table_name IN ('points_of_interest','point_of_interest')
    ORDER BY FIELD(t.table_name,'points_of_interest','point_of_interest')
    LIMIT 1
);

SET @poi_id_col := (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = @poi_table
      AND LOWER(c.column_name) IN ('id','entry')
    ORDER BY FIELD(LOWER(c.column_name),'id','entry')
    LIMIT 1
);

SET @sql := IF(
    @has_gmo = 1,
    'CREATE TABLE IF NOT EXISTS `gossip_menu_option_backup_genre4a` LIKE `gossip_menu_option`',
    'SELECT ''SKIP: table gossip_menu_option does not exist.'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_gmo = 1 AND @has_gossip_menu = 1 AND @gmo_action_menu_col IS NOT NULL AND @gm_menu_col IS NOT NULL,
    CONCAT(
        'INSERT IGNORE INTO `gossip_menu_option_backup_genre4a` ',
        'SELECT gmo.* FROM `gossip_menu_option` gmo ',
        'WHERE gmo.`', @gmo_action_menu_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `gossip_menu` gm WHERE gm.`', @gm_menu_col, '` = gmo.`', @gmo_action_menu_col, '` )'
    ),
    'SELECT ''SKIP: ActionMenuID backup skipped (missing dependency).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_gmo = 1 AND @has_gossip_menu = 1 AND @gmo_action_menu_col IS NOT NULL AND @gm_menu_col IS NOT NULL,
    CONCAT(
        'UPDATE `gossip_menu_option` gmo ',
        'SET gmo.`', @gmo_action_menu_col, '` = 0 ',
        'WHERE gmo.`', @gmo_action_menu_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `gossip_menu` gm WHERE gm.`', @gm_menu_col, '` = gmo.`', @gmo_action_menu_col, '` )'
    ),
    'SELECT ''SKIP: ActionMenuID update skipped (missing dependency).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @rows_gossip_menu_option := @rows_gossip_menu_option + ROW_COUNT(); DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_gmo = 1 AND @poi_table IS NOT NULL AND @poi_id_col IS NOT NULL AND @gmo_action_poi_col IS NOT NULL,
    CONCAT(
        'INSERT IGNORE INTO `gossip_menu_option_backup_genre4a` ',
        'SELECT gmo.* FROM `gossip_menu_option` gmo ',
        'WHERE gmo.`', @gmo_action_poi_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `', @poi_table, '` poi WHERE poi.`', @poi_id_col, '` = gmo.`', @gmo_action_poi_col, '` )'
    ),
    'SELECT ''SKIP: ActionPoiID backup skipped (missing dependency).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_gmo = 1 AND @poi_table IS NOT NULL AND @poi_id_col IS NOT NULL AND @gmo_action_poi_col IS NOT NULL,
    CONCAT(
        'UPDATE `gossip_menu_option` gmo ',
        'SET gmo.`', @gmo_action_poi_col, '` = 0 ',
        'WHERE gmo.`', @gmo_action_poi_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `', @poi_table, '` poi WHERE poi.`', @poi_id_col, '` = gmo.`', @gmo_action_poi_col, '` )'
    ),
    'SELECT ''SKIP: ActionPoiID update skipped (missing dependency).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @rows_gossip_menu_option := @rows_gossip_menu_option + ROW_COUNT(); DEALLOCATE PREPARE stmt;

/* C) npc_text BroadcastTextID* */
SET @has_broadcast_text := (
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'broadcast_text'
);

SET @bt_pk_col := (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'broadcast_text'
      AND LOWER(c.column_name) IN ('id')
    ORDER BY FIELD(LOWER(c.column_name),'id')
    LIMIT 1
);

SET @npc_bt_cols_count := (
    SELECT COUNT(*)
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'npc_text'
      AND LOWER(c.column_name) REGEXP '^broadcasttextid[0-9]+$'
);

SET @npc_invalid_cond := (
    SELECT GROUP_CONCAT(
        CONCAT(
            '(nt.`', c.column_name, '` <> 0 AND NOT EXISTS (SELECT 1 FROM `broadcast_text` bt WHERE bt.`', @bt_pk_col, '` = nt.`', c.column_name, '`))'
        )
        ORDER BY c.ordinal_position SEPARATOR ' OR '
    )
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'npc_text'
      AND LOWER(c.column_name) REGEXP '^broadcasttextid[0-9]+$'
);

SET @npc_set_expr := (
    SELECT GROUP_CONCAT(
        CONCAT(
            'nt.`', c.column_name, '` = IF(nt.`', c.column_name, '` <> 0 AND NOT EXISTS (SELECT 1 FROM `broadcast_text` bt WHERE bt.`', @bt_pk_col, '` = nt.`', c.column_name, '`), 0, nt.`', c.column_name, '`)'
        )
        ORDER BY c.ordinal_position SEPARATOR ', '
    )
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'npc_text'
      AND LOWER(c.column_name) REGEXP '^broadcasttextid[0-9]+$'
);

SET @npc_invalid_sum_expr := (
    SELECT GROUP_CONCAT(
        CONCAT(
            '(nt.`', c.column_name, '` <> 0 AND NOT EXISTS (SELECT 1 FROM `broadcast_text` bt WHERE bt.`', @bt_pk_col, '` = nt.`', c.column_name, '`))'
        )
        ORDER BY c.ordinal_position SEPARATOR ' + '
    )
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'npc_text'
      AND LOWER(c.column_name) REGEXP '^broadcasttextid[0-9]+$'
);

SET @sql := IF(
    @has_npc_text = 1,
    'CREATE TABLE IF NOT EXISTS `npc_text_backup_genre4a` LIKE `npc_text`',
    'SELECT ''SKIP: table npc_text does not exist.'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_npc_text = 1 AND @has_broadcast_text = 1 AND @bt_pk_col IS NOT NULL AND @npc_bt_cols_count > 0,
    CONCAT(
        'INSERT IGNORE INTO `npc_text_backup_genre4a` ',
        'SELECT nt.* FROM `npc_text` nt WHERE ', @npc_invalid_cond
    ),
    'SELECT ''SKIP: npc_text backup skipped (missing broadcast_text or BroadcastTextID* columns).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_npc_text = 1 AND @has_broadcast_text = 1 AND @bt_pk_col IS NOT NULL AND @npc_bt_cols_count > 0,
    CONCAT(
        'UPDATE `npc_text` nt SET ', @npc_set_expr, ' WHERE ', @npc_invalid_cond
    ),
    'SELECT ''SKIP: npc_text update skipped (missing broadcast_text or BroadcastTextID* columns).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @rows_npc_text := @rows_npc_text + ROW_COUNT(); DEALLOCATE PREPARE stmt;

/* D) creature_text */
SET @has_creature_text := (
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'creature_text'
);

SET @ct_bt_col := (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'creature_text'
      AND LOWER(c.column_name) = 'broadcasttextid'
    LIMIT 1
);

SET @ct_sound_col := (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'creature_text'
      AND LOWER(c.column_name) = 'sound'
    LIMIT 1
);

SET @ct_emote_col := (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'creature_text'
      AND LOWER(c.column_name) = 'emote'
    LIMIT 1
);

SET @ct_textrange_col := (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'creature_text'
      AND LOWER(c.column_name) = 'textrange'
    LIMIT 1
);

SET @ct_textrangemin_col := (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'creature_text'
      AND LOWER(c.column_name) = 'textrangemin'
    LIMIT 1
);

SET @ct_textrangemax_col := (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'creature_text'
      AND LOWER(c.column_name) = 'textrangemax'
    LIMIT 1
);

SET @sound_table := (
    SELECT t.table_name
    FROM information_schema.tables t
    WHERE t.table_schema = DATABASE()
      AND t.table_name IN ('sound_entries','soundkit','sound_kit')
    ORDER BY FIELD(t.table_name,'sound_entries','soundkit','sound_kit')
    LIMIT 1
);

SET @sound_id_col := (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = @sound_table
      AND LOWER(c.column_name) IN ('id')
    ORDER BY FIELD(LOWER(c.column_name),'id')
    LIMIT 1
);

SET @has_emotes := (
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'emotes'
);

SET @emote_id_col := (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = DATABASE() AND c.table_name = 'emotes'
      AND LOWER(c.column_name) IN ('id')
    ORDER BY FIELD(LOWER(c.column_name),'id')
    LIMIT 1
);

SET @sql := IF(
    @has_creature_text = 1,
    'CREATE TABLE IF NOT EXISTS `creature_text_backup_genre4a` LIKE `creature_text`',
    'SELECT ''SKIP: table creature_text does not exist.'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_creature_text = 1 AND @has_broadcast_text = 1 AND @ct_bt_col IS NOT NULL AND @bt_pk_col IS NOT NULL,
    CONCAT(
        'INSERT IGNORE INTO `creature_text_backup_genre4a` ',
        'SELECT ct.* FROM `creature_text` ct WHERE ct.`', @ct_bt_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `broadcast_text` bt WHERE bt.`', @bt_pk_col, '` = ct.`', @ct_bt_col, '` )'
    ),
    'SELECT ''SKIP: creature_text BroadcastText backup skipped (missing dependency).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_creature_text = 1 AND @has_broadcast_text = 1 AND @ct_bt_col IS NOT NULL AND @bt_pk_col IS NOT NULL,
    CONCAT(
        'UPDATE `creature_text` ct SET ct.`', @ct_bt_col, '` = 0 ',
        'WHERE ct.`', @ct_bt_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `broadcast_text` bt WHERE bt.`', @bt_pk_col, '` = ct.`', @ct_bt_col, '` )'
    ),
    'SELECT ''SKIP: creature_text BroadcastText update skipped (missing dependency).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @rows_creature_text := @rows_creature_text + ROW_COUNT(); DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_creature_text = 1 AND @ct_sound_col IS NOT NULL AND @sound_table IS NOT NULL AND @sound_id_col IS NOT NULL,
    CONCAT(
        'INSERT IGNORE INTO `creature_text_backup_genre4a` ',
        'SELECT ct.* FROM `creature_text` ct WHERE ct.`', @ct_sound_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `', @sound_table, '` s WHERE s.`', @sound_id_col, '` = ct.`', @ct_sound_col, '` )'
    ),
    'SELECT ''SKIP: creature_text Sound backup skipped (missing dependency).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_creature_text = 1 AND @ct_sound_col IS NOT NULL AND @sound_table IS NOT NULL AND @sound_id_col IS NOT NULL,
    CONCAT(
        'UPDATE `creature_text` ct SET ct.`', @ct_sound_col, '` = 0 ',
        'WHERE ct.`', @ct_sound_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `', @sound_table, '` s WHERE s.`', @sound_id_col, '` = ct.`', @ct_sound_col, '` )'
    ),
    'SELECT ''SKIP: creature_text Sound update skipped (missing dependency).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @rows_creature_text := @rows_creature_text + ROW_COUNT(); DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_creature_text = 1 AND @ct_emote_col IS NOT NULL AND @has_emotes = 1 AND @emote_id_col IS NOT NULL,
    CONCAT(
        'INSERT IGNORE INTO `creature_text_backup_genre4a` ',
        'SELECT ct.* FROM `creature_text` ct WHERE ct.`', @ct_emote_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `emotes` e WHERE e.`', @emote_id_col, '` = ct.`', @ct_emote_col, '` )'
    ),
    'SELECT ''SKIP: creature_text Emote backup skipped (missing dependency).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_creature_text = 1 AND @ct_emote_col IS NOT NULL AND @has_emotes = 1 AND @emote_id_col IS NOT NULL,
    CONCAT(
        'UPDATE `creature_text` ct SET ct.`', @ct_emote_col, '` = 0 ',
        'WHERE ct.`', @ct_emote_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `emotes` e WHERE e.`', @emote_id_col, '` = ct.`', @ct_emote_col, '` )'
    ),
    'SELECT ''SKIP: creature_text Emote update skipped (missing dependency).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @rows_creature_text := @rows_creature_text + ROW_COUNT(); DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_creature_text = 1 AND @ct_textrange_col IS NOT NULL,
    CONCAT(
        'INSERT IGNORE INTO `creature_text_backup_genre4a` ',
        'SELECT ct.* FROM `creature_text` ct WHERE ct.`', @ct_textrange_col, '` < 0 OR ct.`', @ct_textrange_col, '` > 4'
    ),
    'SELECT ''SKIP: creature_text TextRange backup skipped (missing column).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_creature_text = 1 AND @ct_textrange_col IS NOT NULL,
    CONCAT(
        'UPDATE `creature_text` ct SET ct.`', @ct_textrange_col, '` = 0 ',
        'WHERE ct.`', @ct_textrange_col, '` < 0 OR ct.`', @ct_textrange_col, '` > 4'
    ),
    'SELECT ''SKIP: creature_text TextRange update skipped (missing column).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @rows_creature_text := @rows_creature_text + ROW_COUNT(); DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_creature_text = 1 AND @ct_textrangemin_col IS NOT NULL AND @ct_textrangemax_col IS NOT NULL,
    CONCAT(
        'INSERT IGNORE INTO `creature_text_backup_genre4a` ',
        'SELECT ct.* FROM `creature_text` ct ',
        'WHERE ct.`', @ct_textrangemin_col, '` < 0 ',
        'OR ct.`', @ct_textrangemax_col, '` < 0 ',
        'OR ct.`', @ct_textrangemin_col, '` > ct.`', @ct_textrangemax_col, '`'
    ),
    'SELECT ''SKIP: creature_text TextRangeMin/TextRangeMax backup skipped (missing columns).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_creature_text = 1 AND @ct_textrangemin_col IS NOT NULL AND @ct_textrangemax_col IS NOT NULL,
    CONCAT(
        'UPDATE `creature_text` ct ',
        'SET ct.`', @ct_textrangemin_col, '` = 0, ct.`', @ct_textrangemax_col, '` = 0 ',
        'WHERE ct.`', @ct_textrangemin_col, '` < 0 ',
        'OR ct.`', @ct_textrangemax_col, '` < 0 ',
        'OR ct.`', @ct_textrangemin_col, '` > ct.`', @ct_textrangemax_col, '`'
    ),
    'SELECT ''SKIP: creature_text TextRangeMin/TextRangeMax update skipped (missing columns).'' AS note'
);
PREPARE stmt FROM @sql; EXECUTE stmt; SET @rows_creature_text := @rows_creature_text + ROW_COUNT(); DEALLOCATE PREPARE stmt;

/* Verification */
SET @sql := IF(
    @has_gossip_menu = 1 AND @has_npc_text = 1 AND @gm_text_col IS NOT NULL AND @npc_pk_col IS NOT NULL,
    CONCAT(
        'SELECT COUNT(*) INTO @ver_gm_invalid_textid FROM `gossip_menu` gm ',
        'WHERE gm.`', @gm_text_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `npc_text` nt WHERE nt.`', @npc_pk_col, '` = gm.`', @gm_text_col, '` )'
    ),
    'SELECT 0 INTO @ver_gm_invalid_textid'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_gmo = 1 AND @has_gossip_menu = 1 AND @gmo_action_menu_col IS NOT NULL AND @gm_menu_col IS NOT NULL,
    CONCAT(
        'SELECT COUNT(*) INTO @ver_gmo_invalid_actionmenuid FROM `gossip_menu_option` gmo ',
        'WHERE gmo.`', @gmo_action_menu_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `gossip_menu` gm WHERE gm.`', @gm_menu_col, '` = gmo.`', @gmo_action_menu_col, '` )'
    ),
    'SELECT 0 INTO @ver_gmo_invalid_actionmenuid'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_gmo = 1 AND @gmo_action_poi_col IS NOT NULL AND @poi_table IS NOT NULL AND @poi_id_col IS NOT NULL,
    CONCAT(
        'SELECT COUNT(*) INTO @ver_gmo_invalid_actionpoiid FROM `gossip_menu_option` gmo ',
        'WHERE gmo.`', @gmo_action_poi_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `', @poi_table, '` poi WHERE poi.`', @poi_id_col, '` = gmo.`', @gmo_action_poi_col, '` )'
    ),
    'SELECT 0 INTO @ver_gmo_invalid_actionpoiid'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_npc_text = 1 AND @has_broadcast_text = 1 AND @bt_pk_col IS NOT NULL AND @npc_bt_cols_count > 0,
    CONCAT('SELECT IFNULL(SUM(', @npc_invalid_sum_expr, '),0) INTO @ver_npc_invalid_broadcast_refs FROM `npc_text` nt'),
    'SELECT 0 INTO @ver_npc_invalid_broadcast_refs'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_creature_text = 1 AND @has_broadcast_text = 1 AND @ct_bt_col IS NOT NULL AND @bt_pk_col IS NOT NULL,
    CONCAT(
        'SELECT COUNT(*) INTO @ver_ct_invalid_broadcast FROM `creature_text` ct ',
        'WHERE ct.`', @ct_bt_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `broadcast_text` bt WHERE bt.`', @bt_pk_col, '` = ct.`', @ct_bt_col, '` )'
    ),
    'SELECT 0 INTO @ver_ct_invalid_broadcast'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_creature_text = 1 AND @ct_sound_col IS NOT NULL AND @sound_table IS NOT NULL AND @sound_id_col IS NOT NULL,
    CONCAT(
        'SELECT COUNT(*) INTO @ver_ct_invalid_sound FROM `creature_text` ct ',
        'WHERE ct.`', @ct_sound_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `', @sound_table, '` s WHERE s.`', @sound_id_col, '` = ct.`', @ct_sound_col, '` )'
    ),
    'SELECT 0 INTO @ver_ct_invalid_sound'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_creature_text = 1 AND @ct_emote_col IS NOT NULL AND @has_emotes = 1 AND @emote_id_col IS NOT NULL,
    CONCAT(
        'SELECT COUNT(*) INTO @ver_ct_invalid_emote FROM `creature_text` ct ',
        'WHERE ct.`', @ct_emote_col, '` <> 0 ',
        'AND NOT EXISTS (SELECT 1 FROM `emotes` e WHERE e.`', @emote_id_col, '` = ct.`', @ct_emote_col, '` )'
    ),
    'SELECT 0 INTO @ver_ct_invalid_emote'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF(
    @has_creature_text = 1 AND @ct_textrange_col IS NOT NULL,
    CONCAT(
        'SELECT COUNT(*) INTO @ver_ct_invalid_textrange FROM `creature_text` ct ',
        'WHERE ct.`', @ct_textrange_col, '` < 0 OR ct.`', @ct_textrange_col, '` > 4'
    ),
    'SELECT 0 INTO @ver_ct_invalid_textrange'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT
    @rows_gossip_menu AS changed_rows_gossip_menu,
    @rows_gossip_menu_option AS changed_rows_gossip_menu_option,
    @rows_npc_text AS changed_rows_npc_text,
    @rows_creature_text AS changed_rows_creature_text;

SELECT IFNULL(@ver_gm_invalid_textid, 0) AS remaining_invalid_gossip_menu_textid;

SELECT
    IFNULL(@ver_gmo_invalid_actionmenuid, 0) AS remaining_invalid_gossip_menu_option_actionmenuid,
    IFNULL(@ver_gmo_invalid_actionpoiid, 0) AS remaining_invalid_gossip_menu_option_actionpoiid;

SELECT IFNULL(@ver_npc_invalid_broadcast_refs, 0) AS remaining_invalid_npc_text_broadcast_refs;

SELECT
    IFNULL(@ver_ct_invalid_broadcast, 0) AS remaining_invalid_creature_text_broadcast,
    IFNULL(@ver_ct_invalid_sound, 0) AS remaining_invalid_creature_text_sound,
    IFNULL(@ver_ct_invalid_emote, 0) AS remaining_invalid_creature_text_emote,
    IFNULL(@ver_ct_invalid_textrange, 0) AS remaining_invalid_creature_text_textrange;

COMMIT;

SET SQL_SAFE_UPDATES = @OLD_SQL_SAFE_UPDATES;
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;
SET AUTOCOMMIT = @OLD_AUTOCOMMIT;
