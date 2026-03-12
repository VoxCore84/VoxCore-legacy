# Antigravity Optimization Audit — Pass 3: "100% Authority"

**Date**: 2026-03-11
**Auditor**: Claude Opus 4.6 (Claude Code)
**Premise**: If I had unlimited authority and zero constraints, what would I do differently?

---

## Current State Summary

| Component | Status |
|-----------|--------|
| settings.json | 96 lines, well-tuned (editor features stripped, watcher excludes solid) |
| argv.json | 4 flags (crash off, telemetry off, V8 heap 4GB) |
| Bundled extensions | 37 disabled, 67 still enabled (including ~15 unnecessary) |
| Marketplace extensions | 5 enabled (Python x3, Pyrefly, clangd) — all needed |
| MCP servers | 3 (mysql, wago-db2, codeintel) — stdio-based, per-session spawn |
| State DBs | Global=376KB, Workspace=92KB — journal_mode=DELETE, page_size=4096 |
| Watchdog | Polling every 60s, log-based, checks permissions + notifications |
| Launch script | 5-step: MCP pre-warm → context preload → optimizer → watchdog → launch |
| .agentrules | 1046 bytes — extremely concise, well-compressed |
| Agent rules | 3 files, 2338 bytes total — tight |
| Workspace storage | 6 dirs (5 orphan playground dirs, ~173KB wasted) |
| Disk footprint | Install=808MB, AppData=69MB, .antigravity=82MB |

**Critical Discrepancy Found**: MEMORY.md claims `searchMaxWorkspaceFileCount: 15000` and `persistentLanguageServer: true`, but actual `settings.json` shows `5000` and `false`. This needs reconciliation.

---

## A. Electron/Chromium Layer

### A1. Additional argv.json V8/Chromium Flags
**Impact**: HIGH | **Difficulty**: LOW

Current `argv.json` only has 4 entries. Antigravity (being Electron/Chromium-based) supports the full VS Code argv.json flag set. Add these:

```json
{
  "enable-crash-reporter": false,
  "disable-telemetry": true,
  "js-flags": "--max-old-space-size=4096 --optimize-for-size --lite-mode",
  "disable-hardware-acceleration": false,
  "force-disable-new-window": true,
  "password-store": "basic"
}
```

**Key additions explained**:
- `--optimize-for-size` — tells V8 to prefer smaller code over faster JIT, reducing memory pressure from the main renderer
- `--lite-mode` — V8 flag that disables background compilation and some optimization tiers, reducing CPU usage for the V8 runtime (the AI agent is the real workload, not the editor UI)
- `password-store: basic` — avoids spawning gnome-keyring/kwallet processes (VS Code pattern, may apply)
- `force-disable-new-window` — prevents accidental multi-window spawns

### A2. Chromium Flags via launch_antigravity.bat
**Impact**: MEDIUM | **Difficulty**: LOW

Pass Chromium flags via command line in the launch script:

```batch
start "" "%ANTIGRAVITY_EXE%" "%VOXCORE_DIR%" ^
    --disable-background-timer-throttling ^
    --disable-renderer-backgrounding ^
    --disable-backgrounding-occluded-windows ^
    --max-memory=8192
```

**Rationale**:
- `--disable-background-timer-throttling` — prevents Chromium from throttling timers when the window is not focused (critical for MCP servers running in extension host)
- `--disable-renderer-backgrounding` — keeps renderer at full speed when alt-tabbed
- `--disable-backgrounding-occluded-windows` — same, for occluded windows
- `--max-memory=8192` — explicit renderer memory limit (8GB is generous for 128GB system)

### A3. GPU Compositing Control
**Impact**: LOW | **Difficulty**: LOW

Currently no GPU flags set. Since this is primarily an AI coding tool (not a visual editor), consider:

```
--disable-gpu-compositing
```

This removes the GPU compositor layer, reducing VRAM allocation. However, this may make scrolling jankier — test first. With an RTX 5090 the GPU overhead is negligible, so **recommend leaving GPU compositing ON** and not adding this flag.

