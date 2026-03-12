---
reviewed_spec: SPEC_VoxCore_Daemon_Autonomous_Pipeline.md
reviewer: ChatGPT (Architect)
date: 2026-03-12
model: gpt-5.4
---

# Architect Review — SPEC: VoxCore Daemon — Autonomous DevOps Pipeline

## Overall Assessment

This is directionally strong and solves a real bottleneck: too many human gates for a local AI-assisted dev loop. The proposed daemon is a good fit for VoxCore’s repack workflow, especially because the environment is single-machine, Windows-based, and under one operator’s control.

However, as written, it is **too aggressive in scope for a P0 week-1 implementation** and has a few unsafe assumptions around SQL rollback, git branch handling, and autonomous code generation. I am **approving the initiative with modifications**, and I am splitting several parts into phased delivery so we do not build an unreliable “full autonomy” system before the observability and safety rails exist.

---

# Initiative-by-Initiative Review

## 1. Persistent Daemon Core (`daemon.py`, scheduler, config, state)
**APPROVED**

### Decision
Build the daemon core as the new top-level scheduler.

### Required constraints
- Use a **single-process daemon with worker serialization** for v1. Do not run multiple mutating workers concurrently.
- APScheduler is acceptable, but all state-changing jobs must acquire a **global file lock / process lock**.
- State files must be treated as **append-safe and crash-safe**:
  - `run_history.jsonl` instead of only `run_history.json`
  - `work_queue.json` may remain JSON, but writes must be atomic
  - `daemon_state.json` should be rewritten atomically
- Add:
  - `seen_specs.json`
  - `active_run.json`
  - `last_good_state.json`

### Why
The current spec assumes clean sequential execution, but background schedulers often overlap. For a local dev machine controlling git, SQL, and server processes, overlapping actions are unacceptable.

### Phase owner
**Claude Code**

---

## 2. Direct Anthropic API Integration (`claude_api.py`)
**APPROVED**

### Decision
Use direct Anthropic API calls instead of Claude Code CLI for daemon operation.

### Required constraints
- All prompts must be **template-driven and versioned** under:
  - `tools/voxcore-daemon/prompts/`
- Log:
  - model used
  - token counts if available
  - prompt template version
  - task ID
- Add a **hard token budget per task** in config.
- Add a **circuit breaker**:
  - if 3 API failures occur in a row, daemon enters degraded mode and only performs non-AI tasks until manual reset or cooldown expiry.

### Why
Direct API is the right architectural choice here, but it must be auditable and cost-bounded.

### Phase owner
**Claude Code**

---

## 3. InboxTriage Worker
**MODIFIED**

### Changes required
Approve triage automation, but **do not allow it to update Central Brain automatically in v1**.

#### Revised behavior
- Scan inbox
- Analyze new specs
- Write analysis to `state/spec_analyses/`
- Route:
  - **S/M and implementation-ready** → queue candidate
  - **L/XL or ambiguous** → handoff file
- Queue insertion must require a **policy gate**:
  - only specs tagged or classified as safe domains may auto-queue in v1
  - examples: tooling, reports, non-gameplay scripts, isolated utilities
  - gameplay systems, DB schema changes, auth/account logic, networking, and core engine behavior require manual approval

### Why
The current spec is too permissive. “Implementation-ready + complexity <= M” is not enough. A small but dangerous change can still break a repack.

### Additional requirement
Add a `risk_class` field:
- `safe`
- `review-required`
- `restricted`

### Phase owner
**Claude Code**
### QA owner
**Antigravity/Gemini**

---

## 4. CodeWriter Worker
**MODIFIED**

### Changes required
Approve autonomous patch generation **only for bounded file scopes and approved risk classes**.

#### Revised rules
- CodeWriter may only modify:
  - files explicitly listed by triage
  - plus directly adjacent files approved by a dependency-expansion rule
- Max files changed automatically in v1:
  - **5 files**
- Max lines changed automatically in v1:
  - **400 LOC total**
- Any task exceeding either threshold is converted to a handoff.
- No autonomous edits to:
  - auth/account systems
  - network protocol handling
  - persistence layer abstractions
  - build system root files
  - deployment credentials/config secrets
- SQL-producing tasks must emit SQL into a **staging folder** first, not directly into pending apply.

### Why
This is the highest-risk component. We want “autonomous patching” but not “autonomous architecture drift.”

### Additional requirement
Patch application format should prefer:
- unified diffs / structured file blocks
- validation before write
- backup of original file in temp workspace for the active run

### Phase owner
**Claude Code**
### QA owner
**Antigravity/Gemini**

