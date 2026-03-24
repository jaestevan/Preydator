---@diagnostic disable: undefined-field, inject-field

local _, addonTable = ...
local Preydator = _G.Preydator or addonTable

local Alerts = {}
Preydator:RegisterModule("Alerts", Alerts)

local BLOODY_COMMAND_SPELL_IDS = {
    [1245779] = true,
    [1245767] = true,
}
local BLOODY_COMMAND_CHAT_PHRASE = "kill for me. now!"
local BLOODY_COMMAND_CHAT_SOURCE = "astalor bloodsworn"

local bloodyAuraActive = false
local bloodyAuraSpellID = nil

local function IsAmbushRuntimeEnabled(api)
    local runtime = type(api.GetModuleRuntimeState) == "function" and api.GetModuleRuntimeState() or nil
    if type(runtime) ~= "table" then
        return true
    end

    local settings = runtime.settings
    local barEnabled = runtime.barEnabled == true
    local soundsRuntimeEnabled = runtime.soundsRuntimeEnabled == true
    local visualEnabled = barEnabled and (not settings or settings.ambushVisualEnabled ~= false)
    local soundEnabled = soundsRuntimeEnabled and (not settings or settings.ambushSoundEnabled ~= false)
    return visualEnabled or soundEnabled
end

local function IsBloodyRuntimeEnabled(api)
    local runtime = type(api.GetModuleRuntimeState) == "function" and api.GetModuleRuntimeState() or nil
    if type(runtime) ~= "table" then
        return true
    end

    local settings = runtime.settings
    local barEnabled = runtime.barEnabled == true
    local soundsRuntimeEnabled = runtime.soundsRuntimeEnabled == true
    local visualEnabled = barEnabled and (not settings or settings.bloodyCommandVisualEnabled ~= false)
    local soundEnabled = soundsRuntimeEnabled and (not settings or settings.bloodyCommandSoundEnabled ~= false)
    return visualEnabled or soundEnabled
end

local function StringContainsInsensitiveSafe(haystack, needle)
    if type(haystack) ~= "string" or type(needle) ~= "string" or needle == "" then
        return false
    end

    local ok, found = pcall(function()
        local haystackLower = string.lower(haystack)
        local needleLower = string.lower(needle)
        return string.find(haystackLower, needleLower, 1, true) ~= nil
    end)

    return ok and found or false
end

local function ResolveAlertContext(api)
    if type(api.GetBarRuntimeContext) ~= "function" then
        return nil
    end

    local ctx = api.GetBarRuntimeContext()
    if type(ctx) ~= "table" or type(ctx.state) ~= "table" then
        return nil
    end

    return ctx
end

local function AddAlertsDebugLog(api, message)
    if type(api.AddDebugLog) == "function" then
        api.AddDebugLog("BloodyCommand", tostring(message), true)
    end
end

local function IsAmbushSystemMessage(ctx, message, sender)
    if type(message) ~= "string" then
        return false
    end

    local preyName = ctx.state and ctx.state.preyTargetName
    if type(preyName) == "string" and preyName ~= "" then
        if StringContainsInsensitiveSafe(message, preyName) or StringContainsInsensitiveSafe(sender, preyName) then
            return true
        end
    end

    return false
end

local function ShouldScanAmbushChat(ctx)
    local state = ctx.state
    if type(state) ~= "table"
        or type(ctx.getCurrentActivePreyQuestCached) ~= "function"
        or type(ctx.isValidQuestID) ~= "function"
        or type(ctx.refreshInPreyZoneStatus) ~= "function"
        or type(ctx.isRestrictedInstanceForPreyBar) ~= "function"
    then
        return false
    end

    local liveQuestID = ctx.getCurrentActivePreyQuestCached(0)
    if not ctx.isValidQuestID(liveQuestID) then
        return false
    end

    if state.activeQuestID ~= liveQuestID then
        state.zoneCacheDirty = true
        return false
    end

    if tonumber(state.stage) == tonumber(ctx.maxStage) then
        return false
    end

    if state.zoneCacheDirty == true or state.inPreyZone == nil then
        ctx.refreshInPreyZoneStatus(liveQuestID, true)
    end

    if state.inPreyZone ~= true then
        return false
    end

    return not ctx.isRestrictedInstanceForPreyBar()
