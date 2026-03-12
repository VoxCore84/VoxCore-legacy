# SPEC: VoxCore Daemon V2 — Autonomous DevOps Pipeline

**Spec ID**: TRIAD-DAEMON-V2
**Author**: Claude Code (Implementer), revised per Architect review
**Architect Review**: ChatGPT (gpt-5.4) — 2026-03-12
**Date**: 2026-03-12
**Priority**: P0
**Status**: APPROVED WITH MODIFICATIONS (15/16 initiatives approved, 1 rejected)

---

## 1. Problem Statement

The VoxCore Triad architecture requires human intervention at every step: building, applying SQL, restarting the server, reviewing logs, triaging specs, and pushing to git. Despite having 4 AI agents (ChatGPT, Claude Code, Antigravity, Cowork), none can operate unattended. Every layer has a human gate:

- Builds require the user to open Visual Studio
- SQL application has a 15-second timeout that defaults to SKIP
- Server restarts are manual
- Spec triage requires someone to read and route
- Git push requires approval
- Log monitoring is only active when auto_parse is running

The user spends $1K/month on AI tooling but still must be physically present for the pipeline to advance. The goal is to reduce human touchpoints from ~6 per cycle to ~1 per day (PR review).

## 2. Solution: VoxCore Daemon

A persistent Python process running as a background service on Windows, orchestrating the full development pipeline. It calls the Anthropic API directly (not Claude Code CLI) for intelligent decision-making, and uses subprocess/pymysql for builds, SQL, and server management.

### 2.1 Why Direct API, Not Claude Code CLI

| Factor | Claude Code CLI | Anthropic API Direct |
|--------|----------------|---------------------|
| Startup overhead | 5-10s (hooks, memory, MCP) | Instant |
| Needs terminal | Yes | No |
| Permission prompts | Yes | None — daemon's code controls all |
| Context control | Loads full MEMORY.md + rules | Surgical — only relevant files |
| Session limits | Compaction, 3-day /loop expiry | None — daemon runs indefinitely |
| Cost per call | Same model pricing | Same model pricing, less wasted tokens |

### 2.2 Relationship to Existing Orchestrator

The daemon REPLACES `tools/orchestrator/run_job.py` as the top-level scheduler but REUSES its adapter pattern. Existing adapters (`headless_build.py`, `auto_retry.py`) become workers inside the daemon. The daemon adds:
- Persistent scheduling (APScheduler)
- User-away detection (idle timer + time-of-day window)
- Direct Anthropic API calls (replacing Claude Code CLI subprocess)
- Discord webhook notifications
- Safety rails (dirty-tree protection, per-run branches, crash-loop prevention)

## 3. Architecture

```
tools/voxcore-daemon/
  daemon.py                 # Main entry point + APScheduler loop + single-instance guard
  config.toml               # All schedules, paths, toggles, thresholds
  autonomy_policy.toml      # What can be autonomous vs requires human approval
  workers/
    __init__.py
    base.py                 # BaseWorker with logging, error handling, state updates, dry-run
    inbox_triage.py         # Scan 1_Inbox/, call Claude API to analyze specs
    code_writer.py          # Call Claude API to write code patches (bounded)
    builder.py              # ninja CLI build + error parsing + 2 repair attempts
    sql_stager.py           # Validate, classify, checksum SQL files
    sql_applier.py          # Apply approved SQL via pymysql (restricted)
    server_manager.py       # Start/stop worldserver + bnetserver (graceful first)
    log_monitor.py          # Tail logs, detect crashes/errors, crash-loop protection
    git_manager.py          # Per-run branches, commit, push, optional PR
    report_writer.py        # Standup, weekly rollup, daemon run summaries
  state/
    daemon_state.json       # Runtime state (running workers, last heartbeat, managed PIDs)
    active_run.json         # Currently executing run (for crash recovery)
    work_queue.json         # Prioritized task queue
    run_history.jsonl       # Append-only audit trail (JSONL, not JSON)
    seen_specs.json         # Already-triaged inbox specs
    last_good_state.json    # Last known-good checkpoint
    spec_analyses/          # Per-spec triage results
  prompts/
    triage.md               # Prompt template for InboxTriage
    code_write.md           # Prompt template for CodeWriter
    compile_fix.md          # Prompt template for compile error fixing
    commit_message.md       # Prompt template for semantic commit messages
    report.md               # Prompt template for standup/weekly reports
  fixtures/                 # Test inputs for deterministic replay
    sample_specs/
    compile_errors/
    crash_logs/
    sql_files/
  notify.py                 # Discord webhook + BurntToast (notification classes)
  idle_detector.py          # Win32 GetLastInputInfo + time-of-day window
  claude_api.py             # Anthropic API wrapper with retry, circuit breaker, budget
  state_manager.py          # Atomic state read/write with file locking
  requirements.txt          # anthropic, apscheduler, pymysql, python-dotenv, requests
```

