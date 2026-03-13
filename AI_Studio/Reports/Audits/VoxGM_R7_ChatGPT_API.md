# VoxGM R7 Review -- ChatGPT API (gpt-5.4)

**Date**: 2026-03-13
**Round**: 7
**Tokens**: prompt=27360, completion=3975, total=31335

---

Here’s a focused Round 7 review.

## 1. Verification of claimed R6 fixes

### 1) Dead `onChanged` handler removed from `UI:CreateEditBox`
**Verified.**  
In `UI.lua`, `UI:CreateEditBox()` now only wires:
- `OnTextChanged` for placeholder visibility
- `OnEditFocusGained`
- `OnEditFocusLost`
- `OnEscapePressed`
- `OnEnterPressed`

There is **no dead `self.onChanged` invocation** anymore.  
Ref: `UI.lua`, function `CreateEditBox`.

---

### 2) Added error message when CNPC scale value is invalid
**Verified.**  
`Modules/Tab_CNPC.lua`:
```lua
local function doSetCNPCScale()
    local val = VoxGM.Util:ParseNumber(self.cnpcScaleBox:GetText())
    if val then
        val = VoxGM.Util:Clamp(val, 0.1, 10)
        Cmd:SendCommand(".cnpc set scale " .. val, "CNPC")
    else
        VoxGM.Util:PrintError("Enter a valid scale value (0.1-10).")
    end
end
```
This fix is present.  
Ref: `Modules/Tab_CNPC.lua`, CNPC Scale section.

---

### 3) Dropdown first-click bug fixed
**Verified.**  
In `UI.lua`, inside `CreateDropdown()`, after popup creation:
```lua
container.popup = popup
end
container.popup:Show()
```
So first click now actually shows the popup.  
Ref: `UI.lua`, `CreateDropdown`, button `OnClick`.

---

### 4) Dropdown orphan bug fixed
**Verified.**  
Dropdowns are tracked:
```lua
if not self._dropdowns then self._dropdowns = {} end
table.insert(self._dropdowns, container)
```
And closed on:
- main frame hide:
```lua
f:HookScript("OnHide", function()
    if self._dropdowns then
        for _, dd in ipairs(self._dropdowns) do
            if dd.popup and dd.popup:IsShown() then dd.popup:Hide() end
        end
    end
end)
```
- tab switch:
```lua
if self._dropdowns then
    for _, dd in ipairs(self._dropdowns) do
        if dd.popup and dd.popup:IsShown() then dd.popup:Hide() end
    end
end
```
Since popup `OnHide` hides the click-catcher, both are cleaned up.  
Ref: `UI.lua`, `CreateDropdown`; `UI:Init`; `UI:SelectTab`.

---

### 5) `helm` → `head` fixed
**Verified.**  
`Modules/Tab_Appearance.lua`:
```lua
{ label = "Head", cmd = ".disp head 134110" },
```
And `Data/Slots.lua` also uses `"head"`.  
README also says “head”.  
Ref: `Modules/Tab_Appearance.lua`, `HIDDEN_APPEARANCES`; `Data/Slots.lua`; `README.md`.

---

### 6) Integer-only ID validation via `Util:ParseID()` applied broadly
**Mostly verified; appears correctly applied to all critical ID inputs.**

`Util.lua`:
```lua
function Util:ParseID(str)
    local n = self:ParseNumber(str)
    if not n then return nil end
    if n ~= math.floor(n) or n < 1 then return nil end
    return math.floor(n)
end
```

Applied in:
- NPC custom spawn entry: `Modules/Tab_NPC.lua`
- NPC custom faction: `Modules/Tab_NPC.lua`
- NPC aura / unaura spell ID: `Modules/Tab_NPC.lua`
- Character add item itemID + count: `Modules/Tab_Character.lua`
- Character learn spell: `Modules/Tab_Character.lua`
- Appearance `.wmorph`: `Modules/Tab_Appearance.lua`
- Appearance `.morph`: `Modules/Tab_Appearance.lua`
- Appearance `.disp` custom slot IDs: `Modules/Tab_Appearance.lua`
- CNPC equipment item IDs: `Modules/Tab_CNPC.lua`

