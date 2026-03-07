#!/usr/bin/env python3
"""
Extract completion_category and subtitle-based roles from raw Wowhead NPC JSON files.

Outputs:
  - npc_completion_category.csv: id,completion_category
  - npc_roles.csv: id,subtitle,detected_roles

Designed for 219K files - uses multiprocessing for speed.
"""

import json
import os
import re
import csv
import sys
import time
from multiprocessing import Pool, cpu_count
from html.parser import HTMLParser

RAW_DIR = r"C:\Users\atayl\VoxCore\wago\wowhead_data\npc\raw"
OUT_DIR = r"C:\Users\atayl\VoxCore\wago\wowhead_data\npc"

# Role detection rules: (keyword_in_subtitle, role_name, npcflag_bit)
ROLE_RULES = [
    # Trainer detection
    ("Trainer", "trainer", 16),
    # Vendor detection - many subtitle variants
    ("Vendor", "vendor", 128),
    ("Supplies", "vendor", 128),
    ("Goods", "vendor", 128),
    ("Weaponsmith", "vendor", 128),
    ("Armorsmith", "vendor", 128),
    ("Food & Drink", "vendor", 128),
    ("Reagents", "vendor", 128),
    ("Ammunition", "vendor", 128),
    ("Bowyer", "vendor", 128),
    ("Tradesman", "vendor", 128),
    ("Provisioner", "vendor", 128),
    ("Merchant", "vendor", 128),
    ("Bartender", "vendor", 128),
    # Flight master detection
    ("Flight Master", "flight_master", 8192),
    ("Gryphon Master", "flight_master", 8192),
    ("Wind Rider Master", "flight_master", 8192),
    ("Hippogryph Master", "flight_master", 8192),
    ("Bat Handler", "flight_master", 8192),
    ("Wyvern Master", "flight_master", 8192),
    ("Dragonhawk Master", "flight_master", 8192),
    # Innkeeper detection
    ("Innkeeper", "innkeeper", 65536),
    # Stable master detection
    ("Stable Master", "stable_master", 4194304),
    # Banker detection
    ("Banker", "banker", 131072),
    # Auctioneer detection
    ("Auctioneer", "auctioneer", 2097152),
    # Repair detection
    ("Repairs", "repair", 4096),
]


class TooltipSubtitleExtractor(HTMLParser):
    """Extract the subtitle (second <td> content) from a Wowhead NPC tooltip."""

    def __init__(self):
        super().__init__()
        self.in_td = False
        self.td_count = 0
        self.tr_count = 0
        self.current_text = ""
        self.subtitle = None
        self.name_found = False
        self.in_first_table = True

    def handle_starttag(self, tag, attrs):
        if tag == "td" and self.in_first_table:
            self.in_td = True
            self.td_count += 1
            self.current_text = ""
        elif tag == "tr" and self.in_first_table:
            self.tr_count += 1

    def handle_endtag(self, tag):
        if tag == "td" and self.in_td:
            self.in_td = False
            # First <td> = name row, second <td> = subtitle (if it's not a level/type line)
            if self.td_count == 2:
                text = self.current_text.strip()
                # Check if this is a subtitle vs a "Level X Type" line
                # Level lines match: "Level \d+" or just creature type
                if not re.match(r'^Level \d', text):
                    self.subtitle = text
            elif self.td_count > 2 and self.subtitle is None:
                # Sometimes subtitle is in 3rd td if 2nd is empty
                pass
        elif tag == "table":
            self.in_first_table = False

    def handle_data(self, data):
        if self.in_td:
            self.current_text += data


def extract_subtitle(tooltip_html):
    """Extract subtitle text from tooltip HTML."""
    if not tooltip_html:
        return ""

    parser = TooltipSubtitleExtractor()
    try:
        parser.feed(tooltip_html)
    except Exception:
        return ""

    return parser.subtitle or ""


def detect_roles(subtitle):
    """Detect NPC roles from subtitle text. Returns set of role names."""
    if not subtitle:
        return set()

    # "Former X" means the NPC no longer serves that role
    if subtitle.upper().startswith("FORMER "):
        return set()

    roles = set()
    subtitle_upper = subtitle.upper()
    for keyword, role, _ in ROLE_RULES:
        if keyword.upper() in subtitle_upper:
            roles.add(role)

    return roles


def process_file(filepath):
    """Process a single raw JSON file. Returns (id, name, completion_category, subtitle, roles) or None."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)

        npc_id = data.get('id')
        if npc_id is None:
            return None

        name = data.get('name', '')
        completion_category = data.get('completion_category')
        tooltip = data.get('tooltip', '')

        subtitle = extract_subtitle(tooltip)
        roles = detect_roles(subtitle)

        return (npc_id, name, completion_category, subtitle, roles)
    except Exception as e:
        return None


def main():
    start = time.time()

    # Collect all raw JSON files (not *_parsed.json)
    print(f"Scanning {RAW_DIR} for raw JSON files...")
    all_files = []
    for entry in os.scandir(RAW_DIR):
        if entry.is_file() and entry.name.endswith('.json') and not entry.name.endswith('_parsed.json'):
            all_files.append(entry.path)

    print(f"Found {len(all_files)} raw JSON files")

    # Process with multiprocessing
    num_workers = min(cpu_count(), 12)
    print(f"Processing with {num_workers} workers...")

    results = []
    with Pool(num_workers) as pool:
        results = pool.map(process_file, all_files, chunksize=500)

    # Filter None results
    results = [r for r in results if r is not None]
    print(f"Successfully processed {len(results)} NPCs")

    # Sort by ID
    results.sort(key=lambda x: x[0])

    # Write completion_category CSV
    cc_path = os.path.join(OUT_DIR, "npc_completion_category.csv")
    with open(cc_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'completion_category'])
        for npc_id, name, cc, subtitle, roles in results:
            if cc is not None:
                writer.writerow([npc_id, cc])

    cc_count = sum(1 for r in results if r[2] is not None)
    print(f"Wrote {cc_count} entries to {cc_path}")

    # Write roles CSV
    roles_path = os.path.join(OUT_DIR, "npc_roles.csv")
    roles_count = 0
    with open(roles_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'subtitle', 'detected_roles'])
        for npc_id, name, cc, subtitle, roles in results:
            if subtitle or roles:
                writer.writerow([npc_id, subtitle, ','.join(sorted(roles))])
                roles_count += 1

    print(f"Wrote {roles_count} entries with subtitles/roles to {roles_path}")

    # Stats
    role_counts = {}
    for _, _, _, _, roles in results:
        for r in roles:
            role_counts[r] = role_counts.get(r, 0) + 1

    print("\nRole detection summary:")
    for role, count in sorted(role_counts.items(), key=lambda x: -x[1]):
        print(f"  {role}: {count}")

    elapsed = time.time() - start
    print(f"\nCompleted in {elapsed:.1f}s")


if __name__ == '__main__':
    main()
