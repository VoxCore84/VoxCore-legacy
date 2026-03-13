# CreatureCodex v1.0.0v2 — Follow-Up Audit

## For: ChatGPT (GPT-5.4)
## From: VoxCore Development Team (Claude Code + Human Operator)
## Date: 2026-03-13
## Purpose: Verify all v1 audit findings were addressed

---

## What Changed Since v1

Your first audit found 20 issues across 4 severity levels. Here's what we fixed:

### CRITICAL (all 5 addressed)

1. **install_hooks.py marker bug** — Each hook now has a unique marker string. Hook[0] uses "CreatureCodex hooks -- creature spell/aura broadcasting", Hook[1] uses "CreatureCodex dispatch declarations". No more same-file skip.

2. **Server install path incomplete** — HOOKS.md and 02_Server_Setup.md now document BOTH `AddSC_creature_codex_sniffer()` AND `AddSC_creature_codex_commands()`. The `IsAddonRegistered` helper is documented in the README's Full Install section.

3. **Command registration/naming mismatch** — Full rename: `.bestiary` → `.codex`. Files renamed: `bestiary_sniffer.cpp` → `creature_codex_sniffer.cpp`, `cs_bestiary.cpp` → `cs_creature_codex.cpp`. Namespace: `BestiaryForge` → `CreatureCodex`. Class names, function names, RBAC permissions, chat prefixes all updated.

4. **Dead protocol features** — `/cc zone` and `/cc submit` now print honest messages saying they require the Eluna server script. The Eluna script (`creature_codex_server.lua`) is now INCLUDED in the distribution.

5. **Destructive exports** — SQL export now includes WARNING comments about DELETE statements. Users are directed to "New Only" tab for safe additive exports.

### HIGH (all 7 addressed)

6. **README overclaims** — Complete rewrite. Every file reference matches the actual distribution. Screenshot references removed. File structure section matches reality. `wpp_import.py`, `wpp_watcher.py`, and `creature_codex_server.lua` are now shipped.

7. **Retail sniffing docs hide dependencies** — `03_Retail_Sniffing.md` now lists `gh` CLI and `curl` as requirements.

8. **Version inconsistency** — `VERSION = 4` kept for schema migration, new `ADDON_VERSION = "1.0.0"` for display. UI.lua fallback changed from "1.1.0" to "1.0.0". Login banner uses ADDON_VERSION.

9. **Zone scan API** — Slash command help now notes it requires Eluna server script.

10. **string:trim()** — Changed to `strtrim()`.

11. **WPP auto-merge** — `wpp_import.py` and `wpp_watcher.py` are now included in the distribution under `tools/`.

12. **lastTargetEntry permanent block** — Now uses 5-second time-based throttle instead of permanent entry cache.

### MEDIUM (5 addressed)

13. **Doc patch location disagreements** — All docs now reference the same function names consistently.

14. **Unused data model** — Left as-is (they're used by the Eluna bridge, which is now shipped).

15. **update_tools.py ZIP extraction** — Added try/except around interactive prompt for non-interactive environments.

16. **Interactive shortcut prompt** — Wrapped in try/except for automated environments.

17. **Fragile includes** — `#include <unordered_set>` added to cs_creature_codex.cpp.

### LOW (3 addressed)

18. **BestiaryForge naming** — Complete rename pass (see CRITICAL #3).

19. **Screenshot references** — Removed from README.

20. **Windows-only wrappers** — Added `start_ymir.sh`, `update_tools.sh`, `parse_captures.sh` for Linux/macOS.

---

## Your Tasks for v2

### Task 1: Verify Every Fix
Go through each of the 20 items above. Check the actual file contents. Confirm or deny each fix.

### Task 2: Fresh Noob + Expert Walkthrough
Walk through again as both personas. Are the confusion points from v1 resolved?

### Task 3: Find NEW Issues
The fixes may have introduced new problems. Check for:
- Broken references from the rename
- Inconsistencies between old and new naming
- New documentation gaps
- Anything we missed

### Task 4: Is This Ready to Ship?
Give a clear yes/no on whether this distribution is ready for a hostile technical audience. If no, list the remaining blockers.

---

## Distribution Structure (v2)

```
CreatureCodex-1.0.0v2/
  CreatureCodex/                    ← ADDON FOLDER (copy to Interface/AddOns/)
    CreatureCodex.toc
    CreatureCodex.lua
    Export.lua
    UI.lua
    Minimap.lua
    Libs/                           ← LibStub, CallbackHandler, LibDataBroker, LibDBIcon
    session.py                      ← Session manager (Ymir + WPP + SV backup)
    update_tools.py                 ← Tool downloader (WPP + Ymir)
    Start Ymir.bat                  ← Windows: full capture session
    Update Tools.bat                ← Windows: download/update tools
    Parse Captures.bat              ← Windows: WPP only, no Ymir
    start_ymir.sh                   ← Linux/macOS equivalent
    update_tools.sh
    parse_captures.sh
    tools/
      _README.txt
      wpp_import.py                 ← WPP text → SQL / addon import
      wpp_watcher.py                ← Background auto-import companion
      parsed/
        _What_To_Do_With_These_Files.txt

  server/                           ← TC SERVER COMPONENT
    creature_codex_sniffer.cpp      ← C++ UnitScript hooks (renamed from bestiary_*)
    cs_creature_codex.cpp           ← .codex GM commands (renamed)
    install_hooks.py                ← Auto-patcher (marker bug fixed)
    HOOKS.md                        ← Manual patching reference (both AddSC_ registered)
    lua_scripts/
      creature_codex_server.lua     ← Eluna handlers (SL, CI, ZC, AG)

  _GUIDE/
    01_Quick_Start.md
    02_Server_Setup.md              ← Fixed: both registrations, correct file names
    03_Retail_Sniffing.md           ← Fixed: gh CLI documented
    04_Understanding_Exports.md     ← Fixed: destructive export warning

  README.md                         ← REWRITTEN to match reality
  README_RU.md
  README_DE.md
  LICENSE
  CHATGPT_AUDIT_REQUEST_V2.md      ← This file
```