end

local function HandleAmbushChat(api, event, message, sender)
    if not IsAmbushRuntimeEnabled(api) then
        return
    end

    local ctx = ResolveAlertContext(api)
    if not ctx then
        return
    end

    if ShouldScanAmbushChat(ctx) and IsAmbushSystemMessage(ctx, message, sender) then
        if type(api.TriggerAmbushAlert) == "function" then
            api.TriggerAmbushAlert(message, event)
        end
    end
end

local function IsBloodyCommandStageAndDifficultyMatch(ctx)
    local state = ctx and ctx.state
    if type(state) ~= "table" then
        return false
    end

    local stage = tonumber(state.stage) or 0
    if stage <= 1 then
        return false
    end

    local difficulty = state.preyTargetDifficulty
    if type(difficulty) ~= "string" or difficulty == "" then
        return false
    end

    local loweredDifficulty = string.lower(difficulty)
    return string.find(loweredDifficulty, "nightmare", 1, true) ~= nil
end

local function IsBloodyCommandChatMessage(message, sender)
    if type(message) ~= "string" then
        return false
    end

    local loweredMessage = string.lower(message)
    if string.find(loweredMessage, BLOODY_COMMAND_CHAT_PHRASE, 1, true) then
        return true
    end

    -- Some chat payloads include the full speaker prefix in arg1.
    if string.find(loweredMessage, BLOODY_COMMAND_CHAT_SOURCE .. " says: " .. BLOODY_COMMAND_CHAT_PHRASE, 1, true) then
        return true
    end

    if type(sender) == "string" and sender ~= "" then
        local loweredSender = string.lower(sender)
        if string.find(loweredSender, BLOODY_COMMAND_CHAT_SOURCE, 1, true)
            and string.find(loweredMessage, BLOODY_COMMAND_CHAT_PHRASE, 1, true) then
            return true
        end
    end

    return false
end

local function HandleBloodyCommandChat(api, event, message, sender)
    if not IsBloodyCommandChatMessage(message, sender) then
        return
    end

    local ctx = ResolveAlertContext(api)
    local stageAndDifficultyMatch = IsBloodyCommandStageAndDifficultyMatch(ctx)
    local runtimeEnabled = IsBloodyRuntimeEnabled(api)
    local inRestrictedInstance = ctx
        and type(ctx.isRestrictedInstanceForPreyBar) == "function"
        and ctx.isRestrictedInstanceForPreyBar() == true

    AddAlertsDebugLog(api,
        "chat matched"
            .. " | event=" .. tostring(event)
            .. " | sender=" .. tostring(sender)
            .. " | message=" .. tostring(message)
            .. " | stage=" .. tostring(ctx and ctx.state and ctx.state.stage)
            .. " | difficulty=" .. tostring(ctx and ctx.state and ctx.state.preyTargetDifficulty)
            .. " | runtimeEnabled=" .. tostring(runtimeEnabled)
            .. " | restricted=" .. tostring(inRestrictedInstance)
            .. " | stageAndDifficultyMatch=" .. tostring(stageAndDifficultyMatch)
    )

    if inRestrictedInstance then
        AddAlertsDebugLog(api, "chat ignored: restricted instance")
        return
    end

    if not runtimeEnabled then
        AddAlertsDebugLog(api, "chat ignored: runtime disabled")
        return
    end

    if not stageAndDifficultyMatch then
        AddAlertsDebugLog(api, "chat ignored: stage/difficulty gate failed")
        return
    end

    if type(api.TriggerBloodyCommandAlert) == "function" then
        api.TriggerBloodyCommandAlert(nil, sender, event)
    end