I do **not** see any remaining user-entered ID fields still using `ParseNumber()` where `ParseID()` is expected.  
This fix looks real.  
Ref: `Util.lua`; `Modules/Tab_NPC.lua`; `Modules/Tab_Character.lua`; `Modules/Tab_Appearance.lua`; `Modules/Tab_CNPC.lua`.

---

### 7) Quick time buttons persist `lastUsed`
**Verified.**  
`Modules/Tab_DevTools.lua` quick buttons now do:
```lua
self.timeBox:SetText(tostring(t[2]))
S:SetLastUsed("settime", tostring(t[2]))
```
Ref: `Modules/Tab_DevTools.lua`, quick time buttons loop.

---

### 8) README updated: active chat edit box wording + head wording
**Verified.**
- README says:
  > “VoxGM sends commands through the active chat edit box…”
- README appearance section says:
  > “head, shoulders, back...”
No stale `ChatFrame1EditBox` or `helm` claims found.  
Ref: `README.md`.

---

## 2. New issues found

## A. Real Lua/API correctness issue: `unpack` may be invalid on WoW 12.x
In `Events.lua`:
```lua
parser.callback(unpack(captures))
```
Depending on client Lua environment, global `unpack` may not exist while `table.unpack` does. Modern WoW generally exposes `unpack`, but relying on it is brittle and unnecessary.

**Why it matters:** if `unpack` is nil in this environment, all parser callbacks fail at runtime on system messages.

**Recommendation:** use:
```lua
parser.callback(table.unpack(captures))
```
Ref: `Events.lua`, `Events:OnSystemMessage`.

**Severity:** Low-to-medium. Likely okay in WoW, but easy hardening win.

---

## B. CNPC “numeric identity” fields are undervalidated and allow malformed values
In `Modules/Tab_CNPC.lua`, the generic text-field loop includes:
```lua
{ label = "Display ID:", key = "displayid", placeholder = "ID" },
{ label = "Face:", key = "face", placeholder = "Face ID" },
```
But all fields are handled the same way:
```lua
local val = VoxGM.Util:SanitizeText(box:GetText())
if val ~= "" then
    Cmd:SendCommand(".cnpc set " .. field.key .. " " .. val, "CNPC")
end
```

That means `displayid` and `face` accept arbitrary sanitized text instead of strict numeric IDs.

**Why it matters:**
- Not classic command injection, because `;` and control chars are stripped.
- But it still allows malformed commands like:
  - `.cnpc set displayid abc`
  - `.cnpc set face 1 2`
- UX inconsistency: elsewhere IDs are strictly validated now.

**Recommendation:** mark fields with type metadata and validate numerics with `ParseID()`:
```lua
{ label = "Display ID:", key = "displayid", placeholder = "ID", numeric = true },
{ label = "Face:", key = "face", placeholder = "Face ID", numeric = true },
```
Then branch validation accordingly.

Ref: `Modules/Tab_CNPC.lua`, fields table and `doSetField()`.

**Severity:** Medium.

---

## C. `SanitizeText()` still allows spaces, so multi-argument CNPC text fields can send unintended extra tokens
`Util.lua`:
```lua
str = str:gsub("[%c|;]", "")
```
Spaces are preserved intentionally.

Then CNPC text fields send:
```lua
".cnpc set " .. field.key .. " " .. val
```

For fields like name/subname/guild/rank, this may be intended if server parser consumes rest-of-line. Fine.

But because the same path is reused for `displayid` and `face`, users can send values with spaces:
```lua
displayid = "123 456"
```
resulting in:
```lua
.cnpc set displayid 123 456
```
Again, not injection in the shell sense, but definitely malformed command construction.

This is mostly the same root issue as B, but worth calling out as command-shape unsafety.

Ref: `Util.lua`; `Modules/Tab_CNPC.lua`.

**Severity:** Medium-low.

---

## D. Dropdown cleanup table grows forever across UI rebuild patterns / future dynamic controls
`UI._dropdowns` is append-only:
```lua
table.insert(self._dropdowns, container)
```
There is no removal if dropdown frames are destroyed or recreated.

**Current impact:** probably negligible, because tabs are created once in `UI:Init()` and never rebuilt. So today this is harmless.

