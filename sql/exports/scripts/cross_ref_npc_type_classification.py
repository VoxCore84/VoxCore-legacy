"""
Cross-reference Wowhead NPC type & classification against world.creature_template.

Wowhead CSV: C:/Users/atayl/VoxCore/wago/wowhead_data/npc/npc_export.csv
DB table:    world.creature_template (entry < 500000)

Enum mappings:
  Wowhead type (string -> int):
    Beast=1, Dragonkin=2, Demon=3, Elemental=4, Undead=6, Humanoid=7,
    Critter=8, Mechanical=9, Giant=10, Aberration=12
    (also has numeric values: 1,2,3,4,6,7,8,9,10,12,15)
    Special: "Battle Pet" and "Test" are non-standard

  Wowhead classification (string -> DB int):
    Normal=0, Elite=1, Rare=4, "Rare Elite"=2, Boss=3
    (also has numeric values: 0,1,2,3,4)

  DB Classification enum:
    0=Normal, 1=Elite, 2=Rare Elite, 3=Boss, 4=Rare, 5=?, 6=?
"""

import csv
import subprocess
import sys
from collections import Counter, defaultdict

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
MYSQL = "C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe"
CSV_PATH = "C:/Users/atayl/VoxCore/wago/wowhead_data/npc/npc_export.csv"

# Wowhead string -> DB integer for creature type
WH_TYPE_MAP = {
    "Beast": 1,
    "Dragonkin": 2,
    "Demon": 3,
    "Elemental": 4,
    "Undead": 6,
    "Humanoid": 7,
    "Critter": 8,
    "Mechanical": 9,
    "Giant": 10,
    "Aberration": 12,
    "Battle Pet": -1,   # No DB equivalent, skip
    "Test": -1,         # No DB equivalent, skip
}

# Wowhead classification -> DB Classification
# Wowhead: 0=Normal, 1=Elite, 2=Rare, 3=Rare Elite, 4=Boss
# DB:      0=Normal, 1=Elite, 2=Rare Elite, 3=Boss, 4=Rare
WH_CLASSIF_MAP = {
    "Normal": 0,
    "Elite": 1,
    "Rare": 4,
    "Rare Elite": 2,
    "Boss": 3,
}

# For numeric Wowhead classification values, we need to remap:
# WH numeric 0 -> DB 0 (Normal)
# WH numeric 1 -> DB 1 (Elite)
# WH numeric 2 -> DB 4 (Rare)       -- DIFFERENT!
# WH numeric 3 -> DB 2 (Rare Elite) -- DIFFERENT!
# WH numeric 4 -> DB 3 (Boss)       -- DIFFERENT!
WH_CLASSIF_NUMERIC_TO_DB = {
    0: 0,  # Normal -> Normal
    1: 1,  # Elite -> Elite
    2: 4,  # Rare -> Rare
    3: 2,  # Rare Elite -> Rare Elite
    4: 3,  # Boss -> Boss
}

# Reverse maps for friendly names
DB_TYPE_NAMES = {
    0: "Not specified",
    1: "Beast",
    2: "Dragonkin",
    3: "Demon",
    4: "Elemental",
    5: "Giant (old)",
    6: "Undead",
    7: "Humanoid",
    8: "Critter",
    9: "Mechanical",
    10: "Giant",
    11: "Uncategorized(11)",
    12: "Aberration",
    13: "Non-combat Pet(13)",
    14: "Gas Cloud(14)",
    15: "Wild Pet(15)",
}

DB_CLASSIF_NAMES = {
    0: "Normal",
    1: "Elite",
    2: "Rare Elite",
    3: "Boss",
    4: "Rare",
    5: "Unknown(5)",
    6: "Unknown(6)",
}

# Wowhead numeric classification -> friendly name (using WH enum)
WH_CLASSIF_NAMES = {
    0: "Normal",
    1: "Elite",
    2: "Rare",
    3: "Rare Elite",
    4: "Boss",
}

