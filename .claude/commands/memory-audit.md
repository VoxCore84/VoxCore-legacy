---
allowed-tools: Read, Glob, Bash(wc*), Bash(cat*), Write, Edit
description: Audit memory files for size limits, orphans, stale entries, and contradictions
---

# Memory Audit

Check the health of auto-memory files and fix issues.

## Arguments

$ARGUMENTS — optional: `fix` to auto-fix issues, otherwise report-only

## Process

### Step 1: Check MEMORY.md line count

Read `C:\Users\atayl\.claude\projects\C--Users-atayl-VoxCore\memory\MEMORY.md` and count lines.

- **Under 180 lines**: OK (green)
- **180-200 lines**: WARNING — approaching limit, suggest trimming
- **Over 200 lines**: CRITICAL — lines after 200 are silently truncated. Identify what can be moved to topic files or removed

### Step 2: Inventory all memory files

Glob `C:\Users\atayl\.claude\projects\C--Users-atayl-VoxCore\memory\*.md` to get the full list.

For each file:
- Check file size (wc -l)
- Check last modified date
- Flag files over 500 lines as "large — consider splitting"
- Flag files not modified in 30+ days as "stale — verify still relevant"

### Step 3: Check for orphan files

Read MEMORY.md and extract all `[links](filename.md)` references. Compare against the actual file list from Step 2.

- **Orphan**: File exists but is NOT referenced from MEMORY.md or any other memory file → flag as "orphan — add link or delete"
- **Broken link**: MEMORY.md references a file that doesn't exist → flag as "broken link — fix or remove"

### Step 4: Check topic-index.md

Read `memory/topic-index.md` (if exists). Verify every file in the directory is listed in the index. Flag missing entries.

### Step 5: Cross-check for contradictions

Spot-check key facts across files:
- Session numbers in `recent-work.md` — are they monotonically increasing?
- ADSCD date — same in MEMORY.md and case-status.md?
- Build status — consistent between MEMORY.md and migration files?
- Any TODO items marked DONE in one file but still active in another?

### Step 6: Report

Output a summary:

```
## Memory Audit Results

### MEMORY.md
- Lines: N/200 [OK/WARNING/CRITICAL]
- Action needed: [none / trim N lines / move sections to topic files]

### File Inventory (N files)
| File | Lines | Last Modified | Status |
|------|-------|---------------|--------|
| ... | ... | ... | OK/stale/large |

### Orphans (N found)
- [filename] — not linked from any index

### Broken Links (N found)
- [link target] — referenced in [source] but doesn't exist

### Contradictions (N found)
- [description of contradiction]

### Recommendations
1. [actionable fix]
2. [actionable fix]
```

If user passed `fix` in arguments:
- Auto-trim MEMORY.md if over 200 lines (move excess to topic files)
- Add orphan files to topic-index.md
- Remove broken links from MEMORY.md
- Report what was fixed
