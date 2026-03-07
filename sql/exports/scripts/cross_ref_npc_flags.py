#!/usr/bin/env python3
"""
Cross-reference Wowhead NPC roles against DB npcflag values.

Reads:
  - npc_roles.csv (from extract_completion_category.py)
  - npc_completion_category.csv
  - DB: world.creature_template (entry, name, npcflag)
  - DB: world.creature_trainer (CreatureID)

Outputs:
  - Console report of mismatches
  - SQL fix file: npc_flag_fixes.sql (missing flags only)
"""

import csv
import subprocess
import sys
import time
from collections import defaultdict

MYSQL = r"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
ROLES_CSV = r"C:\Users\atayl\VoxCore\wago\wowhead_data\npc\npc_roles.csv"
CC_CSV = r"C:\Users\atayl\VoxCore\wago\wowhead_data\npc\npc_completion_category.csv"
SQL_OUT = r"C:\Users\atayl\VoxCore\sql\exports\cleanup\npc_flag_fixes.sql"

# Role -> npcflag bit mapping
ROLE_FLAG_MAP = {
    "trainer": 16,
    "vendor": 128,
    "flight_master": 8192,
    "innkeeper": 65536,
    "stable_master": 4194304,
    "banker": 131072,
    "auctioneer": 2097152,
    "repair": 4096,
}

# Flag -> role name (for extra-flag detection)
FLAG_ROLE_MAP = {v: k for k, v in ROLE_FLAG_MAP.items()}

# Friendly flag names for reporting
FLAG_NAMES = {
    1: "gossip",
    2: "questgiver",
    16: "trainer",
    128: "vendor",
    4096: "repair",
    8192: "flight_master",
    65536: "innkeeper",
    131072: "banker",
    2097152: "auctioneer",
    4194304: "stable_master",
}


def run_mysql(query):
    """Run a MySQL query and return tab-separated rows."""
    result = subprocess.run(
        [MYSQL, "-u", "root", "-padmin", "--batch", "--skip-column-names", "-e", query],
        capture_output=True
    )
    if result.returncode != 0:
        print(f"MySQL error: {result.stderr.decode('utf-8', errors='replace')}", file=sys.stderr)
        sys.exit(1)
    # Decode with latin1 (MySQL default for NPC names can have non-UTF8 chars)
    stdout = result.stdout.decode('utf-8', errors='replace')
    rows = []
    for line in stdout.strip().split('\n'):
        if line:
            rows.append(line.split('\t'))
    return rows


