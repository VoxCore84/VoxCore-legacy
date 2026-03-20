#!/usr/bin/env python3
"""Walk a directory tree and produce a structured JSON manifest.

Outputs filename, size, type, modification date, and first N chars of text files.
Agents read the manifest instead of doing hundreds of ls/find calls.

Usage:
    python tools/folder_index.py <directory>
    python tools/folder_index.py <directory> --output manifest.json
    python tools/folder_index.py <directory> --preview 500 --max-depth 3
    python tools/folder_index.py <directory> --types .pdf,.docx,.eml
    python tools/folder_index.py <directory> --summary  # compact stats-only mode

Options:
    --output     Output file (default: stdout)
    --preview    Characters to preview from text files (default: 200, 0 to disable)
    --max-depth  Maximum directory depth to traverse (default: unlimited)
    --types      Comma-separated file extensions to include (default: all)
    --exclude    Comma-separated directory names to skip (default: .git,node_modules,__pycache__)
    --summary    Output a compact summary instead of full manifest
"""
import argparse
import json
import os
import sys
from collections import Counter, defaultdict
from datetime import datetime, timezone


TEXT_EXTENSIONS = {
    ".txt", ".md", ".csv", ".json", ".xml", ".html", ".htm", ".yaml", ".yml",
    ".toml", ".ini", ".cfg", ".conf", ".log", ".sql", ".py", ".lua", ".cpp",
    ".h", ".c", ".js", ".ts", ".css", ".sh", ".bat", ".ps1", ".eml", ".mbox",
}

DEFAULT_EXCLUDE = {".git", "node_modules", "__pycache__", ".venv", "venv", ".claude"}


def is_text_file(path, ext):
    if ext in TEXT_EXTENSIONS:
        return True
    # Heuristic: try reading a small chunk
    try:
        with open(path, "r", encoding="utf-8") as f:
            f.read(512)
        return True
    except (UnicodeDecodeError, PermissionError, OSError):
        return False


def get_preview(path, max_chars):
    if max_chars <= 0:
        return None
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            text = f.read(max_chars)
        return text.strip() if text.strip() else None
    except (PermissionError, OSError):
        return None


def scan_directory(root, preview_chars, max_depth, include_types, exclude_dirs):
    entries = []
    root = os.path.abspath(root)
    root_depth = root.rstrip(os.sep).count(os.sep)

    for dirpath, dirnames, filenames in os.walk(root):
        # Prune excluded directories
        dirnames[:] = [d for d in dirnames if d not in exclude_dirs]

        # Check depth
        current_depth = dirpath.rstrip(os.sep).count(os.sep) - root_depth
        if max_depth is not None and current_depth >= max_depth:
            dirnames.clear()
            continue

        for filename in sorted(filenames):
            filepath = os.path.join(dirpath, filename)
            _, ext = os.path.splitext(filename)
            ext = ext.lower()

            if include_types and ext not in include_types:
                continue

            try:
                stat = os.stat(filepath)
            except (PermissionError, OSError):
                continue

            relpath = os.path.relpath(filepath, root).replace("\\", "/")
            modified = datetime.fromtimestamp(stat.st_mtime, tz=timezone.utc).strftime("%Y-%m-%d %H:%M")

            entry = {
                "path": relpath,
                "name": filename,
                "ext": ext or "(none)",
                "size": stat.st_size,
                "modified": modified,
            }

            if is_text_file(filepath, ext) and preview_chars > 0:
                preview = get_preview(filepath, preview_chars)
                if preview:
                    entry["preview"] = preview

            entries.append(entry)

    return entries


def build_summary(entries, root):
    ext_counts = Counter()
    ext_sizes = defaultdict(int)
    total_size = 0
    dir_counts = Counter()

    for e in entries:
        ext_counts[e["ext"]] += 1
        ext_sizes[e["ext"]] += e["size"]
        total_size += e["size"]
        top_dir = e["path"].split("/")[0] if "/" in e["path"] else "(root)"
        dir_counts[top_dir] += 1

    return {
        "root": root,
        "total_files": len(entries),
        "total_size_bytes": total_size,
        "total_size_human": format_size(total_size),
        "by_extension": [
            {"ext": ext, "count": ext_counts[ext], "size": format_size(ext_sizes[ext])}
            for ext in sorted(ext_counts, key=lambda x: ext_sizes[x], reverse=True)
        ],
        "by_directory": [
            {"dir": d, "files": c}
            for d, c in dir_counts.most_common(30)
        ],
    }


def format_size(n):
    for unit in ("B", "KB", "MB", "GB"):
        if n < 1024:
            return f"{n:.1f} {unit}"
        n /= 1024
    return f"{n:.1f} TB"


def main():
    parser = argparse.ArgumentParser(description="Index a directory tree into a JSON manifest")
    parser.add_argument("directory", help="Root directory to scan")
    parser.add_argument("--output", "-o", help="Output file (default: stdout)")
    parser.add_argument("--preview", type=int, default=200, help="Text preview chars (0 to disable)")
    parser.add_argument("--max-depth", type=int, default=None, help="Max directory depth")
    parser.add_argument("--types", help="Comma-separated extensions to include (e.g. .pdf,.docx)")
    parser.add_argument("--exclude", default=".git,node_modules,__pycache__,.venv,venv,.claude",
                        help="Comma-separated dirs to skip")
    parser.add_argument("--summary", action="store_true", help="Compact stats-only output")
    args = parser.parse_args()

    root = os.path.expanduser(args.directory)
    if not os.path.isdir(root):
        print(f"Error: {root} is not a directory", file=sys.stderr)
        sys.exit(1)

    include_types = set(args.types.split(",")) if args.types else None
    exclude_dirs = set(args.exclude.split(",")) if args.exclude else DEFAULT_EXCLUDE

    entries = scan_directory(root, args.preview, args.max_depth, include_types, exclude_dirs)

    if args.summary:
        output = build_summary(entries, os.path.abspath(root))
    else:
        output = {
            "root": os.path.abspath(root),
            "scanned_at": datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC"),
            "total_files": len(entries),
            "files": entries,
        }

    text = json.dumps(output, indent=2, ensure_ascii=False)

    if args.output:
        with open(args.output, "w", encoding="utf-8", newline="\n") as f:
            f.write(text)
        print(f"Wrote {len(entries)} entries to {args.output} ({len(text):,} bytes)")
    else:
        print(text)


if __name__ == "__main__":
    main()
