# RoleplayCore — Agent Instructions

## Project Overview

TrinityCore-based WoW private server targeting the **12.x / Midnight** client, specialized for roleplay. C++20 codebase, built with CMake + Ninja.

## Build (Linux / Codex Container)

The `.codex/setup.sh` script installs dependencies and configures cmake. To build after making changes:

```bash
cd out/build/x64-Debug && ninja -j$(nproc) 2>&1
```

To build only scripts (faster):

```bash
cd out/build/x64-Debug && ninja -j$(nproc) scripts 2>&1
```

## Coding Conventions

- **C++ standard**: C++20 (structured bindings, `contains()`, `string_view`, etc.)
- **Indent**: 4 spaces
- **Charset**: latin1 for C/C++ files
- **Max line length**: 160
- **Header guards**: `#pragma once` for new files
- **Logging**: `TC_LOG_DEBUG(logger, fmt, args...)` and `TC_LOG_ERROR(logger, fmt, args...)`
- **String formatting**: `Trinity::StringFormat(fmt, args...)` (fmt-style)
- **Visibility**: `TC_GAME_API` on classes in `src/server/game/`
- **Includes**: `#include "..."` for project headers, `#include <...>` for system headers

## Project Structure

```
src/server/game/
    RolePlay/                        — Roleplay singleton (sRoleplay), central custom system
    Spells/                          — Spell effect handlers, spell class
    Handlers/                        — CMSG packet handlers (WorldSession methods)
    Server/Packets/                  — Packet class declarations + Read()/Write()
    Entities/Player/                 — Player, EquipmentSet, CollectionMgr
    Entities/Item/                   — Item class, ItemDefines (modifier enums)
    Entities/Creature/               — CreatureOutfit (NPC appearance overlay)
    DataStores/                      — DB2 store loading, DB2 entry structs
    Accounts/RBAC.h                  — Permission constants (custom range 1000+)
src/server/scripts/
    Custom/                          — All custom scripts
    Custom/custom_script_loader.cpp  — Script registration entry point
    Commands/                        — Chat command scripts
sql/
    updates/                         — Incremental SQL updates (YYYY_MM_DD_NN_<db>.sql)
    RoleplayCore/                    — One-time setup scripts
```

## Custom Systems

- **sRoleplay** singleton (`src/server/game/RolePlay/`) — creature extras, custom NPCs, player extras
- **Custom NPC** (`.cnpc` command) — player-race NPCs with equipment/appearance
- **Visual Effects** (`.effect` command, `Noblegarden::` namespace) — SpellVisualKit persistence
- **Display/Transmog** (`.display` command, `RoleplayCore::` namespace) — per-slot appearance overrides
- **Transmog Outfits** — CMSG_TRANSMOG_OUTFIT_* packet handling, spell effect 347

## Adding a New Script

1. Create `.cpp` in `src/server/scripts/Custom/`
2. Define `void AddSC_<name>()` at the bottom
3. Register in `custom_script_loader.cpp`
4. Build with `ninja -j$(nproc) scripts`

## Databases

| DB | Purpose |
|---|---|
| `auth` | Accounts, RBAC permissions |
| `characters` | Player data, equipment sets, transmog outfits |
| `world` | Game world data (creatures, items, spells) |
| `hotfixes` | Client hotfix overrides |
| `roleplay` | Custom: creature_extra, custom_npcs, server_settings |

## General Rules

- Follow existing patterns in nearby code
- Do not modify `CLAUDE.md`, `AGENTS.md`, `.claude/` files, or cmake config
- PR branches should be descriptively named and based on `master`
- Compile-check your changes if the build environment is available
