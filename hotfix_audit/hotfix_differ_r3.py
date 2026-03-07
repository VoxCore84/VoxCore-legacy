#!/usr/bin/env python3
"""
Hotfix Redundancy Differ — Round 3: type-aware comparison with float32 fix.

Fixes over R2:
  1. Float32-aware comparison: uses struct.pack('f') for MySQL FLOAT columns
  2. Exact integer comparison for INT/SMALLINT/TINYINT/BIGINT/MEDIUMINT
  3. broadcast_text_duration: joins on (BroadcastTextID, Locale) instead of ID
  4. Reads column types from table_info_r3.json

Usage:
    python hotfix_differ_r3.py --config table_info_r3.json --tables table1,table2,...
"""

import argparse
import csv
import json
import os
import struct
import sys
import time
import pymysql


CSV_DIR = "C:/Users/atayl/VoxCore/ExtTools/WoW.tools/dbcs/12.0.1.66220/dbfilesclient"
RESULTS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "results_r3")

INT_TYPES = {"int", "smallint", "tinyint", "bigint", "mediumint"}
FLOAT_TYPES = {"float"}
DOUBLE_TYPES = {"double"}
TEXT_TYPES = {"text", "mediumtext", "longtext", "varchar", "char"}


def connect_mysql():
    return pymysql.connect(
        host="127.0.0.1",
        user="root",
        password="admin",
        database="hotfixes",
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
    )


