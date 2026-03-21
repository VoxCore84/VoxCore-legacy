#!/usr/bin/env python3
"""
File Sort Executor — reads a JSON move plan and executes file moves.

Usage:
    python file_sort_executor.py plan.json                    # dry-run (default)
    python file_sort_executor.py plan.json --execute          # actually move files
    python file_sort_executor.py plan.json --execute --delete # also delete marked files
    python file_sort_executor.py --from-inventory inventory.md --output plan.json  # parse .md inventory

Plan format (JSON):
[
    {"action": "move", "source": "path/to/file", "dest": "path/to/dest/", "reason": "..."},
    {"action": "delete", "source": "path/to/file", "reason": "duplicate of X"},
    {"action": "skip", "source": "path/to/file", "reason": "needs manual review"},
    {"action": "secure_delete", "source": "path/to/file", "reason": "contains credentials"}
]
"""

import argparse
import json
import os
import re
import shutil
import sys
from pathlib import Path


def parse_inventory_md(md_path: str) -> list[dict]:
    """Parse a markdown inventory file into a JSON move plan.

    Looks for tables with columns like: File | Size | Target | Reason
    and rows that specify MOVE, DELETE, or other actions.
    """
    plan = []
    text = Path(md_path).read_text(encoding="utf-8")

    # Find the source directory from the inventory header
    source_dir = ""
    m = re.search(r"\*\*Source:\*\*\s*`([^`]+)`", text)
    if m:
        source_dir = m.group(1).rstrip("/\\")

    # Parse table rows — look for | file | size | target | reason |
    # Handle both "MOVE to Case_Reference" and "MOVE to Non-Case" sections
    table_pattern = re.compile(
        r"^\|\s*([^|]+?)\s*\|\s*([^|]*?)\s*\|\s*([^|]+?)\s*\|\s*([^|]*?)\s*\|",
        re.MULTILINE,
    )

    for match in table_pattern.finditer(text):
        filename = match.group(1).strip()
        _size = match.group(2).strip()
        target = match.group(3).strip()
        reason = match.group(4).strip()

        # Skip header rows and separator rows
        if filename in ("File", "---", "------") or filename.startswith("-"):
            continue
        if target in ("Target", "Target Folder", "Action", "---", "------"):
            continue

        source = os.path.join(source_dir, filename) if source_dir else filename

        if "**DELETE**" in target or target.upper() == "DELETE":
            action = "delete"
            dest = ""
        elif "password manager" in target.lower():
            action = "secure_delete"
            dest = ""
        else:
            action = "move"
            # Clean up target path
            dest = target.replace("**DELETE**", "").strip()
            if dest.startswith("Case_Reference/") or dest.endswith("/"):
                # Relative to Desktop
                if dest.startswith("Case_Reference/"):
                    dest = os.path.join(
                        r"C:\Users\atayl\Desktop\Case_Reference",
                        dest.removeprefix("Case_Reference/"),
                    )
                elif dest.startswith("VoxCore ") or dest.startswith("VoxCore/"):
                    dest = os.path.join(
                        r"C:\Users\atayl\VoxCore",
                        dest.removeprefix("VoxCore ").removeprefix("VoxCore/"),
                    )
                elif dest.startswith("Excluded/"):
                    dest = os.path.join(
                        r"C:\Users\atayl\Desktop\Excluded", dest.removeprefix("Excluded/")
                    )
                elif dest.startswith("Desktop/"):
                    dest = os.path.join(
                        r"C:\Users\atayl\Desktop", dest.removeprefix("Desktop/")
                    )
                else:
                    # Assume Case_Reference subfolder
                    dest = os.path.join(r"C:\Users\atayl\Desktop\Case_Reference", dest)

        plan.append(
            {
                "action": action,
                "source": source,
                "dest": dest,
                "reason": reason,
            }
        )

    return plan


