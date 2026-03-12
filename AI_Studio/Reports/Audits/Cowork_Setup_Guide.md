# Claude Cowork — Full Setup Guide

## 0. Platform Warning (READ FIRST)

**You are running Windows 11 Home (build 26200).** The Cowork research uncovered significant stability issues:

- Cowork runs inside a **Hyper-V Linux VM** on Windows. Windows 11 Home has LIMITED Hyper-V support — you get Virtual Machine Platform + Windows Hypervisor Platform, but NOT full Hyper-V
- **Known issue [#24918]**: Windows 11 Home users report "Cannot connect to API" errors in Cowork specifically because of the limited Hyper-V
- **Known issue [#29848]**: "Cowork completely unusable on Windows" — crashes, orphaned VM processes, disappearing Cowork tab
- **Known issue [#26302]**: v1.1.3189+ boots the Hyper-V VM on app start even when Cowork isn't being used, causing UI lag
- **DST bug (fixed v1.1.5749)**: Infinite loop when scheduled tasks fell in the "skipped" hour during DST transition

**Your HypervisorPlatform IS enabled** (session 131) and VMP was already on, which satisfies the minimum requirements. Your system (16C/32T, 128GB RAM) has more than enough resources. The question is whether Win11 Home's partial Hyper-V is sufficient.

**Recommendation**: Try the setup. If Cowork works, it's incredibly valuable as a scheduling layer. If it crashes, you're no worse off than the Antigravity instability you already have. Your existing Claude Code pipeline (`session_state.md` + hooks + `auto_parse` + `start_all.bat`/`stop_all.bat`) remains the reliable fallback.

**Upgrade path**: Windows 11 Pro/Enterprise has full Hyper-V and resolves most of these issues. If you plan on using Cowork heavily, this upgrade may be worth it.

---

## 1. Folder Grant

In Claude Desktop, go to **Settings > Cowork > Add Folder** and grant access to:

**Minimum** (safer):
```
C:\Users\atayl\cowork
```

**Recommended** (gives direct read access to repo):
```
C:\Users\atayl\cowork        (read+write — your workspace)
C:\Users\atayl\VoxCore        (read-only — live repo access)
```

Cowork runs in a sandboxed VM. It can only access folders you explicitly grant. It will ask for permission before deleting anything, regardless.

**Test after granting**: Ask Cowork to "Read C:\Users\atayl\VoxCore\AI_Studio\0_Central_Brain.md and summarize it." If it works, you have direct repo read access and the bridge becomes a secondary sync mechanism rather than the primary one.

## 2. Global Instructions

Copy the contents of `Cowork_Onboarding_Prompt.md` (the section between `BEGIN GLOBAL INSTRUCTIONS` and `END GLOBAL INSTRUCTIONS`) into:

**Claude Desktop > Settings > Cowork > Global Instructions > Edit**

These instructions load at the start of every Cowork session automatically — they're equivalent to CLAUDE.md for Claude Code. Keep them under ~150 instructions (shared budget with folder instructions and any plugins).

**Tip**: After the first few sessions, Claude may suggest refinements to your global instructions. The instructions compound over time — tweak them as you discover things Cowork keeps getting wrong.

## 3. Folder Instructions

Cowork supports **per-folder instructions** that load when you select a specific folder. Create a `CLAUDE.md` at the root of your cowork folder:

**File**: `C:\Users\atayl\cowork\CLAUDE.md`

This supplements the global instructions with workspace-specific rules. The existing `cowork/context/CLAUDE.md` is a reference copy — you want one at the ROOT of `cowork/` for Cowork to auto-read.

**Notable**: Cowork can autonomously UPDATE folder instructions during a session if it discovers something useful. Review these changes.

## 4. Context Files

Place reference files Cowork should read every session in the working folder. The existing `cowork/context/` directory already has:
- `project-bible.md` — full project reference
- `todo.md` — task list
- `CLAUDE.md` — project rules

**Best practice** (from community research): Create these three files for maximum Cowork effectiveness:
- `about-me.md` — your role, what you do, what good work looks like
- `voice.md` — how you want outputs written (technical, concise, date-stamped)
- `working-rules.md` — behavioral rules (ask before deleting, delegate DB work, etc.)

These files compound over time. Each tweak makes every future session better.

## 5. MCP Connectors

### Option A: Desktop Extensions (Recommended for simplicity)
**Settings > Extensions** — browse and one-click install reviewed connectors:
- **Filesystem** (usually built-in with folder grant)
- **GitHub** (read issues, PRs, code search — useful for monitoring VoxCore84 repos)

### Option B: Custom Local MCP via JSON Config
Edit `%APPDATA%\Claude\claude_desktop_config.json` (or access via Settings > Developer > Edit Config):

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "C:\\Users\\atayl\\cowork",
        "C:\\Users\\atayl\\VoxCore"
      ]
    }
  }
}
```

### Option C: Remote MCP Connectors
For external services (Slack, Google Drive, etc.), use **Settings > Connectors** (NOT the JSON config — Claude Desktop won't connect to remote servers from the JSON file).

### Should You Add MySQL/Wago/CodeIntel?
**No.** These MCP servers run as local stdio processes on the HOST, but Cowork runs inside a Linux VM. The path resolution, network access (127.0.0.1 from inside VM → host), and Python/DuckDB dependencies make this fragile. Use the bridge pattern instead: Claude Code runs queries, writes results to `bridge/`, Cowork reads them.

### Token Cost Warning
Every enabled MCP connector consumes tokens even when not called. GitHub MCP (40 tools) = ~8.5K tokens per request. Only enable connectors you actively use to avoid burning through your Max plan quota.

## 6. Scheduled Tasks Setup

After completing sections 1-5, create these scheduled tasks:

### Task 1: Morning Standup
```
/schedule
```
- **Name**: "VoxCore Morning Standup"
- **Prompt**: "Run the morning standup routine from your global instructions. Read Central Brain, session state, and todo. Check bridge freshness. Count unprocessed inbox specs. Write standup report to cowork/outputs/daily/standup_YYYY-MM-DD.md"
- **Cadence**: Daily at 8:00 AM
- **Working folder**: `C:\Users\atayl\cowork`

### Task 2: Inbox Triage
- **Name**: "VoxCore Inbox Triage"
- **Prompt**: "Scan AI_Studio/1_Inbox/ for markdown specs. For each: read, summarize in 2 sentences, assess complexity (S/M/L/XL), identify target agent. If implementation-ready, write a handoff file to cowork/outputs/. Update Central Brain if needed."
- **Cadence**: Every 4 hours

### Task 3: State Watchdog
- **Name**: "VoxCore State Watchdog"
- **Prompt**: "Check bridge/manifest.json freshness. Read bridge/git/status.txt and log_recent.txt. Compare against cowork/state/last_known_state.json. If significant changes, update state file and note what changed."
- **Cadence**: Every 2 hours

### Task 4: Weekly Rollup
- **Name**: "VoxCore Weekly Report"
- **Prompt**: "Compile this week's daily standups from cowork/outputs/daily/. Summarize git commits, specs processed, blockers. Write to cowork/outputs/weekly/report_YYYY-MM-DD.md with metrics."
- **Cadence**: Weekly, Sunday 6:00 PM

**Key facts about scheduled tasks**:
- Only run when computer is awake AND Claude Desktop is open AND you have usage quota
- Skipped runs auto-execute on next wake (you get a notification)
- Claude rewrites your task instructions after the first run to optimize them — review the changes
- Each run is a fresh session (no memory from previous runs), so your instructions must be self-contained
- Minimum UI interval is 1 hour; `/schedule` command in chat allows more precise timing

## 7. Bridge Sync (Keep Cowork Fed)

The bridge script (`cowork/sync_bridge.py`) snapshots VoxCore state into `cowork/bridge/`:

```bash
python ~/cowork/sync_bridge.py        # Quick sync (git + trees + SQL)
python ~/cowork/sync_bridge.py --full  # Full sync (includes source files)
```

**When to sync**:
- After every `/wrap-up` in Claude Code
- After significant commits
- Before starting a new Cowork session

**If you granted Cowork read access to VoxCore/**, the bridge becomes secondary — Cowork can read files directly. But the bridge is still valuable for:
- Git status/diff snapshots (Cowork's VM git can't see the host's git state)
- Source code snapshots for sub-agent analysis
- A fallback if direct read access is unreliable

**Automation**: Add `python ~/cowork/sync_bridge.py` to the Claude Code `/wrap-up` skill so it runs automatically at end of session.

## 8. Testing Your Setup

After completing setup, test with these prompts in a new Cowork task:

1. "Read C:\Users\atayl\VoxCore\AI_Studio\0_Central_Brain.md and summarize who is working on what"
2. "Check cowork/bridge/manifest.json — when was the bridge last synced?"
3. "List all .md files in AI_Studio/1_Inbox/ and count them"
4. "Write a test report to cowork/outputs/test_report.md confirming you can read and write files"
5. "Search the web for 'TrinityCore 12.x Midnight' and summarize what you find"

If all 5 work, Cowork is operational. If test 1 fails, you need direct folder access to VoxCore and will rely on the bridge.

## 9. Cowork vs Other Agents

| Capability | Claude Code | Antigravity | Cowork |
|-----------|------------|------------|--------|
| Terminal/bash | Host OS (full) | IDE terminal | VM sandbox (isolated) |
| MySQL MCP | Direct access | Direct access | No (delegate) |
| Wago DB2 MCP | Direct access | Direct access | No (delegate) |
| Code Intelligence | clangd + ctags | IDE built-in | No (delegate) |
| Git push/commit | Yes (host) | Yes (IDE) | No (VM isolated) |
| Scheduled tasks | `/loop` (3-day expiry) | Unreliable | `/schedule` (persistent) |
| File I/O | Full repo | Full repo | Granted folders |
| Sub-agents | Yes (parallel) | Limited | Yes (parallel) |
| Web search | Yes | Limited | Yes (built-in) |
| Stability | Solid | Crashes often | Research preview |
| Memory | Persistent (MEMORY.md) | None across sessions | None across sessions |
| Cost | Claude Max plan | Gemini API credits | Claude Max plan |
| Build/compile | No (VS only) | Playwright/headless | No |
| Slash commands | 22 custom skills | 21 workflows | `/schedule` only |

**Cowork's unique advantage**: Persistent scheduled tasks. No other agent can reliably run recurring checks on a cadence. This is the entire value proposition for the Triad.

**Antigravity's remaining role**: QA/audit tasks needing full IDE, Playwright browser automation, Gemini perspective for architectural review.

## 10. Architecture

```
                    +------------------+
                    |   Human (User)   |
                    +--------+---------+
                             |
         +-------------------+-------------------+
         |          |              |              |
  +------v----+ +--v--------+ +--v---------+ +--v----------+
  | ChatGPT   | |Claude Code| | Antigravity| |   Cowork    |
  | Architect  | |Implementer| | QA Auditor | | Scheduler   |
  +-+----------+ +----+------+ +-----+------+ +------+------+
    |                 |              |                |
    | writes specs    | implements   | audits         | schedules +
    |                 |              |                | triages
    v                 v              v                v
  +-+--------------------------------------------------+------+
  |                  Shared Filesystem                         |
  |  AI_Studio/0_Central_Brain.md  (who is doing what)         |
  |  AI_Studio/1_Inbox/            (specs waiting)             |
  |  doc/session_state.md          (server state + priorities) |
  |  cowork/outputs/               (reports + handoffs)        |
  |  cowork/bridge/                (Claude Code snapshots)     |
  +------------------------------------------------------------+
```

**The key insight**: Cowork is the heartbeat. It runs on a cadence, checking state, triaging specs, flagging issues, and generating reports. ChatGPT designs, Claude Code implements, Antigravity audits, and Cowork makes sure nothing falls through the cracks between them.
