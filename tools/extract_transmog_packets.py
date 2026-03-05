#!/usr/bin/env python3
"""Extract all transmog-related content from WPP packet log output files.

Produces a single output file with sections:
  1. Transmog Protocol Packets (CMSG_TRANSMOG*/SMSG_TRANSMOG*)
  2. TransmogBridge Addon Messages (TMOG_LOG, TMOG_BRIDGE, TSPY_LOG)
  3. Transmog-related UPDATE_OBJECT fields (ViewedOutfit, TransmogrifyDisabledSlotMask)
  4. Hotfix SQL tables (item_modified_appearance, transmog_illusion, transmog_set, etc.)
  5. Broadcast text / NPC gossip mentioning transmog
  6. Errors file transmog entries
"""

import re
import sys
import os
from pathlib import Path
from collections import defaultdict

# --- Config ---
PKT_DIR = Path(r"C:\Dev\RoleplayCore\out\build\x64-RelWithDebInfo\bin\RelWithDebInfo\PacketLog")
PARSED_FILE = PKT_DIR / "World_parsed.txt"
HOTFIXES_SQL = PKT_DIR / "2026_03_04_14_16_14_World.pkt_hotfixes.sql"
WPP_SQL = PKT_DIR / "2026_03_04_14_16_14_World.pkt_wpp.sql"
WORLD_SQL = PKT_DIR / "2026_03_04_14_16_14_World.pkt_world.sql"
ERRORS_FILE = PKT_DIR / "World_errors.txt"
OUTPUT_FILE = PKT_DIR / "transmog_extract.txt"

# Patterns
PACKET_HEADER_RE = re.compile(r'^(ClientToServer|ServerToClient): (\S+)')
TRANSMOG_OPCODE_RE = re.compile(r'CMSG_TRANSMOG|SMSG_TRANSMOG|CMSG_TRANSMOGRIFY|SMSG_TRANSMOGRIFY')
ADDON_PREFIX_RE = re.compile(r'Prefix: (TMOG_LOG|TMOG_BRIDGE|TSPY_LOG)')
TRANSMOG_FIELD_RE = re.compile(r'(ViewedOutfit|TransmogrifyDisabledSlotMask|TransmogrifyDisabledSlot)')

# Hotfix SQL tables we care about
HOTFIX_TABLES = [
    'item_modified_appearance',
    'item_modified_appearance_extra',
    'transmog_illusion',
    'transmog_set',
    'transmog_set_item',
    'transmog_set_group',
]


def extract_packet_block(lines, start_idx):
    """Given lines and a start index at a packet header, return all lines until next packet or blank-line gap."""
    block = [lines[start_idx]]
    i = start_idx + 1
    while i < len(lines):
        line = lines[i]
        # Next packet header = end of block
        if PACKET_HEADER_RE.match(line):
            break
        block.append(line)
        i += 1
    return block, i


def process_parsed_file(filepath):
    """Process World_parsed.txt, extracting transmog packets, addon messages, and field updates."""
    transmog_packets = []
    addon_messages = []
    field_updates = []

    print(f"  Reading {filepath.name} ({filepath.stat().st_size / 1024 / 1024:.1f} MB)...")

    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        lines = f.readlines()

    print(f"  {len(lines):,} lines loaded, scanning...")

    i = 0
    while i < len(lines):
        line = lines[i]
        header_match = PACKET_HEADER_RE.match(line)

        if header_match:
            opcode = header_match.group(2)

            # 1. Transmog protocol packets
            if TRANSMOG_OPCODE_RE.search(opcode):
                block, i = extract_packet_block(lines, i)
                transmog_packets.append(block)
                continue

            # 2. Addon messages with transmog prefixes
            if 'CMSG_CHAT_ADDON_MESSAGE' in opcode:
                block, next_i = extract_packet_block(lines, i)
                block_text = ''.join(block)
                if ADDON_PREFIX_RE.search(block_text):
                    addon_messages.append(block)
                i = next_i
                continue

            # 3. UPDATE_OBJECT with transmog fields (ViewedOutfit, TransmogrifyDisabledSlotMask)
            if 'SMSG_UPDATE_OBJECT' in opcode:
                block, next_i = extract_packet_block(lines, i)
                # Only include if it has transmog-relevant fields
                relevant_lines = [l for l in block if TRANSMOG_FIELD_RE.search(l)]
                if relevant_lines:
                    field_updates.append(block)
                i = next_i
                continue

        i += 1

    return transmog_packets, addon_messages, field_updates


