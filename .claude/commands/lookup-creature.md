---
allowed-tools: Bash(mysql:*)
description: Look up creature template entries by ID or search by name from the world database
---

## Context

The user wants to look up creature data from the world database.
- MySQL binary: `C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe`
- Credentials: root / admin
- Database: world
- Table: `creature_template` — columns include `entry`, `name`, `subname`, `faction`, `npcflag`, `unit_flags`, `unit_flags2`, `unit_flags3`, `Classification`, `KillCredit1`, `KillCredit2`
- NOTE: No `minlevel`/`maxlevel` columns in 12.x — level data is in `creature_template_difficulty`
- Classification: 0=Normal, 1=Elite, 2=Rare Elite, 3=World Boss, 4=Rare

## Arguments

$ARGUMENTS can be:
- **A number** (e.g., `448`) — look up that creature entry
- **Multiple numbers** (e.g., `448 69 1234`) — look up all of them
- **A text string** (e.g., `Hogger`) — search creature names (case-insensitive, LIKE match)

## Your task

1. Parse $ARGUMENTS to determine if it's an ID lookup or a name search
2. For **ID lookup** (one or more numbers):
   - Query: `SELECT entry, name, subname, faction, npcflag, Classification FROM creature_template WHERE entry IN (id1, id2, ...);`
   - Display results as a clean table
   - If an entry is not found, say so
3. For **name search** (text):
   - Query: `SELECT entry, name, subname, faction, npcflag, Classification FROM creature_template WHERE name LIKE '%search%' LIMIT 25;`
   - Also run a COUNT(*) to show total matches
   - Display as a clean table
4. Run queries via: `"C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe" -u root -padmin world -e "<query>" -t`
   - The `-t` flag gives a nice table output
5. Keep output concise — just the table, no extra commentary
