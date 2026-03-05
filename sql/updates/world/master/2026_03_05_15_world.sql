-- 2026_03_05_15_world.sql
-- Midnight expansion data import — quest starters/enders, NPC loot, boss abilities
-- Source: wowhead_guides/ + wowhead_entities/ (624 pages, 44 MB)

-- creature_queststarter: 58 new entries
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (231472,40710);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (130919,48962);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (126301,48962);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (130133,49354);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (126321,49787);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (126301,49787);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (145005,53735);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (145005,53736);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (145005,53737);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (145015,53882);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (144773,54058);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (145793,54096);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (231891,84779);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (231891,84782);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (230321,84784);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (231702,85027);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (232441,85027);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (231702,85028);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (231702,85029);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (234616,85252);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (234616,85254);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (233752,85862);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (236114,85884);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (236114,85885);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (235386,86543);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (237508,86832);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (237601,86842);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (245186,86846);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (241130,86896);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (241553,89383);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (241553,89385);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (241928,89507);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (257633,89507);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (256867,89560);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (242014,89565);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (242358,90467);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (242688,90544);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (245297,90822);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (246727,91382);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (248015,91694);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (248250,91726);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (237502,91787);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (250402,92321);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (248153,92630);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (257544,92630);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (259941,92630);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (259951,92630);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (252617,92632);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (241629,92732);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (253105,92739);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (253312,92864);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (253312,92866);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (246231,92926);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (253513,93086);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (244521,93575);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (255822,93651);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (256875,93850);
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES (257426,94388);

-- creature_questender: 60 new entries
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (231891,40710);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (126301,48962);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (126332,48962);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (234616,48962);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (130133,49354);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (145005,53735);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (145005,53736);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (145005,53737);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (231891,53763);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (145005,53882);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (16802,54096);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (231891,84371);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (231891,84779);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (230321,84782);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (231891,84789);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (231702,85027);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (232441,85028);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (231702,85029);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (232441,85036);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (234616,85252);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (234616,85254);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (233804,85862);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (233811,85875);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (236114,85878);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (236114,85884);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (236114,85885);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (241130,86887);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (241130,86891);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (237502,86903);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (237565,89193);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (241553,89383);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (241553,89385);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (241928,89507);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (248658,89507);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (257632,89507);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (257633,89507);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (242014,89560);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (247424,89565);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (242689,90467);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (242688,90544);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (235850,90822);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (244446,90822);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (245186,91000);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (246727,91382);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (257130,91694);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (257132,91694);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (248250,91726);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (250402,92321);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (254266,92630);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (254748,92632);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (253087,92732);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (241629,92739);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (253312,92864);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (253312,92866);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (253513,92926);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (246231,93086);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (244521,93575);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (255828,93651);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (256875,93850);
INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES (240403,94388);

