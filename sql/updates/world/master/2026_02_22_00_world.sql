-- ================================================================== --
-- Wizard's Sanctum portal hub v2                                     --
--                                                                    --
-- Fixes portal invisibility and broken teleports in Wizard's Sanctum --
-- by addressing missing templates, phasing, and spell/display wiring --
--                                                                    --
-- v2 fix: Founder's Point (543407) Data1 was 0 (zero charges).       --
-- GAMEOBJECT_TYPE_SPELL_CASTER uses Data1 as charge count:           --
--   -1 = infinite charges (portal always works)                      --
--    0 = zero charges (interaction fires but spell never casts)      --
-- All other portals had Data1=-1. Founder's Point was the only one   --
-- excluded from the set-based CASE update, so it kept Data1=0.      --
-- ================================================================== --

USE `world`;

SET @OGUID := 10001978;
SET @OLD_SQL_SAFE_UPDATES := @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;

-- ================================================================== --
-- 1. Unphase Dornogal portal spawn                                   --
-- ================================================================== --
UPDATE `gameobject`
SET `PhaseId` = 0,
    `PhaseGroup` = 0
WHERE `guid` = @OGUID + 6
  AND `id` = 620463;

-- ================================================================== --
-- 2. Ensure missing portal templates exist (cloned from 620463)      --
-- ================================================================== --
INSERT INTO `gameobject_template`
(`entry`, `type`, `displayId`, `name`, `IconName`, `castBarCaption`, `unk1`, `size`,
 `Data0`, `Data1`, `Data2`, `Data3`, `Data4`, `Data5`, `Data6`, `Data7`, `Data8`, `Data9`,
 `Data10`, `Data11`, `Data12`, `Data13`, `Data14`, `Data15`, `Data16`, `Data17`, `Data18`,
 `Data19`, `Data20`, `Data21`, `Data22`, `Data23`, `Data24`, `Data25`, `Data26`, `Data27`,
 `Data28`, `Data29`, `Data30`, `Data31`, `Data32`, `Data33`, `Data34`,
 `RequiredLevel`, `ContentTuningId`, `VerifiedBuild`)
SELECT
  ids.`entry`,
  base.`type`,
  base.`displayId`,
  ids.`name`,
  base.`IconName`, base.`castBarCaption`, base.`unk1`, base.`size`,
  base.`Data0`, base.`Data1`, base.`Data2`, base.`Data3`, base.`Data4`, base.`Data5`, base.`Data6`, base.`Data7`, base.`Data8`, base.`Data9`,
  base.`Data10`, base.`Data11`, base.`Data12`, base.`Data13`, base.`Data14`, base.`Data15`, base.`Data16`, base.`Data17`, base.`Data18`,
  base.`Data19`, base.`Data20`, base.`Data21`, base.`Data22`, base.`Data23`, base.`Data24`, base.`Data25`, base.`Data26`, base.`Data27`,
  base.`Data28`, base.`Data29`, base.`Data30`, base.`Data31`, base.`Data32`, base.`Data33`, base.`Data34`,
  base.`RequiredLevel`, base.`ContentTuningId`, base.`VerifiedBuild`
FROM `gameobject_template` base
JOIN (
  SELECT 620455 AS `entry`, 'Portal to Caverns of Time' AS `name`
  UNION ALL SELECT 620458, 'Portal to Valdrakken'
  UNION ALL SELECT 620464, 'Portal to Oribos'
  UNION ALL SELECT 620465, 'Portal to Boralus'
  UNION ALL SELECT 620467, 'Portal to Jade Forest'
  UNION ALL SELECT 620472, 'Portal to Shattrath'
  UNION ALL SELECT 620473, 'Portal to the Exodar'
  UNION ALL SELECT 620475, 'Portal to Dalaran, Crystalsong Forest'
  UNION ALL SELECT 620476, 'Portal to Bel''ameth'
  UNION ALL SELECT 620477, 'Portal to Azsuna'
  UNION ALL SELECT 620479, 'Portal to Stormshield, Ashran'
) ids
LEFT JOIN `gameobject_template` existing ON existing.`entry` = ids.`entry`
WHERE base.`entry` = 620463
  AND existing.`entry` IS NULL;

-- ================================================================== --
-- 3. Ensure Founder's Point template exists                          --
-- ================================================================== --
INSERT INTO `gameobject_template`
(`entry`, `type`, `displayId`, `name`, `IconName`, `castBarCaption`, `unk1`, `size`,
 `Data0`, `Data1`, `Data2`, `Data3`, `Data4`, `Data5`, `Data6`, `Data7`, `Data8`, `Data9`,
 `Data10`, `Data11`, `Data12`, `Data13`, `Data14`, `Data15`, `Data16`, `Data17`, `Data18`,
 `Data19`, `Data20`, `Data21`, `Data22`, `Data23`, `Data24`, `Data25`, `Data26`, `Data27`,
 `Data28`, `Data29`, `Data30`, `Data31`, `Data32`, `Data33`, `Data34`,
 `RequiredLevel`, `ContentTuningId`, `VerifiedBuild`)
