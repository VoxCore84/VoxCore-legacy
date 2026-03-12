#!/usr/bin/env python3
"""
BestiaryForge v1.0 -- Creature Intelligence Pipeline (Phase 1 MVP)

Parses BestiaryForge addon export data and generates production-ready SmartAI SQL.

Usage:
    python forge.py                    # Interactive paste mode
    python forge.py --file export.txt  # Read from file
    python forge.py --dry-run          # Preview without writing
"""
import sys
import os
import argparse
from datetime import datetime

try:
    import pymysql
    import pymysql.err
except ImportError:
    print("ERROR: pymysql is required. Install with: pip install pymysql")
    sys.exit(1)

# --- Configuration (override via environment variables) ---
DB_HOST = os.environ.get("BF_DB_HOST", "127.0.0.1")
DB_PORT = int(os.environ.get("BF_DB_PORT", "3306"))
DB_USER = os.environ.get("BF_DB_USER", "root")
DB_PASS = os.environ.get("BF_DB_PASS", "admin")
DB_WORLD = os.environ.get("BF_DB_WORLD", "world")
DB_HOTFIXES = os.environ.get("BF_DB_HOTFIXES", "hotfixes")

MIN_REPEAT_MS = 3000
MIN_INITIAL_MS = 2000
MAX_SPELLS_PER_CREATURE = 15
OUTPUT_FILE = "bestiary_forge_output.sql"

# DB2 SpellEffect.ImplicitTarget -> SmartAI target_type
TARGET_MAP = {
    1: 1,    # TARGET_UNIT_CASTER           -> SMART_TARGET_SELF
    6: 2,    # TARGET_UNIT_TARGET_ENEMY     -> SMART_TARGET_VICTIM
    15: 1,   # TARGET_UNIT_SRC_AREA_ENEMY   -> SMART_TARGET_SELF (AoE around caster)
    16: 2,   # TARGET_UNIT_DEST_AREA_ENEMY  -> SMART_TARGET_VICTIM
    22: 2,   # TARGET_UNIT_CONE_ENEMY       -> SMART_TARGET_VICTIM (frontal cone)
    25: 1,   # TARGET_UNIT_TARGET_ALLY      -> SMART_TARGET_SELF (heals)
    30: 1,   # TARGET_UNIT_SRC_AREA_ALLY    -> SMART_TARGET_SELF (AoE heal)
}


def parse_export(text):
    """Parse BFEXPORT:v1 format into structured creature data."""
    lines = text.strip().splitlines()
    if not lines or lines[0].strip() != "BFEXPORT:v1":
        raise ValueError("Invalid export format. Expected 'BFEXPORT:v1' header.")

    creatures = {}
    for line in lines[1:]:
        line = line.strip()
        if line.upper() == "END":
            break
        if not line:
            continue

        parts = line.split("|")
        if not parts:
            continue

        header = parts[0].split(":", 1)
        if len(header) < 2:
            continue
        try:
            entry = int(header[0])
        except ValueError:
            continue
        name = header[1]

        spells = []
        for spell_part in parts[1:]:
            fields = spell_part.split(":", 3)
            if len(fields) < 4:
                continue
            try:
                spells.append({
                    "spell_id": int(fields[0]),
                    "cast_count": int(fields[1]),
                    "school": int(fields[2]),
                    "name": fields[3],
                })
            except ValueError:
                continue

        if spells:
            # Merge if duplicate creature entry (e.g. concatenated exports)
            if entry in creatures:
                creatures[entry]["spells"].extend(spells)
            else:
                creatures[entry] = {"name": name, "spells": spells}

    return creatures


def connect_db():
    """Connect to MySQL with configured credentials."""
    return pymysql.connect(
        host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASS,
        charset="utf8mb4", cursorclass=pymysql.cursors.DictCursor,
    )


def check_existing_smartai(conn, entries):
    """Return set of creature entries that already have SmartAI scripts."""
    if not entries:
        return set()
    with conn.cursor() as cur:
        ph = ",".join(["%s"] * len(entries))
        cur.execute(
            f"SELECT DISTINCT entryorguid FROM {DB_WORLD}.smart_scripts "
            f"WHERE entryorguid IN ({ph}) AND source_type=0",
            list(entries),
        )
        return {row["entryorguid"] for row in cur.fetchall()}


def check_existing_scripts(conn, entries):
    """Return set of creature entries that have a C++ ScriptName."""
    if not entries:
        return set()
    with conn.cursor() as cur:
        ph = ",".join(["%s"] * len(entries))
        cur.execute(
            f"SELECT entry FROM {DB_WORLD}.creature_template "
            f"WHERE entry IN ({ph}) AND ScriptName != ''",
            list(entries),
        )
        return {row["entry"] for row in cur.fetchall()}


