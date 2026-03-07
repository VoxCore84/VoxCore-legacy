#!/usr/bin/env python3
"""
validate_level_ranges.py — Validate NPC level ranges against ContentTuning.

Cross-references Wowhead tooltip HTML level data against the database's
ContentTuning pipeline (creature_template_difficulty -> hotfixes.content_tuning)
to find NPCs with WRONG level ranges (not just missing ones).

This is Tier 2 validation — Tier 1 (fix_level1_npcs.py) handled NPCs stuck at
level 1 from ContentTuningID=0. This script validates that NPCs with non-zero
ContentTuningIDs have the CORRECT level range.

KEY INSIGHT: Wowhead tooltips show CHROMIE TIME scaled ranges, NOT the raw
ContentTuning range. For example, a Classic zone NPC on CT=2 (5-30) may show
as "Level 5-61" on Wowhead because Chromie Time lets it scale to 60+. This
means we CANNOT directly compare Wowhead max to CT max for old-world content.

Instead we detect mismatches via:
  1. WRONG TIER (too low): Wowhead min level is ABOVE the CT's max level.
     The NPC needs a higher-tier CT. Example: WH 70-80, CT is 5-30.
  2. WRONG TIER (too high): Wowhead max level is BELOW the CT's min level.
     The NPC needs a lower-tier CT. Example: WH 2-2, CT is 70-80.
  3. MIN LEVEL MISMATCH: For matching tiers, the Wowhead min is significantly
     different from the CT min (suggests wrong zone CT within same expansion).

Outputs:
  - level_range_report.txt          Summary report
  - npc_level_range_fixes.sql       SQL to fix unambiguous mismatches
"""

import json
import os
import re
import subprocess
import sys
from collections import defaultdict

# =============================================================================
# Configuration
# =============================================================================

WOWHEAD_RAW_DIR = r"C:\Users\atayl\VoxCore\wago\wowhead_data\npc\raw"
OUTPUT_DIR = r"C:\Users\atayl\VoxCore\sql\exports\cleanup"
ZONE_CT_MAPPING = r"C:\Users\atayl\VoxCore\sql\exports\scripts\zone_ct_mapping.txt"
MYSQL_BIN = r"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"

# MaxLevelType=2 means "current expansion cap". In 12.x / Midnight the cap is
# 90, but Wowhead tooltips show 80 (TWW cap) for most existing content.
# We treat MaxLevelType=2 as effective MaxLevel=80 for comparison.
EXPANSION_CAP = 80

# Minimum Wowhead level to consider (skip level-1 trash)
MIN_WOWHEAD_LEVEL = 2

# =============================================================================
# MySQL helper
# =============================================================================

def run_mysql_query(query, database="world"):
    """Execute a MySQL query and return rows as list of tuples."""
    cmd = [MYSQL_BIN, "-u", "root", "-padmin", "--batch", "--skip-column-names",
           "-e", query, database]
    result = subprocess.run(cmd, capture_output=True, text=True,
                            encoding="utf-8", errors="replace")
    if result.returncode != 0:
        print(f"MySQL error: {result.stderr}", file=sys.stderr)
        sys.exit(1)
    rows = []
    for line in result.stdout.strip().split("\n"):
        if line:
            rows.append(tuple(line.split("\t")))
    return rows


# =============================================================================
# Step 1: Extract level ranges from Wowhead tooltip HTML
# =============================================================================

def extract_wowhead_levels():
    """
    Parse all tooltip JSONs and extract level ranges.
    Returns dict: entry -> (min_level, max_level)
    """
    print("Extracting level ranges from Wowhead tooltip HTML...")
    level_re = re.compile(r"Level\s+(\d+)\s*(?:-\s*(\d+))?")
    boss_re = re.compile(r"Level\s+\?\?")

    npcs = {}
    file_count = 0
    skipped_boss = 0
    skipped_low = 0
    parse_errors = 0

    files = os.listdir(WOWHEAD_RAW_DIR)
    total = len(files)

    for i, fname in enumerate(files):
        if not fname.endswith(".json"):
            continue
        file_count += 1

        if file_count % 50000 == 0:
            print(f"  Processed {file_count}/{total} files...")

        fpath = os.path.join(WOWHEAD_RAW_DIR, fname)
        try:
            with open(fpath, "r", encoding="utf-8", errors="replace") as f:
                data = json.load(f)
        except (json.JSONDecodeError, OSError):
            parse_errors += 1
            continue

        tooltip = data.get("tooltip", "")
        if not tooltip:
            continue

        # Skip boss-level NPCs (Level ??)
        if boss_re.search(tooltip):
            skipped_boss += 1
            continue

        m = level_re.search(tooltip)
        if not m:
            continue

        entry = data.get("id")
        if entry is None:
            try:
                entry = int(fname.replace(".json", ""))
            except ValueError:
                continue

        min_level = int(m.group(1))
        max_level = int(m.group(2)) if m.group(2) else min_level

        if max_level < MIN_WOWHEAD_LEVEL:
            skipped_low += 1
            continue

        npcs[entry] = (min_level, max_level)

    print(f"  Files processed:     {file_count}")
    print(f"  NPCs with levels:    {len(npcs)}")
    print(f"  Skipped (boss ??):   {skipped_boss}")
    print(f"  Skipped (level < {MIN_WOWHEAD_LEVEL}): {skipped_low}")
    print(f"  Parse errors:        {parse_errors}")
    return npcs