SELECT
  543407, base.`type`, 117089, 'Portal to Founder\'s Point',
  base.`IconName`, base.`castBarCaption`, base.`unk1`, 1.299999952316284179,
  base.`Data0`, base.`Data1`, base.`Data2`, base.`Data3`, base.`Data4`, base.`Data5`, base.`Data6`, base.`Data7`, base.`Data8`, base.`Data9`,
  base.`Data10`, base.`Data11`, base.`Data12`, base.`Data13`, base.`Data14`, base.`Data15`, base.`Data16`, base.`Data17`, base.`Data18`,
  base.`Data19`, base.`Data20`, base.`Data21`, base.`Data22`, base.`Data23`, base.`Data24`, base.`Data25`, base.`Data26`, base.`Data27`,
  base.`Data28`, base.`Data29`, base.`Data30`, base.`Data31`, base.`Data32`, base.`Data33`, base.`Data34`,
  0, 0, 65299
FROM `gameobject_template` base
LEFT JOIN `gameobject_template` existing ON existing.`entry` = 543407
WHERE base.`entry` = 620463
  AND existing.`entry` IS NULL;

UPDATE `gameobject_template`
SET
  `type` = 22,
  `displayId` = 117089,
  `name` = 'Portal to Founder\'s Point',
  `size` = 1.299999952316284179,
  `Data0` = 1235595,
  `Data1` = -1,           -- v2: was 0 (zero charges = spell never casts)
  `Data3` = 1,
  `Data5` = 23503,
  `Data6` = 1,
  `RequiredLevel` = 0,
  `ContentTuningId` = 0,
  `VerifiedBuild` = 65299
WHERE `entry` = 543407;

-- ================================================================== --
-- 4. Template addons for visuals/interaction                         --
-- ================================================================== --
DELETE FROM `gameobject_template_addon`
WHERE `entry` IN (620455,620458,620463,620464,620465,620467,620472,620473,620475,620476,620477,620479,543407);

INSERT INTO `gameobject_template_addon` (`entry`, `faction`, `flags`, `WorldEffectID`, `AIAnimKitID`)
VALUES
(620455, 1732, 0x0, 0, 3503),
(620458, 1732, 0x0, 0, 3503),
(620463, 1732, 0x0, 0, 3503),
(620464, 1732, 0x0, 0, 3503),
(620465, 1732, 0x0, 0, 3503),
(620467, 1732, 0x0, 0, 3503),
(620472, 1732, 0x0, 0, 3503),
(620473, 1732, 0x0, 0, 3503),
(620475, 1732, 0x0, 0, 3503),
(620476, 1732, 0x0, 0, 3906),
(620477, 1732, 0x0, 0, 3503),
(620479, 1732, 0x0, 0, 3503),
(543407,    0, 0x0, 0, 24311);

-- ================================================================== --
-- 5. Set spells + interaction flags                                  --
--    v2: 543407 now included in Data1=-1 set (was excluded → 0)      --
-- ================================================================== --
UPDATE `gameobject_template`
SET
  `Data0` = CASE `entry`
    WHEN 620477 THEN 296901   -- Azsuna
    WHEN 620458 THEN 393590   -- Valdrakken
    WHEN 620473 THEN 32268    -- Exodar
    WHEN 620475 THEN 53140    -- Dalaran (Crystalsong)
    WHEN 620455 THEN 59901    -- Caverns of Time
    WHEN 620465 THEN 281405   -- Boralus
    WHEN 620479 THEN 225748   -- Stormshield (Ashran)
    WHEN 620464 THEN 329132   -- Oribos
    WHEN 620472 THEN 33728    -- Shattrath
    WHEN 543407 THEN 1235595  -- Founder's Point
    ELSE `Data0`
  END,
  `Data1` = CASE
    WHEN `entry` IN (620477,620458,620473,620475,620455,620465,620479,620464,620472,543407) THEN -1
    ELSE `Data1`
  END,
  `Data6` = CASE
    WHEN `entry` IN (620477,620458,620473,620475,620455,620465,620479,620464,620472,543407) THEN 1
    ELSE `Data6`
  END
WHERE `entry` IN (620455,620458,620464,620465,620472,620473,620475,620477,620479,543407);

