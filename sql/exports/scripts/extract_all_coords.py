"""
Extract ALL spawn coordinates from raw Wowhead NPC JSON files.

Reads: C:/Users/atayl/VoxCore/wago/wowhead_data/npc/raw/*.json (excluding *_parsed.json)
Writes:
  - npc_all_coords.csv: id,zone_id,floor_id,coord_x,coord_y
  - npc_spawn_summary.csv: id,zone_id,total_coords

Optimized for 218K+ files: uses os.scandir, minimal JSON parsing, batch CSV writes.
"""

import csv
import json
import os
import sys
import time
from collections import defaultdict

RAW_DIR = "C:/Users/atayl/VoxCore/wago/wowhead_data/npc/raw"
OUT_DIR = "C:/Users/atayl/VoxCore/wago/wowhead_data/npc"
COORDS_CSV = os.path.join(OUT_DIR, "npc_all_coords.csv")
SUMMARY_CSV = os.path.join(OUT_DIR, "npc_spawn_summary.csv")

BATCH_SIZE = 5000  # flush CSV rows in batches


def extract_all():
    start = time.time()

    # Collect all raw JSON filenames (exclude *_parsed.json)
    print("Scanning directory...")
    files = []
    for entry in os.scandir(RAW_DIR):
        if entry.is_file() and entry.name.endswith(".json") and not entry.name.endswith("_parsed.json"):
            # Extract NPC ID from filename (e.g. "12345.json" -> 12345)
            try:
                npc_id = int(entry.name[:-5])  # strip .json
                files.append((npc_id, entry.path))
            except ValueError:
                pass

    files.sort(key=lambda x: x[0])
    total_files = len(files)
    print(f"Found {total_files} raw JSON files")

    # Stats
    npcs_with_coords = 0
    total_coord_points = 0
    zone_counts = defaultdict(int)  # zone_id -> coord count
    npc_coord_counts = []  # (npc_id, zone_id, count) for top-N report
    errors = 0

    # Open both CSVs
    coord_file = open(COORDS_CSV, "w", newline="", encoding="utf-8")
    summary_file = open(SUMMARY_CSV, "w", newline="", encoding="utf-8")
    coord_writer = csv.writer(coord_file)
    summary_writer = csv.writer(summary_file)

    coord_writer.writerow(["id", "zone_id", "floor_id", "coord_x", "coord_y"])
    summary_writer.writerow(["id", "zone_id", "total_coords"])

    coord_batch = []

    for i, (npc_id, filepath) in enumerate(files):
        if i > 0 and i % 50000 == 0:
            elapsed = time.time() - start
            rate = i / elapsed
            eta = (total_files - i) / rate
            print(f"  {i}/{total_files} ({i*100//total_files}%) - {rate:.0f} files/s - ETA {eta:.0f}s")

        try:
            with open(filepath, "r", encoding="utf-8") as f:
                data = json.load(f)
        except (json.JSONDecodeError, UnicodeDecodeError, OSError) as e:
            errors += 1
            continue

        map_data = data.get("map")
        if not isinstance(map_data, dict):
            continue

        coords_data = map_data.get("coords")
        zone_id = map_data.get("zone")
        if not coords_data or zone_id is None:
            continue

        npc_total = 0
        for floor_id, points in coords_data.items():
            if not isinstance(points, list):
                continue
            for point in points:
                if isinstance(point, list) and len(point) >= 2:
                    coord_batch.append((npc_id, zone_id, floor_id, point[0], point[1]))
                    npc_total += 1

        if npc_total > 0:
            npcs_with_coords += 1
            total_coord_points += npc_total
            zone_counts[zone_id] += npc_total
            npc_coord_counts.append((npc_id, zone_id, npc_total))
            summary_writer.writerow([npc_id, zone_id, npc_total])

        # Flush coord batch
        if len(coord_batch) >= BATCH_SIZE:
            coord_writer.writerows(coord_batch)
            coord_batch.clear()

    # Final flush
    if coord_batch:
        coord_writer.writerows(coord_batch)

    coord_file.close()
    summary_file.close()

    elapsed = time.time() - start

    # --- Report ---
    print(f"\n{'='*60}")
    print(f"EXTRACTION COMPLETE in {elapsed:.1f}s")
    print(f"{'='*60}")
    print(f"Total raw JSON files:     {total_files:>10,}")
    print(f"NPCs with coordinates:    {npcs_with_coords:>10,}")
    print(f"Total coordinate points:  {total_coord_points:>10,}")
    print(f"Parse errors:             {errors:>10,}")
    print(f"Processing rate:          {total_files/elapsed:>10,.0f} files/s")
    print()

    # Top 20 zones by spawn count
    print("TOP 20 ZONES BY SPAWN COUNT:")
    print(f"  {'Zone ID':>8}  {'Coords':>10}  {'NPCs':>8}")
    print(f"  {'-------':>8}  {'------':>10}  {'----':>8}")

    # Count NPCs per zone
    zone_npc_count = defaultdict(int)
    for npc_id, zone_id, count in npc_coord_counts:
        zone_npc_count[zone_id] += 1

    sorted_zones = sorted(zone_counts.items(), key=lambda x: x[1], reverse=True)[:20]
    for zone_id, coord_count in sorted_zones:
        print(f"  {zone_id:>8}  {coord_count:>10,}  {zone_npc_count[zone_id]:>8,}")
    print()

    # NPCs with most spawn points
    print("TOP 30 NPCs BY SPAWN POINT COUNT:")
    print(f"  {'NPC ID':>10}  {'Zone':>8}  {'Coords':>8}")
    print(f"  {'------':>10}  {'----':>8}  {'------':>8}")
    npc_coord_counts.sort(key=lambda x: x[2], reverse=True)
    for npc_id, zone_id, count in npc_coord_counts[:30]:
        print(f"  {npc_id:>10}  {zone_id:>8}  {count:>8,}")
    print()

    print(f"Output files:")
    print(f"  Coordinates: {COORDS_CSV}")
    print(f"  Summary:     {SUMMARY_CSV}")


if __name__ == "__main__":
    extract_all()