# =============================================================================
# Step 2: Query database for ContentTuning data
# =============================================================================

def get_db_content_tuning():
    """
    Get ContentTuning data for all NPCs (DifficultyID=0).
    Returns dict: entry -> {ct_id, min_level, max_level, max_level_type, effective_max}
    """
    print("Querying database for ContentTuning data...")

    rows = run_mysql_query("""
        SELECT ctd.Entry, ctd.ContentTuningID,
               ct.MinLevel, ct.MaxLevel, ct.MaxLevelType, ct.ExpansionID
        FROM creature_template_difficulty ctd
        LEFT JOIN hotfixes.content_tuning ct ON ct.ID = ctd.ContentTuningID
        WHERE ctd.DifficultyID = 0
          AND ctd.ContentTuningID > 0
    """)

    npcs = {}
    for row in rows:
        entry = int(row[0])
        ct_id = int(row[1])
        min_level = int(row[2]) if row[2] != "NULL" else None
        max_level = int(row[3]) if row[3] != "NULL" else None
        max_level_type = int(row[4]) if row[4] != "NULL" else None
        expansion_id = int(row[5]) if row[5] != "NULL" else None

        if min_level is None:
            # CT row doesn't exist in hotfixes — skip
            continue

        # Compute effective max level
        if max_level_type == 2:
            effective_max = EXPANSION_CAP
        elif max_level_type == 3:
            # Delta from player level — skip, not comparable
            continue
        else:
            effective_max = max_level

        npcs[entry] = {
            "ct_id": ct_id,
            "min_level": min_level,
            "max_level": max_level,
            "max_level_type": max_level_type,
            "effective_max": effective_max,
            "expansion_id": expansion_id,
        }

    print(f"  Loaded {len(npcs)} NPCs with valid ContentTuning data")
    return npcs


def get_npc_names(entries):
    """Get names for a set of NPC entries."""
    if not entries:
        return {}

    names = {}
    batch_size = 500
    entry_list = sorted(entries)

    for i in range(0, len(entry_list), batch_size):
        batch = entry_list[i:i + batch_size]
        ids = ",".join(str(e) for e in batch)
        rows = run_mysql_query(
            f"SELECT entry, name FROM creature_template WHERE entry IN ({ids})"
        )
        for row in rows:
            if len(row) >= 2:
                names[int(row[0])] = row[1]

    return names


# =============================================================================
# Step 3: Compare levels and categorize mismatches
# =============================================================================

# Mismatch categories
CAT_WRONG_TIER_LOW = "WRONG_TIER_LOW"    # WH min > DB max — NPC needs higher CT
CAT_WRONG_TIER_HIGH = "WRONG_TIER_HIGH"  # WH max < DB min — NPC needs lower CT
CAT_MIN_MISMATCH = "MIN_LEVEL_MISMATCH"  # Same tier but wrong min level

# Severity within categories
SEVERITY_CRITICAL = "CRITICAL"
SEVERITY_MAJOR = "MAJOR"
SEVERITY_MINOR = "MINOR"