-- creature_loot_template: 819 new entries across 115 NPCs
-- NPC 19554: 19 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,24645,1.0,0,1,0,1,1,'Astralaan Belt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,24665,1.0,0,1,0,1,1,'Shadow Council Cowl');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,24674,1.0,0,1,0,1,1,'Eldr''naan Pants');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,24870,1.0,0,1,0,1,1,'Ironspine Belt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,24875,1.0,0,1,0,1,1,'Ironspine Legguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,24890,1.0,0,1,0,1,1,'Skettis Helmet');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,24991,1.0,0,1,0,1,1,'Warmaul Greaves');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,25000,1.0,0,1,0,1,1,'Bloodfist Breastplate');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,25005,1.0,0,1,0,1,1,'Bloodfist Vambraces');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,25039,1.0,0,1,0,1,1,'Farseer Cloak');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,25056,1.0,0,1,0,1,1,'Almandine Ring');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,25223,1.0,0,1,0,1,1,'Windcaller Hatchet');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,25305,1.0,0,1,0,1,1,'Elemental Dagger');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,25307,1.0,0,1,0,1,1,'Shadow Dagger');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,25342,5.0,0,1,0,1,1,'Dilapidated Cloth Boots');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,25347,5.0,0,1,0,1,1,'Dilapidated Cloth Shoulderpads');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,25379,5.0,0,1,0,1,1,'Corroded Mail Pants');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,25391,5.0,0,1,0,1,1,'Deteriorating Plate Bracers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (19554,0,25399,5.0,0,1,0,1,1,'Deteriorating Blade');
-- NPC 36477: 1 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (36477,0,252421,1.0,0,1,0,1,1,'Rotting Globule');
-- NPC 36658: 1 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (36658,0,267007,1.0,0,1,0,1,1,'Eye of Acherus');
-- NPC 75964: 5 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (75964,0,258046,1.0,0,1,0,1,1,'Chakram-Breaker Greatsword');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (75964,0,258218,1.0,0,1,0,1,1,'Skybreaker''s Blade');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (75964,0,258412,1.0,0,1,0,1,1,'Stormshaper''s Crossbow');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (75964,0,258574,1.0,0,1,0,1,1,'Legwraps of Swirling Light');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (75964,0,258575,1.0,0,1,0,1,1,'Rigid Scale Greatcloak');
-- NPC 76141: 7 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76141,0,252418,1.0,0,1,0,1,1,'Solar Core Igniter');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76141,0,258047,1.0,0,1,0,1,1,'Spire of the Furious Construct');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76141,0,258436,1.0,0,1,0,1,1,'Edge of the Burning Sun');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76141,0,258576,1.0,0,1,0,1,1,'Sharpeye Chestguard');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76141,0,258577,1.0,0,1,0,1,1,'Boots of Burning Focus');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76141,0,258578,1.0,0,1,0,1,1,'Lightbinder Shoulderguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76141,0,258579,1.0,0,1,0,1,1,'Gutcrusher Greathelm');
-- NPC 76266: 14 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76266,0,112238,1.0,0,1,0,1,1,'Toothbreaker Ring');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76266,0,112239,1.0,0,1,0,1,1,'Seal of Resounding Stalwarts');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76266,0,112240,1.0,0,1,0,1,1,'Iron Wolf Signet');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76266,0,112241,1.0,0,1,0,1,1,'Signet of the Meditative Mind');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76266,0,112242,1.0,0,1,0,1,1,'Band of Bubbly Brews');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76266,0,252420,1.0,0,1,0,1,1,'Solarflare Prism');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76266,0,258049,1.0,0,1,0,1,1,'Viryx''s Indomitable Bulwark');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76266,0,258050,1.0,0,1,0,1,1,'Arcanic of the High Sage');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76266,0,258484,1.0,0,1,0,1,1,'Sunlance of Viryx');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76266,0,258584,1.0,0,1,0,1,1,'Lightbinder Treads');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76266,0,258585,1.0,0,1,0,1,1,'Sharpeye Gleam');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76266,0,258586,1.0,0,1,0,1,1,'Bloodfeather Chestguard');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76266,0,258587,1.0,0,1,0,1,1,'Spaulders of Scorching Ray');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76266,0,258744,1.0,0,1,0,1,1,'Skyreach Circular Table');
-- NPC 76379: 8 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76379,0,252411,1.0,0,1,0,1,1,'Radiant Sunstone');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76379,0,258048,1.0,0,1,0,1,1,'Beakbreaker Scimitar');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76379,0,258438,1.0,0,1,0,1,1,'Blazing Sunclaws');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76379,0,258472,1.0,0,1,0,1,1,'Rukhran''s Solar Reliquary');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76379,0,258580,1.0,0,1,0,1,1,'Bracers of Blazing Light');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76379,0,258581,1.0,0,1,0,1,1,'Bloodfeather Mantle');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76379,0,258582,1.0,0,1,0,1,1,'Rigid Scale Boots');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (76379,0,258583,1.0,0,1,0,1,1,'Incarnadine Gauntlets');
-- NPC 122313: 8 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122313,0,213015,1.0,0,1,0,1,1,'Grimoire of the Eredathian Darkglare');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122313,0,240610,1.0,0,1,0,1,1,'Doomsinger''s Drape');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122313,0,245925,1.0,0,1,0,1,1,'Artifactium Sand');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122313,0,245998,1.0,0,1,0,1,1,'Ring of Mind Shielding');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122313,0,246196,1.0,0,1,0,1,1,'Erratically Ticking Talisman');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122313,0,246201,1.0,0,1,0,1,1,'Signet of the Highborne Magi');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122313,0,246207,1.0,0,1,0,1,1,'Glimmering Soulbloom');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122313,0,258514,1.0,0,1,0,1,1,'Umbral Spire of Zuraal');
-- NPC 122316: 86 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,147869,1.0,0,1,0,1,1,'Fel Meteorite');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,217605,5.0,0,1,0,1,1,'Timeless Scroll of Intellect');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,217606,5.0,0,1,0,1,1,'Timeless Scroll of Fortitude');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,217607,5.0,0,1,0,1,1,'Timeless Scroll of the Wild');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,217608,5.0,0,1,0,1,1,'Timeless Scroll of Battle Shout');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,217730,5.0,0,1,0,1,1,'Timeless Scroll of Chaos');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,217731,5.0,0,1,0,1,1,'Timeless Scroll of Mystic Power');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,217901,5.0,0,1,0,1,1,'Timeless Drums');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,217928,5.0,0,1,0,1,1,'Timeless Scroll of Resurrection');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,217929,5.0,0,1,0,1,1,'Timeless Scroll of Cleansing');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,217956,5.0,0,1,0,1,1,'Timeless Scroll of Summoning');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,238726,5.0,0,1,0,1,1,'Drake Treat');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,238727,5.0,0,1,0,1,1,'Nostwin''s Voucher');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,239717,1.0,0,1,0,1,1,'Doomsinger''s Robe');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240597,1.0,0,1,0,1,1,'Praetorium Guard''s Drape');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240598,1.0,0,1,0,1,1,'Praetorium Guard''s Cape');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240601,1.0,0,1,0,1,1,'Oronaar Disciple''s Drape');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240605,1.0,0,1,0,1,1,'Doomsinger''s Shroud');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240629,1.0,0,1,0,1,1,'Doomsinger''s Cape');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240662,1.0,0,1,0,1,1,'Praetorium Guard''s Helmet');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240663,1.0,0,1,0,1,1,'Praetorium Guard''s Spaulders');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240664,1.0,0,1,0,1,1,'Praetorium Guard''s Breastplate');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240665,1.0,0,1,0,1,1,'Praetorium Guard''s Greatbelt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240666,1.0,0,1,0,1,1,'Praetorium Guard''s Legguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240667,1.0,0,1,0,1,1,'Praetorium Guard''s Sabatons');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240668,1.0,0,1,0,1,1,'Praetorium Guard''s Wristguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240669,1.0,0,1,0,1,1,'Praetorium Guard''s Gauntlets');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240702,1.0,0,1,0,1,1,'Doomsinger''s Guise');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240703,1.0,0,1,0,1,1,'Doomsinger''s Amice');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240704,1.0,0,1,0,1,1,'Doomsinger''s Doublet');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240705,1.0,0,1,0,1,1,'Doomsinger''s Belt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240706,1.0,0,1,0,1,1,'Doomsinger''s Pants');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240707,1.0,0,1,0,1,1,'Doomsinger''s Boots');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240708,1.0,0,1,0,1,1,'Doomsinger''s Bindings');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240709,1.0,0,1,0,1,1,'Doomsinger''s Handwraps');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240767,1.0,0,1,0,1,1,'Arinor Keeper''s Cap');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240768,1.0,0,1,0,1,1,'Arinor Keeper''s Mantle');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240769,1.0,0,1,0,1,1,'Arinor Keeper''s Vest');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240770,1.0,0,1,0,1,1,'Arinor Keeper''s Cinch');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240771,1.0,0,1,0,1,1,'Arinor Keeper''s Breeches');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240772,1.0,0,1,0,1,1,'Arinor Keeper''s Waders');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240773,1.0,0,1,0,1,1,'Arinor Keeper''s Cuffs');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240774,1.0,0,1,0,1,1,'Arinor Keeper''s Grips');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240816,1.0,0,1,0,1,1,'Oronaar Disciple''s Pauldrons');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240817,1.0,0,1,0,1,1,'Oronaar Disciple''s Haubergeon');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240818,1.0,0,1,0,1,1,'Oronaar Disciple''s Waistband');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240819,1.0,0,1,0,1,1,'Oronaar Disciple''s Wargreaves');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240820,1.0,0,1,0,1,1,'Oronaar Disciple''s Greaves');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240821,1.0,0,1,0,1,1,'Oronaar Disciple''s Wristguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,241222,1.0,0,1,0,1,1,'Oronaar Disciple''s Hauberk');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,242501,1.0,0,1,0,1,1,'Memento of Epoch Knowledge');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,242502,1.0,0,1,0,1,1,'Memento of Epoch History');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,242503,1.0,0,1,0,1,1,'Memento of Epoch Stories');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,242504,1.0,0,1,0,1,1,'Memento of Epoch Truth');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,242505,1.0,0,1,0,1,1,'Memento of Epoch Hope');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,242506,1.0,0,1,0,1,1,'Memento of Epoch Rituals');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,242507,1.0,0,1,0,1,1,'Memento of Epoch Power');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,242508,1.0,0,1,0,1,1,'Memento of Epoch Potential');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,242516,1.0,0,1,0,1,1,'Memento of Epoch Legends');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,245996,1.0,0,1,0,1,1,'Chaos-Forged Necklace');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,245997,1.0,0,1,0,1,1,'Seal of the Nazjatar Empire');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,245999,1.0,0,1,0,1,1,'Volatile Chaos Talisman');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246000,1.0,0,1,0,1,1,'Lure of the Unknown Depths');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246190,1.0,0,1,0,1,1,'Pendant of the Watchful Eye');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246193,1.0,0,1,0,1,1,'Strand of the Stars');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246194,1.0,0,1,0,1,1,'Chain of Scorched Bones');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246195,1.0,0,1,0,1,1,'Wolfstride Pendant');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246197,1.0,0,1,0,1,1,'Woe-Bearer''s Band');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246198,1.0,0,1,0,1,1,'Jeweled Signet of Melandrus');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246202,1.0,0,1,0,1,1,'Grasping Tentacle Loop');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246203,1.0,0,1,0,1,1,'Chattering Soulmark');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246204,1.0,0,1,0,1,1,'Arcane Medal of Protection');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246205,1.0,0,1,0,1,1,'Stormwalker''s Icon');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246206,1.0,0,1,0,1,1,'Aethas''s Orbs of Warding');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246208,1.0,0,1,0,1,1,'Mote of Obscure Magics');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,249891,1.0,0,1,0,1,1,'Mound of Artifactium Sand');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,253224,1.0,0,1,0,1,1,'Mote of a Broken Time');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,253227,1.0,0,1,0,1,1,'Flawless Thread of Time');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,152201,5.0,0,1,0,1,1,'Armory Key Fragment');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240815,1.0,0,1,0,1,1,'Oronaar Disciple''s Coif');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,240822,1.0,0,1,0,1,1,'Oronaar Disciple''s Grips');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246191,1.0,0,1,0,1,1,'Chain of the Underking');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246192,1.0,0,1,0,1,1,'Understone Gorget');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246199,1.0,0,1,0,1,1,'Band of Callous Dominance');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,246200,1.0,0,1,0,1,1,'Band of Twisted Bark');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (122316,0,258516,1.0,0,1,0,1,1,'Wand of Saprish''s Gaze');
-- NPC 124309: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (124309,0,258523,1.0,0,1,0,1,1,'Nezhar''s Netherclaw');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (124309,0,258524,1.0,0,1,0,1,1,'Grips of the Dark Viceroy');
-- NPC 190609: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (190609,0,193405,5.0,0,1,0,1,1,'Headteacher''s Ledger');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (190609,0,202002,1.0,0,1,0,1,1,'Enlightened Renascence');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (190609,0,260359,1.0,0,1,0,1,1,'Valdrakken Bookcase');
-- NPC 191736: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (191736,0,199027,1.0,0,1,0,1,1,'Drakeslayer''s Greatsword');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (191736,0,258531,1.0,0,1,0,1,1,'Crawth''s Scaleguard');
-- NPC 194181: 1 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (194181,0,258529,1.0,0,1,0,1,1,'Arcaneclaw Spear');
-- NPC 196482: 1 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (196482,0,220737,5.0,0,1,0,1,1,'Storm Spirit');
-- NPC 214650: 15 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (214650,0,249286,1.0,0,1,0,1,1,'Brazier of the Dissonant Dirge');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (214650,0,249296,1.0,0,1,0,1,1,'Alah''endal, the Dawnsong');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (214650,0,249367,1.0,0,1,0,1,1,'Chiming Void Curio');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (214650,0,249810,1.0,0,1,0,1,1,'Shadow of the Empyrean Requiem');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (214650,0,249811,1.0,0,1,0,1,1,'Light of the Cosmic Crescendo');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (214650,0,249912,1.0,0,1,0,1,1,'Robes of Endless Oblivion');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (214650,0,249913,1.0,0,1,0,1,1,'Mask of Darkest Intent');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (214650,0,249914,1.0,0,1,0,1,1,'Oblivion Guise');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (214650,0,249915,1.0,0,1,0,1,1,'Extinction Guards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (214650,0,249920,1.0,0,1,0,1,1,'Eye of Midnight');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (214650,0,250247,1.0,0,1,0,1,1,'Amulet of the Abyssal Hymn');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (214650,0,258519,1.0,0,1,0,1,1,'Plans: Magister''s Valediction');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (214650,0,260408,1.0,0,1,0,1,1,'Lightless Lament');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (214650,0,264492,1.0,0,1,0,1,1,'Chaotic Void Maw');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (214650,0,267646,1.0,0,1,0,1,1,'March on Quel''Danas Vanquisher''s Argent Trophy');
-- NPC 231606: 7 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231606,0,250144,1.0,0,1,0,1,1,'Emberwing Feather');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231606,0,251077,1.0,0,1,0,1,1,'Roostwarden''s Bough');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231606,0,251078,1.0,0,1,0,1,1,'Emberdawn Defender');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231606,0,251079,1.0,0,1,0,1,1,'Amberfrond Bracers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231606,0,251080,1.0,0,1,0,1,1,'Brambledawn Halo');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231606,0,251081,1.0,0,1,0,1,1,'Embergrove Grasps');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231606,0,251082,1.0,0,1,0,1,1,'Snapvine Cinch');
-- NPC 231626: 6 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231626,0,250226,1.0,0,1,0,1,1,'Latch''s Crooked Hook');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231626,0,251083,1.0,0,1,0,1,1,'Excavating Cudgel');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231626,0,251084,1.0,0,1,0,1,1,'Whipcoil Sabatons');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231626,0,251085,1.0,0,1,0,1,1,'Mantle of Dark Devotion');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231626,0,251086,1.0,0,1,0,1,1,'Riphook Defender');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231626,0,251087,1.0,0,1,0,1,1,'Legwraps of Lingering Legacies');
-- NPC 231631: 6 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231631,0,250227,1.0,0,1,0,1,1,'Kroluk''s Warbanner');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231631,0,251088,1.0,0,1,0,1,1,'Warworn Cleaver');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231631,0,251089,1.0,0,1,0,1,1,'Grips of Forgotten Honor');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231631,0,251090,1.0,0,1,0,1,1,'Commander''s Faded Breeches');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231631,0,251091,1.0,0,1,0,1,1,'Sabatons of Furious Revenge');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231631,0,251092,1.0,0,1,0,1,1,'Fallen Grunt''s Mantle');
-- NPC 231636: 10 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231636,0,250256,1.0,0,1,0,1,1,'Heart of Wind');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231636,0,251094,1.0,0,1,0,1,1,'Sigil of the Restless Heart');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231636,0,251095,1.0,0,1,0,1,1,'Hurricane''s Heart');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231636,0,251096,1.0,0,1,0,1,1,'Pendant of Aching Grief');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231636,0,251097,1.0,0,1,0,1,1,'Spaulders of Arrow''s Flight');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231636,0,251098,1.0,0,1,0,1,1,'Fletcher''s Faded Faceplate');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231636,0,251099,1.0,0,1,0,1,1,'Vest of the Howling Gale');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231636,0,256653,1.0,0,1,0,1,1,'Pattern: Ranger-General''s Grips');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231636,0,256683,1.0,0,1,0,1,1,'Silvermoon Training Dummy');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231636,0,258125,1.0,0,1,0,1,1,'Pattern: Sunfire Sash');
-- NPC 231863: 7 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231863,0,251105,1.0,0,1,0,1,1,'Ward of the Spellbreaker');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231863,0,251106,1.0,0,1,0,1,1,'Resolute Runeglaive');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231863,0,251107,1.0,0,1,0,1,1,'Oathsworn Stompers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231863,0,251108,1.0,0,1,0,1,1,'Wraps of Watchful Wrath');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231863,0,251109,1.0,0,1,0,1,1,'Spellsnap Shadowmask');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231863,0,251110,1.0,0,1,0,1,1,'Sunlash''s Sunsash');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231863,0,260312,1.0,0,1,0,1,1,'Defiant Defender''s Drape');
-- NPC 231864: 6 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231864,0,250242,1.0,0,1,0,1,1,'Jelly Replicator');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231864,0,251111,1.0,0,1,0,1,1,'Splitshroud Stinger');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231864,0,251112,1.0,0,1,0,1,1,'Shadowsplit Girdle');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231864,0,251113,1.0,0,1,0,1,1,'Gloves of Viscous Goo');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231864,0,251114,1.0,0,1,0,1,1,'Voidwarped Oozemail');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231864,0,251115,1.0,0,1,0,1,1,'Bifurcation Band');
-- NPC 231865: 11 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231865,0,250257,1.0,0,1,0,1,1,'Eye of the Drowning Void');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231865,0,251117,1.0,0,1,0,1,1,'Whirling Voidcleaver');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231865,0,251118,1.0,0,1,0,1,1,'Legplates of Lingering Dusk');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231865,0,251119,1.0,0,1,0,1,1,'Vortex Visage');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231865,0,251120,1.0,0,1,0,1,1,'Wraps of Umbral Descent');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231865,0,251121,1.0,0,1,0,1,1,'Domanaar''s Dire Treads');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231865,0,251122,1.0,0,1,0,1,1,'Shadowslash Slicer');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231865,0,256755,1.0,0,1,0,1,1,'Formula: Enchant Chest - Mark of the Magister');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231865,0,256759,1.0,0,1,0,1,1,'Formula: Enchant Weapon - Flames of the Sin''dorei');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231865,0,258033,1.0,0,1,0,1,1,'Pattern: Arcanoweave Lining');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (231865,0,263230,1.0,0,1,0,1,1,'Magister''s Bookshelf');
-- NPC 234647: 5 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (234647,0,250228,1.0,0,1,0,1,1,'Resonant Bellowstone');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (234647,0,251134,1.0,0,1,0,1,1,'Xathuux''s Cleave');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (234647,0,251135,1.0,0,1,0,1,1,'Fury-fletched Armlets');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (234647,0,251136,1.0,0,1,0,1,1,'Signet of Snarling Servitude');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (234647,0,251137,1.0,0,1,0,1,1,'Tempestuous Sandals');
-- NPC 234649: 7 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (234649,0,250215,1.0,0,1,0,1,1,'Freightrunner''s Flask');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (234649,0,251128,1.0,0,1,0,1,1,'Bladesorrow');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (234649,0,251129,1.0,0,1,0,1,1,'Counterfeit Clutches');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (234649,0,251130,1.0,0,1,0,1,1,'Breeches of Deft Deals');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (234649,0,251131,1.0,0,1,0,1,1,'Jangling Felpaulets');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (234649,0,251132,1.0,0,1,0,1,1,'Speakeasy Shroud');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (234649,0,251133,1.0,0,1,0,1,1,'Overseer''s Vambraces');
-- NPC 237415: 11 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (237415,0,250255,1.0,0,1,0,1,1,'Unstable Felheart Crystal');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (237415,0,251138,1.0,0,1,0,1,1,'Cinderfury Shoulderguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (237415,0,251139,1.0,0,1,0,1,1,'Summoner''s Searing Shirt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (237415,0,251140,1.0,0,1,0,1,1,'Vilefiend''s Guise');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (237415,0,251141,1.0,0,1,0,1,1,'Lithiel''s Linked Leggings');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (237415,0,251142,1.0,0,1,0,1,1,'Pendant of Malefic Fury');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (237415,0,256640,1.0,0,1,0,1,1,'Pattern: Row Walker''s Insurance');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (237415,0,256746,1.0,0,1,0,1,1,'Formula: Smuggler''s Enchanted Edge');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (237415,0,258487,1.0,0,1,0,1,1,'Plans: Murder Row Fleet Feet');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (237415,0,258518,1.0,0,1,0,1,1,'Plans: Murder Row Fishhook');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (237415,0,263238,1.0,0,1,0,1,1,'Illicit Long Table');
-- NPC 238498: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (238498,0,264565,1.0,0,1,0,1,1,'Voidscale Shoulderpads');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (238498,0,264642,1.0,0,1,0,1,1,'Carving Voidscythe');
-- NPC 238887: 7 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (238887,0,250225,1.0,0,1,0,1,1,'Void Execution Mandate');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (238887,0,251218,1.0,0,1,0,1,1,'Taz''Rah''s Cosmic Edge');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (238887,0,251219,1.0,0,1,0,1,1,'Riftworn Stompers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (238887,0,251220,1.0,0,1,0,1,1,'Voidscarred Crown');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (238887,0,251221,1.0,0,1,0,1,1,'Despondent''s Gauntlets');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (238887,0,251222,1.0,0,1,0,1,1,'Ethereal Netherwrap');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (238887,0,251223,1.0,0,1,0,1,1,'Somber Spaulders');
-- NPC 239008: 8 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (239008,0,250245,1.0,0,1,0,1,1,'Tumor of the Swarm');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (239008,0,251224,1.0,0,1,0,1,1,'Hulking Handaxe');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (239008,0,251225,1.0,0,1,0,1,1,'Fang of Contagion');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (239008,0,251226,1.0,0,1,0,1,1,'Hide of Pestilence');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (239008,0,251227,1.0,0,1,0,1,1,'Poisoner''s Pauldrons');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (239008,0,251228,1.0,0,1,0,1,1,'Behemoth Waistband');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (239008,0,251229,1.0,0,1,0,1,1,'Visor of the Predator');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (239008,0,252258,1.0,0,1,0,1,1,'Sickening Signet of Atroxus');
-- NPC 240129: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240129,0,264523,1.0,0,1,0,1,1,'Hydrafang Blade');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240129,0,264524,1.0,0,1,0,1,1,'Lightblighted Verdant Vest');
-- NPC 240432: 16 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,249281,1.0,0,1,0,1,1,'Blade of the Final Twilight');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,249298,1.0,0,1,0,1,1,'Tormentor''s Bladed Fists');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,249304,1.0,0,1,0,1,1,'Fallen King''s Cuffs');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,249308,1.0,0,1,0,1,1,'Despotic Raiment');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,249314,1.0,0,1,0,1,1,'Twisted Twilight Sash');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,249316,1.0,0,1,0,1,1,'Crown of the Fractured Tyrant');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,249337,1.0,0,1,0,1,1,'Ribbon of Coiled Malice');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,249340,1.0,0,1,0,1,1,'Wraps of Cosmic Madness');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,249341,1.0,0,1,0,1,1,'Volatile Void Suffuser');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,249363,1.0,0,1,0,1,1,'Voidwoven Unraveled Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,249364,1.0,0,1,0,1,1,'Voidcured Unraveled Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,249365,1.0,0,1,0,1,1,'Voidcast Unraveled Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,249366,1.0,0,1,0,1,1,'Voidforged Unraveled Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,258123,1.0,0,1,0,1,1,'Pattern: Sunfire Silk Spellthread');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,264494,1.0,0,1,0,1,1,'Banded Domanaar Storage Crate');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240432,0,264672,1.0,0,1,0,1,1,'Cosmic Ritual Stone');
-- NPC 240434: 15 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240434,0,249276,1.0,0,1,0,1,1,'Grimoire of the Eternal Light');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240434,0,249302,1.0,0,1,0,1,1,'Inescapable Reach');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240434,0,249315,1.0,0,1,0,1,1,'Voracious Wristwraps');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240434,0,249317,1.0,0,1,0,1,1,'Frenzy''s Rebuke');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240434,0,249327,1.0,0,1,0,1,1,'Void-Skinned Bracers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240434,0,249332,1.0,0,1,0,1,1,'Parasite Stompers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240434,0,249336,1.0,0,1,0,1,1,'Signet of the Starved Beast');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240434,0,249342,1.0,0,1,0,1,1,'Heart of Ancient Hunger');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240434,0,249351,1.0,0,1,0,1,1,'Voidwoven Hungering Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240434,0,249352,1.0,0,1,0,1,1,'Voidcured Hungering Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240434,0,249353,1.0,0,1,0,1,1,'Voidcast Hungering Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240434,0,249354,1.0,0,1,0,1,1,'Voidforged Hungering Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240434,0,249925,1.0,0,1,0,1,1,'Hungering Victory');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240434,0,258522,1.0,0,1,0,1,1,'Plans: Bloomforged Greataxe');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240434,0,264498,1.0,0,1,0,1,1,'Voltaic Trigore Egg');
-- NPC 240435: 14 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240435,0,249275,1.0,0,1,0,1,1,'Bulwark of Noble Resolve');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240435,0,249279,1.0,0,1,0,1,1,'Sunstrike Rifle');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240435,0,249293,1.0,0,1,0,1,1,'Weight of Command');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240435,0,249306,1.0,0,1,0,1,1,'Devouring Night''s Visage');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240435,0,249310,1.0,0,1,0,1,1,'Robes of the Voidbound');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240435,0,249313,1.0,0,1,0,1,1,'Light-Judged Spaulders');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240435,0,249319,1.0,0,1,0,1,1,'Endless March Waistwrap');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240435,0,249320,1.0,0,1,0,1,1,'Sabatons of Obscurement');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240435,0,249323,1.0,0,1,0,1,1,'Leggings of the Devouring Advance');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240435,0,249326,1.0,0,1,0,1,1,'Light''s March Bracers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240435,0,249334,1.0,0,1,0,1,1,'Void-Claimed Shinkickers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240435,0,249335,1.0,0,1,0,1,1,'Imperator''s Banner');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240435,0,249344,1.0,0,1,0,1,1,'Light Company Guidon');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (240435,0,264497,1.0,0,1,0,1,1,'Imperator''s Torment Crystal');
-- NPC 241443: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (241443,0,264610,1.0,0,1,0,1,1,'Escaped Specimen''s ID Tag');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (241443,0,264646,1.0,0,1,0,1,1,'Specimen Sinew Longbow');
-- NPC 241546: 9 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (241546,0,250241,1.0,0,1,0,1,1,'Mark of Light');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (241546,0,251157,1.0,0,1,0,1,1,'Searing Spaulders');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (241546,0,251211,1.0,0,1,0,1,1,'Fractured Fingerguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (241546,0,251212,1.0,0,1,0,1,1,'Radiant Slicer');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (241546,0,251215,1.0,0,1,0,1,1,'Greaves of the Divine Guile');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (241546,0,251216,1.0,0,1,0,1,1,'Maledict Vest');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (241546,0,251217,1.0,0,1,0,1,1,'Occlusion of Void');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (241546,0,256716,1.0,0,1,0,1,1,'Design: Prismatic Focusing Iris');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (241546,0,264338,1.0,0,1,0,1,1,'Domanaar Control Console');
-- NPC 242023: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242023,0,264527,1.0,0,1,0,1,1,'Vile Hexxer''s Mantle');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242023,0,264611,1.0,0,1,0,1,1,'Pendant of Siphoned Vitality');
-- NPC 242024: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242024,0,264585,1.0,0,1,0,1,1,'Snapper Steppers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242024,0,264617,1.0,0,1,0,1,1,'Scourge''s Spike');
-- NPC 242025: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242025,0,264542,1.0,0,1,0,1,1,'Skullcrusher''s Mantle');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242025,0,264631,1.0,0,1,0,1,1,'Harak''s Skullcutter');
-- NPC 242026: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242026,0,264529,1.0,0,1,0,1,1,'Cover of the Furbolg Elder');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242026,0,264547,1.0,0,1,0,1,1,'Worn Furbolg Bindings');
-- NPC 242027: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242027,0,260673,5.0,0,1,0,1,1,'Partially Digested Bracers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242027,0,264598,1.0,0,1,0,1,1,'Eelectrum Signet');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242027,0,264618,1.0,0,1,0,1,1,'Strangely Eelastic Blade');
-- NPC 242028: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242028,0,264557,1.0,0,1,0,1,1,'Borerplate Pauldrons');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242028,0,264640,1.0,0,1,0,1,1,'Sharpened Borer Claw');
-- NPC 242031: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242031,0,260695,5.0,0,1,0,1,1,'Rancid Aquatic Remains');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242031,0,264554,1.0,0,1,0,1,1,'Frilly Leather Vest');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242031,0,264620,1.0,0,1,0,1,1,'Pufferspine Spellpierce');
-- NPC 242032: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242032,0,238519,1.0,0,1,0,1,1,'Void-Tempered Hide');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242032,0,264528,1.0,0,1,0,1,1,'Goop-Coated Leggings');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242032,0,264541,1.0,0,1,0,1,1,'Egg-Swaddling Sash');
-- NPC 242033: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242033,0,260637,5.0,0,1,0,1,1,'Rotting Insect Eggs');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242033,0,264597,1.0,0,1,0,1,1,'Leechtooth Band');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242033,0,264648,1.0,0,1,0,1,1,'Verminscale Gavel');
-- NPC 242034: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242034,0,260654,5.0,0,1,0,1,1,'Abrasive Sand');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242034,0,264564,1.0,0,1,0,1,1,'Crab Wrangling Harness');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242034,0,264586,1.0,0,1,0,1,1,'Crustacean Carapace Chestguard');
-- NPC 242035: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242035,0,260646,5.0,0,1,0,1,1,'Glowing Gland');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242035,0,264559,1.0,0,1,0,1,1,'Devourer''s Visage');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242035,0,264638,1.0,0,1,0,1,1,'Fangs of the Invader');
-- NPC 242056: 16 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,265695,5.0,0,1,0,1,1,'Elementary Voidcore Shard');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,249280,1.0,0,1,0,1,1,'Emblazoned Sunglaive');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,249287,1.0,0,1,0,1,1,'Clutchmates'' Caress');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,249305,1.0,0,1,0,1,1,'Slippers of the Midnight Flame');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,249318,1.0,0,1,0,1,1,'Nullwalker''s Dread Epaulettes');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,249321,1.0,0,1,0,1,1,'Vaelgor''s Fearsome Grasp');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,249331,1.0,0,1,0,1,1,'Ezzorak''s Gloombind');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,249339,1.0,0,1,0,1,1,'Gloom-Spattered Dreadscale');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,249346,1.0,0,1,0,1,1,'Vaelgor''s Final Stare');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,249359,1.0,0,1,0,1,1,'Voidwoven Corrupted Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,249360,1.0,0,1,0,1,1,'Voidcured Corrupted Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,249361,1.0,0,1,0,1,1,'Voidcast Corrupted Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,249362,1.0,0,1,0,1,1,'Voidforged Corrupted Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,249370,1.0,0,1,0,1,1,'Draconic Nullcape');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,258521,1.0,0,1,0,1,1,'Plans: Blood Knight''s Impetus');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (242056,0,264491,1.0,0,1,0,1,1,'Voidbound Holding Cell');
-- NPC 243028: 7 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (243028,0,250254,1.0,0,1,0,1,1,'Seed of Radiant Hope');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (243028,0,251180,1.0,0,1,0,1,1,'Thornblade');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (243028,0,251181,1.0,0,1,0,1,1,'Pruning Lance');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (243028,0,251182,1.0,0,1,0,1,1,'Bedrock Breeches');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (243028,0,251183,1.0,0,1,0,1,1,'Rootwarden Wraps');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (243028,0,251184,1.0,0,1,0,1,1,'Ironroot Collar');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (243028,0,251185,1.0,0,1,0,1,1,'Lightblossom Cinch');
-- NPC 244272: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244272,0,242390,5.0,0,1,0,1,1,'Shadowgraft Fragment');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244272,0,264539,1.0,0,1,0,1,1,'Robes of the Voidcaller');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244272,0,264619,1.0,0,1,0,1,1,'Nethersteel Spellblade');
-- NPC 244424: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244424,0,250446,1.0,0,1,0,1,1,'Cragtender Bulwark');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244424,0,250450,1.0,0,1,0,1,1,'Forest Sentinel''s Savage Longbow');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244424,0,250461,1.0,0,1,0,1,1,'Chain of the Ancient Watcher');
-- NPC 244761: 14 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244761,0,249288,1.0,0,1,0,1,1,'Ranger-Captain''s Lethal Recurve');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244761,0,249295,1.0,0,1,0,1,1,'Turalyon''s False Echo');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244761,0,249309,1.0,0,1,0,1,1,'Sunbound Breastplate');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244761,0,249312,1.0,0,1,0,1,1,'Nightblade''s Pantaloons');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244761,0,249325,1.0,0,1,0,1,1,'Untethered Berserker''s Grips');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244761,0,249329,1.0,0,1,0,1,1,'Gaze of the Unrestrained');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244761,0,249345,1.0,0,1,0,1,1,'Ranger-Captain''s Iridescent Insignia');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244761,0,249368,1.0,0,1,0,1,1,'Eternal Voidsong Chain');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244761,0,249380,1.0,0,1,0,1,1,'Hate-Tied Waistchain');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244761,0,249382,1.0,0,1,0,1,1,'Canopy Walker''s Footwraps');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244761,0,249809,1.0,0,1,0,1,1,'Locus-Walker''s Ribbon');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244761,0,260423,1.0,0,1,0,1,1,'Arator''s Swift Remembrance');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244761,0,268049,1.0,0,1,0,1,1,'Voidspire Vanquisher''s Argent Trophy');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244761,0,269269,1.0,0,1,0,1,1,'Devouring Ritual Spire');
-- NPC 244762: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244762,0,250447,1.0,0,1,0,1,1,'Radiant Eversong Scepter');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244762,0,250451,1.0,0,1,0,1,1,'Dawncrazed Beast Cleaver');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244762,0,250453,1.0,0,1,0,1,1,'Scepter of the Unbound Light');
-- NPC 244887: 6 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244887,0,250238,1.0,0,1,0,1,1,'Seed of the Devouring Wild');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244887,0,251186,1.0,0,1,0,1,1,'Thorntalon Edge');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244887,0,251187,1.0,0,1,0,1,1,'Amirdrassil''s Reach');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244887,0,251188,1.0,0,1,0,1,1,'Doompetal');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244887,0,251189,1.0,0,1,0,1,1,'Rootwalker Harness');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (244887,0,251190,1.0,0,1,0,1,1,'Bloodthorn Burnous');
-- NPC 245044: 5 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245044,0,260604,5.0,0,1,0,1,1,'Insect Shedding');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245044,0,260688,5.0,0,1,0,1,1,'Insect Exoskeleton');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245044,0,243350,5.0,0,1,0,1,1,'Predator Blood');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245044,0,264551,1.0,0,1,0,1,1,'Nightbrood''s Jaw');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245044,0,264574,1.0,0,1,0,1,1,'Netherterror''s Legplates');
-- NPC 245182: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245182,0,244171,5.0,0,1,0,1,1,'Abductor''s Mark');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245182,0,264563,1.0,0,1,0,1,1,'Eruundi''s Wristguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245182,0,264600,1.0,0,1,0,1,1,'Ancient Argussian Band');
-- NPC 245676: 4 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245676,0,245832,1.0,0,1,0,1,1,'Three of Hunt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245676,0,245841,1.0,0,1,0,1,1,'Four of Void');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245676,0,245859,1.0,0,1,0,1,1,'Four of Blood');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245676,0,258854,5.0,0,1,0,1,1,'Stained Pauldrons');
-- NPC 245691: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245691,0,264525,1.0,0,1,0,1,1,'Wrapped Antenna Cuffs');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245691,0,264582,1.0,0,1,0,1,1,'Diamondback-Scale Legguards');
-- NPC 245692: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245692,0,264593,1.0,0,1,0,1,1,'Warcloak of the Butcher');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245692,0,264643,1.0,0,1,0,1,1,'Ash''an''s Spare Cleaver');
-- NPC 245912: 6 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245912,0,250214,1.0,0,1,0,1,1,'Lightspire Core');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245912,0,251165,1.0,0,1,0,1,1,'Pulverizing Pads');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245912,0,251191,1.0,0,1,0,1,1,'Luminescent Sprout');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245912,0,251192,1.0,0,1,0,1,1,'Branch of Pride');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245912,0,251193,1.0,0,1,0,1,1,'Taproot Ribs');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245912,0,251194,1.0,0,1,0,1,1,'Lightwarden''s Bind');
-- NPC 245975: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245975,0,264570,1.0,0,1,0,1,1,'Reinforced Chainmrrl');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (245975,0,264580,1.0,0,1,0,1,1,'Mrrlokk''s Mrgl Grrdle');
-- NPC 246122: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (246122,0,245854,1.0,0,1,0,1,1,'Eight of Rot');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (246122,0,259361,5.0,0,1,0,1,1,'Vile Essence');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (246122,0,245856,1.0,0,1,0,1,1,'Ace of Blood');
-- NPC 246332: 4 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (246332,0,260677,5.0,0,1,0,1,1,'Void Flakes');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (246332,0,260659,5.0,0,1,0,1,1,'Stellar Vortex Residue');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (246332,0,264520,1.0,0,1,0,1,1,'Warden''s Leycrook');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (246332,0,264613,1.0,0,1,0,1,1,'Steelbark Bulwark');
-- NPC 246633: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (246633,0,264521,1.0,0,1,0,1,1,'Striderplume Focus');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (246633,0,264522,1.0,0,1,0,1,1,'Striderplume Armbands');
-- NPC 247570: 6 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247570,0,251162,1.0,0,1,0,1,1,'Traitor''s Talon');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247570,0,251166,1.0,0,1,0,1,1,'Falconer''s Cinch');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247570,0,251167,1.0,0,1,0,1,1,'Nightprey Stalkers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247570,0,251174,1.0,0,1,0,1,1,'Deceiver''s Rotbow');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247570,0,251176,1.0,0,1,0,1,1,'Reanimator''s Weight');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247570,0,263193,1.0,0,1,0,1,1,'Trollhunter''s Bands');
-- NPC 247676: 10 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247676,0,250259,1.0,0,1,0,1,1,'Sapling of the Dawnroot');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247676,0,251195,1.0,0,1,0,1,1,'Thorned Reply');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247676,0,251196,1.0,0,1,0,1,1,'Teldrassil''s Sacrifice');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247676,0,251197,1.0,0,1,0,1,1,'Thornspike Gauntlets');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247676,0,251198,1.0,0,1,0,1,1,'Lightspore Leggings');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247676,0,251199,1.0,0,1,0,1,1,'Worldroot Canopy');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247676,0,251200,1.0,0,1,0,1,1,'Saptorbane Guards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247676,0,253451,1.0,0,1,0,1,1,'Veilroot Fountain');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247676,0,256642,1.0,0,1,0,1,1,'Pattern: Primal Spore Binding');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247676,0,256652,1.0,0,1,0,1,1,'Pattern: World Tender''s Trunkplate');
-- NPC 247976: 10 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247976,0,248583,1.0,0,1,0,1,1,'Drum of Renewed Bonds');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247976,0,251783,1.0,0,1,0,1,1,'Lost Idol of the Hash''ey');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247976,0,251784,1.0,0,1,0,1,1,'Sylvan Wakrapuku');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247976,0,257200,1.0,0,1,0,1,1,'Escaped Witherbark Pango');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247976,0,265543,1.0,0,1,0,1,1,'Tempered Amani Spearhead');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247976,0,265554,1.0,0,1,0,1,1,'Reinforced Amani Haft');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247976,0,265560,1.0,0,1,0,1,1,'Toughened Amani Leather Wrap');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247976,0,257152,1.0,0,1,0,1,1,'Amani Sharptalon');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247976,0,264627,1.0,0,1,0,1,1,'Rav''ik''s Spare Hunting Spear');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (247976,0,264911,1.0,0,1,0,1,1,'Forest Hunter''s Arc');
-- NPC 248015: 9 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248015,0,250224,1.0,0,1,0,1,1,'Mindpiercer''s Sigil');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248015,0,251230,1.0,0,1,0,1,1,'Charonic Crescent');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248015,0,251231,1.0,0,1,0,1,1,'Singularity Slicer');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248015,0,251232,1.0,0,1,0,1,1,'Overseer''s Diadem');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248015,0,251233,1.0,0,1,0,1,1,'Manipulator''s Vest');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248015,0,251234,1.0,0,1,0,1,1,'Graft of the Domanaar');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248015,0,251235,1.0,0,1,0,1,1,'Gravitic Girdle');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248015,0,256721,1.0,0,1,0,1,1,'Design: Voidstone Shielding Array');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248015,0,264336,1.0,0,1,0,1,1,'Voidlight Brazier');
-- NPC 248595: 8 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248595,0,246586,5.0,0,1,0,1,1,'Shell of Shadra');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248595,0,250223,1.0,0,1,0,1,1,'Soulcatcher''s Charm');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248595,0,251161,1.0,0,1,0,1,1,'Soulhunter''s Mask');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248595,0,251169,1.0,0,1,0,1,1,'Footwraps of Ill-Fate');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248595,0,251170,1.0,0,1,0,1,1,'Wickedweave Trousers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248595,0,251171,1.0,0,1,0,1,1,'Enthralled Bonespines');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248595,0,251172,1.0,0,1,0,1,1,'Vilehex Bonds');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248595,0,251178,1.0,0,1,0,1,1,'Ceremonial Hexblade');
-- NPC 248605: 9 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248605,0,250258,1.0,0,1,0,1,1,'Vessel of Tortured Souls');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248605,0,251163,1.0,0,1,0,1,1,'Berserker''s Hexclaws');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248605,0,251164,1.0,0,1,0,1,1,'Amalgamation''s Harness');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248605,0,251168,1.0,0,1,0,1,1,'Liferipper''s Cutlass');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248605,0,251175,1.0,0,1,0,1,1,'Soulblight Cleaver');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248605,0,251177,1.0,0,1,0,1,1,'Fetid Vilecrown');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248605,0,251179,1.0,0,1,0,1,1,'Decaying Cuirass');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248605,0,256625,1.0,0,1,0,1,1,'Pattern: Hexwoven Strand');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248605,0,264717,1.0,0,1,0,1,1,'Amani Warding Hex');
-- NPC 248710: 7 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248710,0,250248,1.0,0,1,0,1,1,'Mycolic Medicine');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248710,0,251143,1.0,0,1,0,1,1,'Grim Harvest Gloves');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248710,0,251144,1.0,0,1,0,1,1,'Autumn''s Boon Belt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248710,0,251145,1.0,0,1,0,1,1,'Forgotten Tribe Footguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248710,0,251146,1.0,0,1,0,1,1,'Scavenger''s Spaulders');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248710,0,251147,1.0,0,1,0,1,1,'Hoarded Harvest Wrap');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248710,0,251148,1.0,0,1,0,1,1,'Pilfered Precious Band');
-- NPC 248741: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248741,0,264530,1.0,0,1,0,1,1,'Grimfur Mittens');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248741,0,264622,1.0,0,1,0,1,1,'Grimfang Shank');
-- NPC 248864: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248864,0,250448,1.0,0,1,0,1,1,'Voidbender''s Spire');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248864,0,250454,1.0,0,1,0,1,1,'Devouring Vanguard''s Soulcleaver');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (248864,0,250460,1.0,0,1,0,1,1,'Encroaching Shadow Signet');
-- NPC 249776: 8 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249776,0,250456,1.0,0,1,0,1,1,'Wretched Scholar''s Gilded Robe');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249776,0,250457,1.0,0,1,0,1,1,'Devouring Outrider''s Chausses');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249776,0,250458,1.0,0,1,0,1,1,'Host Commander''s Casque');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249776,0,250459,1.0,0,1,0,1,1,'Bramblestalker''s Feathered Cowl');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249776,0,250462,1.0,0,1,0,1,1,'Forgotten Farstrider''s Insignia');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249776,0,250449,1.0,0,1,0,1,1,'Skulking Nettledirk');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249776,0,250452,1.0,0,1,0,1,1,'Blooming Thornblade');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249776,0,250455,1.0,0,1,0,1,1,'Beastly Blossombarb');
-- NPC 249844: 4 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249844,0,260636,5.0,0,1,0,1,1,'Algae Covered Stone');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249844,0,260616,5.0,0,1,0,1,1,'Soft Marine Fungi');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249844,0,264538,1.0,0,1,0,1,1,'Translucent Membrane Slippers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249844,0,264544,1.0,0,1,0,1,1,'Grounded Death Cap');
-- NPC 249849: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249849,0,264553,1.0,0,1,0,1,1,'Deepspore Leather Galoshes');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249849,0,264592,1.0,0,1,0,1,1,'Ha''kalawe''s Flawless Wing');
-- NPC 249902: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249902,0,245851,1.0,0,1,0,1,1,'Five of Rot');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249902,0,264532,1.0,0,1,0,1,1,'Robes of Flowing Truths');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249902,0,264650,1.0,0,1,0,1,1,'Truthspreader''s Truth Spreader');
-- NPC 249962: 4 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249962,0,260661,5.0,0,1,0,1,1,'Glowing Shrub');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249962,0,260641,5.0,0,1,0,1,1,'Arid Tendrils');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249962,0,264566,1.0,0,1,0,1,1,'Lashtongue''s Leaffroggers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249962,0,264571,1.0,0,1,0,1,1,'Ironleaf Wristguards');
-- NPC 249997: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249997,0,260683,5.0,0,1,0,1,1,'Fine Magenta Sand');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249997,0,264604,1.0,0,1,0,1,1,'Sludgy Verdant Signet');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (249997,0,264626,1.0,0,1,0,1,1,'Scepter of Radiant Conversion');
-- NPC 250086: 4 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250086,0,260642,5.0,0,1,0,1,1,'Fossilized Wildlife');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250086,0,260678,5.0,0,1,0,1,1,'Sharp Obsidian Chunk');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250086,0,264578,1.0,0,1,0,1,1,'Stumpy''s Terrorplate');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250086,0,264635,1.0,0,1,0,1,1,'Stumpy''s Stump');
-- NPC 250180: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250180,0,238514,5.0,0,1,0,1,1,'Void-Tempered Scales');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250180,0,264568,1.0,0,1,0,1,1,'Serrated Scale Gauntlets');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250180,0,264639,1.0,0,1,0,1,1,'Razorfang Hacker');
-- NPC 250226: 2 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250226,0,264550,1.0,0,1,0,1,1,'Fungal Stalker''s Stockings');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250226,0,264649,1.0,0,1,0,1,1,'Mindrot Claw-Hammer');
-- NPC 250231: 4 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250231,0,260653,5.0,0,1,0,1,1,'Large Lightbloom Fungi');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250231,0,260681,5.0,0,1,0,1,1,'Lightbloom-Infused Spores');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250231,0,264562,1.0,0,1,0,1,1,'Plated Grove Vest');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250231,0,264644,1.0,0,1,0,1,1,'Crawler''s Mindscythe');
-- NPC 250246: 4 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250246,0,260644,5.0,0,1,0,1,1,'Lightbloom Bark');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250246,0,260663,5.0,0,1,0,1,1,'Lightbloom Residue');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250246,0,264581,1.0,0,1,0,1,1,'Bloombark Spaulders');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250246,0,264633,1.0,0,1,0,1,1,'Treetop Battlestave');
-- NPC 250317: 5 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250317,0,264475,1.0,0,1,0,1,1,'Umbral Tin Lockbox');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250317,0,260618,5.0,0,1,0,1,1,'Light-Infused Leaves');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250317,0,260675,5.0,0,1,0,1,1,'Luminous Seeds');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250317,0,264591,1.0,0,1,0,1,1,'Radiant Petalwing''s Feather');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250317,0,264616,1.0,0,1,0,1,1,'Lightblighted Sapdrinker');
-- NPC 250321: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250321,0,264895,1.0,0,1,0,1,1,'Trials of the Florafaun Hunter');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250321,0,264567,1.0,0,1,0,1,1,'Rockscale Hood');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250321,0,264576,1.0,0,1,0,1,1,'Slatescale Grips');
-- NPC 250347: 8 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250347,0,242640,5.0,0,1,0,1,1,'Plant Protein');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250347,0,258914,1.0,0,1,0,1,1,'Tarnished Dawnlit Spellbinder''s Mitts');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250347,0,258951,1.0,0,1,0,1,1,'Tarnished Dawnlit Shortsword');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250347,0,260651,5.0,0,1,0,1,1,'Lustrous Wildlife Pelt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250347,0,252012,1.0,0,1,0,1,1,'Vibrant Petalwing');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250347,0,260685,5.0,0,1,0,1,1,'Large Brittle Bone');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250347,0,264534,1.0,0,1,0,1,1,'Bogvine Shoulderguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250347,0,264540,1.0,0,1,0,1,1,'Mirevine Wristguards');
-- NPC 250358: 12 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250358,0,265800,1.0,0,1,0,1,1,'Earthy Garnish');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250358,0,246735,1.0,0,1,0,1,1,'Rootstalker Grimlynx');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250358,0,251782,1.0,0,1,0,1,1,'Withered Saptor''s Paw');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250358,0,252957,1.0,0,1,0,1,1,'Tangle of Vibrant Vines');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250358,0,255826,1.0,0,1,0,1,1,'Mysterious Skyshards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250358,0,259896,1.0,0,1,0,1,1,'Bark of the Guardian Tree');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250358,0,264968,1.0,0,1,0,1,1,'Telluric Leyblossom');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250358,0,260619,5.0,0,1,0,1,1,'Colorful Leaves');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250358,0,260621,5.0,0,1,0,1,1,'Magic Infused Bark');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250358,0,260664,5.0,0,1,0,1,1,'Bioluminescent Flower Petals');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250358,0,264607,1.0,0,1,0,1,1,'Spore-Laden Choker');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250358,0,264614,1.0,0,1,0,1,1,'Fungal Cap Guard');
-- NPC 250582: 4 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250582,0,260665,5.0,0,1,0,1,1,'Sizable Tusk');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250582,0,260692,5.0,0,1,0,1,1,'Chunk of Mystery Meat');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250582,0,264543,1.0,0,1,0,1,1,'Snapdragon Pantaloons');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250582,0,264560,1.0,0,1,0,1,1,'Sharpclaw Gauntlets');
-- NPC 250589: 14 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250589,0,249277,1.0,0,1,0,1,1,'Bellamy''s Final Judgement');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250589,0,249294,1.0,0,1,0,1,1,'Blade of the Blind Verdict');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250589,0,249303,1.0,0,1,0,1,1,'Waistcord of the Judged');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250589,0,249311,1.0,0,1,0,1,1,'Lightblood Greaves');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250589,0,249330,1.0,0,1,0,1,1,'War Chaplain''s Grips');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250589,0,249333,1.0,0,1,0,1,1,'Blooming Barklight Spaulders');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250589,0,249355,1.0,0,1,0,1,1,'Voidwoven Fanatical Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250589,0,249356,1.0,0,1,0,1,1,'Voidcured Fanatical Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250589,0,249357,1.0,0,1,0,1,1,'Voidcast Fanatical Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250589,0,249358,1.0,0,1,0,1,1,'Voidforged Fanatical Nullcore');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250589,0,249369,1.0,0,1,0,1,1,'Bond of Light');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250589,0,249808,1.0,0,1,0,1,1,'Litany of Lightblind Wrath');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250589,0,258517,1.0,0,1,0,1,1,'Plans: Knight-Commander''s Palisade');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250589,0,262957,1.0,0,1,0,1,1,'Tattered Vanguard Banner');
-- NPC 250683: 4 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250683,0,245831,1.0,0,1,0,1,1,'Two of Hunt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250683,0,258855,5.0,0,1,0,1,1,'Stained Armguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250683,0,264602,1.0,0,1,0,1,1,'Abyss Coral Band');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250683,0,264629,1.0,0,1,0,1,1,'Coralfang''s Hefty Fin');
-- NPC 250719: 14 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250719,0,258957,1.0,0,1,0,1,1,'Tarnished Dawnlit Staff');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250719,0,245850,1.0,0,1,0,1,1,'Four of Rot');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250719,0,258870,5.0,0,1,0,1,1,'Brittle Warboots');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250719,0,266216,5.0,0,1,0,1,1,'Threadbare Cloak');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250719,0,245842,1.0,0,1,0,1,1,'Five of Void');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250719,0,245853,1.0,0,1,0,1,1,'Seven of Rot');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250719,0,258857,5.0,0,1,0,1,1,'Threadbare Sash');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250719,0,258911,1.0,0,1,0,1,1,'Tarnished Dawnlit Pendant');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250719,0,245845,1.0,0,1,0,1,1,'Eight of Void');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250719,0,258872,5.0,0,1,0,1,1,'Frayed Wristwraps');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250719,0,245835,1.0,0,1,0,1,1,'Six of Hunt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250719,0,245834,1.0,0,1,0,1,1,'Five of Hunt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250719,0,264573,1.0,0,1,0,1,1,'Taskmaster''s Sadistic Shoulderguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250719,0,264647,1.0,0,1,0,1,1,'Cre''van''s Punisher');
-- NPC 250754: 3 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250754,0,258948,1.0,0,1,0,1,1,'Tarnished Dawnlit Knife');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250754,0,264612,1.0,0,1,0,1,1,'Tarnished Gold Locket');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250754,0,264645,1.0,0,1,0,1,1,'Aged Farstrider Bow');
-- NPC 250780: 6 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250780,0,258958,1.0,0,1,0,1,1,'Tarnished Dawnlit Greatsword');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250780,0,258941,1.0,0,1,0,1,1,'Tarnished Dawnlit Commander''s Mantle');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250780,0,260694,5.0,0,1,0,1,1,'Foul Kelp');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250780,0,258945,1.0,0,1,0,1,1,'Tarnished Dawnlit Carver');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250780,0,264608,1.0,0,1,0,1,1,'String of Lovely Blossoms');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250780,0,264910,1.0,0,1,0,1,1,'Shell-Cleaving Poleaxe');
-- NPC 250806: 7 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250806,0,258918,1.0,0,1,0,1,1,'Tarnished Dawnlit Spellbinder''s Sash');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250806,0,258960,1.0,0,1,0,1,1,'Tarnished Dawnlit Beacon');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250806,0,258943,1.0,0,1,0,1,1,'Tarnished Dawnlit Commander''s Armplates');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250806,0,260669,5.0,0,1,0,1,1,'Colorless Pebbles');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250806,0,260676,5.0,0,1,0,1,1,'Unremarkable Crystal');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250806,0,264555,1.0,0,1,0,1,1,'Splintered Hexwood Clasps');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250806,0,264575,1.0,0,1,0,1,1,'Hexwood Helm');
-- NPC 250826: 4 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250826,0,260645,5.0,0,1,0,1,1,'Water Filled Organ');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250826,0,258946,1.0,0,1,0,1,1,'Tarnished Dawnlit Chopper');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250826,0,264526,1.0,0,1,0,1,1,'Supremely Slimy Sash');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250826,0,264552,1.0,0,1,0,1,1,'Frogskin Grips');
-- NPC 250841: 8 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250841,0,258848,5.0,0,1,0,1,1,'Stained Girdle');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250841,0,258866,5.0,0,1,0,1,1,'Brittle Gauntlets');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250841,0,245848,1.0,0,1,0,1,1,'Two of Rot');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250841,0,258851,5.0,0,1,0,1,1,'Stained Hauberk');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250841,0,265803,1.0,0,1,0,1,1,'Bazaar Bites');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250841,0,245838,1.0,0,1,0,1,1,'Ace of Void');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250841,0,264536,1.0,0,1,0,1,1,'Zedling Summoning Collar');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250841,0,264621,1.0,0,1,0,1,1,'Bad Zed''s Worst Channeler');
-- NPC 250876: 5 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250876,0,258929,1.0,0,1,0,1,1,'Tarnished Dawnlit Sentinel''s Sabatons');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250876,0,260643,5.0,0,1,0,1,1,'Pile of Feathers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250876,0,260656,5.0,0,1,0,1,1,'Perforated Wing');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250876,0,264537,1.0,0,1,0,1,1,'Winged Terror Gloves');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (250876,0,264546,1.0,0,1,0,1,1,'Bat Fur Boots');
-- NPC 252458: 6 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (252458,0,250243,1.0,0,1,0,1,1,'Manaheart''s Binding Flame');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (252458,0,251123,1.0,0,1,0,1,1,'Nibbles'' Training Rod');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (252458,0,251124,1.0,0,1,0,1,1,'Gauntlets of Fevered Defense');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (252458,0,251125,1.0,0,1,0,1,1,'Felsoaked Soles');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (252458,0,251126,1.0,0,1,0,1,1,'Greathelm of Temptation');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (252458,0,251127,1.0,0,1,0,1,1,'Nibbling Armbands');
-- NPC 254227: 7 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (254227,0,250253,1.0,0,1,0,1,1,'Whisper of the Duskwraith');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (254227,0,251093,1.0,0,1,0,1,1,'Omission of Light');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (254227,0,251207,1.0,0,1,0,1,1,'Dreadflail Bludgeon');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (254227,0,251208,1.0,0,1,0,1,1,'Lightscarred Cuisses');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (254227,0,251209,1.0,0,1,0,1,1,'Corewarden Cuffs');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (254227,0,251210,1.0,0,1,0,1,1,'Eclipse Espadrilles');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (254227,0,251213,1.0,0,1,0,1,1,'Nysarra''s Mantle');
-- NPC 255171: 1 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255171,0,259219,5.0,0,1,0,1,1,'Bear Tooth');
-- NPC 255231: 1 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255231,0,259221,5.0,0,1,0,1,1,'Eagle Talon');
-- NPC 255232: 1 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255232,0,259223,5.0,0,1,0,1,1,'Lynx Claw');
-- NPC 255233: 1 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255233,0,259220,5.0,0,1,0,1,1,'Dragonhawk Feather');
-- NPC 255302: 12 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255302,0,258912,1.0,0,1,0,1,1,'Tarnished Dawnlit Spellbinder''s Robe');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255302,0,258922,1.0,0,1,0,1,1,'Tarnished Dawnlit Corsair''s Gloves');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255302,0,258938,1.0,0,1,0,1,1,'Tarnished Dawnlit Commander''s Gauntlets');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255302,0,258923,1.0,0,1,0,1,1,'Tarnished Dawnlit Corsair''s Hood');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255302,0,258950,1.0,0,1,0,1,1,'Tarnished Dawnlit Warmace');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255302,0,258920,1.0,0,1,0,1,1,'Tarnished Dawnlit Corsair''s Tunic');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255302,0,258928,1.0,0,1,0,1,1,'Tarnished Dawnlit Sentinel''s Hauberk');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255302,0,260693,5.0,0,1,0,1,1,'Mossy Lump of Dirt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255302,0,260606,5.0,0,1,0,1,1,'Light and Shaggy Fur');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255302,0,260670,5.0,0,1,0,1,1,'Bloody Broken Beak');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255302,0,264569,1.0,0,1,0,1,1,'Void-Gorged Kickers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255302,0,264594,1.0,0,1,0,1,1,'Netherscale Cloak');
-- NPC 255329: 17 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,258916,1.0,0,1,0,1,1,'Tarnished Dawnlit Spellbinder''s Trousers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,258921,1.0,0,1,0,1,1,'Tarnished Dawnlit Corsair''s Boots');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,258932,1.0,0,1,0,1,1,'Tarnished Dawnlit Sentinel''s Chausses');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,260689,5.0,0,1,0,1,1,'Fine Bioluminescent Powder');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,258909,1.0,0,1,0,1,1,'Tarnished Dawnlit Signet');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,258942,1.0,0,1,0,1,1,'Tarnished Dawnlit Commander''s Greatbelt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,258944,1.0,0,1,0,1,1,'Tarnished Dawnlit Cleaver');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,258910,1.0,0,1,0,1,1,'Tarnished Dawnlit Loop');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,258936,1.0,0,1,0,1,1,'Tarnished Dawnlit Commander''s Breastplate');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,258952,1.0,0,1,0,1,1,'Tarnished Dawnlit Longsword');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,258925,1.0,0,1,0,1,1,'Tarnished Dawnlit Corsair''s Spaulders');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,258947,1.0,0,1,0,1,1,'Tarnished Dawnlit Dagger');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,260650,5.0,0,1,0,1,1,'Elemental Debris');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,260662,5.0,0,1,0,1,1,'Polished Purple Pebble');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,258940,1.0,0,1,0,1,1,'Tarnished Dawnlit Commander''s Greaves');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,264584,1.0,0,1,0,1,1,'Stonecarved Smashers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255329,0,264603,1.0,0,1,0,1,1,'Guardian''s Gemstone Loop');
-- NPC 255348: 10 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255348,0,251788,1.0,0,1,0,1,1,'Gift of Light');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255348,0,251791,1.0,0,1,0,1,1,'Holy Retributor''s Order');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255348,0,257147,1.0,0,1,0,1,1,'Cobalt Dragonhawk');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255348,0,265027,1.0,0,1,0,1,1,'Lucky Lynx Locket');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255348,0,238518,1.0,0,1,0,1,1,'Void-Tempered Hide');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255348,0,257156,1.0,0,1,0,1,1,'Cerulean Hawkstrider');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255348,0,260652,5.0,0,1,0,1,1,'Broken Wildlife Claw');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255348,0,264595,1.0,0,1,0,1,1,'Lynxhide Shawl');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255348,0,264624,1.0,0,1,0,1,1,'Fang of the Dame');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (255348,0,265609,1.0,0,1,0,1,1,'Princess Bloodshed');
-- NPC 256116: 16 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,249278,1.0,0,1,0,1,1,'Alnscorned Spire');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,249343,1.0,0,1,0,1,1,'Gaze of the Alnseer');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,249347,1.0,0,1,0,1,1,'Alnwoven Riftbloom');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,249348,1.0,0,1,0,1,1,'Alncured Riftbloom');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,249349,1.0,0,1,0,1,1,'Alncast Riftbloom');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,249350,1.0,0,1,0,1,1,'Alnforged Riftbloom');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,249371,1.0,0,1,0,1,1,'Scornbane Waistguard');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,249373,1.0,0,1,0,1,1,'Dream-Scorched Striders');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,249374,1.0,0,1,0,1,1,'Scorn-Scarred Shul''ka''s Belt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,249381,1.0,0,1,0,1,1,'Greaves of the Unformed');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,249805,1.0,0,1,0,1,1,'Undreamt God''s Oozing Vestige');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,249922,1.0,0,1,0,1,1,'Tome of Alnscorned Regret');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,256656,1.0,0,1,0,1,1,'Pattern: World Tender''s Barkclasp');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,256750,1.0,0,1,0,1,1,'Formula: Enchant Weapon - Worldsoul Cradle');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,264246,1.0,0,1,0,1,1,'Eerie Iridescent Riftshroom');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256116,0,267645,1.0,0,1,0,1,1,'Dreamrift Vanquisher''s Argent Trophy');
-- NPC 256770: 4 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256770,0,260647,5.0,0,1,0,1,1,'Digested Human Hand');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256770,0,260608,5.0,0,1,0,1,1,'Bloated Animal Remains');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256770,0,264579,1.0,0,1,0,1,1,'Hungering Wristplates');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256770,0,264623,1.0,0,1,0,1,1,'Shredding Fang');
-- NPC 256808: 4 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256808,0,238520,1.0,0,1,0,1,1,'Void-Tempered Plating');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256808,0,238521,1.0,0,1,0,1,1,'Void-Tempered Plating');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256808,0,264535,1.0,0,1,0,1,1,'Leggings of the Cosmic Harrower');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256808,0,264589,1.0,0,1,0,1,1,'Voidfused Wing Cloak');
-- NPC 256821: 20 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,258954,1.0,0,1,0,1,1,'Tarnished Dawnlit Poleaxe');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,245833,1.0,0,1,0,1,1,'Four of Hunt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,245844,1.0,0,1,0,1,1,'Seven of Void');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,258861,5.0,0,1,0,1,1,'Threadbare Slippers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,258868,5.0,0,1,0,1,1,'Brittle Legguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,258873,5.0,0,1,0,1,1,'Frayed Tunic');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,237016,1.0,0,1,0,1,1,'Sunfire Silk');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,237017,1.0,0,1,0,1,1,'Arcanoweave');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,258877,5.0,0,1,0,1,1,'Frayed Handwraps');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,258955,1.0,0,1,0,1,1,'Tarnished Dawnlit Halberd');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,258908,1.0,0,1,0,1,1,'Tarnished Dawnlit Band');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,245849,1.0,0,1,0,1,1,'Three of Rot');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,245852,1.0,0,1,0,1,1,'Six of Rot');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,245858,1.0,0,1,0,1,1,'Three of Blood');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,245860,1.0,0,1,0,1,1,'Five of Blood');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,266221,5.0,0,1,0,1,1,'Frayed Shroud');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,245843,1.0,0,1,0,1,1,'Six of Void');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,245847,1.0,0,1,0,1,1,'Ace of Rot');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,264912,1.0,0,1,0,1,1,'Void-Channeler''s Spire');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256821,0,264913,1.0,0,1,0,1,1,'Focused Netherslicer');
-- NPC 256922: 9 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256922,0,258961,1.0,0,1,0,1,1,'Tarnished Dawnlit Defender');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256922,0,258953,1.0,0,1,0,1,1,'Tarnished Dawnlit Longbow');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256922,0,258919,1.0,0,1,0,1,1,'Tarnished Dawnlit Spellbinder''s Bands');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256922,0,258927,1.0,0,1,0,1,1,'Tarnished Dawnlit Corsair''s Bracers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256922,0,260672,5.0,0,1,0,1,1,'Fetid Eye');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256922,0,260686,5.0,0,1,0,1,1,'Vibrant Wings');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256922,0,260605,5.0,0,1,0,1,1,'Shattered Spear Tip');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256922,0,264545,1.0,0,1,0,1,1,'Harrower-Claw Grips');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256922,0,264583,1.0,0,1,0,1,1,'Barbute of the Winged Hunter');
-- NPC 256923: 12 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256923,0,260614,5.0,0,1,0,1,1,'Unrecognizable Organ');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256923,0,242639,5.0,0,1,0,1,1,'Practically Pork');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256923,0,258959,1.0,0,1,0,1,1,'Tarnished Dawnlit Blade');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256923,0,258937,1.0,0,1,0,1,1,'Tarnished Dawnlit Commander''s Warboots');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256923,0,258962,1.0,0,1,0,1,1,'Tarnished Dawnlit Warglaive');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256923,0,260684,5.0,0,1,0,1,1,'Sharp Scales');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256923,0,258915,1.0,0,1,0,1,1,'Tarnished Dawnlit Spellbinder''s Crown');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256923,0,258933,1.0,0,1,0,1,1,'Tarnished Dawnlit Sentinel''s Epaulets');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256923,0,258913,1.0,0,1,0,1,1,'Tarnished Dawnlit Spellbinder''s Slippers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256923,0,260648,5.0,0,1,0,1,1,'Tattered Clothes');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256923,0,264558,1.0,0,1,0,1,1,'Vileblood Resistant Sabatons');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256923,0,264572,1.0,0,1,0,1,1,'Netherplate Clasp');
-- NPC 256924: 26 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258934,1.0,0,1,0,1,1,'Tarnished Dawnlit Sentinel''s Girdle');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258939,1.0,0,1,0,1,1,'Tarnished Dawnlit Commander''s Helmet');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,237015,1.0,0,1,0,1,1,'Sunfire Silk');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,237018,1.0,0,1,0,1,1,'Arcanoweave');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,245857,1.0,0,1,0,1,1,'Two of Blood');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258852,5.0,0,1,0,1,1,'Stained Greaves');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258858,5.0,0,1,0,1,1,'Threadbare Crown');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258859,5.0,0,1,0,1,1,'Threadbare Mitts');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258862,5.0,0,1,0,1,1,'Threadbare Vestments');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258863,5.0,0,1,0,1,1,'Threadbare Armbands');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258871,5.0,0,1,0,1,1,'Brittle Armplates');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258876,5.0,0,1,0,1,1,'Frayed Guise');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258879,5.0,0,1,0,1,1,'Frayed Strap');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,266223,5.0,0,1,0,1,1,'Stained Drape');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,266224,5.0,0,1,0,1,1,'Brittle Cape');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258949,1.0,0,1,0,1,1,'Tarnished Dawnlit Mace');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,245861,1.0,0,1,0,1,1,'Six of Blood');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258860,5.0,0,1,0,1,1,'Threadbare Leggings');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258864,5.0,0,1,0,1,1,'Brittle Waistguard');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258867,5.0,0,1,0,1,1,'Brittle Faceguard');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258869,5.0,0,1,0,1,1,'Brittle Pauldrons');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,258874,5.0,0,1,0,1,1,'Frayed Shoulderpads');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,245840,1.0,0,1,0,1,1,'Three of Void');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,265801,1.0,0,1,0,1,1,'Savory Anomaly');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,264549,1.0,0,1,0,1,1,'Ever-Devouring Shoulderguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256924,0,264637,1.0,0,1,0,1,1,'Cosmic Hunter''s Glaive');
-- NPC 256925: 15 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256925,0,257085,1.0,0,1,0,1,1,'Augmented Stormray');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256925,0,258924,1.0,0,1,0,1,1,'Tarnished Dawnlit Corsair''s Breeches');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256925,0,258931,1.0,0,1,0,1,1,'Tarnished Dawnlit Sentinel''s Cover');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256925,0,236965,1.0,0,1,0,1,1,'Bright Linen');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256925,0,245839,1.0,0,1,0,1,1,'Two of Void');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256925,0,258849,5.0,0,1,0,1,1,'Stained Headguard');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256925,0,258853,5.0,0,1,0,1,1,'Stained Sabatons');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256925,0,258856,5.0,0,1,0,1,1,'Threadbare Mantle');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256925,0,258865,5.0,0,1,0,1,1,'Brittle Breastplate');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256925,0,258878,5.0,0,1,0,1,1,'Frayed Boots');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256925,0,258917,1.0,0,1,0,1,1,'Tarnished Dawnlit Spellbinder''s Pads');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256925,0,258850,5.0,0,1,0,1,1,'Stained Fistguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256925,0,258875,5.0,0,1,0,1,1,'Frayed Britches');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256925,0,264548,1.0,0,1,0,1,1,'Sash of Cosmic Tranquility');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256925,0,264632,1.0,0,1,0,1,1,'Darkblossom''s Crook');
-- NPC 256926: 11 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256926,0,260635,1.0,0,1,0,1,1,'Sanguine Harrower');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256926,0,258935,1.0,0,1,0,1,1,'Tarnished Dawnlit Sentinel''s Armguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256926,0,251923,1.0,0,1,0,1,1,'Thalassian Essence of the Faire');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256926,0,258930,1.0,0,1,0,1,1,'Tarnished Dawnlit Sentinel''s Handguards');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256926,0,260687,5.0,0,1,0,1,1,'Decaying Leather');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256926,0,258926,1.0,0,1,0,1,1,'Tarnished Dawnlit Corsair''s Belt');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256926,0,258956,1.0,0,1,0,1,1,'Tarnished Dawnlit Scepter');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256926,0,260638,5.0,0,1,0,1,1,'Fine Void Residue');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256926,0,260655,5.0,0,1,0,1,1,'Decaying Humanoid Flesh');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256926,0,264533,1.0,0,1,0,1,1,'Queen''s Tentacle Sash');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (256926,0,264601,1.0,0,1,0,1,1,'Queen''s Eye Band');
-- NPC 257027: 7 loot items
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (257027,0,248086,5.0,0,1,0,1,1,'Void Essence');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (257027,0,251786,1.0,0,1,0,1,1,'Ever-Collapsing Void Fissure');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (257027,0,264694,1.0,0,1,0,1,1,'Ultradon Cuirass');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (257027,0,264701,1.0,0,1,0,1,1,'Cosmic Bell');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (257027,0,246951,1.0,0,1,0,1,1,'Stormarion Core');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (257027,0,264561,1.0,0,1,0,1,1,'Primal Bonestompers');
INSERT IGNORE INTO `creature_loot_template` (`Entry`,`ItemType`,`Item`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`) VALUES (257027,0,264630,1.0,0,1,0,1,1,'Colossal Voidsunderer');

-- creature_template_spell: 526 new entries across 61 NPCs
-- NPC 122313 (Zuraal the Ascended): 13 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122313,0,244579,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122313,1,244588,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122313,2,244653,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122313,3,244657,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122313,4,246133,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122313,5,246134,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122313,6,246139,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122313,7,246913,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122313,8,247038,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122313,9,1263297,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122313,10,1263399,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122313,11,1263440,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122313,12,1268916,0);
-- NPC 122316 (Saprish &lt;Ethereum-Lord of the Shadowguard&gt;): 11 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122316,0,246026,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122316,1,246943,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122316,2,247145,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122316,3,247175,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122316,4,247245,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122316,5,247246,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122316,6,1263508,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122316,7,1263523,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122316,8,1266449,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122316,9,1268840,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (122316,10,1280067,0);
-- NPC 124309 (Viceroy Nezhar): 8 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (124309,0,244750,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (124309,1,1263529,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (124309,2,1263533,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (124309,3,1263538,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (124309,4,1263542,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (124309,5,1264257,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (124309,6,1265030,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (124309,7,1277358,0);
-- NPC 178942 (Prototype Aquilon): 3 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (178942,0,353088,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (178942,1,353090,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (178942,2,353092,0);
-- NPC 190609 (Echo of Doragosa &lt;Headteacher&gt;): 16 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,0,344663,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,1,373326,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,2,374343,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,3,374350,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,4,374352,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,5,374361,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,6,387970,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,7,388822,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,8,388901,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,9,388951,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,10,389011,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,11,439488,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,12,454362,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,13,454365,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,14,454366,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (190609,15,1282251,0);
-- NPC 191736 (Crawth): 17 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,0,181089,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,1,344663,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,2,376448,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,3,376467,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,4,376997,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,5,377004,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,6,377009,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,7,377034,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,8,377182,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,9,389481,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,10,389483,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,11,393211,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,12,397210,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,13,454341,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,14,454782,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,15,1276752,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (191736,16,1285508,0);
-- NPC 194181 (Vexamus): 9 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (194181,0,385958,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (194181,1,386173,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (194181,2,386181,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (194181,3,386201,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (194181,4,387691,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (194181,5,388537,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (194181,6,388651,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (194181,7,454314,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (194181,8,454782,0);
-- NPC 19554 (Dimensius the All-Devouring): 5 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (19554,3,37396,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (19554,4,37397,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (19554,5,37399,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (19554,6,37405,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (19554,7,37409,0);
-- NPC 196482 (Overgrown Ancient): 9 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (196482,0,288865,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (196482,1,344663,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (196482,2,388544,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (196482,3,388623,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (196482,4,388796,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (196482,5,388923,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (196482,6,390297,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (196482,7,396716,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (196482,8,454782,0);
-- NPC 207283 (Delvers'' Supplies): 5 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (207283,0,456666,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (207283,1,459064,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (207283,2,459069,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (207283,3,459073,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (207283,4,1214889,0);
-- NPC 214650 (L''ura): 43 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,0,1244412,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,1,1249582,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,2,1249584,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,3,1249609,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,4,1249796,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,5,1250898,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,6,1251386,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,7,1251649,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,8,1253915,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,9,1254642,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,10,1260261,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,11,1262055,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,12,1263253,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,13,1263970,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,14,1265842,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,15,1266388,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,16,1266622,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,17,1266897,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,18,1266898,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,19,1273158,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,20,1274455,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,21,1276062,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,22,1276529,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,23,1279420,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,24,1279463,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,25,1281184,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,26,1281194,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,27,1282008,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,28,1282027,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,29,1282034,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,30,1282246,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,31,1282249,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,32,1282373,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,33,1282412,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,34,1282441,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,35,1284525,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,36,1284638,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,37,1284931,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,38,1284980,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,39,1285561,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,40,1285685,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,41,1285827,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (214650,42,1287702,0);
-- NPC 231606 (Emberdawn): 6 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231606,0,465904,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231606,1,466064,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231606,2,466556,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231606,3,467120,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231606,4,469633,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231606,5,1217762,0);
-- NPC 231626 (Kalis): 4 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231626,0,472724,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231626,1,472736,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231626,2,474105,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231626,3,1219551,0);
-- NPC 231631 (Commander Kroluk &lt;Old Horde&gt;): 12 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231631,0,467620,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231631,1,467815,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231631,2,468070,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231631,3,470963,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231631,4,472043,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231631,5,472081,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231631,6,1217094,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231631,7,1250851,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231631,8,1251981,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231631,9,1253026,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231631,10,1270620,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231631,11,1283357,0);
-- NPC 231636 (Restless Heart): 9 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231636,0,468429,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231636,1,468442,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231636,2,472556,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231636,3,472662,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231636,4,474528,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231636,5,1216042,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231636,6,1253977,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231636,7,1253986,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231636,8,1282932,0);
-- NPC 231863 (Seranel Sunlash): 6 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231863,0,1224903,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231863,1,1225135,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231863,2,1225193,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231863,3,1225792,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231863,4,1246446,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231863,5,1248689,0);
-- NPC 231864 (Gemellus): 7 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231864,0,1223847,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231864,1,1223936,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231864,2,1224100,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231864,3,1224299,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231864,4,1224401,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231864,5,1253707,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231864,6,1284958,0);
-- NPC 231865 (Degentrius): 9 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231865,0,1214714,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231865,1,1215087,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231865,2,1215161,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231865,3,1215897,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231865,4,1269631,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231865,5,1271066,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231865,6,1280113,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231865,7,1284627,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (231865,8,1284628,0);
-- NPC 233753 (Muradin Bronzebeard &lt;Ambassador of Ironforge&gt;): 2 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (233753,0,1240116,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (233753,1,1240124,0);
-- NPC 234647 (Xathuux the Annihilator &lt;Lithiel''s Guardian&gt;): 5 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (234647,0,473898,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (234647,1,474197,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (234647,2,474234,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (234647,3,1214650,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (234647,4,1214663,0);
-- NPC 234649 (Zaen Bladesorrow): 6 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (234649,0,474478,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (234649,1,474515,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (234649,2,474765,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (234649,3,1214357,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (234649,4,1218347,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (234649,5,1222795,0);
-- NPC 23576 (Nalorakk &lt;Bear Avatar&gt;): 5 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (23576,0,42384,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (23576,1,42395,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (23576,2,42402,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (23576,3,270992,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (23576,4,1256047,0);
-- NPC 237415 (Lithiel Cinderfury): 8 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (237415,0,474375,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (237415,1,474457,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (237415,2,1214675,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (237415,3,1216945,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (237415,4,1217384,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (237415,5,1217415,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (237415,6,1226469,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (237415,7,1231262,0);
-- NPC 238887 (Taz''Rah): 4 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (238887,0,1222085,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (238887,1,1222199,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (238887,2,1225107,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (238887,3,1263593,0);
-- NPC 239008 (Atroxus): 10 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (239008,0,1222371,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (239008,1,1222484,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (239008,2,1222642,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (239008,3,1222692,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (239008,4,1222724,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (239008,5,1226031,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (239008,6,1262497,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (239008,7,1263971,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (239008,8,1282892,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (239008,9,1283506,0);
-- NPC 240432 (Fallen-King Salhadaar): 14 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240432,0,1245592,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240432,1,1245960,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240432,2,1246175,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240432,3,1247738,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240432,4,1248697,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240432,5,1248709,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240432,6,1250686,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240432,7,1250828,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240432,8,1250991,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240432,9,1251213,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240432,10,1253032,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240432,11,1254081,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240432,12,1260015,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240432,13,1271577,0);
-- NPC 240434 (Vorasius): 9 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240434,0,1241692,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240434,1,1241844,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240434,2,1244419,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240434,3,1254199,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240434,4,1256855,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240434,5,1260052,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240434,6,1272937,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240434,7,1273067,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240434,8,1280101,0);
-- NPC 240435 (Imperator Averzian): 12 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240435,0,1249251,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240435,1,1249262,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240435,2,1251361,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240435,3,1251583,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240435,4,1253918,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240435,5,1258883,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240435,6,1260712,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240435,7,1265540,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240435,8,1280015,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240435,9,1280075,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240435,10,1283069,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (240435,11,1284786,0);
-- NPC 241546 (Lothraxion &lt;High Commander&gt;): 5 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (241546,0,1253848,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (241546,1,1253950,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (241546,2,1255389,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (241546,3,1257613,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (241546,4,1271511,0);
-- NPC 242056 (Vaelgor): 14 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (242056,0,1244221,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (242056,1,1244413,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (242056,2,1244672,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (242056,3,1248847,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (242056,4,1249748,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (242056,5,1252157,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (242056,6,1262623,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (242056,7,1264467,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (242056,8,1265131,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (242056,9,1266570,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (242056,10,1270189,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (242056,11,1270250,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (242056,12,1272867,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (242056,13,1280458,0);
-- NPC 243028 (Meittik): 3 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (243028,0,1234753,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (243028,1,1234782,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (243028,2,1276586,0);
-- NPC 244424 (Cragpine): 4 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244424,0,1235131,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244424,1,1235134,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244424,2,1235144,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244424,3,1257906,0);
-- NPC 244761 (Alleria Windrunner): 25 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,0,1232467,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,1,1232470,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,2,1232784,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,3,1233602,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,4,1233689,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,5,1233865,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,6,1234564,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,7,1234569,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,8,1235622,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,9,1237038,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,10,1237614,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,11,1237729,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,12,1237837,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,13,1238206,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,14,1238708,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,15,1238843,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,16,1239080,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,17,1239089,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,18,1242553,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,19,1243982,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,20,1245874,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,21,1255368,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,22,1255378,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,23,1256787,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244761,24,1260000,0);
-- NPC 244762 (Lu''ashal): 6 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244762,0,1243963,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244762,1,1243988,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244762,2,1258426,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244762,3,1258427,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244762,4,1276247,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244762,5,1276436,0);
-- NPC 244887 (Ikuzz the Light Hunter): 8 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244887,0,1236658,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244887,1,1236709,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244887,2,1236746,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244887,3,1237073,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244887,4,1237090,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244887,5,1237093,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244887,6,1237166,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (244887,7,1272290,0);
-- NPC 245912 (Lightwarden Ruia): 9 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (245912,0,1239821,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (245912,1,1239824,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (245912,2,1239830,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (245912,3,1240098,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (245912,4,1240210,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (245912,5,1241058,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (245912,6,1241067,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (245912,7,1257094,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (245912,8,1272265,0);
-- NPC 247570 (Muro''jin): 7 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (247570,0,1243751,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (247570,1,1249789,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (247570,2,1260643,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (247570,3,1260709,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (247570,4,1260731,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (247570,5,1266480,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (247570,6,1266488,0);
-- NPC 248015 (Charonus): 5 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248015,0,1222755,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248015,1,1223298,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248015,2,1227197,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248015,3,1248130,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248015,4,1263983,0);
-- NPC 248595 (Vordaza): 6 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248595,0,1250708,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248595,1,1251554,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248595,2,1251598,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248595,3,1252054,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248595,4,1252611,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248595,5,1264987,0);
-- NPC 248605 (Rak''tul &lt;Vessel of Souls&gt;): 9 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248605,0,1248863,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248605,1,1248980,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248605,2,1251023,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248605,3,1252676,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248605,4,1253788,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248605,5,1253844,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248605,6,1253909,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248605,7,1259810,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248605,8,1266723,0);
-- NPC 248710 (The Hoardmonger &lt;Spiritpaw Tribe&gt;): 8 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248710,0,1234021,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248710,1,1234233,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248710,2,1234681,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248710,3,1235072,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248710,4,1235105,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248710,5,1235125,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248710,6,1235129,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248710,7,1235405,0);
-- NPC 248864 (Predaxas): 3 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248864,0,1276193,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248864,1,1276320,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (248864,2,1277829,0);
-- NPC 249776 (Thorm''belan): 6 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (249776,0,1257320,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (249776,1,1257618,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (249776,2,1257737,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (249776,3,1257825,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (249776,4,1258136,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (249776,5,1258639,0);
-- NPC 250589 (War Chaplain Senn): 11 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (250589,0,1246155,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (250589,1,1246384,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (250589,2,1246391,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (250589,3,1246745,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (250589,4,1248451,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (250589,5,1248674,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (250589,6,1248710,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (250589,7,1249130,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (250589,8,1255738,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (250589,9,1258514,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (250589,10,1276982,0);
-- NPC 252458 (Kystia Manaheart): 6 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (252458,0,1217989,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (252458,1,1223906,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (252458,2,1230289,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (252458,3,1230298,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (252458,4,1264095,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (252458,5,1264106,0);
-- NPC 254227 (Corewarden Nysarra): 7 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (254227,0,1247937,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (254227,1,1247976,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (254227,2,1249014,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (254227,3,1252703,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (254227,4,1252828,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (254227,5,1252883,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (254227,6,1253965,0);
-- NPC 256116 (Chimaerus &lt;The Undreamt God&gt;): 22 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,0,1245396,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,1,1245406,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,2,1245486,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,3,1245698,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,4,1245727,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,5,1245844,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,6,1245919,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,7,1246132,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,8,1246621,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,9,1246653,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,10,1250953,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,11,1252863,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,12,1253744,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,13,1257085,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,14,1257087,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,15,1257093,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,16,1258610,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,17,1262289,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,18,1264756,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,19,1267201,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,20,1272726,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (256116,21,1282001,0);
-- NPC 258189 (Enraged Bloodclaw): 2 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (258189,0,1277694,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (258189,1,1277711,0);
-- NPC 258200 (Ingested Consumptor): 2 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (258200,0,1276988,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (258200,1,1277043,0);
-- NPC 258202 (Radiating Voidtick): 1 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (258202,0,1276884,0);
-- NPC 36476 (Ick &lt;Krick''s Minion&gt;): 6 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36476,0,69021,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36476,1,1264192,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36476,2,1264287,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36476,3,1264299,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36476,4,1264336,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36476,5,1264349,0);
-- NPC 36477 (Krick): 12 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36477,0,69024,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36477,1,69028,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36477,2,69413,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36477,3,1264027,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36477,4,1264186,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36477,5,1264299,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36477,6,1264363,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36477,7,1264453,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36477,8,1264461,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36477,9,1271678,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36477,10,1278893,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36477,11,1279667,0);
-- NPC 36494 (Forgemaster Garfrost): 14 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36494,0,68771,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36494,1,68774,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36494,2,68785,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36494,3,68786,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36494,4,68788,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36494,5,70326,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36494,6,1261299,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36494,7,1261546,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36494,8,1261799,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36494,9,1261806,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36494,10,1261847,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36494,11,1261921,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36494,12,1262029,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36494,13,1272433,0);
-- NPC 36658 (Scourgelord Tyrannus): 11 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36658,0,69155,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36658,1,69167,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36658,2,69172,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36658,3,69275,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36658,4,1262582,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36658,5,1263406,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36658,6,1263671,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36658,7,1263756,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36658,8,1276357,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36658,9,1276391,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36658,10,1276648,0);
-- NPC 36954 (The Lich King): 6 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36954,0,69409,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36954,1,69780,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36954,2,70063,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36954,3,74115,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36954,4,397239,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (36954,5,1240266,0);
-- NPC 38112 (Falric): 9 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (38112,0,72390,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (38112,1,72391,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (38112,2,72395,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (38112,3,72396,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (38112,4,72397,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (38112,5,72422,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (38112,6,72426,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (38112,7,72435,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (38112,8,365958,0);
-- NPC 38113 (Marwyn): 5 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (38113,0,49020,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (38113,1,72360,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (38113,2,72362,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (38113,3,72363,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (38113,4,341941,0);
-- NPC 75964 (Ranjit &lt;Master of the Four Winds&gt;): 12 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (75964,0,153123,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (75964,1,153139,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (75964,2,153315,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (75964,3,153544,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (75964,4,153757,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (75964,5,153759,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (75964,6,156793,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (75964,7,165731,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (75964,8,165733,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (75964,9,1252691,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (75964,10,1258140,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (75964,11,1258152,0);
-- NPC 76141 (Araknath &lt;Construct of the Sun&gt;): 10 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (76141,0,154110,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (76141,1,154113,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (76141,2,154132,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (76141,3,154135,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (76141,4,154139,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (76141,5,154150,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (76141,6,1252877,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (76141,7,1279002,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (76141,8,1281874,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (76141,9,1283770,0);
-- NPC 76266 (High Sage Viryx): 1 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (76266,0,154396,0);
-- NPC 76379 (Rukhran): 4 abilities
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (76379,0,153898,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (76379,1,159381,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (76379,2,1253510,0);
INSERT IGNORE INTO `creature_template_spell` (`CreatureID`,`Index`,`Spell`,`VerifiedBuild`) VALUES (76379,3,1253519,0);
