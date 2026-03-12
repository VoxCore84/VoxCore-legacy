-- Strip pipe and newline chars that would break the export format
local function SanitizeName(name)
    if not name then return "Unknown" end
    return name:gsub("[|\n\r]", "")
end

function BestiaryForge_Export()
    if not BestiaryForgeDB or not BestiaryForgeDB.creatures then
        print("|cff00ccff[BestiaryForge]|r No data to export.")
        return
    end

    local lines = {"BFEXPORT:v1"}
    local creatureCount = 0

    local entries = {}
    for entry in pairs(BestiaryForgeDB.creatures) do
        entries[#entries + 1] = entry
    end
    table.sort(entries)

    for _, entry in ipairs(entries) do
        local creature = BestiaryForgeDB.creatures[entry]
        local parts = {entry .. ":" .. SanitizeName(creature.name)}

        -- Sort spells by cast count descending
        local spellList = {}
        for spellId, spell in pairs(creature.spells or {}) do
            spellList[#spellList + 1] = {id = spellId, data = spell}
        end
        table.sort(spellList, function(a, b)
            local ac, bc = (a.data.castCount or 0), (b.data.castCount or 0)
            if ac ~= bc then return ac > bc end
            return a.id < b.id
        end)

        for _, s in ipairs(spellList) do
            local total = (s.data.castCount or 0) + (s.data.auraCount or 0)
            parts[#parts + 1] = s.id .. ":" .. total .. ":" .. (s.data.school or 0) .. ":" .. SanitizeName(s.data.name)
        end

        lines[#lines + 1] = table.concat(parts, "|")
        creatureCount = creatureCount + 1
    end

    lines[#lines + 1] = "END"
    local exportText = table.concat(lines, "\n")

    -- Reusable export frame with scrollable editbox
    if not BestiaryForgeExportFrame then
        local f = CreateFrame("Frame", "BestiaryForgeExportFrame", UIParent, "BasicFrameTemplateWithInset")
        f:SetSize(620, 400)
        f:SetPoint("CENTER")
        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", f.StartMoving)
        f:SetScript("OnDragStop", f.StopMovingOrSizing)
        f:SetFrameStrata("DIALOG")

        local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        title:SetPoint("TOP", f, "TOP", 0, -5)
        title:SetText("BestiaryForge Export")

        local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 12, -30)
        scroll:SetPoint("BOTTOMRIGHT", -30, 10)

        local editBox = CreateFrame("EditBox", nil, scroll)
        editBox:SetMultiLine(true)
        editBox:SetAutoFocus(false)
        editBox:SetFontObject(ChatFontNormal)
        editBox:SetWidth(555)
        editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        scroll:SetScrollChild(editBox)

        f.editBox = editBox
        tinsert(UISpecialFrames, "BestiaryForgeExportFrame")
    end

    BestiaryForgeExportFrame.editBox:SetText(exportText)
    BestiaryForgeExportFrame:Show()
    BestiaryForgeExportFrame.editBox:HighlightText()
    BestiaryForgeExportFrame.editBox:SetFocus()

    print("|cff00ccff[BestiaryForge]|r Exported " .. creatureCount .. " creatures. Copy from the window (Ctrl+A, Ctrl+C).")
end