**Verdict**: Skip A3, implement A1 + A2.

---

## B. Extension Host Isolation

### B1. Disable 15+ More Bundled Extensions
**Impact**: HIGH | **Difficulty**: MEDIUM (must re-apply after every update)

67 bundled extensions are still enabled. For a VoxCore C++/Python/Lua/SQL workflow, at least 15 more can be disabled by renaming to `.disabled`:

| Extension | Reason to disable |
|-----------|-------------------|
| `css` + `css-language-features` | No CSS in VoxCore |
| `html` + `html-language-features` | No HTML editing |
| `emmet` | HTML/CSS snippet expander — unused |
| `docker` | Docker used for Lambda only, not in Antigravity |
| `ipynb` | No Jupyter notebooks |
| `powershell` | Shell scripts are bash, not PowerShell |
| `xml` | Minimal XML in project |
| `dotenv` | Minimal .env files, no syntax needed |
| `markdown-math` | No LaTeX math in markdown |
| `chrome-devtools-mcp` | Browser debugging — unused |
| `media-preview` | Image/video preview — unused in agent context |
| `mermaid-chat-features` | Mermaid diagrams in chat — marginal value |
| `antigravity-dev-containers` | No devcontainers used |
| `antigravity-remote-wsl` | No WSL used |
| `antigravity-remote-openssh` | No remote SSH development |

**Additionally, 14 theme extensions** are loaded but only 1-2 are actively used. Each theme registers color tokens at startup. Disable all but `theme-defaults` and whichever theme is actually active:

Candidates to disable: `theme-abyss`, `theme-kimbie-dark`, `theme-monokai-dimmed`, `theme-quietlight`, `theme-red`, `theme-seti`, `theme-solarized-dark`, `theme-solarized-light`, `theme-synthwave`, `theme-tokyo-night`, `theme-tomorrow-night-blue`

That is **26 more extensions** to disable, reducing from 67 to ~41 enabled bundled extensions.

### B2. Extension Host Memory Limit
**Impact**: MEDIUM | **Difficulty**: LOW

Add to `settings.json`:
```json
"extensions.experimental.affinity": {},
"remote.extensionKind": {}
```

VS Code-derived editors support `--max-old-space-size` per extension host. Currently the main process has 4GB (`argv.json`), but extension hosts inherit defaults (~1.5GB). For VoxCore's 5 marketplace extensions (Python, clangd, Pyrefly, debugpy), a 2GB extension host is more than enough. If Antigravity exposes this setting:

```json
"extensions.experimental.maxMemory": 2048
```

### B3. Disable Extension Host Restart Recovery
**Impact**: LOW | **Difficulty**: LOW

If the extension host crashes, VS Code auto-restarts it (potentially multiple times). For a developer who primarily uses the AI agent, a crashed extension host is noise. If Antigravity exposes it:

```json
"extensions.experimental.autoRestart": false
```

**Verdict**: B1 is the highest-value item in this entire audit. B2/B3 depend on Antigravity exposing these settings.

---

## C. File System Layer

### C1. RAM Disk for Temp/Scratch Directories
**Impact**: MEDIUM | **Difficulty**: MEDIUM

With 128GB RAM, allocating 4-8GB as a RAM disk (using ImDisk or OSFMount) for:
- Antigravity's temp directory (`%TEMP%\antigravity-*`)
- The playground sandbox dirs (`~/.gemini/antigravity/playground/`)
- Extension host IPC temp files

This eliminates disk I/O for ephemeral operations. However, the Samsung 980 PRO NVMe is already fast (7GB/s read), and the upcoming 9100 PRO Dev Drive will be even faster. **Net benefit is marginal on NVMe but significant if hitting NTFS metadata bottlenecks** (which can happen with many small temp files).

**Recommendation**: Wait for the 9100 PRO Dev Drive migration. If the Dev Drive (ReFS) resolves NTFS metadata overhead, skip the RAM disk. If not, revisit with ImDisk.

