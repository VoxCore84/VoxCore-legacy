# Catalog Pilot Audit: MySQL DB Cache Mirrors

**Spec**: `TRIAD-CATALOG-PILOT-01`
**Date**: 2026-03-10
**Author**: Claude Code (Implementer)
**Status**: Intelligence gathering complete

---

## Executive Summary

The 1GB+ UniServerZ duplication between `runtime/` and `out/build/.../bin/RelWithDebInfo/` is caused by a **failed junction in `setup_junctions.bat`**. The script intends to create a junction but silently skips UniServerZ every run because bare `rmdir` cannot remove a non-empty directory. The build output copy is the **active** instance; the runtime copy is **stale dead weight** (8.5 GB, missing 3 databases that exist in the active copy). Deduplication is straightforward but requires a one-time manual migration.

---

## Question 1: What copies UniServerZ into the build output?

### Answer: Nothing copies it anymore. It was copied once and is now stuck.

**There is no CMake instruction that copies UniServerZ.** An exhaustive search of all `.cmake` and `CMakeLists.txt` files found zero references to UniServerZ or MySQL data directories. CMake only copies:
- `worldserver.conf.dist` / `bnetserver.conf.dist` (config templates)
- `bnetserver.cert.pem` / `bnetserver.key.pem` (TLS certs)
- Lua extension scripts (Eluna)
- `Directory.Build.props` (VS build metadata)

**The intended mechanism is `tools/build/setup_junctions.bat`** (called by `tools/build/build.bat` line 13 as a post-build step). This script creates Windows directory junctions from the build output to `runtime/` for 8 directories:

```
maps, vmaps, mmaps, dbc, gt, cameras, lua_scripts, UniServerZ
```

**7 of 8 junctions work correctly.** Verified via `dir /AL`:

| Directory | Junction? | Target |
|-----------|-----------|--------|
| Buildings | YES | `runtime\Buildings` |
| cameras | YES | `runtime\cameras` |
| dbc | YES | `runtime\dbc` |
| gt | YES | `runtime\gt` |
| lua_scripts | YES | `runtime\lua_scripts` |
| maps | YES | `runtime\maps` |
| mmaps | YES | `runtime\mmaps` |
| vmaps | YES | `runtime\vmaps` |
| **UniServerZ** | **NO** | **Real directory (fsutil: "not a reparse point")** |

### Root Cause: `rmdir` bug in `setup_junctions.bat`

```batch
for %%d in (maps vmaps mmaps dbc gt cameras lua_scripts UniServerZ) do (
    if exist "%BIN%\%%d" (
        rmdir "%BIN%\%%d" 2>nul          ← Line 16: bare rmdir
        if exist "%BIN%\%%d" (
            echo SKIP %%d — still exists in build dir, may be in use  ← Always hits this
        ) else (
            mklink /J "%BIN%\%%d" "%RT%\%%d"
        )
    ) else (
        mklink /J "%BIN%\%%d" "%RT%\%%d"
    )
)
```

**Problem**: Bare `rmdir` (without `/S /Q`) can only remove **empty directories** or **junction points**. UniServerZ is a real directory containing ~11 GB of MySQL data files. `rmdir` fails silently (stderr suppressed by `2>nul`), the directory still exists, and the script prints `SKIP UniServerZ — still exists in build dir, may be in use` and moves on.

**Why this works for other directories**: When the script runs for the first time on a fresh build, `maps/`, `vmaps/`, etc. don't exist yet in the build output (CMake doesn't create them). So the script takes the `else` branch and creates the junction directly. UniServerZ was already present in the build output from a prior manual setup (likely the initial UniServerZ installation before `setup_junctions.bat` existed), so it always hits the `rmdir` path and always fails.

### Origin of the build-output copy

