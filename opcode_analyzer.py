#!/usr/bin/env python3
"""
opcode_analyzer.py — TrinityCore Opcode Dictionary + Unknown Opcode Finder

Parses Opcodes.h and Opcodes.cpp to build a complete opcode dictionary,
then cross-references with a World_parsed.txt packet capture to find:
  - Unhandled client opcodes the client actually sent
  - Unknown opcodes not in the source at all
  - All transmog-related opcodes with handler status
  - Detailed breakdown for any highlighted opcode

Usage:
    python opcode_analyzer.py                          # auto-detect World_parsed.txt
    python opcode_analyzer.py World_parsed.txt         # explicit packet file
    python opcode_analyzer.py --lookup TRANSMOG         # search opcode dictionary
    python opcode_analyzer.py --lookup 0x3A017C         # lookup by hex
    python opcode_analyzer.py --dict-only               # dump full dictionary
    python opcode_analyzer.py --highlight 0x3A0043      # highlight specific opcode
"""

import re
import sys
import os
import json
import argparse
from collections import defaultdict

DEFAULT_PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
OPCODES_H_REL = "src/server/game/Server/Protocol/Opcodes.h"
OPCODES_CPP_REL = "src/server/game/Server/Protocol/Opcodes.cpp"
CACHE_FILE = ".opcode_cache.json"

# Where World_parsed.txt usually lives
PACKET_LOG_CANDIDATES = [
    "out/build/x64-RelWithDebInfo/bin/RelWithDebInfo/PacketLog/World_parsed.txt",
    "out/build/x64-Debug/bin/Debug/PacketLog/World_parsed.txt",
    "out/build/x64-RelWithDebInfo/bin/PacketLog/World_parsed.txt",
    "out/build/x64-Debug/bin/PacketLog/World_parsed.txt",
]


# ---------------------------------------------------------------------------
# 1. Parse Opcodes.h — build name → hex value mapping
# ---------------------------------------------------------------------------

def parse_opcodes_h(filepath):
    """Parse both OpcodeClient and OpcodeServer enums from Opcodes.h.

    Handles:
      - Direct hex:   CMSG_FOO = 0x3A0047,
      - Expressions:  CMSG_BAR = CMSG_FOO + 1,
      - Direct dec:   CMSG_BAZ = 12345,
    Returns dict  { name(str) → value(int) }
    """
    opcodes = {}
    current_enum = None
    enum_re = re.compile(r'^\s*(\w+)\s*=\s*(.+?),?\s*(?://.*)?$')

    with open(filepath, 'r', encoding='latin1') as f:
        for line in f:
            stripped = line.strip()

            # Detect enum start / end
            if 'enum OpcodeClient' in stripped:
                current_enum = 'client'
                continue
            elif 'enum OpcodeServer' in stripped:
                current_enum = 'server'
                continue
            elif current_enum and stripped.startswith('};'):
                current_enum = None
                continue

            if not current_enum:
                continue

            # Skip blank, comment-only, or constexpr lines
            if not stripped or stripped.startswith('//') or stripped.startswith('constexpr'):
                continue

            m = enum_re.match(stripped)
            if not m:
                continue

            name = m.group(1)
            expr = m.group(2).strip().rstrip(',')

            # Direct hex
            hm = re.fullmatch(r'0[xX]([0-9A-Fa-f]+)', expr)
            if hm:
                opcodes[name] = int(hm.group(1), 16)
                continue

            # Direct decimal
            dm = re.fullmatch(r'(\d+)', expr)
            if dm:
                opcodes[name] = int(dm.group(1))
                continue

            # Expression: OTHER_NAME + N
            em = re.fullmatch(r'(\w+)\s*\+\s*(\d+)', expr)
            if em:
                base = em.group(1)
                offset = int(em.group(2))
                if base in opcodes:
                    opcodes[name] = opcodes[base] + offset
                else:
                    print(f"  [warn] Cannot resolve {name} = {base} + {offset} (base unknown)",
                          file=sys.stderr)
                continue

            # Alias: OTHER_NAME  (no arithmetic)
            am = re.fullmatch(r'(\w+)', expr)
            if am:
                ref = am.group(1)
                if ref in opcodes:
                    opcodes[name] = opcodes[ref]
                elif ref == 'UNKNOWN_OPCODE':
                    pass  # intentionally disabled opcode, skip silently
                else:
                    print(f"  [warn] Cannot resolve {name} = {ref} (alias unknown)",
                          file=sys.stderr)
                continue

    return opcodes


