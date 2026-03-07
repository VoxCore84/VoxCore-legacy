"""
Extract NEW smart_scripts rows from LoreWalkerTDB that don't exist in our world DB.
Filters: source_type IN (0,1,9,12) only. Skips type 5 (quest boilerplate).
For type 9 (actionlist), only keeps rows referenced by creature/GO scripts we have or are importing.

Column order (non-standard action_param order):
entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask,
event_chance, event_flags, event_param1-5, event_param_string,
action_type, action_param1-5, action_param7, action_param_string, action_param6,
target_type, target_param1-4, target_param_string, target_x-z, target_o, comment
"""

import subprocess
import sys
import os

LW_DUMP = r"C:\Users\atayl\OneDrive\Desktop\Excluded\LoreWalkerTDB\LoreWalkerTDB\world.sql"
OUTPUT = r"C:\Users\atayl\VoxCore\sql\exports\lw_smartai_remaining.sql"
MYSQL = r"C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe"
BATCH_SIZE = 500

COLUMNS = (
    "entryorguid, source_type, id, link, Difficulties, event_type, event_phase_mask, "
    "event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, "
    "event_param5, event_param_string, action_type, action_param1, action_param2, "
    "action_param3, action_param4, action_param5, action_param7, action_param_string, "
    "action_param6, target_type, target_param1, target_param2, target_param3, "
    "target_param4, target_param_string, target_x, target_y, target_z, target_o, comment"
)

# Action types that reference timed actionlists
ACTIONLIST_ACTION_TYPES = {80, 87, 88}