def classify_mismatch(wh_min, wh_max, db_min, db_eff_max, db_max_type):
    """
    Compare Wowhead levels vs DB ContentTuning levels.

    IMPORTANT: Wowhead shows Chromie Time scaled ranges. The WH max level is
    often much higher than the CT max because Chromie Time scales NPCs up.
    We therefore focus on:
    - Whether the NPC is on the right TIER (WH range overlaps CT range)
    - Whether the CT min level is appropriate for the NPC

    Returns (category, severity, description) or None if no mismatch.
    """
    # --- Universal scaling (MaxLevelType=2) always matches ---
    # These scale 1-cap and cover any Wowhead level range
    if db_max_type == 2:
        return None

    # --- Check 1: Is the NPC on a completely wrong tier? ---

    # WRONG TIER LOW: Wowhead min is above the CT max
    # This means the NPC's lowest level exceeds what the CT can provide.
    # Allow some tolerance because Wowhead min can be slightly above CT max
    # due to scaling granularity.
    if wh_min > db_eff_max + 5:
        gap = wh_min - db_eff_max
        if gap > 30:
            severity = SEVERITY_CRITICAL
        elif gap > 10:
            severity = SEVERITY_MAJOR
        else:
            severity = SEVERITY_MINOR
        desc = (f"WH {wh_min}-{wh_max} but CT gives {db_min}-{db_eff_max} "
                f"(WH min is {gap} above CT max — needs higher tier)")
        return (CAT_WRONG_TIER_LOW, severity, desc)

    # WRONG TIER HIGH: Wowhead max is below the CT min
    # The NPC is too low-level for the assigned CT.
    if wh_max < db_min - 5:
        gap = db_min - wh_max
        if gap > 30:
            severity = SEVERITY_CRITICAL
        elif gap > 10:
            severity = SEVERITY_MAJOR
        else:
            severity = SEVERITY_MINOR
        desc = (f"WH {wh_min}-{wh_max} but CT gives {db_min}-{db_eff_max} "
                f"(WH max is {gap} below CT min — needs lower tier)")
        return (CAT_WRONG_TIER_HIGH, severity, desc)

    # --- Check 2: Same tier, but CT min is way off? ---
    # Only flag if the CT min is significantly ABOVE the WH min, meaning
    # the CT floor is too high for this NPC.
    # (CT min below WH min is fine — it just means the CT is broader)
    if db_min > wh_min + 15 and db_min > wh_max:
        # CT min is significantly above both WH min and WH max
        gap = db_min - wh_max
        severity = SEVERITY_MAJOR if gap > 10 else SEVERITY_MINOR
        desc = (f"WH {wh_min}-{wh_max} but CT min is {db_min} "
                f"(CT floor {gap} above WH max)")
        return (CAT_MIN_MISMATCH, severity, desc)

    # --- No mismatch ---
    return None


# =============================================================================
# Step 4: CT suggestion logic
# =============================================================================

# Level-range to recommended ContentTuningID (from zone_ct_mapping quick reference)
LEVEL_TO_CT = {
    # (wh_min, wh_max) -> ct_id
    # Broadest/most commonly used CTs per expansion tier
    (1, 80):   864,    # Universal scaling
    (1, 30):   73,     # Starter zones (Elwynn etc.)
    (5, 30):   2,      # Classic zones
    (7, 30):   11,     # Mid-classic
    (10, 30):  13,     # WotLK / mid-classic
    (15, 30):  23,     # Higher classic / TBC
    (20, 30):  41,     # TBC tier
    (25, 30):  42,     # TBC high
    (30, 35):  56,     # Cataclysm
    (10, 35):  57,     # MoP
    (10, 40):  64,     # WoD
    (10, 45):  633,    # Legion
    (45, 45):  628,    # Legion max
    (10, 60):  1227,   # BfA Chromie Time
    (50, 50):  690,    # Nazjatar/Mechagon
    (60, 60):  742,    # Shadowlands max
    (10, 70):  2151,   # Dragonflight
    (70, 70):  2151,   # DF max
    (70, 80):  2677,   # TWW
    (80, 80):  2677,   # TWW max
    (80, 83):  3085,   # Midnight
}

# For suggesting a CT based on the Wowhead MIN level alone (used when
# we know the tier is wrong but Wowhead max is unreliable due to Chromie Time)
MIN_LEVEL_TO_CT = [
    # (min_wh_level, max_wh_level, ct_id, description)
    (80, 999, 2677, "TWW (70-80)"),
    (70, 79,  2677, "TWW (70-80)"),
    (60, 69,  2151, "Dragonflight (10-70)"),
    (50, 59,  1227, "BfA Chromie (10-60)"),
    (45, 49,  633,  "Legion (10-45)"),
    (40, 44,  64,   "WoD (10-40)"),
    (35, 39,  57,   "MoP (10-35)"),
    (30, 34,  56,   "Cataclysm (30-35)"),
    (10, 29,  2,    "Classic (5-30)"),
    (1,  9,   864,  "Universal (1-cap)"),
]


