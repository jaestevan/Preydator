local Preydator = _G.Preydator
if type(Preydator) ~= "table" then
    return
end

local PreyContextRuntime = {}
Preydator:RegisterModule("PreyContextRuntime", PreyContextRuntime)

function PreyContextRuntime:GetPreyZoneInfo(questID, ctx)
    -- Taint-safe: avoid task-quest and map-ID probing here. These APIs can
    -- return protected numbers that later poison Blizzard Area POI/tooltips.
    return nil, nil
end

function PreyContextRuntime:GetCurrentActivePreyQuest(ctx)
    local questLog = ctx and ctx.questLog
    if questLog and questLog.GetActivePreyQuest then
        return questLog.GetActivePreyQuest()
    end

    return nil
end

function PreyContextRuntime:IsPlayerInPreyZone(preyMapID, state, ctx)
    return nil
end

function PreyContextRuntime:IsPreyQuestOnCurrentMap(questID, ctx)
    local questLog = ctx and ctx.questLog
    if not (questID and questLog and questLog.GetLogIndexForQuestID and questLog.GetInfo) then
        return nil
    end

    local logIndex = questLog.GetLogIndexForQuestID(questID)
    if not logIndex then
        return nil
    end

    local info = questLog.GetInfo(logIndex)
    if type(info) ~= "table" then
        return nil
    end

    if info.isOnMap == nil then
        return nil
    end

    return info.isOnMap == true
end

function PreyContextRuntime:RefreshInPreyZoneStatus(questID, force, state, ctx)
    if type(state) ~= "table" then
        return nil
    end

    local isValidQuestID = ctx and ctx.isValidQuestID
    if type(isValidQuestID) ~= "function" or not isValidQuestID(questID) then
        state.inPreyZone = nil
        return nil
    end

    local getTime = ctx and ctx.getTime
    local now = (type(getTime) == "function" and getTime()) or 0
    local staleFalseCheck = state.inPreyZone == false
        and (now - (state.lastZoneStatusRefreshAt or 0)) >= 2.0

    if staleFalseCheck then
        -- Force a map hierarchy rebuild during retry checks so we do not stay
        -- stuck on a stale map snapshot after loading-screen transitions.
        state.zoneCacheDirty = true
    end

    local shouldRefresh = force == true or state.inPreyZone == nil or state.zoneCacheDirty == true or staleFalseCheck
    if not shouldRefresh then
        return state.inPreyZone
    end

    local inPreyZone = self:IsPreyQuestOnCurrentMap(questID, ctx)
    state.playerMapID = nil
    state.playerMapHierarchy = nil
    state.zoneCacheDirty = false

    state.inPreyZone = inPreyZone
    state.lastZoneStatusRefreshAt = now
    return inPreyZone
end

function PreyContextRuntime:RefreshCurrentActivePreyQuestCache(state, ctx)
    if type(state) ~= "table" then
        return nil
    end

    local getTime = ctx and ctx.getTime
    local now = (type(getTime) == "function" and getTime()) or 0
    local getCurrentActivePreyQuest = ctx and ctx.getCurrentActivePreyQuest

    if type(getCurrentActivePreyQuest) == "function" then
        state.cachedActivePreyQuestID = getCurrentActivePreyQuest()
    else
        state.cachedActivePreyQuestID = nil
    end
    state.cachedActivePreyQuestAt = now
    return state.cachedActivePreyQuestID
end

function PreyContextRuntime:GetCurrentActivePreyQuestCached(maxAgeSeconds, state, ctx)
    if type(state) ~= "table" then
        return nil
    end

    local getTime = ctx and ctx.getTime
    local now = (type(getTime) == "function" and getTime()) or 0
    local maxAge = tonumber(maxAgeSeconds)
    if not maxAge or maxAge < 0 then
        maxAge = (ctx and tonumber(ctx.defaultMaxAgeSeconds)) or 0
    end

    if (now - (state.cachedActivePreyQuestAt or 0)) > maxAge then
        return self:RefreshCurrentActivePreyQuestCache(state, ctx)
    end

    return state.cachedActivePreyQuestID
end

function PreyContextRuntime:ArmQuestListenBurst(durationSeconds, state, ctx)
    if type(state) ~= "table" then
        return
    end

    local getTime = ctx and ctx.getTime
    local now = (type(getTime) == "function" and getTime()) or 0
    local duration = tonumber(durationSeconds)
    if not duration or duration <= 0 then
        duration = (ctx and tonumber(ctx.defaultBurstSeconds)) or 0
    end
    local untilTime = now + duration
    if untilTime > (state.questListenUntil or 0) then
        state.questListenUntil = untilTime
    end

    -- Force a fresh quest sample when a relevant interaction starts.
    self:RefreshCurrentActivePreyQuestCache(state, ctx)
end