#!/usr/bin/env python3
"""
Build table_info_r3.json — fixed column mappings for WTL CSVs.

Fixes over R2:
  1. Off-by-one array index: DB FooN (1-indexed) -> CSV Foo[N-1] (0-indexed)
  2. Coordinate X/Y/Z -> [0]/[1]/[2] bracket mapping
  3. broadcast_text_duration: semantic PK + Duration/DurationMS mapping
  4. Includes column types from MySQL for type-aware comparison
"""

import csv
import json
import os
import re

WTL_DIR = "C:/Users/atayl/VoxCore/ExtTools/WoW.tools/dbcs/12.0.1.66220/dbfilesclient"
R1_INFO = "C:/Users/atayl/VoxCore/hotfix_audit/table_info.json"
R2_TABLES = "C:/Users/atayl/VoxCore/hotfix_audit/tables_r2.json"
COL_TYPES = "C:/Users/atayl/VoxCore/hotfix_audit/col_types.json"
OUTPUT = "C:/Users/atayl/VoxCore/hotfix_audit/table_info_r3.json"

# R1 manual mappings (DB col -> CSV col)
MANUAL_MAPS = {
    "item_sparse": {
        "FactionRelated": "OppositeFactionItemID",
        "DamageDamageType": "DamageType",
    },
    "spell_effect": {
        "EffectBasePoints": "EffectBasePointsF",
        "TargetNodeGraph": "Node__Field_12_0_0_63534_001",
    },
    "gameobjects": {
        "Unknown1100": "Field_11_0_0_54210_011",
    },
    "spell_item_enchantment": {
        "MinItemLevel": "ItemLevelMin",
        "MaxItemLevel": "ItemLevelMax",
    },
    "creature": {
        "FemaleName": "NameAlt_lang",
        "SubName": "Title_lang",
        "FemaleSubName": "TitleAlt_lang",
        "Type": "CreatureType",
        "Family": "CreatureFamily",
        "ItemID1": "AlwaysItem[0]",
        "ItemID2": "AlwaysItem[1]",
        "ItemID3": "AlwaysItem[2]",
        "DisplayIDProbability1": "DisplayProbability[0]",
        "DisplayIDProbability2": "DisplayProbability[1]",
        "DisplayIDProbability3": "DisplayProbability[2]",
        "DisplayIDProbability4": "DisplayProbability[3]",
    },
    "azerite_unlock_mapping": {
        "ItemLevel": "MinItemLevel",
        "ItemBonusListHead": "HeadBonus",
        "ItemBonusListShoulders": "ShoulderBonus",
        "ItemBonusListChest": "ChestBonus",
        "AzeriteUnlockMappingSetID": "SetID",
    },
    "ui_map_assignment": {
        "Unknown1125": "Field_11_2_5_62687_010",
        "Region1X": "Region[0]",
        "Region1Y": "Region[1]",
        "Region1Z": "Region[2]",
        "Region2X": "Region[3]",
        "Region2Y": "Region[4]",
        "Region2Z": "Region[5]",
    },
    "content_tuning": {
        "HealthItemLevelCurveID": "HPScalingCurveID",
        "DamageItemLevelCurveID": "DMGScalingCurveID",
        "HealthPrimaryStatCurveID": "HPPrimaryStatScalingCurveID",
        "DamagePrimaryStatCurveID": "DMGPrimaryStatScalingCurveID",
        "MinLevel": "MinLevelSquish",
        "MaxLevel": "MaxLevelSquish",
        "MinLevelType": "MinLevelScalingOffset",
        "MaxLevelType": "MaxLevelScalingOffset",
        "TargetLevelDelta": "AllowedMinOffset",
        "TargetLevelMaxDelta": "AllowedMaxOffset",
        "TargetLevelMin": "LfgMinLevel",
        "TargetLevelMax": "LfgMaxLevel",
        "MinItemLevel": "ILevel",
        "QuestXpMultiplier": "XpMultQuest",
    },
    "broadcast_text_duration": {
        "Duration": "DurationMS",
    },
    "curve_point": {
        "PreSLSquishPosX": "PosPreSquish[0]",
        "PreSLSquishPosY": "PosPreSquish[1]",
    },
    "light_params": {
        "Field_12_0_1_65617_016": "Field_12_0_0_63534_016",
        "Field_12_0_1_65617_017": "Field_12_0_0_63534_017",
        "Field_12_0_1_65617_018": "Field_12_0_0_63534_018",
        "Field_12_0_1_65617_019": "Field_12_0_0_63534_019",
        "Field_12_0_1_65617_020": "Field_12_0_0_63534_020",
        "Field_12_0_1_65617_021": "Field_12_0_0_63534_021",
        "Field_12_0_1_65617_022": "Field_12_0_0_63534_022",
        "Field_12_0_1_65617_023": "Field_12_0_0_63534_023",
        "Field_12_0_1_65617_024": "Field_12_0_0_63534_024",
        "Field_12_0_1_65617_025": "Field_12_0_0_63534_025",
        "Field_12_0_1_65617_026": "Field_12_0_0_63534_026",
        "Field_12_0_1_65617_027": "Field_12_0_0_63534_027",
        "Field_12_0_1_65617_028": "Field_12_0_0_63534_028",
        "Field_12_0_1_65617_029": "Field_12_0_0_63534_029",
    },
    "transmog_set": {
        "Unknown810": "CompleteWorldStateID",
        "PatchID": "PatchIntroduced",
        "PlayerConditionID": "ConditionID",
    },
    "scene_script_package": {
        "Flags": "Field_12_0_0_64499_001",
        "Unknown915": "Field_9_1_5_39977_001",
    },
    "quest_v2": {
        "UiQuestDetailsTheme": "UiQuestDetailsThemeID",
    },
    "creature_difficulty": {
        "MinLevel": "Field_9_0_1_35522_003Min",
        "MaxLevel": "Field_9_0_1_35522_003Max",
    },
}

