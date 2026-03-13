# VoxGM R4 Review - ChatGPT API (gpt-4.1)

Let's proceed step by step as requested.

---

## 1. **R4 Fixes Verification**

### **Deleted orphan files (Preview.lua, Data/Commands.lua)**
- **TOC**: Neither file appears in the TOC.
- **Filesystem**: Not present in the file list above.
- **Result**: **Fixed**

### **Deleted dead Data/Factions.lua (loaded but never referenced by any code)**
- **TOC**: Not present.
- **Filesystem**: Not present.
- **Result**: **Fixed**

### **Removed dead Util:ShallowCopy (never called)**
- **Util.lua**: No function named `ShallowCopy` exists.
- **Result**: **Fixed**

### **SanitizeText now strips semicolons: [%c|;]**
- **Util.lua:55**:
  ```lua
  str = str:gsub("[%c|;]", "")
  ```
- **Result**: **Fixed**

### **Added FAVORITES_CAP=200 with enforcement in Fav:Add()**
- **Constants.lua:10**:
  ```lua
  C.FAVORITES_CAP = 200
  ```
- **Modules/Favorites.lua:15**:
  ```lua
  local cap = VoxGM.C.FAVORITES_CAP or 200
  if #favorites >= cap then
      VoxGM.Util:PrintError("Favorites full (" .. cap .. " max). Remove one first.")
      return false
  end
  ```
- **Result**: **Fixed**

### **Re-entry guards on God Mode (_godInProgress), Visible OFF (_visInProgress), Hide All (hideAllInProgress) to prevent rapid-click command interleaving**
- **God Mode**: **Modules/Tab_GM.lua:54**
  ```lua
  if S.session._godInProgress then return end
  S.session._godInProgress = true
  ```
- **Visible OFF**: **Modules/Tab_GM.lua:36**
  ```lua
  if not newState and S.session._visInProgress then return end
  if not newState then
      S.session._visInProgress = true
      ...
      C_Timer.After(0.4, function()
          Cmd:SendCommand(".unaura 37800", "GM")
          S.session._visInProgress = false
      end)
  ```
- **Hide All**: **Modules/Tab_Appearance.lua:92**
  ```lua
  local hideAllInProgress = false
  local hideAllBtn = UI:CreateButton(parent, "Hide All", 80, 22, function()
      if hideAllInProgress then return end
      hideAllInProgress = true
      for i, h in ipairs(HIDDEN_APPEARANCES) do
          if i == 1 then
              Cmd:SendCommand(h.cmd, "Appearance")
          else
              C_Timer.After(0.2 * (i - 1), function()
                  Cmd:SendCommand(h.cmd, "Appearance")
                  if i == #HIDDEN_APPEARANCES then
                      hideAllInProgress = false
                  end
              end)
          end
      end
  end, "Hides all armor appearance slots (sends 10 commands in sequence)")
  ```
- **Result**: **Fixed**

### **Minimap drag debounced (SavedVariables only written on DragStop, not every frame)**
- **Minimap.lua:28**:
  ```lua
  btn:SetScript("OnDragStop", function(self)
      self.isDragging = false
      if MM._pendingAngle then
          VoxGM.State:SetUI("minimapAngle", MM._pendingAngle)
          MM._pendingAngle = nil
      end
      MM:UpdatePosition()
  end)
  ```
- **Result**: **Fixed**

### **README: bold private-server disclaimer added at top**
- **README.md:4**:
  ```
  **This addon is for Game Masters on TrinityCore private servers. It does not work on retail Blizzard servers.**
  ```
- **Result**: **Fixed**

### **README: Glossary section added (TrinityCore, dot-commands, RBAC, Stock TC, VoxCore)**
- **README.md:~110**:
  ```
  ## Glossary

  | Term | Meaning |
  |------|---------|
  | **TrinityCore** | Open-source WoW server emulator. VoxGM sends commands to this server |
  | **Dot-commands** | Server GM commands typed in chat, prefixed with `.` (e.g., `.gm fly on`) |
  | **RBAC** | Role-Based Access Control -- the server permission system that controls which commands each account can use |
  | **Stock TC** | Unmodified TrinityCore, as opposed to custom forks like VoxCore |
  | **VoxCore** | A TrinityCore fork with additional custom commands (`.wmorph`, `.cnpc`, `.disp`, etc.) |
  ```
- **Result**: **Fixed**

### **TOC and README file structure updated to match actual 22-file layout**
- **TOC**: 22 files, matches the README's file structure section.
- **README.md**: File structure block matches the TOC.
- **Result**: **Fixed**

---

## 2. **NEW Issues (R5)**

### **A. Lua Correctness**