### C2. Move Antigravity State to Dev Drive
**Impact**: LOW | **Difficulty**: LOW (after 9100 PRO arrives)

Junction `AppData/Roaming/Antigravity/` to the Dev Drive. SQLite journals + workspace storage benefit from ReFS's copy-on-write semantics. Low priority — current 69MB footprint is trivial.

### C3. Clean Orphan Playground Workspace Storage
**Impact**: LOW | **Difficulty**: TRIVIAL

5 orphaned playground workspace storage dirs exist (173KB). These correspond to `~/.gemini/antigravity/playground/` sandbox dirs that Antigravity creates for scratch work. They accumulate state.vscdb files that are never cleaned.

**Action**: Add to `optimize_antigravity.py`:
```python
def clean_playground_workspaces(report, fix=False):
    """Remove workspace storage for playground dirs."""
    ws_root = AG_USER / "workspaceStorage"
    VOXCORE_HASH = "29ea68fc3b3d69dba9758beec734ef8c"
    for d in ws_root.iterdir():
        if d.is_dir() and d.name != VOXCORE_HASH:
            ws_json = d / "workspace.json"
            if ws_json.exists():
                data = json.loads(ws_json.read_text())
                folder = data.get("folder", "")
                if "playground" in folder:
                    if fix:
                        shutil.rmtree(str(d))
                    report.add("Playground Orphan", "WARN" if not fix else "FIXED", d.name)
```

---

## D. State DB Maintenance

### D1. Switch to WAL Mode
**Impact**: HIGH | **Difficulty**: LOW

Both state DBs use `journal_mode=DELETE` (the default). WAL (Write-Ahead Logging) is dramatically better for concurrent read/write workloads:

- **Readers never block writers** — the watchdog can read while Antigravity writes
- **Writers never block readers** — Antigravity doesn't stall on permission checks
- **Crash recovery is faster** — WAL checkpoints vs full journal replay
- **Reduced disk I/O** — WAL batches small writes

**Implementation**: Add to `optimize_antigravity.py` and run pre-launch:

```python
def set_wal_mode(report, db_path, name):
    conn = sqlite3.connect(str(db_path))
    current = conn.execute("PRAGMA journal_mode;").fetchone()[0]
    if current != "wal":
        conn.execute("PRAGMA journal_mode=WAL;")
        report.add(f"WAL Mode ({name})", "FIXED", f"{current} -> WAL")
    else:
        report.add(f"WAL Mode ({name})", "OK", "Already WAL")
    conn.close()
```

**Caveat**: Antigravity may reset this on startup. If so, the watchdog should periodically re-assert WAL mode (every cycle, not just once).

### D2. Optimize Page Size
**Impact**: LOW | **Difficulty**: MEDIUM

Current page_size=4096 is the default. For these small DBs (376KB / 92KB with ~95/69 rows), the page size is fine. A smaller page size (1024) would reduce waste for tiny rows, but SQLite handles this well already. **Not worth changing** — the DB must be rebuilt (VACUUM INTO) to change page size, and the benefit is negligible at these sizes.

### D3. Set Optimal Cache Size
**Impact**: LOW | **Difficulty**: LOW

Current cache_size=-2000 (2MB). For 376KB and 92KB databases, this is already generous — the entire DB fits in cache multiple times over. No change needed.

### D4. Pre-Optimize with ANALYZE
**Impact**: LOW | **Difficulty**: TRIVIAL

Add `ANALYZE` after VACUUM in `optimize_antigravity.py`. SQLite uses query planner statistics from ANALYZE to pick better indexes. With only ~100 rows it doesn't matter much, but it's free:

```python
conn.execute("ANALYZE")
```

**Verdict**: D1 (WAL mode) is the clear winner here. D4 is trivially easy to add. Skip D2/D3.

---

## E. MCP Server Optimization

### E1. Persistent MCP Daemon Mode
**Impact**: HIGH | **Difficulty**: HIGH