def suggest_ct_for_level(wh_min, wh_max, current_ct_id):
    """
    Given a Wowhead level range, suggest the best ContentTuningID.
    Returns (ct_id, confidence, description) or (None, None, None).
    """
    # Exact match in LEVEL_TO_CT
    if (wh_min, wh_max) in LEVEL_TO_CT:
        ct = LEVEL_TO_CT[(wh_min, wh_max)]
        if ct != current_ct_id:
            return ct, "exact", f"exact range match ({wh_min}-{wh_max})"

    # For single-level NPCs, use the narrowest containing CT
    if wh_min == wh_max:
        level = wh_min
        best = None
        best_range = 999
        best_desc = ""
        for (lo, hi), ct in LEVEL_TO_CT.items():
            if lo <= level <= hi and ct != current_ct_id:
                rng = hi - lo
                if rng < best_range:
                    best = ct
                    best_range = rng
                    best_desc = f"narrowest containing CT for level {level}"
        if best:
            return best, "contains", best_desc

    # Fall back to MIN_LEVEL_TO_CT based on Wowhead min
    # This handles the Chromie Time case where WH max is inflated
    for lo, hi, ct, desc in MIN_LEVEL_TO_CT:
        if lo <= wh_min <= hi and ct != current_ct_id:
            return ct, "tier_match", f"tier match: WH min {wh_min} -> {desc}"

    return None, None, None


# =============================================================================
# Step 5: Generate report and SQL
# =============================================================================

def generate_report(mismatches, npc_names, db_data, wh_data, match_count):
    """Generate the text report."""
    report_path = os.path.join(OUTPUT_DIR, "level_range_report.txt")

    # Organize by category then severity
    by_cat = defaultdict(lambda: defaultdict(list))
    for entry, info in mismatches.items():
        by_cat[info["category"]][info["severity"]].append((entry, info))

    with open(report_path, "w", encoding="utf-8") as f:
        f.write("=" * 80 + "\n")
        f.write("NPC LEVEL RANGE VALIDATION REPORT\n")
        f.write("=" * 80 + "\n")
        f.write("Generated by validate_level_ranges.py\n")
        f.write(f"Expansion cap assumed: {EXPANSION_CAP}\n\n")

        f.write("METHODOLOGY\n")
        f.write("-" * 40 + "\n")
        f.write("Wowhead tooltips show Chromie Time scaled level ranges which are\n")
        f.write("often HIGHER than the raw ContentTuning max. This is expected.\n")
        f.write("We only flag mismatches where:\n")
        f.write("  - WH min level is ABOVE CT max (NPC needs a higher-tier CT)\n")
        f.write("  - WH max level is BELOW CT min (NPC needs a lower-tier CT)\n")
        f.write("  - CT min is significantly above WH max (CT floor too high)\n")
        f.write("Universal scaling CTs (MaxLevelType=2) are always accepted.\n\n")

        # Summary
        overlap = set(wh_data.keys()) & set(db_data.keys())
        f.write("SUMMARY\n")
        f.write("-" * 40 + "\n")
        f.write(f"Wowhead NPCs with level data:   {len(wh_data):>8,}\n")
        f.write(f"DB NPCs with ContentTuning:      {len(db_data):>8,}\n")
        f.write(f"NPCs in both sources:            {len(overlap):>8,}\n")
        f.write(f"Matching (OK):                   {match_count:>8,}\n")
        f.write(f"Total mismatches found:          {len(mismatches):>8,}\n\n")

        cat_labels = {
            CAT_WRONG_TIER_LOW: "WRONG TIER (too low) — NPC needs higher-level CT",
            CAT_WRONG_TIER_HIGH: "WRONG TIER (too high) — NPC needs lower-level CT",
            CAT_MIN_MISMATCH: "MIN LEVEL MISMATCH — CT floor too high for NPC",
        }

        for cat in [CAT_WRONG_TIER_LOW, CAT_WRONG_TIER_HIGH, CAT_MIN_MISMATCH]:
            cat_entries = by_cat.get(cat, {})
            total = sum(len(v) for v in cat_entries.values())
            f.write(f"  {cat_labels[cat]}: {total}\n")
            for sev in [SEVERITY_CRITICAL, SEVERITY_MAJOR, SEVERITY_MINOR]:
                cnt = len(cat_entries.get(sev, []))
                if cnt:
                    f.write(f"    {sev}: {cnt}\n")
        f.write("\n")

        # CT distribution of mismatches
        ct_dist = defaultdict(int)
        for entry, info in mismatches.items():
            db = db_data[entry]
            ct_dist[db["ct_id"]] += 1

        f.write("MISMATCH DISTRIBUTION BY CURRENT CT\n")
        f.write("-" * 40 + "\n")
        for ct_id, cnt in sorted(ct_dist.items(), key=lambda x: -x[1])[:20]:
            f.write(f"  CT {ct_id:>5d}: {cnt:>5d} mismatches\n")
        f.write("\n")

        # Detailed listings by category + severity
        for cat in [CAT_WRONG_TIER_LOW, CAT_WRONG_TIER_HIGH, CAT_MIN_MISMATCH]:
            cat_entries = by_cat.get(cat, {})
            total = sum(len(v) for v in cat_entries.values())
            if not total:
                continue

            f.write("=" * 80 + "\n")
            f.write(f"{cat_labels[cat]} ({total} NPCs)\n")
            f.write("=" * 80 + "\n\n")

            for sev in [SEVERITY_CRITICAL, SEVERITY_MAJOR, SEVERITY_MINOR]:
                entries = cat_entries.get(sev, [])
                if not entries:
                    continue

                f.write(f"--- {sev} ({len(entries)} NPCs) ---\n\n")
                entries.sort(key=lambda x: x[0])

                for entry, info in entries:
                    name = npc_names.get(entry, "???")
                    wh_min, wh_max = wh_data[entry]
                    db = db_data[entry]

                    f.write(f"  Entry {entry:>7d}  {name:<40s}\n")
                    f.write(f"    Wowhead:  Level {wh_min}-{wh_max}\n")
                    f.write(f"    Database: CT {db['ct_id']} -> "
                            f"{db['min_level']}-{db['effective_max']}")
                    if db["max_level_type"] == 2:
                        f.write(f" (MaxLevelType=2)")
                    f.write(f" [Exp {db['expansion_id']}]\n")
                    f.write(f"    Issue:    {info['description']}\n")

                    if info.get("suggested_ct"):
                        f.write(f"    Suggest:  CT {info['suggested_ct']} "
                                f"({info['suggest_confidence']}: "
                                f"{info['suggest_desc']})\n")

                    f.write("\n")

    print(f"  Report written to: {report_path}")
    return report_path


