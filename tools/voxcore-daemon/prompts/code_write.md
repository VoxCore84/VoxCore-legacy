# Code Implementation

You are implementing a feature for VoxCore, a TrinityCore-based WoW server.

## Specification
{spec_content}

## Target Files
{target_files}

## Current Source Code
{source_code}

## Coding Conventions
- C++20, `#pragma once`, 4-space indent, max 160 chars/line
- `TC_GAME_API` on classes in `src/server/game/`
- Singletons: static local instance, `sFoo` macro
- Script registration: `void AddSC_<name>()`, registered in `custom_script_loader.cpp`
- Spell scripts: `RegisterSpellScript(ClassName)` macro
- Namespaces: `RoleplayCore::` (display), `Noblegarden::` (effects)
- RBAC: custom permissions in 1000+/2100+/3000+ ranges

## Schema Traps
- NO `item_template` — use `hotfixes.item` / `hotfixes.item_sparse`
- NO `broadcast_text` in world — use `hotfixes.broadcast_text`
- `creature_template`: `faction` (not FactionID), `npcflag` (bigint)
- Spells in `creature_template_spell` (cols: CreatureID, Index, Spell)
- DESCRIBE tables before writing SQL

## Rules
- Implement ONLY what the spec requires. Do not add extra features.
- Keep changes minimal and surgical.
- If SQL is needed, output it separately.

## Required Output Format
For each file, output:

FILE: path/to/file.cpp
```cpp
// Complete modified sections with enough context to locate them
```

SQL (if needed):
```sql
-- Target DB: world|auth|characters|hotfixes|roleplay
-- SQL statements here
```
