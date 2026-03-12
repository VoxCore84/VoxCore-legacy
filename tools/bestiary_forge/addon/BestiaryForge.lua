local VERSION = 1

local TRACKED_EVENTS = {
    SPELL_CAST_START = true,
    SPELL_CAST_SUCCESS = true,
    SPELL_AURA_APPLIED = true,
    SPELL_SUMMON = true,
    SPELL_HEAL = true,
}

local SPELL_BLACKLIST = {
    [1604] = true,    -- Dazed
    [6603] = true,    -- Auto Attack
    [75]   = true,    -- Auto Shot
    [3018] = true,    -- Shoot
    [1784] = true,    -- Stealth
    [2983] = true,    -- Sprint
    [20577] = true,   -- Cannibalize
    [7744] = true,    -- Will of the Forsaken
    [20549] = true,   -- War Stomp
    [26297] = true,   -- Berserking
}

local CREATURE_BLACKLIST = {
    [0] = true,
    [1] = true,
    [19871] = true,   -- WorldTrigger
    [21252] = true,   -- World Trigger (Large AOI)
    [22515] = true,   -- World Trigger (Large AOI, Not Immune)
}

-- Flag constants — use raw hex values directly (guaranteed correct across all clients)
local TYPE_NPC     = 0x00000800
local CONTROL_NPC  = 0x00000200
local HOSTILE_FLAG = 0x00000040
local TYPE_PLAYER  = 0x00000400

-- 11.0+ removed the bit library; standalone bitband() replaces bit.band()
local _bitband = bitband or (bit and bit.band) or function(a, b) return 0 end

local frame = CreateFrame("Frame", "BestiaryForgeFrame")
local sessionCreatures, sessionSpells = 0, 0
local currentZone = "Unknown"
local currentDifficulty = 0
local debugMode = false
local debugThrottle = 0

local function InitDB()
    if not BestiaryForgeDB or BestiaryForgeDB.version ~= VERSION then
        BestiaryForgeDB = {
            version = VERSION,
            collector = UnitName("player") .. "-" .. GetRealmName(),
            lastExport = 0,
            creatures = {},
            spellBlacklist = {},
            creatureBlacklist = {},
        }
    end
    for id in pairs(BestiaryForgeDB.spellBlacklist or {}) do
        SPELL_BLACKLIST[id] = true
    end
    for id in pairs(BestiaryForgeDB.creatureBlacklist or {}) do
        CREATURE_BLACKLIST[id] = true
    end
end

local function ExtractCreatureEntry(guid)
    if not guid then return nil end
    local unitType, _, _, _, _, npcID = strsplit("-", guid)
    if unitType == "Creature" or unitType == "Vehicle" then
        return tonumber(npcID)
    end
end

local cleuCount = 0

