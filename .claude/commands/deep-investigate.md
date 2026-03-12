---
allowed-tools: Read, Grep, Glob, Bash(python3:*), Bash(grep:*), Bash(mysql:*), Agent, mcp__codeintel__*, mcp__mysql__*, mcp__wago-db2__*
description: Deep multi-agent investigation — fan out specialized agents to analyze a complex bug or system behavior from all angles simultaneously
---

# Deep Investigation

Coordinate multiple specialized agents to investigate a complex issue from all angles.
This is the VoxCore equivalent of "ultrathink" — but instead of generic agents, it uses
your actual project-specific agents with real MCP access.

## When to use

- Complex bugs that span multiple systems (C++ + SQL + packets + client behavior)
- Issues that took more than 10 minutes of single-threaded analysis without progress
- Anything touching transmog, companion AI, or cross-system interactions

## Arguments

$ARGUMENTS — Description of the issue to investigate.

## Process

### Phase 1: Fan Out (parallel agents)

Launch these agents SIMULTANEOUSLY — do NOT run them sequentially:

1. **Code Trace Agent** (researcher model): Use codeintel to trace the code path.
   Find the entry point, follow the call chain, identify all functions involved.
   Search for relevant error handling, edge cases, and assumptions.

2. **Data Agent** (sql-writer model): Query the database state.
   DESCRIBE relevant tables. Run targeted queries to check data consistency.
   Look for missing rows, wrong values, orphaned references.

3. **Log Agent** (log-analyst model): Read Server.log, DBErrors.log, Debug.log.
   Search for timestamps around the issue. Correlate log entries with the
   code path from Agent 1.

4. **Context Agent** (researcher model): Search memory files, bug trackers,
   and session history for prior work on this issue. Check transmog-bugtracker.md,
   spell-audit.md, companion-system.md as relevant.

### Phase 2: Synthesize

After ALL agents return, combine their findings:

1. **Cross-reference**: Do the code assumptions match the DB state?
   Do the logs confirm the expected code path was hit?
2. **Identify the gap**: Where does expected behavior diverge from actual?
3. **Cite evidence**: Every claim must reference a specific log line, DB row,
   code path (file:line), or packet field. No speculation.

### Phase 3: Propose (if enough data)

Following the 4-gate debugging pipeline:
- State the hypothesis with explicit citations
- Propose ONE fix (root cause only, never combine fixes)
- Trace downstream callers before modifying any function
- Flag anything unverified

### Output Format

```
## Investigation: [issue title]

### Evidence Collected
| Source | Finding | Citation |
|--------|---------|----------|
| Code   | ...     | file.cpp:123 |
| DB     | ...     | SELECT result |
| Logs   | ...     | Server.log line |
| History| ...     | session N finding |

### Hypothesis
[Single sentence] because [evidence A] + [evidence B] contradict [expected behavior].

### Proposed Fix
[One specific change with unified diff]

### Unverified Assumptions
- [anything not confirmed by tool output]
```

### Rules
- NEVER propose a fix without Phase 1 data. If agents return empty, say so.
- NEVER combine multiple fixes. One hypothesis, one change.
- NEVER skip the synthesis phase. Raw agent output without cross-referencing is useless.
- If the investigation is inconclusive, say "Insufficient data — need [specific thing]"