# broadcast_text_duration uses a non-standard PK
CUSTOM_PK = {
    "broadcast_text_duration": {
        "logical_pk": ["BroadcastTextID", "Locale"],
        # full PK still includes ID + VerifiedBuild for traceability
    },
}


def normalize_name(name):
    """Normalize for basic matching: lowercase, strip _lang."""
    n = re.sub(r'\[(\d+)\]', r'_\1', name)
    n = n.lower()
    n = re.sub(r'_lang$', '', n)
    return n


def normalize_stripped(name):
    """Aggressive: remove underscores."""
    n = normalize_name(name)
    n = re.sub(r'[^a-z0-9]', '', n)
    return n


def find_wtl_csv(table_name):
    candidate = table_name.replace("_", "") + ".csv"
    path = os.path.join(WTL_DIR, candidate)
    if os.path.exists(path):
        return candidate, path
    candidate = table_name + ".csv"
    path = os.path.join(WTL_DIR, candidate)
    if os.path.exists(path):
        return candidate, path
    return None, None


def get_csv_headers(path):
    with open(path, encoding="utf-8-sig") as f:
        reader = csv.reader(f)
        return next(reader)


def build_bracket_index(csv_headers):
    """Build lookup: base_name -> {index: csv_col_name} for bracket columns."""
    bracket_cols = {}
    for h in csv_headers:
        m = re.match(r'^(.+)\[(\d+)\]$', h)
        if m:
            base, idx = m.group(1), int(m.group(2))
            bracket_cols.setdefault(base, {})[idx] = h
    return bracket_cols


def build_column_mapping(db_cols, csv_headers, table_name):
    """Map DB columns to CSV columns with all R3 fixes."""
    manual = MANUAL_MAPS.get(table_name, {})

    csv_set = set(csv_headers)
    csv_norm = {}
    csv_stripped = {}
    for h in csv_headers:
        csv_norm[normalize_name(h)] = h
        csv_stripped[normalize_stripped(h)] = h

    bracket_index = build_bracket_index(csv_headers)
    db_col_set = set(db_cols)

    # Pre-compute: for each base name, is the DB array 0-indexed or 1-indexed?
    # If base+"0" exists in db_cols -> 0-indexed (direct: FooN -> Foo[N])
    # If only base+"1" exists -> 1-indexed (offset: FooN -> Foo[N-1])
    db_array_bases = {}
    for col in db_cols:
        m = re.match(r'^(.+?)(\d+)$', col)
        if m:
            base = m.group(1)
            idx = int(m.group(2))
            if base not in db_array_bases:
                db_array_bases[base] = set()
            db_array_bases[base].add(idx)

    def is_zero_indexed(base):
        """Check if a DB array base name starts at index 0."""
        if base in db_array_bases:
            return 0 in db_array_bases[base]
        return False

    shared = []
    matched_db = set()

    for db_col in db_cols:
        if db_col == "VerifiedBuild":
            continue

        # 1. Manual mapping first
        if db_col in manual:
            csv_col = manual[db_col]
            if csv_col in csv_set:
                shared.append((db_col, csv_col))
                matched_db.add(db_col)
                continue
            norm_target = normalize_name(csv_col)
            if norm_target in csv_norm:
                shared.append((db_col, csv_norm[norm_target]))
                matched_db.add(db_col)
                continue

        # 2. Direct match
        if db_col in csv_set:
            shared.append((db_col, db_col))
            matched_db.add(db_col)
            continue

        # 3. Normalized match
        db_norm = normalize_name(db_col)
        if db_norm in csv_norm:
            shared.append((db_col, csv_norm[db_norm]))
            matched_db.add(db_col)
            continue

        # 4. Array index mapping (DB FooN -> CSV Foo[N] or Foo[N-1])
        # Must come BEFORE stripped match to prevent wrong digit-based matching
        m = re.match(r'^(.+?)(\d+)$', db_col)
        if m:
            base, idx = m.group(1), int(m.group(2))
            if base in bracket_index:
                if is_zero_indexed(base):
                    # 0-indexed: FooN -> Foo[N]
                    csv_idx = idx
                else:
                    # 1-indexed: FooN -> Foo[N-1]
                    csv_idx = idx - 1
                if csv_idx in bracket_index[base]:
                    shared.append((db_col, bracket_index[base][csv_idx]))
                    matched_db.add(db_col)
                    continue
                # Also try direct index (in case detection failed)
                if idx in bracket_index[base]:
                    shared.append((db_col, bracket_index[base][idx]))
                    matched_db.add(db_col)
                    continue

        # 5. Coordinate X/Y/Z -> [0]/[1]/[2]
        xyz_match = re.match(r'^(.+?)(X|Y|Z)$', db_col)
        if xyz_match:
            coord_base = xyz_match.group(1)
            suffix = xyz_match.group(2)
            idx_map = {"X": 0, "Y": 1, "Z": 2}

            if coord_base in bracket_index and idx_map[suffix] in bracket_index[coord_base]:
                shared.append((db_col, bracket_index[coord_base][idx_map[suffix]]))
                matched_db.add(db_col)
                continue

            # Try case-insensitive base
            for csv_base, indices in bracket_index.items():
                if csv_base.lower() == coord_base.lower() and idx_map[suffix] in indices:
                    shared.append((db_col, indices[idx_map[suffix]]))
                    matched_db.add(db_col)
                    break
            else:
                pass  # Fall through
            if db_col in matched_db:
                continue

        # 6. Stripped match (last resort for non-array columns)
        db_stripped = normalize_stripped(db_col)
        if db_stripped in csv_stripped:
            shared.append((db_col, csv_stripped[db_stripped]))
            matched_db.add(db_col)
            continue

    return shared


