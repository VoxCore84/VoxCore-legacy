---
description: "Implement transmog fixes from the bug tracker — reads current state, applies surgical patches, verifies build"
allowed-tools: ["Read", "Edit", "Write", "Bash", "Grep", "Glob", "Agent"]
---

# Transmog Implementation Session

You are implementing fixes for the VoxCore transmog outfit system (WoW 12.x / Midnight client).
This skill provides everything you need to work autonomously without a catchup/analysis phase.

## Step 1: Load Context (MANDATORY — do this FIRST)

Read these files in parallel:
1. `C:\Users\atayl\.claude\projects\C--Users-atayl-VoxCore\memory\transmog-bugtracker.md` — **THE BUG LIST**. Pick the next unresolved bug.
2. `C:\Users\atayl\.claude\projects\C--Users-atayl-VoxCore\memory\transmog-implementation.md` — architecture + history
3. The CLAUDE.md "Transmog UI / Midnight 12.x — Authoritative Rules" section — behavioral model (ADT/IDT values, 30-row layout, hidden IMA IDs)

Do NOT re-read the entire codebase. The bug tracker has exact file:line references for every bug.

## Step 2: Pick a Bug

From `transmog-bugtracker.md`, find the highest-priority OPEN bug. Each bug entry has:
- **Status**: OPEN / IN-PROGRESS / FIXED / VERIFIED
- **Priority**: CRITICAL > HIGH > MEDIUM > LOW
- **File:Line**: Exact location
- **Root Cause**: What's wrong
- **Fix**: What to change
- **Verification**: How to confirm the fix is correct

## Step 3: Implement

1. Read ONLY the file(s) listed in the bug entry
2. Apply the fix as described — surgical, minimal changes
3. If the fix description is ambiguous, check the authoritative rules in CLAUDE.md

## Step 4: Self-QA

After each fix, verify against the retail behavioral model:
- Stored empty = ADT=0/IDT=0
- Stored assigned = ADT=1/IDT=0
- Viewed empty = ADT=2/IDT=2
- Viewed assigned = ADT=1/IDT=0 (SAME as stored — NOT ADT=2)
- Hidden = ADT=3/IDT=0 (real hidden IMA ID, never zero)
- Enchanted weapon = ADT=1/IDT=1
- Paired placeholder (opts 8-11) = ADT=4/IDT=4
- No fake weapon option-0 rows
- Bridge defer for slots 2/12/13 preserved

## Step 5: Update Bug Tracker

After implementing, update `transmog-bugtracker.md`:
- Change status to FIXED
- Add the commit hash (if committed)
- Note any follow-up issues discovered

## Rules

- ONE bug per invocation. Don't combine fixes.
- Show unified diff for every change.
- NEVER build from Claude Code — user builds via VS IDE. Just report "ready for build".
- Don't touch files not listed in the bug entry unless a build error requires it.
- Don't add comments, docstrings, or refactoring beyond the fix.
- If a bug's fix reveals a NEW bug, add it to the tracker as a new entry — don't fix it in the same pass.
- Prefer `Edit` over `Write` for existing files.

## Key Files Quick Reference

| File | What's There |
|------|-------------|
| `src/server/game/Entities/Player/Player.cpp` | `fillOutfitData`, `_SyncTransmogOutfitsToActivePlayerData`, ViewedOutfit sync |
| `src/server/game/Handlers/TransmogrificationHandler.cpp` | All 4 CMSG handlers, bridge finalize, deferred path |
| `src/server/game/Server/Packets/TransmogrificationPackets.h/.cpp` | Packet structs + parsers |
| `src/server/game/Entities/Player/TransmogrificationUtils.h/.cpp` | `ApplyTransmogOutfitToPlayer()` shared utility |
| `src/server/game/Spells/SpellEffects.cpp` | `EffectEquipTransmogOutfit()` (spell 347) |
| `src/server/scripts/Custom/spell_clear_transmog.cpp` | Clear All Transmogrifications spell handler |
| `src/server/game/Entities/Player/EquipmentSet.h` | `EquipmentSetData` struct, `MainHandOption`/`OffHandOption` |
| `src/server/game/Entities/Player/CollectionMgr.cpp` | `SendFavoriteAppearances()`, login sync |
| `C:/WoW/_retail_/Interface/AddOns/TransmogBridge/TransmogBridge.lua` | Client addon — 3-layer hybrid merge |