def execute_plan(plan: list[dict], dry_run: bool = True, allow_delete: bool = False):
    """Execute a file sort plan."""
    stats = {"moved": 0, "deleted": 0, "skipped": 0, "errors": 0, "missing": 0}

    for i, item in enumerate(plan, 1):
        action = item.get("action", "skip")
        source = item.get("source", "")
        dest = item.get("dest", "")
        reason = item.get("reason", "")

        if not source:
            continue

        source_path = Path(source)
        exists = source_path.exists()

        prefix = f"[{i:3d}/{len(plan)}]"

        if not exists:
            print(f"{prefix} MISSING: {source}")
            stats["missing"] += 1
            continue

        if action == "skip":
            print(f"{prefix} SKIP: {source} — {reason}")
            stats["skipped"] += 1

        elif action == "move":
            dest_dir = Path(dest)
            dest_file = dest_dir / source_path.name

            if dry_run:
                print(f"{prefix} WOULD MOVE: {source}")
                print(f"         -> {dest_file}")
                stats["moved"] += 1
            else:
                try:
                    dest_dir.mkdir(parents=True, exist_ok=True)
                    if dest_file.exists():
                        print(f"{prefix} CONFLICT: {dest_file} already exists — skipping")
                        stats["skipped"] += 1
                    else:
                        shutil.move(str(source_path), str(dest_file))
                        print(f"{prefix} MOVED: {source_path.name} -> {dest_dir}")
                        stats["moved"] += 1
                except Exception as e:
                    print(f"{prefix} ERROR: {source} — {e}")
                    stats["errors"] += 1

        elif action == "delete":
            if dry_run:
                size = source_path.stat().st_size if source_path.is_file() else "dir"
                print(f"{prefix} WOULD DELETE: {source} ({size})")
                stats["deleted"] += 1
            elif allow_delete:
                try:
                    if source_path.is_dir():
                        shutil.rmtree(str(source_path))
                    else:
                        source_path.unlink()
                    print(f"{prefix} DELETED: {source}")
                    stats["deleted"] += 1
                except Exception as e:
                    print(f"{prefix} ERROR deleting: {source} — {e}")
                    stats["errors"] += 1
            else:
                print(f"{prefix} SKIP DELETE (--delete not set): {source}")
                stats["skipped"] += 1

        elif action == "secure_delete":
            print(f"{prefix} SECURE: {source} — MOVE TO PASSWORD MANAGER FIRST, then delete")
            stats["skipped"] += 1

    # Summary
    mode = "DRY RUN" if dry_run else "EXECUTED"
    print(f"\n--- {mode} Summary ---")
    print(f"  Moved:   {stats['moved']}")
    print(f"  Deleted: {stats['deleted']}")
    print(f"  Skipped: {stats['skipped']}")
    print(f"  Missing: {stats['missing']}")
    print(f"  Errors:  {stats['errors']}")

    if dry_run:
        print("\nThis was a DRY RUN. Add --execute to actually move files.")
        if stats["deleted"]:
            print("Deletes require both --execute AND --delete flags.")

    return stats


def main():
    parser = argparse.ArgumentParser(description="Execute a file sort plan")
    parser.add_argument("plan", nargs="?", help="Path to JSON plan file")
    parser.add_argument("--execute", action="store_true", help="Actually move files (default: dry-run)")
    parser.add_argument("--delete", action="store_true", help="Also execute delete actions (requires --execute)")
    parser.add_argument("--from-inventory", type=str, help="Parse a .md inventory file into a JSON plan")
    parser.add_argument("--output", "-o", type=str, help="Output path for generated JSON plan")
    args = parser.parse_args()

    if args.from_inventory:
        plan = parse_inventory_md(args.from_inventory)
        if args.output:
            Path(args.output).write_text(
                json.dumps(plan, indent=2, ensure_ascii=False), encoding="utf-8"
            )
            print(f"Plan written to {args.output} ({len(plan)} actions)")
        else:
            print(json.dumps(plan, indent=2, ensure_ascii=False))
        return

    if not args.plan:
        parser.print_help()
        sys.exit(1)

    plan = json.loads(Path(args.plan).read_text(encoding="utf-8"))
    execute_plan(plan, dry_run=not args.execute, allow_delete=args.delete)


if __name__ == "__main__":
    main()