def generate_sql(fixable, npc_names, db_data, wh_data):
    """Generate SQL file for fixable mismatches."""
    sql_path = os.path.join(OUTPUT_DIR, "npc_level_range_fixes.sql")

    # Group fixes by suggested CT
    by_ct = defaultdict(list)
    for entry, info in fixable.items():
        ct = info["suggested_ct"]
        by_ct[ct].append(entry)

    total_fixes = sum(len(v) for v in by_ct.values())

    with open(sql_path, "w", encoding="utf-8") as f:
        f.write("-- " + "=" * 77 + "\n")
        f.write("-- NPC Level Range Fixes -- ContentTuningID corrections\n")
        f.write("-- " + "=" * 77 + "\n")
        f.write("-- Generated by validate_level_ranges.py\n")
        f.write("-- \n")
        f.write("-- These NPCs have non-zero ContentTuningIDs that produce INCORRECT level\n")
        f.write("-- ranges compared to Wowhead data. Only unambiguous mismatches are included:\n")
        f.write("--   - WRONG_TIER_LOW: Wowhead min level above CT max (needs higher CT)\n")
        f.write("--   - WRONG_TIER_HIGH: Wowhead max level below CT min (needs lower CT)\n")
        f.write("-- Only CRITICAL/MAJOR severity with exact or tier-match confidence.\n")
        f.write(f"-- Total fixes: {total_fixes} NPCs\n")
        f.write("-- " + "=" * 77 + "\n\n")

        for ct_id in sorted(by_ct.keys()):
            entries = sorted(by_ct[ct_id])

            # Describe this CT
            ct_desc = ""
            for lo, hi, cid, desc in MIN_LEVEL_TO_CT:
                if cid == ct_id:
                    ct_desc = f" -- {desc}"
                    break

            f.write(f"-- ContentTuningID {ct_id}{ct_desc} -- {len(entries)} NPCs\n")

            BATCH = 100
            for i in range(0, len(entries), BATCH):
                batch = entries[i:i + BATCH]

                for entry in batch:
                    name = npc_names.get(entry, "???")
                    wh_min, wh_max = wh_data[entry]
                    db = db_data[entry]
                    old_ct = db["ct_id"]
                    f.write(f"-- {entry} {name}: WH {wh_min}-{wh_max}, "
                            f"was CT {old_ct} ({db['min_level']}-{db['effective_max']})\n")

                entry_list = ", ".join(str(e) for e in batch)
                f.write(
                    f"UPDATE `creature_template_difficulty` "
                    f"SET `ContentTuningID` = {ct_id} "
                    f"WHERE `Entry` IN ({entry_list}) "
                    f"AND `DifficultyID` = 0;\n\n"
                )

        if total_fixes == 0:
            f.write("-- No unambiguous fixes found. All mismatches require manual review.\n")

    print(f"  SQL written to: {sql_path}")
    return sql_path