# Wowhead numeric type -> friendly name
WH_TYPE_NAMES = {
    1: "Beast",
    2: "Dragonkin",
    3: "Demon",
    4: "Elemental",
    6: "Undead",
    7: "Humanoid",
    8: "Critter",
    9: "Mechanical",
    10: "Giant",
    12: "Aberration",
    15: "Wild Pet",
}


def normalize_wh_type(val: str) -> int | None:
    """Convert Wowhead type value to DB integer. Returns None if skip/empty."""
    if not val:
        return None
    # Try as integer first
    try:
        v = int(val)
        return v
    except ValueError:
        pass
    # Try string mapping
    mapped = WH_TYPE_MAP.get(val)
    if mapped == -1:
        return None  # Skip Battle Pet, Test
    return mapped


def normalize_wh_classif(val: str) -> int | None:
    """Convert Wowhead classification value to DB Classification integer."""
    if not val:
        return None
    # Try as integer first (Wowhead numeric enum)
    try:
        v = int(val)
        return WH_CLASSIF_NUMERIC_TO_DB.get(v, v)
    except ValueError:
        pass
    # Try string mapping
    return WH_CLASSIF_MAP.get(val)


def load_wowhead_csv() -> dict:
    """Load Wowhead CSV, return dict of {id: (type_int, classif_int)}."""
    data = {}
    skipped_type = 0
    skipped_classif = 0
    with open(CSV_PATH, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                npc_id = int(row["id"])
            except (ValueError, TypeError):
                print(f"  WARNING: skipping malformed row (bad id): {row}", file=sys.stderr)
                continue
            raw_type = row["type"].strip() if row["type"] else ""
            raw_classif = row["classification"].strip() if row["classification"] else ""

            wh_type = normalize_wh_type(raw_type)
            wh_classif = normalize_wh_classif(raw_classif)

            if wh_type is None and wh_classif is None:
                continue

            data[npc_id] = (wh_type, wh_classif, raw_type, raw_classif)
    return data


def load_db_data() -> dict:
    """Query DB for creature_template entries, return {entry: (type, Classification)}."""
    query = "SELECT entry, type, Classification FROM world.creature_template WHERE entry < 500000"
    result = subprocess.run(
        [MYSQL, "-u", "root", "-padmin", "-N", "-B", "-e", query],
        capture_output=True, text=True, timeout=120
    )
    if result.returncode != 0:
        print(f"MySQL error: {result.stderr}", file=sys.stderr)
        sys.exit(1)

    data = {}
    for line in result.stdout.strip().split("\n"):
        if not line:
            continue
        parts = line.split("\t")
        entry = int(parts[0])
        ctype = int(parts[1])
        classif = int(parts[2])
        data[entry] = (ctype, classif)
    return data


def main():
    print("Loading Wowhead CSV...")
    wh_data = load_wowhead_csv()
    print(f"  Loaded {len(wh_data)} NPCs with type/classification data")

    print("Loading DB creature_template...")
    db_data = load_db_data()
    print(f"  Loaded {len(db_data)} creature_template entries")

    # Find common IDs
    common_ids = set(wh_data.keys()) & set(db_data.keys())
    print(f"  Common IDs: {len(common_ids)}")

    # Compare
    type_mismatches = []
    classif_mismatches = []
    type_pattern_counter = Counter()
    classif_pattern_counter = Counter()

    for npc_id in sorted(common_ids):
        wh_type, wh_classif, raw_type, raw_classif = wh_data[npc_id]
        db_type, db_classif = db_data[npc_id]

        # Type comparison (only if Wowhead has data)
        if wh_type is not None and wh_type != db_type:
            # Always use the friendly name for WH type
            wh_name = DB_TYPE_NAMES.get(wh_type, raw_type or str(wh_type))
            db_name = DB_TYPE_NAMES.get(db_type, str(db_type))
            type_mismatches.append((npc_id, db_name, wh_name, db_type, wh_type))
            pattern = f"DB={db_name} -> WH={wh_name}"
            type_pattern_counter[pattern] += 1

        # Classification comparison (only if Wowhead has data)
        if wh_classif is not None and wh_classif != db_classif:
            # Always use the friendly name for WH classification
            wh_name = DB_CLASSIF_NAMES.get(wh_classif, raw_classif or str(wh_classif))
            db_name = DB_CLASSIF_NAMES.get(db_classif, str(db_classif))
            classif_mismatches.append((npc_id, db_name, wh_name, db_classif, wh_classif))
            pattern = f"DB={db_name} -> WH={wh_name}"
            classif_pattern_counter[pattern] += 1

    # ---------------------------------------------------------------------------
    # Report
    # ---------------------------------------------------------------------------
    print("\n" + "=" * 80)
    print("TYPE MISMATCHES")
    print("=" * 80)
    print(f"Total: {len(type_mismatches)}")
    print(f"\nSample (first 50):")
    print(f"{'Entry':>10}  {'DB Type':<20}  {'Wowhead Type':<20}")
    print("-" * 55)
    for npc_id, db_name, wh_name, _, _ in type_mismatches[:50]:
        print(f"{npc_id:>10}  {db_name:<20}  {wh_name:<20}")

    print(f"\nMost common type mismatch patterns:")
    print(f"{'Count':>8}  Pattern")
    print("-" * 60)
    for pattern, count in type_pattern_counter.most_common(20):
        print(f"{count:>8}  {pattern}")

    print("\n" + "=" * 80)
    print("CLASSIFICATION MISMATCHES")
    print("=" * 80)
    print(f"Total: {len(classif_mismatches)}")
    print(f"\nSample (first 50):")
    print(f"{'Entry':>10}  {'DB Classification':<20}  {'Wowhead Classification':<20}")
    print("-" * 55)
    for npc_id, db_name, wh_name, _, _ in classif_mismatches[:50]:
        print(f"{npc_id:>10}  {db_name:<20}  {wh_name:<20}")

    print(f"\nMost common classification mismatch patterns:")
    print(f"{'Count':>8}  Pattern")
    print("-" * 60)
    for pattern, count in classif_pattern_counter.most_common(20):
        print(f"{count:>8}  {pattern}")

    # Summary
    print("\n" + "=" * 80)
    print("SUMMARY")
    print("=" * 80)
    total_comparable_type = sum(1 for nid in common_ids if wh_data[nid][0] is not None)
    total_comparable_classif = sum(1 for nid in common_ids if wh_data[nid][1] is not None)
    print(f"NPCs compared (type):           {total_comparable_type}")
    print(f"NPCs compared (classification): {total_comparable_classif}")
    print(f"Type mismatches:                {len(type_mismatches)} ({100*len(type_mismatches)/max(total_comparable_type,1):.1f}%)")
    print(f"Classification mismatches:      {len(classif_mismatches)} ({100*len(classif_mismatches)/max(total_comparable_classif,1):.1f}%)")

    # Write fix SQL for the most impactful mismatches
    with open("C:/Users/atayl/VoxCore/sql/exports/cleanup/npc_type_classification_fixes.sql", "w", encoding="utf-8") as f:
        f.write("-- NPC type & classification fixes based on Wowhead cross-reference\n")
        f.write("-- Generated by cross_ref_npc_type_classification.py\n\n")

        f.write("-- TYPE FIXES\n")
        for npc_id, db_name, wh_name, db_val, wh_val in type_mismatches:
            f.write(f"UPDATE creature_template SET type = {wh_val} WHERE entry = {npc_id}; "
                    f"-- was {db_name} ({db_val}), Wowhead says {wh_name} ({wh_val})\n")

        f.write("\n-- CLASSIFICATION FIXES\n")
        for npc_id, db_name, wh_name, db_val, wh_val in classif_mismatches:
            f.write(f"UPDATE creature_template SET Classification = {wh_val} WHERE entry = {npc_id}; "
                    f"-- was {db_name} ({db_val}), Wowhead says {wh_name}\n")

    print(f"\nSQL fix file written to: sql/exports/cleanup/npc_type_classification_fixes.sql")


if __name__ == "__main__":
    main()
