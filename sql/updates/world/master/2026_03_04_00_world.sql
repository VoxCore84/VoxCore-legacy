-- Fix bad quest giver flags on Stormwind guards
-- Entry 68 (Stormwind City Guard): was npcflag=3 (GOSSIP|QUESTGIVER), drop QUESTGIVER, keep GOSSIP (1)
-- Entry 1976 (Stormwind City Patroller): was npcflag=3 (GOSSIP|QUESTGIVER), drop both bits (0)
UPDATE creature_template SET npcflag = 1 WHERE entry = 68;
UPDATE creature_template SET npcflag = 0 WHERE entry = 1976;