-- ================================================================== --
-- 6. Copy full portal payload from known-good references             --
-- ================================================================== --
-- Jade Forest (620467) ← from 323844
UPDATE `gameobject_template` t
JOIN `gameobject_template` ref ON ref.`entry` = 323844
SET
  t.`Data0`=ref.`Data0`, t.`Data1`=ref.`Data1`, t.`Data2`=ref.`Data2`, t.`Data3`=ref.`Data3`, t.`Data4`=ref.`Data4`,
  t.`Data5`=ref.`Data5`, t.`Data6`=ref.`Data6`, t.`Data7`=ref.`Data7`, t.`Data8`=ref.`Data8`, t.`Data9`=ref.`Data9`,
  t.`Data10`=ref.`Data10`, t.`Data11`=ref.`Data11`, t.`Data12`=ref.`Data12`, t.`Data13`=ref.`Data13`, t.`Data14`=ref.`Data14`,
  t.`Data15`=ref.`Data15`, t.`Data16`=ref.`Data16`, t.`Data17`=ref.`Data17`, t.`Data18`=ref.`Data18`, t.`Data19`=ref.`Data19`,
  t.`Data20`=ref.`Data20`, t.`Data21`=ref.`Data21`, t.`Data22`=ref.`Data22`, t.`Data23`=ref.`Data23`, t.`Data24`=ref.`Data24`,
  t.`Data25`=ref.`Data25`, t.`Data26`=ref.`Data26`, t.`Data27`=ref.`Data27`, t.`Data28`=ref.`Data28`, t.`Data29`=ref.`Data29`,
  t.`Data30`=ref.`Data30`, t.`Data31`=ref.`Data31`, t.`Data32`=ref.`Data32`, t.`Data33`=ref.`Data33`, t.`Data34`=ref.`Data34`,
  t.`ContentTuningId`=ref.`ContentTuningId`,
  t.`RequiredLevel`=ref.`RequiredLevel`
WHERE t.`entry` = 620467;

-- Bel'ameth (620476) ← from 420918
UPDATE `gameobject_template` t
JOIN `gameobject_template` ref ON ref.`entry` = 420918
SET
  t.`Data0`=ref.`Data0`, t.`Data1`=ref.`Data1`, t.`Data2`=ref.`Data2`, t.`Data3`=ref.`Data3`, t.`Data4`=ref.`Data4`,
  t.`Data5`=ref.`Data5`, t.`Data6`=ref.`Data6`, t.`Data7`=ref.`Data7`, t.`Data8`=ref.`Data8`, t.`Data9`=ref.`Data9`,
  t.`Data10`=ref.`Data10`, t.`Data11`=ref.`Data11`, t.`Data12`=ref.`Data12`, t.`Data13`=ref.`Data13`, t.`Data14`=ref.`Data14`,
  t.`Data15`=ref.`Data15`, t.`Data16`=ref.`Data16`, t.`Data17`=ref.`Data17`, t.`Data18`=ref.`Data18`, t.`Data19`=ref.`Data19`,
  t.`Data20`=ref.`Data20`, t.`Data21`=ref.`Data21`, t.`Data22`=ref.`Data22`, t.`Data23`=ref.`Data23`, t.`Data24`=ref.`Data24`,
  t.`Data25`=ref.`Data25`, t.`Data26`=ref.`Data26`, t.`Data27`=ref.`Data27`, t.`Data28`=ref.`Data28`, t.`Data29`=ref.`Data29`,
  t.`Data30`=ref.`Data30`, t.`Data31`=ref.`Data31`, t.`Data32`=ref.`Data32`, t.`Data33`=ref.`Data33`, t.`Data34`=ref.`Data34`,
  t.`ContentTuningId`=ref.`ContentTuningId`,
  t.`RequiredLevel`=ref.`RequiredLevel`
WHERE t.`entry` = 620476;

-- ================================================================== --
-- 7. Display IDs                                                     --
-- ================================================================== --
UPDATE `gameobject_template`
SET `displayId` = CASE `entry`
  WHEN 620467 THEN 55651
  WHEN 620477 THEN 55648
  WHEN 620458 THEN 77931
  WHEN 620473 THEN 55650
  WHEN 620475 THEN 55649
  WHEN 620455 THEN 57430
  WHEN 620463 THEN 92603
  WHEN 620465 THEN 55652
  WHEN 620479 THEN 55647
  WHEN 620464 THEN 68190
  WHEN 620472 THEN 55653
  WHEN 620476 THEN 87382
  WHEN 543407 THEN 117089
  ELSE `displayId`
END
WHERE `entry` IN (620455,620458,620463,620464,620465,620467,620472,620473,620475,620476,620477,620479,543407);

SET SQL_SAFE_UPDATES = @OLD_SQL_SAFE_UPDATES;