def main():
    start = time.time()

    # Step 1: Load Wowhead roles
    print("Loading Wowhead role data...")
    wh_roles = {}  # id -> set of roles
    wh_subtitles = {}  # id -> subtitle
    with open(ROLES_CSV, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            npc_id = int(row['id'])
            roles_str = row['detected_roles'].strip()
            roles = set(roles_str.split(',')) if roles_str else set()
            wh_roles[npc_id] = roles
            wh_subtitles[npc_id] = row['subtitle']

    print(f"  Loaded {len(wh_roles)} NPCs with subtitle/role data")

    # Step 2: Load completion_category
    print("Loading completion_category data...")
    wh_cc = {}
    with open(CC_CSV, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            wh_cc[int(row['id'])] = int(row['completion_category'])

    print(f"  Loaded {len(wh_cc)} completion categories")

    # Step 3: Query DB for creature_template
    print("Querying creature_template...")
    rows = run_mysql("SELECT entry, name, npcflag FROM world.creature_template WHERE entry < 300000;")
    db_npcs = {}
    for entry, name, npcflag in rows:
        db_npcs[int(entry)] = (name, int(npcflag))

    print(f"  Loaded {len(db_npcs)} creature_template entries")

    # Step 4: Query creature_trainer for trainer check
    print("Querying creature_trainer...")
    trainer_rows = run_mysql("SELECT DISTINCT CreatureID FROM world.creature_trainer;")
    db_trainers = set(int(r[0]) for r in trainer_rows)
    print(f"  Found {len(db_trainers)} creatures with trainer data")

    # Step 5: Cross-reference
    print("\nCross-referencing...")

    missing_flags = []   # (entry, name, role, flag_bit, subtitle)
    extra_flags = []     # (entry, name, role, flag_bit, subtitle)
    trainer_no_data = [] # (entry, name) - has trainer flag but no creature_trainer row

    missing_by_type = defaultdict(int)
    extra_by_type = defaultdict(int)

    for entry, (name, npcflag) in db_npcs.items():
        roles = wh_roles.get(entry, set())
        cc = wh_cc.get(entry)
        subtitle = wh_subtitles.get(entry, "")

        # Check A: Missing flags - Wowhead says role exists, DB missing the flag
        for role in roles:
            flag_bit = ROLE_FLAG_MAP[role]
            if not (npcflag & flag_bit):
                missing_flags.append((entry, name, role, flag_bit, subtitle))
                missing_by_type[role] += 1

        # Check B: Extra flags - DB has flag, Wowhead doesn't indicate role
        for flag_bit, role in FLAG_ROLE_MAP.items():
            if npcflag & flag_bit:
                has_wh_role = role in roles
                # For vendor, also check completion_category == 7 (vendor category on Wowhead)
                # Actually cc=7 is very common for all NPC types, not vendor-specific
                # So only use subtitle-based detection
                if not has_wh_role:
                    extra_flags.append((entry, name, role, flag_bit, subtitle))
                    extra_by_type[role] += 1

        # Check C: Trainer flag but no trainer data
        if npcflag & 16 and entry not in db_trainers:
            trainer_no_data.append((entry, name))

    # Report
    print("\n" + "=" * 80)
    print("MISSING FLAGS (Wowhead role present, DB flag missing)")
    print("=" * 80)
    for role in sorted(missing_by_type.keys(), key=lambda r: -missing_by_type[r]):
        count = missing_by_type[role]
        flag = ROLE_FLAG_MAP[role]
        print(f"  {role:20s}: {count:5d} missing (flag bit {flag})")
    print(f"  {'TOTAL':20s}: {len(missing_flags):5d}")

    print("\n" + "=" * 80)
    print("EXTRA FLAGS (DB flag set, no Wowhead role indicator)")
    print("=" * 80)
    for role in sorted(extra_by_type.keys(), key=lambda r: -extra_by_type[r]):
        count = extra_by_type[role]
        flag = ROLE_FLAG_MAP[role]
        print(f"  {role:20s}: {count:5d} extra (flag bit {flag})")
    print(f"  {'TOTAL':20s}: {len(extra_flags):5d}")

    print(f"\n  Trainer flag but no creature_trainer row: {len(trainer_no_data)}")

    # Sample: 30 highest-impact missing-flag fixes (named NPCs players interact with)
    # Prioritize: named NPCs (no generic names), lower entry IDs (classic content)
    print("\n" + "=" * 80)
    print("TOP 30 HIGHEST-IMPACT MISSING FLAG FIXES")
    print("=" * 80)

    # Score: prefer named NPCs, lower entries, important roles
    role_priority = {
        "flight_master": 6, "innkeeper": 5, "banker": 5, "auctioneer": 5,
        "stable_master": 4, "trainer": 3, "vendor": 2, "repair": 4
    }

    def impact_score(item):
        entry, name, role, flag_bit, subtitle = item
        # Penalize generic names
        generic = any(kw in name.lower() for kw in ['[dnr', 'test', 'unused', 'deprecated', '[ph]', 'template', 'generic'])
        score = role_priority.get(role, 1)
        if generic:
            score -= 10
        # Prefer lower entries (more classic/important)
        if entry < 50000:
            score += 3
        elif entry < 100000:
            score += 1
        return score

    sorted_missing = sorted(missing_flags, key=lambda x: -impact_score(x))
    for i, (entry, name, role, flag_bit, subtitle) in enumerate(sorted_missing[:30]):
        print(f"  {i+1:2d}. [{entry:6d}] {name:40s} missing {role:15s} (subtitle: {subtitle})")

    # Sample extra flags
    print("\n" + "=" * 80)
    print("SAMPLE 30 EXTRA FLAGS (DB has flag, Wowhead doesn't indicate role)")
    print("=" * 80)
    # Focus on lower entries and important roles
    sorted_extra = sorted(extra_flags, key=lambda x: (x[0]))
    shown = 0
    for entry, name, role, flag_bit, subtitle in sorted_extra:
        if shown >= 30:
            break
        # Skip very generic/test NPCs
        if any(kw in name.lower() for kw in ['[dnr', 'test', 'unused']):
            continue
        print(f"  [{entry:6d}] {name:40s} extra {role:15s} (subtitle: {subtitle})")
        shown += 1

    # Step 6: Generate SQL fixes (missing flags only)
    print(f"\n{'=' * 80}")
    print(f"Generating SQL fixes...")
    print(f"{'=' * 80}")

    # Group fixes by entry to combine multiple missing flags
    fixes_by_entry = defaultdict(list)  # entry -> [(role, flag_bit)]
    for entry, name, role, flag_bit, subtitle in missing_flags:
        # Skip entries that look like test/unused NPCs
        if any(kw in name.lower() for kw in ['[dnr', 'test ', 'unused', 'deprecated', '[ph]', 'template']):
            continue
        fixes_by_entry[entry].append((role, flag_bit, name, subtitle))

    with open(SQL_OUT, 'w', encoding='utf-8') as f:
        f.write("-- NPC flag fixes: add missing npcflag bits based on Wowhead role data\n")
        f.write("-- Generated by cross_ref_npc_flags.py\n")
        f.write(f"-- Total fixes: {len(fixes_by_entry)} NPCs\n")
        f.write("-- Uses bitwise OR so operations are idempotent\n\n")

        for entry in sorted(fixes_by_entry.keys()):
            items = fixes_by_entry[entry]
            name = items[0][2]
            subtitle = items[0][3]
            combined_flag = 0
            roles_desc = []
            for role, flag_bit, _, _ in items:
                combined_flag |= flag_bit
                roles_desc.append(f"{role}({flag_bit})")

            f.write(f"-- {name} [{entry}] subtitle=\"{subtitle}\" add: {', '.join(roles_desc)}\n")
            f.write(f"UPDATE creature_template SET npcflag = npcflag | {combined_flag} WHERE entry = {entry};\n")

    print(f"  Wrote {len(fixes_by_entry)} fix statements to {SQL_OUT}")

    # Additional stats
    print(f"\nFixes by role type:")
    fix_role_counts = defaultdict(int)
    for entry, items in fixes_by_entry.items():
        for role, _, _, _ in items:
            fix_role_counts[role] += 1
    for role in sorted(fix_role_counts.keys(), key=lambda r: -fix_role_counts[r]):
        print(f"  {role:20s}: {fix_role_counts[role]:5d}")

    elapsed = time.time() - start
    print(f"\nCompleted in {elapsed:.1f}s")


if __name__ == '__main__':
    main()
