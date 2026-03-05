-- ============================================================
-- WPP Sniff Enrichment — Stormwind build 66263
-- Generated: 2026-03-05T15:04:46
-- creature_template, creature_equip, spawns, portal cleanup
-- ============================================================

-- creature_template.type: 43 gap fills from sniff
UPDATE `creature_template` SET `type`=7 WHERE `entry`=1307 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=1308 AND `type`=0;
UPDATE `creature_template` SET `type`=8 WHERE `entry`=1412 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=1413 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=1414 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=1415 AND `type`=0;
UPDATE `creature_template` SET `type`=1 WHERE `entry`=1419 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=1976 AND `type`=0;
UPDATE `creature_template` SET `type`=10 WHERE `entry`=2334 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=2485 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=2708 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=5497 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=5694 AND `type`=0;
UPDATE `creature_template` SET `type`=10 WHERE `entry`=15214 AND `type`=0;
UPDATE `creature_template` SET `type`=10 WHERE `entry`=32520 AND `type`=0;
UPDATE `creature_template` SET `type`=1 WHERE `entry`=43102 AND `type`=0;
UPDATE `creature_template` SET `type`=1 WHERE `entry`=43103 AND `type`=0;
UPDATE `creature_template` SET `type`=2 WHERE `entry`=52408 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=62821 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=62822 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=85307 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=85816 AND `type`=0;
UPDATE `creature_template` SET `type`=9 WHERE `entry`=103033 AND `type`=0;
UPDATE `creature_template` SET `type`=10 WHERE `entry`=111190 AND `type`=0;
UPDATE `creature_template` SET `type`=10 WHERE `entry`=120751 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=141902 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=142641 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=149121 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=149124 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=149467 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=149469 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=149616 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=149626 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=150122 AND `type`=0;
UPDATE `creature_template` SET `type`=10 WHERE `entry`=151937 AND `type`=0;
UPDATE `creature_template` SET `type`=10 WHERE `entry`=180538 AND `type`=0;
UPDATE `creature_template` SET `type`=10 WHERE `entry`=180701 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=187196 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=193786 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=193812 AND `type`=0;
UPDATE `creature_template` SET `type`=10 WHERE `entry`=197503 AND `type`=0;
UPDATE `creature_template` SET `type`=10 WHERE `entry`=197611 AND `type`=0;
UPDATE `creature_template` SET `type`=7 WHERE `entry`=198079 AND `type`=0;

-- creature_template.type: 2 retail corrections from sniff
UPDATE `creature_template` SET `type`=1 WHERE `entry`=1933 AND `type`=8; -- was 8
UPDATE `creature_template` SET `type`=10 WHERE `entry`=218381 AND `type`=7; -- was 7

-- creature_template.family: 1 gap fills from sniff
UPDATE `creature_template` SET `family`=1 WHERE `entry`=165189 AND `family`=0;

-- creature_template.Classification: 2 gap fills from sniff
UPDATE `creature_template` SET `Classification`=1 WHERE `entry`=242175 AND `Classification`=0;
UPDATE `creature_template` SET `Classification`=1 WHERE `entry`=242177 AND `Classification`=0;

-- creature_template.unit_class: 23 corrections (warrior->caster) from sniff
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=5694 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=4 WHERE `entry`=17252 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=54442 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=62821 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=82564 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=84751 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=2 WHERE `entry`=85307 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=133509 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=4 WHERE `entry`=143622 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=147741 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=148124 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=148233 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=148796 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=149099 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=149131 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=149616 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=149626 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=150122 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=2 WHERE `entry`=217642 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=8 WHERE `entry`=218381 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=4 WHERE `entry`=219318 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=2 WHERE `entry`=221294 AND `unit_class`=1;
UPDATE `creature_template` SET `unit_class`=2 WHERE `entry`=223728 AND `unit_class`=1;

-- creature_template_difficulty.HealthScalingExpansion: 22 fills from sniff
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=2 WHERE `Entry`=32206 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=3 WHERE `Entry`=52408 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=5 WHERE `Entry`=82564 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=5 WHERE `Entry`=84745 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=5 WHERE `Entry`=84749 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=5 WHERE `Entry`=84751 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=1 WHERE `Entry`=85307 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=5 WHERE `Entry`=85816 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=5 WHERE `Entry`=85817 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=5 WHERE `Entry`=85818 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=5 WHERE `Entry`=85819 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=6 WHERE `Entry`=103033 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=6 WHERE `Entry`=111190 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=6 WHERE `Entry`=125210 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=7 WHERE `Entry`=141902 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=7 WHERE `Entry`=142641 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=9 WHERE `Entry`=180538 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=9 WHERE `Entry`=180701 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=11 WHERE `Entry`=183978 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=9 WHERE `Entry`=197611 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=11 WHERE `Entry`=199602 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=10 WHERE `Entry`=243253 AND `DifficultyID`=0 AND `HealthScalingExpansion`=0;