**Why mention it:** with any future tab refresh/rebuild or settings reload logic, stale entries will accumulate.

**Recommendation:** either:
- key by frame and prune dead entries on cleanup, or
- store weak references, or
- clear/rebuild `_dropdowns` during `UI:Init()`.

Ref: `UI.lua`, `CreateDropdown`.

**Severity:** Low.

---

## E. `CreateDropdown()` computes `screenH` and never uses it
In popup `OnShow`:
```lua
local _, screenH = UIParent:GetCenter()
local _, btnBottom = self:GetCenter()
if btnBottom and btnBottom < popupHeight + 40 then
```
`screenH` is dead code.

Ref: `UI.lua`, `CreateDropdown`, popup `OnShow`.

**Severity:** None; dead code cleanup.

---

## F. README overstates “Full .cnpc command coverage”
README claims:
> “Full `.cnpc` command coverage”

Actual implementation covers:
- create
- spawn
- delete
- remove variation
- set race
- set gender
- set displayname/subname/guild/rank/displayid/face
- set scale
- set tameable
- equip/unequip some slots

That is **not obviously “full coverage”** unless VoxCore’s `.cnpc` command set is exactly this small. Given the wording, this is risky.

**Recommendation:** soften to:
- “Broad `.cnpc` coverage”
- or enumerate supported subcommands

Ref: `README.md`, Custom NPC tab section; compare with `Modules/Tab_CNPC.lua`.

**Severity:** Low UX/docs issue.

---

## G. README says Character features work on stock TC, but `.maxachieve` / `.maxtitles` / maybe `.maxrep` may not be universally stock
The README says:
> “The core GM/NPC/Character features work on any TC server.”

And table says Character features use:
> `.modify money`, `.additem`, `.learn`, `.maxrep` | Yes

But Character tab also includes:
- `.maxtitles`
- `.maxachieve`
- `.profs` (explicitly VoxCore only)

I can’t verify from this code whether `.maxtitles` and `.maxachieve` are stock TrinityCore in 12.x. The README’s blanket statement is likely too broad.

**Recommendation:** narrow to “many Character features” or annotate per-command support more carefully.

Ref: `README.md`; `Modules/Tab_Character.lua`.

**Severity:** Low, but could mislead operators.

---

## H. System parser for GM mode is overly permissive and may misread unrelated text
In `Events.lua`:
```lua
self:RegisterParser("^GM mode (.+)", function(state)
    VoxGM.State.session.gmOn = (state == "on" or state == "ON" or state:find("[Oo][Nn]")) ~= nil
```
This will interpret any `state` containing “on” anywhere as on.

Examples:
- `"only for staff"` → on
- `"turned on."` → on, okay
- `"off (command only)"` contains `on` in `command only`? no, but similar edge cases exist

Same looseness appears in other parsers using `find("[Oo][Nn]")`.

Not a security issue, but state sync could be wrong on nonstandard localized/custom system messages.

**Recommendation:** tighten to exact expected outputs where possible, e.g.:
```lua
state = state:lower()
VoxGM.State.session.gmOn = state:match("^on[%p%s]*$") ~= nil
```
or support a small whitelist.

Ref: `Events.lua`, `RegisterDefaultParsers`.

**Severity:** Low.

---

## I. `combatLogOn` is not reset on fresh login while other session toggles are
In `State.session`:
```lua
combatLogOn = false,
```
In `Events:OnEnteringWorld()` reset block:
```lua
s.flyOn = false
s.gmOn = false
s.gmVisible = false
s.godMode = false
s.stealthOn = false
s.typingOn = false
s.phaseId = nil
```
`combatLogOn` and the run-once session flags (`ranMaxrep`, etc.) are **not reset** here.

Now, for a true fresh login, Lua state usually starts clean so this may not matter. But `PLAYER_ENTERING_WORLD` explicitly claims to reset session toggles on login, and does so incompletely.

**Why it matters:** inconsistency in intended semantics, especially across odd loading/reconnect flows.

**Recommendation:** reset all session-only fields there, including:
- `combatLogOn`
- `ranMaxrep`
- `ranMaxtitles`
- `ranMaxachieve`
- `ranProfs`
- `ranGoldPackage`
- transient guards `_godInProgress`, `_visInProgress`