## 4. Worker Specifications

### 4.1 InboxTriage (Every 30 Minutes)

**Input**: `AI_Studio/1_Inbox/*.md`
**Output**: `state/spec_analyses/<spec>.json` + queue candidate OR handoff file

1. List all `.md` files in Inbox
2. Compare against `state/seen_specs.json` to find NEW files
3. For each new spec:
   a. Read the full text
   b. Call Claude API (Sonnet): "Analyze this spec. Rate complexity S/M/L/XL. Classify risk_class (safe/review-required/restricted). Is it implementation-ready? What source files would need to change? What databases are affected?"
   c. Store the analysis in `state/spec_analyses/`
   d. Route based on risk_class + complexity:
      - `safe` + complexity S/M + implementation-ready: add to `work_queue.json`
      - `review-required` OR complexity L/XL: write handoff to `cowork/outputs/daemon/`
      - `restricted`: write handoff, alert via Discord, never auto-queue
4. **Do NOT update Central Brain automatically in v1** — write to daemon outputs only

**Risk classification policy** (from `autonomy_policy.toml`):
- `safe`: tooling, reports, non-gameplay scripts, isolated utilities
- `review-required`: gameplay systems, new features, DB schema additions
- `restricted`: auth/account systems, network protocol, persistence layer, build system, credentials

**API context**: Spec text + project-bible.md summary. ~4K tokens input.

### 4.2 CodeWriter (On Queue Trigger)

**Input**: Work queue item with spec + target files
**Output**: Modified source files on disk (backed up originals in temp workspace)

1. **Preflight checks**:
   a. Verify working tree is clean (no uncommitted non-daemon changes)
   b. Verify task risk_class is `safe`
   c. Verify file count <= 5 and estimated LOC <= 400
   d. If any check fails: convert to handoff, skip
2. Pop highest-priority item from `work_queue.json`
3. Read the relevant source files (listed in the spec analysis)
4. Call Claude API (Sonnet for S/M, Opus only for explicitly complex tasks within budget):
   - The spec
   - The source files that need changing
   - Schema traps reminder (if SQL involved)
   - Coding conventions summary
5. Parse Claude's response for file modifications (unified diff / structured file blocks)
6. **Validate** parsed output before writing
7. **Backup** original files to `state/backups/<run_id>/`
8. Write patches to disk (atomic — write to `.tmp` first, then rename)
9. If SQL is produced: emit to `sql/updates/staging/` (NOT pending/)
10. Mark work queue item as "patched, awaiting build"

**Autonomous edit restrictions** (from `autonomy_policy.toml`):
- Max 5 files per task
- Max 400 LOC total change
- Exceeding either threshold converts task to handoff
- NEVER autonomously edit: auth/account systems, network protocol handlers, persistence layer abstractions, build system root files, deployment credentials/config

**API context**: Spec + target files + conventions. Typically 10-30K tokens.

### 4.3 Builder (After CodeWriter)

**Input**: Modified source files on disk
**Output**: Build success/failure + compiled binaries + artifacts

1. Run `ninja -j{config.ninja_jobs} -C out/build/{config.preset} 2>&1`
2. Capture stdout/stderr, store raw build log in `state/build_logs/<run_id>.log`
3. If exit code 0: mark success, proceed to SQL staging + restart
4. If exit code != 0:
   a. Parse errors using `tools/build/extract_compile_errors.py`
   b. Store parsed errors in `state/build_logs/<run_id>_errors.json`
   c. Call Claude API (Sonnet) with errors + source files: "Fix these compile errors"
   d. Apply fix, rebuild (**max 2 fix attempts**, then stop)
   e. If 2 retries exhausted: alert via Discord, stop pipeline for this item
5. Record build result in `run_history.jsonl`