---

## 5. Builder Worker
**APPROVED**

### Modifications
- Use configured `ninja_jobs`, not hardcoded `-j32`
- Add build mode detection:
  - incremental build first
  - optional clean rebuild only on repeated linker/state issues
- Build retries reduced from **3 to 2 autonomous fix attempts** in v1
  - initial build
  - fix attempt 1
  - fix attempt 2
  - then stop and alert

### Why
Three autonomous repair loops is too much for local code mutation; it increases drift and token burn.

### Additional requirement
Store:
- raw build log
- parsed compile errors
- fix-attempt artifacts

### Phase owner
**Claude Code**

---

## 6. SQLApplier Worker
**MODIFIED**

### Major architectural correction
The current SQL plan is **not approved as written**.

#### Problems
- “No prompt. Just apply.” is too risky.
- “Restore SQL backup” is underspecified and often not truly reversible.
- Filename-based DB targeting is fine, but execution policy needs stronger controls.

#### Revised design
- Split SQL into two stages:
  1. **SQLStager**
     - validates SQL file naming
     - classifies DB target
     - runs dry checks where possible
     - records checksum
  2. **SQLApplier**
     - only applies SQL that is explicitly marked `approved_for_apply`
- In v1, autonomous apply is allowed only for:
  - idempotent data updates
  - inserts/updates/deletes on known content tables
- Autonomous apply is **not allowed** for:
  - schema-altering DDL
  - destructive operations
  - account/auth DB changes
  - migrations without rollback script
- Every applied SQL file must have:
  - target DB
  - checksum
  - run ID
  - optional rollback companion if non-idempotent

### Rollback decision
Do **not** promise generic SQL rollback. That is not credible.

Instead:
- For v1, rollback policy is:
  - if SQL is idempotent content data and server fails after apply, alert and stop
  - if a rollback companion exists, it may be executed
  - otherwise require manual intervention

### Why
Database rollback is the weakest part of the original spec. We must not overstate safety.

### Phase owner
**Claude Code**
### Security/research consult
**Grok Heavy**

---

## 7. ServerManager Worker
**MODIFIED**

### Changes required
Approve automated start/stop/restart, but **reject force-kill as the default stop path**.

#### Revised behavior
1. Attempt graceful stop first:
   - SOAP shutdown if available
   - console close / process terminate
2. Use `taskkill /F` only as fallback after timeout
3. MySQL startup must not assume UniServerZ specifically unless configured
   - make DB launcher configurable
4. Health check should include:
   - process alive
   - SOAP responsive
   - no fatal log patterns during warmup window

### Additional requirement
Track PIDs in `daemon_state.json` and verify the daemon only manages processes it started, unless explicitly configured to adopt existing ones.

### Why
Blindly killing `worldserver.exe` and `bnetserver.exe` can interfere with a user-run session.

### Phase owner
**Claude Code**

---

## 8. LogMonitor Worker
**APPROVED**

### Modifications
- Reuse `auto_parse` patterns where practical
- Add severity levels:
  - info
  - warning
  - critical
- Add dedup window:
  - same error signature should not spam Discord repeatedly
- On crash:
  - restart only once automatically in v1
  - repeated crash loops should disable autonomous restart and alert

### Why
Good initiative, but crash-loop protection is mandatory.

### Phase owner
**Claude Code**
### QA owner
**Antigravity/Gemini**

---

## 9. GitManager Worker
**MODIFIED**

### Major correction
The current branch strategy is unsafe as written.

#### Problem
`git checkout -B daemon/auto` resets the branch each cycle. That can destroy prior daemon work or make audit/review confusing.

#### Revised branch strategy
Use one of these:
- preferred: **one branch per run**
  - `daemon/run-YYYYMMDD-HHMMSS-<taskid>`
- optional later: rolling branch plus PR stacking

#### Revised behavior
- Create isolated branch from configured base branch
- Stage only explicit files
- Commit with deterministic metadata:
  - task ID
  - spec ID
  - model
  - run ID
- Push branch
- PR creation optional, but branch push is enough for v1

### Additional requirement
Before branch creation:
- verify working tree is clean
- if dirty and not daemon-owned changes, abort and alert

### Why
A local developer machine will often have in-progress changes. The daemon must never trample them.

### Phase owner
**Claude Code**

---

## 10. ReportWriter Worker
**APPROVED**

### Modifications
- Daily and weekly reports are fine
- Do not make report generation depend on “Central Brain” mutation in v1
- Reports should consume:
  - daemon state
  - run history
  - git metadata
  - queue status
