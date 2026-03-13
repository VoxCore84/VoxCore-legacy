#!/bin/bash
# CreatureCodex — Update WPP + Ymir (Linux/macOS)
cd "$(dirname "$0")"
python3 update_tools.py --no-shortcut "$@"
