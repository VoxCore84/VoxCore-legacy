-- Add SPELL_EFFECT_SCRIPT_EFFECT (77) for spell 1247917 "Clear Current Transmogrifications"
-- The spell exists in DB2 (SpellName + SpellMisc) but has no SpellEffect rows,
-- so it does nothing when cast. We add a script effect targeting self (TARGET_UNIT_CASTER=1).
INSERT INTO spell_effect (ID, Effect, EffectIndex, SpellID, ImplicitTarget1, VerifiedBuild)
VALUES (1900003, 77, 0, 1247917, 1, 66102)
ON DUPLICATE KEY UPDATE Effect=77, SpellID=1247917, ImplicitTarget1=1;

-- hotfix_data entry so the server loads this new spell_effect record
INSERT INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild)
VALUES (17003523, FLOOR(RAND() * 4294967295), 3776013982, 1900003, 1, 66102)
ON DUPLICATE KEY UPDATE Status=1;
