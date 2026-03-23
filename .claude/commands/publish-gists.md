---
allowed-tools: Bash(git*), Bash(gh*), Bash(diff*), Bash(cat*), Read, Glob
description: Check which gist source files changed since last publish and push updates
---

# Publish Gists

Diff gist source files against their last-published state, show what changed, and push updates with confirmation.

## Arguments

$ARGUMENTS — optional: `all` to force-push all, or specific gist name (e.g., `changelog`, `runbook`)

## Gist Registry

| Name | Gist ID | Source File |
|------|---------|-------------|
| DB Report | `528e801b53f6c62ce2e5c2ffe7e63e29` | `doc/gist_db_report.md` |
| Changelog | `4c63baf8154753d2a89475d9a4f5b2cc` | `doc/gist_changelog.md` |
| Open Issues | `2b69757faa2a53172c7acb5bfa3ad3c4` | `doc/gist_open_issues.md` |
| Runbook | `84656ef0960c699927e3a555e8248f7b` | `doc/gist_runbook.md` |
| Style Guide | (no ID yet) | `doc/gist_style_guide.md` |

## Process

### Step 1: Check source file freshness

For each gist in the registry:
1. Check if the source file exists (`Read` or `Glob`)
2. Get last commit that touched it: `git log --oneline -1 -- <source_file>`
3. Compare against the gist's last update: `gh gist view <gist_id> --files` (check timestamp if available)

If user specified a name, only process that one. If `all`, process everything.

### Step 2: Show diff summary

For each gist with changes:
- Show a brief summary of what changed (new sections, updated counts, etc.)
- Show line count delta

Format:
```
## Gist Status

| Name | Source | Last Commit | Status |
|------|--------|-------------|--------|
| DB Report | gist_db_report.md | abc1234 (2d ago) | STALE |
| Changelog | gist_changelog.md | def5678 (today) | CHANGED |
| Open Issues | gist_open_issues.md | — | UP TO DATE |
| Runbook | gist_runbook.md | ghi9012 (5d ago) | STALE |
| Style Guide | gist_style_guide.md | — | NO GIST ID |
```

### Step 3: Confirm and push

**STOP and ask for confirmation.** Show which gists will be updated.

For each confirmed gist:
```bash
gh gist edit <gist_id> -f <filename> <source_file>
```

The `-f` flag specifies the filename within the gist. Use the basename of the source file.

### Step 4: Report

```
## Published
- Changelog → 4c63baf8... (updated)
- DB Report → 528e801b... (updated)

## Skipped
- Open Issues — already current
- Style Guide — no gist ID (create with `gh gist create doc/gist_style_guide.md`)
```

## Rules
- NEVER push without user confirmation
- If a source file doesn't exist, skip it with a warning
- If `gh gist edit` fails, report the error and continue with remaining gists
- If Style Guide has no gist ID, suggest creating one with `gh gist create`
