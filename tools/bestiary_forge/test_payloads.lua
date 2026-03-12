-- Mock WoW API environment for testing the payload logic
local _passedCount = 0
local _failedCount = 0

function print(msg)
    io.write(msg .. "\n")
end

-- Mock WoW Constants & Globals
bitband = bit32 and bit32.band or function(a, b) return 0 end
GetTime = os.clock
time = os.time

BestiaryForgeDB = {
    creatures = {},
    spellBlacklist = {},
    creatureBlacklist = {}
}

local TRACKED_EVENTS = { SPELL_CAST_SUCCESS = true }
local TYPE_NPC = 0x00000800
local HOSTILE_FLAG = 0x00000040
local TYPE_PLAYER = 0x00000400
local _bitband = bitband

local function ExtractCreatureEntry(guid)
    if not guid then return nil end
    local parts = {}
    for part in string.gmatch(guid, "[^-]+") do
        table.insert(parts, part)
    end
    if parts[1] == "Creature" then
        return tonumber(parts[6])
    end
    return nil
end

local cleuCount = 0
local debugMode = false
local debugThrottle = 0

-- THE TARGET FUNCTION (Extracted directly from BestiaryForge.lua)
local function OnCombatLogEvent(...)
    local args = {...}
    if type(args[1]) == "table" then
        args = args[1]
    end

    local ts, subevent, hideCaster,
          sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags,
          spellId, spellName, spellSchool

    if #args > 2 then
        ts, subevent, hideCaster,
        sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
        destGUID, destName, destFlags, destRaidFlags,
        spellId, spellName, spellSchool = unpack(args, 1, 14)
    else
        local fn = CombatLogGetCurrentEventInfo or (C_CombatLog and C_CombatLog.GetCurrentEventInfo)
        if fn then
            ts, subevent, hideCaster,
            sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
            destGUID, destName, destFlags, destRaidFlags,
            spellId, spellName, spellSchool = fn()
        else
            return "NO_PAYLOAD_AND_NO_API"
        end
    end

    cleuCount = cleuCount + 1

    if not subevent then return "NIL_SUBEVENT" end
    if not spellId or spellId == 0 then return "NIL_SPELL" end
    if not sourceFlags then return "NIL_SOURCE_FLAGS" end
    if _bitband(sourceFlags, TYPE_PLAYER) ~= 0 then return "IS_PLAYER" end
    if _bitband(sourceFlags, TYPE_NPC) == 0 then return "NOT_NPC" end
    if _bitband(sourceFlags, HOSTILE_FLAG) == 0 then return "NOT_HOSTILE" end
    
    local creatureEntry = ExtractCreatureEntry(sourceGUID)
    if not creatureEntry then return "BAD_GUID" end

    -- Success path simulation complete
    return "SUCCESS_PROCESSED"
end

-- ==========================================
-- TEST HARNESS
-- ==========================================

local function runTest(name, expected, ...)
    local result = OnCombatLogEvent(...)
    if result == expected then
        print("[PASS] " .. name)
        _passedCount = _passedCount + 1
    else
        print("[FAIL] " .. name .. " (Expected: " .. tostring(expected) .. ", Got: " .. tostring(result) .. ")")
        _failedCount = _failedCount + 1
    end
end

print("--- Running BestiaryForge Adversarial Tests ---")

-- Test 1: Empty args, no API
CombatLogGetCurrentEventInfo = nil
C_CombatLog = nil
runTest("Empty args, no API", "NO_PAYLOAD_AND_NO_API")

-- Test 2: Standard varargs, but missing data
runTest("Missing data (too short)", "NIL_SUBEVENT", 123456)

-- Test 3: Standard varargs, good payload, but player
runTest("Valid payload (Player cast)", "IS_PLAYER", 
    123456, "SPELL_CAST_SUCCESS", false, 
    "Player-123-456", "PlayerOne", TYPE_PLAYER, 0,
    "Creature-0-0-0-0-999", "Target", 0, 0,
    1337, "Fireball", 0)

-- Test 4: Standard varargs, valid hostile NPC payload
runTest("Valid hostile NPC payload in varargs", "SUCCESS_PROCESSED", 
    123456, "SPELL_CAST_SUCCESS", false, 
    "Creature-0-0-0-0-12345", "Dragon", bit32.bor(TYPE_NPC, HOSTILE_FLAG), 0,
    "Player-123-456", "Target", 0, 0,
    1337, "FireBreath", 4)

-- Test 5: Table payload (11.0 format), valid hostile NPC
runTest("Valid hostile NPC payload in TABLE", "SUCCESS_PROCESSED", 
    {
        123456, "SPELL_CAST_SUCCESS", false, 
        "Creature-0-0-0-0-99999", "Ogre", bit32.bor(TYPE_NPC, HOSTILE_FLAG), 0,
        "Player-123-456", "Target", 0, 0,
        999, "Smash", 1
    }
)

-- Test 6: Nil payload with API fallback (GTFO behavior)
CombatLogGetCurrentEventInfo = function()
    return 123456, "SPELL_CAST_SUCCESS", false, 
    "Creature-0-0-0-0-11111", "Goblin", bit32.bor(TYPE_NPC, HOSTILE_FLAG), 0,
    "Player-123-456", "Target", 0, 0,
    555, "Stab", 1
end

runTest("Empty args, API fallback exists", "SUCCESS_PROCESSED")

-- Test 7: Malformed GUID (causes ExtractCreatureEntry to return nil)
runTest("Malformed GUID string", "BAD_GUID", 
    123456, "SPELL_CAST_SUCCESS", false, 
    "GARBAGE-STRING", "Glitch", bit32.bor(TYPE_NPC, HOSTILE_FLAG), 0,
    "Player-123-456", "Target", 0, 0,
    1337, "GlitchBolt", 0)

-- Test 8: Nasty type injection (boolean instead of number for flags)
runTest("Garbage types in payload (Flags=boolean)", "NIL_SOURCE_FLAGS", 
    {
        123456, "SPELL_CAST_SUCCESS", false, 
        "Creature-0-0-0-0-99999", "Ogre", false, 0,
        "Player-123-456", "Target", 0, 0,
        999, "Smash", 1
    }
)

print("-----------------------------------------------")
print("Tests complete. Passed: " .. _passedCount .. ", Failed: " .. _failedCount)
if _failedCount > 0 then os.exit(1) end