def validate_spells(conn, spell_ids):
    """Validate spell IDs against hotfixes.spell_name and world.serverside_spell."""
    if not spell_ids:
        return set()
    valid = set()
    ph = ",".join(["%s"] * len(spell_ids))
    with conn.cursor() as cur:
        try:
            cur.execute(
                f"SELECT ID FROM {DB_HOTFIXES}.spell_name WHERE ID IN ({ph})",
                list(spell_ids),
            )
            valid.update(row["ID"] for row in cur.fetchall())
        except pymysql.err.ProgrammingError as e:
            print(f"  WARNING: Could not query {DB_HOTFIXES}.spell_name: {e}")
            print("  Trusting all spell IDs without validation.")
            return set(spell_ids)
        try:
            cur.execute(
                f"SELECT Id FROM {DB_WORLD}.serverside_spell WHERE Id IN ({ph})",
                list(spell_ids),
            )
            valid.update(row["Id"] for row in cur.fetchall())
        except pymysql.err.ProgrammingError:
            pass  # Table may not exist on all setups
    return valid


def get_spell_targets(conn, spell_ids):
    """Infer SmartAI target_type from DB2 SpellEffect.ImplicitTarget."""
    if not spell_ids:
        return {}
    targets = {}
    try:
        with conn.cursor() as cur:
            # Discover the correct column name for ImplicitTarget[0]
            cur.execute(f"DESCRIBE {DB_HOTFIXES}.spell_effect")
            all_cols = {row["Field"] for row in cur.fetchall()}
            target_col = None
            for candidate in ("ImplicitTarget_0", "ImplicitTarget0", "ImplicitTarget[0]"):
                if candidate in all_cols:
                    target_col = candidate
                    break
            if not target_col:
                print("  (no ImplicitTarget column found, skipping target inference)")
                return targets

            ph = ",".join(["%s"] * len(spell_ids))
            quoted = f"`{target_col}`"
            cur.execute(
                f"SELECT SpellID, {quoted} AS target "
                f"FROM {DB_HOTFIXES}.spell_effect "
                f"WHERE SpellID IN ({ph}) AND EffectIndex=0",
                list(spell_ids),
            )
            for row in cur.fetchall():
                it = int(row.get("target") or 0)
                targets[row["SpellID"]] = TARGET_MAP.get(it, 2)
    except Exception as e:
        print(f"  (target inference skipped: {e})")
    return targets


def estimate_timer(cast_count, fight_duration=30):
    """Estimate SmartAI timer from observed cast count.

    cast_count <= 1 is treated as on-aggro (cast once per fight).
    This is a heuristic -- without WCL timing data, we assume a
    30-second fight duration for interval estimation.
    """
    if cast_count <= 1:
        return None  # On-aggro spell

    interval = fight_duration / cast_count
    repeat_min = max(MIN_REPEAT_MS, int(interval * 0.75 * 1000))
    repeat_max = max(MIN_REPEAT_MS + 2000, int(interval * 1.25 * 1000))
    initial_min = max(MIN_INITIAL_MS, int(interval * 0.5 * 1000))
    initial_max = max(MIN_INITIAL_MS + 2000, int(interval * 0.75 * 1000))
    return initial_min, initial_max, repeat_min, repeat_max


def escape_sql(s):
    """Escape a string for use in SQL string literals and comments."""
    return (s
            .replace("\\", "\\\\")
            .replace("'", "\\'")
            .replace("\n", " ")
            .replace("\r", ""))