def main():
    with open(R1_INFO) as f:
        r1_tables = json.load(f)
    r1_map = {t["table"]: t for t in r1_tables}

    with open(R2_TABLES) as f:
        r2_tables = json.load(f)

    with open(COL_TYPES) as f:
        col_types = json.load(f)

    r3_info = []
    unmapped = []

    for t in r2_tables:
        table = t["table"]
        r1 = r1_map.get(table)
        if not r1:
            unmapped.append(table)
            continue

        csv_name, csv_path = find_wtl_csv(table)
        if not csv_path:
            unmapped.append(table)
            continue

        csv_headers = get_csv_headers(csv_path)
        db_cols = r1["db_cols"]
        pk_cols = r1["pk_cols"]

        shared = build_column_mapping(db_cols, csv_headers, table)

        # Get column types
        table_col_types = col_types.get(table, {})

        # Custom PK for broadcast_text_duration
        custom = CUSTOM_PK.get(table, {})
        logical_pk = custom.get("logical_pk")

        total_mappable = len([c for c in db_cols if c != "VerifiedBuild"])
        coverage = len(shared) / total_mappable * 100 if total_mappable > 0 else 0

        entry = {
            "table": table,
            "csv_file": csv_name,
            "csv_path": csv_path,
            "pk_cols": pk_cols,
            "db_cols": db_cols,
            "csv_headers": csv_headers,
            "shared_cols": shared,
            "col_types": table_col_types,
            "coverage_pct": round(coverage, 1),
            "row_count": t["remaining"],
        }
        if logical_pk:
            entry["logical_pk_override"] = logical_pk

        r3_info.append(entry)

    with open(OUTPUT, "w") as f:
        json.dump(r3_info, f, indent=2)

    # Report
    low_cov = [(e["table"], e["coverage_pct"]) for e in r3_info if e["coverage_pct"] < 80]
    low_cov.sort(key=lambda x: x[1])

    print(f"Tables mapped: {len(r3_info)}")
    print(f"Unmapped: {len(unmapped)}")
    if low_cov:
        print(f"Tables with <80% coverage: {len(low_cov)}")
        for t, c in low_cov:
            print(f"  {t}: {c}%")
    else:
        print("All tables >= 80% coverage")

    # Compare vs R2 to see what changed
    with open("C:/Users/atayl/VoxCore/hotfix_audit/table_info_r2.json") as f:
        r2_info = json.load(f)
    r2_map = {e["table"]: e for e in r2_info}

    changed = 0
    for e in r3_info:
        r2 = r2_map.get(e["table"])
        if not r2:
            changed += 1
            continue
        r2_shared = set((a, b) for a, b in r2["shared_cols"])
        r3_shared = set((a, b) for a, b in e["shared_cols"])
        if r2_shared != r3_shared:
            changed += 1
            added = r3_shared - r2_shared
            removed = r2_shared - r3_shared
            if added or removed:
                print(f"  CHANGED {e['table']}: +{len(added)} -{len(removed)} cols")

    print(f"\nTotal tables with mapping changes: {changed}")
    print(f"Saved: {OUTPUT}")


if __name__ == "__main__":
    main()
