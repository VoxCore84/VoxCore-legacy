---
allowed-tools: Read, Grep, Glob, Bash(python3:*), Bash(git:*), Bash(mysql:*), Agent, mcp__mysql__*, mcp__codeintel__*
description: Verify work is actually complete — not a polite "double check" but a rigorous evidence-based audit of what was done vs. what was requested
---

# Verify Completion

This is the VoxCore version of "double-check" — but instead of asking Claude to
"please think again," it runs actual verification steps with tool calls.

## Arguments

$ARGUMENTS — Optional: specific aspect to verify. If empty, verifies everything
done in the current session.

## Process

### Step 1: Reconstruct the Request

Go back to the FIRST user message in this conversation and extract:
- What was requested (exact words)
- What success looks like (stated or implied criteria)
- Any sub-tasks mentioned

List each item as a numbered checklist.

### Step 2: Audit Each Item

For EACH item in the checklist:

**If it was a code change:**
- Read the file NOW and confirm the change is present (quote the relevant lines)
- Check that the change compiles conceptually (correct types, includes, namespaces)
- Verify the function is registered if it's a new script (check custom_script_loader.cpp)
- Reminder: user builds in Visual Studio — don't claim "builds successfully"

**If it was a SQL change:**
- DESCRIBE the target table and verify column count matches VALUES count
- If the SQL was applied, check DBErrors.log for errors since application time
- If not applied, remind about /apply-sql or pending pipeline

**If it was a database query or investigation:**
- Re-run the key verification query and quote the output
- Does the result match what was claimed?

**If it was a configuration change:**
- Read the config file and confirm the change is present
- Check for syntax errors (JSON validity, YAML indentation)

### Step 3: Check for Silent Omissions

Compare the checklist from Step 1 against what was actually done:
- Were any items skipped without mentioning them?
- Were any items partially done but reported as complete?
- Were any verification steps in the original request skipped?

### Step 4: Evidence Report

```
## Verification Report

### Requested (N items)
1. [x] Item — VERIFIED: [quote tool output proving it]
2. [x] Item — VERIFIED: [quote tool output proving it]
3. [ ] Item — NOT DONE: [reason]
4. [~] Item — PARTIAL: [what's done, what's missing]

### Confidence Assessment
- Items with tool-output evidence: N/M
- Items claimed without verification: N/M
- Items silently skipped: N/M

### Remaining Work
- [list anything not done or not verified]
```

### Rules
- This is an AUDIT, not a rubber stamp. The purpose is to FIND problems.
- Every "VERIFIED" must include quoted tool output. No tool output = "UNVERIFIED"
- "I believe it works" is not verification. "I read the file and line 47 shows X" is.
- If you can't verify something without building/running, say so honestly.
- This skill enforces the Anti-Theater Protocol from completion-integrity.md