-- creature_template_difficulty.HealthScalingExpansion: 7 corrections from sniff
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=2 WHERE `Entry`=32335 AND `DifficultyID`=0 AND `HealthScalingExpansion`=5; -- was 5
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=3 WHERE `Entry`=53888 AND `DifficultyID`=0 AND `HealthScalingExpansion`=5; -- was 5
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=3 WHERE `Entry`=53891 AND `DifficultyID`=0 AND `HealthScalingExpansion`=5; -- was 5
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=4 WHERE `Entry`=62088 AND `DifficultyID`=0 AND `HealthScalingExpansion`=5; -- was 5
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=4 WHERE `Entry`=80651 AND `DifficultyID`=0 AND `HealthScalingExpansion`=5; -- was 5
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=4 WHERE `Entry`=80674 AND `DifficultyID`=0 AND `HealthScalingExpansion`=5; -- was 5
UPDATE `creature_template_difficulty` SET `HealthScalingExpansion`=6 WHERE `Entry`=225508 AND `DifficultyID`=0 AND `HealthScalingExpansion`=10; -- was 10

-- creature_template_difficulty.HealthModifier: 5 retail values from sniff
UPDATE `creature_template_difficulty` SET `HealthModifier`=1.5 WHERE `Entry`=165189 AND `DifficultyID`=0 AND `HealthModifier`=1;
UPDATE `creature_template_difficulty` SET `HealthModifier`=1.5 WHERE `Entry`=186180 AND `DifficultyID`=0 AND `HealthModifier`=1;
UPDATE `creature_template_difficulty` SET `HealthModifier`=2.0 WHERE `Entry`=198579 AND `DifficultyID`=0 AND `HealthModifier`=1;
UPDATE `creature_template_difficulty` SET `HealthModifier`=2.0 WHERE `Entry`=198581 AND `DifficultyID`=0 AND `HealthModifier`=1;
UPDATE `creature_template_difficulty` SET `HealthModifier`=2.0 WHERE `Entry`=198589 AND `DifficultyID`=0 AND `HealthModifier`=1;

-- creature_template_difficulty.ManaModifier: 6 retail values from sniff
UPDATE `creature_template_difficulty` SET `ManaModifier`=2.0 WHERE `Entry`=17252 AND `DifficultyID`=0 AND `ManaModifier`=1;
UPDATE `creature_template_difficulty` SET `ManaModifier`=1.5 WHERE `Entry`=62821 AND `DifficultyID`=0 AND `ManaModifier`=1;
UPDATE `creature_template_difficulty` SET `ManaModifier`=5.0 WHERE `Entry`=82564 AND `DifficultyID`=0 AND `ManaModifier`=1;
UPDATE `creature_template_difficulty` SET `ManaModifier`=5.0 WHERE `Entry`=84751 AND `DifficultyID`=0 AND `ManaModifier`=1;
UPDATE `creature_template_difficulty` SET `ManaModifier`=10.0 WHERE `Entry`=85307 AND `DifficultyID`=0 AND `ManaModifier`=1;
UPDATE `creature_template_difficulty` SET `ManaModifier`=3.0 WHERE `Entry`=201312 AND `DifficultyID`=0 AND `ManaModifier`=1;

-- creature_equip_template: 1 gap fills from sniff
UPDATE `creature_equip_template` SET `ItemID1`=2202 WHERE `CreatureID`=5516 AND `ID`=1 AND `ItemID1`=0; -- DB=(0, 0, 2552) -> Sniff=(2202, 0, 2552)