# ---------------------------------------------------------------------------
# 2. Parse Opcodes.cpp — build name → handler metadata
# ---------------------------------------------------------------------------

def parse_opcodes_cpp(filepath):
    """Extract handler status and function for each opcode name.

    Returns dict  { name(str) → { status, handler|connection, type } }
    """
    handlers = {}

    client_re = re.compile(
        r'\s*DEFINE_HANDLER\(\s*(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*,\s*&WorldSession::(\w+)\s*\)')
    server_re = re.compile(
        r'\s*DEFINE_SERVER_OPCODE_HANDLER\(\s*(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*\)')

    with open(filepath, 'r', encoding='latin1') as f:
        for line in f:
            m = client_re.match(line)
            if m:
                handlers[m.group(1)] = {
                    'status': m.group(2),
                    'processing': m.group(3),
                    'handler': m.group(4),
                    'type': 'client',
                }
                continue

            m = server_re.match(line)
            if m:
                handlers[m.group(1)] = {
                    'status': m.group(2),
                    'connection': m.group(3),
                    'type': 'server',
                }

    return handlers


# ---------------------------------------------------------------------------
# 3. Merge into hex → info dictionary (with JSON cache)
# ---------------------------------------------------------------------------

def build_opcode_dict(project_root, use_cache=True):
    cache_path = os.path.join(project_root, CACHE_FILE)
    h_path = os.path.join(project_root, OPCODES_H_REL)
    cpp_path = os.path.join(project_root, OPCODES_CPP_REL)

    for p in (h_path, cpp_path):
        if not os.path.exists(p):
            print(f"[error] Required file not found: {p}", file=sys.stderr)
            sys.exit(1)

    # Check cache freshness
    if use_cache and os.path.exists(cache_path):
        cache_mt = os.path.getmtime(cache_path)
        if cache_mt > os.path.getmtime(h_path) and cache_mt > os.path.getmtime(cpp_path):
            with open(cache_path, 'r') as f:
                cached = json.load(f)
            result = {int(k): v for k, v in cached.items()}
            print(f"[cache] Loaded {len(result)} opcodes from cache", file=sys.stderr)
            return result

    print("[parse] Building opcode dictionary from source...", file=sys.stderr)
    name_to_hex = parse_opcodes_h(h_path)
    name_to_handler = parse_opcodes_cpp(cpp_path)

    # Merge:  hex → { name, status, handler, type, ... }
    hex_to_info = {}
    for name, val in name_to_hex.items():
        info = {'name': name}
        if name in name_to_handler:
            info.update(name_to_handler[name])
        else:
            info['status'] = 'NO_HANDLER_ENTRY'
            info['type'] = 'client' if name.startswith('CMSG_') else 'server'
        hex_to_info[val] = info

    for name in name_to_handler:
        if name not in name_to_hex:
            print(f"  [warn] {name} in Opcodes.cpp but missing from Opcodes.h enum",
                  file=sys.stderr)

    # Write cache
    try:
        with open(cache_path, 'w') as f:
            json.dump({str(k): v for k, v in hex_to_info.items()}, f, separators=(',', ':'))
        print(f"[cache] Wrote {len(hex_to_info)} opcodes", file=sys.stderr)
    except OSError as e:
        print(f"  [warn] Cache write failed: {e}", file=sys.stderr)

    n_cmsg = sum(1 for v in hex_to_info.values() if v.get('type') == 'client')
    n_smsg = sum(1 for v in hex_to_info.values() if v.get('type') == 'server')
    print(f"[parse] {n_cmsg} CMSG + {n_smsg} SMSG = {len(hex_to_info)} total", file=sys.stderr)
    return hex_to_info


