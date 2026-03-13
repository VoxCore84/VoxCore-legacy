# CreatureCodex v1.0.0 — Pre-Launch Audit Request

## For: ChatGPT (GPT-5.4)
## From: VoxCore Development Team (Claude Code + Human Operator)
## Date: 2026-03-13
## Purpose: Comprehensive pre-launch review before public distribution

---

## PART 1: THE PROBLEM

### What This App Solves

In TrinityCore-based World of Warcraft private servers ("repacks"), creatures don't fight. They stand there and auto-attack because the database table that assigns spells to creatures (`creature_template_spell`) is mostly empty, and there's no AI scripting (`smart_scripts`) telling them when to cast.

Getting this data is hard because:

1. **It doesn't ship in game files.** Creature spell assignments are server-side data. The only way to know what spells a creature should cast is to observe it on Blizzard's live retail servers.

2. **The 12.x WoW client broke traditional methods.** The combat log (`COMBAT_LOG_EVENT_UNFILTERED`) — previously the gold standard for capturing creature casts — is effectively dead due to cross-addon GUID lockdowns, taint injection on spell IDs/GUIDs, and `issecretvalue()` opaque userdata. Traditional addons that read spell data silently fail.

3. **Instant casts are invisible to the client.** `UnitCastingInfo`/`UnitChannelInfo` only see spells with visible cast bars. Instant casts, triggered spells, and many boss mechanics never appear in client APIs.

4. **The traditional sniffing pipeline requires expertise.** Ymir (packet sniffer) → WowPacketParser produces the best data, but turning raw packet captures into usable SQL requires offline parsing, manual review, and hand-written queries. The tools have minimal documentation and no hand-holding.

### What CreatureCodex Does

CreatureCodex is a three-layer creature spell capture tool:

- **Layer 1: Client-side visual scraper** (works everywhere — retail, repacks, any server)
  - Polls cast bars at 10Hz, scans nameplate auras at 5Hz
  - Wraps every access in taint-safe helpers for 12.x compatibility
  - Records spell name, school, creature entry, HP%, timestamps

- **Layer 2: Server-side C++ hooks** (TrinityCore only, requires source + rebuild)
  - 4 UnitScript hooks catch 100% of casts including instant/hidden
  - Broadcasts as lightweight addon messages to nearby players with the addon
  - CCDX protocol: SC (spell cast), SS (spell start), CF (channel finished), AA (aura applied)

- **Layer 3: Ymir + WowPacketParser pipeline** (retail only)
  - Ymir captures all network packets while playing retail
  - WPP parses the captures into text/SQL
  - Session manager auto-runs WPP when WoW closes, archives captures, backs up data

### Target Users

1. **Repack players** — casual users who want to see what spells creatures use. They install addons but don't compile servers. Value: visual spell browser / encyclopedia.

2. **Repack server operators** — technical users who build TrinityCore from source. Value: accurate spell data + ready-to-apply SQL.

3. **TrinityCore developers / sniff contributors** — expert users who capture retail data and contribute to the TC database. Value: integrated capture pipeline that's faster than manual WPP review.

### Our Intent

Ship a "batteries included" package that serves all three audiences:
- The addon works standalone for casuals (no Python, no server hooks needed)
- The server hooks + auto-patcher serve TC developers
- The Ymir/WPP pipeline + session manager serves sniff contributors
- One-click SQL export in TrinityCore-standard format

### Known Limitations We Want You To Try To Overcome

1. **No auto-backup without a running process.** WoW's addon sandbox can't write files or launch processes. SavedVariables backups require `Start Ymir.bat` (or similar) to be running alongside WoW. If the user just plays without running the companion script, no backups happen. Is there a better architecture?

2. **No diff/audit view.** The killer feature would be: "Here's what retail creatures cast. Here's what your repack creatures cast. Here's the gap." Currently the addon doesn't distinguish retail data from repack data. How would you implement this?