The build-output UniServerZ directory predates the junction script. It was likely placed there manually during initial server setup (UniServerZ is a standalone MySQL distribution that was installed directly into the server's working directory). When `setup_junctions.bat` was later created to manage runtime data, it couldn't retroactively convert the existing real directory into a junction.

---

## Question 2: Is the build-output copy actively used?

### Answer: YES. The build-output copy is the ONLY active MySQL instance. The runtime copy is stale.

**Evidence:**

1. **`start_all.bat` (line 8-9)**:
   ```batch
   set "RUNTIME=%ROOT%\out\build\x64-RelWithDebInfo\bin\RelWithDebInfo"
   set "MYSQL_DIR=%RUNTIME%\UniServerZ\core\mysql"
   ```
   MySQL is launched from the build output path with `--datadir=%MYSQL_DIR%\data`.

2. **`start_mysql_uniserverz.bat` (line 3)** — hardcoded absolute path:
   ```batch
   set MYSQL_DIR=C:\Users\atayl\VoxCore\out\build\x64-RelWithDebInfo\bin\RelWithDebInfo\UniServerZ\core\mysql
   ```

3. **`apply_pending_sql.bat` (line 3-4)** — same build output path.

4. **`_optimize_db.bat` (line 12)** — same build output path.

5. **Size differential confirms divergence**:
   - `runtime/UniServerZ/` = **8.5 GB**
   - `out/build/.../UniServerZ/` = **11 GB**
   - Build output has 3 extra databases: `lorewalker_world/`, `wpp/`, `fusiongen/`
   - Build output InnoDB files are larger (more data written post-LoreWalker import)

6. **No script ever references `runtime/UniServerZ` directly.** The `runtime/` copy has no consumers. It is orphaned.

### What runs from where — complete picture

```
worldserver.exe     → out/build/.../bin/RelWithDebInfo/   (CWD set by start_all.bat /D flag)
bnetserver.exe      → out/build/.../bin/RelWithDebInfo/   (CWD set by start_all.bat /D flag)
mysqld_z.exe        → out/build/.../bin/RelWithDebInfo/UniServerZ/core/mysql/bin/
MySQL data (active) → out/build/.../bin/RelWithDebInfo/UniServerZ/core/mysql/data/
MySQL data (stale)  → runtime/UniServerZ/core/mysql/data/
worldserver.conf    → out/build/.../bin/RelWithDebInfo/worldserver.conf  (DataDir = ".")
Game data (maps etc)→ runtime/ via junctions
```

---

## Question 3: Architectural recommendation for deduplication

### Recommended approach: Promote `runtime/UniServerZ` to canonical, junction from build output

This follows the **existing architectural pattern** — every other large data directory (maps, vmaps, mmaps, dbc, gt, cameras, lua_scripts) is already junctioned from build output to runtime/. UniServerZ should be the same.

### One-time migration procedure

**Prerequisites**: MySQL must be STOPPED. No `mysqld_z.exe` process running.

```
Step 1: Stop MySQL
  taskkill /IM mysqld_z.exe /F

Step 2: Back up the active data (safety net)
  robocopy "out\build\...\UniServerZ" "out\build\...\UniServerZ_backup" /MIR

Step 3: Merge active data INTO runtime
  - Delete runtime\UniServerZ\core\mysql\data\ entirely
  - Move out\build\...\UniServerZ\core\mysql\data\ → runtime\UniServerZ\core\mysql\data\
  - Copy any other changed files (my.ini, binaries if updated)
  OR simpler: replace runtime\UniServerZ entirely with the build output copy:
  rmdir /S /Q runtime\UniServerZ
  move "out\build\...\UniServerZ" "runtime\UniServerZ"

Step 4: Remove the build-output copy
  rmdir /S /Q "out\build\...\UniServerZ"

Step 5: Create the junction
  mklink /J "out\build\...\UniServerZ" "runtime\UniServerZ"

Step 6: Verify
  dir /AL "out\build\...\bin\RelWithDebInfo\" | findstr UniServerZ
  → Should show: <JUNCTION> UniServerZ [C:\Users\atayl\VoxCore\runtime\UniServerZ]

Step 7: Start MySQL and verify databases
  start_all.bat (or start_mysql_uniserverz.bat)
  mysql -u root -padmin -e "SHOW DATABASES;"
  → Must show: auth, characters, world, hotfixes, roleplay, lorewalker_world, wpp, fusiongen
```

### Script fix: `setup_junctions.bat`

The current `rmdir` approach is fundamentally broken for non-empty directories. Recommended fix:

```batch
for %%d in (maps vmaps mmaps dbc gt cameras lua_scripts UniServerZ) do (
    REM Check if already a junction — leave it alone
    fsutil reparsepoint query "%BIN%\%%d" >nul 2>&1
    if not errorlevel 1 (
        echo OK %%d — already a junction
    ) else if exist "%BIN%\%%d" (
        echo ERROR %%d — real directory exists, cannot auto-junction. Manual migration needed.
    ) else (
        mklink /J "%BIN%\%%d" "%RT%\%%d"
        if errorlevel 1 (echo FAIL %%d) else (echo JUNCTION %%d)
    )
)
```

This replaces the dangerous `rmdir` approach with explicit detection:
- If it's already a junction: skip (no-op, correct state)
- If it's a real directory: warn loudly (never silently skip)
- If it doesn't exist: create the junction

### Alternative considered and rejected: Stop the CMake copy

There is no CMake copy to stop. The duplication is a legacy artifact, not an active copy mechanism. The only fix is the one-time migration above.

### Alternative considered and rejected: Symlink instead of junction

Windows junctions (`mklink /J`) are the correct choice over symlinks (`mklink /D`) because:
- Junctions don't require elevated privileges
- Junctions work transparently with all applications (including MySQL `--datadir`)
- The existing architecture already uses junctions for all other directories
- Junctions are resolved by the filesystem, not the application

---

## Disk savings

| Location | Current size | After dedup |
|----------|-------------|-------------|
| `runtime/UniServerZ/` | 8.5 GB | **11 GB** (receives active data) |
| `out/build/.../UniServerZ/` | 11 GB | **0 bytes** (junction, no space) |
| **Total** | **19.5 GB** | **11 GB** |
| **Savings** | | **~8.5 GB** |

---

## Risk assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| MySQL data corruption during move | HIGH | Step 2 creates a full backup before any changes |
| Scripts with hardcoded build-output paths | LOW | All scripts reference `%RUNTIME%\UniServerZ` which resolves through the junction transparently |
| `start_mysql_uniserverz.bat` hardcoded absolute path | LOW | Path resolves through junction. Optional: update to use relative path |
| Junction broken by `rmdir /S /Q` in other scripts | MEDIUM | Search codebase for any `rmdir` targeting the build output root. None found beyond `setup_junctions.bat` |
| Build system overwrites junction | NONE | CMake does not touch UniServerZ. Only `setup_junctions.bat` does, and the fix above makes it safe |

---

## Files referenced in this audit

| File | Lines | Role |
|------|-------|------|
| `tools/build/setup_junctions.bat` | 1-39 | Junction creation (UniServerZ on line 14, rmdir bug on line 16) |
| `tools/build/build.bat` | 13 | Calls setup_junctions.bat post-build |
| `tools/shortcuts/start_all.bat` | 8-9, 26-31, 61 | Sets RUNTIME path, launches MySQL and worldserver from build output |
| `tools/shortcuts/start_mysql_uniserverz.bat` | 3, 20-25 | Hardcoded path to build output UniServerZ |
| `tools/shortcuts/apply_pending_sql.bat` | 3-4, 30 | Uses mysql.exe from build output UniServerZ |
| `tools/_optimize_db.bat` | 12 | Uses mysql.exe from build output UniServerZ |
| `cmake/platform/win/settings.cmake` | 10 | Sets CMAKE_RUNTIME_OUTPUT_DIRECTORY |
| `src/server/worldserver/CMakeLists.txt` | 62, 71 | Copies worldserver.conf.dist only (no UniServerZ) |
| `src/server/bnetserver/CMakeLists.txt` | 51-52, 60, 70 | Copies certs and bnetserver.conf.dist only |

---

## Session 143 Updates (2026-03-11)

Several items identified in this audit were resolved during the desktop/batch cleanup session:

| Item | Original Finding | Resolution |
|------|-----------------|------------|
| `start_mysql_uniserverz.bat` hardcoded absolute path (line 86-89 above) | Hardcoded `C:\Users\atayl\VoxCore\...` | **FIXED** — now uses `%~dp0..\..` relative resolution |
| `apply_pending_sql.bat` always targeting `world` DB (line 93 above) | Every SQL file piped to `world` regardless of DB | **FIXED** — parses DB name from `YYYY_MM_DD_NN_<db>.sql` filename convention |
| `_optimize_db.bat` hardcoded paths (line 94 above) | Listed as using build output paths | **Already portable** — uses `%~dp0..` relative resolution (was never broken) |
| `setup_junctions.bat` bare `rmdir` bug (core finding) | Bare `rmdir` silently failed on non-empty dirs | **ALREADY FIXED** — current code uses `fsutil reparsepoint query` check, no bare `rmdir` |

**~~Still pending~~: RESOLVED.** Session 143 verified via `fsutil reparsepoint query` that the build-output UniServerZ **IS ALREADY A JUNCTION** pointing to `runtime\UniServerZ`. The migration was completed at some point between the audit (Mar 10) and verification (Mar 11). The 11 GB data lives only in `runtime/UniServerZ/` — zero duplication. All 5 VoxCore databases confirmed present (auth, characters, world, hotfixes, roleplay) plus fusiongen, lorewalker_world, wpp.

**Additional discovery**: The running MySQL was actually MySQL Server 8.0 (system service at `C:\Program Files\MySQL\MySQL Server 8.0\`), NOT UniServerZ. MySQL 8.0 only had system databases — VoxCore's databases are exclusively in UniServerZ. The system MySQL 8.0 service was stopped and UniServerZ started for 66337 pipeline work.

---

*Report complete. Ready for Antigravity ingestion.*
