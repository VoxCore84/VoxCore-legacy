---
spec_id: TRIAD-66337-EXTRACT
title: Build 66337 Client Extractor Results
status: COMPLETE
date: 2026-03-10
executor: Claude Code
---

# Build 66337 Client Extractor Report

## Summary

All four client extractors (mapextractor, vmap4extractor/vmap4assembler, mmaps_generator)
ran successfully against the WoW 12.x retail client at `C:\WoW\_retail_\`. All output has
been staged to `C:\Users\atayl\VoxCore\runtime\` (symlinked from the RelWithDebInfo runtime directory).

## Extraction Source

- **Client path**: `C:\WoW\_retail_\`
- **Extractor binaries**: Copied from `out/build/x64-RelWithDebInfo/bin/RelWithDebInfo/`
- **Target build**: 66337

## Extraction Results

| Asset | Files | Verified | Notes |
|-------|-------|----------|-------|
| DBC | 1,121 .db2 files (enUS locale) | Extract=Runtime | Locale subfolder `enUS/` |
| Maps | 44,336 files (1,061 maps) | Extract=Runtime | .map tiles + .tilelist per map |
| VMaps | 951 map directories | Extract=Runtime | Per-map subdirs with .vmo files |
| Buildings | 38,690 files | Extract=Runtime | VMap intermediate data |
| MMaps | 27,201 .mmtile + 745 .mmap | Extract=Runtime | 745 maps with nav mesh tiles |
| Cameras | 27 files | Extract=Runtime | Camera cinematic data |
| GT | 20 files | Extract=Runtime | Game table text files |

## Timeline

- **~15:45** — mapextractor completed (DBC, cameras, GT, maps)
- **~16:13** — vmap4extractor + vmap4assembler completed (VMaps, Buildings)
- **16:24+** — mmaps_generator started (PID 19636)
- **17:34** — Staging began for completed assets (DBC, cameras, GT)
- **17:38-17:50** — Maps, VMaps, Buildings staged to runtime
- **~17:56** — mmaps_generator completed (final tile: map 3038)
- **17:59** — MMaps staged to runtime
- **18:00** — All staging verified, report written

## Staging Verification

All file counts verified as exact matches between extraction output and runtime destination:

```
DBC:       1,121 = 1,121
Maps:     44,336 = 44,336
VMaps:       951 = 951 (directories)
Buildings: 38,690 = 38,690
MMaps:     27,201 = 27,201 (tiles) + 745 = 745 (headers)
Cameras:      27 = 27
GT:           20 = 20
```

## Staging Destination

All data staged to `C:\Users\atayl\VoxCore\runtime\` which is symlinked from:
`C:\Users\atayl\VoxCore\out\build\x64-RelWithDebInfo\bin\RelWithDebInfo\`

The worldserver.conf `DataDir = "."` resolves these via the existing symlinks.

## Status

**COMPLETE** -- All 66337 extracted assets are generated and staged. The server can be
started against the new data once the build is updated to compile against 66337 structures.