3. **WPP output is a dead end.** WPP generates generic packet text/SQL. There's no bridge from WPP's creature spell data → the addon's data model. The parsed output sits in a folder with a README but no automated merge path. How would you close this loop?

4. **The server hooks require custom patches.** Stock TrinityCore doesn't have our 4 UnitScript hooks. The auto-patcher works but the TC community may resist non-standard patches. Is there a way to achieve server-side capture without core patches? (Eluna? Database triggers? Packet injection?)

5. **No aggregate/community data sharing.** Each user captures their own data in isolation. A shared database where users contribute discoveries would be far more valuable. The addon has a Submit button concept (currently removed). What's the right architecture for community aggregation?

6. **Passive auras and pet/vehicle spells** are partially or fully missed by all three capture layers.

---

## PART 2: WHAT WAS BUILT

### Distribution Structure

```
CreatureCodex-1.0.0/
  CreatureCodex/                    ← ADDON FOLDER (copy to Interface/AddOns/)
    CreatureCodex.toc               — Addon manifest (v1.0.0, Interface 120001)
    CreatureCodex.lua               — Core engine: capture, DB, CCDX protocol, schema migration
    UI.lua                          — Browser: tabs (Browse|Ignored|Settings), creature list, spell detail
    Export.lua                      — 4-mode export: Raw, SQL, SmartAI, New Only
    Minimap.lua                     — LibDBIcon minimap button + Addon Compartment
    Libs/                           — LibStub, CallbackHandler, LibDataBroker, LibDBIcon
    session.py                      — Session manager: Ymir lifecycle, WPP parsing, SV backup
    update_tools.py                 — Tool updater: downloads WPP + Ymir from GitHub
    Start Ymir.bat                  — Launches session.py (full Ymir + WoW watcher flow)
    Update Tools.bat                — Launches update_tools.py (download/update WPP + Ymir)
    Parse Captures.bat              — Launches session.py --parse (WPP only, no Ymir)
    tools/                          — Created by Update Tools.bat
      _README.txt                   — Explains folder contents
      WowPacketParser/              — WPP binary (downloaded)
      Ymir/                         — Ymir binary + dumps/ + dumps/archived/
      parsed/                       — WPP output destination
        _What_To_Do_With_These_Files.txt
    data/                           — Created by session.py on first run
                                      Timestamped SavedVariables backups

  server/                           ← TC SERVER COMPONENT (for developers only)
    bestiary_sniffer.cpp            — C++ UnitScript: 4 hooks, CCDX broadcast, blacklist
    cs_bestiary.cpp                 — .codex GM command tree (query, stats, blacklist)
    install_hooks.py                — Auto-patcher: inserts hooks into TC source via pattern matching
    HOOKS.md                        — Manual patching reference (exact code + locations)

  _GUIDE/                           ← DOCUMENTATION
    01_Quick_Start.md               — Install + first use (noob-friendly)
    02_Server_Setup.md              — TC developer walkthrough
    03_Retail_Sniffing.md           — Ymir pipeline guide
    04_Understanding_Exports.md     — Export modes + how to apply SQL

  README.md                         — GitHub repo README (comprehensive)
  LICENSE                           — MIT
```

### Key Technical Details

**Addon Protocol (CCDX):**
- Addon message prefix: "CCDX"
- Messages are pipe-delimited: `TYPE|entry|spellID|schoolMask|creatureName|hpPct`
- Server broadcasts to all nearby players (100yd) with CCDX registered
- Client sends requests: SL (spell list), CI (creature info), ZC (zone creatures)

**SavedVariables Schema:**
- `CreatureCodexDB.creatures[entry]` = `{name, spells, firstSeen, lastSeen}`
- `CreatureCodexDB.creatures[entry].spells[spellId]` = `{name, school, castCount, auraCount, zones, dbKnown, cooldownMin, cooldownAvg, hpMin, hpMax}`
- `CreatureCodexDB.ignored[entry]` = `{name, ignoredAt}` (creatures)
- `CreatureCodexDB.ignoredSpells[spellId]` = `{name, ignoredAt}` (spells)
- `CreatureCodexDB.creatureBlacklist[entry]` = true
- `CreatureCodexDB.spellBlacklist[spellId]` = true