local function OnCombatLogEvent(...)
    if not BestiaryForgeDB then return end

    -- 11.0 / 12.0 private servers: Extract data from varargs if API is missing
    local args = {...}
    
    -- In some clients the payload is a table passed as the first arg
    if type(args[1]) == "table" then
        args = args[1]
    end

    local ts, subevent, hideCaster,
          sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags,
          spellId, spellName, spellSchool

    -- Prefer explicitly passed event arguments
    if #args >= 2 then
        ts, subevent, hideCaster,
        sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
        destGUID, destName, destFlags, destRaidFlags,
        spellId, spellName, spellSchool = unpack(args, 1, 14)
    else
        -- Fallback to API if present
        local fn = CombatLogGetCurrentEventInfo or (C_CombatLog and C_CombatLog.GetCurrentEventInfo)
        if fn then
            ts, subevent, hideCaster,
            sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
            destGUID, destName, destFlags, destRaidFlags,
            spellId, spellName, spellSchool = fn()
        else
            if debugMode then
                cleuCount = cleuCount + 1
                local now = GetTime()
                if now - debugThrottle > 2 then
                    debugThrottle = now
                    print("|cffff0000[BF #" .. cleuCount .. "]|r CLEU fired but no payload args and no GetEventInfo function exists!")
                end
            end
            return
        end
    end

    -- Raw event counter (before ANY filtering)
    cleuCount = cleuCount + 1
    if debugMode then
        local now = GetTime()
        if now - debugThrottle > 0.3 then
            debugThrottle = now
            if not subevent then
                print("|cffff0000[BF #" .. cleuCount .. "]|r CLEU fired but subevent is nil!")
            else
                local flagHex = sourceFlags and format("0x%08X", sourceFlags) or "nil"
                local entry = ExtractCreatureEntry(sourceGUID)
                local tracked = TRACKED_EVENTS[subevent] and "YES" or "no"
                local isNpc = sourceFlags and _bitband(sourceFlags, TYPE_NPC) ~= 0
                local isHostile = sourceFlags and _bitband(sourceFlags, HOSTILE_FLAG) ~= 0
                local isPlayer = sourceFlags and _bitband(sourceFlags, TYPE_PLAYER) ~= 0
                print(format("|cff00ccff[BF #%d]|r %s src=%s spell=%s[%s] flags=%s tracked=%s npc=%s hostile=%s player=%s entry=%s",
                    cleuCount, tostring(subevent), sourceName or "?",
                    spellName or "", tostring(spellId or 0), flagHex,
                    tracked, tostring(isNpc), tostring(isHostile), tostring(isPlayer),
                    tostring(entry)))
            end
        end
    end

    if not subevent then return end
    if not spellId or spellId == 0 then return end
    if SPELL_BLACKLIST[spellId] then return end

    -- Guard against nil or malformed sourceFlags (corrupted event)
    if type(sourceFlags) ~= "number" then return end

    -- Source must NOT be a player
    if _bitband(sourceFlags, TYPE_PLAYER) ~= 0 then return end

    -- Source must be an NPC (only check TYPE_NPC, not CONTROL_NPC — private servers may omit control flag)
    if _bitband(sourceFlags, TYPE_NPC) == 0 then return end

    -- Source must be hostile
    if _bitband(sourceFlags, HOSTILE_FLAG) == 0 then return end

    -- Extract creature entry (rejects Pet/Player/GameObject GUIDs by returning nil)
    local creatureEntry = ExtractCreatureEntry(sourceGUID)
    if not creatureEntry or CREATURE_BLACKLIST[creatureEntry] then return end

    local db = BestiaryForgeDB.creatures
    local now = time()

    if not db[creatureEntry] then
        db[creatureEntry] = {
            name = sourceName or "Unknown",
            spells = {},
            firstSeen = now,
            lastSeen = now,
        }
        sessionCreatures = sessionCreatures + 1
    end

    local creature = db[creatureEntry]
    creature.lastSeen = now
    if sourceName then creature.name = sourceName end

    if not creature.spells[spellId] then
        creature.spells[spellId] = {
            name = spellName or "Unknown",
            school = spellSchool or 0,
            castCount = 0,
            auraCount = 0,
            firstSeen = now,
            lastSeen = now,
            zones = {},
            difficulties = {},
        }
        sessionSpells = sessionSpells + 1
    end

    local spell = creature.spells[spellId]
    spell.lastSeen = now
    if spellName then spell.name = spellName end

    -- Only count meaningful events (not SPELL_DAMAGE/MISSED/PERIODIC ticks)
    if subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" then
        spell.auraCount = (spell.auraCount or 0) + 1
    elseif subevent == "SPELL_CAST_SUCCESS" or subevent == "SPELL_HEAL"
        or subevent == "SPELL_SUMMON" or subevent == "SPELL_ENERGIZE" then
        spell.castCount = (spell.castCount or 0) + 1
    end

    spell.zones[currentZone] = true
    spell.difficulties[currentDifficulty] = true
end

local function CountDB()
    if not BestiaryForgeDB then return 0, 0 end
    local creatures, spells = 0, 0
    for _, c in pairs(BestiaryForgeDB.creatures or {}) do
        creatures = creatures + 1
        for _ in pairs(c.spells or {}) do
            spells = spells + 1
        end
    end
    return creatures, spells
end

-- Expose for minimap tooltip and UI
function BestiaryForge_CountDB() return CountDB() end
function BestiaryForge_GetSessionStats() return sessionCreatures, sessionSpells end
function BestiaryForge_ToggleDebug() debugMode = not debugMode end
function BestiaryForge_IsDebug() return debugMode end

function BestiaryForge_IgnoreSpell(spellId)
    SPELL_BLACKLIST[spellId] = true
    if BestiaryForgeDB then
        BestiaryForgeDB.spellBlacklist[spellId] = true
    end