def process_hotfixes_sql(filepath):
    """Extract transmog-related table INSERTs from hotfixes SQL."""
    sections = defaultdict(list)
    current_table = None
    in_transmog_block = False

    print(f"  Reading {filepath.name} ({filepath.stat().st_size / 1024 / 1024:.1f} MB)...")

    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        for line in f:
            line_lower = line.lower()

            # Detect DELETE/INSERT for transmog tables
            for table in HOTFIX_TABLES:
                if f'`{table}`' in line_lower:
                    current_table = table
                    in_transmog_block = True
                    break

            if in_transmog_block:
                sections[current_table].append(line)
                # End of INSERT block (line ends with semicolon not inside values)
                if line.rstrip().endswith(';') and not line.strip().startswith('DELETE'):
                    in_transmog_block = False
                    current_table = None

    return sections


def process_sql_file(filepath, label):
    """Extract any transmog-related lines from a SQL file."""
    results = []
    if not filepath.exists():
        return results

    print(f"  Reading {filepath.name}...")
    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        for line_num, line in enumerate(f, 1):
            if re.search(r'transmog|transmogrif|ViewedOutfit|ItemModifiedAppearance', line, re.IGNORECASE):
                results.append((line_num, line.rstrip()))
    return results


def process_errors_file(filepath):
    """Extract transmog-related error packets."""
    results = []
    if not filepath.exists():
        return results

    print(f"  Reading {filepath.name}...")
    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        for line_num, line in enumerate(f, 1):
            if re.search(r'transmog|transmogrif|TRANSMOG', line, re.IGNORECASE):
                results.append((line_num, line.rstrip()))
    return results


def write_output(output_path, transmog_packets, addon_messages, field_updates,
                 hotfix_sections, wpp_lines, world_lines, error_lines):
    """Write all extracted content to a single output file."""
    total_items = 0

    with open(output_path, 'w', encoding='utf-8') as out:
        out.write("=" * 100 + "\n")
        out.write("  TRANSMOG PACKET EXTRACT\n")
        out.write(f"  Generated from WPP output files in: {PKT_DIR}\n")
        out.write("=" * 100 + "\n\n")

        # --- Section 1: Transmog Protocol Packets ---
        out.write("=" * 100 + "\n")
        out.write(f"  SECTION 1: TRANSMOG PROTOCOL PACKETS ({len(transmog_packets)} packets)\n")
        out.write("  CMSG_TRANSMOG_OUTFIT_UPDATE_SLOTS, SMSG_TRANSMOG_OUTFIT_SLOTS_UPDATED, etc.\n")
        out.write("=" * 100 + "\n\n")
        for block in transmog_packets:
            for line in block:
                out.write(line if line.endswith('\n') else line + '\n')
            out.write('\n')
        total_items += len(transmog_packets)

        # --- Section 2: TransmogBridge Addon Messages ---
        out.write("=" * 100 + "\n")
        out.write(f"  SECTION 2: TRANSMOGBRIDGE ADDON MESSAGES ({len(addon_messages)} messages)\n")
        out.write("  TMOG_LOG, TMOG_BRIDGE, TSPY_LOG diagnostic addon messages\n")
        out.write("=" * 100 + "\n\n")
        for block in addon_messages:
            # Extract just the useful fields (skip the NullReferenceException noise)
            header = block[0].rstrip()
            prefix_line = ""
            text_line = ""
            for line in block:
                if 'Prefix:' in line:
                    prefix_line = line.strip()
                if 'Text:' in line:
                    text_line = line.strip()
            # Write compact form
            out.write(f"{header}\n")
            if prefix_line:
                out.write(f"  {prefix_line}\n")
            if text_line:
                out.write(f"  {text_line}\n")
            out.write('\n')
        total_items += len(addon_messages)

        # --- Section 3: UPDATE_OBJECT with Transmog Fields ---
        out.write("=" * 100 + "\n")
        out.write(f"  SECTION 3: UPDATE_OBJECT WITH TRANSMOG FIELDS ({len(field_updates)} packets)\n")
        out.write("  ViewedOutfit, TransmogrifyDisabledSlotMask from SMSG_UPDATE_OBJECT\n")
        out.write("=" * 100 + "\n\n")
        for block in field_updates:
            for line in block:
                out.write(line if line.endswith('\n') else line + '\n')
            out.write('\n')
        total_items += len(field_updates)

        # --- Section 4: Hotfix SQL Tables ---
        out.write("=" * 100 + "\n")
        out.write(f"  SECTION 4: HOTFIX SQL TABLES ({len(hotfix_sections)} tables)\n")
        out.write("  item_modified_appearance, transmog_illusion, transmog_set, etc.\n")
        out.write("=" * 100 + "\n\n")
        for table_name, lines in sorted(hotfix_sections.items()):
            # Count rows (approximate by counting lines with leading parentheses in VALUES)
            row_count = sum(1 for l in lines if l.strip().startswith('('))
            out.write(f"--- {table_name} ({row_count} rows, {len(lines)} SQL lines) ---\n")
            # For large tables, write summary + first/last few rows
            if row_count > 50:
                # Write the DELETE + INSERT header
                for line in lines:
                    if line.strip().startswith('('):
                        break
                    out.write(line)
                # First 10 data rows
                data_rows = [l for l in lines if l.strip().startswith('(')]
                out.write(f"-- First 10 of {row_count} rows:\n")
                for row in data_rows[:10]:
                    out.write(row)
                out.write(f"-- ... ({row_count - 20} rows omitted) ...\n")
                out.write(f"-- Last 10 rows:\n")
                for row in data_rows[-10:]:
                    out.write(row)
                out.write('\n')
            else:
                for line in lines:
                    out.write(line)
                out.write('\n')
        total_items += sum(len(v) for v in hotfix_sections.values())

        # --- Section 5: WPP/World SQL Mentions ---
        out.write("=" * 100 + "\n")
        out.write(f"  SECTION 5: OTHER SQL FILE MENTIONS\n")
        out.write("=" * 100 + "\n\n")
        if wpp_lines:
            out.write(f"--- From _wpp.sql ({len(wpp_lines)} lines) ---\n")
            for line_num, line in wpp_lines:
                out.write(f"  L{line_num}: {line}\n")
            out.write('\n')
        if world_lines:
            out.write(f"--- From _world.sql ({len(world_lines)} lines) ---\n")
            for line_num, line in world_lines:
                out.write(f"  L{line_num}: {line}\n")
            out.write('\n')
        if not wpp_lines and not world_lines:
            out.write("  (no transmog-related content found)\n\n")

        # --- Section 6: Errors ---
        out.write("=" * 100 + "\n")
        out.write(f"  SECTION 6: ERRORS ({len(error_lines)} lines)\n")
        out.write("=" * 100 + "\n\n")
        if error_lines:
            for line_num, line in error_lines:
                out.write(f"  L{line_num}: {line}\n")
        else:
            out.write("  (no transmog-related errors found)\n")
        out.write('\n')

        # --- Summary ---
        out.write("=" * 100 + "\n")
        out.write("  SUMMARY\n")
        out.write("=" * 100 + "\n")
        out.write(f"  Transmog protocol packets:     {len(transmog_packets)}\n")
        out.write(f"  TransmogBridge addon messages:  {len(addon_messages)}\n")
        out.write(f"  UPDATE_OBJECT with transmog:    {len(field_updates)}\n")
        out.write(f"  Hotfix SQL tables:              {len(hotfix_sections)} tables\n")
        for table_name, lines in sorted(hotfix_sections.items()):
            row_count = sum(1 for l in lines if l.strip().startswith('('))
            out.write(f"    - {table_name}: {row_count} rows\n")
        out.write(f"  WPP SQL mentions:               {len(wpp_lines)}\n")
        out.write(f"  World SQL mentions:             {len(world_lines)}\n")
        out.write(f"  Error lines:                    {len(error_lines)}\n")

    return total_items


