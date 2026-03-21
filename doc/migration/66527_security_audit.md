# Security Audit — Build 66527 Migration

## Severity Taxonomy
| Severity | Pattern | Blocks Migration? |
|----------|---------|-------------------|
| CRITICAL | DirectExecute/Query with player-controlled strings | YES |
| HIGH | DirectExecute with server-controlled dynamic values | NO (document) |
| MEDIUM | Hardcoded SQL with no dynamic input | NO (document) |
| INFO | Lua DB queries with concatenation, promoted if player-controlled | YES if player input |

## Audit Scope
1. src/server/game/RolePlay/
2. src/server/game/Companion/
3. src/server/game/Craft/
4. src/server/game/Hoff/
5. src/server/scripts/Custom/
6. src/server/scripts/Commands/cs_customnpc.cpp
7. runtime/lua_scripts/

## Findings

_Populated during Phase 6 security audit._