Currently each MCP server spawns fresh per-session via stdio. The codeintel server loads 416K symbols; wago-db2 loads CSV indexes. These take seconds each time.

**Proposal**: Create a persistent MCP multiplexer daemon:

```
┌─────────────────────────┐
│  mcp_daemon.py          │
│  (listens on named pipe │
│   or TCP 127.0.0.1:*)   │
│                         │
│  ┌─── codeintel ───┐    │
│  │ (416K symbols)  │    │
│  └─────────────────┘    │
│  ┌─── wago-db2 ────┐    │
│  │ (CSV indexes)   │    │
│  └─────────────────┘    │
│  ┌─── mysql ───────┐    │
│  │ (connection)    │    │
│  └─────────────────┘    │
└─────────────────────────┘
        ↑ stdio adapter ↑
        (thin wrapper for
         Antigravity's
         stdio-only MCP)
```

The daemon stays running between Antigravity restarts. A thin stdio adapter connects Antigravity's per-session stdio to the persistent daemon via named pipe.

**Complexity**: HIGH — requires writing a multiplexer, handling session lifecycle, and managing the stdio-to-pipe bridge. But the payoff is instant MCP availability on every new chat session.

**Alternative (E1b)**: Instead of a full daemon, just keep the pre-warm approach from `launch_antigravity.bat` but don't kill them — let Antigravity's own MCP instances connect to already-warm resources (OS file cache, MySQL connection pool). This is already partially implemented. **The pre-warm approach is 80% of the benefit at 10% of the complexity.**

### E2. Named Pipes Instead of stdio
**Impact**: MEDIUM | **Difficulty**: HIGH

stdio has overhead: Python's stdin/stdout buffering, line-by-line parsing, subprocess management. Named pipes (Windows) or Unix domain sockets bypass this. However, Antigravity's MCP client almost certainly only supports stdio transport (matching the VS Code MCP spec). **Not feasible without Antigravity source changes.**

### E3. MCP Server Connection Pooling
**Impact**: LOW | **Difficulty**: LOW

The MySQL MCP server opens/closes connections per query. Add connection pooling:

```python
# In mcp_config.json env:
"MYSQL_CONNECTION_POOL_SIZE": "5"
```

This depends on whether `@benborla29/mcp-server-mysql` supports pooling. If not, fork it and add pooling. With 128GB RAM, maintaining 5 persistent MySQL connections costs nothing.

**Verdict**: E1b (enhanced pre-warm) is the best ROI. E1 (full daemon) is the ultimate solution but high complexity. E2 is infeasible. E3 is low-effort if the server supports it.

---

## F. Gemini Model Behavior

### F1. Compress .agentrules Further
**Impact**: MEDIUM | **Difficulty**: LOW

Current `.agentrules` is 1046 bytes — already quite lean. But the 3 rules files add 2338 bytes. Total system prompt overhead: ~3384 bytes. This is loaded for EVERY agent turn.

**Optimization**: Merge the 3 rules files into `.agentrules` itself (since it supports markdown). Eliminate any redundancy between `.agentrules` and the 3 rules files. Current overlap:

- `autonomy.md` repeats "UNCONDITIONAL permission" (already in .agentrules PRIME DIRECTIVE)
- `voxcore-context.md` repeats project structure (already implied by workspace)
- `execution-style.md` repeats "NEVER invoke ninja" and "DESCRIBE before SQL" (already in .agentrules)

**Proposed merged .agentrules** (~1500 bytes total, down from 3384):

