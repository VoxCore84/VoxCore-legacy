# Transmog UI Status (RoleplayCore)

This note tracks the **current** state of transmog outfit support in this branch for TWW/Midnight-era clients.

## Current status

### Implemented

- Outfit CMSG handlers are registered and no longer routed to `Handle_NULL`:
  - `CMSG_TRANSMOG_OUTFIT_NEW`
  - `CMSG_TRANSMOG_OUTFIT_UPDATE_INFO`
  - `CMSG_TRANSMOG_OUTFIT_UPDATE_SLOTS`
  - `CMSG_TRANSMOG_OUTFIT_UPDATE_SITUATIONS`
- Matching SMSG opcodes are registered as sendable (`STATUS_NEVER`).
- Outfit packet parser classes exist in `TransmogrificationPackets.*`.
- `_SyncTransmogOutfitsToActivePlayerData()` populates outfit update fields from transmog equipment sets and is invoked on login/save/delete transmog set paths.

### In progress / partial

- Situation updates are parsed and acknowledged, but currently treated as a no-op (diagnostic-only persistence path).

## Known limitations

1. **Packed player guid decode mismatch in outfit packets**
   - Some captures decode packet guid as `Creature-*` while session guid is `Player-*`.
   - Validation now tolerates this mismatch for transmog outfit opcodes and logs it for diagnostics.

2. **UPDATE_SLOTS payload variants**
   - Payloads include alignment/extra bytes after packed guid and before slot entries.
   - Parser currently consumes one known alignment byte (`0x00/0x80/0xC0`) and logs framing diagnostics (`extraBytes`, `bytesBeforeSlots`).
   - If captures vary further, additional framing rules may be needed.

3. **Situation persistence TODO**
   - `CMSG_TRANSMOG_OUTFIT_UPDATE_SITUATIONS` currently logs parsed rows and sends response, but does not persist situation state yet.

4. **Non-transmog opcode noise is expected**
   - Client may emit unrelated not-handled opcodes (e.g. perks/catalog requests); these are separate from outfit flow and not blockers for transmog outfit parsing.

## Troubleshooting flow

1. Enable `network.opcode.transmog` debug logging.
2. Reproduce at transmog NPC:
   - create outfit,
   - rename/icon update,
   - slot updates,
   - situation toggle.
3. Verify logs show:
   - parser diag line per opcode,
   - no parse overflow/errors,
   - handler acceptance (or explicit validation reason if rejected).
4. Verify persistence and sync:
   - DB rows mutate for saved outfits,
   - relog populates `ActivePlayerData` outfits,
   - UI reflects renamed/edited outfits.

## Quick verification checklist

- [ ] Outfit CMSGs route to `HandleTransmogOutfit*` handlers.
- [ ] SMSG outfit responses are emitted after successful updates.
- [ ] No `ByteBuffer overflow` in outfit parser logs.
- [ ] UPDATE_SLOTS slotIndex extraction/mapping yields sane equip slots in logs.
- [ ] Outfit list appears after relog via active player sync.
- [ ] Situation updates no longer no-op once persistence is implemented.
