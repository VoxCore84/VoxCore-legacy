#!/usr/bin/env python3
"""Generate round 3 cleanup SQL from R3 results."""

import json
import os
import sys
import glob
from datetime import datetime

RESULTS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "results_r3")
OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

sys.path.insert(0, "C:/Users/atayl/VoxCore/wago")
from table_hashes import TABLE_HASHES

NAME_FIXUPS = {
    "gameobject_art_kit": "game_object_art_kit",
    "gameobject_display_info": "game_object_display_info",
    "gameobject_label": "game_object_label",
    "mcr_slot_x_mcr_category": "mcr_slot_xmcr_category",
}


def get_table_hash(table_name):
    fixed = NAME_FIXUPS.get(table_name, table_name)
    return TABLE_HASHES.get(fixed)


def has_overlap(r):
    pk_cols = [c for c in r.get("pk_cols", []) if c != "VerifiedBuild"]
    if not pk_cols:
        return False
    redundant_pks = set()
    for row in r["redundant"]:
        pk = tuple(str(row.get(c)) for c in pk_cols)
        redundant_pks.add(pk)
    for item in r.get("override", []):
        pk_dict = item.get("pk", item)
        pk = tuple(str(pk_dict.get(c)) for c in pk_cols)
        if pk in redundant_pks:
            return True
    for row in r.get("new", []):
        pk = tuple(str(row.get(c)) for c in pk_cols)
        if pk in redundant_pks:
            return True
    return False


