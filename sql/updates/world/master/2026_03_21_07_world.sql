-- Remove 13,902 creature_template_spell rows with out-of-range Index
-- MAX_CREATURE_SPELLS = 8 (indices 0-7 only). Rows with Index >= 8 are
-- ignored by the server but generate ~1,300 error log entries per boot.
-- These are from massparse data that assigned more spells than TC supports.
DELETE FROM `creature_template_spell` WHERE `Index` >= 8;
