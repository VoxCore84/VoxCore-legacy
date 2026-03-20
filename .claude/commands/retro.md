---
allowed-tools: Read, Write, Edit, Bash(python3:*), Grep, Glob, Agent
description: Deep session retrospective — analyze pain points, rate improvements by effort/impact, auto-build quick wins
---

# Session Retrospective — Deep Analysis

## Arguments

- `$ARGUMENTS` — optional: focus area (e.g., "tooling", "case work", "financial planning") or "build" to auto-build all quick wins from the backlog

## Instructions

Run a comprehensive retrospective on the current session. This is the detailed version of the quick 5-bullet retro in `/wrap-up` Step 8.

### Phase 1: Collect Evidence (parallel)

Launch these in parallel:
1. **Read `memory/improvements.md`** — look for recurring patterns across sessions
2. **Read `memory/recent-work.md`** — understand session scope and complexity
3. **Read `memory/todo.md`** — see what's already tracked
4. **Review conversation context** — identify every point where you:
   - Had to retry something (tool failure, wrong approach, bad path)
   - Did manual work that could be automated
   - Lost context to compaction
   - Waited on sequential operations that could have been parallel
   - Searched for information that should have been cached
   - Wrote something that already existed in a different form
   - Generated output in the wrong format (markdown in email, etc.)
   - Had to redo work because of missing information
   - Wrote findings at the end instead of incrementally (accumulate-then-choke risk)
   - Launched agents without pre-reading memory for cached data
   - Searched directories manually instead of using /index-folder manifest first
   - Verified filenames but not file content (existence != evidence)
   - Let agent output grow unbounded (should cap at 200 lines, split if more)

### Phase 1b: Quality Audit of Session Output

Check everything produced this session for:
- **Internal contradictions** — does any output contradict itself or other outputs from the same session?
- **Factual accuracy** — are all dates, names, dollar amounts, statute citations, and file paths verifiable?
- **Completeness gaps** — did we fully address every user request, or did some get partially answered?

### Phase 2: Analyze and Rate

For each improvement identified, rate on two axes:

| Rating | Effort | Impact |
|--------|--------|--------|
| LOW    | <30 min, simple script/skill | Saves <5 min per session |
| MED    | 1-3 hours, new tool or agent | Saves 10-30 min per session |
| HIGH   | Half-day+, pipeline or system | Saves 30+ min or prevents data loss |

Priority = Impact / Effort. A LOW-effort HIGH-impact item is a **quick win** and gets built immediately.

### Phase 3: Categorize

Group improvements into:
- **Skills** — new `/slash-commands`
- **Tools** — new Python scripts in `tools/`
- **Agents** — new agent types or agent improvements
- **Hooks** — pre/post hooks that enforce workflows
- **Workflows** — changes to existing skills or processes
- **Memory** — new memory files or updates to existing ones
- **Rules** — new `.claude/rules/` files

### Phase 4: Auto-Build Quick Wins

If effort=LOW and impact>=MED, **build it immediately**:
1. Write the skill/tool/agent/hook
2. Test it if possible (dry-run, syntax check)
3. Update `skill-reminders.md` with the trigger
4. Tell the user what was built and why

If `$ARGUMENTS` contains "build", also build MEDIUM effort items.

### Phase 5: Ownership Lens

Answer: **"What would I do differently if this was my project/file/case/life?"**

This is not a hypothetical. Think about:
- What would you prioritize differently?
- What risks would you mitigate that the user hasn't asked about?
- What would you automate first?
- What would you stop doing entirely?
- What's the 80/20 — which 20% of effort produces 80% of results?

### Phase 6: Gap Check

Answer: **"Did we miss anything?"**
- Re-read the user's original request(s) from this session
- Check every explicit ask against what was delivered
- Check for implicit needs that weren't stated but are obvious
- Check for follow-up work that should have been mentioned

### Phase 7: Report and Persist

**Write to `memory/improvements.md`** (append):

```markdown
### Session [N] Deep Retro — [date]

| # | Improvement | Category | Effort | Impact | Status |
|---|------------|----------|--------|--------|--------|
| 1 | [description] | Skill | LOW | HIGH | BUILT |
| 2 | [description] | Tool | MED | MED | LOGGED |
| 3 | [description] | Workflow | HIGH | HIGH | BACKLOGGED |

**Patterns detected**: [any pain point appearing 3+ times]
**Auto-built this session**: [list what was built]
**Escalated to todo.md**: [list what was added as HIGH priority]
**Ownership reflection**: [1-2 sentences]
**Missed**: [anything missed, or "nothing"]
```

**Update `todo.md`**: Add any MED+ effort items to the appropriate priority section with `[from retro]` tag.

### Phase 8: Output to User

```
## Session Retrospective

### Quick Wins Built
- `/skill-name`: [what it does] — DONE

### Logged for Next Session
| Improvement | Effort | Impact | Category |
|------------|--------|--------|----------|
| [desc]     | MED    | HIGH   | Tool     |

### Patterns (recurring across sessions)
- [pattern]: appeared [N] times -> [action taken]

### Ownership Lens
"If this were my project, I would..."
- [insight 1]
- [insight 2]

### Did We Miss Anything?
- [yes/no + what]

### Recommendations
1. [highest priority improvement to build next]
2. [second priority]
3. [third priority]
```
