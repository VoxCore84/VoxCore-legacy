---
allowed-tools: Bash(git:*), Bash(gh:*), Bash(python3:*), Read, Edit, Write, Grep, Glob, Agent
description: End-of-session routine — commit changes, push, sync bridge, update gists, and refresh memory
---

# Wrap Up Session

## Arguments

- `$ARGUMENTS` — optional: a commit message or specific instructions (e.g., "skip gists", "no push", "just commit", "quick")

## Instructions

Run the full end-of-session wrap-up for VoxCore. Execute steps in parallel where possible.

If user passes **"quick"** in `$ARGUMENTS`, only do Steps 1-3 (commit, push, bridge). Skip gists and memory.

### Step 1: Assess current state (parallel)

Run these simultaneously:
- `git status --porcelain` — machine-parseable change detection
- `git log --oneline -5` — recent commits for message style
- `git diff --stat` — unstaged changes
- `git diff --cached --stat` — staged changes

If there are NO uncommitted changes (no M or A lines in porcelain output), skip to Step 3.

### Step 2: Commit and push

1. **Stage changes**: Only stage files that show as modified (M) or added (A) in `git status --porcelain`. Do NOT stage untracked files (`??`) unless they are clearly part of this session's work (e.g., a new `.cpp` file you just created). Never stage build artifacts, `*_vNext/` dirs, `" - Copy"` files, `.env`, or credential files.
2. **Commit**: If the user provided a message in `$ARGUMENTS`, use it. Otherwise, analyze the diff and write a concise commit message summarizing what changed. Always include the co-author trailer.
3. **Push**: `git push origin HEAD` — unless the user said "no push" or "skip push"

### Step 3: Sync bridge for Cowork

Run the bridge sync so Cowork has fresh data:
```
python /c/Users/atayl/cowork/sync_bridge.py --full 2>&1
```
If the script doesn't exist or fails, try the VoxCore copy:
```
python /c/Users/atayl/VoxCore/cowork/sync_bridge.py --full 2>&1
```
If neither exists or both fail, note it and continue. This step is critical — Cowork's scheduled tasks depend on fresh bridge data.

### Step 4: Update gists (unless user said "skip gists" or "quick")

Check if gist source files have changed since last push by running `git log --oneline -1 -- doc/gist_*.md` to see recent touches. If stale, remind the user which gists need updating:
- **DB Report** (`528e801b53f6c62ce2e5c2ffe7e63e29`) — from `doc/gist_db_report.md`
- **Changelog** (`4c63baf8154753d2a89475d9a4f5b2cc`) — from `doc/gist_changelog.md`
- **Open Issues** (`2b69757faa2a53172c7acb5bfa3ad3c4`) — from `doc/gist_open_issues.md`
- **Runbook** (`84656ef0960c699927e3a555e8248f7b`) — from `doc/gist_runbook.md`
- **Style Guide** — from `doc/gist_style_guide.md`

Also check if `doc/gist_changelog.md` should have this session's work appended (compare against recent-work.md entries).

Do NOT auto-push gist updates without confirmation. Just report which ones look stale.

### Step 5: Update memory files (unless user said "quick")

Read these memory files and check if anything from this session should be updated:
- `C:\Users\atayl\.claude\projects\C--Users-atayl-VoxCore\memory\MEMORY.md` (main index)
- `C:\Users\atayl\.claude\projects\C--Users-atayl-VoxCore\memory\recent-work.md` (work log)
- `C:\Users\atayl\.claude\projects\C--Users-atayl-VoxCore\memory\todo.md` (task list)

For **recent-work.md**: Add an entry for this session if meaningful work was done. Follow the existing format (date, session number, title, description, commit hash). Determine the session number by incrementing the highest number found in recent-work.md.

For **todo.md**:
- Mark any completed items with `~~strikethrough~~ DONE (session N)`
- Add any new items discovered during the session to the appropriate priority section (HIGH/MEDIUM/LOW)
- If the session uncovered blocked work or open questions, add them to DEFERRED/BLOCKED

For **MEMORY.md**: Only update if something structural changed (new system, config change, new tool, etc.). Don't update for routine work.

### Step 5b: Update session_state.md (unless user said "quick")

If `doc/session_state.md` exists, update it:
1. Mark this tab's row as COMPLETE in the Active Tabs table (add commit hash)
2. Move any completed Tier items to the Recently Completed table
3. Update any status fields that changed during this session

### Step 5c: Update Central Brain (unless user said "quick")