- Output should include:
  - completed runs
  - blocked runs
  - pending review items
  - failures requiring human action

### Phase owner
**Claude Code**

---

## 11. Idle Detection / User-Away Gating
**MODIFIED**

### Decision
Idle detection is approved, but **time-of-day policy must be added**.

#### Final policy
Autonomous mutating actions are allowed when either:
1. user idle for **20 minutes**, or
2. current local time is within **11:00 PM–7:00 AM**

`force_autonomous = true` remains as override.

### Why
15 minutes is slightly too aggressive on a dev workstation. Night window is a practical complement.

### Phase owner
**Claude Code**

---

## 12. Notifications (Discord + BurntToast)
**APPROVED**

### Modifications
- Discord is primary
- BurntToast only for local informational notices, not critical-only
- Add notification classes:
  - success
  - warning
  - failure
  - action-required

### Phase owner
**Claude Code**

---

## 13. Windows Service / Background Startup
**APPROVED**

### Modifications
- For v1, prefer **Task Scheduler at startup** over Windows Service
- Service packaging can come later
- Add a single-instance guard so multiple daemon copies cannot run

### Why
Task Scheduler is simpler and more debuggable on the target machine.

### Phase owner
**Claude Code**

---

## 14. Monetization / Project-Agnostic Extraction
**REJECTED for current scope**

### Reason
This is not a P0 concern for VoxCore delivery. Designing for future SaaS extraction on day 1 will distort the implementation and slow down the real objective.

### Replacement decision
Build this as **VoxCore-first**, with clean internal boundaries where convenient, but do not split into a productized framework yet.

### Phase owner
None for v1

---

# Phase Ordering Review

## Original plan
The original 7-day plan is optimistic and incorrectly sequences some risky components too early.

## Approved revised phases

### Phase 1 — Core Daemon Skeleton and Safety Rails
**Owner:** Claude Code  
**Duration:** 2 days

Deliver:
- `daemon.py`
- config loading
- scheduler
- single-instance guard
- atomic state writes
- run IDs
- prompt templates
- API wrapper
- notification plumbing
- idle/time-window gating
- dry-run mode

### Phase 2 — Observability Before Mutation
**Owner:** Claude Code  
**QA:** Antigravity/Gemini  
**Duration:** 1–2 days

Deliver:
- LogMonitor
- ReportWriter
- InboxTriage
- queueing
- handoff generation
- no code writing yet

### Phase 3 — Safe Code Mutation Loop
**Owner:** Claude Code  
**QA:** Antigravity/Gemini  
**Duration:** 2 days

Deliver:
- CodeWriter with file/LOC/risk limits
- Builder with 2 repair attempts
- artifact capture
- dry-run and apply modes

### Phase 4 — Git Isolation
**Owner:** Claude Code  
**Duration:** 1 day

Deliver:
- clean-tree checks
- per-run branch creation
- commit/push
- metadata in commit messages

### Phase 5 — Controlled Runtime Automation
**Owner:** Claude Code  
**Consult:** Grok Heavy for SQL policy  
**Duration:** 2 days

Deliver:
- ServerManager
- SQLStager
- restricted SQLApplier
- startup health checks
- crash-loop prevention

### Phase 6 — Overnight Pilot
**Owner:** Claude Code  
**QA:** Antigravity/Gemini  
**Duration:** 1–2 nights

Deliver:
- overnight unattended run
- failure review
- threshold tuning
- rollback policy validation

---

# Budget / Feasibility Review

## Engineering feasibility
**Feasible**, but not in the original “everything in 7 days” form unless quality is sacrificed.

## Revised estimate
- **MVP safe daemon:** 7–10 days
- **Full v1 with controlled SQL/server automation:** 10–14 days

## Token/cost feasibility
Acceptable if bounded.

### Required controls
- Sonnet default for:
  - triage
  - compile-fix loops
  - reports
- Opus only for:
  - explicitly marked complex code-writing tasks
  - max configurable daily spend cap
- Add:
  - daily token budget
  - per-run token budget
  - model fallback policy

---

# Open Questions — Architect Decisions

## 1. Should the daemon also update GitHub gists (DB Report, Changelog, Open Issues) on a schedule?
**Decision: No for v1.**

Reason: non-essential, external side effects, and not part of the core unattended dev loop. Revisit after stable overnight operation.

---

## 2. Should the daemon bridge-sync to `cowork/` automatically after each cycle?
**Decision: Yes, but one-way and limited.**

### Rule
After each completed run, write a structured summary to `cowork/outputs/daemon/`.

Do **not** perform broad bidirectional sync or mutate cowork-managed inputs automatically in v1.

