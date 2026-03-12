---
description: Check OTTO Health - Run Antigravity optimization health check and report findings
---

// turbo-all

Run the OTTO optimization health check for Antigravity IDE.

### What to do

1. Use the `otto` MCP server's `otto_health_check` tool to get the full health report
2. Parse the response JSON and present findings as a table

### Argument handling
- No argument → health check only, report findings
- `fix` → after checking, run `otto_fix_regressions` tool, report what was fixed
- `baseline` → run `otto_get_baseline` to show current known-good state
- `update` → run `otto_update_baseline` to save current state as new baseline

### Output format

Present results as:

```
## OTTO Health Report

| Check | Status | Detail |
|-------|--------|--------|
| ... | OK/WARN/ERROR | ... |

**Overall: HEALTHY/DEGRADED/CRITICAL** (N/M checks passed)
```

If `fix` was requested, show before/after comparison.
If regressions were found, suggest running with `fix` argument.
