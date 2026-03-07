#!/usr/bin/env python3
"""
Deeper analysis of the 437 substantive NPC name mismatches.
Categorize the "(1)" suffix pattern and other sub-patterns.
"""

import csv
import re
from collections import Counter

# Load the mismatch data by re-reading the SQL file
SQL_PATH = "C:/Users/atayl/VoxCore/sql/exports/scripts/npc_name_fixes.sql"

mismatches = []
try:
    fh = open(SQL_PATH, "r", encoding="utf-8")
except FileNotFoundError:
    print(f"ERROR: Input file not found: {SQL_PATH}")
    raise SystemExit(1)

with fh:
    for line in fh:
        m = re.match(r"UPDATE `creature_template` SET `name` = '((?:[^'\\]|\\.)*)' WHERE `entry` = (\d+); -- was: (.+)", line)
        if m:
            wh_name = m.group(1).replace("\\'", "'").replace("\\\\", "\\")
            entry = int(m.group(2))
            db_name = m.group(3).strip()
            mismatches.append((entry, wh_name, db_name))

print(f"Total substantive mismatches: {len(mismatches)}")

# ── Sub-pattern analysis ─────────────────────────────────────────────────────

suffix_pattern = re.compile(r'^(.+?) \((\d+)\)$')

categories = {
    "db_has_numeric_suffix": [],       # DB = "Foo (1)", Wowhead = "Foo"
    "wh_has_numeric_suffix": [],       # Wowhead = "Foo (1)", DB = "Foo"
    "both_diff_suffix": [],            # Both have suffix but different
    "completely_different_name": [],    # Names share no significant overlap
    "minor_word_difference": [],       # Most words match, 1-2 differ
    "prefix_tag_difference": [],       # [UNUSED], [DNT], [PH], [HIDDEN] etc
    "typo_or_spacing": [],             # Off by 1-2 chars or spacing
    "other": [],
}

for entry, wh_name, db_name in mismatches:
    db_match = suffix_pattern.match(db_name)
    wh_match = suffix_pattern.match(wh_name)

    if db_match and db_match.group(1) == wh_name:
        categories["db_has_numeric_suffix"].append((entry, wh_name, db_name))
    elif wh_match and wh_match.group(1) == db_name:
        categories["wh_has_numeric_suffix"].append((entry, wh_name, db_name))
    elif db_match and wh_match:
        categories["both_diff_suffix"].append((entry, wh_name, db_name))
    elif re.match(r'\[', wh_name) or re.match(r'\[', db_name):
        categories["prefix_tag_difference"].append((entry, wh_name, db_name))
    else:
        # Check overlap: how many words are shared?
        wh_words = set(wh_name.lower().split())
        db_words = set(db_name.lower().split())
        if len(wh_words) == 0 or len(db_words) == 0:
            categories["completely_different_name"].append((entry, wh_name, db_name))
        else:
            overlap = len(wh_words & db_words) / max(len(wh_words), len(db_words))
            # Check for typo (edit distance)
            if overlap == 0:
                categories["completely_different_name"].append((entry, wh_name, db_name))
            elif overlap < 0.5:
                categories["minor_word_difference"].append((entry, wh_name, db_name))
            else:
                # Check if it's just a spacing/typo issue
                wh_nospace = re.sub(r'\s+', '', wh_name.lower())
                db_nospace = re.sub(r'\s+', '', db_name.lower())
                if wh_nospace == db_nospace:
                    categories["typo_or_spacing"].append((entry, wh_name, db_name))
                else:
                    categories["minor_word_difference"].append((entry, wh_name, db_name))

print(f"\n{'='*100}")
print(f"DETAILED CATEGORY BREAKDOWN")
print(f"{'='*100}")

for cat, items in sorted(categories.items(), key=lambda x: -len(x[1])):
    if not items:
        continue
    label = {
        "db_has_numeric_suffix": "DB has '(N)' suffix, Wowhead does not",
        "wh_has_numeric_suffix": "Wowhead has '(N)' suffix, DB does not",
        "both_diff_suffix": "Both have numeric suffix but different",
        "completely_different_name": "Completely different names",
        "minor_word_difference": "Partially overlapping / word differences",
        "prefix_tag_difference": "Tag prefix difference ([UNUSED] etc.)",
        "typo_or_spacing": "Spacing or typo difference",
        "other": "Other",
    }.get(cat, cat)
    print(f"\n--- {label}: {len(items)} ---")
    for entry, wh, db in items[:15]:
        print(f"  {entry:>8}  WH: {wh:<45}  DB: {db}")
    if len(items) > 15:
        print(f"  ... and {len(items) - 15} more")

# ── Summary ──────────────────────────────────────────────────────────────────

print(f"\n{'='*100}")
print(f"SUMMARY")
print(f"{'='*100}")
total = sum(len(v) for v in categories.values())
for cat, items in sorted(categories.items(), key=lambda x: -len(x[1])):
    if not items:
        continue
    label = {
        "db_has_numeric_suffix": "DB has '(N)' suffix, Wowhead does not",
        "wh_has_numeric_suffix": "Wowhead has '(N)' suffix, DB does not",
        "both_diff_suffix": "Both have numeric suffix but different",
        "completely_different_name": "Completely different names",
        "minor_word_difference": "Partially overlapping / word differences",
        "prefix_tag_difference": "Tag prefix difference",
        "typo_or_spacing": "Spacing or typo",
        "other": "Other",
    }.get(cat, cat)
    pct = len(items) / total * 100
    print(f"  {len(items):>4} ({pct:5.1f}%)  {label}")
print(f"  {total:>4} (100.0%)  TOTAL")