# ---------------------------------------------------------------------------
# 4. Stream-parse World_parsed.txt
# ---------------------------------------------------------------------------

def parse_packet_capture(filepath):
    """Stream through a (potentially huge) World_parsed.txt.

    Returns dict  { hex_val(int) → stats }
    """
    stats = defaultdict(lambda: {
        'direction': None,
        'count': 0,
        'min_size': None,
        'max_size': None,
        'first_time': None,
        'last_time': None,
        'first_hex_dump': None,
        'wpp_name': None,
    })

    header_re = re.compile(
        r'^(ClientToServer|ServerToClient):\s+'
        r'(\S+)\s+'
        r'\(0x([0-9A-Fa-f]+)\)\s+'
        r'Length:\s+(\d+)\s+'
        r'.*?Time:\s+(\S+\s+\S+)')

    hex_line_re = re.compile(r'^\|\s+([0-9A-Fa-f ]{2,}?)\s*\|')
    # The column-offset header "| 00 01 02 ... 0F |" also matches hex_line_re,
    # so we skip lines that exactly match the 16-byte offset row.
    OFFSET_HEADER = "00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F"

    current_opcode = None
    hex_lines = []
    line_count = 0
    is_first_hex_block = True  # track whether we still need hex dump for current opcode

    file_size = os.path.getsize(filepath)
    print(f"[parse] Streaming {filepath} ({file_size / 1048576:.1f} MB)", file=sys.stderr)

    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        for line in f:
            line_count += 1
            if line_count % 1_000_000 == 0:
                print(f"  ...{line_count:,} lines", file=sys.stderr)

            m = header_re.match(line)
            if m:
                # Flush previous packet's hex dump
                if current_opcode is not None and hex_lines and is_first_hex_block:
                    stats[current_opcode]['first_hex_dump'] = '\n'.join(hex_lines[:32])

                direction = m.group(1)
                name_or_dec = m.group(2)
                hex_val = int(m.group(3), 16)
                length = int(m.group(4))
                timestamp = m.group(5)

                current_opcode = hex_val
                hex_lines = []

                entry = stats[hex_val]
                entry['direction'] = direction
                entry['count'] += 1
                if entry['min_size'] is None or length < entry['min_size']:
                    entry['min_size'] = length
                if entry['max_size'] is None or length > entry['max_size']:
                    entry['max_size'] = length
                if entry['first_time'] is None:
                    entry['first_time'] = timestamp
                entry['last_time'] = timestamp

                if not name_or_dec.isdigit():
                    entry['wpp_name'] = name_or_dec

                # Only capture hex dump for the first occurrence of each opcode
                is_first_hex_block = entry['first_hex_dump'] is None

                continue

            # Hex-dump lines (only for first occurrence of this opcode)
            if current_opcode is not None and is_first_hex_block:
                hm = hex_line_re.match(line)
                if hm:
                    captured = hm.group(1).rstrip()
                    # Skip the column-offset header row
                    if captured != OFFSET_HEADER:
                        hex_lines.append(captured)

    # Flush last packet
    if current_opcode is not None and hex_lines and is_first_hex_block:
        stats[current_opcode]['first_hex_dump'] = '\n'.join(hex_lines[:32])

    print(f"[parse] {line_count:,} lines, {len(stats)} unique opcodes, "
          f"{sum(s['count'] for s in stats.values()):,} total packets", file=sys.stderr)
    return dict(stats)


# ---------------------------------------------------------------------------
# 5. Report generation
# ---------------------------------------------------------------------------

