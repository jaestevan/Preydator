---@diagnostic disable

local Preydator = _G.Preydator
local SlashCmdList = _G["SlashCmdList"]
if type(Preydator) ~= "table" then
    return
end

local EventRuntime = {}
Preydator:RegisterModule("EventRuntime", EventRuntime)

function EventRuntime:HandleEvent(event, arg1, arg2, ctx)
    if type(ctx) ~= "table" then
        return false
    end

    -- Taint safety: never propagate noisy widget payload args.
    -- UPDATE_UI_WIDGET args can carry secret-number values; addons should not
    -- read/forward them unless absolutely required.
    if event == "UPDATE_UI_WIDGET" or event == "UPDATE_ALL_UI_WIDGETS" then
        arg1, arg2 = nil, nil
    end

    local state = ctx.state
    local ui = ctx.ui

    if event == "ADDON_LOADED" and arg1 == ctx.addonName then
        if type(ctx.onAddonLoaded) == "function" then
            ctx.onAddonLoaded()
        end
        if type(ctx.ensureOptionsPanel) == "function" then
            ctx.ensureOptionsPanel()
        end
        if type(ctx.handleSlashCommand) == "function" and type(SlashCmdList) == "table" then
            SlashCmdList["PREYDATOR"] = ctx.handleSlashCommand
        end
        return true
    end

    -- Blizzard_UIWidgets is a delayed sub-addon. Gate the mixin suppression hook
    -- and first icon-visibility pass on its load so widget APIs are guaranteed present.
    if event == "ADDON_LOADED" and arg1 == "Blizzard_UIWidgets" then
        if type(ctx.onBlizzardWidgetsLoaded) == "function" then
            ctx.onBlizzardWidgetsLoaded()
        end
        return true
    end

    if event == "ADDON_LOADED" then
        return true
    end

    if event == "PLAYER_LOGIN"
        or event == "PLAYER_ENTERING_WORLD"
        or event == "ZONE_CHANGED"
        or event == "ZONE_CHANGED_INDOORS"
        or event == "ZONE_CHANGED_NEW_AREA" then
        state.zoneCacheDirty = true
        if event == "PLAYER_ENTERING_WORLD" and ui.barFrame and type(ctx.applyBarSettings) == "function" then
            ctx.applyBarSettings()
        end
    end

    if event == "PLAYER_REGEN_ENABLED" and type(ctx.onPlayerRegenEnabled) == "function" then
        ctx.onPlayerRegenEnabled()
    end

    local isRestrictedInstance = type(ctx.isRestrictedInstanceForPreyBar) == "function"
        and ctx.isRestrictedInstanceForPreyBar() == true

    -- Gate module fanout for noisy UI widget events when no prey context exists.
    -- Keep this lazy so non-noisy events do not pay quest/cache costs.
    local isNoisyEvent = event == "UPDATE_UI_WIDGET" or event == "UPDATE_ALL_UI_WIDGETS"
    if event == "UPDATE_UI_WIDGET" and type(ctx.isRelevantWidgetUpdateEvent) == "function" then
        if ctx.isRelevantWidgetUpdateEvent(arg1, arg2) ~= true then
            return true
        end
    end

    local now
    local isPreySignalEvent = isNoisyEvent
        or event == "CHAT_MSG_SYSTEM"
        or event == "CHAT_MSG_MONSTER_SAY"
        or event == "CHAT_MSG_MONSTER_YELL"
        or event == "CHAT_MSG_MONSTER_EMOTE"
        or event == "RAID_BOSS_EMOTE"
        or event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW"
        or event == "QUEST_DETAIL"
        or event == "QUEST_ACCEPTED"
        or event == "QUEST_TURNED_IN"

    if isNoisyEvent then
        now = type(ctx.getTime) == "function" and ctx.getTime() or 0
        local hasPreyContext = state.activeQuestID or (now < (state.killStageUntil or 0))
        local outOfZoneQuestIdle = type(ctx.isValidQuestID) == "function"
            and ctx.isValidQuestID(state.activeQuestID)
            and state.inPreyZone ~= true
            and not (now < (state.killStageUntil or 0))
            and not (now < (state.ambushAlertUntil or 0))
            and not (now < (state.bloodyCommandAlertUntil or 0))
        if (not isRestrictedInstance)
            and hasPreyContext
            and not outOfZoneQuestIdle
            and type(ctx.runModuleHook) == "function" then
            ctx.runModuleHook("OnEvent", event, arg1, arg2)
        end
    else
        if (not (isRestrictedInstance and isPreySignalEvent)) and type(ctx.runModuleHook) == "function" then
            ctx.runModuleHook("OnEvent", event, arg1, arg2)
        end
    end

    if isRestrictedInstance and event ~= "PLAYER_LOGIN" then
        if type(ctx.setPollingActive) == "function" then
            ctx.setPollingActive(false)
        end
        if type(ctx.updateBarDisplay) == "function" then
            ctx.updateBarDisplay()
        end
        return true
    end

    if event == "PLAYER_LOGIN" then
        local custV2 = type(ctx.getCustomizationModule) == "function" and ctx.getCustomizationModule() or nil
        local barEnabled = true
        if custV2 and type(custV2.IsModuleEnabled) == "function" then
            barEnabled = custV2:IsModuleEnabled("bar") == true
        end
        if barEnabled then
            if type(ctx.ensureBar) == "function" then
                ctx.ensureBar()
            end
            if type(ctx.applyBarSettings) == "function" then
                ctx.applyBarSettings()
            end
            if type(ctx.updateBarDisplay) == "function" then
                ctx.updateBarDisplay()
            end
        end
        if type(ctx.setPollingActive) == "function" and type(ctx.shouldUseActivePolling) == "function" then
            ctx.setPollingActive(ctx.shouldUseActivePolling())
        end
        return true
    end

    if event == "CHAT_MSG_SYSTEM" or event == "CHAT_MSG_MONSTER_SAY" or event == "CHAT_MSG_MONSTER_YELL" or event == "CHAT_MSG_MONSTER_EMOTE" or event == "RAID_BOSS_EMOTE" then
        -- Alert modules (Core/Alerts.lua) own ambush and Bloody Command chat handling.
        return true
    end

    if event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" or event == "QUEST_DETAIL" or event == "QUEST_ACCEPTED" then
        if type(ctx.armQuestListenBurst) == "function" then
            ctx.armQuestListenBurst()
        end
    end

    if event == "QUEST_TURNED_IN" and state.activeQuestID and arg1 == state.activeQuestID then
        state.killStageUntil = (type(ctx.getTime) == "function" and ctx.getTime() or 0) + 8
        state.progressState = ctx.preyProgressFinal
        state.progressPercent = 100
        if type(ctx.updateBarDisplay) == "function" then
            ctx.updateBarDisplay()
        end
        if type(ctx.setPollingActive) == "function" then
            ctx.setPollingActive(true)
        end
    end

    now = now or (type(ctx.getTime) == "function" and ctx.getTime() or 0)
    local livePreyQuestID = nil
    if type(ctx.getCurrentActivePreyQuestCached) == "function" then
        livePreyQuestID = ctx.getCurrentActivePreyQuestCached(isNoisyEvent and ctx.activePreyQuestCacheSeconds or 0)
    end

    if not (((state.killStageUntil or 0) > now)
        or ((state.ambushAlertUntil or 0) > now)
        or ((state.bloodyCommandAlertUntil or 0) > now)
        or ((state.questListenUntil or 0) > now)
        or (type(ctx.isValidQuestID) == "function" and ctx.isValidQuestID(state.activeQuestID))
        or (type(ctx.isValidQuestID) == "function" and ctx.isValidQuestID(livePreyQuestID))) then
        return true
    end

    if isNoisyEvent
        and type(ctx.isValidQuestID) == "function"
        and ctx.isValidQuestID(state.activeQuestID)
        and state.inPreyZone ~= true
        and not ((state.killStageUntil or 0) > now)
        and not ((state.ambushAlertUntil or 0) > now)
        and not ((state.bloodyCommandAlertUntil or 0) > now) then
        return true
    end

    if type(ctx.updatePreyState) == "function" then
        ctx.updatePreyState()
    end
    if type(ctx.setPollingActive) == "function" and type(ctx.shouldUseActivePolling) == "function" then
        ctx.setPollingActive(ctx.shouldUseActivePolling())
    end

    return true
end
