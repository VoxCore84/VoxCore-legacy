# Compile Error Fix

You are fixing compile errors in VoxCore, a TrinityCore-based WoW server (C++20, MSVC).

## Compile Errors
{errors}

## Source Files
{source_files}

## Coding Conventions
- C++20, `#pragma once`, 4-space indent, 160 max line
- `TC_GAME_API` on game classes, `sFoo` singleton macros
- `RegisterSpellScript(ClassName)` for spell scripts
- `#include "..."` for TC headers, `#include <...>` for system

## Rules
- Fix ONLY the compile errors shown. Do not refactor or improve other code.
- Output your fixes as structured file edits.

## Required Output Format
For each file that needs changes, output:

FILE: path/to/file.cpp
```cpp
// Show the complete corrected function or section, with enough context to locate it
```

If a fix requires adding an #include, show it separately.
