-- Fix 79 npc_text entries with all probabilities = 0 (no text selectable)
-- Set Probability0 = 1 so at least the first text option is selectable
UPDATE `npc_text` SET `Probability0` = 1
WHERE `Probability0` = 0 AND `Probability1` = 0 AND `Probability2` = 0 AND `Probability3` = 0
AND `Probability4` = 0 AND `Probability5` = 0 AND `Probability6` = 0 AND `Probability7` = 0
AND `ID` > 0;

-- Fix 88 creature_model_info rows with invalid DisplayID_Other_Gender = 1
-- DisplayID 1 doesn't exist as a valid creature display — clear to 0
UPDATE `creature_model_info` SET `DisplayID_Other_Gender` = 0 WHERE `DisplayID_Other_Gender` = 1;
