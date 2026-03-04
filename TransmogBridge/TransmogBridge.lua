-- TransmogBridge: Sends all outfit slot appearances and illusions to the server via addon message.
-- The 12.x client's CommitAndApplyAllPending() C++ serializer omits HEAD, MH, OH,
-- and sends stale data for all other slots. This addon uses a hybrid approach:
-- snapshot via GetViewedOutfitSlotInfo (captures outfit-loaded armor slots)
-- merged with SetPendingTransmog hooks (captures weapons, illusions, secondary shoulder,
-- tabard, shirt — slots where the snapshot is unreliable). Hook data wins on conflict.

local ADDON_PREFIX = "TMOG_BRIDGE"
local LOG_PREFIX  = "TMOG_LOG"
local pendingOverrides = {}
local pendingIllusions = {} -- slot -> SpellItemEnchantmentID (weapon enchant visuals)

-- Inventory slot names for TransmogUtil.GetTransmogLocation (Layer 3 fallback)
local INV_SLOT_NAMES = {
    [0]  = "HEADSLOT",
    [1]  = "SHOULDERSLOT",
    [3]  = "BACKSLOT",
    [4]  = "CHESTSLOT",
    [5]  = "TABARDSLOT",
    [6]  = "SHIRTSLOT",
    [7]  = "WRISTSLOT",
    [8]  = "HANDSSLOT",
    [9]  = "WAISTSLOT",
    [10] = "LEGSSLOT",
    [11] = "FEETSLOT",
    [12] = "MAINHANDSLOT",
    [13] = "SECONDARYHANDSLOT",
}

-- Check API availability once at load
local HAS_SLOT_VISUAL_INFO = C_Transmog and C_Transmog.GetSlotVisualInfo ~= nil
    and TransmogUtil and TransmogUtil.GetTransmogLocation ~= nil
    and Enum and Enum.TransmogType ~= nil

C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)
C_ChatInfo.RegisterAddonMessagePrefix(LOG_PREFIX)

-- Send log entries to the server via addon message → shows up in Debug.log
local function Log(msg)
    local entry = date("%H:%M:%S") .. " " .. msg
    -- Truncate to 255 byte addon message limit
    if #entry > 255 then entry = entry:sub(1, 255) end
    C_ChatInfo.SendAddonMessage(LOG_PREFIX, entry, "WHISPER", UnitName("player"))
end

-- Capture every SetPendingTransmog call.
-- Client slot indices (confirmed via TransmogSpy):
--   0=HEAD, 1=SHOULDER, 2=SECONDARY_SHOULDER, 3=BACK, 4=CHEST,
--   5=TABARD, 6=SHIRT, 7=WRIST, 8=HANDS, 9=WAIST, 10=LEGS,
--   11=FEET, 12=MAINHAND, 13=OFFHAND
-- tmogType: 0=appearance, 1=illusion (weapon enchant visual)
-- transmogID: IMAID (type 0) or SpellItemEnchantmentID (type 1)
hooksecurefunc(C_TransmogOutfitInfo, "SetPendingTransmog", function(slot, tmogType, option, transmogID, displayType)
    if tmogType == 1 then
        -- Illusion (weapon enchant visual): slot 12=MH, 13=OH
        pendingIllusions[slot] = transmogID or 0
        Log(string.format("SetPending illusion slot=%d enchantID=%d", slot, transmogID or 0))
        return
    end
    if tmogType ~= 0 then
        Log(string.format("SetPending SKIP type=%d slot=%d id=%d", tmogType, slot, transmogID or 0))
        return
    end
    pendingOverrides[slot] = pendingOverrides[slot] or {}
    pendingOverrides[slot].transmogID = transmogID
    pendingOverrides[slot].option = option
    Log(string.format("SetPending slot=%d IMAID=%d opt=%d", slot, transmogID or 0, option or 0))
end)

