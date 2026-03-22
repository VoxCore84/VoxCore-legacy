-- Add class_expansion_requirement entries for Haranir races
-- Race 86 = Haranir (Horde), Race 91 = Haranir (Alliance)
-- Classes: Warrior(1), Hunter(3), Rogue(4), Priest(5), Shaman(7), Mage(8), Warlock(9), Monk(10), Druid(11)
-- Without these rows, Haranir races don't appear in character creation (no AvailableClasses data)

DELETE FROM `class_expansion_requirement` WHERE `RaceID` IN (86, 91);
INSERT INTO `class_expansion_requirement` (`ClassID`, `RaceID`, `ActiveExpansionLevel`, `AccountExpansionLevel`) VALUES
(1,  86, 11, 11),
(3,  86, 11, 11),
(4,  86, 11, 11),
(5,  86, 11, 11),
(7,  86, 11, 11),
(8,  86, 11, 11),
(9,  86, 11, 11),
(10, 86, 11, 11),
(11, 86, 11, 11),
(1,  91, 11, 11),
(3,  91, 11, 11),
(4,  91, 11, 11),
(5,  91, 11, 11),
(7,  91, 11, 11),
(8,  91, 11, 11),
(9,  91, 11, 11),
(10, 91, 11, 11),
(11, 91, 11, 11);
