---
allowed-tools: Read, Write, Bash(git:*), Grep, Glob
description: Mid-session checkpoint — snapshot current state to survive compaction in long sessions
---

# Checkpoint

Save a snapshot of current session state so nothing is lost to context compaction.

## Arguments

`$ARGUMENTS` — optional: a label for this checkpoint (e.g., "pre-research", "angel-forms-done", "financial-planning-complete")

## Instructions

### When to Use This
- Session has been going 30+ minutes with substantial work
- About to start a major topic shift
- Background agents returned important data
- Just completed a phase of multi-step work
- Context window is getting large (lots of tool calls, file reads)

### What to Capture

Determine a label: use `$ARGUMENTS` if provided, otherwise generate one from context (e.g., "session-195-midpoint").

Write a checkpoint file to: `AI_Studio/Reports/checkpoint_[YYYY-MM-DD]_[label].md`

Contents:

```markdown
# Session Checkpoint — [label]
**Date**: [YYYY-MM-DD HH:MM]
**Session**: [number if known]

## Session Goal
[What the user originally asked for — 1-2 sentences]

## Completed So Far
1. [task] — [key output file or result]
2. [task] — [key output file or result]
...

## Key Data (expensive to re-discover)
- [fact]: [value] — source: [file path or "user stated"]
- [fact]: [value] — source: [file path or "user stated"]
...

## Currently Working On
[What you're doing right now and where you left off]

## Still Pending
- [ ] [task — brief description]
- [ ] [task — brief description]
...

## Files Created/Modified This Session
- [path] — [created/modified] — [what changed]
...

## Background Agent Results
- [agent description]: [summary of key findings]
...

## Open Questions
- [anything unresolved or needing user input]
...
```

### Rules
1. Be specific — "Angel's DOB is 4/20/1994 (from Case_Reference/14_AFW2)" is useful. "Found Angel's info" is not.
2. Include full file paths — future sessions need to find these files
3. Key data section is the most important — anything that took multiple searches or agent passes to discover goes here
4. Don't include verbose tool output — just the conclusions
5. If agents are still running in background, note what they were tasked with

### After Writing

Tell the user:
1. "Checkpoint saved to [path]"
2. "If context compacts or you start a new session, read this file to restore state."
3. If the session has been very long (3+ checkpoints or obvious context pressure), suggest: "Consider `/wrap-up` and continuing in a fresh tab — you won't lose anything."