def _size_range(ps):
    lo, hi = ps.get('min_size'), ps.get('max_size')
    if lo is None:
        return "0 bytes"
    return f"{lo} bytes" if lo == hi else f"{lo}-{hi} bytes"


def print_report(opcode_dict, packet_stats, highlight_opcode=None, unhandled_only=False):
    # -- Section 1: unhandled client opcodes actually sent -----------------
    print("\n" + "=" * 90)
    print("  UNHANDLED CLIENT OPCODES  (sent by client, server ignores)")
    print("=" * 90)

    unhandled = []
    for hx, ps in sorted(packet_stats.items()):
        if ps['direction'] != 'ClientToServer':
            continue
        info = opcode_dict.get(hx)
        if info and info.get('status') == 'STATUS_UNHANDLED':
            unhandled.append((hx, info, ps))

    if unhandled:
        for hx, info, ps in unhandled:
            tag = "  <-- NEEDS HANDLER" if 'TRANSMOG' in info['name'] else ""
            print(f"  0x{hx:06X}  {info['name']:<52s} {info['status']:<20s}"
                  f" sent {ps['count']}x ({_size_range(ps)}){tag}")
    else:
        print("  (none)")

    if unhandled_only:
        return

    # -- Section 2: unknown opcodes ----------------------------------------
    print("\n" + "=" * 90)
    print("  UNKNOWN OPCODES  (not in Opcodes.h at all)")
    print("=" * 90)

    unknown = [(hx, ps) for hx, ps in sorted(packet_stats.items()) if hx not in opcode_dict]

    if unknown:
        for hx, ps in unknown:
            wpp = f"  WPP:{ps['wpp_name']}" if ps['wpp_name'] else ""
            print(f"  0x{hx:06X}  {ps['direction']:<18s} sent {ps['count']}x ({_size_range(ps)})"
                  f"  first: {ps['first_time']}  last: {ps['last_time']}{wpp}")
    else:
        print("  (none)")

    # -- Section 3: all transmog opcodes -----------------------------------
    print("\n" + "=" * 90)
    print("  ALL TRANSMOG / TRANSMOGRIFY OPCODES  (from Opcodes.h)")
    print("=" * 90)

    transmog = {h: i for h, i in opcode_dict.items()
                if 'TRANSMOG' in i['name'] or 'TRANSMOGRIF' in i['name']}

    for hx, info in sorted(transmog.items()):
        ps = packet_stats.get(hx)
        seen = f"seen: {ps['count']}x" if ps else "not seen"

        if info.get('type') == 'server':
            note = "(server-sent)"
        else:
            note = ""

        flag = ""
        if info.get('status') == 'STATUS_UNHANDLED' and info.get('type') == 'client':
            flag = "  <-- NEEDS HANDLER"
        elif info.get('handler') == 'Handle_NULL' and info.get('type') == 'client':
            flag = "  <-- NULL HANDLER"

        print(f"  0x{hx:06X}  {info['name']:<52s} {info.get('status','?'):<20s}"
              f" {seen:<15s} {note}{flag}")

    if not transmog:
        print("  (none)")

    # -- Section 4: highlighted opcode detail ------------------------------
    if highlight_opcode is not None:
        hx = highlight_opcode
        print("\n" + "=" * 90)
        print(f"  OPCODE 0x{hx:06X} DETAIL")
        print("=" * 90)

        info = opcode_dict.get(hx)
        ps = packet_stats.get(hx)

        if info:
            print(f"  Name:       {info['name']}")
            print(f"  Status:     {info.get('status', '?')}")
            print(f"  Type:       {info.get('type', '?')}")
            if 'handler' in info:
                print(f"  Handler:    WorldSession::{info['handler']}")
            if 'processing' in info:
                print(f"  Processing: {info['processing']}")
            if 'connection' in info:
                print(f"  Connection: {info['connection']}")
        else:
            print(f"  NOT FOUND in Opcodes.h")

        if ps:
            print(f"  Direction:  {ps['direction']}")
            print(f"  Times seen: {ps['count']}")
            print(f"  Sizes:      {_size_range(ps)}")
            print(f"  First:      {ps['first_time']}")
            print(f"  Last:       {ps['last_time']}")
            if ps['first_hex_dump']:
                print(f"  Hex dump (first occurrence):")
                for hl in ps['first_hex_dump'].split('\n'):
                    print(f"    | {hl}")
        else:
            print(f"  NOT SEEN in packet capture")

    # -- Section 5: summary ------------------------------------------------
    print("\n" + "=" * 90)
    print("  SUMMARY")
    print("=" * 90)

    total = sum(s['count'] for s in packet_stats.values())
    n_c2s = sum(1 for s in packet_stats.values() if s['direction'] == 'ClientToServer')
    n_s2c = sum(1 for s in packet_stats.values() if s['direction'] == 'ServerToClient')
    n_cmsg = sum(1 for v in opcode_dict.values() if v.get('type') == 'client')
    n_smsg = sum(1 for v in opcode_dict.values() if v.get('type') == 'server')

    print(f"  Packets in capture:         {total:,}")
    print(f"  Unique opcodes seen:        {len(packet_stats)}  ({n_c2s} C->S,  {n_s2c} S->C)")
    print(f"  Dictionary size:            {len(opcode_dict)}  ({n_cmsg} CMSG, {n_smsg} SMSG)")
    print(f"  Unknown opcodes:            {len(unknown)}")
    print(f"  Unhandled client opcodes:   {len(unhandled)}")


