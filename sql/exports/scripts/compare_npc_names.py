#!/usr/bin/env python3
"""
Cross-reference Wowhead NPC names against world.creature_template to find mismatches.

Reads:
  - Wowhead CSV: C:/Users/atayl/VoxCore/wago/wowhead_data/npc/npc_export.csv
  - MySQL: world.creature_template (entry, name) WHERE entry < 500000

Outputs a report of name mismatches, excluding trivial whitespace/encoding differences.
"""

import csv
import subprocess
import sys
import re
import unicodedata
from collections import Counter

# ── 1. Load Wowhead CSV ─────────────────────────────────────────────────────

CSV_PATH = "C:/Users/atayl/VoxCore/wago/wowhead_data/npc/npc_export.csv"

print("Loading Wowhead CSV...")
wowhead = {}
with open(CSV_PATH, "r", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        try:
            npc_id = int(row["id"])
            name = row["name"].strip()
            wowhead[npc_id] = name
        except (ValueError, KeyError):
            continue

print(f"  Loaded {len(wowhead):,} Wowhead entries")

# ── 2. Load DB names ────────────────────────────────────────────────────────

MYSQL = "C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe"

print("Loading creature_template from MySQL...")
result = subprocess.run(
    [MYSQL, "-u", "root", "-padmin", "-N", "-B", "--default-character-set=utf8mb4", "-e",
     "SELECT entry, name FROM world.creature_template WHERE entry < 500000;"],
    capture_output=True, encoding="utf-8", errors="replace"
)

if result.returncode != 0:
    print(f"MySQL error: {result.stderr}", file=sys.stderr)
    sys.exit(1)

db_names = {}
for line in result.stdout.strip().split("\n"):
    if not line:
        continue
    parts = line.split("\t", 1)
    if len(parts) == 2:
        try:
            entry = int(parts[0])
            name = parts[1].strip()
            db_names[entry] = name
        except ValueError:
            continue

print(f"  Loaded {len(db_names):,} DB entries")

# ── 3. Normalization helpers ────────────────────────────────────────────────

def normalize_whitespace(s):
    """Collapse all whitespace to single spaces, strip."""
    return re.sub(r'\s+', ' ', s).strip()

def decode_html_entities(s):
    """Decode common HTML entities."""
    import html
    return html.unescape(s)

def normalize_encoding(s):
    """Normalize unicode to NFC form and strip zero-width chars."""
    s = unicodedata.normalize("NFC", s)
    # Remove zero-width chars
    s = re.sub(r'[\u200b\u200c\u200d\ufeff\u00ad]', '', s)
    return s

def is_trivial_difference(a, b):
    """Return True if difference is only whitespace, encoding, or HTML entities."""
    na = normalize_encoding(decode_html_entities(normalize_whitespace(a)))
    nb = normalize_encoding(decode_html_entities(normalize_whitespace(b)))
    return na == nb

# ── 4. Compare ──────────────────────────────────────────────────────────────

print("\nComparing names...")

common_ids = set(wowhead.keys()) & set(db_names.keys())
wowhead_only = set(wowhead.keys()) - set(db_names.keys())
db_only = set(db_names.keys()) - set(wowhead.keys())

print(f"  Common IDs: {len(common_ids):,}")
print(f"  Wowhead-only IDs: {len(wowhead_only):,}")
print(f"  DB-only IDs: {len(db_only):,}")

mismatches = []
trivial_count = 0

for npc_id in sorted(common_ids):
    wh_name = wowhead[npc_id]
    db_name = db_names[npc_id]

    if wh_name == db_name:
        continue  # exact match

    if is_trivial_difference(wh_name, db_name):
        trivial_count += 1
        continue

    mismatches.append((npc_id, wh_name, db_name))

print(f"\n{'='*100}")
print(f"RESULTS")
print(f"{'='*100}")
print(f"Total common entries compared: {len(common_ids):,}")
print(f"Exact matches:                 {len(common_ids) - len(mismatches) - trivial_count:,}")
print(f"Trivial differences (skipped): {trivial_count:,}")
print(f"Real name mismatches:          {len(mismatches):,}")

# ── 5. Classify mismatch patterns ──────────────────────────────────────────

patterns = Counter()

for npc_id, wh_name, db_name in mismatches:
    wh_lower = wh_name.lower()
    db_lower = db_name.lower()

    if wh_lower == db_lower:
        patterns["case_only"] += 1
    elif wh_name.startswith("[UNUSED]") or db_name.startswith("[UNUSED]"):
        patterns["unused_tag"] += 1
    elif wh_name.startswith("[DNT]") or db_name.startswith("[DNT]"):
        patterns["dnt_tag"] += 1
    elif wh_name.startswith("[PH]") or db_name.startswith("[PH]"):
        patterns["placeholder_tag"] += 1
    elif "'" in wh_name or "'" in db_name or "'" in wh_name or "'" in db_name:
        # Check if difference is just apostrophe style
        wh_apos = wh_name.replace("\u2019", "'").replace("\u2018", "'")
        db_apos = db_name.replace("\u2019", "'").replace("\u2018", "'")
        if wh_apos == db_apos:
            patterns["apostrophe_style"] += 1
        else:
            patterns["other"] += 1
    elif db_name == "" or wh_name == "":
        patterns["one_side_empty"] += 1
    elif set(wh_name) - set(db_name) or set(db_name) - set(wh_name):
        # Check for accent/diacritical differences
        wh_ascii = unicodedata.normalize("NFKD", wh_name).encode("ascii", "ignore").decode()
        db_ascii = unicodedata.normalize("NFKD", db_name).encode("ascii", "ignore").decode()
        if wh_ascii == db_ascii:
            patterns["diacritical_diff"] += 1
        else:
            patterns["other"] += 1
    else:
        patterns["other"] += 1

print(f"\n{'='*100}")
print(f"PATTERN BREAKDOWN")
print(f"{'='*100}")
for pattern, count in patterns.most_common():
    label = {
        "case_only": "Case difference only",
        "unused_tag": "[UNUSED] tag mismatch",
        "dnt_tag": "[DNT] tag mismatch",
        "placeholder_tag": "[PH] placeholder mismatch",
        "apostrophe_style": "Apostrophe style (' vs \u2019)",
        "one_side_empty": "One side has empty name",
        "diacritical_diff": "Diacritical/accent difference",
        "other": "Other (substantive difference)",
    }.get(pattern, pattern)
    print(f"  {label}: {count:,}")

# ── 6. Print first 50 mismatches ────────────────────────────────────────────

print(f"\n{'='*100}")
print(f"FIRST 50 MISMATCHES (sorted by ID)")
print(f"{'='*100}")
print(f"{'ID':>8}  {'Wowhead Name':<50}  {'DB Name':<50}  Pattern")
print(f"{'-'*8}  {'-'*50}  {'-'*50}  {'-'*20}")

for i, (npc_id, wh_name, db_name) in enumerate(mismatches[:50]):
    wh_lower = wh_name.lower()
    db_lower = db_name.lower()

    if wh_lower == db_lower:
        pat = "CASE"
    elif wh_name.startswith("[UNUSED]") or db_name.startswith("[UNUSED]"):
        pat = "UNUSED"
    elif wh_name.startswith("[DNT]") or db_name.startswith("[DNT]"):
        pat = "DNT"
    elif wh_name.startswith("[PH]") or db_name.startswith("[PH]"):
        pat = "PH"
    elif db_name == "" or wh_name == "":
        pat = "EMPTY"
    else:
        wh_apos = wh_name.replace("\u2019", "'").replace("\u2018", "'")
        db_apos = db_name.replace("\u2019", "'").replace("\u2018", "'")
        if wh_apos == db_apos:
            pat = "APOSTROPHE"
        else:
            pat = "OTHER"

    print(f"{npc_id:>8}  {wh_name:<50}  {db_name:<50}  {pat}")

# ── 7. Show "OTHER" (substantive) mismatches separately ─────────────────────

substantive_list = []
for npc_id, wh_name, db_name in mismatches:
    wh_lower = wh_name.lower()
    db_lower = db_name.lower()
    if wh_lower == db_lower:
        continue
    if wh_name.startswith("[UNUSED]") or db_name.startswith("[UNUSED]"):
        continue
    if wh_name.startswith("[DNT]") or db_name.startswith("[DNT]"):
        continue
    if wh_name.startswith("[PH]") or db_name.startswith("[PH]"):
        continue
    if db_name == "" or wh_name == "":
        continue
    wh_apos = wh_name.replace("\u2019", "'").replace("\u2018", "'")
    db_apos = db_name.replace("\u2019", "'").replace("\u2018", "'")
    if wh_apos == db_apos:
        continue
    substantive_list.append((npc_id, wh_name, db_name))

print(f"\n{'='*100}")
print(f"SUBSTANTIVE MISMATCHES (first 50 — not just case/tag/apostrophe)")
print(f"{'='*100}")
print(f"{'ID':>8}  {'Wowhead Name':<50}  {'DB Name':<50}")
print(f"{'-'*8}  {'-'*50}  {'-'*50}")

for npc_id, wh_name, db_name in substantive_list[:50]:
    print(f"{npc_id:>8}  {wh_name:<50}  {db_name:<50}")

print(f"\nTotal substantive mismatches: {len(substantive_list):,}")

# ── 8. Generate SQL fix for substantive mismatches ──────────────────────────

SQL_OUT = "C:/Users/atayl/VoxCore/sql/exports/scripts/npc_name_fixes.sql"

print(f"\nWriting SQL fixes to: {SQL_OUT}")
with open(SQL_OUT, "w", encoding="utf-8") as f:
    f.write("-- NPC name fixes: Wowhead -> DB corrections\n")
    f.write("-- Generated by compare_npc_names.py\n")
    f.write(f"-- Total fixes: {len(substantive_list)}\n\n")

    for npc_id, wh_name, db_name in substantive_list:
        escaped = wh_name.replace("\\", "\\\\").replace("'", "\\'")
        f.write(f"UPDATE `creature_template` SET `name` = '{escaped}' WHERE `entry` = {npc_id}; -- was: {db_name}\n")

print(f"  Wrote {len(substantive_list):,} UPDATE statements")
print("\nDone.")