def main():
    print("Transmog Packet Extractor")
    print("=" * 50)

    # Process all files
    print("\n[1/5] Processing parsed packet log...")
    transmog_packets, addon_messages, field_updates = process_parsed_file(PARSED_FILE)

    print(f"  Found: {len(transmog_packets)} transmog packets, "
          f"{len(addon_messages)} addon messages, "
          f"{len(field_updates)} update objects")

    print("\n[2/5] Processing hotfixes SQL...")
    hotfix_sections = process_hotfixes_sql(HOTFIXES_SQL)
    for table, lines in sorted(hotfix_sections.items()):
        row_count = sum(1 for l in lines if l.strip().startswith('('))
        print(f"  {table}: {row_count} rows")

    print("\n[3/5] Processing WPP SQL...")
    wpp_lines = process_sql_file(WPP_SQL, "wpp")
    print(f"  Found: {len(wpp_lines)} lines")

    print("\n[4/5] Processing world SQL...")
    world_lines = process_sql_file(WORLD_SQL, "world")
    print(f"  Found: {len(world_lines)} lines")

    print("\n[5/5] Processing errors file...")
    error_lines = process_errors_file(ERRORS_FILE)
    print(f"  Found: {len(error_lines)} lines")

    # Write output
    print(f"\nWriting output to {OUTPUT_FILE}...")
    write_output(OUTPUT_FILE, transmog_packets, addon_messages, field_updates,
                 hotfix_sections, wpp_lines, world_lines, error_lines)

    size_mb = OUTPUT_FILE.stat().st_size / 1024 / 1024
    print(f"\nDone! Output: {OUTPUT_FILE} ({size_mb:.1f} MB)")


if __name__ == '__main__':
    main()