# =============================================================================
# Main
# =============================================================================

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Step 1: Extract Wowhead level data
    wh_data = extract_wowhead_levels()

    # Step 2: Get DB ContentTuning data
    db_data = get_db_content_tuning()

    # Step 3: Compare and classify mismatches
    print("\nComparing level ranges...")
    overlap = set(wh_data.keys()) & set(db_data.keys())
    print(f"  NPCs present in both sources: {len(overlap)}")

    mismatches = {}
    match_count = 0

    for entry in overlap:
        wh_min, wh_max = wh_data[entry]
        db = db_data[entry]

        result = classify_mismatch(
            wh_min, wh_max,
            db["min_level"], db["effective_max"],
            db["max_level_type"]
        )

        if result is None:
            match_count += 1
            continue

        category, severity, description = result

        # Try to suggest a fix
        suggested_ct, confidence, suggest_desc = suggest_ct_for_level(
            wh_min, wh_max, db["ct_id"]
        )

        mismatches[entry] = {
            "category": category,
            "severity": severity,
            "description": description,
            "suggested_ct": suggested_ct,
            "suggest_confidence": confidence,
            "suggest_desc": suggest_desc,
        }

    print(f"  Matches (OK):        {match_count}")
    print(f"  Mismatches found:    {len(mismatches)}")

    # Count by category + severity
    cat_sev = defaultdict(lambda: defaultdict(int))
    for info in mismatches.values():
        cat_sev[info["category"]][info["severity"]] += 1

    for cat in [CAT_WRONG_TIER_LOW, CAT_WRONG_TIER_HIGH, CAT_MIN_MISMATCH]:
        sevs = cat_sev.get(cat, {})
        total = sum(sevs.values())
        if total:
            detail = ", ".join(f"{s}: {c}" for s, c in
                               sorted(sevs.items(), key=lambda x: x[0]))
            print(f"    {cat}: {total} ({detail})")

    # Step 4: Get NPC names for report
    print("\nFetching NPC names...")
    all_entries = set(mismatches.keys())
    npc_names = get_npc_names(all_entries)
    print(f"  Got names for {len(npc_names)} NPCs")

    # Step 5: Generate report
    print("\nGenerating report...")
    generate_report(mismatches, npc_names, db_data, wh_data, match_count)

    # Step 6: Generate SQL for fixable entries
    # Only include CRITICAL/MAJOR with good confidence suggestions
    fixable = {}
    for entry, info in mismatches.items():
        if info["severity"] in (SEVERITY_CRITICAL, SEVERITY_MAJOR):
            if info.get("suggested_ct") and info["suggest_confidence"] in (
                "exact", "contains", "tier_match"
            ):
                fixable[entry] = info

    print(f"\nFixable mismatches (CRITICAL/MAJOR, high confidence): {len(fixable)}")
    generate_sql(fixable, npc_names, db_data, wh_data)

    # Final summary
    print(f"\n{'=' * 70}")
    print("DONE")
    print(f"{'=' * 70}")
    print(f"Total NPCs compared:     {len(overlap):>8,}")
    print(f"Matching (OK):           {match_count:>8,}")
    print(f"Mismatches:              {len(mismatches):>8,}")
    for cat in [CAT_WRONG_TIER_LOW, CAT_WRONG_TIER_HIGH, CAT_MIN_MISMATCH]:
        sevs = cat_sev.get(cat, {})
        total = sum(sevs.values())
        print(f"  {cat}: {total}")
    print(f"Fixable (SQL generated): {len(fixable):>8,}")


if __name__ == "__main__":
    main()
