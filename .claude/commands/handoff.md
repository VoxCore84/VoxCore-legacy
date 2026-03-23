---
allowed-tools: Read, Glob, Bash(git*), Write
description: Generate a context handoff prompt for the next Claude Code tab — includes recent work, git state, pending items, and memory snapshots
---

# Handoff

Auto-generate a handoff document that gives the next Claude Code tab everything it needs to continue work without re-analysis.

## Arguments

$ARGUMENTS — optional: label or focus area (e.g., "companion system", "spell audit", "medium fixes")

## Process

### Step 1: Gather state (parallel)

Run these simultaneously:
- `git status --porcelain` — uncommitted changes
- `git log --oneline -10` — recent commits
- `git diff --stat` — current diff summary
- `git branch --show-current` — active branch
- Read `doc/session_state.md` (if exists)
- Read `memory/recent-work.md` — last 5 entries
- Read `memory/todo.md` — Next Session + HIGH sections
- Read `AI_Studio/0_Central_Brain.md` — current focus and infrastructure state

### Step 2: Extract actionable items

From the gathered state, build a prioritized list:
1. **Uncommitted work** — files modified but not committed (from git status)
2. **Next Session items** — from todo.md
3. **Pending handoffs** — from session_state.md
4. **User-specified focus** — from $ARGUMENTS if provided

### Step 3: Build handoff document

Write to `doc/handoff_[label].md` (use sanitized $ARGUMENTS as label, or `session_N` with the current session number from recent-work.md):

```markdown
# Handoff — [Label]
**Generated**: [date]
**Branch**: [branch]
**Last commit**: [hash] [message]

## What Was Done (This Session)
[Pull from recent-work.md latest entry]

## Current State
- **Build**: [last known build status from Central Brain]
- **Server**: [running/stopped]
- **Uncommitted files**: [count and list]
- **Branch**: [branch name]

## Priority Work for This Tab
1. [highest priority item with file paths]
2. [next item]
3. [next item]

## Key Context
- [relevant architectural decisions from this session]
- [any gotchas or things to watch out for]
- [DB state notes if applicable]

## Files You'll Need
- [list of key files for the priority work, with brief descriptions]

## Don't Touch (Other Tab Owns)
- [anything claimed by another tab in session_state.md]
```

### Step 4: Create desktop shortcut

Create a `.lnk`-equivalent shortcut on the desktop pointing to the handoff file:
```bash
# Windows shortcut via PowerShell
powershell.exe -Command "& { \$s = (New-Object -COM WScript.Shell).CreateShortcut('C:\Users\atayl\Desktop\Handoff - [label].lnk'); \$s.TargetPath = 'C:\Users\atayl\VoxCore\doc\handoff_[label].md'; \$s.Save() }"
```

### Step 5: Output summary

Show the user:
- Path to handoff file
- Top 3 items for next tab
- Any warnings (uncommitted changes, stale session_state, etc.)

## Rules
- Always include file paths, not just descriptions
- Include commit hashes for reference
- Don't include full file contents in the handoff — just paths and summaries
- If session_state.md has tab assignments, respect them in the "Don't Touch" section
- The handoff should be self-contained — the next tab reads ONE file and knows everything
