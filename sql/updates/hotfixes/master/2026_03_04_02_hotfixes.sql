-- RoleplayCore — Wire up Silvermoon portal spell (1259194)
-- The portal GO (entry 621992) in the Wizard's Sanctum casts spell 1259194
-- "Portal: Silvermoon City" but it had zero spell_effect rows, making it inert.
-- Same fix pattern as Founder's Point (spell 1235595).
-- Destination: classic Silvermoon City on map 530 (Outland/Eversong Woods).
-- No new Midnight-era Silvermoon map exists yet in hotfixes.map.

INSERT INTO `spell_effect`
    (`ID`, `EffectAura`, `DifficultyID`, `EffectIndex`, `Effect`,
     `EffectAmplitude`, `EffectAttributes`, `EffectAuraPeriod`,
     `EffectBonusCoefficient`, `EffectChainAmplitude`, `EffectChainTargets`,
     `EffectItemType`, `EffectMechanic`, `EffectPointsPerResource`,
     `EffectPosFacing`, `EffectRealPointsPerLevel`, `EffectTriggerSpell`,
     `BonusCoefficientFromAP`, `PvpMultiplier`, `Coefficient`, `Variance`,
     `ResourceCoefficient`, `GroupSizeBasePointsCoefficient`, `EffectBasePoints`,
     `ScalingClass`, `TargetNodeGraph`,
     `EffectMiscValue1`, `EffectMiscValue2`,
     `EffectRadiusIndex1`, `EffectRadiusIndex2`,
     `EffectSpellClassMask1`, `EffectSpellClassMask2`, `EffectSpellClassMask3`, `EffectSpellClassMask4`,
     `ImplicitTarget1`, `ImplicitTarget2`, `SpellID`, `VerifiedBuild`)
VALUES
    (1900005, 0, 0, 0, 15,
     0, 0, 0,
     0, 1, 0,
     0, 0, 0,
     0, 0, 0,
     0, 1, 0, 0,
     0, 1, 0,
     0, 0,
     0, 0,
     0, 0,
     0, 0, 0, 0,
     1, 17, 1259194, 66220);

-- Register in hotfix_data so TC pushes this to the client
INSERT INTO `hotfix_data`
    (`Id`, `UniqueId`, `TableHash`, `RecordId`, `Status`, `VerifiedBuild`)
VALUES
    (17006230, 17006230, 4030871717, 1900005, 1, 0);
