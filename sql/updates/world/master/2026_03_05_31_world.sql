-- ============================================================================
-- Stormwind Ambient SmartAI Scripts — Round 2
-- 22 entries total, ~47 spawns affected
-- Categories: Children, Blacksmiths, Cooks/Bakers, Priests/Healers,
--             Stable Keeper, Conversation Pairs, Researchers
-- ============================================================================

-- ============================================================================
-- CATEGORY 1: CHILDREN (6 entries, 6 spawns)
-- Adam(1366) & Billy(1367) fish together at the canals
-- Justin(1368), Brandon(1370), Roman(1371) hang out together
-- William(2533) plays alone nearby
-- All already have creature_text — just need SmartAI to trigger it
-- ============================================================================

-- --- Adam (1366) — fishing with Billy, responds to Billy's stories ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=1366;
DELETE FROM smart_scripts WHERE entryorguid=1366 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(1366, 0, 0, 0, '', 11, 0, 100, 0, 0, 0, 0, 0, 0, '', 5, 92, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Adam - On Respawn - Set Emote State Use Standing (Fishing)'),
(1366, 0, 1, 0, '', 1, 0, 100, 0, 120000, 360000, 120000, 360000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Adam - OOC 2-6min - Say Line 0'),
(1366, 0, 2, 0, '', 1, 0, 30, 0, 60000, 180000, 60000, 180000, 0, '', 10, 10, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Adam - OOC 1-3min 30% - Play Emote Laugh');

-- --- Billy (1367) — fishing with Adam, tells tall tales ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=1367;
DELETE FROM smart_scripts WHERE entryorguid=1367 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(1367, 0, 0, 0, '', 11, 0, 100, 0, 0, 0, 0, 0, 0, '', 5, 92, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Billy - On Respawn - Set Emote State Use Standing (Fishing)'),
(1367, 0, 1, 0, '', 1, 0, 100, 0, 120000, 360000, 120000, 360000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Billy - OOC 2-6min - Say Line 0'),
(1367, 0, 2, 0, '', 1, 0, 20, 0, 300000, 600000, 300000, 600000, 0, '', 1, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Billy - OOC 5-10min 20% - Say Line 1 (Lets go elsewhere)'),
(1367, 0, 3, 0, '', 1, 0, 30, 0, 60000, 180000, 60000, 180000, 0, '', 10, 4, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Billy - OOC 1-3min 30% - Play Emote Cheer');

-- --- Justin (1368) — storyteller of the trio ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=1368;
DELETE FROM smart_scripts WHERE entryorguid=1368 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(1368, 0, 0, 0, '', 1, 0, 100, 0, 120000, 300000, 120000, 300000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Justin - OOC 2-5min - Say Line 0 (Tell a story)'),
(1368, 0, 1, 0, '', 1, 0, 40, 0, 60000, 120000, 60000, 120000, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Justin - OOC 1-2min 40% - Play Emote Talk'),
(1368, 0, 2, 0, '', 1, 0, 20, 0, 90000, 240000, 90000, 240000, 0, '', 10, 25, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Justin - OOC 1.5-4min 20% - Play Emote Point');

-- --- Brandon (1370) — listener, reacts to Justin's stories ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=1370;
DELETE FROM smart_scripts WHERE entryorguid=1370 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(1370, 0, 0, 0, '', 1, 0, 100, 0, 150000, 360000, 150000, 360000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Brandon - OOC 2.5-6min - Say Line 0 (React to stories)'),
(1370, 0, 1, 0, '', 1, 0, 30, 0, 60000, 180000, 60000, 180000, 0, '', 10, 10, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Brandon - OOC 1-3min 30% - Play Emote Laugh'),
(1370, 0, 2, 0, '', 1, 0, 20, 0, 90000, 240000, 90000, 240000, 0, '', 10, 4, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Brandon - OOC 1.5-4min 20% - Play Emote Cheer');

-- --- Roman (1371) — the cautious one, hears things ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=1371;
DELETE FROM smart_scripts WHERE entryorguid=1371 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(1371, 0, 0, 0, '', 1, 0, 100, 0, 150000, 360000, 150000, 360000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Roman - OOC 2.5-6min - Say Line 0 (Cautious observations)'),
(1371, 0, 1, 0, '', 1, 0, 25, 0, 60000, 180000, 60000, 180000, 0, '', 10, 26, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Roman - OOC 1-3min 25% - Play Emote Shy'),
(1371, 0, 2, 0, '', 1, 0, 20, 0, 120000, 300000, 120000, 300000, 0, '', 10, 33, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Roman - OOC 2-5min 20% - Play Emote Cry (dramatic)');

-- --- William (2533) — playing alone, chasing his gorilla toy ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=2533;
DELETE FROM smart_scripts WHERE entryorguid=2533 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(2533, 0, 0, 0, '', 1, 0, 100, 0, 90000, 300000, 90000, 300000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'William - OOC 1.5-5min - Say Line 0 (Crying about gorilla)'),
(2533, 0, 1, 0, '', 1, 0, 40, 0, 60000, 180000, 60000, 180000, 0, '', 10, 33, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'William - OOC 1-3min 40% - Play Emote Cry'),
(2533, 0, 2, 0, '', 1, 0, 20, 0, 120000, 360000, 120000, 360000, 0, '', 1, 3, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'William - OOC 2-6min 20% - Say Line 3 (WAAAHHH)');

-- Set wander_distance for children so they move around a little
UPDATE creature SET wander_distance=3, MovementType=1 WHERE guid=314222 AND id=1366; -- Adam
UPDATE creature SET wander_distance=3, MovementType=1 WHERE guid=314223 AND id=1367; -- Billy
UPDATE creature SET wander_distance=4, MovementType=1 WHERE guid=313762 AND id=1368; -- Justin
UPDATE creature SET wander_distance=4, MovementType=1 WHERE guid=313761 AND id=1370; -- Brandon
UPDATE creature SET wander_distance=4, MovementType=1 WHERE guid=313763 AND id=1371; -- Roman
UPDATE creature SET wander_distance=5, MovementType=1 WHERE guid=252244 AND id=2533; -- William


-- ============================================================================
-- CATEGORY 2: BLACKSMITHS (2 entries, 12 spawns)
-- ============================================================================

-- --- Ironforge Blastsmith (108895) — 9 spawns at the harbor construction ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=108895;
DELETE FROM smart_scripts WHERE entryorguid=108895 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(108895, 0, 0, 0, '', 11, 0, 100, 0, 0, 0, 0, 0, 0, '', 5, 273, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Ironforge Blastsmith - On Respawn - Set Emote State Work Smith'),
(108895, 0, 1, 0, '', 1, 0, 100, 0, 180000, 480000, 180000, 480000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Ironforge Blastsmith - OOC 3-8min - Say Line 0'),
(108895, 0, 2, 0, '', 22, 0, 100, 0, 101, 15000, 15000, 0, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Ironforge Blastsmith - On Receive Wave - Play Emote Talk');

DELETE FROM creature_text WHERE CreatureID=108895;
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
(108895, 0, 0, 'This iron''s got good grain. Bronzebeard stock, no doubt.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Ironforge Blastsmith'),
(108895, 0, 1, 'Steady heat, steady hammer. That''s how me da taught it.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Ironforge Blastsmith'),
(108895, 0, 2, 'Hah! Perfect fold on that one. Almost too pretty to rivet.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Ironforge Blastsmith'),
(108895, 0, 3, 'Whoever ordered steel plate this thick is expectin'' trouble.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Ironforge Blastsmith'),
(108895, 0, 4, 'Just need to quench this last piece...', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Ironforge Blastsmith'),
(108895, 0, 5, 'Could use a pint after this shift. Harbor work''s thirsty business.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Ironforge Blastsmith'),
(108895, 0, 6, 'These hull plates won''t shape themselves!', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Ironforge Blastsmith');

-- --- Dracthyr Smith (198383) — 3 spawns, Obsidian Warders ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=198383;
DELETE FROM smart_scripts WHERE entryorguid=198383 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(198383, 0, 0, 0, '', 11, 0, 100, 0, 0, 0, 0, 0, 0, '', 5, 273, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Dracthyr Smith - On Respawn - Set Emote State Work Smith'),
(198383, 0, 1, 0, '', 1, 0, 100, 0, 180000, 600000, 180000, 600000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Dracthyr Smith - OOC 3-10min - Say Line 0'),
(198383, 0, 2, 0, '', 22, 0, 100, 0, 101, 15000, 15000, 0, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Dracthyr Smith - On Receive Wave - Play Emote Talk');

DELETE FROM creature_text WHERE CreatureID=198383;
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
(198383, 0, 0, 'The forge burns hot today. Good conditions for shaping adamant.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Dracthyr Smith'),
(198383, 0, 1, 'In the Forbidden Reach, we had no choice but to craft our own weapons. Here, it is a pleasure.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Dracthyr Smith'),
(198383, 0, 2, 'Fascinating technique, this human tempering. Crude, but surprisingly effective.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Dracthyr Smith'),
(198383, 0, 3, 'Dragonfire would heat this faster, but the humans get nervous when I breathe near their forges.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Dracthyr Smith'),
(198383, 0, 4, 'Another blade finished. Neltharion would have demanded perfection. I demand it of myself.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Dracthyr Smith'),
(198383, 0, 5, 'The Alliance smiths were skeptical at first. Now they ask for tips.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Dracthyr Smith');


-- ============================================================================
-- CATEGORY 3: COOKS & BAKERS (3 entries, 3 spawns)
-- ============================================================================

-- --- Thomas Miller (3518) — Baker, already has creature_text ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=3518;
DELETE FROM smart_scripts WHERE entryorguid=3518 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(3518, 0, 0, 0, '', 11, 0, 100, 0, 0, 0, 0, 0, 0, '', 5, 274, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Thomas Miller - On Respawn - Set Emote State Work'),
(3518, 0, 1, 0, '', 1, 0, 100, 0, 120000, 300000, 120000, 300000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Thomas Miller - OOC 2-5min - Say Line 0 (Fresh bread!)'),
(3518, 0, 2, 0, '', 22, 0, 100, 0, 101, 15000, 15000, 0, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Thomas Miller - On Receive Wave - Play Emote Talk');

-- --- Connor Rivers (5081) — Apprentice Chef ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=5081;
DELETE FROM smart_scripts WHERE entryorguid=5081 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(5081, 0, 0, 0, '', 11, 0, 100, 0, 0, 0, 0, 0, 0, '', 5, 274, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Connor Rivers - On Respawn - Set Emote State Work'),
(5081, 0, 1, 0, '', 1, 0, 100, 0, 180000, 480000, 180000, 480000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Connor Rivers - OOC 3-8min - Say Line 0'),
(5081, 0, 2, 0, '', 1, 0, 30, 0, 60000, 180000, 60000, 180000, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Connor Rivers - OOC 1-3min 30% - Play Emote Talk');

DELETE FROM creature_text WHERE CreatureID=5081;
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
(5081, 0, 0, 'Hmm, needs more seasoning... I think.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Connor Rivers'),
(5081, 0, 1, 'Chef Angus says presentation is half the meal. The other half is not burning it.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Connor Rivers'),
(5081, 0, 2, 'One day I''ll have my own inn. Connor''s Kitchen... no, that''s terrible.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Connor Rivers'),
(5081, 0, 3, 'Stir, don''t stab, stir, don''t stab... there we go.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Connor Rivers'),
(5081, 0, 4, 'I wonder if Pandaren spices would work in boar stew...', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Connor Rivers'),
(5081, 0, 5, 'The trick to a good broth is patience. And not letting it boil over. Again.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Connor Rivers');

-- --- Kendor Kabonka (340) — Master of Cooking Recipes (vendor, but add personality) ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=340;
DELETE FROM smart_scripts WHERE entryorguid=340 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(340, 0, 0, 0, '', 1, 0, 100, 0, 240000, 600000, 240000, 600000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Kendor Kabonka - OOC 4-10min - Say Line 0'),
(340, 0, 1, 0, '', 1, 0, 30, 0, 120000, 300000, 120000, 300000, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Kendor Kabonka - OOC 2-5min 30% - Play Emote Talk');

DELETE FROM creature_text WHERE CreatureID=340;
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
(340, 0, 0, 'I have recipes from every corner of Azeroth! Well, most corners. I''m working on it.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Kendor Kabonka'),
(340, 0, 1, 'Fifty years behind the stove and I still learn something new every season.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Kendor Kabonka'),
(340, 0, 2, 'You haven''t lived until you''ve tasted Westfall stew made with fresh thyme.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Kendor Kabonka'),
(340, 0, 3, 'The secret to a good recipe? Knowing when to follow it and when to improvise.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Kendor Kabonka'),
(340, 0, 4, 'A dwarf once traded me a recipe for Dark Iron stout cake. Worth every copper.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Kendor Kabonka');


-- ============================================================================
-- CATEGORY 4: PRIESTS & HEALERS (3 entries, 6 spawns)
-- ============================================================================

-- --- Stormwind Priest (141508) — 4 spawns near wounded refugees, healing/tending ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=141508;
DELETE FROM smart_scripts WHERE entryorguid=141508 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(141508, 0, 0, 0, '', 11, 0, 100, 0, 0, 0, 0, 0, 0, '', 5, 28, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Stormwind Priest - On Respawn - Set Emote State Kneel'),
(141508, 0, 1, 0, '', 1, 0, 100, 0, 180000, 420000, 180000, 420000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Stormwind Priest - OOC 3-7min - Say Line 0'),
(141508, 0, 2, 0, '', 1, 0, 40, 0, 90000, 240000, 90000, 240000, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Stormwind Priest - OOC 1.5-4min 40% - Play Emote Talk');

DELETE FROM creature_text WHERE CreatureID=141508;
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
(141508, 0, 0, 'The Light will mend you. Be still.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Stormwind Priest'),
(141508, 0, 1, 'Rest now. You are safe within these walls.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Stormwind Priest'),
(141508, 0, 2, 'By the grace of the Light, your wounds will heal.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Stormwind Priest'),
(141508, 0, 3, 'Drink this. It will ease the pain.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Stormwind Priest'),
(141508, 0, 4, 'Teldrassil may be lost, but your spirit endures.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Stormwind Priest'),
(141508, 0, 5, 'There now... the fever is breaking. You''ll be all right.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Stormwind Priest');

-- --- Bishop Farthing (1212) — 1 spawn, pious leader ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=1212;
DELETE FROM smart_scripts WHERE entryorguid=1212 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(1212, 0, 0, 0, '', 1, 0, 100, 0, 240000, 600000, 240000, 600000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Bishop Farthing - OOC 4-10min - Say Line 0'),
(1212, 0, 1, 0, '', 1, 0, 30, 0, 120000, 360000, 120000, 360000, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Bishop Farthing - OOC 2-6min 30% - Play Emote Talk'),
(1212, 0, 2, 0, '', 22, 0, 100, 0, 17, 15000, 15000, 0, 0, '', 10, 2, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Bishop Farthing - On Receive Bow - Play Emote Bow');

DELETE FROM creature_text WHERE CreatureID=1212;
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
(1212, 0, 0, 'The Light watches over Stormwind. Of this, I am certain.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Bishop Farthing'),
(1212, 0, 1, 'In these troubled times, faith is our greatest shield.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Bishop Farthing'),
(1212, 0, 2, 'The Cathedral stands as it always has. A beacon for the faithful.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Bishop Farthing'),
(1212, 0, 3, 'May the Light grant us the wisdom to weather what lies ahead.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Bishop Farthing'),
(1212, 0, 4, 'We must tend to the refugees. Their need is great.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Bishop Farthing');

-- --- Brother Benjamin (5484) — Priest Trainer, 1 spawn ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=5484;
DELETE FROM smart_scripts WHERE entryorguid=5484 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(5484, 0, 0, 0, '', 1, 0, 100, 0, 240000, 600000, 240000, 600000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Brother Benjamin - OOC 4-10min - Say Line 0'),
(5484, 0, 1, 0, '', 1, 0, 25, 0, 90000, 300000, 90000, 300000, 0, '', 10, 28, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Brother Benjamin - OOC 1.5-5min 25% - Play Emote Kneel (Praying)'),
(5484, 0, 2, 0, '', 22, 0, 100, 0, 17, 15000, 15000, 0, 0, '', 10, 2, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Brother Benjamin - On Receive Bow - Play Emote Bow');

DELETE FROM creature_text WHERE CreatureID=5484;
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
(5484, 0, 0, 'The path of the Light is not an easy one, but it is always rewarding.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Brother Benjamin'),
(5484, 0, 1, 'To heal is to serve. To serve is to know the Light.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Brother Benjamin'),
(5484, 0, 2, 'Prayer and discipline. The foundations of all who channel the Light.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Brother Benjamin'),
(5484, 0, 3, 'Even in darkness, a single candle can illuminate the way.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Brother Benjamin');


-- ============================================================================
-- CATEGORY 5: STABLE KEEPER (1 entry, 1 spawn)
-- ============================================================================

-- --- Valarian (198579) — Stable Keeper, near the stables ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=198579;
DELETE FROM smart_scripts WHERE entryorguid=198579 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(198579, 0, 0, 0, '', 1, 0, 100, 0, 180000, 480000, 180000, 480000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Valarian - OOC 3-8min - Say Line 0'),
(198579, 0, 1, 0, '', 1, 0, 30, 0, 90000, 240000, 90000, 240000, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Valarian - OOC 1.5-4min 30% - Play Emote Talk'),
(198579, 0, 2, 0, '', 22, 0, 100, 0, 101, 15000, 15000, 0, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Valarian - On Receive Wave - Play Emote Talk');

DELETE FROM creature_text WHERE CreatureID=198579;
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
(198579, 0, 0, 'Easy there, girl. You''ll get your oats soon enough.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Valarian'),
(198579, 0, 1, 'These mounts have seen more battles than most soldiers. They deserve proper care.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Valarian'),
(198579, 0, 2, 'A well-groomed steed is a loyal companion on any road.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Valarian'),
(198579, 0, 3, 'The horses get restless before a storm. Must be one coming.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Valarian'),
(198579, 0, 4, 'Good hay, clean water, and a kind hand. That''s all they ask for.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Valarian'),
(198579, 0, 5, 'Shhh, steady now... that''s it.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Valarian');


-- ============================================================================
-- CATEGORY 6: CONVERSATION PAIRS (4 entries, 4 spawns)
-- Uses timed action lists (source_type=9) for synchronized dialogue
-- ============================================================================

-- ---- PAIR A: Harriet Mura (176234) & Anna Taki (176231) ----
-- Two women chatting in the Trade District
-- Harriet initiates the conversation via action list

UPDATE creature_template SET AIName='SmartAI' WHERE entry=176234;
UPDATE creature_template SET AIName='SmartAI' WHERE entry=176231;

DELETE FROM smart_scripts WHERE entryorguid=176234 AND source_type=0;
DELETE FROM smart_scripts WHERE entryorguid=176231 AND source_type=0;
DELETE FROM smart_scripts WHERE entryorguid IN (17623400, 17623401) AND source_type=9;

-- Harriet Mura: triggers timed action list conversations periodically
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(176234, 0, 0, 0, '', 1, 0, 100, 0, 300000, 600000, 300000, 600000, 0, '', 80, 17623400, 17623401, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Harriet Mura - OOC 5-10min - Run Random Action List'),
(176234, 0, 1, 0, '', 1, 0, 30, 0, 90000, 240000, 90000, 240000, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Harriet Mura - OOC 1.5-4min 30% - Play Emote Talk');

-- Anna Taki: ambient emotes between conversations
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(176231, 0, 0, 0, '', 1, 0, 30, 0, 120000, 300000, 120000, 300000, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Anna Taki - OOC 2-5min 30% - Play Emote Talk'),
(176231, 0, 1, 0, '', 1, 0, 20, 0, 180000, 420000, 180000, 420000, 0, '', 10, 10, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Anna Taki - OOC 3-7min 20% - Play Emote Laugh');

-- Action List: Conversation about the market
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(17623400, 9, 0, 0, '', 0, 0, 100, 0, 0, 0, 0, 0, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Harriet Mura - Action List - Say Line 0'),
(17623400, 9, 1, 0, '', 0, 0, 100, 0, 5000, 0, 0, 0, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 19, 176231, 0, 0, 0, NULL, 0, 0, 0, 0, 'Harriet Mura - Action List - Anna Taki Say Line 0'),
(17623400, 9, 2, 0, '', 0, 0, 100, 0, 6000, 0, 0, 0, 0, '', 1, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Harriet Mura - Action List - Say Line 1'),
(17623400, 9, 3, 0, '', 0, 0, 100, 0, 5000, 0, 0, 0, 0, '', 1, 1, 0, 0, 0, 0, 0, 0, NULL, 19, 176231, 0, 0, 0, NULL, 0, 0, 0, 0, 'Harriet Mura - Action List - Anna Taki Say Line 1');

-- Action List: Conversation about the refugees
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(17623401, 9, 0, 0, '', 0, 0, 100, 0, 0, 0, 0, 0, 0, '', 1, 2, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Harriet Mura - Action List 2 - Say Line 2'),
(17623401, 9, 1, 0, '', 0, 0, 100, 0, 6000, 0, 0, 0, 0, '', 1, 2, 0, 0, 0, 0, 0, 0, NULL, 19, 176231, 0, 0, 0, NULL, 0, 0, 0, 0, 'Harriet Mura - Action List 2 - Anna Taki Say Line 2'),
(17623401, 9, 2, 0, '', 0, 0, 100, 0, 5000, 0, 0, 0, 0, '', 1, 3, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Harriet Mura - Action List 2 - Say Line 3');

DELETE FROM creature_text WHERE CreatureID IN (176234, 176231);
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
-- Harriet Mura
(176234, 0, 0, 'Have you seen the prices at the Auction House lately? Outrageous!', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'Harriet Mura - Market chat 1'),
(176234, 1, 0, 'I heard the Gilnean merchants are setting up shop near the canals.', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'Harriet Mura - Market chat 2'),
(176234, 2, 0, 'Those poor night elf refugees. Losing their home like that...', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Harriet Mura - Refugee chat 1'),
(176234, 3, 0, 'The Cathedral has been doing what it can. We all should help where we''re able.', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'Harriet Mura - Refugee chat 2'),
-- Anna Taki
(176231, 0, 0, 'Tell me about it! A simple linen bolt cost me three gold yesterday.', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'Anna Taki - Market reply 1'),
(176231, 1, 0, 'That''s good news. Competition keeps the prices honest, I say.', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'Anna Taki - Market reply 2'),
(176231, 2, 0, 'I know. My neighbor took in a family of three. They have almost nothing.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Anna Taki - Refugee reply');


-- ---- PAIR B: Chris Miller (50525) & Kyle Radue (50523) ----
-- Two men hanging out in the city, near the canals

UPDATE creature_template SET AIName='SmartAI' WHERE entry=50525;
UPDATE creature_template SET AIName='SmartAI' WHERE entry=50523;

DELETE FROM smart_scripts WHERE entryorguid=50525 AND source_type=0;
DELETE FROM smart_scripts WHERE entryorguid=50523 AND source_type=0;
DELETE FROM smart_scripts WHERE entryorguid IN (5052500, 5052501) AND source_type=9;

-- Chris Miller: initiates conversations
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(50525, 0, 0, 0, '', 1, 0, 100, 0, 300000, 600000, 300000, 600000, 0, '', 80, 5052500, 5052501, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Chris Miller - OOC 5-10min - Run Random Action List'),
(50525, 0, 1, 0, '', 1, 0, 25, 0, 90000, 240000, 90000, 240000, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Chris Miller - OOC 1.5-4min 25% - Play Emote Talk');

-- Kyle Radue: ambient
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(50523, 0, 0, 0, '', 1, 0, 25, 0, 120000, 300000, 120000, 300000, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Kyle Radue - OOC 2-5min 25% - Play Emote Talk'),
(50523, 0, 1, 0, '', 1, 0, 15, 0, 180000, 420000, 180000, 420000, 0, '', 10, 10, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Kyle Radue - OOC 3-7min 15% - Play Emote Laugh');

-- Action List: Conversation about life in Stormwind
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(5052500, 9, 0, 0, '', 0, 0, 100, 0, 0, 0, 0, 0, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Chris Miller - Action List - Say Line 0'),
(5052500, 9, 1, 0, '', 0, 0, 100, 0, 5000, 0, 0, 0, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 19, 50523, 0, 0, 0, NULL, 0, 0, 0, 0, 'Chris Miller - Action List - Kyle Radue Say Line 0'),
(5052500, 9, 2, 0, '', 0, 0, 100, 0, 6000, 0, 0, 0, 0, '', 1, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Chris Miller - Action List - Say Line 1'),
(5052500, 9, 3, 0, '', 0, 0, 100, 0, 5000, 0, 0, 0, 0, '', 1, 1, 0, 0, 0, 0, 0, 0, NULL, 19, 50523, 0, 0, 0, NULL, 0, 0, 0, 0, 'Chris Miller - Action List - Kyle Radue Say Line 1');

-- Action List: Conversation about adventures
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(5052501, 9, 0, 0, '', 0, 0, 100, 0, 0, 0, 0, 0, 0, '', 1, 2, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Chris Miller - Action List 2 - Say Line 2'),
(5052501, 9, 1, 0, '', 0, 0, 100, 0, 6000, 0, 0, 0, 0, '', 1, 2, 0, 0, 0, 0, 0, 0, NULL, 19, 50523, 0, 0, 0, NULL, 0, 0, 0, 0, 'Chris Miller - Action List 2 - Kyle Radue Say Line 2'),
(5052501, 9, 2, 0, '', 0, 0, 100, 0, 5000, 0, 0, 0, 0, '', 1, 3, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Chris Miller - Action List 2 - Say Line 3'),
(5052501, 9, 3, 0, '', 0, 0, 100, 0, 6000, 0, 0, 0, 0, '', 1, 3, 0, 0, 0, 0, 0, 0, NULL, 19, 50523, 0, 0, 0, NULL, 0, 0, 0, 0, 'Chris Miller - Action List 2 - Kyle Radue Say Line 3');

DELETE FROM creature_text WHERE CreatureID IN (50525, 50523);
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
-- Chris Miller
(50525, 0, 0, 'You know what I could go for right now? A pint at the Pig and Whistle.', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'Chris Miller - City life 1'),
(50525, 1, 0, 'My wife wants to move to Goldshire. Says the city is too crowded now.', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'Chris Miller - City life 2'),
(50525, 2, 0, 'Did you hear? Some adventurer cleared out the Deadmines again. Third time this month.', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'Chris Miller - Adventures 1'),
(50525, 3, 0, 'I tell you, Kyle, sometimes I wonder what it would be like to just... go. See the world.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Chris Miller - Adventures 2'),
-- Kyle Radue
(50523, 0, 0, 'Now you''re talking. Reese brews the best stout this side of Ironforge.', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'Kyle Radue - City life reply 1'),
(50523, 1, 0, 'Goldshire? With the gnolls? Rather take my chances with the crowds.', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'Kyle Radue - City life reply 2'),
(50523, 2, 0, 'Those Defias types never learn. You''d think they''d find a new hideout by now.', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'Kyle Radue - Adventures reply 1'),
(50523, 3, 0, 'And get eaten by a dragon? No thanks. I''ll stick to the canals, where it''s safe.', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'Kyle Radue - Adventures reply 2');


-- ============================================================================
-- CATEGORY 7: RESEARCHERS & EXPLORERS (2 entries, 12 spawns)
-- Near the harbor expedition area
-- ============================================================================

-- --- Brave Researcher (187193) — 6 spawns, studying expedition findings ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=187193;
DELETE FROM smart_scripts WHERE entryorguid=187193 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(187193, 0, 0, 0, '', 1, 0, 100, 0, 180000, 480000, 180000, 480000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Brave Researcher - OOC 3-8min - Say Line 0'),
(187193, 0, 1, 0, '', 1, 0, 30, 0, 60000, 180000, 60000, 180000, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Brave Researcher - OOC 1-3min 30% - Play Emote Talk'),
(187193, 0, 2, 0, '', 1, 0, 20, 0, 90000, 300000, 90000, 300000, 0, '', 10, 25, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Brave Researcher - OOC 1.5-5min 20% - Play Emote Point');

DELETE FROM creature_text WHERE CreatureID=187193;
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
(187193, 0, 0, 'These Dragon Isles samples are unlike anything in our archives.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Brave Researcher'),
(187193, 0, 1, 'If my calculations are correct, this artifact predates the Sundering.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Brave Researcher'),
(187193, 0, 2, 'Fascinating. The crystalline structure matches nothing in known geology.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Brave Researcher'),
(187193, 0, 3, 'I need more ink. And more parchment. And possibly more coffee.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Brave Researcher'),
(187193, 0, 4, 'The expedition reports mention a proto-drake nesting ground. We must study it further.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Brave Researcher'),
(187193, 0, 5, 'Cross-referencing with the Explorers'' League records... ah, there it is.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Brave Researcher');

-- --- Cataloguing Enthusiast (193786) — 6 spawns, excitable researcher ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=193786;
DELETE FROM smart_scripts WHERE entryorguid=193786 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(193786, 0, 0, 0, '', 1, 0, 100, 0, 180000, 480000, 180000, 480000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Cataloguing Enthusiast - OOC 3-8min - Say Line 0'),
(193786, 0, 1, 0, '', 1, 0, 25, 0, 60000, 180000, 60000, 180000, 0, '', 10, 4, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Cataloguing Enthusiast - OOC 1-3min 25% - Play Emote Cheer'),
(193786, 0, 2, 0, '', 1, 0, 30, 0, 90000, 240000, 90000, 240000, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Cataloguing Enthusiast - OOC 1.5-4min 30% - Play Emote Talk');

DELETE FROM creature_text WHERE CreatureID=193786;
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
(193786, 0, 0, 'Oh! Item seven hundred and twelve! A fossilized... hmm, what IS this?', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Cataloguing Enthusiast'),
(193786, 0, 1, 'Must categorize, must catalogue, must... ooh, is that a new specimen?!', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Cataloguing Enthusiast'),
(193786, 0, 2, 'The Explorers'' League will be thrilled when they see my notes!', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Cataloguing Enthusiast'),
(193786, 0, 3, 'Genus: unknown. Species: unknown. Excitement level: VERY HIGH.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Cataloguing Enthusiast'),
(193786, 0, 4, 'I''ve catalogued three hundred items today and I''m just getting started!', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Cataloguing Enthusiast'),
(193786, 0, 5, 'Now where did I put ledger number nine... ah, I''m sitting on it.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Cataloguing Enthusiast');


-- ============================================================================
-- CATEGORY 8: ADDITIONAL AMBIENT NPCS
-- ============================================================================

-- --- Attentive Child (151249) — near the Mage Tower, watching Jordan Meier ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=151249;
DELETE FROM smart_scripts WHERE entryorguid=151249 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(151249, 0, 0, 0, '', 1, 0, 100, 0, 180000, 480000, 180000, 480000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Attentive Child - OOC 3-8min - Say Line 0'),
(151249, 0, 1, 0, '', 1, 0, 30, 0, 60000, 180000, 60000, 180000, 0, '', 10, 4, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Attentive Child - OOC 1-3min 30% - Play Emote Cheer'),
(151249, 0, 2, 0, '', 1, 0, 20, 0, 120000, 300000, 120000, 300000, 0, '', 10, 10, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Attentive Child - OOC 2-5min 20% - Play Emote Laugh');

DELETE FROM creature_text WHERE CreatureID=151249;
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
(151249, 0, 0, 'Do it again! Do it again!', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Attentive Child'),
(151249, 0, 1, 'Wow! I wanna be a mage when I grow up!', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Attentive Child'),
(151249, 0, 2, 'Can you make a dragon?! Please?!', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Attentive Child'),
(151249, 0, 3, 'How do you make the sparkly lights?', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Attentive Child');

-- --- Jordan Meier (151251) — near Mage Tower, performing magic for children ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=151251;
DELETE FROM smart_scripts WHERE entryorguid=151251 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(151251, 0, 0, 0, '', 1, 0, 100, 0, 180000, 480000, 180000, 480000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Jordan Meier - OOC 3-8min - Say Line 0'),
(151251, 0, 1, 0, '', 1, 0, 30, 0, 60000, 180000, 60000, 180000, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Jordan Meier - OOC 1-3min 30% - Play Emote Talk'),
(151251, 0, 2, 0, '', 22, 0, 100, 0, 101, 15000, 15000, 0, 0, '', 10, 2, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Jordan Meier - On Receive Wave - Play Emote Bow');

DELETE FROM creature_text WHERE CreatureID=151251;
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
(151251, 0, 0, 'Watch closely now... nothing up my sleeve...', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'Jordan Meier'),
(151251, 0, 1, 'And for my next trick, a conjured butterfly!', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'Jordan Meier'),
(151251, 0, 2, 'The arcane arts aren''t just for battle. Sometimes, they''re for wonder.', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'Jordan Meier'),
(151251, 0, 3, 'Every great mage started by watching someone else make sparks.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Jordan Meier');

-- --- Shauna Strattonmeier (151247) — Librarian near the Mage Tower ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=151247;
DELETE FROM smart_scripts WHERE entryorguid=151247 AND source_type=0;
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(151247, 0, 0, 0, '', 1, 0, 100, 0, 240000, 600000, 240000, 600000, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Shauna Strattonmeier - OOC 4-10min - Say Line 0'),
(151247, 0, 1, 0, '', 1, 0, 20, 0, 90000, 300000, 90000, 300000, 0, '', 10, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Shauna Strattonmeier - OOC 1.5-5min 20% - Play Emote Talk');

DELETE FROM creature_text WHERE CreatureID=151247;
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
(151247, 0, 0, 'Please keep your voices down. This is a place of study.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Shauna Strattonmeier'),
(151247, 0, 1, 'I have a new shipment of tomes from Dalaran. Quite fascinating.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Shauna Strattonmeier'),
(151247, 0, 2, 'The history section is particularly comprehensive. Five Ages of Azeroth, all documented.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Shauna Strattonmeier'),
(151247, 0, 3, 'Books are the foundation of knowledge. Well, books and not setting them on fire.', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Shauna Strattonmeier');

-- --- SI:7 Agent (198885) & Defias Thief (198886) — interrogation scene ---
UPDATE creature_template SET AIName='SmartAI' WHERE entry=198885;
UPDATE creature_template SET AIName='SmartAI' WHERE entry=198886;

DELETE FROM smart_scripts WHERE entryorguid=198885 AND source_type=0;
DELETE FROM smart_scripts WHERE entryorguid=198886 AND source_type=0;
DELETE FROM smart_scripts WHERE entryorguid IN (19888500, 19888501) AND source_type=9;

-- SI:7 Agent: triggers interrogation conversations
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(198885, 0, 0, 0, '', 1, 0, 100, 0, 300000, 600000, 300000, 600000, 0, '', 80, 19888500, 19888501, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'SI:7 Agent - OOC 5-10min - Run Random Action List'),
(198885, 0, 1, 0, '', 11, 0, 100, 0, 0, 0, 0, 0, 0, '', 5, 381, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'SI:7 Agent - On Respawn - Set Emote State Stand Guard');

-- Defias Thief: cowering
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(198886, 0, 0, 0, '', 11, 0, 100, 0, 0, 0, 0, 0, 0, '', 5, 28, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Defias Thief - On Respawn - Set Emote State Kneel'),
(198886, 0, 1, 0, '', 1, 0, 30, 0, 120000, 360000, 120000, 360000, 0, '', 10, 26, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'Defias Thief - OOC 2-6min 30% - Play Emote Shy (Cower)');

-- Action List: Interrogation about the Brotherhood
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(19888500, 9, 0, 0, '', 0, 0, 100, 0, 0, 0, 0, 0, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'SI:7 Agent - Action List - Say Line 0'),
(19888500, 9, 1, 0, '', 0, 0, 100, 0, 5000, 0, 0, 0, 0, '', 1, 0, 0, 0, 0, 0, 0, 0, NULL, 19, 198886, 0, 0, 0, NULL, 0, 0, 0, 0, 'SI:7 Agent - Action List - Defias Thief Say Line 0'),
(19888500, 9, 2, 0, '', 0, 0, 100, 0, 5000, 0, 0, 0, 0, '', 1, 1, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'SI:7 Agent - Action List - Say Line 1');

-- Action List: Threatening
INSERT INTO smart_scripts (entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, event_param5, event_param_string, action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6, action_param7, action_param_string, target_type, target_param1, target_param2, target_param3, target_param4, target_param_string, target_x, target_y, target_z, target_o, comment) VALUES
(19888501, 9, 0, 0, '', 0, 0, 100, 0, 0, 0, 0, 0, 0, '', 1, 2, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'SI:7 Agent - Action List 2 - Say Line 2'),
(19888501, 9, 1, 0, '', 0, 0, 100, 0, 5000, 0, 0, 0, 0, '', 1, 1, 0, 0, 0, 0, 0, 0, NULL, 19, 198886, 0, 0, 0, NULL, 0, 0, 0, 0, 'SI:7 Agent - Action List 2 - Defias Thief Say Line 1'),
(19888501, 9, 2, 0, '', 0, 0, 100, 0, 5000, 0, 0, 0, 0, '', 1, 3, 0, 0, 0, 0, 0, 0, NULL, 1, 0, 0, 0, 0, NULL, 0, 0, 0, 0, 'SI:7 Agent - Action List 2 - Say Line 3');

DELETE FROM creature_text WHERE CreatureID IN (198885, 198886);
INSERT INTO creature_text (CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, SoundPlayType, BroadcastTextId, TextRange, comment) VALUES
-- SI:7 Agent
(198885, 0, 0, 'Talk. Who''s running the Brotherhood now?', 12, 0, 100, 25, 0, 0, 0, 0, 0, 'SI:7 Agent - Interrogation 1'),
(198885, 1, 0, 'Shaw wants answers by sundown. I suggest you cooperate.', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'SI:7 Agent - Interrogation 2'),
(198885, 2, 0, 'We found the safehouse in Moonbrook. Your friends already talked.', 12, 0, 100, 25, 0, 0, 0, 0, 0, 'SI:7 Agent - Threat 1'),
(198885, 3, 0, 'Last chance. The Stockade isn''t known for its hospitality.', 12, 0, 100, 1, 0, 0, 0, 0, 0, 'SI:7 Agent - Threat 2'),
-- Defias Thief
(198886, 0, 0, 'I... I don''t know anything! I was just a lookout!', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Defias Thief - Plea 1'),
(198886, 1, 0, 'Please... I have a family in Westfall. I was desperate for coin!', 12, 0, 100, 0, 0, 0, 0, 0, 0, 'Defias Thief - Plea 2');


-- ============================================================================
-- Done! 22 entries total:
-- Children:     1366, 1367, 1368, 1370, 1371, 2533 (6 spawns)
-- Blacksmiths:  108895, 198383 (12 spawns)
-- Cooks/Bakers: 3518, 5081, 340 (3 spawns)
-- Priests:      141508, 1212, 5484 (6 spawns)
-- Stable:       198579 (1 spawn)
-- Conv. Pairs:  176234+176231, 50525+50523, 198885+198886 (6 spawns)
-- Researchers:  187193, 193786 (12 spawns)
-- Mage Tower:   151249, 151251, 151247 (3 spawns)
-- ============================================================================
