# VoxCore Project Context

TrinityCore-based WoW private server (12.x / Midnight client, roleplay focus). ~15K commits ahead of upstream.

## Structure
- `src/server/game/RolePlay/` — sRoleplay singleton
- `src/server/game/Companion/` — sCompanionMgr singleton
- `src/server/scripts/Custom/` — all custom scripts
- `sql/updates/` — incremental SQL updates
- `tools/` — Python tooling, discord bot, auto_parse
- `AI_Studio/` — multi-AI coordination hub

## Coordination
- `AI_Studio/0_Central_Brain.md` — read before work, update when done
- `doc/session_state.md` — multi-agent coordination
- `cowork/context/todo.md` — task list

## Build
- NEVER invoke ninja/cmake — user builds via Visual Studio 2026
- MySQL: `"C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe" -u root -padmin`
- 5 databases: auth, characters, world, hotfixes, roleplay

## Anti-Theater
Never claim completion without evidence. DESCRIBE tables before SQL. Verify each step. "I didn't verify" beats false "Success!"
