#!/bin/bash
# CreatureCodex — Parse existing captures (Linux/macOS)
cd "$(dirname "$0")"
python3 session.py --parse "$@"
