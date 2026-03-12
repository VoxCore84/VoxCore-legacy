-- BestiaryForge Minimap Button via LibDBIcon
-- Left-click opens browser, right-click exports, drag to reposition

local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
if not ldb then return end

local plugin = ldb:NewDataObject("BestiaryForge", {
    type = "data source",
    text = "BestiaryForge",
    icon = "Interface\\Icons\\INV_Misc_Book_09",

    OnClick = function(_, button)
        if button == "RightButton" then
            BestiaryForge_Export()
        else
            BestiaryForge_ToggleUI()
        end
    end,

    OnTooltipShow = function(tt)
        tt:AddLine("BestiaryForge", 0, 0.8, 1)

        local totalC, totalS = BestiaryForge_CountDB()
        tt:AddLine(totalC .. " creatures, " .. totalS .. " spells tracked", 1, 1, 1)

        local sc, ss = BestiaryForge_GetSessionStats()
        if sc > 0 or ss > 0 then
            tt:AddLine("Session: +" .. sc .. " creatures, +" .. ss .. " spells", 0.5, 1, 0.5)
        end

        tt:AddLine(" ")
        tt:AddLine("|cff00ff00Left-click|r to open browser", 0.8, 0.8, 0.8)
        tt:AddLine("|cff00ff00Right-click|r to export", 0.8, 0.8, 0.8)
        tt:AddLine("|cff00ff00Drag|r to reposition", 0.8, 0.8, 0.8)
    end,
})

-- Register on PLAYER_LOGIN (after DB is ready)
function BestiaryForge_InitMinimap()
    local icon = LibStub("LibDBIcon-1.0", true)
    if not icon then return end
    if not BestiaryForgeDB.minimapIcon then
        BestiaryForgeDB.minimapIcon = {}
    end
    icon:Register("BestiaryForge", plugin, BestiaryForgeDB.minimapIcon)
end