-- creature_equip_template: 10 retail corrections from sniff
UPDATE `creature_equip_template` SET `ItemID1`=47104 WHERE `CreatureID`=332 AND `ID`=1 AND `ItemID1`=2711; -- DB=(2711, 2711, 0) -> Sniff=(47104, 0, 0)
UPDATE `creature_equip_template` SET `ItemID1`=1899 WHERE `CreatureID`=1976 AND `ID`=1 AND `ItemID1`=2715; -- DB=(2715, 143, 2551) -> Sniff=(1899, 143, 2551)
UPDATE `creature_equip_template` SET `ItemID1`=2202 WHERE `CreatureID`=5515 AND `ID`=1 AND `ItemID1`=2703; -- DB=(2703, 0, 0) -> Sniff=(2202, 0, 0)
UPDATE `creature_equip_template` SET `ItemID1`=2703 WHERE `CreatureID`=5517 AND `ID`=1 AND `ItemID1`=1909; -- DB=(1909, 0, 0) -> Sniff=(2703, 0, 0)
UPDATE `creature_equip_template` SET `ItemID1`=1911 WHERE `CreatureID`=29016 AND `ID`=1 AND `ItemID1`=1903; -- DB=(1903, 0, 0) -> Sniff=(1911, 0, 0)
UPDATE `creature_equip_template` SET `ItemID1`=2703 WHERE `CreatureID`=54214 AND `ID`=1 AND `ItemID1`=2202; -- DB=(2202, 0, 0) -> Sniff=(2703, 0, 0)
UPDATE `creature_equip_template` SET `ItemID1`=768 WHERE `CreatureID`=114246 AND `ID`=1 AND `ItemID1`=118563; -- DB=(118563, 0, 0) -> Sniff=(768, 0, 0)
UPDATE `creature_equip_template` SET `ItemID1`=2703 WHERE `CreatureID`=176192 AND `ID`=1 AND `ItemID1`=1905; -- DB=(1905, 0, 0) -> Sniff=(2703, 0, 0)
UPDATE `creature_equip_template` SET `ItemID1`=2202 WHERE `CreatureID`=176203 AND `ID`=1 AND `ItemID1`=1905; -- DB=(1905, 0, 0) -> Sniff=(2202, 0, 0)
UPDATE `creature_equip_template` SET `ItemID1`=2703 WHERE `CreatureID`=176220 AND `ID`=1 AND `ItemID1`=2202; -- DB=(2202, 0, 0) -> Sniff=(2703, 0, 0)

