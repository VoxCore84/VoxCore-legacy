---
allowed-tools: Read, Grep, Glob, Agent
description: Generate a 1-page executive summary for a specific audience (attorney, congressional, afbcmr, odc)
---

# One-Pager Generator

Generate a focused, 500-word executive summary of the case tailored to a specific audience.

## Arguments

The user provides the target audience:
- `/one-pager attorney` — for Tolin, ODC, or POD
- `/one-pager congressional` — for Lujan, Heinrich, or other congressional offices
- `/one-pager afbcmr` — for DD Form 149 narrative
- `/one-pager odc` — for ODC emergency intake

If no audience specified, ask which one.

## Instructions

Spawn the `one-pager` agent with the audience parameter. The agent reads all 5 master files + complaint trail + FINAL docs and generates a 500-word max summary using the audience-specific template.

Example agent prompt:
```
Generate a one-page executive summary for audience: [AUDIENCE].
Read all 6 source files, then produce a 500-word max summary using the [AUDIENCE] template.
```

## After Agent Returns

1. Display the one-pager to the user
2. Ask: "Save to Desktop as `Case_OnePager_[audience]_[date].md`?"
3. If yes, write the file

## Quality Check

Before presenting, verify:
- Word count is under 500
- Every factual claim has a parenthetical source reference
- Specific numbers are used (not vague language)
- The "Specific Asks" section has numbered action items
- No information that isn't traceable to the source files