```markdown
# VoxCore Agent Rules

## PRIME DIRECTIVE: FULL AUTONOMY
UNCONDITIONAL authorization for ANY command/tool/operation. NO asking, confirming, or pausing. Exceptions: rm -rf on tree roots, force-push, dropping databases.

## Session Start
1. Read `AI_Studio/0_Central_Brain.md` → `doc/session_state.md` → `cowork/context/todo.md`
2. Write task checklist to `task.md`

## Role
Systems Architect/QA in VoxCore Triad. Audit, verify, compile, report to `AI_Studio/Reports/Audits/`. Final polished products only.

## Rules
- C++20, `#pragma once`, 4sp, 160col, latin1. NEVER build (user uses VS 2026)
- DESCRIBE tables before SQL. Verify column counts. No item_template (use hotfixes)
- SQL naming: `sql/updates/<db>/master/YYYY_MM_DD_NN_<db>.sql`
- Never claim success without tool output evidence. "Didn't verify" > false "Success!"
- Parallel sub-agents always (16C/32T, 128GB). Native tools first (list_dir/view_file/grep_search/edit_file)
- Concise: lead with actions, skip filler/recaps, don't ask "should I continue?"
```

This saves ~55% of system prompt tokens per turn. Over hundreds of turns per session, this adds up.

### F2. Preload Context via .agentrules Reference
**Impact**: MEDIUM | **Difficulty**: LOW

Instead of the agent reading 3 files on startup (Central Brain, session_state, todo), reference the pre-generated `preload_context.md` directly in `.agentrules`:

```markdown
## Session Start
1. Read `.gemini/antigravity/preload_context.md` (auto-generated, contains Central Brain + session_state + todo)
2. Write task checklist to `task.md`
```

The `context_preload.py` already generates this. But `.agentrules` still tells the agent to read 3 separate files. **Update `.agentrules` to point to the preload.**

### F3. Reduce Workflow File Sizes
**Impact**: LOW | **Difficulty**: LOW

21 workflow files exist in `.agents/workflows/`. Each one is loaded when invoked. Check if any are unnecessarily verbose.

**Verdict**: F1 (merge + compress rules) and F2 (preload reference) are easy wins.

---

## G. Process Priority

### G1. Set Antigravity to Above Normal Priority
**Impact**: MEDIUM | **Difficulty**: LOW

Add to `launch_antigravity.bat`:

```batch
:: Launch at Above Normal priority
start "" /ABOVENORMAL "%ANTIGRAVITY_EXE%" "%VOXCORE_DIR%" ...
```

With VoxCore builds happening in VS 2026 (which spawns ninja at normal priority with `-j20`), elevating Antigravity ensures the AI agent stays responsive during compilation.

**Do NOT use HIGH or REALTIME** — these can starve system processes and cause instability.

### G2. CPU Affinity to Performance Cores
**Impact**: LOW-MEDIUM | **Difficulty**: MEDIUM

The Ryzen 9 9950X3D has 16 cores but with 3D V-Cache on one CCD. For a mixed workload (Antigravity + VS builds), pinning Antigravity to one CCD and builds to the other would be ideal. However:

- Windows 11 24H2 has improved its thread director for Zen 5
- Antigravity is multi-process (main + renderer + extension host + MCP children) — pinning all of them requires a wrapper
- The benefit is marginal unless builds are causing UI stalls

**Recommendation**: Only implement if the user reports UI lag during builds. Use Process Lasso or a PowerShell wrapper:

```powershell
$p = Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue
if ($p) { $p.ProcessorAffinity = 0xFF00 }  # Cores 8-15
```

### G3. MCP Server Priority
**Impact**: LOW | **Difficulty**: LOW

The pre-warm MCP processes and the watchdog run at normal priority. Since they're background workers, they should run at BELOW_NORMAL:

```batch
start /B /BELOWNORMAL "AG-Watchdog" ...
```

This prevents the watchdog's 60-second polling from stealing time slices from foreground work.

**Verdict**: G1 is easy and worthwhile. G3 is trivially easy. G2 is situational.

---

## H. Monitoring

### H1. Event-Driven Watchdog via File System Watcher
**Impact**: MEDIUM | **Difficulty**: MEDIUM

The current watchdog polls every 60 seconds. This means:
- Up to 60 seconds of regression before detection
- Wasted CPU cycles on 59 of 60 polls (where nothing changed)

Replace polling with a file system watcher on `state.vscdb`:

```python
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class StateDBHandler(FileSystemEventHandler):
    def on_modified(self, event):
        if event.src_path.endswith("state.vscdb"):
            run_once(logger)

