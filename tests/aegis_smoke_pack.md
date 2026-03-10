# Aegis Config: Regression Smoke Pack

*Phase 2 Closeout Validation Layer | Status: ACTIVE | Date: 2026-03-09*

This minimal regression pack governs the verification of Phase 2 core runtime and parser migrations resulting from `TRIAD-STAB-V1A-V1E`. It ensures dynamic path resolutions (`resolve_roots.py` and `%~dp0`) do not regress across different environments.

## Prerequisite Assumptions
- `VOXCORE_ROOT` environment variables are theoretically cleared or non-existent in the target execution space.
- Desktop configurations are not guaranteed.

---

## 1. Payload Generator Execution Profile
**Target:** `tools/gen_chatgpt_payload.py`
**Validation Condition:** The script must dynamically discover its active root and write context output to the user's OS without absolute hardcoding.

- [ ] Execute `python tools/gen_chatgpt_payload.py` natively from `VOXCORE_ROOT`.
- [ ] Execute `python gen_chatgpt_payload.py` inside the `tools/` folder itself.
- [ ] Verify `chatgpt_payload_latest.txt` generates correctly on the Desktop regardless of the launch context.

---

## 2. Core Server Orchestrators (Batch Layer)
**Target:** `tools/shortcuts/start_all.bat`
**Target:** `tools/command-center/app.py`
**Validation Condition:** Sub-processes fired from the orchestrator must anchor correctly using `%~dp0` variable expansion instead of `C:\`.

- [ ] Execute `tools/shortcuts/start_all.bat`.
- [ ] Confirm no "path cannot be found" execution errors appear for `worldserver`, `authserver`, or database boots.
- [ ] Boot `python tools/command-center/app.py` and verify all linked GUI shortcut buttons still natively start the correct services.

---

## 3. Toolchain Launchers
**Target:** `tools/shortcuts/Launch_AI_Studio.bat`
**Target:** `tools/ai_studio/orchestrator.py`
**Validation Condition:** Multi-part boot loops must launch secondary code terminals correctly using native system directories rather than VoxCore hardcodes.

- [ ] Launch `tools/shortcuts/Launch_AI_Studio.bat`.
- [ ] Observe that the `claude.cmd` window instances correctly instantiate their targeted contexts.
- [ ] Observe that the `orchestrator.py` module discovers the VoxCore `/AI_Studio` root independently.

---

## 4. Pipeline & Packet Parser Hygiene
**Target:** `tools/packet_tools/packet_scope.py`
**Validation Condition:** Auto-parse pipelines must dynamically orient against `_ROOT` imports.

- [ ] Execute `python tools/packet_tools/packet_scope.py` with no arguments.
- [ ] Confirm it gracefully discovers the absolute default `out/build/.../PacketLog/World_parsed.txt` log via dynamic appending, instead of producing a generic `FileNotFoundError: C:\Users\...`.