-- New creature spawn points: 37 (stationary, >100yd from existing)
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218766, 68, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8175.0767, 803.566, 74.15611, 4.073729038238525, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 68 AND SQRT(POW(`position_x`-(-8175.0767),2)+POW(`position_y`-(803.566),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218767, 1366, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8795.641, 771.099, 96.39687, 1.6747467517852783, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 1366 AND SQRT(POW(`position_x`-(-8795.641),2)+POW(`position_y`-(771.099),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218768, 1367, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8793.71, 771.80554, 96.39687, 1.5953067541122437, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 1367 AND SQRT(POW(`position_x`-(-8793.71),2)+POW(`position_y`-(771.80554),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218769, 1478, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8607.547, 403.30383, 102.993744, 5.410520553588867, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 1478 AND SQRT(POW(`position_x`-(-8607.547),2)+POW(`position_y`-(403.30383),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218770, 1933, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -9200.161, 353.92126, 73.71884, 0.9880269765853882, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 1933 AND SQRT(POW(`position_x`-(-9200.161),2)+POW(`position_y`-(353.92126),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218771, 2198, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8553.445, 512.00793, 98.81859, 2.078450918197632, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 2198 AND SQRT(POW(`position_x`-(-8553.445),2)+POW(`position_y`-(512.00793),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218772, 2532, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8538.7, 686.7571, 97.742935, 2.686691999435425, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 2532 AND SQRT(POW(`position_x`-(-8538.7),2)+POW(`position_y`-(686.7571),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218773, 2533, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8516.484, 661.8807, 101.96455, 2.2027268409729004, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 2533 AND SQRT(POW(`position_x`-(-8516.484),2)+POW(`position_y`-(661.8807),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218774, 3520, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8656.448, 676.9375, 108.19375, 2.3403711318969727, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 3520 AND SQRT(POW(`position_x`-(-8656.448),2)+POW(`position_y`-(676.9375),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218775, 3627, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8901.677, 833.63104, 94.037094, 5.258670330047607, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 3627 AND SQRT(POW(`position_x`-(-8901.677),2)+POW(`position_y`-(833.63104),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218776, 8666, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8667.367, 891.1595, 97.52886, 0.7343459725379944, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 8666 AND SQRT(POW(`position_x`-(-8667.367),2)+POW(`position_y`-(891.1595),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218777, 14423, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8840.07, 536.111, 100.851, 4.105103492736816, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 14423 AND SQRT(POW(`position_x`-(-8840.07),2)+POW(`position_y`-(536.111),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218778, 14438, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8959.344, 769.904, 93.84323, 5.962859630584717, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 14438 AND SQRT(POW(`position_x`-(-8959.344),2)+POW(`position_y`-(769.904),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218779, 23837, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8973.757, 841.51215, 105.60037, 5.8868608474731445, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 23837 AND SQRT(POW(`position_x`-(-8973.757),2)+POW(`position_y`-(841.51215),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218780, 32638, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8842.39, 647.5247, 97.18678, 0.5022644996643066, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 32638 AND SQRT(POW(`position_x`-(-8842.39),2)+POW(`position_y`-(647.5247),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218781, 32639, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8842.39, 647.5247, 97.18678, 0.5022644996643066, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 32639 AND SQRT(POW(`position_x`-(-8842.39),2)+POW(`position_y`-(647.5247),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218782, 38821, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8367.76, 267.592, 176.38632, 4.555309295654297, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 38821 AND SQRT(POW(`position_x`-(-8367.76),2)+POW(`position_y`-(267.592),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218783, 47688, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8425.313, 666.5909, 94.53955, 3.8523378372192383, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 47688 AND SQRT(POW(`position_x`-(-8425.313),2)+POW(`position_y`-(666.5909),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218784, 50434, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8416.883, 936.09595, 98.36789, 0.5696304440498352, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 50434 AND SQRT(POW(`position_x`-(-8416.883),2)+POW(`position_y`-(936.09595),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218785, 50435, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8417.993, 937.75806, 98.36868, 0.5867952108383179, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 50435 AND SQRT(POW(`position_x`-(-8417.993),2)+POW(`position_y`-(937.75806),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218786, 51348, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8088.2886, 845.82623, 151.49051, 4.846224784851074, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 51348 AND SQRT(POW(`position_x`-(-8088.2886),2)+POW(`position_y`-(845.82623),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218787, 61080, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8030.29, 630.6948, 81.83488, 5.569974899291992, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 61080 AND SQRT(POW(`position_x`-(-8030.29),2)+POW(`position_y`-(630.6948),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218788, 62821, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8178.288, 787.8109, 73.71654, 3.5565338134765625, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 62821 AND SQRT(POW(`position_x`-(-8178.288),2)+POW(`position_y`-(787.8109),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218789, 62822, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8178.288, 787.8109, 73.71654, 3.5565338134765625, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 62822 AND SQRT(POW(`position_x`-(-8178.288),2)+POW(`position_y`-(787.8109),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218790, 112686, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8197.805, 796.9457, 71.51122, 5.30743408203125, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 112686 AND SQRT(POW(`position_x`-(-8197.805),2)+POW(`position_y`-(796.9457),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218791, 113211, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8817.515, 896.60455, 98.88781, 3.4796438217163086, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 113211 AND SQRT(POW(`position_x`-(-8817.515),2)+POW(`position_y`-(896.60455),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218792, 121541, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8342.671, 618.4528, 99.00492, 5.795866966247559, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 121541 AND SQRT(POW(`position_x`-(-8342.671),2)+POW(`position_y`-(618.4528),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218793, 152643, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8832.819, 835.6094, 99.6364, 0.0, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 152643 AND SQRT(POW(`position_x`-(-8832.819),2)+POW(`position_y`-(835.6094),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218794, 189767, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8402.46, 1060.9219, 31.713549, 5.077036380767822, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 189767 AND SQRT(POW(`position_x`-(-8402.46),2)+POW(`position_y`-(1060.9219),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218795, 197503, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8895.489, 1295.0507, 8.805849, 2.8958566188812256, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 197503 AND SQRT(POW(`position_x`-(-8895.489),2)+POW(`position_y`-(1295.0507),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218796, 197611, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8894.133, 1291.7013, 6.183543, 2.8958566188812256, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 197611 AND SQRT(POW(`position_x`-(-8894.133),2)+POW(`position_y`-(1291.7013),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218797, 197762, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8650.152, 742.1379, 96.84901, 5.379617691040039, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 197762 AND SQRT(POW(`position_x`-(-8650.152),2)+POW(`position_y`-(742.1379),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218798, 198383, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8401.67, 1057.9601, 31.713549, 1.8659204244613647, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 198383 AND SQRT(POW(`position_x`-(-8401.67),2)+POW(`position_y`-(1057.9601),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218799, 249196, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8177.981, 421.33853, 116.91821, 3.83972430229187, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 249196 AND SQRT(POW(`position_x`-(-8177.981),2)+POW(`position_y`-(421.33853),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218800, 249197, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8180.193, 419.11633, 116.80338, 0.8028514385223389, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 249197 AND SQRT(POW(`position_x`-(-8180.193),2)+POW(`position_y`-(419.11633),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218801, 249198, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8179.3525, 417.59027, 116.83621, 1.0821040868759155, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 249198 AND SQRT(POW(`position_x`-(-8179.3525),2)+POW(`position_y`-(417.59027),2)) < 100);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnDifficulties`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curHealthPct`, `MovementType`, `VerifiedBuild`) SELECT 3000218802, 249200, 0, 0, 0, '0', 0, 0, 0, -1, 0, 0, -8176.6562, 419.51562, 116.89813, 3.2114057540893555, 120, 0, 0, 100, 0, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id` = 249200 AND SQRT(POW(`position_x`-(-8176.6562),2)+POW(`position_y`-(419.51562),2)) < 100);

-- Portal cleanup: remove old duplicates replaced by Midnight versions
DELETE FROM `gameobject` WHERE `guid`=10000994; -- Old Portal to Dornogal (452405, PhaseId=24506, build 56819) -> replaced by 620463
DELETE FROM `gameobject` WHERE `guid`=500399; -- Old Doodad_8SW_Stormwind_MagePortal001 (311875, build 41488) -> replaced by 617539