Update `AI_Studio/0_Central_Brain.md` with:
1. **"Current Focus"** section — reflect what was completed this session
2. **"Infrastructure State"** — update build/server/DB status if changed
3. **"Inbox Status"** — update count if specs were processed or added
4. **Timestamp** — update "Last updated" at top

Keep Central Brain updates concise (1-2 lines per change). This file is read by Cowork's scheduled tasks and other Claude Code tabs.

### Step 6: Update todo.md with next-session suggestions

After completing Steps 1-5, review the current state and add a `## Next Session` section at the top of `todo.md` (after the title, before `## Completed`). This section should contain up to 10 actionable items for the next session, based on:

1. **Uncommitted changes** — if `git status` still shows modified/deleted files not committed this session, list them as "Review and commit outstanding changes (N files)"
2. **Blocked items unblocked** — scan DEFERRED/BLOCKED for anything that may now be actionable
3. **Natural follow-ups** — work that logically continues from this session's changes
4. **HIGH priority items** — pull the top 1-2 non-DONE items from the HIGH section

Format:
```markdown
## Next Session
- [ ] Item 1 — brief description
- [ ] Item 2 — brief description
- [ ] Item 3 — brief description
```

If a `## Next Session` section already exists, **replace it entirely** with fresh suggestions. Stale next-session items are worse than none.

### Step 7: Session summary

Write a **"What We Did"** section that gives the user (and future sessions) a clear picture of everything accomplished. This is the most valuable part of the wrap-up — it prevents re-analysis in future sessions.

Structure it as a numbered list of major accomplishments. For each item:
- **Bold title** — what category of work (e.g., "Server Log Audit", "Transmog Infrastructure")
- 2-3 sentences of what was done, key findings, and artifacts produced
- Reference specific files created/modified, commit hashes, or metrics where relevant

Guidelines:
- Group related work together (don't list every file edit separately)
- Include quantitative results where available (rows fixed, bugs catalogued, files changed)
- Mention any agents launched and what they found
- Note anything deployed-but-unverified or left for next session
- Keep each item to 3-4 lines max — this is a summary, not a narrative

Then output the operational summary:
```
## Session Wrap-Up

### What We Did
1. **Category** — description of work, key outputs, metrics
2. **Category** — description of work, key outputs, metrics
...

### Committed
- [commit hash] message (or "nothing to commit")

### Pushed
- [branch] -> origin (or "skipped")

### Bridge
- Synced (or "failed: reason")

### Gists
- [list any stale gists, or "all current"]

### Memory
- [what was updated, or "no changes needed"]

### Next Session (written to todo.md)
- [ ] item 1
- [ ] item 2
- [ ] item 3
```

### Step 8: Session Retrospective (unless user said "quick")

Quick 5-bullet reflection on what could be improved. Takes 60 seconds and compounds across sessions.

Answer these 5 questions (one concise bullet each):

1. **Pain point**: What slowed you down most this session? (missing tool, manual repetition, context loss, fragile workflow, bad path)
2. **Missed automation**: What did you do manually 2+ times that should be a skill, agent, hook, or tool?
3. **Ownership lens**: What would you have done differently if this was YOUR project/file/case/life — not a client's?
4. **Accuracy check**: Any internal contradictions, factual errors, or completeness gaps in what we produced this session?
5. **What did we miss?**: Anything the user asked for that didn't get delivered, or a better approach you thought of too late?

**Write results to `memory/improvements.md`** (append, don't replace):

```markdown
### Session [N] — [date]
1. **Pain**: [one-liner]
2. **Automate**: [one-liner]
3. **Ownership**: [one-liner]
4. **Accuracy**: [one-liner or "clean"]
5. **Missed**: [one-liner or "nothing"]
> Quick win: [if any item is <30 min to build, note it here]
```

**Escalation rule**: After writing, scan `memory/improvements.md` for patterns. If any pain point or automation suggestion appears **3+ times** across sessions:
1. Add it to the top of `todo.md` as a HIGH priority build task
2. If it's clearly low-effort (<30 min), **build it right now** during wrap-up and tell the user what you built
3. If medium+ effort, note it as "ESCALATED — build next session" in todo.md

For a deeper analysis with effort/impact ratings and auto-building, suggest the user run `/retro`.

### Rules
- Never force-push
- Never commit `.env`, credentials, or binary files
- Never auto-update gists without user confirmation
- If any step fails, continue with remaining steps and report the failure
- Keep commit messages concise (1-2 lines)
- If the user passes specific instructions in $ARGUMENTS, respect them (e.g., "just commit", "skip gists", "no push", "quick")
- The `## Next Session` section in todo.md must always be fresh — replace it every wrap-up, never append