def generate_sql(creatures, existing_smartai, existing_scripts, valid_spells, spell_targets):
    """Generate SmartAI SQL from parsed creature data."""
    lines = []
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Mandatory safety header (spec section 8c)
    lines.append("-- =====================================================================")
    lines.append("-- BestiaryForge Auto-Generated SmartAI")
    lines.append(f"-- Generated: {now}")
    lines.append(f"-- Creatures in input: {len(creatures)}")
    lines.append("--")
    lines.append("-- !! BACKUP YOUR WORLD DATABASE BEFORE APPLYING !!")
    lines.append("-- HeidiSQL: Right-click world DB > Export as SQL")
    lines.append("-- Command line: mysqldump -u root -p world > world_backup.sql")
    lines.append("--")
    lines.append("-- After applying, restart worldserver or run: .reload smart_scripts")
    lines.append("--")
    lines.append("-- This file is SAFE to apply multiple times (idempotent).")
    lines.append("-- It will NOT overwrite existing hand-crafted SmartAI.")
    lines.append("--")
    lines.append("-- NOTE: Timer intervals assume ~30s average fight duration.")
    lines.append("-- Adjust timers manually for bosses or quick-dying trash.")
    lines.append("--")
    lines.append("-- COMPATIBLE WITH: TrinityCore master branch (Midnight / 12.x)")
    lines.append("-- NOT COMPATIBLE WITH: AzerothCore, CMaNGOS, WOTLK 3.3.5")
    lines.append("-- =====================================================================\n")

    generated = 0
    skipped_smartai = 0
    skipped_script = 0
    skipped_no_spells = 0
    invalid_spell_count = 0

    for entry in sorted(creatures.keys()):
        creature = creatures[entry]
        name = creature["name"]

        if entry in existing_smartai:
            lines.append(f"-- SKIPPED: {escape_sql(name)} (entry {entry}) -- already has SmartAI")
            skipped_smartai += 1
            continue

        if entry in existing_scripts:
            lines.append(f"-- SKIPPED: {escape_sql(name)} (entry {entry}) -- has C++ ScriptName")
            skipped_script += 1
            continue

        # Filter to validated spells, sort by cast count, cap at max
        valid_creature_spells = sorted(
            [s for s in creature["spells"] if s["spell_id"] in valid_spells],
            key=lambda s: s["cast_count"],
            reverse=True,
        )[:MAX_SPELLS_PER_CREATURE]

        for s in creature["spells"]:
            if s["spell_id"] not in valid_spells:
                invalid_spell_count += 1

        if not valid_creature_spells:
            lines.append(f"-- SKIPPED: {escape_sql(name)} (entry {entry}) -- no valid spells")
            skipped_no_spells += 1
            continue

        cname = escape_sql(name)
        lines.append(f"\n-- === {cname} (entry {entry}) ===")
        lines.append(f"UPDATE `creature_template` SET `AIName`='SmartAI'")
        lines.append(f"WHERE `entry`={entry} AND `AIName`='' AND `ScriptName`='';")
        lines.append(f"DELETE FROM `smart_scripts` WHERE `entryorguid`={entry} AND `source_type`=0;")

        values = []
        for idx, spell in enumerate(valid_creature_spells):
            target_type = spell_targets.get(spell["spell_id"], 2)  # default: VICTIM
            timer = estimate_timer(spell["cast_count"])
            sname = escape_sql(spell["name"])

            if timer is None:
                # On-aggro: event_type=4 (SMART_EVENT_AGGRO)
                comment = f"{cname} - On Aggro - Cast {sname}"
                row = (
                    f"({entry}, 0, {idx}, 0, '',  "
                    f"4, 0, 100, 0,  "
                    f"0, 0, 0, 0, 0, '',  "
                    f"11, {spell['spell_id']}, 0, 0, 0, 0, 0, 0, '',  "
                    f"{target_type}, 0, 0, 0, 0, '',  "
                    f"0, 0, 0, 0, '{comment}')"
                )
            else:
                # Timed IC: event_type=0 (SMART_EVENT_UPDATE_IC)
                ep1, ep2, ep3, ep4 = timer
                comment = f"{cname} - IC {ep3 // 1000}-{ep4 // 1000}s - Cast {sname}"
                row = (
                    f"({entry}, 0, {idx}, 0, '',  "
                    f"0, 0, 100, 0,  "
                    f"{ep1}, {ep2}, {ep3}, {ep4}, 0, '',  "
                    f"11, {spell['spell_id']}, 0, 0, 0, 0, 0, 0, '',  "
                    f"{target_type}, 0, 0, 0, 0, '',  "
                    f"0, 0, 0, 0, '{comment}')"
                )
            values.append(row)

        lines.append(
            "INSERT INTO `smart_scripts` "
            "(`entryorguid`,`source_type`,`id`,`link`,`Difficulties`,\n"
            "  `event_type`,`event_phase_mask`,`event_chance`,`event_flags`,\n"
            "  `event_param1`,`event_param2`,`event_param3`,`event_param4`,"
            "`event_param5`,`event_param_string`,\n"
            "  `action_type`,`action_param1`,`action_param2`,`action_param3`,"
            "`action_param4`,`action_param5`,`action_param6`,`action_param7`,"
            "`action_param_string`,\n"
            "  `target_type`,`target_param1`,`target_param2`,`target_param3`,"
            "`target_param4`,`target_param_string`,\n"
            "  `target_x`,`target_y`,`target_z`,`target_o`,`comment`) VALUES"
        )
        lines.append(",\n".join(values) + ";")
        generated += 1

    # Summary
    lines.append(f"\n-- === SUMMARY ===")
    lines.append(f"-- Generated SmartAI for: {generated} creatures")
    lines.append(f"-- Skipped (existing SmartAI): {skipped_smartai}")
    lines.append(f"-- Skipped (C++ ScriptName): {skipped_script}")
    lines.append(f"-- Skipped (no valid spells): {skipped_no_spells}")
    lines.append(f"-- Invalid spell IDs filtered: {invalid_spell_count}")

    return "\n".join(lines), generated


