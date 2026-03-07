"""
Extract NPC subtitles from raw Wowhead tooltip JSON data.

Reads all raw NPC JSON files (excluding *_parsed.json), parses the tooltip HTML
to extract subtitles, and writes results to a CSV file.

Tooltip structure:
  Row 1: NPC name (in <b> tag)
  Row 2 (optional): Subtitle text (e.g., "Fishing Trainer", "Food & Drink")
  Row 3: Level/Type/Classification (e.g., "Level 9 - 80 Humanoid (Normal)")
  Row 4 (optional): Zone name

The subtitle is the second <td> if it does NOT match:
  - The level+type pattern: "Level X ..." or just "Type (Classification)"
  - The type-only pattern: e.g., "Humanoid (Normal)", "Beast (Elite)", " (Normal)"
"""

import os
import re
import json
import csv
import sys
import time
from collections import Counter
from pathlib import Path

RAW_DIR = Path("C:/Users/atayl/VoxCore/wago/wowhead_data/npc/raw")
OUTPUT_CSV = Path("C:/Users/atayl/VoxCore/wago/wowhead_data/npc/npc_subtitles.csv")

# Creature type names (used for type-row detection)
CREATURE_TYPES = {
    'Aberration', 'Beast', 'Critter', 'Demon', 'Dragonkin', 'Elemental',
    'Gas Cloud', 'Giant', 'Humanoid', 'Mechanical', 'Not specified', 'Totem',
    'Undead', 'Non-combat Pet', 'Wild Pet', 'Uncategorized', 'Dragonkind',
    'Companion',
}

# Pattern to match the type/classification row
# Matches: "Level X ...", "Level ?? ...", "Humanoid (Normal)", " (Normal)", "Beast", etc.
LEVEL_PATTERN = re.compile(r'^Level\s+(?:\d|\?\?)')
TYPE_WITH_CLASS_PATTERN = re.compile(
    r'^\s*(?:Aberration|Beast|Critter|Demon|Dragonkin|Elemental|Gas Cloud|Giant|'
    r'Humanoid|Mechanical|Not specified|Totem|Undead|Non-combat Pet|Wild Pet|'
    r'Uncategorized|Dragonkind|Companion|)\s*\('
)

# Battle Pet tooltip pattern - these have a special structure
BATTLE_PET_PATTERN = re.compile(r'Battle Pet')

# Wowhead dev/internal tier labels (e.g., "T1 (1/1)", "T2 Melee", "T0 SWARMER")
# These are NOT real in-game subtitles
TIER_LABEL_PATTERN = re.compile(r'^T\d')

# Pre-compile the td extraction regex
TD_RE = re.compile(r'<td[^>]*>(.*?)</td>', re.DOTALL)
TAG_RE = re.compile(r'<[^>]+>')


def is_type_or_level_row(text: str) -> bool:
    """Check if a row is the Level/Type/Classification line or a bare type name."""
    text = text.strip()
    if not text:
        return True
    if LEVEL_PATTERN.match(text):
        return True
    if TYPE_WITH_CLASS_PATTERN.match(text):
        return True
    # Bare type name without classification, e.g., "Beast", "Humanoid"
    if text in CREATURE_TYPES:
        return True
    return False


def extract_subtitle_from_tooltip(tooltip: str, npc_name: str = '') -> str | None:
    """
    Extract subtitle from tooltip HTML.
    Returns the subtitle string or None if no subtitle found.
    """
    # Skip Battle Pet tooltips entirely (different structure)
    if 'tooltip-pet-header' in tooltip or 'Battle Pet' in tooltip:
        return None

    tds = TD_RE.findall(tooltip)

    # Strip out graphic/image rows (dungeon journal boss images)
    # These contain <img> tags and no useful text
    cleaned_tds = []
    for td in tds:
        text = TAG_RE.sub('', td).strip()
        # Skip rows that are empty after stripping HTML (image-only rows)
        if not text:
            continue
        cleaned_tds.append(td)

    if len(cleaned_tds) < 3:
        # Need at least: name, subtitle, type/level row
        # If only 2 rows, the second is the type row, not a subtitle
        return None

    # Row 0 is always the name (in <b> tag)
    # Row 1 could be subtitle or type/level
    row1_raw = cleaned_tds[1]
    row1 = TAG_RE.sub('', row1_raw).strip()

    # Decode HTML entities
    row1 = row1.replace('&amp;', '&').replace('&lt;', '<').replace('&gt;', '>')

    if not row1 or row1 == '&nbsp;' or row1 == '\xa0':
        return None

    # If the "subtitle" equals the NPC name, it's a misparse (graphic offset bug)
    if npc_name and row1 == npc_name:
        return None

    # If row1 is a level or type line, there's no subtitle
    if is_type_or_level_row(row1):
        return None

    # Filter out Wowhead dev tier labels (T0, T1, T2, etc.)
    if TIER_LABEL_PATTERN.match(row1):
        return None

    # Verify row 2 IS a type/level line (confirms row1 is a subtitle)
    row2 = TAG_RE.sub('', cleaned_tds[2]).strip()
    if not is_type_or_level_row(row2):
        # Row 2 is also not a type line — could be a misparse or unusual structure
        # Don't extract subtitle in ambiguous cases
        return None

    return row1