# ---------------------------------------------------------------------------
# 6. Standalone lookup helpers
# ---------------------------------------------------------------------------

def do_lookup(opcode_dict, query):
    """Look up by hex value, decimal value, or name substring."""
    q = query.strip()
    results = []

    # Explicit hex prefix
    if q.lower().startswith('0x'):
        try:
            val = int(q, 16)
        except ValueError:
            pass
        else:
            info = opcode_dict.get(val)
            if info:
                results.append((val, info))
            else:
                print(f"0x{val:06X}  not found in dictionary")
                return

    # Decimal
    if not results and q.isdigit():
        val = int(q)
        info = opcode_dict.get(val)
        if info:
            results.append((val, info))

    # Name substring search (always preferred over bare-hex guessing)
    if not results:
        upper = q.upper()
        results = [(h, i) for h, i in opcode_dict.items() if upper in i['name']]

    # Bare hex fallback (no 0x prefix, no name matches)
    if not results:
        try:
            val = int(q, 16)
        except ValueError:
            pass
        else:
            info = opcode_dict.get(val)
            if info:
                results.append((val, info))

    if results:
        for hx, info in sorted(results):
            handler = info.get('handler', info.get('connection', 'N/A'))
            print(f"  0x{hx:06X}  {info['name']:<52s} {info.get('status','?'):<20s} {handler}")
    else:
        print(f"  No matches for '{query}'")


def do_dict_dump(opcode_dict, filter_type=None):
    """Print full dictionary, optionally filtered to 'client' or 'server'."""
    for hx, info in sorted(opcode_dict.items()):
        if filter_type and info.get('type') != filter_type:
            continue
        handler = info.get('handler', info.get('connection', ''))
        print(f"0x{hx:06X}  {info['name']:<55s} {info.get('status','?'):<20s} {handler}")


# ---------------------------------------------------------------------------
# 7. Main
# ---------------------------------------------------------------------------

