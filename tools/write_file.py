#!/usr/bin/env python3
"""Write large content to a file via stdin — avoids bash heredoc encoding issues.

Usage (from Claude Code agents):
    echo "content" | python tools/write_file.py <path>
    python tools/write_file.py <path> < source.txt
    python tools/write_file.py <path> --append

Or with inline content via --content flag:
    python tools/write_file.py <path> --content "text here"

Options:
    --append    Append instead of overwrite
    --mkdir     Create parent directories if they don't exist
    --encoding  File encoding (default: utf-8)
"""
import argparse
import os
import sys


def main():
    parser = argparse.ArgumentParser(description="Write content to a file from stdin or --content")
    parser.add_argument("path", help="Output file path")
    parser.add_argument("--append", action="store_true", help="Append instead of overwrite")
    parser.add_argument("--mkdir", action="store_true", help="Create parent directories")
    parser.add_argument("--encoding", default="utf-8", help="File encoding (default: utf-8)")
    parser.add_argument("--content", help="Content to write (alternative to stdin)")
    args = parser.parse_args()

    path = os.path.expanduser(args.path)

    if args.mkdir:
        os.makedirs(os.path.dirname(path) or ".", exist_ok=True)

    if args.content is not None:
        content = args.content
    elif not sys.stdin.isatty():
        content = sys.stdin.read()
    else:
        print("Error: No content provided. Pipe via stdin or use --content.", file=sys.stderr)
        sys.exit(1)

    mode = "a" if args.append else "w"
    with open(path, mode, encoding=args.encoding, newline="\n") as f:
        f.write(content)

    size = os.path.getsize(path)
    lines = content.count("\n")
    action = "Appended to" if args.append else "Wrote"
    print(f"{action} {path} ({size:,} bytes, {lines:,} lines)")


if __name__ == "__main__":
    main()