**SQL Export Format:**
- TrinityCore standard: DELETE + INSERT, backtick column names
- `creature_template_spell`: columns `CreatureID`, `Index`, `Spell`
- `smart_scripts`: full 18-column INSERT with estimated cooldowns
- SmartAI cooldowns estimated from observed cast intervals
- HP-phase spells (seen below 40% HP) get event_type=2

**Session Manager (session.py):**
- Starts Ymir, waits for WoW.exe to appear then disappear
- Ymir auto-closes ~5s after WoW (built-in Ymir behavior)
- Runs WPP on all .pkt files in dumps/
- Detects WPP output via directory snapshots (before/after)
- Archives .pkt to dumps/archived/ with collision handling
- Backs up SavedVariables to data/ with timestamp: `CreatureCodex_YYYY-MM-DD_HH-MM-SS.lua` + `CreatureCodex_latest.lua`
- Derives WoW root from script location (AddOns/CreatureCodex/ → _retail_/)

**Auto-Patcher (install_hooks.py):**
- Pattern-based: searches for anchor strings/regex in TC source, inserts code after match
- Handles multiple matches via context disambiguation (e.g., UnitScript class vs ScriptMgr class in same file)
- Supports --dry-run (preview) and --revert (remove hooks)
- 7 patch operations across 4 files

**UI Architecture:**
- Tab system: Browse | Ignored | Settings
- Browse: creature list (left) + spell detail (right) + action bar (bottom)
- Ignored: two sections (creatures + spells) with Unignore buttons
- Settings: Toggle Debug + Reset All Data (with confirmation popup)
- Status bar: "CreatureCodex: Active" (server hooks) / "Scanning" (visual only) / "Ready" (idle)
- Spell tooltips: full detail including DB status, cast/aura counts, cooldown estimates, HP range, zones
- Ctrl-click: Wowhead URL popup. Shift-click: chat link. Right-click: ignore spell

---

## PART 3: YOUR AUDIT TASKS

### Task 1: Walk Through as a WoW Noob

Assume you are someone who:
- Has played WoW but never installed an addon manually
- Found CreatureCodex from a YouTube video or Discord recommendation
- Runs a prebuilt repack (no source access, no compilation ability)
- Doesn't have Python installed
- Doesn't know what SQL, MySQL, Ymir, or WPP are

Walk through every step from download to "I got value from this." Document every point where you'd get confused, stuck, or give up. Be specific about what instruction is missing or unclear.

### Task 2: Walk Through as a TrinityCore Discord Expert

Assume you are someone who:
- Compiles TrinityCore from source daily
- Has Ymir and WPP already installed elsewhere
- Reads source code before installing anything
- Has strong opinions about code quality, SQL conventions, and architecture
- Will publicly criticize anything that doesn't meet their standards

Walk through from "I found this repo" to "I trust this tool and use it regularly." Document every technical concern, code quality issue, architectural complaint, or standards violation you'd flag. Be harsh — these people are.

### Task 3: Find Everything Wrong

Go through every file in the distribution. Look for:
- Bugs (logic errors, missing error handling, edge cases)
- UX problems (confusing labels, missing feedback, dead ends)
- Documentation gaps (missing steps, wrong paths, assumed knowledge)
- Architecture issues (wrong abstractions, coupling, fragile patterns)
- Security concerns (code injection, path traversal, untrusted input)
- Naming inconsistencies (the server scripts still use "bestiary" internally but the public name is "CreatureCodex")
- Missing features that would be trivial to add but significantly improve the experience

For each issue, rate it:
- **CRITICAL**: Blocks usage or causes data loss
- **HIGH**: Causes significant confusion or produces wrong results
- **MEDIUM**: Annoying but workaround exists
- **LOW**: Cosmetic or minor improvement

