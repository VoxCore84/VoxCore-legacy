# Antigravity Optimization — 3-Pass QA/QC Audit

**Date**: 2026-03-11 (Session 142)
**Auditor**: Claude Opus 4.6 (Claude Code)
**Scope**: Full audit of all Antigravity optimization work from session 142
**Method**: 3 parallel agents, each performing an independent pass

---

## Pass 1: CORRECTNESS (Syntax, Logic, Values)

Every modified file was re-read and verified for syntax errors, wrong enum values, and logic bugs.

### Results: 10 PASS, 1 FAIL

| # | File | Verdict | Notes |
|---|------|---------|-------|
| 1 | `settings.json` | PASS | Valid JSON, 49 keys, no duplicates |
| 2 | `watchdog.py` | PASS | Correct enums (terminal=3, artifact=2, planning=1), correct DB path, sound protobuf logic |
| 3 | `optimize_antigravity.py` | **FAIL** | Line 184: `TURBO_AGENT_PREFS_B64` undefined — should be `OPTIMAL_AGENT_PREFS_B64`. Runtime NameError when `--fix` is used with missing agentPreferences key |
| 4 | `context_preload.py` | PASS | Correct source paths, reasonable fallback logic |
| 5 | `launch_antigravity.bat` | PASS | Correct step ordering, all paths verified on disk |
| 6 | `.agentrules` | PASS | Well-formed, not truncated |
| 7 | `autonomy.md` | PASS | Clear permission scope |
| 8 | `execution-style.md` | PASS | Correct hardware specs |
| 9 | `voxcore-context.md` | PASS | Correct DB list, coordination paths |
| 10 | `argv.json` | PASS | Valid JSON, correct flags |
| 11 | `mcp_config.json` | PASS | Valid JSON, all paths verified |

### Bug Fixed

**`optimize_antigravity.py` line 184**: Changed `TURBO_AGENT_PREFS_B64` to `OPTIMAL_AGENT_PREFS_B64`. This was a latent runtime bug — the old constant name was left over from when the script was first written with a 2-setting blob. The rename to `OPTIMAL_AGENT_PREFS_B64` (when it was upgraded to 5 settings) missed this one reference.

---

## Pass 2: COMPLETENESS (Gaps & Missing Optimizations)

### P0 — Fixed During Audit

| Issue | Action Taken |
|-------|-------------|
| `settings.json` had `searchMaxWorkspaceFileCount: 5000` — too low for VoxCore's ~15K+ files | **Restored to 15000** |
| `settings.json` had `persistentLanguageServer: false` — clangd restarted every session | **Restored to true** |
| `argv.json` missing Electron background throttling flags | **Added `disable-renderer-backgrounding` and `disable-background-timer-throttling`** |
| `argv.json` missing V8 optimization flags | **Added `--optimize-for-size --lite-mode` to js-flags** |
| State DB using DELETE journal mode (blocking reads/writes) | **Switched global state.vscdb to WAL mode** |
| `settings.json` missing git, timeline, word suggestion settings | **Added 7 new settings** (see below) |

### New settings.json entries added:

```json
"git.autorefresh": false,
"git.decorations.enabled": false,
"timeline.enabled": false,
"editor.wordBasedSuggestions": "off",
"extensions.ignoreRecommendations": true,
"terminal.integrated.gpuAcceleration": "on",
"workbench.localHistory.enabled": false
```

### P1 — Gaps Identified, Not Yet Fixed

| # | Gap | Severity | Why Not Fixed |
|---|-----|----------|---------------|
| 1 | Watchdog monitors 5 of 7 known permissions (missing browser JS + secure mode) | MEDIUM | Requires adding 2 new sentinel key checks — should be done next session |
| 2 | No settings.json drift detection in watchdog | HIGH | Requires hash-based comparison + backup restore — non-trivial |
| 3 | No argv.json regression monitoring | MEDIUM | Updates overwrite argv.json — needs check in optimizer |
| 4 | No bundled extension re-disable automation | HIGH | 37+ disabled extensions restored on every update — needs manifest-driven script |
| 5 | `.agentrules` missing hotfixes schema rules | MEDIUM | One-liner addition: "No item_template, use hotfixes.item_sparse" |
| 6 | ~26 more bundled extensions could be disabled | MEDIUM | CSS, HTML, Emmet, Docker, IPynb, unused themes, remote-WSL/SSH/DevContainers |
| 7 | Watchdog has no PID file / duplicate prevention | LOW | Can run multiple instances if launcher called twice |
| 8 | MCP pre-warm `taskkill` by WINDOWTITLE is fragile | LOW | May not match on all Windows versions |

---

## Pass 3: 100% AUTHORITY (What Would I Do Differently?)

Full 26-proposal analysis saved separately at:
`AI_Studio/Reports/Audits/2026-03-11__ANTIGRAVITY_PASS3_100_AUTHORITY.md`

