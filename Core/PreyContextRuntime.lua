local Preydator = _G.Preydator
if type(Preydator) ~= "table" then
    return
end

local PreyContextRuntime = {}
Preydator:RegisterModule("PreyContextRuntime", PreyContextRuntime)

function PreyContextRuntime:GetPreyZoneInfo(questID, ctx)
    if not questID then
        return nil, nil
    end

    local taskQuestApi = ctx and ctx.taskQuestApi
    local mapApi = ctx and ctx.mapApi
    if not (taskQuestApi and taskQuestApi.GetQuestZoneID and mapApi and mapApi.GetMapInfo) then
        return nil, nil
    end

    local okMapID, rawMapID = pcall(taskQuestApi.GetQuestZoneID, questID)
    local okNumericMapID, numericMapID = pcall(function()
        return tonumber(rawMapID)
    end)
    local mapID = nil
    if okMapID and okNumericMapID and numericMapID and numericMapID > 0 then
        mapID = numericMapID
    end
    if not mapID then
        return nil, nil
    end

    local okMapInfo, mapInfo = pcall(mapApi.GetMapInfo, mapID)
    mapInfo = okMapInfo and mapInfo or nil
    return (mapInfo and mapInfo.name or nil), mapID
end

function PreyContextRuntime:GetCurrentActivePreyQuest(ctx)
    local questLog = ctx and ctx.questLog
    if questLog and questLog.GetActivePreyQuest then
        return questLog.GetActivePreyQuest()
    end

    return nil
end

function PreyContextRuntime:IsPlayerInPreyZone(preyMapID, state, ctx)
    if not preyMapID then
        return nil
    end

    if type(state) ~= "table" then
        return nil
    end

    local mapApi = ctx and ctx.mapApi
    if not (mapApi and mapApi.GetBestMapForUnit and mapApi.GetMapInfo) then
        return nil
    end

    if state.zoneCacheDirty == true or type(state.playerMapHierarchy) ~= "table" then
        local okPlayerMapID, rawPlayerMapID = pcall(mapApi.GetBestMapForUnit, "player")
        local okNumericMapID, numericPlayerMapID = pcall(function()
            return tonumber(rawPlayerMapID)
        end)
        local playerMapID = nil
        if okPlayerMapID and okNumericMapID and numericPlayerMapID and numericPlayerMapID > 0 then
            playerMapID = numericPlayerMapID
        end
        state.playerMapID = playerMapID
        state.playerMapHierarchy = {}
        state.zoneCacheDirty = false

        local guard = 0
        local currentMapID = playerMapID
        while currentMapID and guard < 20 do
            state.playerMapHierarchy[currentMapID] = true

            local okMapInfo, mapInfo = pcall(mapApi.GetMapInfo, currentMapID)
            mapInfo = okMapInfo and mapInfo or nil
            local okParentMapID, numericParentMapID = pcall(function()
                return tonumber(mapInfo and mapInfo.parentMapID)
            end)
            local parentMapID = nil
            if okParentMapID and numericParentMapID and numericParentMapID > 0 then
                parentMapID = numericParentMapID
            end
            if not parentMapID then
                break
            end

            currentMapID = parentMapID
            guard = guard + 1
        end
    end

    if not state.playerMapID then
        return nil
    end

    return state.playerMapHierarchy[preyMapID] == true
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

    local inPreyZone = nil
    local usedOnMapFallback = false
    if state.preyZoneMapID then
        inPreyZone = self:IsPlayerInPreyZone(state.preyZoneMapID, state, ctx)
    else
        usedOnMapFallback = true
        inPreyZone = self:IsPreyQuestOnCurrentMap(questID, ctx)
        if inPreyZone == false then
            -- Some prey quests do not expose a stable task-quest zone map ID and
            -- may also report isOnMap=false while the player is actually in-zone.
            -- Treat this as unknown so we do not incorrectly hide the bar.
            inPreyZone = nil
        end
        -- For quests with no task-quest map ID, treat this as our zone snapshot.
        state.zoneCacheDirty = false
    end

    if inPreyZone == nil and not usedOnMapFallback then
        inPreyZone = self:IsPreyQuestOnCurrentMap(questID, ctx)
        state.zoneCacheDirty = false
    end

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