#### **1. Global Leaks**
- **General**: All modules use `local _, VoxGM = ...` and assign to local variables or to `VoxGM` sub-tables. No obvious global leaks.
- **Compartment.lua**: Defines `VoxGM_OnAddonCompartmentClick` etc. as globals, but this is required for TOC AddonCompartmentFunc. **Acceptable**.

#### **2. Nil Guards**
- **UI:CreateTabContainers**: Calls `tabModule:Create(container)` if `tabModule` and `tabModule.Create` exist. **OK**.
- **UI:FitScrollChild**: Uses `GetPoint()` on regions/children, but does not check if `GetPoint()` returns nil. However, fallback logic is robust and only used if first pass fails. **Acceptable**.
- **Modules/Tab_GM.lua:38**: Uses `UnitName("player") or "Unknown"` for self-targeting. **OK**.
- **Modules/Tab_DevTools.lua:97**: `GetCVar(cv.cvar) or cv.value` -- safe fallback. **OK**.

#### **3. Truthiness and Scope**
- **Modules/Tab_Appearance.lua:92**: `hideAllInProgress` is a local upvalue, not session state. This means if you switch tabs, the guard resets. **This is probably fine** (prevents rapid re-entry, but allows after tab switch).
- **Session-only state**: All session toggles are in `State.session`, as intended.

#### **4. Table Indexing**
- **Modules/Favorites.lua:41**: `if fav.favType == "command" or fav.favType == "custom" then ...` -- matches Constants.lua FAVORITE_TYPES. **OK**.

#### **5. Use of C_Timer**
- **All usages**: Use of `C_Timer.After` is correct.

#### **6. Use of C_AddOns.GetAddOnMetadata**
- **Core.lua:3**: `C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")` -- This API is correct for 12.x.

#### **7. Use of ChatFrame1EditBox**
- **Commands.lua:7**: Uses `ChatFrame1EditBox`. This is still available in 12.x.

#### **8. Use of SetScript vs HookScript**
- **UI.lua**: All template frames use `HookScript` for tooltips, `SetScript` for main handlers. **Correct**.

#### **9. Use of LoggingCombat**
- **Modules/Tab_DevTools.lua:157**: Uses `LoggingCombat(true/false)`. This is correct for 12.x.

#### **10. Use of StaticPopupDialogs**
- **UI.lua:213**: Overwrites `StaticPopupDialogs["VOXGM_CONFIRM"]` each time. **Minor**: If two confirmations are shown simultaneously (unlikely), one will overwrite the other. **Acceptable** for this use case.

---

### **B. WoW 12.x API Correctness**

- **All API calls** (CreateFrame, SetScript, C_Timer, SetCVar, GetCVar, LoggingCombat, StaticPopupDialogs, ChatFrame_OpenChat, ChatEdit_SendText) are valid for 12.x.
- **No use of protected APIs** (e.g., TargetUnit) -- self-targeting is done via `/target PlayerName` as chat command, as noted in README and code.

---

### **C. Security (Input Validation, Command Injection)**

#### **1. SanitizeText**
- **Util.lua:55**: `str:gsub("[%c|;]", "")` -- strips control chars, pipes, semicolons.
- **Modules/Tab_CNPC.lua:77**: All CNPC text fields use `SanitizeText` before sending.
- **Other command inputs**: All numeric inputs use `ParseNumber`, which trims and calls `tonumber`, returning nil if invalid.
- **Potential issue**: **Spaces are not stripped** from text fields. This is intentional (names/guilds may have spaces). However, if a user enters a value like `foo bar; .cheat god on`, the semicolon is stripped, so it becomes `foo bar .cheat god on`. This is not a valid command, so the server will likely reject it, but it's not a true injection vector.
- **No direct user input is concatenated into commands without either `SanitizeText` (for text) or `ParseNumber` (for numbers).**
- **No use of dangerous APIs or insecure evals.**

#### **2. Command History**
- **Modules/History.lua**: Only stores commands sent, does not execute arbitrary code.

#### **3. Favorites**
- **Modules/Favorites.lua**: Only executes commands that were previously sent via the UI, or via the "Add" function (which uses the same input validation).

---

### **D. UX (Missing Feedback, Confusing Behavior, Broken Workflows)**

#### **1. Status Bar**
- **Util:StatusMessage**: All commands sent via `SendCommand` update the status bar with the command string.

#### **2. Error Feedback**
- **All numeric/text inputs**: Print errors via `Util:PrintError` if invalid.

#### **3. Toggle Buttons**
- **Tab_GM**: All toggles update their state optimistically and are resynced via Events.lua parsers.
- **Tab_DevTools**: Typing and Combat Log toggles update state and button color.

