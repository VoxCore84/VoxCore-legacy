"""
Find duplicate creature and gameobject spawns in the world database.
Duplicates = same (id, map, position_x, position_y, position_z, PhaseId, PhaseGroup).
Keep the LOWEST guid per group, delete the rest.
Also clean up related tables (addon, spawn_group, game_event, creature_formations).
"""

import subprocess
import csv
import io
import sys
from collections import defaultdict

MYSQL = r"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
DB = "world"

def run_query(sql):
    """Run a MySQL query and return TSV output."""
    proc = subprocess.run(
        [MYSQL, "-u", "root", "-padmin", DB, "--batch", "-e", sql],
        capture_output=True, text=True, timeout=300
    )
    if proc.returncode != 0:
        print(f"MySQL error: {proc.stderr}", file=sys.stderr)
        sys.exit(1)
    return proc.stdout

def parse_tsv(output):
    """Parse MySQL TSV output into list of dicts."""
    reader = csv.DictReader(io.StringIO(output), delimiter='\t')
    return list(reader)

def find_duplicates(rows, guid_col):
    """
    Group rows by (id, map, position_x, position_y, position_z, PhaseId, PhaseGroup).
    For groups with >1 row, keep the lowest guid and return the rest as duplicates.
    """
    groups = defaultdict(list)
    for row in rows:
        key = (
            row['id'],
            row['map'],
            row['position_x'],
            row['position_y'],
            row['position_z'],
            row['PhaseId'],
            row['PhaseGroup'],
        )
        groups[key].append(int(row[guid_col]))

    dup_guids = []
    dup_group_count = 0
    for key, guids in groups.items():
        if len(guids) > 1:
            dup_group_count += 1
            guids.sort()
            # Keep lowest, delete the rest
            dup_guids.extend(guids[1:])

    return dup_guids, dup_group_count

def chunk_list(lst, size=500):
    """Split list into chunks."""
    for i in range(0, len(lst), size):
        yield lst[i:i+size]

def main():
    output_file = r"C:\Users\atayl\VoxCore\sql\exports\cleanup_duplicate_spawns.sql"

    # ── Export gameobject data ──
    print("Exporting gameobject spawns...")
    go_sql = "SELECT guid, id, map, position_x, position_y, position_z, PhaseId, PhaseGroup FROM gameobject"
    go_output = run_query(go_sql)
    go_rows = parse_tsv(go_output)
    print(f"  Total gameobject rows: {len(go_rows)}")

    # ── Export creature data ──
    print("Exporting creature spawns...")
    cr_sql = "SELECT guid, id, map, position_x, position_y, position_z, PhaseId, PhaseGroup FROM creature"
    cr_output = run_query(cr_sql)
    cr_rows = parse_tsv(cr_output)
    print(f"  Total creature rows: {len(cr_rows)}")

    # ── Find duplicates ──
    print("Finding gameobject duplicates...")
    go_dups, go_groups = find_duplicates(go_rows, 'guid')
    print(f"  Gameobject duplicate groups: {go_groups}, guids to delete: {len(go_dups)}")

    print("Finding creature duplicates...")
    cr_dups, cr_groups = find_duplicates(cr_rows, 'guid')
    print(f"  Creature duplicate groups: {cr_groups}, guids to delete: {len(cr_dups)}")

    # ── Generate SQL ──
    print(f"Writing SQL to {output_file}...")
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("-- Cleanup duplicate creature and gameobject spawns\n")
        f.write("-- Duplicates = same (id, map, position_x, position_y, position_z, PhaseId, PhaseGroup)\n")
        f.write("-- Keeps the LOWEST guid per group, deletes the rest\n")
        f.write(f"-- Generated: 2026-02-27\n")
        f.write(f"-- Gameobject: {go_groups} duplicate groups, {len(go_dups)} guids to delete\n")
        f.write(f"-- Creature: {cr_groups} duplicate groups, {len(cr_dups)} guids to delete\n\n")
        f.write("SET innodb_lock_wait_timeout=120;\n\n")

        # ── Gameobject deletes ──
        if go_dups:
            f.write(f"-- ========================================\n")
            f.write(f"-- GAMEOBJECT DUPLICATE CLEANUP ({len(go_dups)} guids)\n")
            f.write(f"-- ========================================\n\n")

            go_dups.sort()
            for chunk in chunk_list(go_dups, 500):
                guid_list = ','.join(str(g) for g in chunk)

                f.write(f"-- gameobject_addon for {len(chunk)} guids\n")
                f.write(f"DELETE FROM gameobject_addon WHERE guid IN ({guid_list});\n\n")

                f.write(f"-- spawn_group (spawnType=1 = gameobject) for {len(chunk)} guids\n")
                f.write(f"DELETE FROM spawn_group WHERE spawnType=1 AND spawnId IN ({guid_list});\n\n")

                f.write(f"-- game_event_gameobject for {len(chunk)} guids\n")
                f.write(f"DELETE FROM game_event_gameobject WHERE guid IN ({guid_list});\n\n")

                f.write(f"-- gameobject for {len(chunk)} guids\n")
                f.write(f"DELETE FROM gameobject WHERE guid IN ({guid_list});\n\n")

        # ── Creature deletes ──
        if cr_dups:
            f.write(f"-- ========================================\n")
            f.write(f"-- CREATURE DUPLICATE CLEANUP ({len(cr_dups)} guids)\n")
            f.write(f"-- ========================================\n\n")

            cr_dups.sort()
            for chunk in chunk_list(cr_dups, 500):
                guid_list = ','.join(str(g) for g in chunk)

                f.write(f"-- creature_addon for {len(chunk)} guids\n")
                f.write(f"DELETE FROM creature_addon WHERE guid IN ({guid_list});\n\n")

                f.write(f"-- spawn_group (spawnType=0 = creature) for {len(chunk)} guids\n")
                f.write(f"DELETE FROM spawn_group WHERE spawnType=0 AND spawnId IN ({guid_list});\n\n")

                f.write(f"-- game_event_creature for {len(chunk)} guids\n")
                f.write(f"DELETE FROM game_event_creature WHERE guid IN ({guid_list});\n\n")

                f.write(f"-- creature_formations for {len(chunk)} guids\n")
                f.write(f"DELETE FROM creature_formations WHERE leaderGUID IN ({guid_list}) OR memberGUID IN ({guid_list});\n\n")

                f.write(f"-- creature for {len(chunk)} guids\n")
                f.write(f"DELETE FROM creature WHERE guid IN ({guid_list});\n\n")

    print("Done!")
    print(f"\nSummary:")
    print(f"  Gameobject: {go_groups} duplicate groups, {len(go_dups)} rows to delete (from {len(go_rows)} total)")
    print(f"  Creature:   {cr_groups} duplicate groups, {len(cr_dups)} rows to delete (from {len(cr_rows)} total)")

if __name__ == '__main__':
    main()