Ref: `Events.lua`, `OnEnteringWorld`; `State.lua`, `State.session`.

**Severity:** Low.

---

## 3. What I would do differently with unlimited authority

Short version: I’d separate **command construction**, **validation**, and **UI** much more aggressively.

### 1) Introduce a typed command builder layer
Instead of many inline string concatenations like:
```lua
".cnpc set " .. field.key .. " " .. val
```
I’d define builders:
```lua
Cmd:CNPCSetScale(scale)
Cmd:CNPCSetDisplayID(id)
Cmd:NPCSetFaction(id)
Cmd:AddItem(itemID, count)
```
Each would:
- validate inputs centrally
- normalize/clamp
- return exact command strings

This would eliminate almost all malformed-command risk and make README support matrix easier to maintain.

---

### 2) Formalize input schemas per control
Every edit box would be one of:
- integer ID
- decimal range
- free text
- enum
- quantity
- optional ID

Right now validation is decent but scattered. A small schema system would make consistency much better.

---

### 3) Stop reusing the chat edit box text in-place if possible
Current dispatch:
- capture old text
- set command
- send
- restore old text

That’s pragmatic, but it still risks weirdness with active chat addons and draft preservation. If unlimited authority included tolerance for a more invasive solution, I’d investigate a safer dispatch abstraction or explicit draft-handling UX.

That said, within addon sandbox limits, current approach is understandable.

---

### 4) Add a real History/Favorites UI now, not later
The data layer exists. For GM workflows, discoverability matters. A bottom drawer or side panel with:
- recent commands
- favorite spawns
- favorite morphs
would materially improve usefulness.

---

### 5) Build a command support profile system
Since this targets stock TC and VoxCore, I’d add:
- server profile selection
- hide/disable unsupported buttons
- per-command tooltips for support status

This would reduce “button does nothing / command not found” confusion.

---

### 6) Make event parsing explicit and testable
I’d move parser rules into declarative data and write sample-message tests. Right now the regexes are simple and workable, but fragile.

---

### 7) Improve dropdown architecture
I’d replace custom dropdown popups with a reusable menu component that:
- clamps to screen
- handles ESC/outside click consistently
- does keyboard navigation
- doesn’t need global tracking hacks

Current implementation is okay, but custom popups are easy to regress.

---

### 8) Persist optional session snapshots
Even if full desync-proof persistence is deferred, I’d persist:
- last known toggle states
- whether user wants optimistic restore after reload
with clear UI copy saying “restored UI assumption, not authoritative server state.”

---

## 4. Shipping readiness: **7.5/10**

### Why not lower
The addon is in substantially better shape now:
- claimed R6 fixes are genuinely present
- major dropdown bugs were actually fixed
- integer-only ID validation is a meaningful safety improvement
- obvious dead code issue removed
- README is mostly aligned with implementation
- codebase is structured cleanly enough for a non-library addon

I do **not** see any catastrophic Lua errors guaranteed to break startup.

### Why not higher
A few things still keep it from “ship with high confidence” territory:

1. **CNPC field validation inconsistency**
   - `displayid` and `face` should not be free text.
   - This is the most concrete remaining correctness/input-quality issue.

2. **Some parser/state logic is still loose**
   - event parsing is optimistic and not very strict.
   - session reset semantics are inconsistent.

3. **Docs overclaim in places**
   - “Full .cnpc command coverage” is not supported by the visible implementation.
   - Stock TC compatibility wording is broader than the concrete command set shown.

4. **A few minor robustness nits**
   - `unpack` vs `table.unpack`
   - append-only dropdown registry
   - small dead-code leftovers

### Practical release recommendation
- **Okay for private/internal release now**
- **Okay for limited public release if README is softened**
- **Not yet ideal for “polished 1.0”** without one more pass on validation/docs

### Minimum patch set before I’d call it an 8.5+
1. Fix CNPC `displayid` and `face` to use numeric validation.
2. Change `unpack` → `table.unpack`.
3. Reset all `State.session` fields consistently in `OnEnteringWorld()`.
4. Soften README claims around `.cnpc` coverage and stock TC Character support.

If you want, I can do a **Round 7 patch-ready checklist** with exact code snippets for each remaining issue.