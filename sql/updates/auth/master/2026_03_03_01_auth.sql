DELETE FROM `build_info` WHERE `build` IN (66220);
INSERT INTO `build_info` (`build`,`majorVersion`,`minorVersion`,`bugfixVersion`,`hotfixVersion`) VALUES
(66220,12,0,1,NULL);

-- Auth keys for 66220 not yet available from TrinityCore upstream.
-- WorldSocket.cpp bypass is in place (commit 787b013bc2).
-- When TC publishes keys, add build_auth_key rows here.

UPDATE `realmlist` SET `gamebuild`=66220 WHERE `gamebuild`=66198;

ALTER TABLE `realmlist` CHANGE `gamebuild` `gamebuild` int unsigned NOT NULL DEFAULT '66220';