observer = Observer()
observer.schedule(handler, str(GLOBAL_STATE_DB.parent), recursive=False)
observer.start()
```

**Benefits**: Near-instant detection of permission regressions. Zero CPU between changes.

**Dependency**: `pip install watchdog` (or use `ReadDirectoryChangesW` via ctypes for zero-dependency).

### H2. Watchdog Health Metrics
**Impact**: LOW | **Difficulty**: LOW

Add structured metrics to the watchdog log:

```python
def run_once(logger):
    start = time.monotonic()
    # ... existing checks ...
    elapsed_ms = (time.monotonic() - start) * 1000
    logger.info(f"cycle={cycle} elapsed={elapsed_ms:.1f}ms fixes={len(actions)} db_size={db_size_kb(GLOBAL_STATE_DB):.0f}KB")
```

This enables trend analysis (is the DB growing? Are regressions happening after updates?).

### H3. Watchdog Process Guard
**Impact**: LOW | **Difficulty**: LOW

Currently the watchdog can silently die (crash, OOM) with no recovery. Add a process guard to `launch_antigravity.bat`:

```batch
:: Launch watchdog with auto-restart
:watchdog_loop
"%PYTHON%" "%WATCHDOG_SCRIPT%" --interval 60
echo [WARN] Watchdog exited — restarting in 5s...
timeout /t 5 /nobreak >nul
goto watchdog_loop
```

Or better, run the watchdog as a Windows scheduled task with restart-on-failure.

**Verdict**: H1 (event-driven) is the right architectural upgrade. H3 (process guard) is cheap insurance.

---

## I. Post-Update Resilience

### I1. Auto-Re-Disable Script
**Impact**: HIGH | **Difficulty**: LOW

When Antigravity updates, all `.disabled` extensions are replaced with fresh (enabled) copies. The 37 currently disabled + the proposed 26 more = 63 extensions that must be re-disabled after every update.

**Create `tools/antigravity/redisable_extensions.py`**:

```python
"""
Re-disable bundled extensions after Antigravity update.
Reads a manifest of extensions that should be disabled,
renames their directories to .disabled.
"""

DISABLED_MANIFEST = [
    "clojure", "coffeescript", "csharp", "dart", "fsharp", "go",
    "groovy", "grunt", "gulp", "handlebars", "hlsl", "jake",
    "java", "javascript", "julia", "latex", "less", "npm",
    "objective-c", "perl", "php", "php-language-features", "pug",
    "r", "razor", "restructuredtext", "ruby", "rust", "scss",
    "shaderlab", "swift", "typescript-basics",
    "typescript-language-features", "vb",
    "ms-vscode.js-debug-companion", "ms-vscode.js-debug",
    "ms-vscode.vscode-js-profile-table",
    # Pass 3 additions:
    "css", "css-language-features", "html", "html-language-features",
    "emmet", "docker", "ipynb", "powershell", "xml", "dotenv",
    "markdown-math", "chrome-devtools-mcp", "media-preview",
    "mermaid-chat-features", "antigravity-dev-containers",
    "antigravity-remote-wsl", "antigravity-remote-openssh",
    # Themes (keep only theme-defaults and theme-monokai):
    "theme-abyss", "theme-kimbie-dark", "theme-monokai-dimmed",
    "theme-quietlight", "theme-red", "theme-seti",
    "theme-solarized-dark", "theme-solarized-light",
    "theme-synthwave", "theme-tokyo-night",
    "theme-tomorrow-night-blue",
]
```

**Integration**: Add version detection to `optimize_antigravity.py` — compare stored version hash against `product.json` commit hash. If they differ, an update occurred and `redisable_extensions.py` should run automatically.

### I2. Scheduled Task for Post-Update
**Impact**: MEDIUM | **Difficulty**: LOW

Register a Windows Task Scheduler task that runs `redisable_extensions.py` on user logon:

```batch
schtasks /create /tn "VoxCore\AntigravityPostUpdate" ^
    /tr "C:\Python314\python.exe C:\Users\atayl\VoxCore\tools\antigravity\redisable_extensions.py" ^
    /sc ONLOGON /rl HIGHEST
