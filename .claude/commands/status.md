---
allowed-tools: Read, Glob, Bash(python3:*), Bash(wc:*), Bash(cat:*), Bash(git:*)
description: System dashboard — show hooks, agents, skills, MCP servers, env vars, session stats, and modified files at a glance
---

# System Status Dashboard

Display the complete health status of the Claude Code VoxCore environment.

## Instructions

Run these checks IN PARALLEL and format the results:

### 1. Hook Health
List all files in `.claude/hooks/` and verify each exists. Check `settings.local.json`
to see which hooks are wired to which lifecycle events. Report any hooks that exist
as files but aren't wired, or hooks referenced in settings that don't have files.

### 2. Agent Inventory
List all `.claude/agents/*/CLAUDE.md` files. For each, show: name, model, maxTurns,
memory setting, and one-line description from the frontmatter.

### 3. Skill Inventory
Count files in `.claude/commands/*.md`. Check that all have YAML frontmatter
(starts with `---`). Report any that are missing frontmatter.

### 4. Rules Files
List all `.claude/rules/*.md`. For each, show name and line count.

### 5. MCP Servers
Read the MCP configuration and list connected servers with their tool counts.

### 6. Environment Variables
Read `~/.claude/settings.json` and count the env vars. Group them by category
(model, timeout, output, feature flags). Flag any that look unusual.

### 7. Session Stats
If `~/.claude/session-stats.jsonl` exists, read the last 20 lines and report:
- Total entries today
- Most-used tools (top 5)
- Any PostToolUseFailure events (tool failures)
- Time of last entry

### 8. Git State
Run `git status --porcelain | wc -l` to count modified files.
Run `git log --oneline -1` to show last commit.

### 9. Settings Audit
Check for permission duplicates between `~/.claude/settings.json` and
`.claude/settings.local.json`. Check for env vars that might conflict.

### Output Format

```
## Claude Code System Status

### Hooks: N/N active (M wired in settings)
| Hook Script         | Event          | Async | Status |
|---------------------|----------------|-------|--------|
| sql-safety.py       | PreToolUse     | no    | OK     |
| ...                 | ...            | ...   | ...    |

### Agents: N defined
| Name                | Model  | MaxTurns | Memory  |
|---------------------|--------|----------|---------|
| ...                 | ...    | ...      | ...     |

### Skills: N commands (M with frontmatter)

### Rules: N files

### MCP: N servers connected

### Env Vars: N configured
[grouped summary]

### Session: [stats summary or "no stats file"]

### Git: [branch] | [N modified files] | last commit: [hash] [message]

### Issues Found:
- [any problems detected]
- [or "None — all systems nominal"]
```