### Top 10 Proposals by Impact

| # | Proposal | Impact | Difficulty | Status |
|---|----------|--------|------------|--------|
| 1 | Fix settings.json discrepancy (searchMax/persistentLS) | HIGH | TRIVIAL | **DONE** (this audit) |
| 2 | Switch state DB to WAL mode | HIGH | LOW | **DONE** (this audit) |
| 3 | Add argv.json V8+Electron flags | HIGH | LOW | **DONE** (this audit) |
| 4 | Add missing settings.json entries (7 new) | MEDIUM | LOW | **DONE** (this audit) |
| 5 | Fix optimize_antigravity.py NameError | HIGH | TRIVIAL | **DONE** (this audit) |
| 6 | Disable 26 more bundled extensions | HIGH | MEDIUM | PENDING — needs manifest script first |
| 7 | Build auto-re-disable script (`redisable_extensions.py`) | HIGH | LOW | PENDING — prevents update regressions |
| 8 | Merge 3 rules files into .agentrules (~55% token savings) | MEDIUM | LOW | PENDING |
| 9 | Update .agentrules to reference preload_context.md | MEDIUM | LOW | PENDING |
| 10 | Above Normal process priority for Antigravity | MEDIUM | LOW | PENDING — add `/ABOVENORMAL` to launch script |

### Projected Impact (if all "NOW" + "NEXT" items implemented)

| Metric | Before Audit | After Audit | After All Proposals |
|--------|-------------|-------------|---------------------|
| Enabled bundled extensions | 67 | 67 | ~41 |
| State DB journal mode | DELETE | **WAL** | WAL |
| Electron background throttling | Active | **Disabled** | Disabled |
| V8 optimization | None | **lite-mode + optimize-for-size** | Same |
| Settings completeness | 40 settings | **47 settings** | ~50 settings |
| searchMaxWorkspaceFileCount | 5000 (broken) | **15000** (correct) | 15000 |
| persistentLanguageServer | false (broken) | **true** (correct) | true |
| System prompt tokens/turn | ~850 | ~850 | ~380 (after merge) |

---

## Changes Applied During This Audit

### Files Modified

1. **`tools/antigravity/optimize_antigravity.py`** line 184
   - `TURBO_AGENT_PREFS_B64` → `OPTIMAL_AGENT_PREFS_B64` (bug fix)

2. **`AppData/Roaming/Antigravity/User/settings.json`**
   - `searchMaxWorkspaceFileCount`: 5000 → 15000 (restored)
   - `persistentLanguageServer`: false → true (restored)
   - Added 7 new settings (git.autorefresh, git.decorations, timeline, wordBasedSuggestions, ignoreRecommendations, gpuAcceleration, localHistory)

3. **`~/.antigravity/argv.json`**
   - Added `--optimize-for-size --lite-mode` to js-flags
   - Added `disable-renderer-backgrounding: true`
   - Added `disable-background-timer-throttling: true`

4. **`AppData/Roaming/Antigravity/User/globalStorage/state.vscdb`**
   - `journal_mode`: DELETE → WAL

5. **Memory files updated**
   - `MEMORY.md`: Session 142 entry, Antigravity settings line, topic file index, duplicate lines removed
   - `recent-work.md`: Session 142 entry added
   - `antigravity-optimization.md`: Written earlier in session (complete reference)

---

## Known Limitations (Cannot Fix)

These are architectural limitations of Antigravity/Gemini that no configuration can address:

| Limitation | Why |
|-----------|-----|
| **Gemini API latency** | Server-side, Google infrastructure |
| **Model RLHF caution** | Gemini may still say "I'll now run X" even with EAGER terminal — the IDE just won't stop and wait |
| **Electron overhead** | VS Code fork, inherently heavier than a CLI |
| **MCP tool confirmation UI** | MCP calls have their own approval UI separate from terminal policy. No global auto-approve setting in source. Reverse-engineered from `jetskiAgent/main.js` (11.2 MB) |
| **Extension re-enable on update** | Antigravity installer restores `.disabled` extensions. Requires external automation |

---

## Audit Conclusion

**Session 142 optimization work was solid** — the core wins (37 extensions disabled, file watchers configured, telemetry off, 5 permissions patched, MCP cold-start eliminated) are correct and well-implemented.

**This QA audit found and fixed**:
- 1 runtime bug (NameError in optimizer)
- 2 over-aggressive setting changes (searchMaxWorkspaceFileCount + persistentLanguageServer)
- 4 missing Electron/V8 flags
- 7 missing settings.json entries
- 1 state DB mode change (DELETE → WAL)

**Remaining work** (8 items in P1 backlog): The highest priorities are the auto-re-disable script for post-update resilience (prevents 37+ extensions from being restored) and adding browser JS + secure mode monitoring to the watchdog.
