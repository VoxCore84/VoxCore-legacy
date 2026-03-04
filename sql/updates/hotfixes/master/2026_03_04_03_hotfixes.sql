-- RoleplayCore — Clean up unnecessary Silvermoon spell 1259194 hotfix rows
-- Spell 1259194 is a Mage portal spell, not a GO-click teleport.
-- The GO now uses spell 1286187 instead (has its own retail spell_effect rows).
-- Remove the custom spell_effect and hotfix_data rows we added in error.

DELETE FROM `spell_effect` WHERE `ID` = 1900005;
DELETE FROM `hotfix_data` WHERE `Id` = 17006230;