def main():
    results = []
    for path in sorted(glob.glob(os.path.join(RESULTS_DIR, "*.json"))):
        with open(path) as f:
            results.append(json.load(f))

    fully_redundant = []
    partial_redundant = []

    for r in results:
        total = r["total_rows"]
        n_r = len(r["redundant"])
        if total == 0 or n_r == 0:
            continue
        if n_r == total:
            fully_redundant.append(r)
        else:
            partial_redundant.append(r)

    lines = []
    lines.append("-- HOTFIX REDUNDANCY CLEANUP — ROUND 3 (Type-Aware R3 Audit)")
    lines.append(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("-- BEFORE RUNNING: python C:/Users/atayl/VoxCore/wago/db_snapshot.py snapshot --db hotfixes --label pre-round3-cleanup")
    lines.append("--")
    lines.append("-- R3 fixes: float32 relative tolerance, unsigned/signed int32,")
    lines.append("-- broadcast_text_duration logical PK, corrected array index mapping")
    lines.append("--")
    lines.append(f"-- This script uses TRUNCATE for {len(fully_redundant)} fully-redundant tables")
    lines.append(f"-- and targeted DELETEs for {len(partial_redundant)} partially-redundant tables.")
    lines.append("--")
    lines.append("")

    # Section 1: TRUNCATE
    fully_redundant.sort(key=lambda r: -r["total_rows"])
    total_truncated = sum(r["total_rows"] for r in fully_redundant)
    lines.append("-- ======================================================================")
    lines.append(f"-- SECTION 1: TRUNCATE {len(fully_redundant)} fully-redundant tables ({total_truncated:,} rows)")
    lines.append("-- These tables are 100% identical to WTL DBC2CSV baseline.")
    lines.append("-- ======================================================================")
    lines.append("")

    for r in fully_redundant:
        lines.append(f"-- {r['table']}: {r['total_rows']:,} rows (100% redundant)")
        lines.append(f"TRUNCATE TABLE `hotfixes`.`{r['table']}`;")
    lines.append("")

    # Section 1b: hotfix_data cleanup
    hashes_with_names = []
    unmapped_tables = []
    for r in fully_redundant:
        h = get_table_hash(r["table"])
        if h is not None:
            hashes_with_names.append((r["table"], h))
        else:
            unmapped_tables.append(r["table"])

    if hashes_with_names:
        lines.append("-- ======================================================================")
        lines.append(f"-- SECTION 1b: Clean hotfix_data entries for {len(hashes_with_names)} TRUNCATEd tables")
        lines.append("-- ======================================================================")
        lines.append("")
        hash_values = [h for _, h in hashes_with_names]
        for i in range(0, len(hash_values), 50):
            batch = hash_values[i:i + 50]
            hash_list = ", ".join(str(h) for h in batch)
            batch_names = [n for n, _ in hashes_with_names[i:i + 50]]
            lines.append(f"-- Tables: {', '.join(batch_names)}")
            lines.append(f"DELETE FROM `hotfixes`.`hotfix_data` WHERE `TableHash` IN ({hash_list});")
        lines.append("")

        if unmapped_tables:
            lines.append(f"-- WARNING: {len(unmapped_tables)} TRUNCATEd tables unmapped to TableHash:")
            for t in unmapped_tables:
                lines.append(f"--   {t}")
            lines.append("")

    # Section 2: Targeted DELETEs
    partial_redundant.sort(key=lambda r: -len(r["redundant"]))
    total_deletes = sum(len(r["redundant"]) for r in partial_redundant)
    lines.append("-- ======================================================================")
    lines.append(f"-- SECTION 2: Targeted DELETEs for {len(partial_redundant)} partially-redundant tables ({total_deletes:,} rows)")
    lines.append("-- ======================================================================")
    lines.append("")
    lines.append("SET autocommit=0;")
    lines.append("START TRANSACTION;")
    lines.append("")

    for r in partial_redundant:
        redundant = r["redundant"]
        if not redundant:
            continue
        table = r["table"]
        total = r["total_rows"]
        pk_cols = r.get("pk_cols", [])
        logical_pk = [c for c in pk_cols if c != "VerifiedBuild"]
        pct = len(redundant) / total * 100 if total > 0 else 0

        overlap = has_overlap(r)

        lines.append(f"-- {table}: {len(redundant):,} redundant rows of {total:,} total ({pct:.1f}%)")
        if overlap:
            lines.append(f"-- NOTE: Uses full PK (ID + VerifiedBuild) -- same ID has both redundant and override rows")

        if len(logical_pk) == 1 and not overlap:
            pk_col = logical_pk[0]
            ids = sorted(set(str(row[pk_col]) for row in redundant), key=lambda x: int(x) if x.lstrip('-').isdigit() else x)
            for i in range(0, len(ids), 500):
                batch = ids[i:i + 500]
                id_list = ", ".join(batch)
                lines.append(f"DELETE FROM `hotfixes`.`{table}` WHERE `{pk_col}` IN ({id_list});")
        elif len(logical_pk) == 1 and overlap:
            pk_col = logical_pk[0]
            by_vb = {}
            for row in redundant:
                vb = row.get("VerifiedBuild", 0)
                by_vb.setdefault(vb, []).append(str(row[pk_col]))
            for vb, ids in sorted(by_vb.items()):
                ids_sorted = sorted(set(ids), key=lambda x: int(x) if x.lstrip('-').isdigit() else x)
                for i in range(0, len(ids_sorted), 500):
                    batch = ids_sorted[i:i + 500]
                    id_list = ", ".join(batch)
                    lines.append(f"DELETE FROM `hotfixes`.`{table}` WHERE `{pk_col}` IN ({id_list}) AND `VerifiedBuild` = {vb};")
        else:
            for pk_dict in redundant:
                where_parts = []
                for col in pk_cols:
                    val = pk_dict.get(col)
                    if val is None:
                        where_parts.append(f"`{col}` IS NULL")
                    elif isinstance(val, (int, float)):
                        where_parts.append(f"`{col}` = {val}")
                    else:
                        escaped = str(val).replace("'", "''")
                        where_parts.append(f"`{col}` = '{escaped}'")
                where = " AND ".join(where_parts)
                lines.append(f"DELETE FROM `hotfixes`.`{table}` WHERE {where};")
        lines.append("")

    lines.append("COMMIT;")
    lines.append("")
    lines.append(f"-- Total: {len(fully_redundant)} TRUNCATEs ({total_truncated:,} rows)")
    lines.append(f"--        + hotfix_data cleanup for {len(hashes_with_names)} table hashes")
    lines.append(f"--        + {total_deletes:,} targeted DELETEs across {len(partial_redundant)} tables")
    lines.append(f"--        = {total_truncated + total_deletes:,} rows removed")

    sql = "\n".join(lines)
    out_path = os.path.join(OUTPUT_DIR, "hotfix_cleanup_round3.sql")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(sql)

    print(f"Written: {out_path}")
    print(f"Fully redundant: {len(fully_redundant)} tables, {total_truncated:,} rows (TRUNCATE)")
    print(f"hotfix_data cleanup: {len(hashes_with_names)} table hashes")
    if unmapped_tables:
        print(f"WARNING: {len(unmapped_tables)} unmapped: {unmapped_tables}")
    print(f"Partially redundant: {len(partial_redundant)} tables, {total_deletes:,} rows (DELETE)")
    print(f"Total cleanup: {total_truncated + total_deletes:,} rows")


if __name__ == "__main__":
    main()
