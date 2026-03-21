---
allowed-tools: Read, Write, Bash(python:*), Bash(python3:*), Glob, Grep, Agent
description: Sort unsorted files — generate a move plan from inventory, dry-run, then execute with confirmation
---

# File Sort

## Arguments

`$ARGUMENTS` — one of:
- A directory path to sort (e.g., `Desktop/_Needs Sorted`)
- `execute` — execute the existing plan at `/tmp/sort_plan.json`
- `execute --delete` — execute moves AND deletes
- A specific subfolder (e.g., `Career`, `Brand`) to sort just that section

## Instructions

### If given a directory path (or no argument defaults to `Desktop/_Needs Sorted`):

1. **Check for existing inventory**: Look in `memory/needs-sorted-inventory.md` for a cached plan
2. **If inventory exists and is recent** (<7 days old):
   - Parse it into a JSON plan: `python tools/file_sort_executor.py --from-inventory <inventory.md> --output /tmp/sort_plan.json`
   - Dry-run: `python tools/file_sort_executor.py /tmp/sort_plan.json`
   - Show summary to user: N moves, N deletes, N missing, N errors
   - Ask: "Ready to execute? Say `/file-sort execute` to move files."

3. **If no inventory or stale** (>7 days):
   - Run `/index-folder` on the target directory first
   - Launch `file-sorter` agent with the manifest
   - Agent writes new inventory to `memory/needs-sorted-inventory.md`
   - Then proceed to step 2

### If `$ARGUMENTS` is "execute":

1. Read `/tmp/sort_plan.json` (or `C:/Users/atayl/AppData/Local/Temp/sort_plan.json` on Windows)
2. Execute moves only: `python tools/file_sort_executor.py /tmp/sort_plan.json --execute`
3. Report results
4. Do NOT delete files unless user explicitly says `execute --delete`

### If `$ARGUMENTS` is "execute --delete":

1. Same as execute but with `--delete` flag
2. **Warn before deleting**: Show the delete list and get confirmation
3. NEVER delete files marked as `secure_delete` — remind user to move credentials to password manager first

### Edge Cases

- If a destination directory doesn't exist, the executor creates it automatically
- If a destination file already exists (name conflict), the executor skips it and reports CONFLICT
- Files with `...` in their name (truncated in inventory) will show as MISSING — search for them with Glob
- Subdirectory moves (e.g., "MOVE AddonResearch/ to ExtTools/") need `shutil.move` on the whole dir — the executor handles both files and directories

### Safety Rules

1. **Always dry-run first** — never execute without showing the plan
2. **Never delete without explicit `--delete` flag** from the user
3. **Security-sensitive files** (passwords, recovery codes) — remind to move to password manager
4. **Large directories** (>1 GB) — warn before moving, suggest archiving instead
5. **After execution**: Update `memory/needs-sorted-inventory.md` with results (what moved, what's left)