### Task 4: What Would You Do Differently?

If you were 100% in charge of this project from this point forward — same tools, same target audience, same problem space — what would you change? Consider:

1. **Architecture**: Is the three-layer capture model the right approach? Would you restructure?
2. **Distribution**: Is the zip-with-bat-files model right, or should this be a CurseForge addon + separate server package?
3. **Data model**: Is SavedVariables the right storage? Should there be a SQLite database? A server-side API?
4. **The audit/diff vision**: How would you implement "show me what retail has that my repack doesn't"?
5. **Community features**: How would you build shared data aggregation?
6. **Automation**: How would you solve the "auto-backup without a running process" problem?
7. **Monetization/sustainability**: This is MIT-licensed open source. Is there a sustainable model?
8. **Roadmap**: What would your next 5 releases look like?

### Task 5: Verify Completion

Claude Code (the AI that built this) claims to have completed the following in this session. Verify each claim against the provided files:

1. ✅ Version changed to 1.0.0 everywhere (TOC, UI, README)
2. ✅ Tab system implemented (Browse | Ignored | Settings)
3. ✅ "Sniffer: ON/--" changed to "CreatureCodex: Active/Scanning/Ready"
4. ✅ Ignore feedback messages guide users to Ignored tab
5. ✅ Start Session.bat renamed to Start Ymir.bat
6. ✅ Parse Captures.bat added
7. ✅ Sync Sniffer button removed from Settings (was pointless)
8. ✅ Settings panel has Toggle Debug + Reset All Data with confirmation
9. ✅ session.py backs up SavedVariables with timestamps to data/
10. ✅ update_tools.py downloads WPP from CI artifacts and Ymir from releases
11. ✅ Server component packaged: bestiary_sniffer.cpp, cs_bestiary.cpp
12. ✅ install_hooks.py auto-patcher created with --dry-run and --revert
13. ✅ HOOKS.md manual reference created
14. ✅ SQL export follows TrinityCore conventions (DELETE+INSERT, backtick columns)
15. ✅ 4 guide documents created in _GUIDE/
16. ✅ Subfolder READMEs in tools/ and tools/parsed/
17. ✅ Old broken code removed (ignoredBtn on nonexistent utilBar, ShowIgnoredPanel, BackButton)

For each, check the actual file contents and confirm or deny. If denied, explain what's actually in the file.

---

## PART 4: CONTEXT THAT MIGHT HELP

### Naming History
The project was originally called "BestiaryForge" internally. It was renamed to "CreatureCodex" for public release. Some internal files still use the old name (bestiary_sniffer.cpp, cs_bestiary.cpp, BestiaryForge namespace in the C++ code). This is a known inconsistency.

### What Exists vs What's Described
The GitHub README.md (included in this zip) was written aspirationally and describes some features that don't exist yet:
- `wpp_watcher.py` (background WPP companion) — NOT BUILT
- `wpp_import.py` with --smartai/--sql/--addon flags — EXISTS but may not have all flags
- `creature_codex_server.lua` (Eluna handlers) — NOT INCLUDED in this distribution
- `codex_aggregated.sql` (aggregation table) — NOT INCLUDED
- `auth_rbac_creature_codex.sql` — NOT INCLUDED
- Some slash commands described may not be implemented

This is a known gap. The README describes the full vision; the v1.0 distribution is the working subset.

### Competition
There is essentially no competition. The closest thing is ClassicBestiary (static Classic-only encyclopedia) which is completely different. No other addon captures creature spells in real-time and generates SQL. This is a new product category.

### The TrinityCore Community
The TC Discord is notoriously harsh. They will:
- Read every line of code before installing
- Compare SQL output against WPP's output byte-for-byte
- Reject anything that requires non-standard core patches (our hooks)
- Mock documentation that assumes too little or too much knowledge
- Demand everything work on Linux (our bat files are Windows-only)

Getting even grudging acceptance from this community would be a significant achievement.
