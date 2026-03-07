#!/usr/bin/env python3
"""
audit_empty_services.py

Audits NPCs that have vendor/trainer flags but no corresponding service data.
Categorizes each as scripted, genuine gap, unspawned, wrong type, etc.
Generates a report and conservative SQL fixes.
"""

import csv
import os
import re
import subprocess
import sys
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Optional

# --- Config ---
MYSQL_BIN = r"C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe"
MYSQL_USER = "root"
MYSQL_PASS = "admin"
MYSQL_DB = "world"

WOWHEAD_ROLES_CSV = r"C:/Users/atayl/VoxCore/wago/wowhead_data/npc/npc_roles.csv"
WOWHEAD_SUBTITLES_CSV = r"C:/Users/atayl/VoxCore/wago/wowhead_data/npc/npc_subtitles.csv"

REPORT_PATH = r"C:/Users/atayl/VoxCore/sql/exports/cleanup/empty_services_report.txt"
SQL_FIX_PATH = r"C:/Users/atayl/VoxCore/sql/exports/cleanup/npc_empty_service_fixes.sql"

# npcflag bits
VENDOR_FLAG = 128     # 0x80
TRAINER_FLAG = 16     # 0x10

# creature type enum
CREATURE_TYPES = {
    0: "None", 1: "Beast", 2: "Dragonkin", 3: "Demon", 4: "Elemental",
    5: "Giant", 6: "Undead", 7: "Humanoid", 8: "Critter", 9: "Mechanical",
    10: "Not specified", 11: "Totem", 12: "Non-combat Pet", 13: "Gas Cloud",
    14: "Wild Pet", 15: "Aberration"
}

# Subtitle patterns that suggest a genuine vendor
VENDOR_SUBTITLE_PATTERNS = [
    r'\bvendor\b', r'\bmerchant\b', r'\bsuppl', r'\bsmith\b', r'\bbowyer\b',
    r'\btrade\b', r'\bgoods\b', r'\bwares\b', r'\barmor\b', r'\bweapon\b',
    r'\bgeneral\b', r'\bfood\b', r'\bdrink\b', r'\bbaker\b', r'\bbrewer\b',
    r'\btailor\b', r'\bleather\b', r'\bcloth\b', r'\bmail\b', r'\bplate\b',
    r'\breagent\b', r'\bpoison\b', r'\bherb\b', r'\balchem\b', r'\bflask\b',
    r'\brepair\b', r'\binnkeeper\b', r'\bammo\b', r'\barrow\b', r'\bbullet\b',
    r'\bstable\b', r'\bfruit\b', r'\bbread\b', r'\bmeat\b', r'\bfish\b',
    r'\bjewel\b', r'\bgem\b', r'\bscribe\b', r'\bink\b', r'\bparchment\b',
    r'\bengine\b', r'\bmining\b', r'\bpick\b', r'\btabard\b', r'\btoy\b',
    r'\bpet\b', r'\bmount\b', r'\brecipe\b', r'\bpattern\b', r'\bschematic\b',
    r'\bplan\b', r'\bdesign\b', r'\bformula\b', r'\bmanual\b',
    r'\bprovisioner\b', r'\bquartermaster\b', r'\bsalvage\b',
]

# Subtitle patterns that suggest a genuine trainer
TRAINER_SUBTITLE_PATTERNS = [
    r'\btrainer\b', r'\btraining\b', r'\binstructor\b', r'\bteacher\b',
    r'\bmaster\b', r'\bgrand master\b', r'\bartisan\b', r'\bapprentice\b',
    r'\bjourneyma\b', r'\bexpert\b',
]

# Name patterns that indicate test/debug/unused NPCs
SKIP_NAME_PATTERNS = [
    r'\btest\b', r'\bdebug\b', r'\bunused\b', r'\bzzold\b', r'\b\[ph\]',
    r'\btemp\b', r'\bdummy\b', r'\bplaceholder\b', r'\bgeneric\b',
    r'\bcopy\b', r'\bmonster -\b', r'\b\[dnr\]', r'\b\[deprecated\]',
]


