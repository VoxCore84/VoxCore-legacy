# Execution Style

## Native Tools First
- **list_dir** / **find_by_name** instead of ls/find
- **view_file** instead of cat
- **grep_search** instead of grep/rg
- **edit_file** instead of sed/awk
- Shell only for: builds, Python scripts, mysql, git

## Parallelism
Ryzen 9 9950X3D 16C/32T, 128GB RAM. Run independent tasks in parallel sub-agents. Never serialize parallelizable work.

## SQL
- DESCRIBE table before INSERT/UPDATE
- No `item_template` (use hotfixes), no `broadcast_text` in world
- Naming: `sql/updates/<db>/master/YYYY_MM_DD_NN_<db>.sql`

## Conciseness
- Lead with actions, not explanations
- Don't recap, don't ask "should I continue?" — just continue
- Skip filler: "Let me", "I'll now", "Great!", "Sure!"