```

This catches updates that happen during restarts or background auto-updates (even though auto-update is disabled in settings, the installer might still update).

### I3. Settings.json Drift Detection
**Impact**: MEDIUM | **Difficulty**: LOW

Add to `optimize_antigravity.py`: store a hash of `settings.json` and compare on each run. If the hash changes unexpectedly (update reset settings), restore from a known-good backup:

```python
SETTINGS_BACKUP = AG_USER / "settings.json.voxcore-backup"

def backup_settings():
    shutil.copy2(str(SETTINGS_JSON), str(SETTINGS_BACKUP))

def check_settings_drift():
    if SETTINGS_BACKUP.exists():
        backup_hash = hashlib.md5(SETTINGS_BACKUP.read_bytes()).hexdigest()
        current_hash = hashlib.md5(SETTINGS_JSON.read_bytes()).hexdigest()
        if backup_hash != current_hash:
            # Settings were modified — check if it was intentional
            ...
```

**Verdict**: I1 is critical — without it, every update undoes work. I2 is cheap insurance. I3 prevents silent settings regression.

---

## J. Network

### J1. DNS Prefetch for MCP Targets
**Impact**: LOW | **Difficulty**: TRIVIAL

All MCP servers connect to `127.0.0.1` (localhost). DNS resolution is not a bottleneck. **No action needed.**

### J2. MySQL Connection Keep-Alive
**Impact**: LOW | **Difficulty**: LOW

Add to the MCP mysql env:

```json
"MYSQL_CONNECTION_TIMEOUT": "0",
"MYSQL_KEEP_ALIVE": "true"
```

This prevents MySQL from dropping idle connections during long pauses between queries. Depends on whether the Node.js MCP server exposes these options.

### J3. Disable Antigravity Network Features
**Impact**: LOW | **Difficulty**: TRIVIAL

Already done: telemetry off, auto-update off, experiments off. Check if there are additional network calls:

```json
"extensions.gallery.serviceUrl": "",
"update.showReleaseNotes": false,
"workbench.settings.enableNaturalLanguageSearch": false
```

The gallery URL override would prevent extension marketplace queries entirely. Only do this if the user never installs new extensions through the UI.

**Verdict**: J section is mostly optimized already. J2 is a minor improvement if supported.

---

## BONUS: Discoveries and Fixes

### X1. MEMORY.md / settings.json Discrepancy (FIX NOW)
**Impact**: HIGH | **Difficulty**: TRIVIAL

MEMORY.md says:
- `searchMaxWorkspaceFileCount: 15000`
- `persistentLanguageServer: true`

Actual `settings.json` shows:
- `searchMaxWorkspaceFileCount: 5000`
- `persistentLanguageServer: false`

**Decision needed**: Which is correct?
- `15000` was the original intent (MEMORY.md). `5000` may have been set by the optimizer or reset. For VoxCore (~15K+ files), `5000` is too low and will cause incomplete search results. **Restore to 15000.**
- `persistentLanguageServer: true` keeps the language server alive between sessions. Setting it to `false` means clangd restarts on every session open, re-indexing 416K symbols. **Restore to true** — with 128GB RAM, keeping it persistent is free.

### X2. Orphan Workspace Storage Cleanup
**Impact**: LOW | **Difficulty**: TRIVIAL

5 playground workspace storage dirs (173KB) exist for scratch sandbox sessions. Add cleanup to `optimize_antigravity.py`.

### X3. launch_antigravity.bat MCP Pre-Warm is Partially Broken
**Impact**: MEDIUM | **Difficulty**: LOW

The current pre-warm spawns MCP processes and kills them after 3 seconds. But:
- The `taskkill /FI "WINDOWTITLE eq MCP-MySQL"` approach is fragile — window titles may not match
- The MCP processes may not fully initialize in 3 seconds (codeintel indexes 416K symbols)
- The pre-warm processes are killed BEFORE Antigravity launches, so the OS file cache benefit is time-limited

**Fix**: Don't kill pre-warm processes explicitly. Let them run for 30-60 seconds (or until their stdin closes, which terminates MCP servers naturally). The OS file cache persists after the process exits anyway, so the kill timing is less important than the initial read.

---

## Priority Matrix

| # | Proposal | Impact | Difficulty | Implement? |
|---|----------|--------|------------|------------|
| X1 | Fix MEMORY.md/settings.json discrepancy | HIGH | TRIVIAL | **NOW** |
| B1 | Disable 26 more bundled extensions | HIGH | MEDIUM | **NOW** |
| I1 | Auto-re-disable script | HIGH | LOW | **NOW** |
| D1 | Switch state DBs to WAL mode | HIGH | LOW | **NOW** |
| A1 | Additional argv.json V8 flags | HIGH | LOW | **NOW** |
| F1 | Merge + compress agent rules | MEDIUM | LOW | **NEXT** |
| F2 | Update .agentrules to use preload | MEDIUM | LOW | **NEXT** |
| A2 | Chromium flags in launch script | MEDIUM | LOW | **NEXT** |
| G1 | Above Normal process priority | MEDIUM | LOW | **NEXT** |
| H1 | Event-driven watchdog | MEDIUM | MEDIUM | **LATER** |
| E1b | Enhanced MCP pre-warm | MEDIUM | LOW | **NEXT** |
| I2 | Scheduled task for post-update | MEDIUM | LOW | **NEXT** |
| I3 | Settings drift detection | MEDIUM | LOW | **NEXT** |
| X3 | Fix pre-warm kill timing | MEDIUM | LOW | **NEXT** |
| G3 | Below Normal priority for watchdog | LOW | TRIVIAL | **NEXT** |
| H3 | Watchdog process guard | LOW | LOW | **LATER** |
| C3 | Clean orphan workspace storage | LOW | TRIVIAL | **NEXT** |
| D4 | Add ANALYZE to optimizer | LOW | TRIVIAL | **NEXT** |
| E1 | Full persistent MCP daemon | HIGH | HIGH | **LATER** |
| C1 | RAM disk for temp dirs | MEDIUM | MEDIUM | **SKIP** (wait for Dev Drive) |
| G2 | CPU affinity | LOW | MEDIUM | **SKIP** (situational) |
| E2 | Named pipes for MCP | MEDIUM | HIGH | **SKIP** (infeasible) |
| A3 | Disable GPU compositing | LOW | LOW | **SKIP** (marginal) |
| D2 | Optimize page size | LOW | MEDIUM | **SKIP** |
| D3 | Optimize cache size | LOW | LOW | **SKIP** (already optimal) |
| J1 | DNS prefetch | LOW | TRIVIAL | **SKIP** (localhost) |

---

## Estimated Total Impact

If all "NOW" + "NEXT" items are implemented:

| Metric | Current | Projected |
|--------|---------|-----------|
| Enabled bundled extensions | 67 | ~41 |
| Extension host memory | ~500MB (estimated) | ~300MB |
| State DB write latency | ~5ms (DELETE journal) | ~0.5ms (WAL) |
| System prompt tokens/turn | ~850 tokens | ~380 tokens |
| MCP cold start | 3-8 seconds | 0.5-1 second (pre-warm) |
| Post-update recovery | Manual (30+ minutes) | Automatic (5 seconds) |
| Watchdog reaction time | Up to 60 seconds | Near-instant (event-driven) |

**Bottom line**: The existing optimization work is solid — passes 1 and 2 handled the big wins (37 extensions disabled, file watchers configured, telemetry off, permissions watchdog). Pass 3 is about closing the remaining gaps, hardening against regression, and squeezing out the last 20-30% of overhead. The highest-impact items are B1 (more extension disabling), I1 (auto-re-disable), D1 (WAL mode), and X1 (fix the settings discrepancy).
