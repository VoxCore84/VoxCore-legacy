-- 2026_03_05_27_world.sql
-- Stormwind Wowhead scrape import — Hero's Call Board quest starters + SmartAI orphan cleanup

-- gameobject_queststarter: 28 new entries for Hero's Call Board (GO 206111)
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 27724, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=27724);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 27726, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=27726);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 27727, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=27727);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28551, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28551);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28552, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28552);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28558, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28558);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28562, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28562);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28563, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28563);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28564, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28564);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28576, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28576);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28578, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28578);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28579, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28579);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28582, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28582);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28666, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28666);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28673, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28673);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28675, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28675);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28699, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28699);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28702, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28702);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28708, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28708);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28709, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28709);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28716, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28716);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 28825, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=28825);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 29156, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=29156);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 29387, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=29387);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 29547, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=29547);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 34398, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=34398);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 36498, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=36498);
INSERT INTO `gameobject_queststarter` (`id`, `quest`, `VerifiedBuild`) SELECT 206111, 40519, 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `gameobject_queststarter` WHERE `id`=206111 AND `quest`=40519);

-- SmartAI orphan cleanup: 5 creatures with AIName='SmartAI' but no smart_scripts entries
UPDATE `creature_template` SET `AIName`='' WHERE `entry`=15214 AND `AIName`='SmartAI';
UPDATE `creature_template` SET `AIName`='' WHERE `entry`=29016 AND `AIName`='SmartAI';
UPDATE `creature_template` SET `AIName`='' WHERE `entry`=29152 AND `AIName`='SmartAI';
UPDATE `creature_template` SET `AIName`='' WHERE `entry`=140253 AND `AIName`='SmartAI';
UPDATE `creature_template` SET `AIName`='' WHERE `entry`=194437 AND `AIName`='SmartAI';