**Build strategy**:
- Incremental build first (default)
- Clean rebuild only on repeated linker/state issues (manual trigger or config flag)

**Timeout**: 20 minutes per build attempt.

### 4.4 SQLStager (After CodeWriter produces SQL)

**Input**: SQL files in `sql/updates/staging/`
**Output**: Validated SQL moved to `sql/updates/pending/` with approval metadata

1. For each file in `staging/`:
   a. Validate filename format (`YYYY_MM_DD_NN_<db>.sql`)
   b. Classify target database from filename
   c. Classify SQL type: DDL (schema-altering) vs DML (data-only)
   d. Compute checksum (SHA-256)
   e. Check against `autonomy_policy.toml`:
      - Idempotent DML on content tables: mark `approved_for_apply`
      - DDL, destructive ops, auth/account changes: mark `requires_human_approval`
   f. Write approval metadata to `state/sql_approvals/<filename>.json`
2. Move `approved_for_apply` files to `sql/updates/pending/`
3. Leave `requires_human_approval` files in staging, alert via Discord

### 4.5 SQLApplier (After Successful Build)

**Input**: `sql/updates/pending/*.sql` (only those with `approved_for_apply` metadata)
**Output**: Applied SQL, files moved to `applied/`

1. Check `sql/updates/pending/` for `.sql` files
2. For each file:
   a. Verify approval metadata exists in `state/sql_approvals/`
   b. Verify checksum matches (file not modified since staging)
   c. Parse target database from filename
   d. Connect via pymysql (credentials from env)
   e. Execute the SQL
   f. On success: move to `sql/updates/applied/`, record in `run_history.jsonl`
   g. On error: log error, move to `sql/updates/failed/`, alert via Discord, stop pipeline
3. Every applied file records: target DB, checksum, run ID, timestamp

**Rollback policy** (Architect decision — no generic rollback claims):
- If SQL is idempotent content data and server fails after apply: alert and stop
- If a rollback companion file exists (`<filename>.rollback.sql`): may be executed
- Otherwise: require manual intervention, do NOT promise automatic reversal

### 4.6 ServerManager (After SQL Apply or On Demand)

**Input**: Command (start/stop/restart)
**Output**: Server running or stopped

1. **Stop** (graceful-first):
   a. Attempt SOAP `.server shutdown 5` (5-second countdown)
   b. Wait up to 15 seconds for graceful exit
   c. If still running: `taskkill /F /IM worldserver.exe` as fallback
   d. Same for bnetserver
2. **Start MySQL** (if not running): Launch configured DB process, poll port 3306
3. **Start bnetserver**: `subprocess.Popen(bnetserver_exe)`, record PID
4. **Start worldserver**: `subprocess.Popen(worldserver_exe)`, poll SOAP port 7878 (up to 90s), record PID
5. **Health check**: After worldserver starts, monitor `Server.log` for 60 seconds
   - If crash detected: alert via Discord, stop pipeline (do NOT auto-rollback blindly)
   - If clean startup: proceed

**Process ownership**:
- Track PIDs in `daemon_state.json` for all daemon-started processes
- Only manage processes the daemon started, unless `adopt_existing = true` in config
- Never kill user-started processes without explicit config

**SOAP integration**: Send `.server info` via SOAP to confirm server is responsive.

### 4.7 LogMonitor (Continuous While Server Running)

**Input**: `Server.log`, `DBErrors.log`
**Output**: Alerts via Discord, entries in `run_history.jsonl`

1. Tail `Server.log` for: crashes, fatal errors, unhandled exceptions
2. Tail `DBErrors.log` for: new SQL errors (dedup against known patterns)
3. Severity classification:
   - `info`: normal operational messages
   - `warning`: non-fatal issues, DB warnings
   - `critical`: crashes, fatal errors, unhandled exceptions
4. On critical error: alert via Discord with error text
5. On crash: restart **once** automatically, then:
   - If second crash within 10 minutes: **disable autonomous restart**, alert as crash loop
   - Require manual intervention to re-enable

**Dedup**: Same error signature suppressed for configurable window (default 30 minutes).

**Implementation**: Reuse patterns from `tools/auto_parse/engine.py` (LogTailer class).

### 4.8 GitManager (After Successful Build + Test)

**Input**: Modified files on disk
**Output**: Commit on per-run branch, optional PR