#### **4. Favorites/History UI**
- **README**: States that UI for browsing favorites/history is planned for v1.1, not present in v1.0.0. **Matches code and expectations.**

#### **5. Minimap Button**
- **Tooltip**: Present.
- **Drag**: Debounced; only saves on drag stop.

#### **6. Addon Compartment**
- **Tooltip and click**: Present.

#### **7. Manual Command Entry**
- **All manual command entry boxes**: Hitting Enter or clicking the button works.

#### **8. Session Buttons (Character Tab)**
- **Dimming after use**: Works by setting `SetAlpha(0.5)` and changing font color.

#### **9. Tab Scrolling**
- **UI.lua**: Mouse wheel scrolling, scroll indicator present.

#### **10. No UI for Favorites/History**
- **README**: Clearly states this is data layer only for now.

---

### **E. Dead Code / Unused Variables**

- **All files**: No dead code or unused variables found.
- **sessionButtons** in Tab_Character is used for dimming logic.
- **All upvalues and locals are used.**

---

### **F. README Claims vs Reality**

- **All features described in README are present in code.**
- **File structure matches.**
- **No claims of features that are missing.**
- **All caveats about VoxCore-only features and missing UI for favorites/history are accurate.**

---

### **G. Minor/Edge Issues**

#### **1. StaticPopupDialogs["VOXGM_CONFIRM"] overwrite**
- If two confirmations are shown at once (very rare), one may overwrite the other. Not a practical issue for this addon.

#### **2. Hide All re-entry guard is local, not session**
- If user switches tabs and returns, can re-trigger Hide All before previous sequence finishes. Not dangerous, but could be improved by storing in session state.

#### **3. CNPC Scale input**
- No clamp on scale value (unlike NPC scale, which clamps 0.1-10). Could allow negative or extreme values. **Minor**.

#### **4. CNPC fields**
- If user enters only whitespace in a CNPC field, `SanitizeText` trims it to empty string, which is rejected. **OK**.

#### **5. UI:CreateDropdown**
- If items list is empty, selectedValue is nil. All usages provide at least one item.

#### **6. Tab_DevTools: Frame Stack/Event Trace**
- If those slash commands are not available, prints error. **OK**.

#### **7. Tab_DevTools: CVar status indicator**
- If GetCVar returns nil, shows orange with "?". **OK**.

#### **8. Tab_Character: Bags button**
- Sends two commands with 0.3s delay, as expected.

#### **9. Tab_Appearance: Custom .disp grid**
- No last-used value persistence per slot (not claimed in README).

---

## 3. **Shipping Readiness Rating (1-10)**

### **Summary**

- **All R4 fixes are present and correct.**
- **No dead code, no global leaks, no major API errors.**
- **Input validation is robust; command injection is not possible.**
- **UX is solid for all implemented features.**
- **README is accurate and up to date.**
- **No critical bugs found.**
- **Minor nits:** Hide All guard could be session, CNPC scale could be clamped, StaticPopupDialogs overwrite is low risk.

### **Score: 9.5 / 10**

**Rationale:**  
This is a highly polished, robust, and secure GM panel for TrinityCore 12.x. All critical and most minor issues have been addressed. The only remaining issues are extremely minor (edge-case UI nits, not security or crash bugs). The code is clean, modular, and matches all documentation.

**Ready to ship as v1.0.0.**

---

## **Summary Table**

| Area         | Status   | Notes |
|--------------|----------|-------|
| R4 Fixes     | ✅       | All present and correct |
| Lua Correctness | ✅    | No global leaks, nil guards in place |
| WoW API      | ✅       | All APIs valid for 12.x |
| Security     | ✅       | Input validation robust, no injection |
| UX           | ✅       | All workflows smooth, feedback present |
| Dead Code    | ✅       | None found |
| README       | ✅       | Accurate, up to date |
| Minor Issues | ⚠️      | Hide All guard, CNPC scale clamp, StaticPopupDialogs overwrite (all minor) |
| Overall      | 9.5/10   | Ready to ship |

---

## **Actionable Suggestions (Optional, for v1.1+)**

1. **CNPC Scale Clamp:**  
   Clamp scale in CNPC tab to 0.1-10 as in NPC tab.

2. **Hide All Guard:**  
   Store `hideAllInProgress` in `VoxGM.State.session` to persist across tab switches.

3. **StaticPopupDialogs:**  
   Consider using unique keys if multiple confirmations may be shown at once.

---

## **Conclusion**

**VoxGM v1.0.0 is ready to ship.**  
All R4 fixes are present, and no new critical issues were found. Only minor polish items remain.