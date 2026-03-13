# VoxGM R6 Review - ChatGPT API (gpt-4.1)

## 1. R5 Fix Verification

### a) State migration always backfills missing keys regardless of schemaVersion (future-proof)
- **State.lua:38-56**: The `Migrate()` function now always backfills missing keys from `DEFAULTS`, regardless of schemaVersion. This is present and correct.

### b) Commands.lua resolves ACTIVE_CHAT_EDIT_BOX before ChatFrame1EditBox, with re-resolve after ChatFrame_OpenChat
- **Commands.lua:7-18**: The code first checks `ACTIVE_CHAT_EDIT_BOX` or `ChatFrame1EditBox`, and after `ChatFrame_OpenChat("")`, it re-resolves the edit box. This is present and correct.

### c) Dropdown popup parented to UIParent (not button) to prevent scroll-frame clipping
- **UI.lua:164**: The dropdown popup is created as a child of `UIParent`, not the button. This is present and correct.

### d) All 6 event parser patterns anchored with ^
- **Events.lua:45-73**: All patterns start with `^` (e.g., `^GM mode (.+)`, `^[Ff]ly[%s%w]* (.+)`, etc.). This is present and correct.

### e) Minimap drag-click suppression via wasDragged flag + 50ms C_Timer clear
- **Minimap.lua:25-36, 43-47**: `wasDragged` is set on drag start, cleared after 0.05s on drag stop, and checked in the click handler. This is present and correct.

### f) /vgm minimap slash command added (toggles minimapHidden with create-on-restore)
- **Core.lua:41-52**: `/vgm minimap` toggles minimap button visibility, and creates the button if needed. This is present and correct.

### g) CNPC scale clamped 0.1-10
- **Modules/Tab_CNPC.lua:110-117**: `doSetCNPCScale()` clamps the value to 0.1-10. This is present and correct.

### h) README documents reload desync behavior and /vgm minimap command
- **README.md**: The `/vgm minimap` command is documented in the Slash Commands table, and reload desync is explained under Technical Notes. This is present and correct.

**Conclusion:** All R5 fixes are present and correctly implemented.

---

## 2. New Issues (R6 Review)

### Lua Correctness

#### a) Global Leaks

- **Modules/Tab_Character.lua:6**  
  `sessionButtons = {}` is declared at file scope, but not local. This leaks `sessionButtons` as a global.
  - **Fix:** Add `local` before `sessionButtons`.

#### b) Use of `self:GetFontString()` on UIPanelButtonTemplate

- **Modules/Tab_Character.lua:13, 20, 74, 82**  
  `btn:GetFontString():SetTextColor(...)` is called on buttons created with `UI:CreateButton`, which uses `UIPanelButtonTemplate`.  
  - In modern WoW, `UIPanelButtonTemplate` does not have a `GetFontString()` method; instead, you should use `btn.text` (as set in `UI:CreateButton`).  
  - **Impact:** If `GetFontString()` returns nil, this will error.
  - **Fix:** Use `btn.text:SetTextColor(...)` instead.

#### c) Use of `SetTextColor` on nil

- **Modules/Tab_Character.lua:20, 74, 82**  
  If `btn:GetFontString()` returns nil, this will error. See above.

#### d) Use of `box.onEnter = function ...` but in `UI:CreateEditBox` the handler is called as `self:onEnter()`

- **UI.lua:69**  
  The code calls `if self.onEnter then self:onEnter() end` (note the colon), but all assignments are `box.onEnter = function() ... end` (dot, not colon).  
  - **Impact:** This will not pass `self` as the first argument, but the handler is always defined as `function() ... end` (no arguments), so this is harmless, but inconsistent.
  - **Fix:** For clarity, use `self.onEnter(self)` or `self.onEnter()` consistently.

#### e) `box.onChanged` handler in `UI:CreateEditBox` is never used

- **UI.lua:62**  
  The `onChanged` handler is referenced, but no code in the addon assigns `onChanged` to any edit box.  
  - **Impact:** Dead code.
  - **Fix:** Remove or document.