@dataclass
class NpcEntry:
    entry: int
    name: str
    subname: Optional[str]
    npcflag: int
    creature_type: int
    script_name: str
    has_spawns: bool = False
    is_quest_giver: bool = False
    is_quest_ender: bool = False
    wowhead_roles: list = field(default_factory=list)
    wowhead_subtitle: Optional[str] = None
    category: str = ""
    priority: int = 0  # lower = higher priority


def run_query(sql: str) -> list[list[str]]:
    """Run a MySQL query and return rows as list of string lists."""
    cmd = [MYSQL_BIN, "-u", MYSQL_USER, f"-p{MYSQL_PASS}", "-D", MYSQL_DB,
           "--batch", "--skip-column-names", "-e", sql]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    if result.returncode != 0:
        print(f"MySQL error: {result.stderr}", file=sys.stderr)
        sys.exit(1)
    rows = []
    for line in result.stdout.strip().split('\n'):
        if line:
            rows.append(line.split('\t'))
    return rows


def load_wowhead_roles() -> dict[int, list[str]]:
    """Load Wowhead detected roles by NPC ID."""
    roles = {}
    if not os.path.exists(WOWHEAD_ROLES_CSV):
        print(f"Warning: {WOWHEAD_ROLES_CSV} not found, skipping", file=sys.stderr)
        return roles
    with open(WOWHEAD_ROLES_CSV, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            npc_id = int(row['id'])
            detected = row.get('detected_roles', '').strip()
            if detected:
                roles[npc_id] = [r.strip() for r in detected.split(',')]
            else:
                roles[npc_id] = []
    return roles


def load_wowhead_subtitles() -> dict[int, str]:
    """Load Wowhead subtitles by NPC ID."""
    subs = {}
    if not os.path.exists(WOWHEAD_SUBTITLES_CSV):
        print(f"Warning: {WOWHEAD_SUBTITLES_CSV} not found, skipping", file=sys.stderr)
        return subs
    with open(WOWHEAD_SUBTITLES_CSV, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            npc_id = int(row['id'])
            subtitle = row.get('subtitle', '').strip()
            if subtitle:
                subs[npc_id] = subtitle
    return subs


def matches_patterns(text: str, patterns: list[str]) -> bool:
    """Check if text matches any of the given regex patterns (case-insensitive)."""
    if not text:
        return False
    text_lower = text.lower()
    for pattern in patterns:
        if re.search(pattern, text_lower):
            return True
    return False


def categorize_vendor(npc: NpcEntry) -> tuple[str, int]:
    """Categorize an empty vendor. Returns (category, priority)."""
    name_lower = (npc.name or "").lower()
    sub_lower = (npc.subname or "").lower()
    wh_sub_lower = (npc.wowhead_subtitle or "").lower()

    # 1. Skip test/debug/unused
    if matches_patterns(npc.name, SKIP_NAME_PATTERNS):
        return ("test_debug_unused", 99)

    # 2. Has C++ ScriptName -> likely scripted
    if npc.script_name:
        return ("scripted_cpp", 80)

    # 3. Not spawned -> doesn't matter
    if not npc.has_spawns:
        return ("unspawned", 90)

    # 4. Weird creature type (Critter=8, Non-combat Pet=12, Totem=11, Gas Cloud=13)
    if npc.creature_type in (8, 11, 12, 13, 14):
        return ("wrong_type", 20)

    # 5. Wowhead says vendor role
    if 'vendor' in npc.wowhead_roles:
        # Wowhead confirms vendor - this is a genuine gap
        if matches_patterns(npc.subname, VENDOR_SUBTITLE_PATTERNS) or \
           matches_patterns(npc.wowhead_subtitle, VENDOR_SUBTITLE_PATTERNS):
            return ("genuine_gap_confirmed", 1)
        else:
            return ("genuine_gap_wowhead", 5)

    # 6. Subtitle strongly suggests vendor
    if matches_patterns(npc.subname, VENDOR_SUBTITLE_PATTERNS):
        return ("genuine_gap_subtitle", 2)

    # 7. Wowhead subtitle suggests vendor but our DB subtitle doesn't
    if matches_patterns(npc.wowhead_subtitle, VENDOR_SUBTITLE_PATTERNS):
        return ("genuine_gap_wowhead_subtitle", 3)

    # 8. Quest-related NPC - might be quest-reward vendor
    if npc.is_quest_giver or npc.is_quest_ender:
        return ("quest_related", 50)

    # 9. Wowhead has no vendor role, no vendor subtitle - likely wrong flag
    if npc.wowhead_roles and 'vendor' not in npc.wowhead_roles:
        return ("flag_incorrect_wowhead", 10)

    # 10. No subtitle at all, no Wowhead data, spawned but no evidence of being vendor
    if not npc.subname and not npc.wowhead_subtitle:
        return ("no_evidence", 15)

    # 11. Has subtitle but not vendor-like
    if npc.subname and not matches_patterns(npc.subname, VENDOR_SUBTITLE_PATTERNS):
        return ("subtitle_not_vendor", 25)

    return ("uncategorized", 50)


def categorize_trainer(npc: NpcEntry) -> tuple[str, int]:
    """Categorize an empty trainer. Returns (category, priority)."""
    name_lower = (npc.name or "").lower()
    sub_lower = (npc.subname or "").lower()
    wh_sub_lower = (npc.wowhead_subtitle or "").lower()

    # 1. Skip test/debug/unused
    if matches_patterns(npc.name, SKIP_NAME_PATTERNS):
        return ("test_debug_unused", 99)

    # 2. Has C++ ScriptName -> likely scripted
    if npc.script_name:
        return ("scripted_cpp", 80)

    # 3. Not spawned -> doesn't matter
    if not npc.has_spawns:
        return ("unspawned", 90)

    # 4. Weird creature type
    if npc.creature_type in (8, 11, 12, 13, 14):
        return ("wrong_type", 20)

    # 5. Wowhead says trainer role
    if 'trainer' in npc.wowhead_roles:
        if matches_patterns(npc.subname, TRAINER_SUBTITLE_PATTERNS) or \
           matches_patterns(npc.wowhead_subtitle, TRAINER_SUBTITLE_PATTERNS):
            return ("genuine_gap_confirmed", 1)
        else:
            return ("genuine_gap_wowhead", 5)

    # 6. Subtitle strongly suggests trainer
    if matches_patterns(npc.subname, TRAINER_SUBTITLE_PATTERNS):
        return ("genuine_gap_subtitle", 2)

    # 7. Wowhead subtitle suggests trainer
    if matches_patterns(npc.wowhead_subtitle, TRAINER_SUBTITLE_PATTERNS):
        return ("genuine_gap_wowhead_subtitle", 3)

    # 8. Quest-related
    if npc.is_quest_giver or npc.is_quest_ender:
        return ("quest_related", 50)

    # 9. Wowhead has roles but not trainer
    if npc.wowhead_roles and 'trainer' not in npc.wowhead_roles:
        return ("flag_incorrect_wowhead", 10)

    # 10. No evidence
    if not npc.subname and not npc.wowhead_subtitle:
        return ("no_evidence", 15)

    # 11. Subtitle doesn't suggest trainer
    if npc.subname and not matches_patterns(npc.subname, TRAINER_SUBTITLE_PATTERNS):
        return ("subtitle_not_trainer", 25)

    return ("uncategorized", 50)


def main():
    print("=== Empty Services Audit ===")
    print()

    # Load Wowhead reference data
    print("Loading Wowhead roles data...")
    wh_roles = load_wowhead_roles()
    print(f"  Loaded {len(wh_roles)} NPC role entries")

    print("Loading Wowhead subtitles data...")
    wh_subtitles = load_wowhead_subtitles()
    print(f"  Loaded {len(wh_subtitles)} NPC subtitle entries")

    # --- Query empty vendors ---
    print("\nQuerying empty vendors...")
    vendor_sql = """
        SELECT ct.entry, ct.name, ct.subname, ct.npcflag, ct.type, ct.ScriptName
        FROM creature_template ct
        WHERE (ct.npcflag & 128) = 128
        AND ct.entry NOT IN (SELECT DISTINCT entry FROM npc_vendor)
        ORDER BY ct.entry
    """
    vendor_rows = run_query(vendor_sql)
    print(f"  Found {len(vendor_rows)} empty vendors")

    # --- Query empty trainers ---
    print("Querying empty trainers...")
    trainer_sql = """
        SELECT ct.entry, ct.name, ct.subname, ct.npcflag, ct.type, ct.ScriptName
        FROM creature_template ct
        WHERE (ct.npcflag & 16) = 16
        AND ct.entry NOT IN (SELECT DISTINCT CreatureID FROM creature_trainer)
        ORDER BY ct.entry
    """
    trainer_rows = run_query(trainer_sql)
    print(f"  Found {len(trainer_rows)} empty trainers")

    # Collect all entry IDs for batch queries
    all_entries = set()
    for row in vendor_rows + trainer_rows:
        all_entries.add(int(row[0]))

    if not all_entries:
        print("No empty vendors or trainers found. Exiting.")
        return

    # --- Batch query: which entries have spawns ---
    print("\nQuerying spawn data...")
    # Do this in chunks to avoid query length limits
    spawned_entries = set()
    entry_list = sorted(all_entries)
    chunk_size = 500
    for i in range(0, len(entry_list), chunk_size):
        chunk = entry_list[i:i + chunk_size]
        ids_str = ",".join(str(e) for e in chunk)
        spawn_sql = f"SELECT DISTINCT id FROM creature WHERE id IN ({ids_str})"
        spawn_rows = run_query(spawn_sql)
        for row in spawn_rows:
            spawned_entries.add(int(row[0]))
    print(f"  {len(spawned_entries)} of {len(all_entries)} entries have world spawns")

    # --- Batch query: quest starters/enders ---
    print("Querying quest starter/ender data...")
    quest_starter_entries = set()
    quest_ender_entries = set()
    for i in range(0, len(entry_list), chunk_size):
        chunk = entry_list[i:i + chunk_size]
        ids_str = ",".join(str(e) for e in chunk)

        qs_sql = f"SELECT DISTINCT id FROM creature_queststarter WHERE id IN ({ids_str})"
        qs_rows = run_query(qs_sql)
        for row in qs_rows:
            quest_starter_entries.add(int(row[0]))

        qe_sql = f"SELECT DISTINCT id FROM creature_questender WHERE id IN ({ids_str})"
        qe_rows = run_query(qe_sql)
        for row in qe_rows:
            quest_ender_entries.add(int(row[0]))
    print(f"  {len(quest_starter_entries)} quest starters, {len(quest_ender_entries)} quest enders")

    # --- Build NPC objects for vendors ---
    def build_npc(row: list[str]) -> NpcEntry:
        # Pad row to 6 elements - empty ScriptName may not appear in tab output
        while len(row) < 6:
            row.append("")
        entry = int(row[0])
        name = row[1] if row[1] != "NULL" else ""
        subname = row[2] if row[2] not in ("NULL", "") else None
        npcflag = int(row[3])
        creature_type = int(row[4])
        script_name = row[5] if row[5] not in ("NULL", "") else ""

        npc = NpcEntry(
            entry=entry,
            name=name,
            subname=subname,
            npcflag=npcflag,
            creature_type=creature_type,
            script_name=script_name,
            has_spawns=entry in spawned_entries,
            is_quest_giver=entry in quest_starter_entries,
            is_quest_ender=entry in quest_ender_entries,
            wowhead_roles=wh_roles.get(entry, []),
            wowhead_subtitle=wh_subtitles.get(entry, None),
        )
        return npc

    print("\nCategorizing vendors...")
    vendors: list[NpcEntry] = []
    for row in vendor_rows:
        npc = build_npc(row)
        npc.category, npc.priority = categorize_vendor(npc)
        vendors.append(npc)

    print("Categorizing trainers...")
    trainers: list[NpcEntry] = []
    for row in trainer_rows:
        npc = build_npc(row)
        npc.category, npc.priority = categorize_trainer(npc)
        trainers.append(npc)

    # --- Generate Report ---
    print("\nGenerating report...")

    vendor_cats = defaultdict(list)
    for v in vendors:
        vendor_cats[v.category].append(v)

    trainer_cats = defaultdict(list)
    for t in trainers:
        trainer_cats[t.category].append(t)

    cat_descriptions = {
        "genuine_gap_confirmed": "GENUINE GAP - Both Wowhead role + subtitle confirm service",
        "genuine_gap_subtitle": "GENUINE GAP - Subtitle strongly suggests service",
        "genuine_gap_wowhead": "GENUINE GAP - Wowhead role confirms, no matching subtitle",
        "genuine_gap_wowhead_subtitle": "GENUINE GAP - Wowhead subtitle suggests service",
        "scripted_cpp": "SCRIPTED - Has C++ ScriptName (likely handled in code)",
        "quest_related": "QUEST-RELATED - Is a quest giver/ender (may be quest-reward service)",
        "flag_incorrect_wowhead": "FLAG INCORRECT - Wowhead has roles but not this one",
        "wrong_type": "WRONG TYPE - Creature type doesn't match service role",
        "no_evidence": "NO EVIDENCE - No subtitle, no Wowhead data",
        "subtitle_not_vendor": "SUBTITLE MISMATCH - Has subtitle but not vendor-related",
        "subtitle_not_trainer": "SUBTITLE MISMATCH - Has subtitle but not trainer-related",
        "unspawned": "UNSPAWNED - No world spawns (doesn't matter)",
        "test_debug_unused": "TEST/DEBUG - Name indicates test or unused NPC",
        "uncategorized": "UNCATEGORIZED - Could not determine",
    }

    # Priority order for categories
    cat_priority = {
        "genuine_gap_confirmed": 1,
        "genuine_gap_subtitle": 2,
        "genuine_gap_wowhead_subtitle": 3,
        "genuine_gap_wowhead": 4,
        "flag_incorrect_wowhead": 10,
        "no_evidence": 15,
        "wrong_type": 20,
        "subtitle_not_vendor": 25,
        "subtitle_not_trainer": 25,
        "quest_related": 50,
        "scripted_cpp": 80,
        "unspawned": 90,
        "test_debug_unused": 99,
        "uncategorized": 50,
    }

    with open(REPORT_PATH, 'w', encoding='utf-8') as f:
        f.write("=" * 100 + "\n")
        f.write("EMPTY SERVICES AUDIT REPORT\n")
        f.write(f"Generated by audit_empty_services.py\n")
        f.write("=" * 100 + "\n\n")

        # --- VENDORS SUMMARY ---
        f.write("=" * 100 + "\n")
        f.write(f"EMPTY VENDORS (have vendor flag 0x80 but no npc_vendor rows)\n")
        f.write(f"Total: {len(vendors)}\n")
        f.write("=" * 100 + "\n\n")

        f.write("CATEGORY SUMMARY:\n")
        f.write("-" * 80 + "\n")
        for cat in sorted(vendor_cats.keys(), key=lambda c: cat_priority.get(c, 50)):
            npcs = vendor_cats[cat]
            desc = cat_descriptions.get(cat, cat)
            spawned_count = sum(1 for n in npcs if n.has_spawns)
            f.write(f"  {desc}\n")
            f.write(f"    Count: {len(npcs)} ({spawned_count} spawned)\n")
        f.write("\n")

        # Detailed listings by category
        for cat in sorted(vendor_cats.keys(), key=lambda c: cat_priority.get(c, 50)):
            npcs = vendor_cats[cat]
            desc = cat_descriptions.get(cat, cat)
            f.write("-" * 80 + "\n")
            f.write(f"VENDORS - {desc} ({len(npcs)})\n")
            f.write("-" * 80 + "\n")

            for npc in sorted(npcs, key=lambda n: n.entry):
                spawned_str = "SPAWNED" if npc.has_spawns else "not spawned"
                quest_str = ""
                if npc.is_quest_giver:
                    quest_str += " [quest-giver]"
                if npc.is_quest_ender:
                    quest_str += " [quest-ender]"
                wh_role_str = f" wh_roles={npc.wowhead_roles}" if npc.wowhead_roles else ""
                wh_sub_str = f" wh_sub=\"{npc.wowhead_subtitle}\"" if npc.wowhead_subtitle else ""
                script_str = f" script={npc.script_name}" if npc.script_name else ""
                type_str = CREATURE_TYPES.get(npc.creature_type, f"type{npc.creature_type}")

                f.write(f"  {npc.entry:>8}  {npc.name:<40} "
                        f"sub=\"{npc.subname or ''}\" "
                        f"type={type_str} "
                        f"[{spawned_str}]"
                        f"{quest_str}{wh_role_str}{wh_sub_str}{script_str}\n")
            f.write("\n")

        # --- TRAINERS SUMMARY ---
        f.write("\n" + "=" * 100 + "\n")
        f.write(f"EMPTY TRAINERS (have trainer flag 0x10 but no creature_trainer rows)\n")
        f.write(f"Total: {len(trainers)}\n")
        f.write("=" * 100 + "\n\n")

        f.write("CATEGORY SUMMARY:\n")
        f.write("-" * 80 + "\n")
        for cat in sorted(trainer_cats.keys(), key=lambda c: cat_priority.get(c, 50)):
            npcs = trainer_cats[cat]
            desc = cat_descriptions.get(cat, cat)
            spawned_count = sum(1 for n in npcs if n.has_spawns)
            f.write(f"  {desc}\n")
            f.write(f"    Count: {len(npcs)} ({spawned_count} spawned)\n")
        f.write("\n")

        for cat in sorted(trainer_cats.keys(), key=lambda c: cat_priority.get(c, 50)):
            npcs = trainer_cats[cat]
            desc = cat_descriptions.get(cat, cat)
            f.write("-" * 80 + "\n")
            f.write(f"TRAINERS - {desc} ({len(npcs)})\n")
            f.write("-" * 80 + "\n")

            for npc in sorted(npcs, key=lambda n: n.entry):
                spawned_str = "SPAWNED" if npc.has_spawns else "not spawned"
                quest_str = ""
                if npc.is_quest_giver:
                    quest_str += " [quest-giver]"
                if npc.is_quest_ender:
                    quest_str += " [quest-ender]"
                wh_role_str = f" wh_roles={npc.wowhead_roles}" if npc.wowhead_roles else ""
                wh_sub_str = f" wh_sub=\"{npc.wowhead_subtitle}\"" if npc.wowhead_subtitle else ""
                script_str = f" script={npc.script_name}" if npc.script_name else ""
                type_str = CREATURE_TYPES.get(npc.creature_type, f"type{npc.creature_type}")

                f.write(f"  {npc.entry:>8}  {npc.name:<40} "
                        f"sub=\"{npc.subname or ''}\" "
                        f"type={type_str} "
                        f"[{spawned_str}]"
                        f"{quest_str}{wh_role_str}{wh_sub_str}{script_str}\n")
            f.write("\n")

        # --- PRIORITY ACTION ITEMS ---
        f.write("\n" + "=" * 100 + "\n")
        f.write("PRIORITY ACTION ITEMS\n")
        f.write("=" * 100 + "\n\n")

        # Genuine gaps - vendors
        genuine_vendor_cats = ["genuine_gap_confirmed", "genuine_gap_subtitle",
                               "genuine_gap_wowhead", "genuine_gap_wowhead_subtitle"]
        genuine_vendors = []
        for cat in genuine_vendor_cats:
            genuine_vendors.extend(vendor_cats.get(cat, []))
        genuine_vendors_spawned = [v for v in genuine_vendors if v.has_spawns]

        f.write(f"1. GENUINE VENDOR GAPS: {len(genuine_vendors)} total, "
                f"{len(genuine_vendors_spawned)} spawned\n")
        f.write("   These NPCs appear to be real vendors but have empty inventories.\n")
        f.write("   They need npc_vendor data populated.\n\n")

        # Genuine gaps - trainers
        genuine_trainer_cats = ["genuine_gap_confirmed", "genuine_gap_subtitle",
                                "genuine_gap_wowhead", "genuine_gap_wowhead_subtitle"]
        genuine_trainers = []
        for cat in genuine_trainer_cats:
            genuine_trainers.extend(trainer_cats.get(cat, []))
        genuine_trainers_spawned = [t for t in genuine_trainers if t.has_spawns]

        f.write(f"2. GENUINE TRAINER GAPS: {len(genuine_trainers)} total, "
                f"{len(genuine_trainers_spawned)} spawned\n")
        f.write("   These NPCs appear to be real trainers but have no creature_trainer rows.\n")
        f.write("   They need trainer data populated.\n\n")

        # Flag removal candidates
        flag_removal_vendors = []
        flag_removal_trainers = []

        # Conservative: only remove flags from spawned NPCs where Wowhead
        # explicitly says they are NOT this role, or wrong creature type,
        # or test/unused NPCs
        for v in vendors:
            if v.category in ("wrong_type", "test_debug_unused"):
                flag_removal_vendors.append(v)
            elif v.category == "flag_incorrect_wowhead" and v.has_spawns:
                flag_removal_vendors.append(v)
            elif v.category == "no_evidence" and v.has_spawns and not v.is_quest_giver and not v.is_quest_ender:
                # Only if definitely no evidence at all
                flag_removal_vendors.append(v)

        for t in trainers:
            if t.category in ("wrong_type", "test_debug_unused"):
                flag_removal_trainers.append(t)
            elif t.category == "flag_incorrect_wowhead" and t.has_spawns:
                flag_removal_trainers.append(t)
            elif t.category == "no_evidence" and t.has_spawns and not t.is_quest_giver and not t.is_quest_ender:
                flag_removal_trainers.append(t)

        f.write(f"3. FLAG REMOVAL CANDIDATES (VENDOR): {len(flag_removal_vendors)}\n")
        f.write("   NPCs that should NOT have the vendor flag.\n")
        f.write(f"   SQL generated at: {SQL_FIX_PATH}\n\n")

        f.write(f"4. FLAG REMOVAL CANDIDATES (TRAINER): {len(flag_removal_trainers)}\n")
        f.write("   NPCs that should NOT have the trainer flag.\n\n")

        # Unspawned counts
        unspawned_vendors = len(vendor_cats.get("unspawned", []))
        unspawned_trainers = len(trainer_cats.get("unspawned", []))
        f.write(f"5. UNSPAWNED (low priority): {unspawned_vendors} vendors, "
                f"{unspawned_trainers} trainers\n")
        f.write("   Not spawned in the world, so these don't affect gameplay.\n\n")

        scripted_vendors = len(vendor_cats.get("scripted_cpp", []))
        scripted_trainers = len(trainer_cats.get("scripted_cpp", []))
        f.write(f"6. SCRIPTED (no action needed): {scripted_vendors} vendors, "
                f"{scripted_trainers} trainers\n")
        f.write("   Handled by C++ scripts, intentionally empty in DB.\n\n")

        # --- Grand totals ---
        f.write("\n" + "=" * 100 + "\n")
        f.write("GRAND TOTALS\n")
        f.write("=" * 100 + "\n\n")

        f.write(f"{'Category':<45} {'Vendors':>10} {'Trainers':>10} {'Total':>10}\n")
        f.write("-" * 75 + "\n")

        all_cats = sorted(set(list(vendor_cats.keys()) + list(trainer_cats.keys())),
                         key=lambda c: cat_priority.get(c, 50))
        grand_v = 0
        grand_t = 0
        for cat in all_cats:
            vc = len(vendor_cats.get(cat, []))
            tc = len(trainer_cats.get(cat, []))
            desc = cat_descriptions.get(cat, cat).split(" - ")[0]
            f.write(f"  {desc:<43} {vc:>10} {tc:>10} {vc + tc:>10}\n")
            grand_v += vc
            grand_t += tc
        f.write("-" * 75 + "\n")
        f.write(f"  {'TOTAL':<43} {grand_v:>10} {grand_t:>10} {grand_v + grand_t:>10}\n")

    print(f"Report written to: {REPORT_PATH}")

    # --- Generate SQL Fixes ---
    print("\nGenerating SQL fixes...")

    with open(SQL_FIX_PATH, 'w', encoding='utf-8') as f:
        f.write("-- ==========================================================================\n")
        f.write("-- Empty Service Flag Fixes\n")
        f.write("-- Generated by audit_empty_services.py\n")
        f.write("-- \n")
        f.write("-- Removes vendor/trainer flags from NPCs that clearly should not have them.\n")
        f.write("-- Conservative: only removes from wrong-type, test/debug, or Wowhead-confirmed\n")
        f.write("-- non-vendor/non-trainer NPCs.\n")
        f.write("-- ==========================================================================\n\n")

        # --- Vendor flag removals ---
        if flag_removal_vendors:
            f.write("-- -------------------------------------------------------\n")
            f.write(f"-- Remove vendor flag (npcflag & ~128) - {len(flag_removal_vendors)} NPCs\n")
            f.write("-- -------------------------------------------------------\n\n")

            # Group by category for clarity
            by_cat = defaultdict(list)
            for v in flag_removal_vendors:
                by_cat[v.category].append(v)

            for cat in sorted(by_cat.keys(), key=lambda c: cat_priority.get(c, 50)):
                npcs = sorted(by_cat[cat], key=lambda n: n.entry)
                desc = cat_descriptions.get(cat, cat)
                f.write(f"-- {desc}\n")
                for npc in npcs:
                    sub_comment = f" -- {npc.subname}" if npc.subname else ""
                    wh_comment = f" wh_roles={npc.wowhead_roles}" if npc.wowhead_roles else ""
                    type_comment = f" type={CREATURE_TYPES.get(npc.creature_type, str(npc.creature_type))}"
                    f.write(f"UPDATE creature_template SET npcflag = npcflag & ~128 "
                            f"WHERE entry = {npc.entry}; "
                            f"-- {npc.name}{sub_comment}{type_comment}{wh_comment}\n")
                f.write("\n")

        # --- Trainer flag removals ---
        if flag_removal_trainers:
            f.write("-- -------------------------------------------------------\n")
            f.write(f"-- Remove trainer flag (npcflag & ~16) - {len(flag_removal_trainers)} NPCs\n")
            f.write("-- -------------------------------------------------------\n\n")

            by_cat = defaultdict(list)
            for t in flag_removal_trainers:
                by_cat[t.category].append(t)

            for cat in sorted(by_cat.keys(), key=lambda c: cat_priority.get(c, 50)):
                npcs = sorted(by_cat[cat], key=lambda n: n.entry)
                desc = cat_descriptions.get(cat, cat)
                f.write(f"-- {desc}\n")
                for npc in npcs:
                    sub_comment = f" -- {npc.subname}" if npc.subname else ""
                    wh_comment = f" wh_roles={npc.wowhead_roles}" if npc.wowhead_roles else ""
                    type_comment = f" type={CREATURE_TYPES.get(npc.creature_type, str(npc.creature_type))}"
                    f.write(f"UPDATE creature_template SET npcflag = npcflag & ~16 "
                            f"WHERE entry = {npc.entry}; "
                            f"-- {npc.name}{sub_comment}{type_comment}{wh_comment}\n")
                f.write("\n")

        if not flag_removal_vendors and not flag_removal_trainers:
            f.write("-- No flag removals needed.\n")

        # Count total SQL statements
        total_fixes = len(flag_removal_vendors) + len(flag_removal_trainers)
        f.write(f"\n-- Total fixes: {total_fixes}\n")

    print(f"SQL fixes written to: {SQL_FIX_PATH}")
    print(f"  Vendor flag removals: {len(flag_removal_vendors)}")
    print(f"  Trainer flag removals: {len(flag_removal_trainers)}")
    print("\nDone!")


if __name__ == "__main__":
    main()