1. **Preflight**: Verify working tree is clean of non-daemon changes
   - If dirty with user changes: abort and alert, do NOT trample
2. Create isolated branch: `daemon/run-YYYYMMDD-HHMMSS-<taskid>`
3. `git add` specific modified files (never `git add -A`)
4. `git commit` with deterministic metadata:
   - Semantic message from Claude API
   - Task ID, spec ID, model used, run ID in commit body
5. `git push origin <branch> -u`
6. PR creation optional (controlled by `auto_pr` config)
7. Record commit hash + branch in `run_history.jsonl`

**Safety**:
- NEVER push to `master`
- Each run gets its own branch (no shared `daemon/auto` that resets)
- Per-run branches are disposable — user reviews and merges via PR

### 4.9 ReportWriter (Daily + Weekly)

**Input**: `state/run_history.jsonl`, `state/work_queue.json`, daemon state
**Output**: `cowork/outputs/daemon/standup_*.md`, `cowork/outputs/daemon/report_*.md`

1. **Daily (8 AM)**: Read daemon state, run history, queue status. Compile standup report including:
   - Completed runs (with outcomes)
   - Blocked runs (with reasons)
   - Pending review items
   - Failures requiring human action
2. **Weekly (Sunday 6 PM)**: Aggregate daily reports + git log. Compile weekly rollup.
3. After each completed daemon run: write structured summary to `cowork/outputs/daemon/`

**Do NOT read/write Central Brain in v1** — daemon reports are standalone.

## 5. Scheduling

| Schedule | Worker | Condition |
|----------|--------|-----------|
| Every 30 min | InboxTriage | Always |
| On queue trigger | CodeWriter | Only when user is away |
| After CodeWriter | Builder | Only when user is away |
| After CodeWriter (SQL) | SQLStager | Only when user is away |
| After Builder success | SQLApplier | Only when user is away |
| After SQLApplier | ServerManager.restart | Only when user is away |
| Continuous | LogMonitor | While worldserver is running |
| After build+test success | GitManager | Always |
| Daily 8 AM | ReportWriter.standup | Always |
| Sunday 6 PM | ReportWriter.weekly | Always |

**"User is away"** = EITHER:
1. No keyboard/mouse input for **20 minutes** (Win32 `GetLastInputInfo`), OR
2. Current local time is within **11:00 PM - 7:00 AM**

**Override**: `config.toml` toggle `force_autonomous = true` bypasses both checks.

**Worker serialization**: In v1, all state-changing jobs acquire a global process lock. No concurrent mutating workers.

## 6. Configuration (`config.toml`)

```toml
[daemon]
log_file = "logs/daemon/daemon.log"
state_dir = "tools/voxcore-daemon/state"
force_autonomous = false
dry_run = false
idle_threshold_minutes = 20
night_window_start = 23  # 11 PM
night_window_end = 7     # 7 AM

[api]
provider = "anthropic"
model_default = "claude-sonnet-4-6"
model_complex = "claude-opus-4-6"
max_retries = 3
circuit_breaker_threshold = 3  # consecutive failures before degraded mode
circuit_breaker_cooldown_minutes = 30
env_file = "tools/ai_studio/.env"
daily_token_budget = 500000
per_run_token_budget = 100000

[build]
preset = "x64-RelWithDebInfo"
ninja_jobs = 32
timeout_sec = 1200
max_build_retries = 2

[mysql]
host = "127.0.0.1"
port = 3306
user = "root"
password_env = "MYSQL_PASSWORD"
db_launcher = ""  # optional: path to MySQL launcher script

[server]
worldserver_exe = "out/build/x64-RelWithDebInfo/bin/RelWithDebInfo/worldserver.exe"
bnetserver_exe = "out/build/x64-RelWithDebInfo/bin/RelWithDebInfo/bnetserver.exe"
soap_host = "127.0.0.1"
soap_port = 7878
soap_user = "1"
soap_password_env = "SOAP_PASSWORD"
startup_timeout_sec = 90
health_check_sec = 60
adopt_existing_processes = false

[git]
base_branch = "master"
branch_prefix = "daemon/run"
auto_pr = false
never_push_master = true

[notify]
discord_webhook_env = "DISCORD_WEBHOOK_URL"
burnttoast_enabled = true

[schedules]
inbox_triage_minutes = 30
daily_standup_hour = 8
weekly_report_day = "sunday"
weekly_report_hour = 18
```

