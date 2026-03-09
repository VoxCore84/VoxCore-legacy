"""DBErrors.log parser -- 47 categorized patterns from parse_dberrors.py."""

from __future__ import annotations

import re
from typing import TYPE_CHECKING

from .base import ParsedEntry, Severity, extract_ts

if TYPE_CHECKING:
    from ..config import Config

# -- 47 patterns absorbed from tools/parse_dberrors.py -------------------------
# Format: (compiled_regex, category_name, addressed_by_cleanup)

_PATTERNS: list[tuple[re.Pattern, str, bool]] = [
    # Hotfix
    (re.compile(r"hotfix_data.*unknown DB2 store by hash"), "hotfix_data (unknown hash)", False),
    # Spell proc
    (re.compile(r"Spell Id \d+ has DBC ProcFlags"), "spell_proc (missing entry)", False),
    # Creature template
    (re.compile(r"No model data exist for `CreatureDisplayID` = \d+ listed by creature"), "creature_model (bad displayID)", False),
    (re.compile(r"Creature \(Entry: \d+\) has non-existing faction template"), "creature (bad faction)", False),
    (re.compile(r"Creature \(Entry: \d+\) has non-existing Spell"), "creature_spell (bad spell)", False),
    (re.compile(r"Creature \(Entry: \d+\) has invalid unit_class"), "creature (bad unit_class)", False),
    (re.compile(r"Creature \(Entry: \d+\) does not have any existing display"), "creature_model (no display)", False),
    (re.compile(r"Creature \(Entry: \d+\) has invalid creature family"), "creature (bad family)", False),
    # Creature equip
    (re.compile(r"Item \(ID=\d+\) in creature_equip_template\.ItemID\d+.*not equipable"), "creature_equip (bad item)", False),
    (re.compile(r"Creature equipment template with id 0 found for creature"), "creature_equip (id=0)", False),
    # Creature template addon
    (re.compile(r"Creature \(Entry: \d+\) has invalid displayInfoId.*mount.*creature_template_addon"), "creature_addon (bad mount)", False),
    (re.compile(r"Creature template \(Entry: \d+\) does not exist but has.*creature_template_addon"), "creature_addon (orphan)", False),
    (re.compile(r"Creature \(Entry: \d+\) has invalid aiAnimKit.*creature_template_addon"), "creature_addon (aiAnimKit)", False),
    # Creature spawn
    (re.compile(r"Table `creature`.*phaseid.*does not exist"), "spawn (bad phaseID)", False),
    (re.compile(r"Table `creature`.*unsupported difficulty"), "spawn (bad difficulty)", False),
    (re.compile(r"Table `creature`.*not spawned in any difficulty"), "spawn (no difficulty)", False),
    (re.compile(r"Table `creature`.*nonexistent map"), "spawn (bad map)", False),
    (re.compile(r"Table `creature`.*both `phaseid` and `phasegroup` set"), "spawn (phase conflict)", False),
    (re.compile(r"Table `creature`.*invalid `curHealthPct`"), "spawn (curHealthPct)", False),
    (re.compile(r"Table `creature`.*UNIT_FLAG3_FAKE_DEAD.*IMMUNE"), "spawn (FAKE_DEAD flag)", False),
    (re.compile(r"Table `creature`.*terrainSwapMap.*cannot be used"), "spawn (terrainSwapMap)", True),
    (re.compile(r"Table `creature`.*MovementType.*0.*idle.*wander_distance"), "spawn (wander_distance)", False),
    # Gameobject
    (re.compile(r"Table `gameobject`.*unsupported difficulty"), "gameobject (difficulty)", False),
    (re.compile(r"Table `gameobject`.*spawntimesecs.*\(0\)"), "gameobject (spawntimesecs)", True),
    # Quest
    (re.compile(r"Quest \d+ has PrevQuestId \d+, but no such quest"), "quest (PrevQuestId)", False),
    (re.compile(r"Quest \d+ has NextQuestId \d+, but no such quest"), "quest (NextQuestId)", False),
    (re.compile(r"Quest \d+ objective \d+ has non existing creature entry"), "quest_objectives (creature)", False),
    (re.compile(r"Quest \d+ objective \d+ has non existing gameobject entry"), "quest_objectives (gameobject)", False),
    (re.compile(r"Quest \d+ objective \d+ has non existing item entry"), "quest_objectives (item)", False),
    (re.compile(r"Quest \d+ objective \d+ has non existing areatrigger"), "quest_objectives (areatrigger)", False),
    (re.compile(r"Quest \d+ objective \d+ has non existing spell id"), "quest_objectives (spell)", False),
    (re.compile(r"Quest \d+ objective \d+ has unhandled type"), "quest_objectives (unhandled type)", False),
    (re.compile(r"Quest \d+ has `RewardSpellCast`.*spell.*does not exist"), "quest (RewardSpellCast)", False),
    (re.compile(r"Quest \d+ has `SourceItemId`.*item.*does not exist"), "quest (SourceItemId)", False),
    (re.compile(r"Quest \d+ has `StartItem`.*`ProvidedItemCount` = 0"), "quest (ProvidedItemCount)", False),
    # Loot
    (re.compile(r"creature_loot_template.*item does not exist"), "creature_loot (bad item)", True),
    (re.compile(r"gameobject_loot_template.*item does not exist"), "go_loot (bad item)", True),
    (re.compile(r"gameobject_loot_template.*isn't gameobject entry.*not referenced"), "go_loot (orphan)", True),
    (re.compile(r"gameobject_loot_template.*total chance > 100"), "go_loot (chance>100%)", False),
    (re.compile(r"gameobject_loot_template.*chance=0%"), "go_loot (chance=0%)", False),
    (re.compile(r"spell_loot_template.*does not exist but.*used by Spell"), "spell_loot (missing)", False),
    (re.compile(r"creature_static_flags_override.*nonexistent"), "static_flags (orphan)", False),
    # Scripts
    (re.compile(r"Script '.+' is referenced.*does not exist in the core"), "scripts (missing)", False),
    # SmartAI
    (re.compile(r"SmartAIMgr.*SMART_EVENT_QUEST_OBJ_COMPLETION.*invalid objective id 0"), "smartai (quest obj id=0)", False),
    (re.compile(r"SmartAIMgr.*SPELL_EFFECT_KILL_CREDIT.*invalid target"), "smartai (invalid target)", False),
    (re.compile(r"SmartAIMgr.*Kill Credit.*killcredit spell exists"), "smartai (killcredit warn)", False),
    (re.compile(r"SmartAIMgr.*is not using SmartAI"), "smartai (wrong AIName)", False),
    (re.compile(r"SmartAIMgr.*Creature guid.*does not exist"), "smartai (missing creature)", False),
    (re.compile(r"SmartAIMgr.*AreaTrigger entry"), "smartai (areatrigger)", False),
    (re.compile(r"SmartAIMgr.*Link.*not found"), "smartai (broken link)", False),
    (re.compile(r"SmartAIMgr.*Unused action_type"), "smartai (unused action)", False),
    (re.compile(r"SmartAIMgr.*uses param.*valid values"), "smartai (param validation)", False),
    (re.compile(r"SmartAIMgr.*non-existent Spell"), "smartai (bad spell)", False),
    (re.compile(r"SmartAIMgr.*invalid creature entry"), "smartai (creature mismatch)", False),
    (re.compile(r"SmartAIMgr.*has abs"), "smartai (bad orientation)", False),
    (re.compile(r"SmartAIMgr.*incorrect TempSummonType"), "smartai (TempSummonType)", False),
    # Misc
    (re.compile(r"Table `command`.*non-exist"), "command (stale)", False),
    (re.compile(r"BattlegroundMgr.*bad mapid"), "battleground_template", False),
    (re.compile(r"class_expansion_requirement.*does not exists"), "class_expansion_requirement", False),
    (re.compile(r"scenario_poi.*CriteriaTreeID"), "scenario_poi", False),
]


class DBErrorsParser:
    name = "DBError"
    log_file = "DBErrors.log"

    def __init__(self, config: Config) -> None:
        pass

    def parse_lines(
        self, lines: list[str], line_offset: int = 0
    ) -> list[ParsedEntry]:
        entries: list[ParsedEntry] = []

        for i, line in enumerate(lines):
            stripped = line.rstrip("\n\r")
            if not stripped:
                continue

            lineno = line_offset + i + 1
            ts = extract_ts(stripped) or ""

            # Match against all patterns
            category = "uncategorized"
            addressed = False
            for regex, cat, addr in _PATTERNS:
                if regex.search(stripped):
                    category = cat
                    addressed = addr
                    break

            entries.append(
                ParsedEntry(
                    timestamp=ts,
                    source=self.name,
                    category=category,
                    severity=Severity.WARN,  # DB errors are load-time warnings
                    text=stripped[:300],
                    line_number=lineno,
                    metadata={"addressed": addressed},
                )
            )

        return entries


def create(config: Config) -> DBErrorsParser:
    return DBErrorsParser(config)