end

local function FindPlayerBloodyCommandSpellID()
    local auraUtil = _G.AuraUtil
    if auraUtil and type(auraUtil.FindAuraBySpellID) == "function" then
        for spellID in pairs(BLOODY_COMMAND_SPELL_IDS) do
            local auraName = auraUtil.FindAuraBySpellID(spellID, "player", "HARMFUL")
            if auraName then
                return spellID
            end
        end
    end

    if type(_G.UnitAura) == "function" then
        for index = 1, 40 do
            local _, _, _, _, _, _, _, _, _, auraSpellID = _G.UnitAura("player", index, "HARMFUL")
            auraSpellID = tonumber(auraSpellID)
            if rawget(BLOODY_COMMAND_SPELL_IDS, auraSpellID) ~= nil then
                return auraSpellID
            end
        end
    end

    return nil
end

local function HandleBloodyCommandUnitAura(api)
    local activeSpellID = FindPlayerBloodyCommandSpellID()

    if activeSpellID then
        local ctx = ResolveAlertContext(api)
        local stageAndDifficultyMatch = IsBloodyCommandStageAndDifficultyMatch(ctx)
        local runtimeEnabled = IsBloodyRuntimeEnabled(api)
        local shouldBeActive = stageAndDifficultyMatch and runtimeEnabled
        local changed = (not bloodyAuraActive) or (bloodyAuraSpellID ~= activeSpellID)

        AddAlertsDebugLog(api,
            "aura scan"
                .. " | spellID=" .. tostring(activeSpellID)
                .. " | stage=" .. tostring(ctx and ctx.state and ctx.state.stage)
                .. " | difficulty=" .. tostring(ctx and ctx.state and ctx.state.preyTargetDifficulty)
                .. " | runtimeEnabled=" .. tostring(runtimeEnabled)
                .. " | stageAndDifficultyMatch=" .. tostring(stageAndDifficultyMatch)
                .. " | changed=" .. tostring(changed)
        )

        if shouldBeActive and changed and type(api.TriggerBloodyCommandAlert) == "function" then
            api.TriggerBloodyCommandAlert(activeSpellID, nil, "UNIT_AURA")
        end

        if shouldBeActive then
            bloodyAuraActive = true
            bloodyAuraSpellID = activeSpellID
        else
            if bloodyAuraActive and type(api.ClearBloodyCommandAlert) == "function" then
                api.ClearBloodyCommandAlert()
                if type(api.UpdateBarDisplay) == "function" then
                    api.UpdateBarDisplay()
                end
            end
            bloodyAuraActive = false
            bloodyAuraSpellID = nil
        end

        return
    end

    if bloodyAuraActive and type(api.ClearBloodyCommandAlert) == "function" then
        api.ClearBloodyCommandAlert()
        if type(api.UpdateBarDisplay) == "function" then
            api.UpdateBarDisplay()
        end
    end

    bloodyAuraActive = false
    bloodyAuraSpellID = nil
end

function Alerts:OnEvent(event, arg1, arg2)
    local api = Preydator.API
    if type(api) ~= "table" then
        return
    end

    if event == "CHAT_MSG_SYSTEM"
        or event == "CHAT_MSG_MONSTER_SAY"
        or event == "CHAT_MSG_MONSTER_YELL"
        or event == "CHAT_MSG_MONSTER_EMOTE"
        or event == "RAID_BOSS_EMOTE"
    then
        HandleAmbushChat(api, event, arg1, arg2)
        HandleBloodyCommandChat(api, event, arg1, arg2)
        return
    end

    if event == "UNIT_AURA" and arg1 == "player" then
        HandleBloodyCommandUnitAura(api)
        return
    end

    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        HandleBloodyCommandUnitAura(api)
    end
end