## 7. Autonomy Policy (`autonomy_policy.toml`)

```toml
[domains]
# Risk classification for spec domains
safe = ["tooling", "reports", "utilities", "non-gameplay-scripts", "documentation"]
review_required = ["gameplay-systems", "new-features", "db-schema-additions", "ui-changes"]
restricted = ["auth-account", "network-protocol", "persistence-layer", "build-system", "credentials"]

[code_writer]
max_files_per_task = 5
max_loc_per_task = 400
never_edit_paths = [
    "src/server/game/Accounts/",
    "src/server/game/Server/Protocol/",
    "src/server/database/Database/",
    "CMakeLists.txt",
    "cmake/",
    "config/",
    ".env",
]

[sql]
# SQL types that can be auto-applied
auto_apply = ["INSERT", "UPDATE", "DELETE", "REPLACE"]
# SQL types that always require human approval
require_approval = ["ALTER", "DROP", "CREATE", "TRUNCATE", "RENAME"]
# Databases that are restricted from autonomous changes
restricted_databases = ["auth"]

[time_windows]
# Autonomous mutation allowed during these windows
idle_threshold_minutes = 20
night_start_hour = 23
night_end_hour = 7
```

## 8. Safety & Crash Recovery

1. **Never push to master** — all daemon work goes to per-run branches
2. **Dirty-tree protection** — refuse to mutate code if repo has uncommitted non-daemon changes
3. **Pre-write backup** — backup original files to `state/backups/<run_id>/` before patching
4. **Post-build health check** — 60 seconds of log monitoring after restart
5. **Crash-loop prevention** — max 1 automatic restart, then disable and alert
6. **Max build retries** — 2 fix attempts, then stop and alert
7. **Audit trail** — every action logged in `run_history.jsonl` with timestamps and run IDs
8. **Discord alerts** — immediate notification on any failure (with severity classes)
9. **No deletion** — daemon never deletes files, only creates/modifies
10. **SQL failure isolation** — failed SQL goes to `sql/updates/failed/`, not retried
11. **No generic SQL rollback** — only explicit rollback companions are used
12. **Single-instance guard** — prevent multiple daemon copies from running
13. **Process ownership** — only manage processes the daemon started
14. **Secrets handling** — never log secrets, validate required env vars at startup, fail fast
15. **Atomic state writes** — all state files written via temp-write-and-rename with process lock
16. **Startup reconciliation** — on daemon start, inspect `active_run.json`, detect interrupted runs, mark as interrupted, do not resume mutating actions without policy check

## 9. Dry-Run Mode

When `dry_run = true` in config:
- All scheduling, analysis, and artifact generation runs normally
- InboxTriage: analyzes specs, writes analyses, but does NOT queue for implementation
- CodeWriter: generates patches but does NOT write to disk
- Builder: skipped entirely
- SQLStager: validates and classifies but does NOT move files
- SQLApplier: skipped entirely
- ServerManager: skipped entirely
- GitManager: skipped entirely
- LogMonitor: runs normally (read-only)
- ReportWriter: runs normally
- All actions logged with `[DRY-RUN]` prefix

## 10. Dependencies

```
anthropic>=1.0.0
apscheduler>=3.10.0
pymysql>=1.1.0
python-dotenv>=1.0.0
requests>=2.31.0        # Discord webhooks
```

All already available or trivially installable. No new system dependencies.

## 11. Installation & Startup

```bash
# Install
cd tools/voxcore-daemon
pip install -r requirements.txt

# Configure
cp config.toml.example config.toml
cp autonomy_policy.toml.example autonomy_policy.toml

# Run (foreground, dry-run for testing)
python daemon.py --dry-run

# Run (foreground, live)
python daemon.py

# Run (background, production)
pythonw daemon.py

# Run (Windows Task Scheduler, auto-start on boot)
# Action: pythonw.exe
# Arguments: C:\Users\atayl\VoxCore\tools\voxcore-daemon\daemon.py
# Start in: C:\Users\atayl\VoxCore
# Trigger: At system startup
```

## 12. Success Criteria