def get_existing_pks():
    """Export all (entryorguid, source_type, id, link) from our world DB."""
    print("Step 1: Exporting existing PKs from world DB...")
    cmd = [
        MYSQL, "-u", "root", "-padmin", "world", "-N", "-B",
        "-e", "SELECT entryorguid, source_type, id, link FROM smart_scripts"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    if result.returncode != 0:
        print(f"MySQL error: {result.stderr}", file=sys.stderr)
        sys.exit(1)

    pks = set()
    for line in result.stdout.strip().split('\n'):
        if not line.strip():
            continue
        parts = line.split('\t')
        pks.add((int(parts[0]), int(parts[1]), int(parts[2]), int(parts[3])))

    print(f"  Found {len(pks):,} existing PK tuples in world DB")
    return pks


def parse_values_from_line(line):
    """
    Parse a mysqldump INSERT line into individual row strings (without outer parens).
    Returns list of raw row content strings between ( and ).
    """
    idx = line.find('VALUES ')
    if idx < 0:
        return []
    data = line[idx + 7:].rstrip().rstrip(';')

    rows = []
    i = 0
    n = len(data)

    while i < n:
        # Skip whitespace/commas between rows
        while i < n and data[i] in (' ', ',', '\n', '\r'):
            i += 1
        if i >= n:
            break
        if data[i] != '(':
            break

        # Find matching closing paren, respecting strings
        i += 1  # skip opening (
        start = i
        in_string = False
        escape_next = False

        while i < n:
            c = data[i]
            if escape_next:
                escape_next = False
                i += 1
                continue
            if c == '\\':
                escape_next = True
                i += 1
                continue
            if c == "'":
                in_string = not in_string
                i += 1
                continue
            if not in_string:
                if c == ')':
                    rows.append(data[start:i])
                    i += 1
                    break
            i += 1

    return rows


def split_row_fields(row_str):
    """
    Split a row string like "val1,val2,'str,val',NULL,..." into individual field strings.
    Respects quoted strings with escaped chars.
    """
    fields = []
    i = 0
    n = len(row_str)

    while i < n:
        # Skip leading whitespace
        while i < n and row_str[i] == ' ':
            i += 1
        if i >= n:
            break

        if row_str[i] == "'":
            # Quoted string field — include quotes
            start = i
            i += 1  # skip opening quote
            while i < n:
                if row_str[i] == '\\':
                    i += 2
                    continue
                if row_str[i] == "'":
                    i += 1
                    break
                i += 1
            fields.append(row_str[start:i])
            # Skip comma
            if i < n and row_str[i] == ',':
                i += 1
        else:
            # Unquoted field (number or NULL)
            start = i
            while i < n and row_str[i] != ',':
                i += 1
            fields.append(row_str[start:i])
            if i < n and row_str[i] == ',':
                i += 1

    return fields


def extract_pk(fields):
    """Extract (entryorguid, source_type, id, link) from field list."""
    try:
        entryorguid = int(fields[0])
        source_type = int(fields[1])
        id_ = int(fields[2])
        link = int(fields[3])
        return (entryorguid, source_type, id_, link)
    except (ValueError, IndexError):
        return None


def extract_action_type(fields):
    """Get action_type (field index 15)."""
    try:
        return int(fields[15])
    except (ValueError, IndexError):
        return None


def get_actionlist_refs_from_fields(fields):
    """
    For action types 80/87/88, extract the actionlist IDs referenced.
    Column layout (0-indexed):
      15=action_type, 16=action_param1, 17=action_param2, 18=action_param3,
      19=action_param4, 20=action_param5, 21=action_param7, 22=action_param_string,
      23=action_param6
    - 80 (CALL_TIMED_ACTIONLIST): param1 is the actionlist ID
    - 87 (RANDOM_TIMED_ACTIONLIST): params 1-6 are actionlist IDs (0=unused)
    - 88 (RANDOM_RANGE_TIMED_ACTIONLIST): param1=min, param2=max (range)
    """
    atype = extract_action_type(fields)
    ids = set()

    if atype == 80:
        # Call timed actionlist: param1 only
        try:
            val = int(fields[16])
            if val != 0:
                ids.add(val)
        except (ValueError, IndexError):
            pass
    elif atype == 87:
        # Random timed actionlist: params 1-6
        # param1=idx16, param2=idx17, param3=idx18, param4=idx19, param5=idx20, param6=idx23
        for idx in [16, 17, 18, 19, 20, 23]:
            try:
                val = int(fields[idx])
                if val != 0:
                    ids.add(val)
            except (ValueError, IndexError):
                pass
    elif atype == 88:
        # Random range: param1=min, param2=max
        try:
            min_id = int(fields[16])
            max_id = int(fields[17])
            if min_id > 0 and max_id >= min_id and (max_id - min_id) < 1000:
                for v in range(min_id, max_id + 1):
                    ids.add(v)
        except (ValueError, IndexError):
            pass

    return ids


def get_existing_actionlist_refs():
    """Query our DB for actionlist IDs referenced by existing creature/GO/scene scripts."""
    print("  Querying existing actionlist references from world DB...")
    cmd = [
        MYSQL, "-u", "root", "-padmin", "world", "-N", "-B",
        "-e",
        "SELECT action_type, action_param1, action_param2, action_param3, "
        "action_param4, action_param5, action_param6 "
        "FROM smart_scripts WHERE source_type IN (0,1,12) AND action_type IN (80,87,88)"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    refs = set()

    if result.returncode == 0 and result.stdout.strip():
        for line in result.stdout.strip().split('\n'):
            parts = line.split('\t')
            atype = int(parts[0])
            if atype == 80:
                v = int(parts[1])
                if v != 0:
                    refs.add(v)
            elif atype == 87:
                for p in parts[1:7]:
                    v = int(p)
                    if v != 0:
                        refs.add(v)
            elif atype == 88:
                min_id = int(parts[1])
                max_id = int(parts[2])
                if min_id > 0 and max_id >= min_id and (max_id - min_id) < 1000:
                    for v in range(min_id, max_id + 1):
                        refs.add(v)

    print(f"  Found {len(refs):,} actionlist IDs referenced by existing DB scripts")
    return refs


def main():
    existing_pks = get_existing_pks()

    print(f"\nStep 2: Parsing LW dump for smart_scripts rows...")
    sys.stdout.flush()

    # First pass: collect all LW rows by source_type
    lw_rows = {0: [], 1: [], 9: [], 12: []}
    wanted_types = {0, 1, 9, 12}
    total_lw = 0
    skipped_type5 = 0
    skipped_other = 0
    insert_count = 0

    with open(LW_DUMP, 'r', encoding='utf-8', errors='replace') as f:
        for line in f:
            if not line.startswith("INSERT INTO `smart_scripts`"):
                continue

            insert_count += 1
            if insert_count % 20 == 0:
                print(f"  Processing INSERT #{insert_count}...", flush=True)

            raw_rows = parse_values_from_line(line)
            for row_str in raw_rows:
                total_lw += 1
                fields = split_row_fields(row_str)
                pk = extract_pk(fields)
                if pk is None:
                    continue

                source_type = pk[1]
                if source_type == 5:
                    skipped_type5 += 1
                    continue
                if source_type not in wanted_types:
                    skipped_other += 1
                    continue

                lw_rows[source_type].append((pk, row_str, fields))

    print(f"  INSERT statements processed: {insert_count}")
    print(f"  Total LW smart_scripts rows parsed: {total_lw:,}")
    print(f"  Skipped type 5 (quest): {skipped_type5:,}")
    print(f"  Skipped other types: {skipped_other:,}")
    for st in sorted(lw_rows.keys()):
        print(f"  Type {st}: {len(lw_rows[st]):,} rows in LW")

    # Filter out rows already in our DB
    print(f"\nStep 3: Filtering out existing PKs...")
    new_rows = {0: [], 1: [], 9: [], 12: []}
    dup_counts = {0: 0, 1: 0, 9: 0, 12: 0}

    for source_type in [0, 1, 9, 12]:
        for pk, row_str, fields in lw_rows[source_type]:
            if pk in existing_pks:
                dup_counts[source_type] += 1
            else:
                new_rows[source_type].append((pk, row_str, fields))

    total_dups = sum(dup_counts.values())
    print(f"  Duplicates filtered: {total_dups:,}")
    for st in [0, 1, 9, 12]:
        print(f"  Type {st}: {len(new_rows[st]):,} new, {dup_counts[st]:,} dups")

    # Resolve actionlist references
    print(f"\nStep 4: Resolving actionlist references...")
    referenced_actionlists = get_existing_actionlist_refs()

    # Add refs from new creature/GO/scene rows we're importing
    new_refs = set()
    for source_type in [0, 1, 12]:
        for pk, row_str, fields in new_rows[source_type]:
            atype = extract_action_type(fields)
            if atype in ACTIONLIST_ACTION_TYPES:
                ids = get_actionlist_refs_from_fields(fields)
                new_refs.update(ids)

    print(f"  Actionlists referenced by new scripts: {len(new_refs):,}")
    referenced_actionlists.update(new_refs)
    print(f"  Total referenced actionlists: {len(referenced_actionlists):,}")

    # Filter type 9 rows — only keep referenced ones
    filtered_type9 = []
    orphan_count = 0
    for pk, row_str, fields in new_rows[9]:
        actionlist_id = pk[0]  # entryorguid IS the actionlist ID for type 9
        if actionlist_id in referenced_actionlists:
            filtered_type9.append((pk, row_str, fields))
        else:
            orphan_count += 1

    new_rows[9] = filtered_type9
    print(f"  Type 9 new (referenced): {len(new_rows[9]):,}")
    print(f"  Type 9 orphan actionlists skipped: {orphan_count:,}")

    # Write output SQL
    print(f"\nStep 5: Writing output SQL...")
    total_new = sum(len(new_rows[st]) for st in [0, 1, 9, 12])

    if total_new == 0:
        print("  No new rows to write!")
        return

    with open(OUTPUT, 'w', encoding='utf-8') as out:
        out.write("-- LoreWalkerTDB SmartAI import: new rows not in world DB\n")
        out.write("-- source_type: 0=creature, 1=gameobject, 9=actionlist, 12=scene\n")
        out.write("-- Skipped: type 5 (quest boilerplate), orphan actionlists\n")
        out.write(f"-- Total LW rows: {total_lw:,} -> New rows: {total_new:,}\n")
        out.write(f"-- Generated: 2026-02-27\n\n")

        for st, label in [(0, "creature"), (1, "gameobject"), (9, "actionlist"), (12, "scene")]:
            rows = new_rows[st]
            if not rows:
                continue

            out.write(f"\n-- source_type={st} ({label}): {len(rows):,} new rows\n")

            for batch_start in range(0, len(rows), BATCH_SIZE):
                batch = rows[batch_start:batch_start + BATCH_SIZE]
                out.write(f"INSERT IGNORE INTO `smart_scripts` ({COLUMNS}) VALUES\n")
                row_strs = []
                for pk, row_str, fields in batch:
                    row_strs.append(f"({row_str})")
                out.write(",\n".join(row_strs))
                out.write(";\n\n")

    file_size = os.path.getsize(OUTPUT)
    print(f"\nDone! Output: {OUTPUT}")
    print(f"  File size: {file_size:,} bytes ({file_size / 1024 / 1024:.2f} MB)")
    print(f"\nSummary of new rows:")
    for st, label in [(0, "creature"), (1, "gameobject"), (9, "actionlist"), (12, "scene")]:
        count = len(new_rows[st])
        print(f"  source_type={st} ({label}): {count:,}")
    print(f"  TOTAL: {total_new:,}")


if __name__ == "__main__":
    main()
