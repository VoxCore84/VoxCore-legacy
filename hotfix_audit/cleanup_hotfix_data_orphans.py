#!/usr/bin/env python3
"""
Cleanup orphaned hotfix_data entries.

After the R3 content table cleanup, many hotfix_data entries reference records
that no longer exist in their target tables. This script identifies and removes them.

Usage:
    python cleanup_hotfix_data_orphans.py [--dry-run] [--apply]
"""

import sys
import os
import argparse
from datetime import datetime

sys.path.insert(0, "C:/Users/atayl/VoxCore/wago")
from table_hashes import TABLE_HASHES

try:
    import pymysql
except ImportError:
    print("pip install pymysql")
    sys.exit(1)


# DB2 filename -> TC snake_case table name fixups
# (when the automatic CamelCase->snake_case conversion doesn't match)
DB2_TO_TC_FIXUPS = {
    "GameObjects": "gameobjects",  # TC uses plural
}

# Reverse: hash -> DB2 filename
HASH_TO_DB2 = {v: k for k, v in TABLE_HASHES.items()}


def db2_to_snake(name):
    """Convert DB2 CamelCase filename to TC snake_case table name."""
    if name in DB2_TO_TC_FIXUPS:
        return DB2_TO_TC_FIXUPS[name]
    # Standard CamelCase -> snake_case
    result = []
    for i, ch in enumerate(name):
        if ch.isupper() and i > 0:
            prev = name[i - 1]
            # Insert underscore before uppercase if preceded by lowercase,
            # or if preceded by uppercase followed by lowercase (e.g., "POI" -> "poi")
            if prev.islower() or prev.isdigit():
                result.append('_')
            elif i + 1 < len(name) and name[i + 1].islower():
                result.append('_')
        result.append(ch.lower())
    return ''.join(result)


def get_pk_column(cursor, table_name):
    """Get the primary key column(s) for a hotfix table. Returns the first PK column."""
    cursor.execute(
        "SELECT COLUMN_NAME FROM information_schema.KEY_COLUMN_USAGE "
        "WHERE TABLE_SCHEMA = 'hotfixes' AND TABLE_NAME = %s AND CONSTRAINT_NAME = 'PRIMARY' "
        "ORDER BY ORDINAL_POSITION LIMIT 1",
        (table_name,)
    )
    row = cursor.fetchone()
    return row[0] if row else "ID"