-- Clear on window close (also handles cancel — ClearAllPending doesn't exist in 12.x)
local f = CreateFrame("Frame")
f:RegisterEvent("TRANSMOGRIFY_CLOSE")
f:SetScript("OnEvent", function(self, event)
    if event == "TRANSMOGRIFY_CLOSE" then
        local count = 0
        for _ in pairs(pendingOverrides) do count = count + 1 end
        if count > 0 then
            Log(string.format("TRANSMOGRIFY_CLOSE — cleared %d pending overrides", count))
        end
        wipe(pendingOverrides)
        wipe(pendingIllusions)
    end
end)

-- Send overrides on apply (post-hook: fires after CommitAndApplyAllPending queues the CMSG)
hooksecurefunc(C_TransmogOutfitInfo, "CommitAndApplyAllPending", function(useDiscount)
    -- Hybrid merge: snapshot all slots via GetViewedOutfitSlotInfo (base layer),
    -- then overlay SetPendingTransmog accumulations on top (wins on conflict).
    -- GetViewedOutfitSlotInfo is unreliable for weapons (12, 13), secondary
    -- shoulder (2), tabard (5), and shirt (6), but SetPendingTransmog captures
    -- those correctly when the user clicks slots manually. Outfit set loading
    -- bypasses SetPendingTransmog but populates the viewed state for armor slots.
    local merged = {} -- slot -> {transmogID, option}

    -- Layer 1: snapshot from GetViewedOutfitSlotInfo (base)
    for slot = 0, 13 do
        if slot ~= 2 then -- secondary shoulder queried separately below
            local info = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(slot, 0, 0)
            if info and info.transmogID and info.transmogID > 0 then
                merged[slot] = { transmogID = info.transmogID, option = 0 }
            end
        end
    end

    -- Secondary shoulder: slot 1 with option=1
    local info2 = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(1, 0, 1)
    if info2 and info2.transmogID and info2.transmogID > 0 then
        merged[2] = { transmogID = info2.transmogID, option = 0 }
    end

    -- Layer 2: SetPendingTransmog accumulations override snapshot (wins on conflict)
    -- transmogID=0 from SetPendingTransmog means user explicitly cleared this slot
    for slot, data in pairs(pendingOverrides) do
        local tmogID = data.transmogID or 0
        if tmogID > 0 then
            merged[slot] = { transmogID = tmogID, option = data.option or 0 }
        else
            -- Explicit clear: user removed transmog from this slot via UI
            merged[slot] = { transmogID = 0, option = 0 }
            Log(string.format("Layer2 explicit clear slot=%d", slot))
        end
    end

    -- Layer 3: C_Transmog.GetSlotVisualInfo fallback for slots still missing.
    -- GetViewedOutfitSlotInfo returns nil for tabard (5), shirt (6), weapons (12, 13),
    -- and secondary shoulder during outfit loading. If SetPendingTransmog didn't fire
    -- either (outfit load, not manual click), try the old per-slot transmog API.
    if HAS_SLOT_VISUAL_INFO then
        for slot = 0, 13 do
            if not merged[slot] and slot ~= 2 then -- skip secondary shoulder (no inv slot)
                local invName = INV_SLOT_NAMES[slot]
                if invName then
                    local ok, loc = pcall(TransmogUtil.GetTransmogLocation, invName, Enum.TransmogType.Appearance, false)
                    if ok and loc then
                        local ok2, visInfo = pcall(C_Transmog.GetSlotVisualInfo, loc)
                        if ok2 and visInfo then
                            local id = visInfo.pendingSourceID
                            if (not id or id == 0) then id = visInfo.appliedSourceID end
                            if id and id > 0 then
                                merged[slot] = { transmogID = id, option = 0 }
                                Log(string.format("Layer3 fallback slot=%d IMAID=%d (visual)", slot, id))
                            end
                        end
                    end
                end
            end
        end
    end

    -- Illusion overlay: apply SetPendingTransmog illusion data to weapon slots (12=MH, 13=OH)
    for slot, illusionID in pairs(pendingIllusions) do
        if not merged[slot] then
            -- Get current weapon appearance (illusions require a transmogged weapon)
            local invName = INV_SLOT_NAMES[slot]
            if invName and HAS_SLOT_VISUAL_INFO then
                local ok, loc = pcall(TransmogUtil.GetTransmogLocation, invName, Enum.TransmogType.Appearance, false)
                if ok and loc then
                    local ok2, visInfo = pcall(C_Transmog.GetSlotVisualInfo, loc)
                    if ok2 and visInfo then
                        local id = visInfo.appliedSourceID
                        if id and id > 0 then
                            merged[slot] = { transmogID = id, option = 0 }
                            Log(string.format("Illusion: looked up current appearance slot=%d IMAID=%d", slot, id))
                        end
                    end
                end
            end
        end
        if merged[slot] then
            merged[slot].illusionID = illusionID
            Log(string.format("Illusion overlay slot=%d enchantID=%d", slot, illusionID))
        end
    end

    -- Log slots that are still missing after all 3 layers (known limitation for weapons
    -- during outfit loading — server baseline restoration handles these)
    local missing = {}
    for slot = 0, 13 do
        if not merged[slot] then
            missing[#missing + 1] = slot
        end
    end
    if #missing > 0 then
        Log(string.format("Missing after 3-layer merge: slots %s (server baseline will fill)",
            table.concat(missing, ",")))
    end

    -- Encode: "slot.transmogID.option[.illusionID];..."
    -- 4th field only included when illusion data was explicitly set
    local parts = {}
    for slot, data in pairs(merged) do
        if data.illusionID ~= nil then
            parts[#parts + 1] = string.format("%d.%d.%d.%d", slot, data.transmogID, data.option, data.illusionID)
        else
            parts[#parts + 1] = string.format("%d.%d.%d", slot, data.transmogID, data.option)
        end
    end

    if #parts == 0 then
        Log("CommitAndApplyAllPending — hybrid merge produced 0 overrides")
        wipe(pendingOverrides)
        wipe(pendingIllusions)
        return
    end

    local payload = table.concat(parts, ";")

    -- Addon message payload limit is 255 bytes.
    -- Worst case: 12 3-field + 2 4-field (illusions) = ~192 bytes. Multi-part handles overflow.
    if #payload <= 255 then
        C_ChatInfo.SendAddonMessage(ADDON_PREFIX, payload, "WHISPER", UnitName("player"))
    else
        -- Split at nearest ; boundary
        local mid = payload:sub(1, 255):match(".*;") or payload:sub(1, 255)
        local part1 = mid
        local part2 = payload:sub(#mid + 1)
        C_ChatInfo.SendAddonMessage(ADDON_PREFIX, "1>" .. part1, "WHISPER", UnitName("player"))
        C_ChatInfo.SendAddonMessage(ADDON_PREFIX, "2>" .. part2, "WHISPER", UnitName("player"))
    end

    Log(string.format("Sent %d overrides (%d bytes): %s", #parts, #payload, payload))

    wipe(pendingOverrides)
    wipe(pendingIllusions)
end)
