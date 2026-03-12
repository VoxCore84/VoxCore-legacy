---
description: "Start a new session — load state, show pending work, suggest tab assignments"
allowed-tools: ["Read", "Glob"]
---

# Session Start

Read the current project state and present a concise briefing so the user can decide what to work on.

## Steps

1. **Read coordination state**: `doc/session_state.md` (if it exists)
   - Show the Active Tabs table
   - Show Tier 1-2 items (highest priority work)
   - Note anything marked IN-PROGRESS by another tab

2. **Read todo**: `C:\Users\atayl\.claude\projects\C--Users-atayl-VoxCore\memory\todo.md`
   - Show the `## Next Session` items
   - Count open items by priority (HIGH/MEDIUM/LOW)

3. **Check for uncommitted work**: Run a quick `git status --porcelain` equivalent by checking if `doc/session_state.md` mentions uncommitted files or pending builds.

4. **Present the briefing** in this format:

```
## Session Briefing

### Active Tabs
[table from session_state.md, or "No other tabs active"]

### Top Priority
1. [highest priority item]
2. [next item]
3. [next item]

### Suggested Tab Split
- **This tab**: [focused assignment]
- **Tab 2** (if warranted): [independent workstream]
- **Tab 3** (if warranted): [independent workstream]

### Quick Commands
- `/todo` — full task list
- `/check-logs` — server log health
- `/build-loop` — iterative build+fix
```

5. **Always suggest multi-tab splits** when the top priorities span different domains (world DB vs spells vs infrastructure vs DraconicBot). Reference the CLAUDE.md Work Style multi-tab rules.

## Rules
- Keep the briefing under 40 lines
- Don't start any work — just present options and let the user choose
- If `doc/session_state.md` doesn't exist, note that and work from todo.md alone
- Suggest creating/updating session_state.md if it's missing or stale