def main():
    start = time.time()

    # Collect all raw JSON filenames (exclude _parsed.json)
    print(f"Scanning {RAW_DIR} for raw JSON files...")
    all_files = []
    for entry in os.scandir(RAW_DIR):
        if entry.is_file() and entry.name.endswith('.json') and not entry.name.endswith('_parsed.json'):
            all_files.append(entry.path)

    print(f"Found {len(all_files):,} raw JSON files")

    # Process all files
    results = {}  # id -> subtitle
    errors = 0
    no_tooltip = 0
    processed = 0

    for filepath in all_files:
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                data = json.load(f)

            tooltip = data.get('tooltip', '')
            if not tooltip:
                no_tooltip += 1
                processed += 1
                continue

            npc_id = data.get('id')
            if npc_id is None:
                # Try to extract from filename
                npc_id = int(Path(filepath).stem)

            npc_name = data.get('name', '')
            subtitle = extract_subtitle_from_tooltip(tooltip, npc_name)
            if subtitle:
                results[npc_id] = subtitle

        except (json.JSONDecodeError, ValueError, KeyError) as e:
            errors += 1
        except Exception as e:
            errors += 1

        processed += 1
        if processed % 50000 == 0:
            elapsed = time.time() - start
            print(f"  Processed {processed:,} files ({elapsed:.1f}s)...")

    elapsed = time.time() - start
    print(f"\nProcessing complete in {elapsed:.1f}s")
    print(f"  Total files: {len(all_files):,}")
    print(f"  Processed:   {processed:,}")
    print(f"  Errors:      {errors:,}")
    print(f"  No tooltip:  {no_tooltip:,}")
    print(f"  With subtitle: {len(results):,}")

    # Write CSV sorted by ID
    OUTPUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'subtitle'])
        for npc_id in sorted(results.keys()):
            writer.writerow([npc_id, results[npc_id]])

    print(f"\nWrote {len(results):,} entries to {OUTPUT_CSV}")

    # Stats: top 20 most common subtitles
    subtitle_counts = Counter(results.values())
    print("\n=== Top 20 Most Common Subtitles ===")
    for subtitle, count in subtitle_counts.most_common(20):
        print(f"  {count:>5}  {subtitle}")

    # Category breakdown
    trainers = sum(1 for s in results.values() if 'Trainer' in s)
    vendors = sum(1 for s in results.values() if 'Vendor' in s or 'Supplies' in s or 'Goods' in s or 'Merchant' in s)
    food_drink = sum(1 for s in results.values() if 'Food' in s or 'Drink' in s or 'Innkeeper' in s or 'Bartender' in s or 'Cook' in s)
    flight = sum(1 for s in results.values() if 'Flight Master' in s or 'Gryphon' in s or 'Wind Rider' in s or 'Hippogryph' in s or 'Bat Handler' in s)
    guards = sum(1 for s in results.values() if 'Guard' in s or 'Sentinel' in s or 'Grunt' in s)
    quest = sum(1 for s in results.values() if 'Quest' in s)
    repair = sum(1 for s in results.values() if 'Repair' in s or 'Armorer' in s or 'Weaponsmith' in s or 'Armorsmith' in s)
    stable = sum(1 for s in results.values() if 'Stable' in s)
    banking = sum(1 for s in results.values() if 'Banker' in s or 'Auctioneer' in s or 'Guild' in s)
    mount = sum(1 for s in results.values() if 'Handler' in s or 'Dealer' in s or 'Riding' in s)

    print(f"\n=== Category Breakdown ===")
    print(f"  Trainers:       {trainers:>5}")
    print(f"  Vendors:        {vendors:>5}")
    print(f"  Food/Drink/Inn: {food_drink:>5}")
    print(f"  Flight:         {flight:>5}")
    print(f"  Guards:         {guards:>5}")
    print(f"  Quest:          {quest:>5}")
    print(f"  Repair/Armor:   {repair:>5}")
    print(f"  Stable:         {stable:>5}")
    print(f"  Banking/Guild:  {banking:>5}")
    print(f"  Mount/Riding:   {mount:>5}")

    return results


if __name__ == '__main__':
    main()