def load_csv_data(csv_file, pk_csv_cols, shared_csv_cols):
    """Load CSV into a dict keyed by primary key tuple."""
    path = os.path.join(CSV_DIR, csv_file)
    data = {}
    with open(path, "r", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                pk = tuple(row[col] for col in pk_csv_cols)
            except KeyError:
                continue
            data[pk] = {col: row.get(col, "") for col in shared_csv_cols}
    return data


def float32_equal(a_str, b_str):
    """Compare two numeric values accounting for MySQL FLOAT precision loss.

    MySQL FLOAT stores as IEEE 754 float32, but TC's SQL serialization
    truncates to ~6 significant digits. So the stored value may differ
    slightly from the original DBC float32. We compare at float32 level
    first, then fall back to relative tolerance for serialization artifacts.
    """
    try:
        a = float(a_str)
        b = float(b_str)
    except (ValueError, TypeError):
        return False
    if a == b:
        return True
    # Pack both to float32 and compare bits
    a32 = struct.unpack('f', struct.pack('f', a))[0]
    b32 = struct.unpack('f', struct.pack('f', b))[0]
    if a32 == b32:
        return True
    # Relative tolerance for TC SQL serialization artifacts (~6 sig digits)
    max_abs = max(abs(a32), abs(b32))
    if max_abs == 0:
        return True
    return abs(a32 - b32) / max_abs < 1e-5


def compare_values(db_val, csv_val, csv_col_name, col_type):
    """Type-aware comparison between hotfix DB and CSV values.

    Returns True if they match (redundant for this column).
    """
    is_lang = csv_col_name.endswith("_lang")
    base_type = col_type.lower().split("(")[0].strip() if col_type else ""

    # NULL handling
    if db_val is None and csv_val is None:
        return True

    if (db_val is not None and csv_val is not None
            and str(db_val).strip() == "" and str(csv_val).strip() == ""):
        return True

    if db_val is None and csv_val is not None:
        if is_lang and csv_val.strip() == "":
            return True
        return False
    if csv_val is None or csv_val == "":
        if is_lang and (db_val is None or str(db_val).strip() == ""):
            return True
        if db_val is None:
            return True
        return str(db_val).strip() == "" if is_lang else False

    db_str = str(db_val).strip()
    csv_str = str(csv_val).strip()

    # Type-aware comparison
    if base_type in INT_TYPES:
        # Exact integer comparison, with unsigned/signed int32 handling
        try:
            db_int = int(float(db_str))
            csv_int = int(float(csv_str))
            if db_int == csv_int:
                return True
            # Check if they're the same 32-bit pattern (unsigned vs signed)
            if db_int >= 0 and csv_int < 0:
                if (db_int & 0xFFFFFFFF) == (csv_int & 0xFFFFFFFF):
                    return True
            elif csv_int >= 0 and db_int < 0:
                if (csv_int & 0xFFFFFFFF) == (db_int & 0xFFFFFFFF):
                    return True
            return False
        except (ValueError, OverflowError):
            return db_str == csv_str

    if base_type in FLOAT_TYPES:
        # Float32 bit-level comparison
        return float32_equal(db_str, csv_str)

    if base_type in DOUBLE_TYPES:
        # Double with tight epsilon
        try:
            return abs(float(db_str) - float(csv_str)) < 1e-10
        except (ValueError, OverflowError):
            return db_str == csv_str

    if base_type in TEXT_TYPES:
        return db_str == csv_str

    # Fallback: try numeric, then string
    try:
        db_num = float(db_str)
        csv_num = float(csv_str)
        if db_num == 0.0 and csv_num == 0.0:
            return True
        # Use float32 comparison as safe default for unknown numeric types
        return float32_equal(db_str, csv_str)
    except (ValueError, OverflowError):
        pass

    return db_str == csv_str


def process_table(table_info, conn):
    """Process a single table and return classification results."""
    table = table_info["table"]
    csv_file = table_info["csv_file"]
    raw_pk_cols = table_info["pk_cols"]
    shared_cols = table_info["shared_cols"]  # [(db_col, csv_col), ...]
    col_types = table_info.get("col_types", {})

    has_verified_build = "VerifiedBuild" in table_info.get("db_cols", [])

    # Use logical_pk_override if present (e.g. broadcast_text_duration)
    logical_pk_override = table_info.get("logical_pk_override")
    if logical_pk_override:
        logical_pk_cols = logical_pk_override
        # When using override PK, skip original PK cols during comparison
        # (e.g. ID is a meaningless row index in broadcast_text_duration)
        original_pk_cols = set(c for c in raw_pk_cols if c != "VerifiedBuild")
        skip_cols = set(logical_pk_cols) | original_pk_cols
    else:
        logical_pk_cols = [c for c in raw_pk_cols if c != "VerifiedBuild"]
        skip_cols = set(logical_pk_cols)

    full_pk_cols = raw_pk_cols

    result = {
        "table": table,
        "csv_file": csv_file,
        "pk_cols": full_pk_cols,
        "logical_pk_cols": logical_pk_cols,
        "total_rows": 0,
        "negative_build": [],
        "redundant": [],
        "override": [],
        "new": [],
        "errors": [],
    }

    if not shared_cols:
        result["errors"].append("No shared columns -- skipping")
        return result

    if not logical_pk_cols:
        result["errors"].append("No logical PK columns after stripping VerifiedBuild")
        return result

    # Map logical PK DB cols to CSV cols
    pk_db_to_csv = {}
    for db_col, csv_col in shared_cols:
        if db_col in logical_pk_cols:
            pk_db_to_csv[db_col] = csv_col
    pk_csv_cols = [pk_db_to_csv.get(pk, pk) for pk in logical_pk_cols]

    if not all(pk in pk_db_to_csv for pk in logical_pk_cols):
        missing = [pk for pk in logical_pk_cols if pk not in pk_db_to_csv]
        result["errors"].append(f"Logical PK columns not in shared set: {missing}")
        return result

    shared_csv_cols = [csv_col for _, csv_col in shared_cols]

    try:
        csv_data = load_csv_data(csv_file, pk_csv_cols, shared_csv_cols)
    except Exception as e:
        result["errors"].append(f"Failed to load CSV: {e}")
        return result

    # Build SELECT — need all shared DB cols + VerifiedBuild
    all_db_cols_needed = set(db_col for db_col, _ in shared_cols)
    # Also need logical PK cols that might not be in shared_cols
    for pk_col in logical_pk_cols:
        all_db_cols_needed.add(pk_col)
    if has_verified_build:
        all_db_cols_needed.add("VerifiedBuild")
    # Also need full PK cols for the result
    for pk_col in full_pk_cols:
        all_db_cols_needed.add(pk_col)

    db_col_list = ", ".join(f"`{c}`" for c in sorted(all_db_cols_needed))
    query = f"SELECT {db_col_list} FROM `{table}`"

    try:
        with conn.cursor() as cursor:
            cursor.execute(query)
            rows = cursor.fetchall()
    except Exception as e:
        result["errors"].append(f"MySQL query failed: {e}")
        return result

    result["total_rows"] = len(rows)

    for row in rows:
        full_pk_dict = {}
        for col in full_pk_cols:
            full_pk_dict[col] = row.get(col)

        if has_verified_build and row.get("VerifiedBuild") is not None:
            try:
                if int(row["VerifiedBuild"]) < 0:
                    result["negative_build"].append(full_pk_dict)
                    continue
            except (ValueError, TypeError):
                pass

        csv_pk = tuple(str(row[db_col]) for db_col in logical_pk_cols)
        csv_row = csv_data.get(csv_pk)

        if csv_row is None:
            result["new"].append(full_pk_dict)
            continue

        is_redundant = True
        diff_cols = []
        for db_col, csv_col in shared_cols:
            if db_col in skip_cols:
                continue
            db_val = row[db_col]
            csv_val = csv_row.get(csv_col)
            ct = col_types.get(db_col, "")
            if not compare_values(db_val, csv_val, csv_col, ct):
                is_redundant = False
                diff_cols.append({
                    "column": db_col,
                    "hotfix": str(db_val) if db_val is not None else None,
                    "dbc": str(csv_val) if csv_val is not None else None,
                    "col_type": ct,
                })

        if is_redundant:
            result["redundant"].append(full_pk_dict)
        else:
            result["override"].append({"pk": full_pk_dict, "diffs": diff_cols})

    return result


def main():
    parser = argparse.ArgumentParser(description="Hotfix redundancy differ (round 3)")
    parser.add_argument("--config", required=True, help="Path to table_info_r3.json")
    parser.add_argument("--tables", required=True, help="Comma-separated table names to process")
    args = parser.parse_args()

    with open(args.config) as f:
        all_tables = json.load(f)

    table_lookup = {t["table"]: t for t in all_tables}
    requested = [t.strip() for t in args.tables.split(",") if t.strip()]

    os.makedirs(RESULTS_DIR, exist_ok=True)

    conn = connect_mysql()
    try:
        for table_name in requested:
            if table_name not in table_lookup:
                print(f"SKIP: {table_name} not found in config", file=sys.stderr)
                continue

            info = table_lookup[table_name]
            print(f"Processing {table_name} ({info['row_count']:,} rows)...", flush=True)
            t0 = time.time()

            try:
                result = process_table(info, conn)
            except Exception as e:
                result = {
                    "table": table_name,
                    "total_rows": 0,
                    "errors": [str(e)],
                    "negative_build": [],
                    "redundant": [],
                    "override": [],
                    "new": [],
                }

            elapsed = time.time() - t0
            out_path = os.path.join(RESULTS_DIR, f"{table_name}.json")
            with open(out_path, "w") as f:
                json.dump(result, f, indent=2, default=str)

            n_r = len(result["redundant"])
            n_o = len(result["override"])
            n_n = len(result["new"])
            n_nb = len(result["negative_build"])
            n_e = len(result["errors"])
            total = result["total_rows"]
            pct = (n_r / total * 100) if total > 0 else 0
            print(
                f"  Done in {elapsed:.1f}s: {total} rows -- "
                f"{n_r} redundant ({pct:.1f}%), {n_o} override, "
                f"{n_n} new, {n_nb} neg_build, {n_e} errors",
                flush=True,
            )
    finally:
        conn.close()


if __name__ == "__main__":
    main()