def main():
    parser = argparse.ArgumentParser(description="Cleanup orphaned hotfix_data entries")
    parser.add_argument("--dry-run", action="store_true", help="Only report, don't generate SQL")
    parser.add_argument("--apply", action="store_true", help="Apply cleanup directly to DB")
    args = parser.parse_args()

    conn = pymysql.connect(host="127.0.0.1", user="root", password="admin",
                           database="hotfixes", charset="utf8mb4")
    cursor = conn.cursor()

    # Get all distinct TableHash values and counts from hotfix_data
    cursor.execute(
        "SELECT TableHash, COUNT(*) AS cnt FROM hotfix_data GROUP BY TableHash ORDER BY cnt DESC"
    )
    hash_counts = cursor.fetchall()

    # Get list of actual tables in hotfixes DB
    cursor.execute(
        "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'hotfixes'"
    )
    existing_tables = {row[0] for row in cursor.fetchall()}

    total_orphans = 0
    total_kept = 0
    orphan_deletes = []  # (table_hash, count, table_name)
    unmapped = []

    print(f"Scanning {len(hash_counts)} table hashes in hotfix_data...")
    print(f"{'Table':<40} {'Entries':>8} {'Content':>8} {'Orphans':>8} {'Status'}")
    print("-" * 90)

    for table_hash, hd_count in hash_counts:
        db2_name = HASH_TO_DB2.get(table_hash)
        if not db2_name:
            unmapped.append((table_hash, hd_count))
            print(f"{'UNKNOWN 0x' + format(table_hash, '08X'):<40} {hd_count:>8} {'?':>8} {'?':>8} UNMAPPED HASH")
            continue

        tc_name = db2_to_snake(db2_name)

        if tc_name not in existing_tables:
            # Table doesn't exist in DB — all entries are orphans
            orphan_deletes.append((table_hash, hd_count, tc_name, hd_count))
            total_orphans += hd_count
            print(f"{tc_name:<40} {hd_count:>8} {'N/A':>8} {hd_count:>8} TABLE MISSING")
            continue

        # Get content row count
        pk_col = get_pk_column(cursor, tc_name)
        cursor.execute(f"SELECT COUNT(*) FROM `{tc_name}`")
        content_count = cursor.fetchone()[0]

        if content_count == 0:
            # Table exists but is empty — all entries are orphans
            orphan_deletes.append((table_hash, hd_count, tc_name, hd_count))
            total_orphans += hd_count
            print(f"{tc_name:<40} {hd_count:>8} {content_count:>8} {hd_count:>8} EMPTY TABLE")
            continue

        if content_count >= hd_count:
            # More content rows than hotfix_data entries — likely no orphans (or very few)
            # Still check for safety
            pass

        # Find orphaned RecordIds: in hotfix_data but not in content table
        # Use LEFT JOIN approach
        cursor.execute(f"""
            SELECT COUNT(*) FROM hotfix_data hd
            LEFT JOIN `{tc_name}` t ON hd.RecordId = t.`{pk_col}`
            WHERE hd.TableHash = %s AND t.`{pk_col}` IS NULL
        """, (table_hash,))
        orphan_count = cursor.fetchone()[0]

        if orphan_count > 0:
            orphan_deletes.append((table_hash, hd_count, tc_name, orphan_count))
            total_orphans += orphan_count
            total_kept += hd_count - orphan_count
            print(f"{tc_name:<40} {hd_count:>8} {content_count:>8} {orphan_count:>8} ORPHANS FOUND")
        else:
            total_kept += hd_count
            if hd_count >= 100:
                print(f"{tc_name:<40} {hd_count:>8} {content_count:>8} {0:>8} OK")

    print("-" * 90)
    print(f"Total hotfix_data entries: {sum(c for _, c in hash_counts):,}")
    print(f"Orphaned entries to remove: {total_orphans:,}")
    print(f"Entries to keep: {total_kept:,}")
    if unmapped:
        print(f"Unmapped hashes: {len(unmapped)} ({sum(c for _, c in unmapped):,} entries)")

    if args.dry_run or total_orphans == 0:
        cursor.close()
        conn.close()
        return

    # Generate SQL
    sql_lines = []
    sql_lines.append("-- HOTFIX_DATA ORPHAN CLEANUP")
    sql_lines.append(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    sql_lines.append(f"-- Orphaned entries: {total_orphans:,}")
    sql_lines.append(f"-- Kept entries: {total_kept:,}")
    sql_lines.append("")

    if args.apply:
        print(f"\nApplying cleanup of {total_orphans:,} orphaned entries...")

    for table_hash, hd_count, tc_name, orphan_count in sorted(orphan_deletes, key=lambda x: -x[3]):
        pk_col = get_pk_column(cursor, tc_name) if tc_name in existing_tables else "ID"

        if orphan_count == hd_count:
            # All entries for this hash are orphans — simple DELETE by hash
            sql = f"DELETE FROM `hotfix_data` WHERE `TableHash` = {table_hash};"
            sql_lines.append(f"-- {tc_name}: {orphan_count:,} orphans (all entries)")
            sql_lines.append(sql)

            if args.apply:
                cursor.execute(f"DELETE FROM `hotfix_data` WHERE `TableHash` = %s", (table_hash,))
                print(f"  Deleted {cursor.rowcount:,} from {tc_name}")
        else:
            # Partial — need to identify specific RecordIds
            sql_lines.append(f"-- {tc_name}: {orphan_count:,} orphans of {hd_count:,} entries")

            if args.apply:
                cursor.execute(f"""
                    DELETE hd FROM `hotfix_data` hd
                    LEFT JOIN `{tc_name}` t ON hd.RecordId = t.`{pk_col}`
                    WHERE hd.TableHash = %s AND t.`{pk_col}` IS NULL
                """, (table_hash,))
                print(f"  Deleted {cursor.rowcount:,} from {tc_name}")
            else:
                sql_lines.append(
                    f"DELETE hd FROM `hotfix_data` hd "
                    f"LEFT JOIN `{tc_name}` t ON hd.RecordId = t.`{pk_col}` "
                    f"WHERE hd.TableHash = {table_hash} AND t.`{pk_col}` IS NULL;"
                )

        sql_lines.append("")

    if args.apply:
        conn.commit()
        cursor.execute("SELECT COUNT(*) FROM hotfix_data")
        remaining = cursor.fetchone()[0]
        print(f"\nDone. hotfix_data: {remaining:,} entries remaining")
    else:
        out_path = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "hotfix_data_orphan_cleanup.sql")
        with open(out_path, "w") as f:
            f.write("\n".join(sql_lines))
        print(f"\nSQL written to: {out_path}")

    cursor.close()
    conn.close()


if __name__ == "__main__":
    main()