#### f) `box.placeholder` fontstring is created but never explicitly hidden on creation

- **UI.lua:60**  
  When a placeholder is created, its visibility is not set. If the box is non-empty at creation, the placeholder may be visible.  
  - **Impact:** Minor visual bug.
  - **Fix:** After creation, set `box.placeholder:Show()` or `:Hide()` depending on `box:GetText()`.

#### g) `box.onEnter` is called on Enter, but not on losing focus

- **UI.lua:69**  
  Some users expect pressing Tab or clicking away to also trigger the action (e.g., "Set" for an edit box).  
  - **Impact:** Usability.
  - **Fix:** Consider calling `onEnter` on `OnEditFocusLost` as well.

#### h) `doSetCNPCScale()` in Tab_CNPC does not print error if value is invalid

- **Modules/Tab_CNPC.lua:115**  
  If the value is not valid, nothing happens (no error printed).
  - **Fix:** Add `else VoxGM.Util:PrintError("Enter a valid scale value.") end`

#### i) `doSetField()` in Tab_CNPC does not check for dangerous input (e.g., spaces, semicolons)

- **Modules/Tab_CNPC.lua:99**  
  Uses `VoxGM.Util:SanitizeText`, which removes control chars, pipes, semicolons, but not spaces or quotes.  
  - **Impact:** Spaces are allowed in names, but quotes could be used for injection if the server is vulnerable.  
  - **Fix:** Consider hardening `SanitizeText` or documenting that server-side must be robust.

### WoW 12.x API Correctness

#### a) Use of `C_Timer` is correct for 12.x

- **All usages**: `C_Timer` is available in 12.x.

#### b) Use of `SetBackdrop` on frames

- **UI.lua:110, 136**  
  Uses `"BackdropTemplate"` and `SetBackdrop`. In 12.x, this is correct.

#### c) Use of `SetCVar` and `GetCVar`

- **Modules/Tab_DevTools.lua:38, 54, 65, 73, 78**  
  These APIs are present in 12.x.

#### d) Use of `LoggingCombat`

- **Modules/Tab_DevTools.lua:120**  
  `LoggingCombat` is available in 12.x.

#### e) Use of `SlashCmdList["FRAMESTACK"]` and `["EVENTTRACE"]`

- **Modules/Tab_DevTools.lua:29, 36**  
  These are present in 12.x, but may not be loaded unless the user has `/console scriptErrors 1` or similar. The code already checks for nil.

### Security

#### a) Command Injection

- **Util.lua:54**  
  `SanitizeText` removes control characters, pipes, and semicolons.  
  - **Impact:** This blocks most command injection, but does not remove quotes or spaces.
  - **Note:** Spaces are needed for names, but quotes could be dangerous if the server is not robust.
  - **Fix:** Consider removing quotes, or at least documenting the risk.

#### b) Numeric input validation

- **Util.lua:44**  
  `ValidateNumericInput` clamps values and prints errors.

#### c) All command sends use `SanitizeText` or numeric parsing

- **Review:** All user-editable text fields for command payloads use either `ParseNumber` or `SanitizeText`. This is sufficient for client-side, but server-side must still be robust.

### UX

#### a) No feedback if minimap button is hidden via `/vgm minimap` and user reloads UI

- **Minimap.lua:7**  
  On `:Init()`, if `minimapHidden` is true, the button is not created.  
  - **Impact:** User may forget how to restore it.  
  - **Mitigation:** The print message in `/vgm minimap` tells user how to restore.

#### b) No UI for Favorites or History (planned for v1.1)

- **README.md**  
  Data layers exist, but no UI for browsing history or favorites.  
  - **Impact:** Not a bug, but a missing feature.

#### c) No error if user tries to set CNPC scale to invalid value

- **Modules/Tab_CNPC.lua:115**  
  See above.

#### d) Some buttons (e.g., "Set" for CNPC fields) do not clear the edit box after use

- **All tabs**  
  After sending a command, the edit box remains populated.  
  - **Impact:** Not necessarily a bug, but could be improved for workflow.