- [ ] Daemon runs for 24+ hours without crash
- [ ] Single-instance guard prevents duplicate daemons
- [ ] Processes at least 1 inbox spec autonomously (triage -> code -> build -> SQL -> restart)
- [ ] Sends Discord notification on completion (with severity classes)
- [ ] Stops pipeline after 2 failed build fix attempts and alerts
- [ ] Crash-loop prevention: max 1 restart, then disable + alert
- [ ] Dirty-tree protection: refuses to mutate when user has uncommitted changes
- [ ] Per-run branches: each task gets `daemon/run-YYYYMMDD-HHMMSS-<taskid>`
- [ ] Generates accurate daily standup report
- [ ] User reviews per-run branch PR and merges to master
- [ ] Dry-run mode produces all artifacts without mutations
- [ ] Startup reconciliation handles interrupted runs correctly
- [ ] Total human touchpoints per day: 1 (PR review)

## 13. Phased Implementation Plan (Architect-Approved)

### Phase 1 — Core Daemon Skeleton and Safety Rails (2 days)
**Owner**: Claude Code

Deliver:
- `daemon.py` (main loop, APScheduler, single-instance guard, signal handling)
- `config.toml` + `autonomy_policy.toml` (loading, validation)
- `state_manager.py` (atomic state reads/writes, file locking, run IDs)
- `claude_api.py` (Anthropic API wrapper, retry, circuit breaker, token budgets)
- `notify.py` (Discord webhook + BurntToast, notification classes)
- `idle_detector.py` (Win32 GetLastInputInfo + time-of-day window)
- `workers/base.py` (BaseWorker with dry-run support, logging, state updates)
- Prompt templates in `prompts/`
- Dry-run mode across all workers
- Startup reconciliation (`active_run.json` inspection)
- Secrets validation at startup

### Phase 2 — Observability Before Mutation (1-2 days)
**Owner**: Claude Code | **QA**: Antigravity/Gemini

Deliver:
- `workers/log_monitor.py` (tail + severity + dedup + crash-loop prevention)
- `workers/report_writer.py` (daily standup + weekly rollup)
- `workers/inbox_triage.py` (scan + analyze + risk_class + queue/handoff routing)
- Work queue management
- Handoff file generation
- No code writing yet — observability only

### Phase 3 — Safe Code Mutation Loop (2 days)
**Owner**: Claude Code | **QA**: Antigravity/Gemini

Deliver:
- `workers/code_writer.py` (bounded: 5 files, 400 LOC, risk-class gating)
- `workers/builder.py` (ninja build + 2 repair attempts + artifact capture)
- Dirty-tree protection (preflight checks)
- File backup before patching
- Dry-run and apply modes

### Phase 4 — Git Isolation (1 day)
**Owner**: Claude Code

Deliver:
- `workers/git_manager.py` (clean-tree checks, per-run branches, commit metadata)
- Branch creation: `daemon/run-YYYYMMDD-HHMMSS-<taskid>`
- Push + optional PR creation

### Phase 5 — Controlled Runtime Automation (2 days)
**Owner**: Claude Code | **Consult**: Grok Heavy (SQL policy)

Deliver:
- `workers/server_manager.py` (graceful SOAP stop, PID tracking, process ownership)
- `workers/sql_stager.py` (validate, classify DDL/DML, checksum, approval gate)
- `workers/sql_applier.py` (restricted: only `approved_for_apply`, checksum verify)
- Startup health checks
- Crash-loop prevention integration

### Phase 6 — Overnight Pilot (1-2 nights)
**Owner**: Claude Code | **QA**: Antigravity/Gemini

Deliver:
- Overnight unattended run
- Failure review + threshold tuning
- Rollback policy validation
- Edge case hardening based on results

**Total estimated timeline**: 10-14 days for full v1.

## 14. Architect Decisions (Resolved)

| Question | Decision |
|----------|----------|
| Update GitHub gists on schedule? | No for v1. Non-essential external side effects |
| Bridge-sync to cowork/? | Yes, one-way: write summaries to `cowork/outputs/daemon/` after each run |
| Web dashboard? | No for v1. Discord + file output sufficient |
| Sonnet vs Opus? | Sonnet default. Opus only for explicitly complex tasks within budget |
| Idle threshold? | 20 min idle OR 11 PM-7 AM window |
| Standalone repo? | No. Keep in `tools/voxcore-daemon/` for v1. Extract later if stable |
| Monetization? | REJECTED for v1 scope. Build VoxCore-first with clean internal boundaries |
