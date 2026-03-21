-- Fix spell 1247917 (Clear Current Transmogrifications) effect mismatch
-- Retail row (ID 1250344) had Effect 347 (EQUIP_TRANSMOG_OUTFIT) overriding
-- our custom SCRIPT_EFFECT hook because it had a higher VerifiedBuild.
-- Delete the retail row so our custom Effect 77 handler fires correctly.
DELETE FROM `spell_effect` WHERE `ID` = 1250344 AND `SpellID` = 1247917 AND `Effect` = 347;
UPDATE `spell_effect` SET `VerifiedBuild` = 66527 WHERE `ID` = 1900003 AND `SpellID` = 1247917;

-- Remove hotfix_blob rows for 8 DB2 stores now natively loaded by TC
-- These caused ~13,480 error log entries per boot:
--   SpecializationSpellsDisplay, NPCSounds, CraftingReagentQuality, CraftingData,
--   ModelFileData, ScreenEffect, ModifiedCraftingSpellSlot, Campaign
DELETE FROM `hotfix_blob` WHERE `TableHash` IN (
    476847390,   -- SpecializationSpellsDisplay
    1230280159,  -- NPCSounds
    1335698303,  -- CraftingReagentQuality
    2534422486,  -- CraftingData
    2707547180,  -- ModelFileData
    3007265124,  -- ScreenEffect
    3388959798,  -- ModifiedCraftingSpellSlot
    3656496423   -- Campaign
);