def _resolve_opcode(text, opcode_dict):
    """Resolve a user-provided opcode string to an int hex value.

    Tries in order:
      1. Explicit '0x' prefix  -> parse as hex
      2. Exact name match      -> return that opcode's value
      3. Name substring match  -> return if unambiguous, warn + pick lowest if multiple
      4. Bare hex (only if no name matches found) -> parse as hex
    """
    t = text.strip()

    # 1. Explicit hex prefix — unambiguous intent
    if t.lower().startswith('0x'):
        try:
            return int(t, 16)
        except ValueError:
            print(f"[warn] '{t}' looks like hex but won't parse", file=sys.stderr)
            return None

    # 2. Exact name match (case-insensitive)
    upper = t.upper()
    for hx, info in opcode_dict.items():
        if info['name'] == upper:
            return hx

    # 3. Substring match
    matches = sorted([(h, i) for h, i in opcode_dict.items() if upper in i['name']])
    if len(matches) == 1:
        return matches[0][0]
    elif matches:
        print(f"[warn] '{text}' matched {len(matches)} opcodes, "
              f"using: {matches[0][1]['name']}", file=sys.stderr)
        return matches[0][0]

    # 4. Bare hex fallback (no 0x prefix) — only if no name matched
    try:
        return int(t, 16)
    except ValueError:
        print(f"[warn] Cannot resolve '{text}' to any opcode", file=sys.stderr)
        return None


def find_packet_file(root):
    """Auto-detect the most recent World_parsed.txt."""
    best = None
    best_mt = 0
    for rel in PACKET_LOG_CANDIDATES:
        p = os.path.join(root, rel)
        if os.path.exists(p):
            mt = os.path.getmtime(p)
            if mt > best_mt:
                best, best_mt = p, mt
    return best


def main():
    ap = argparse.ArgumentParser(
        description="TrinityCore opcode dictionary + unknown-opcode finder")
    ap.add_argument('packet_file', nargs='?',
                    help='World_parsed.txt  (auto-detected if omitted)')
    ap.add_argument('--root', default=DEFAULT_PROJECT_ROOT,
                    help='Project root directory')
    ap.add_argument('--no-cache', action='store_true',
                    help='Rebuild opcode dictionary from source (ignore cache)')
    ap.add_argument('--highlight', default='0x3A017C',
                    help='Opcode to show in detail section (hex, default 0x3A017C)')
    ap.add_argument('--dict-only', action='store_true',
                    help='Dump the opcode dictionary and exit')
    ap.add_argument('--cmsg-only', action='store_true',
                    help='With --dict-only, show only client opcodes')
    ap.add_argument('--smsg-only', action='store_true',
                    help='With --dict-only, show only server opcodes')
    ap.add_argument('--unhandled-only', action='store_true',
                    help='Only print the unhandled client opcodes section')
    ap.add_argument('--lookup', metavar='QUERY',
                    help='Look up an opcode by hex value or name substring')

    args = ap.parse_args()

    # Build dictionary
    opcode_dict = build_opcode_dict(args.root, use_cache=not args.no_cache)

    # --lookup mode
    if args.lookup:
        do_lookup(opcode_dict, args.lookup)
        return

    # --dict-only mode
    if args.dict_only:
        ft = None
        if args.cmsg_only:
            ft = 'client'
        elif args.smsg_only:
            ft = 'server'
        do_dict_dump(opcode_dict, filter_type=ft)
        return

    # Full analysis mode — need a packet file
    pkt = args.packet_file
    if not pkt:
        pkt = find_packet_file(args.root)
        if pkt:
            print(f"[auto] {pkt}", file=sys.stderr)
        else:
            ap.error("No World_parsed.txt found. Pass it as an argument or place it in PacketLog/.")

    if not os.path.exists(pkt):
        print(f"[error] File not found: {pkt}", file=sys.stderr)
        sys.exit(1)

    highlight = _resolve_opcode(args.highlight, opcode_dict) if args.highlight else None

    packet_stats = parse_packet_capture(pkt)
    print_report(opcode_dict, packet_stats, highlight_opcode=highlight,
                 unhandled_only=args.unhandled_only)


if __name__ == '__main__':
    main()