def main():
    parser = argparse.ArgumentParser(description="BestiaryForge -- SmartAI Generator")
    parser.add_argument("--file", "-f", help="Read export from file instead of interactive paste")
    parser.add_argument("--dry-run", action="store_true", help="Preview output without writing file")
    parser.add_argument("--output", "-o", default=OUTPUT_FILE, help="Output SQL file path")
    args = parser.parse_args()

    print("=" * 60)
    print("  BestiaryForge v1.0 -- Creature Intelligence Pipeline")
    print("=" * 60)
    print()

    # --- Input ---
    if args.file:
        with open(args.file, "r", encoding="utf-8") as f:
            export_text = f.read()
        print(f"Read export from: {args.file}")
    else:
        print("Paste your BestiaryForge export below (from /bf export in-game).")
        print("The export starts with BFEXPORT:v1 and ends with END.")
        print("-" * 60)
        input_lines = []
        while True:
            try:
                line = input()
            except EOFError:
                break
            input_lines.append(line)
            if line.strip().upper() == "END":
                break
        export_text = "\n".join(input_lines)

    # --- Parse ---
    try:
        creatures = parse_export(export_text)
    except ValueError as e:
        print(f"\nERROR: {e}")
        if not args.file:
            input("\nPress Enter to exit...")
        sys.exit(1)

    if not creatures:
        print("\nNo creature data found in export.")
        if not args.file:
            input("\nPress Enter to exit...")
        sys.exit(1)

    total_spells = sum(len(c["spells"]) for c in creatures.values())
    print(f"\nParsed {len(creatures)} creatures with {total_spells} spell pairs.")

    # --- Database checks ---
    print("\nConnecting to MySQL...")
    try:
        conn = connect_db()
    except Exception as e:
        print(f"ERROR: Could not connect to MySQL: {e}")
        print("Set environment variables: BF_DB_HOST, BF_DB_PORT, BF_DB_USER, BF_DB_PASS")
        if not args.file:
            input("\nPress Enter to exit...")
        sys.exit(1)

    try:
        entries = set(creatures.keys())
        all_spell_ids = set()
        for c in creatures.values():
            for s in c["spells"]:
                all_spell_ids.add(s["spell_id"])

        print("Checking existing SmartAI scripts...")
        existing_smartai = check_existing_smartai(conn, entries)
        print(f"  {len(existing_smartai)} creatures already have SmartAI (will be skipped)")

        print("Checking existing C++ scripts...")
        existing_scripts = check_existing_scripts(conn, entries)
        print(f"  {len(existing_scripts)} creatures have C++ scripts (will be skipped)")

        print(f"Validating {len(all_spell_ids)} spell IDs...")
        valid_spells = validate_spells(conn, all_spell_ids)
        invalid_count = len(all_spell_ids) - len(valid_spells)
        print(f"  {len(valid_spells)} valid, {invalid_count} invalid")

        print("Inferring spell target types from DB2 SpellEffect...")
        spell_targets = get_spell_targets(conn, valid_spells)
        print(f"  {len(spell_targets)} spells with target data")
    finally:
        conn.close()

    # --- Generate ---
    print("\nGenerating SmartAI SQL...")
    sql, generated_count = generate_sql(
        creatures, existing_smartai, existing_scripts, valid_spells, spell_targets,
    )

    if args.dry_run:
        print("\n--- DRY RUN OUTPUT ---")
        print(sql)
        print(f"\n[Dry run] Would generate SmartAI for {generated_count} creatures.")
    else:
        output_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), args.output)
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(sql)
        print(f"\nOutput written to: {output_path}")
        print(f"Generated SmartAI for {generated_count} creatures.")
        print("\nNext steps:")
        print("  1. Review the SQL file")
        print("  2. Apply to your world database")
        print("  3. Restart worldserver or run: .reload smart_scripts")

    if not args.file:
        input("\nPress Enter to exit...")


if __name__ == "__main__":
    main()