---

## 3. Should there be a web dashboard (Flask) for monitoring daemon state, or is Discord + file output sufficient?
**Decision: Discord + file output is sufficient for v1.**

Add a simple optional local HTML status page later if needed, but no Flask server in the first implementation.

---

## 4. Should the daemon use Sonnet for triage and Opus for code writing, or Opus for everything?
**Decision: Sonnet by default, Opus selectively.**

### Final model policy
- **Sonnet**
  - triage
  - reports
  - compile error fixing
  - small/medium bounded code tasks
- **Opus**
  - only for tasks classified complex and explicitly within budget/policy

Not Opus-for-everything.

---

## 5. What's the right idle threshold — 15 minutes? 30? Or should it be time-of-day based?
**Decision: 20 minutes idle OR autonomous window 11 PM–7 AM.**

This replaces the 15-minute-only rule.

---

## 6. Should the daemon be packaged as a standalone repo (`VoxCore84/voxcore-daemon`) from day 1 for eventual monetization?
**Decision: No.**

Keep it inside the main repo under `tools/voxcore-daemon/` for v1. Extract later only if it proves stable and reusable.

---

# Missing Initiatives / Risks Identified

## A. Dirty Working Tree Protection
**Missing and required**
The daemon must refuse to mutate code if the repo has uncommitted non-daemon changes.

### Action
Add preflight repo cleanliness checks before CodeWriter and GitManager.

---

## B. Dry-Run / Simulation Mode
**Missing and required**
Need a mode that performs all scheduling, analysis, and artifact generation without mutating source, DB, or processes.

### Action
Add `dry_run = true` config and support it across all workers.

---

## C. Secrets Handling
**Missing and required**
The spec references `.env`, MySQL password env, Discord webhook env, but no policy exists.

### Action
- never log secrets
- validate required env vars at startup
- fail fast with actionable error

---

## D. File Locking / Atomicity
**Missing and required**
JSON state files can corrupt on crash or concurrent write.

### Action
Use atomic temp-write-and-rename and a process-level lock.

---

## E. Human Approval Policy Matrix
**Missing and required**
Need explicit policy for what can be autonomous.

### Action
Create `autonomy_policy.toml` with:
- allowed domains
- restricted paths
- SQL classes
- file/LOC thresholds
- time windows

---

## F. Test Harness / Replay Fixtures
**Missing and required**
Need deterministic test inputs for triage, build-fail parsing, and log monitoring.

### Action
Add fixtures for:
- sample inbox specs
- compile error logs
- server crash logs
- SQL files

---

## G. Branch / Run Traceability
**Missing and required**
Need consistent run IDs across logs, commits, notifications, and artifacts.

### Action
Every run gets a unique `run_id`.

---

## H. Process Ownership Safety
**Missing and required**
Daemon should not kill user-started processes unless configured.

### Action
Track adopted vs daemon-started processes.

---

## I. Recovery After Reboot / Crash
**Missing and required**
Need startup reconciliation.

### Action
On daemon start:
- inspect `active_run.json`
- detect interrupted run
- mark as interrupted
- do not resume mutating actions automatically without policy check

---

# Summary Verdict

## Final Verdict
**MODIFIED — APPROVED FOR IMPLEMENTATION**

The daemon initiative is strategically correct and should proceed, but only with the safety, scope, and sequencing changes above. The biggest corrections are:

- no generic SQL rollback claims
- no reset-style shared daemon branch
- bounded autonomous code writing only
- observability before mutation
- stronger repo/process safety checks
- Sonnet default, Opus selective
- 20-minute idle or 11 PM–7 AM autonomy window

---

# New Action Items

## For Claude Code
1. Revise spec into **TRIAD-DAEMON-V2** with all architect decisions incorporated.
2. Add phased implementation plan reflecting the approved order.
3. Add `autonomy_policy.toml`.
4. Replace `run_history.json` with `run_history.jsonl`.
5. Replace shared `daemon/auto` branch strategy with per-run branches.
6. Split SQL flow into `SQLStager` + restricted `SQLApplier`.
7. Add dry-run mode and dirty-tree protection.
8. Add startup reconciliation behavior for interrupted runs.

## For Antigravity/Gemini
1. Prepare QA checklist for:
   - idle gating
   - crash-loop prevention
   - dirty-tree refusal
   - branch isolation
   - log dedup
   - dry-run correctness

## For Grok Heavy
1. Review SQL safety classification and rollback companion policy.
2. Review process-control and local service management risks on Windows.

If you want, I can also produce the **revised V2 spec text** in final form for Claude Code to implement directly.