#### e) Some edit boxes (e.g., NPC Aura) accept invalid input (e.g., blank, non-numeric)

- **Modules/Tab_NPC.lua:153**  
  Error is printed if input is invalid.

#### f) "Hide All" in Appearance tab can be spammed, but has a re-entry guard

- **Modules/Tab_Appearance.lua:102**  
  `hideAllInProgress` prevents re-entry until the sequence is done.

#### g) "Set" buttons for CVars do not validate input format

- **Modules/Tab_DevTools.lua:73**  
  User can enter any string, which is set as the CVar value.  
  - **Impact:** Could break client settings, but is expected for dev tools.

### Dead Code or Unused Variables

#### a) `onChanged` handler in `UI:CreateEditBox` is never used

- **UI.lua:62**  
  See above.

#### b) `host == popup` checks in dropdown code are a bit convoluted

- **UI.lua:207**  
  Not a bug, just minor code style.

### README Claims vs Reality

- **All features described in README are present.**
- **Favorites and History UI** is marked as "planned for v1.1" and is not present, which matches the code.
- **Reload desync and minimap command** are documented.
- **No server-side components** is accurate.

---

## 3. What Would I Do Differently (Unlimited Authority)

### a) **Architecture**

- **Modularize UI further:**  
  Use a true widget/component system for all controls (e.g., AceGUI-like), to reduce code duplication and improve maintainability.
- **Abstract command templates:**  
  Store all command templates and argument validation in data, not code, to allow easier extension and localization.
- **Event-driven state:**  
  Use a more robust event system for state changes and UI updates, to decouple logic from UI.

### b) **UX**

- **Full UI for Favorites and History:**  
  Add tabbed browsers for command history and favorites, with search, filtering, and one-click resend/execute.
- **Command preview and undo:**  
  Show a preview of the command to be sent, and allow undo for reversible actions (where possible).
- **Inline help/tooltips everywhere:**  
  Every field and button should have clear tooltips, error messages, and contextual help.
- **Better error handling:**  
  Parse more server responses for error messages and display them in the status bar.
- **Theme/skin support:**  
  Allow users to customize the look and feel.

### c) **Capabilities**

- **Server-side API (optional):**  
  If possible, add a secure server-side API for GM commands, allowing for richer feedback, confirmation, and error handling (with proper authentication).
- **Multi-account support:**  
  Allow switching between GM accounts, with per-account settings.
- **Audit log export:**  
  Allow exporting command history for audit/compliance.
- **Macro import/export:**  
  Allow importing existing macros as favorites.

### d) **Testing**

- **Automated UI tests:**  
  Use a WoW UI test harness (e.g., WoWUnit, or custom) to simulate user input and verify all workflows.
- **Static analysis:**  
  Run LuaCheck and other tools to catch global leaks, unused variables, and API misuse.
- **Localization:**  
  Prepare for multi-language support.

### e) **Distribution**

- **CurseForge/Wago.io release:**  
  Package for easy install/update.
- **Auto-update checker:**  
  Notify users of new versions.

---

## 4. Shipping Readiness (1-10)

**Score: 8/10**

### Rationale

- **Strengths:**
  - All core features work as described.
  - No critical bugs or crashes.
  - Good input validation and security for a client-side addon.
  - All R5 fixes are present and correct.
  - Code is readable and well-structured for a non-Ace3 addon.

- **Weaknesses:**
  - Minor global leak (`sessionButtons`).
  - Potential error if `GetFontString()` returns nil (should use `btn.text`).
  - Minor dead code (`onChanged` handler).
  - Some minor UX polish missing (edit box clearing, error feedback in a few places).
  - No UI for favorites/history yet (but this is documented as planned).
  - Security: `SanitizeText` could be hardened further for quotes, but risk is low if server is robust.

**Conclusion:**  
VoxGM is ready for release as a v1.0.0, with only minor polish and technical debt. No showstopper bugs or security issues. The code is robust for its intended audience (GMs on private servers). The missing features are enhancements, not blockers.