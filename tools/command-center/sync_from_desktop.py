"""
Sync Command Center shortcuts from desktop VC folders.

Reads all .lnk files from VC desktop folders, compares against app.py CATEGORIES,
and reports what's missing or extra. Can also generate the Python dict entries.

Usage:
    python sync_from_desktop.py           # Report differences
    python sync_from_desktop.py --dump    # Dump all desktop shortcuts as JSON
"""
import json
import os
import sys

import win32com.client

DESKTOP = os.path.join(os.environ["USERPROFILE"], "Desktop")

# Map desktop folder names to Command Center category IDs
FOLDER_TO_CAT = {
    "VC Server":   "server",
    "VC Build":    "build",
    "VC Pipeline": "pipeline",
    "VC Packets":  "packets",
    "VC Audits":   "audits",
    "VC Web":      "web",
    "VC Tools":    "tools",
}

# Folders that are known duplicates — skip them
SKIP_FOLDERS = {"VC Data"}


def read_desktop_shortcuts():
    """Read all .lnk files from VC desktop folders, return structured data."""
    ws = win32com.client.Dispatch("WScript.Shell")
    result = {}

    for folder_name in sorted(os.listdir(DESKTOP)):
        folder_path = os.path.join(DESKTOP, folder_name)
        if not folder_name.startswith("VC ") or not os.path.isdir(folder_path):
            continue
        if folder_name in SKIP_FOLDERS:
            continue

        cat_id = FOLDER_TO_CAT.get(folder_name, folder_name.lower().replace("vc ", ""))
        shortcuts = []

        for f in sorted(os.listdir(folder_path)):
            if not f.endswith(".lnk"):
                continue
            lnk_path = os.path.join(folder_path, f)
            s = ws.CreateShortcut(lnk_path)
            shortcuts.append({
                "name": f.replace(".lnk", ""),
                "target": s.TargetPath,
                "args": s.Arguments,
                "cwd": s.WorkingDirectory,
                "desc": s.Description,
                "icon": s.IconLocation,
            })

        result[cat_id] = {
            "folder": folder_name,
            "shortcuts": shortcuts,
        }

    return result


def load_command_center_names():
    """Load shortcut names from app.py CATEGORIES."""
    sys.path.insert(0, os.path.dirname(__file__))
    from app import CATEGORIES
    result = {}
    for cat in CATEGORIES:
        result[cat["id"]] = {s["name"] for s in cat["shortcuts"]}
    return result


def main():
    if "--dump" in sys.argv:
        data = read_desktop_shortcuts()
        print(json.dumps(data, indent=2, default=str))
        return

    desktop = read_desktop_shortcuts()
    cc_names = load_command_center_names()

    print("=" * 60)
    print("  VoxCore Command Center <-> Desktop Sync Report")
    print("=" * 60)

    total_desktop = 0
    total_cc = 0
    missing_in_cc = []
    extra_in_cc = []

    for cat_id, cat_data in sorted(desktop.items()):
        desk_names = {s["name"] for s in cat_data["shortcuts"]}
        cc = cc_names.get(cat_id, set())
        total_desktop += len(desk_names)
        total_cc += len(cc)

        # Fuzzy match: strip numbers, parenthetical suffixes, take first 2 words
        def normalize(n):
            import re
            n = n.lstrip("0123456789. ").lower().strip()
            n = re.sub(r'\s*\(.*?\)', '', n)  # remove (parenthetical)
            words = n.split()[:2]  # first 2 words to match abbreviated CC names
            return " ".join(words)

        desk_norm = {normalize(n): n for n in desk_names}
        cc_norm = {normalize(n): n for n in cc}

        only_desktop = set(desk_norm.keys()) - set(cc_norm.keys())
        only_cc = set(cc_norm.keys()) - set(desk_norm.keys())

        status = "OK" if not only_desktop and not only_cc else "DIFF"
        print(f"\n  [{status}] {cat_data['folder']} ({cat_id}): {len(desk_names)} desktop, {len(cc)} CC")

        for n in sorted(only_desktop):
            print(f"    + DESKTOP ONLY: {desk_norm[n]}")
            missing_in_cc.append((cat_id, desk_norm[n]))

        for n in sorted(only_cc):
            print(f"    - CC ONLY: {cc_norm[n]}")
            extra_in_cc.append((cat_id, cc_norm[n]))

    # Check for CC categories with no desktop folder
    for cat_id in cc_names:
        if cat_id not in desktop:
            print(f"\n  [??] CC category '{cat_id}' has no desktop folder")
            for name in sorted(cc_names[cat_id]):
                extra_in_cc.append((cat_id, name))

    print(f"\n{'=' * 60}")
    print(f"  Desktop: {total_desktop} shortcuts across {len(desktop)} folders")
    print(f"  Command Center: {total_cc} cards across {len(cc_names)} categories")
    if missing_in_cc:
        print(f"  Missing in CC: {len(missing_in_cc)} (add these to app.py)")
    if extra_in_cc:
        print(f"  Extra in CC: {len(extra_in_cc)} (URL links or CC-only items)")
    if not missing_in_cc and not extra_in_cc:
        print(f"  Status: FULLY SYNCED")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()