end

-- Addon Compartment (11.0+ minimap addon menu)
function BestiaryForge_OnCompartmentClick(_, buttonName)
    if buttonName == "RightButton" then
        BestiaryForge_Export()
    else
        BestiaryForge_ToggleUI()
    end
end

function BestiaryForge_OnCompartmentEnter(_, menuButtonFrame)
    GameTooltip:SetOwner(menuButtonFrame, "ANCHOR_LEFT")
    GameTooltip:SetText("BestiaryForge", 0, 0.8, 1)
    local totalC, totalS = CountDB()
    GameTooltip:AddLine(totalC .. " creatures, " .. totalS .. " spells tracked", 1, 1, 1)
    local sc, ss = sessionCreatures, sessionSpells
    if sc > 0 or ss > 0 then
        GameTooltip:AddLine("Session: +" .. sc .. " creatures, +" .. ss .. " spells", 0.5, 1, 0.5)
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cff00ff00Left-click|r Browser  |cff00ff00Right-click|r Export", 0.8, 0.8, 0.8)
    GameTooltip:Show()
end

function BestiaryForge_OnCompartmentLeave()
    GameTooltip:Hide()
end

-- No slash commands — all interaction is through the UI buttons and minimap icon

StaticPopupDialogs["BESTIARYFORGE_RESET"] = {
    text = "Reset all BestiaryForge data? This cannot be undone.",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        if not BestiaryForgeDB then return end
        local totalC, totalS = CountDB()
        BestiaryForgeDB.creatures = {}
        sessionCreatures, sessionSpells = 0, 0
        if BestiaryForgeBrowserFrame and BestiaryForgeBrowserFrame:IsShown() then
            BestiaryForgeBrowserFrame:Hide()
            BestiaryForge_ToggleUI()
        end
        print("|cff00ccff[BestiaryForge]|r Reset. Cleared " .. totalC .. " creatures, " .. totalS .. " spell pairs.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local function UpdateZoneCache()
    local z = GetRealZoneText()
    currentZone = (z and z ~= "") and z or "Unknown"
    currentDifficulty = select(3, GetInstanceInfo()) or 0
end

-- Match production addon pattern: GTFO registers CLEU from PLAYER_LOGIN handler.
-- This avoids the ADDON_ACTION_FORBIDDEN taint from file-load-time RegisterEvent.
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        InitDB()
        UpdateZoneCache()
        BestiaryForge_InitMinimap()
        -- Register CLEU HERE — from PLAYER_LOGIN context, same as GTFO
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        -- Fallback: Register the filtered COMBAT_LOG_EVENT since _UNFILTERED is failing on Arctium
        frame:RegisterEvent("COMBAT_LOG_EVENT")
        frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        frame:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
        local totalC, totalS = CountDB()
        print("|cff00ccff[BestiaryForge]|r v" .. VERSION .. " loaded. " .. totalC .. " creatures, " .. totalS .. " spells tracked.")
        -- Diagnostic
        local fn = CombatLogGetCurrentEventInfo or (C_CombatLog and C_CombatLog.GetCurrentEventInfo)
        print("|cff00ccff[BestiaryForge]|r  CombatLogGetCurrentEventInfo = " .. tostring(fn))
        if C_CombatLog and type(C_CombatLog) == "table" then
            local keys = {}
            for k in pairs(C_CombatLog) do keys[#keys+1] = tostring(k) end
            print("|cff00ccff[BestiaryForge]|r  C_CombatLog keys: " .. (#keys > 0 and table.concat(keys, ", ") or "EMPTY"))
        end
        print("|cff00ccff[BestiaryForge]|r  CLEU registered: " .. tostring(frame:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED")))
        print("|cff00ccff[BestiaryForge]|r  CLE registered: " .. tostring(frame:IsEventRegistered("COMBAT_LOG_EVENT")))
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_DIFFICULTY_CHANGED" then
        UpdateZoneCache()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" or event == "COMBAT_LOG_EVENT" then
        -- Pass all event arguments through to the handler for payload extraction
        OnCombatLogEvent(...)
    end
end)

-- Only register PLAYER_LOGIN at load time — everything else registers from its handler
frame:RegisterEvent("PLAYER_LOGIN")
