---@diagnostic disable

local ADDON_NAME = ...

local CreateFrame = _G.CreateFrame
local PlaySoundFile = _G.PlaySoundFile
local C_Timer = _G.C_Timer
local ColorPickerFrame = _G.ColorPickerFrame
local OpacitySliderFrame = _G.OpacitySliderFrame
local Enum = _G.Enum
local C_QuestLog = _G["C_QuestLog"]
local C_UIWidgetManager = _G["C_UIWidgetManager"]
local C_TaskQuest = _G["C_TaskQuest"]
local C_Map = _G["C_Map"]
local C_SuperTrack = _G["C_SuperTrack"]
local GetQuestProgressBarPercent = _G.GetQuestProgressBarPercent
local UIParent = _G.UIParent
local GetTime = _G.GetTime
local IsInInstance = _G.IsInInstance
local SlashCmdList = _G["SlashCmdList"]
local Settings = _G["Settings"]
local UIDropDownMenu_Initialize = _G.UIDropDownMenu_Initialize
local UIDropDownMenu_CreateInfo = _G.UIDropDownMenu_CreateInfo
local UIDropDownMenu_SetWidth = _G.UIDropDownMenu_SetWidth
local UIDropDownMenu_SetText = _G.UIDropDownMenu_SetText
local UIDropDownMenu_AddButton = _G.UIDropDownMenu_AddButton

_G.SLASH_PREYDATOR1 = "/preydator"
_G.SLASH_PREYDATOR2 = "/pd"

local PREY_WIDGET_TYPE = 31
local PREY_PROGRESS_FINAL = 3
local MAX_STAGE = 4
local MAX_TICK_MARKS = 3
local WIDGET_SHOWN = 1
-- local IDLE_SOUND_PATH = "Interface\\AddOns\\Preydator\\sounds\\predator-idle.ogg"
local ALERT_SOUND_PATH = "Interface\\AddOns\\Preydator\\sounds\\predator-alert.ogg"
local AMBUSH_SOUND_PATH = "Interface\\AddOns\\Preydator\\sounds\\predator-ambush.ogg"
local TORMENT_SOUND_PATH = "Interface\\AddOns\\Preydator\\sounds\\predator-torment.ogg"
local KILL_SOUND_PATH = "Interface\\AddOns\\Preydator\\sounds\\predator-kill.ogg"
local DEBUG_LOG_LIMIT = 200
local DEFAULT_OUT_OF_ZONE_LABEL = _G.PreydatorL["No Sign in These Fields"]
local DEFAULT_AMBUSH_LABEL = _G.PreydatorL["AMBUSH"]
local PROGRESS_SEGMENTS_QUARTERS = "quarters"
local PROGRESS_SEGMENTS_THIRDS = "thirds"
local BAR_TICK_PCTS_BY_SEGMENT = {
    [PROGRESS_SEGMENTS_QUARTERS] = { 25, 50, 75 },
    [PROGRESS_SEGMENTS_THIRDS] = { 33, 66 },
}
local PERCENT_DISPLAY_INSIDE = "inside"
local PERCENT_DISPLAY_INSIDE_BELOW = "inside_below"
local PERCENT_DISPLAY_BELOW_BAR = "below_bar"
PERCENT_DISPLAY_ABOVE_BAR = "above_bar"
PERCENT_DISPLAY_ABOVE_TICKS = "above_ticks"
local PERCENT_DISPLAY_UNDER_TICKS = "under_ticks"
local PERCENT_DISPLAY_OFF = "off"
local PERCENT_FALLBACK_STAGE = "stage"
local LAYER_MODE_ABOVE = "above"
local LAYER_MODE_BELOW = "below"
local LABEL_MODE_CENTER = "center"
local LABEL_MODE_LEFT = "left"
LABEL_MODE_LEFT_COMBINED = "left_combined"
local LABEL_MODE_LEFT_SUFFIX = "left_suffix"
local LABEL_MODE_RIGHT = "right"
LABEL_MODE_RIGHT_COMBINED = "right_combined"
local LABEL_MODE_RIGHT_PREFIX = "right_prefix"
local LABEL_MODE_SEPARATE = "separate"
local LABEL_MODE_NONE = "none"
LABEL_ROW_ABOVE = "above"
LABEL_ROW_BELOW = "below"
ORIENTATION_HORIZONTAL = "horizontal"
ORIENTATION_VERTICAL = "vertical"
FILL_DIRECTION_UP = "up"
FILL_DIRECTION_DOWN = "down"
local FILL_INSET = 3
local AMBUSH_ALERT_DURATION_SECONDS = 6
local AMBUSH_SOUND_COOLDOWN_SECONDS = 45
local QUEST_LISTEN_BURST_SECONDS = 6
local ACTIVE_PREY_QUEST_CACHE_SECONDS = 0.75
local AMBUSH_SOUND_ALERT = "alert"
local AMBUSH_SOUND_AMBUSH = "ambush"
local AMBUSH_SOUND_TORMENT = "torment"
local AMBUSH_SOUND_KILL = "kill"
local SOUND_FOLDER_PREFIX = "Interface\\AddOns\\Preydator\\sounds\\"
local DEFAULT_SOUND_FILENAMES = {
    "predator-alert.ogg",
    "predator-ambush.ogg",
    "predator-torment.ogg",
    "predator-kill.ogg",
}
local PROTECTED_SOUND_FILENAMES = {
    ["predator-alert.ogg"] = true,
    ["predator-ambush.ogg"] = true,
    ["predator-torment.ogg"] = true,
    ["predator-kill.ogg"] = true,
}
local DEFAULT_STAGE_LABELS = {
    [1] = _G.PreydatorL["Scent in the Wind"],
    [2] = _G.PreydatorL["Blood in the Shadows"],
    [3] = _G.PreydatorL["Echoes of the Kill"],
    [4] = _G.PreydatorL["Feast of the Fang"],
}
local STAGE_PCT_BY_SEGMENT = {
    [PROGRESS_SEGMENTS_QUARTERS] = {
        [1] = 25,
        [2] = 50,
        [3] = 75,
        [4] = 100,
    },
    [PROGRESS_SEGMENTS_THIRDS] = {
        [1] = 0,
        [2] = 33,
        [3] = 66,
        [4] = 100,
    },
}

local TEXTURE_PRESETS = {
    default = "Interface\\TARGETINGFRAME\\UI-StatusBar",
    flat = "Interface\\Buttons\\WHITE8x8",
    raid = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
    classic = "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar",
}

local FONT_PRESETS = {
    frizqt = "Fonts\\FRIZQT__.TTF",
    arialn = "Fonts\\ARIALN.TTF",
    skurri = "Fonts\\SKURRI.TTF",
    morpheus = "Fonts\\MORPHEUS.TTF",
}

-- Forward declaration for helpers used before their implementation block.
local NormalizeSoundSettings
local GetSoundPathForKey
local IsValidQuestID
local ShouldSuppressDefaultPreyEncounter

local DEFAULTS = {
    point = { anchor = "CENTER", relativePoint = "CENTER", x = 0, y = 472 },
    width = 160,
    height = 30,
    horizontalWidth = 160,
    horizontalHeight = 30,
    verticalWidth = 40,
    verticalHeight = 160,
    scale = 0.9,
    verticalScale = 0.9,
    fontSize = 12,
    locked = true,
    onlyShowInPreyZone = false,
    disableDefaultPreyIcon = false,
    showInEditMode = true,
    fillColor = { 0.85, 0.2, 0.2, 0.95 },
    bgColor = { 0, 0, 0, 0.6 },
    titleColor = { 1, 0.82, 0, 1 },
    percentColor = { 1, 1, 1, 1 },
    tickColor = { 1, 1, 1, 0.35 },
    sparkColor = { 1, 0.95, 0.75, 0.9 },
    textureKey = "default",
    titleFontKey = "frizqt",
    percentFontKey = "frizqt",
    outOfZoneLabel = DEFAULT_OUT_OF_ZONE_LABEL,
    outOfZonePrefix = "",
    ambushLabel = DEFAULT_AMBUSH_LABEL,
    ambushPrefix = "",
    bloodyCommandPrefix = "",
    bloodyCommandSuffix = "",
    ambushCustomText = "",
    stageLabels = {
        [1] = DEFAULT_STAGE_LABELS[1],
        [2] = DEFAULT_STAGE_LABELS[2],
        [3] = DEFAULT_STAGE_LABELS[3],
        [4] = DEFAULT_STAGE_LABELS[4],
    },
    stageSounds = {
        [1] = ALERT_SOUND_PATH,
        [2] = AMBUSH_SOUND_PATH,
        [3] = TORMENT_SOUND_PATH,
        [4] = KILL_SOUND_PATH,
    },
    soundsEnabled = true,
    soundChannel = "SFX",
    soundEnhance = 0,
    soundFileNames = {
        "predator-alert.ogg",
        "predator-ambush.ogg",
        "predator-torment.ogg",
        "predator-kill.ogg",
    },
    debugSounds = false,
    currencyDebugEvents = false,
    currencyWindowEnabled = false,
    currencyMinimapButton = true,
    currencyMinimapAngle = 225,
    currencyMinimap = {
        hide = false,
        minimapPos = 225,
    },
    currencyWindowPoint = { anchor = "CENTER", relativePoint = "CENTER", x = 340, y = -80 },
    currencyWindowWidth = 276,
    currencyWindowHeight = 236,
    currencyWindowFontSize = 14,
    currencyWindowScale = 1,
    currencyWindowHideInInstance = false,
    currencyWarbandWindowEnabled = false,
    currencyWarbandWindowPoint = { anchor = "CENTER", relativePoint = "CENTER", x = 660, y = -80 },
    currencyWarbandWidth = 420,
    currencyWarbandHeight = 250,
    currencyWarbandFontSize = 12,
    currencyWarbandScale = 1,
    currencyWarbandWindowHideInInstance = false,
    currencyWarbandCollapsedRealms = {},
    currencyWarbandShowPreyTrack = true,
    currencyWarbandPreyMode = "available",
    currencyWarbandTrackedIDs = {
        [3392] = true,
        [3316] = true,
        [3383] = true,
        [3341] = true,
        [3343] = true,
    },
    currencyWarbandUseCurrencyTheme = true,
    currencyWarbandTheme = "brown",
    currencyShowAffordableHunts = false,
    currencyShowRealmInWarband = false,
    currencyTheme = "brown",
    currencyDeltaGainColor = { 0.00, 0.56, 0.32, 1 },
    currencyDeltaLossColor = { 0.72, 0.24, 0.15, 1 },
    currencyTrackedIDs = {
        [3392] = true,
        [3316] = true,
        [3383] = true,
        [3341] = true,
        [3343] = true,
    },
    randomHuntCosts = {
        normal = 50,
        hard = 50,
        nightmare = 0,
    },
    huntScannerEnabled = true,
    huntScannerSide = "right",
    huntScannerMatchCurrencyTheme = true,
    huntScannerUseCurrencyTheme = true,
    huntScannerTheme = "brown",
    huntScannerGroupBy = "difficulty",
    huntScannerSortBy = "zone",
    huntScannerSortDir = "asc",
    huntScannerWidth = 336,
    huntScannerHeight = 460,
    huntScannerFontSize = 12,
    huntScannerScale = 1.00,
    huntScannerAnchorAlign = "top",
    huntScannerCollapsedGroups = {},
    huntScannerPreviewInOptions = false,
    ambushSoundEnabled = true,
    ambushVisualEnabled = true,
    ambushSoundPath = KILL_SOUND_PATH,
    bloodyCommandSoundEnabled = true,
    bloodyCommandVisualEnabled = true,
    bloodyCommandSoundPath = KILL_SOUND_PATH,
    showTicks = true,
    showSparkLine = false,
    tickLayerMode = LAYER_MODE_ABOVE,
    labelRowPosition = "above",
    orientation = "horizontal",
    verticalFillDirection = "up",
    verticalTextSide = "right",
    verticalPercentSide = "center",
    showVerticalTickPercent = false,
    verticalPercentDisplay = PERCENT_DISPLAY_INSIDE,
    verticalTextOffset = 10,
    verticalPercentOffset = 10,
    verticalTextAlign = "separate",
    showAlignmentDot = false,
    verticalSideOffset = 10,
    progressSegments = PROGRESS_SEGMENTS_THIRDS,
    stageLabelMode = LABEL_MODE_CENTER,
    stageSuffixLabels = {
        [1] = "",
        [2] = "",
        [3] = "",
        [4] = "",
    },
    borderColorLinked = true,
    borderColor = { 0.8, 0.2, 0.2, 0.85 },
    percentDisplay = PERCENT_DISPLAY_INSIDE,
    percentFallbackMode = PERCENT_FALLBACK_STAGE,
    customizationV2 = {
        moduleEnabled = {
            bar = true,
            sounds = true,
            currency = true,
            hunt = true,
            warband = true,
            achievement = false,  -- Not yet implemented
        },
    },
}

local settings
local debugDB
local Preydator = _G.Preydator or {}
_G.Preydator = Preydator
Preydator.modules = Preydator.modules or {}

function Preydator:RegisterModule(name, module)
    if type(name) ~= "string" or name == "" or type(module) ~= "table" then
        return
    end

    module.name = name
    self.modules[name] = module
end

function Preydator:GetModule(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end

    return self.modules and self.modules[name] or nil
end

-- CustomizationStateV2: Manages module enable/disable state
local CustomizationStateV2 = {
    name = "CustomizationStateV2",
}

function CustomizationStateV2:IsModuleEnabled(moduleKey)
    if type(moduleKey) ~= "string" or moduleKey == "" then
        return true
    end

    local db = settings or _G.PreydatorDB or {}
    local custV2 = db.customizationV2 or {}
    local moduleState = custV2.moduleEnabled or {}

    -- Default to true if not explicitly set to false
    if moduleState[moduleKey] == nil then
        return true
    end
    return moduleState[moduleKey] == true
end

function CustomizationStateV2:Set(path, value)
    if type(path) ~= "string" or path == "" then
        return
    end

    local db = settings or _G.PreydatorDB or {}
    db.customizationV2 = db.customizationV2 or {}
    db.customizationV2.moduleEnabled = db.customizationV2.moduleEnabled or {}

    -- Parse path like "customizationV2.moduleEnabled.bar"
    local parts = {}
    for part in string.gmatch(path, "[^.]+") do
        parts[#parts + 1] = part
    end

    if #parts == 3 and parts[1] == "customizationV2" and parts[2] == "moduleEnabled" then
        local moduleKey = parts[3]
        if type(moduleKey) == "string" and moduleKey ~= "" then
            db.customizationV2.moduleEnabled[moduleKey] = value and true or false
        end
    end
end

Preydator:RegisterModule("CustomizationStateV2", CustomizationStateV2)

local frame = CreateFrame("Frame")
local warnedMissingSoundPaths = {}

-- UI frame references grouped in a table to reduce local variable count from ~30 to 1
local UI = {
    barFrame = false,
    barFillContainer = false,
    barFill = false,
    barSpark = false,
    barText = false,
    stageText = false,
    stageSuffixText = false,
    barAlignmentDot = false,
    barBorder = false,
    barTickMarks = {},
    barTickLabels = {},
    optionsPanel = false,
    optionsCategoryID = false,
    optionsScrollFrame = false,
    optionsContentFrame = false,
    candidateWidgetSetIDs = {},
    targetedWidgetGlobalFrameCache = {},
    colorPickerSessionCounter = 0,
}

local EnsureOptionsPanel
local OpenOptionsPanel
local ExtractWidgetQuestID
local AddDebugLog
local TryPlaySound
local TryPlayStageSound
local UpdateBarDisplay
local ApplyBarSettings
local ApplyDefaultPreyIconVisibility
local TryOpenPreyQuestOnMap
local BarRuntimeApplyHandler
local BarRuntimeUpdateHandler

local function RunModuleHook(hookName, ...)
    for _, module in pairs(Preydator.modules) do
        local fn = module and module[hookName]
        if type(fn) == "function" then
            pcall(fn, module, ...)
        end
    end
end

local state = {
    activeQuestID = nil,
    progressState = nil,
    progressPercent = nil,
    stageSoundPlayed = {},
    stageSoundAttempted = {},
    forceShowBar = false,
    killStageUntil = 0,
    stage = 1,
    preyZoneName = nil,
    preyZoneMapID = nil,
    inPreyZone = nil,
    preyTooltipText = nil,
    elapsedSinceUpdate = 0,
    lastWidgetSeenAt = 0,
    lastStateDebugSnapshot = nil,
    lastDisplayPct = 0,
    lastDisplayReason = "init",
    lastPercentSource = "none",
    preyTargetName = nil,
    preyTargetDifficulty = nil,
    ambushAlertUntil = 0,
    lastAmbushSoundAt = 0,
    lastAmbushSystemMessage = nil,
    bloodyCommandAlertUntil = 0,
    bloodyCommandSourceName = nil,
    lastBloodyCommandSpellID = nil,
    lastNotifiedPreyEndQuestID = nil,
    questListenUntil = 0,
    cachedActivePreyQuestID = nil,
    cachedActivePreyQuestAt = 0,
    playerMapID = nil,
    playerMapHierarchy = nil,
    zoneCacheDirty = true,
    pollingActive = false,
    nextPollingEligibilityCheckAt = 0,
}

local UPDATE_INTERVAL_SECONDS = 0.5
local INSPECT_VERSION = "v4"

Preydator.GetState = function()
    return state
end

Preydator.GetSettings = function()
    return settings
end

Preydator.GetBarFrame = function()
    return UI.barFrame
end

Preydator.GetLabelFrames = function()
    return {
        prefix = UI.stageText,
        suffix = UI.stageSuffixText,
        percent = UI.barText,
        centerDot = UI.barAlignmentDot,
    }
end

Preydator.RequestRefresh = function()
    if type(UpdateBarDisplay) == "function" then
        UpdateBarDisplay()
    end
end

local function ApplyDefaults(dst, src)
    for key, value in pairs(src) do
        if type(value) == "table" then
            if type(dst[key]) ~= "table" then
                dst[key] = {}
            end
            ApplyDefaults(dst[key], value)
        elseif dst[key] == nil then
            dst[key] = value
        end
    end
end

local function GetStageLabel(stage)
    if settings and settings.stageLabels then
        local customLabel = settings.stageLabels[stage]
        if type(customLabel) == "string" and customLabel ~= "" then
            return customLabel
        end
    end

    return DEFAULT_STAGE_LABELS[stage] or "Unknown"
end

local function Clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local function RoundToStep(value, step)
    if not step or step <= 0 then
        return value
    end

    return math.floor((value / step) + 0.5) * step
end

local function NormalizeSliderValue(value, minValue, maxValue, step)
    local numeric = tonumber(value)
    if not numeric then
        return nil
    end

    numeric = Clamp(numeric, minValue, maxValue)
    numeric = RoundToStep(numeric, step)
    return Clamp(numeric, minValue, maxValue)
end

local function CreateCheckboxControl(parent, x, y, label, getter, setter, options)
    options = type(options) == "table" and options or {}

    local check = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    check:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    check.Text:SetText(label)
    check:SetChecked(getter() and true or false)
    check:SetScript("OnClick", function(self)
        setter(self:GetChecked() and true or false)
    end)

    function check:PreydatorRefresh()
        self:SetChecked(getter() and true or false)
    end

    if options.withSetEnabled == true then
        function check:PreydatorSetEnabled(enabled)
            local isEnabled = enabled and true or false
            self:SetAlpha(isEnabled and 1 or 0.45)
            self:SetEnabled(isEnabled)
            if self.EnableMouse then
                self:EnableMouse(isEnabled)
            end
        end
    end

    return check
end

local function CreateSliderControl(parent, x, y, label, minValue, maxValue, step, getter, setter, formatValue, options)
    options = type(options) == "table" and options or {}

    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(options.containerWidth or 250, options.containerHeight or 54)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

    local title = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 0, 0)
    title:SetText(label)

    local slider = CreateFrame("Slider", nil, container, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 0, -18)
    slider:SetWidth(options.sliderWidth or 165)
    slider:SetScale(options.sliderScale or 1)
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    if slider.Low then slider.Low:Hide() end
    if slider.High then slider.High:Hide() end

    local valueBox = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
    valueBox:SetSize(options.valueBoxWidth or 52, options.valueBoxHeight or 20)
    valueBox:SetPoint("LEFT", slider, "RIGHT", options.valueBoxOffsetX or 10, 0)
    valueBox:SetAutoFocus(false)
    valueBox:SetTextInsets(6, 6, 0, 0)
    valueBox:SetJustifyH("CENTER")

    local formatter = formatValue or function(value)
        if step and step < 1 then
            return string.format("%.2f", value)
        end
        return tostring(math.floor(value + 0.5))
    end

    local function RefreshFromValue(rawValue)
        local normalized = NormalizeSliderValue(rawValue, minValue, maxValue, step)
        if normalized == nil then
            normalized = getter()
        end
        slider:SetValue(normalized)
        valueBox:SetText(formatter(normalized))
    end

    slider:SetScript("OnValueChanged", function(_, value)
        local normalized = NormalizeSliderValue(value, minValue, maxValue, step)
        if normalized == nil then
            return
        end

        valueBox:SetText(formatter(normalized))
        setter(normalized)
    end)

    valueBox:SetScript("OnEnterPressed", function(self)
        local normalized = NormalizeSliderValue(self:GetText(), minValue, maxValue, step)
        if normalized == nil then
            self:SetText(formatter(getter()))
            self:ClearFocus()
            return
        end

        slider:SetValue(normalized)
        self:ClearFocus()
    end)

    valueBox:SetScript("OnEditFocusLost", function(self)
        self:SetText(formatter(getter()))
    end)

    function container:PreydatorRefresh()
        RefreshFromValue(getter())
    end

    if options.withSetEnabled == true then
        function container:PreydatorSetEnabled(enabled)
            local isEnabled = enabled and true or false
            self:SetAlpha(isEnabled and 1 or 0.45)
            slider:SetEnabled(isEnabled)
            valueBox:SetEnabled(isEnabled)
            if valueBox.SetTextColor then
                local channel = isEnabled and 1 or 0.65
                valueBox:SetTextColor(channel, channel, channel)
            end
        end
    end

    container:PreydatorRefresh()
    return container
end

local function Round(value)
    if value >= 0 then
        return math.floor(value + 0.5)
    end

    return math.ceil(value - 0.5)
end

local function GetRuntimeModule(moduleName)
    if not (Preydator and type(Preydator.GetModule) == "function") then
        return nil
    end

    local runtime = Preydator:GetModule(moduleName)
    if type(runtime) == "table" then
        return runtime
    end

    return nil
end

local function NormalizeLabelSettings()
    local runtime = GetRuntimeModule("SettingsRuntime")
    if runtime and type(runtime.NormalizeLabelSettings) == "function" then
        runtime:NormalizeLabelSettings(settings, {
            maxStage = MAX_STAGE,
            defaultStageLabels = DEFAULT_STAGE_LABELS,
            defaultOutOfZoneLabel = DEFAULT_OUT_OF_ZONE_LABEL,
            defaultAmbushLabel = DEFAULT_AMBUSH_LABEL,
        })
        return
    end

    if type(settings.stageLabels) ~= "table" then
        settings.stageLabels = {}
    end

    for stage = 1, MAX_STAGE do
        local label = settings.stageLabels[stage]
        if type(label) ~= "string" then
            local legacy = settings.stageLabels[tostring(stage)]
            if type(legacy) == "string" then
                label = legacy
            end
        end

        if type(label) ~= "string" then
            label = DEFAULT_STAGE_LABELS[stage] or ""
        end

        settings.stageLabels[stage] = label
    end

    if type(settings.outOfZoneLabel) ~= "string" or settings.outOfZoneLabel == "" then
        settings.outOfZoneLabel = DEFAULT_OUT_OF_ZONE_LABEL
    end

    if type(settings.outOfZonePrefix) ~= "string" then
        settings.outOfZonePrefix = ""
    end

    if type(settings.ambushLabel) ~= "string" or settings.ambushLabel == "" then
        settings.ambushLabel = DEFAULT_AMBUSH_LABEL
    end

    if type(settings.ambushPrefix) ~= "string" then
        settings.ambushPrefix = ""
    end

    if type(settings.bloodyCommandPrefix) ~= "string" then
        settings.bloodyCommandPrefix = ""
    end

    if type(settings.bloodyCommandSuffix) ~= "string" then
        settings.bloodyCommandSuffix = ""
    end

    if type(settings.ambushCustomText) ~= "string" then
        settings.ambushCustomText = ""
    end
end

local function NormalizeColorSettings()
    local runtime = GetRuntimeModule("SettingsRuntime")
    if runtime and type(runtime.NormalizeColorSettings) == "function" then
        runtime:NormalizeColorSettings(settings, {
            defaults = DEFAULTS,
            clamp = Clamp,
        })
        return
    end

    local function normalizeColor(source, fallback)
        local color = type(source) == "table" and source or {}
        local r = Clamp(tonumber(color[1] or color.r) or fallback[1], 0, 1)
        local g = Clamp(tonumber(color[2] or color.g) or fallback[2], 0, 1)
        local b = Clamp(tonumber(color[3] or color.b) or fallback[3], 0, 1)
        local a = Clamp(tonumber(color[4] or color.a) or fallback[4], 0, 1)
        return { r, g, b, a }
    end

    settings.fillColor = normalizeColor(settings.fillColor, DEFAULTS.fillColor)
    settings.bgColor = normalizeColor(settings.bgColor, DEFAULTS.bgColor)
    settings.titleColor = normalizeColor(settings.titleColor, DEFAULTS.titleColor)
    settings.percentColor = normalizeColor(settings.percentColor, DEFAULTS.percentColor)
    settings.tickColor = normalizeColor(settings.tickColor, DEFAULTS.tickColor)
    settings.sparkColor = normalizeColor(settings.sparkColor, DEFAULTS.sparkColor)
    settings.borderColor = normalizeColor(settings.borderColor, DEFAULTS.borderColor)
    if settings.borderColorLinked == nil then
        settings.borderColorLinked = true
    end
end

local function NormalizeDisplaySettings()
    local runtime = GetRuntimeModule("SettingsRuntime")
    if runtime and type(runtime.NormalizeDisplaySettings) == "function" then
        runtime:NormalizeDisplaySettings(settings, {
            constants = Preydator.Constants,
            defaults = DEFAULTS,
            maxStage = MAX_STAGE,
            clamp = Clamp,
        })
        return
    end

    settings.showTicks = settings.showTicks ~= false
    settings.showSparkLine = settings.showSparkLine == true
    settings.showInEditMode = settings.showInEditMode ~= false

    local mode = settings.percentDisplay
    if mode == "below" then
        mode = PERCENT_DISPLAY_BELOW_BAR
    end

    if mode ~= PERCENT_DISPLAY_INSIDE
        and mode ~= PERCENT_DISPLAY_BELOW_BAR
        and mode ~= "above_bar"
        and mode ~= "above_ticks"
        and mode ~= PERCENT_DISPLAY_UNDER_TICKS
        and mode ~= PERCENT_DISPLAY_OFF
    then
        settings.percentDisplay = PERCENT_DISPLAY_INSIDE
    else
        settings.percentDisplay = mode
    end

    settings.tickLayerMode = LAYER_MODE_ABOVE

    settings.percentFallbackMode = PERCENT_FALLBACK_STAGE

    local labelMode = settings.stageLabelMode
    if labelMode ~= LABEL_MODE_CENTER
        and labelMode ~= LABEL_MODE_LEFT
        and labelMode ~= "left_combined"
        and labelMode ~= LABEL_MODE_LEFT_SUFFIX
        and labelMode ~= LABEL_MODE_RIGHT
        and labelMode ~= "right_combined"
        and labelMode ~= LABEL_MODE_RIGHT_PREFIX
        and labelMode ~= LABEL_MODE_SEPARATE
        and labelMode ~= LABEL_MODE_NONE
    then
        settings.stageLabelMode = LABEL_MODE_CENTER
    end

    if settings.labelRowPosition ~= "above" and settings.labelRowPosition ~= "below" then
        settings.labelRowPosition = "above"
    end

    if settings.orientation ~= "horizontal" and settings.orientation ~= "vertical" then
        settings.orientation = "horizontal"
    end

    if settings.verticalFillDirection ~= "up" and settings.verticalFillDirection ~= "down" then
        settings.verticalFillDirection = "up"
    end

    if settings.verticalTextSide ~= "left" and settings.verticalTextSide ~= "right" then
        settings.verticalTextSide = "right"
    end

    -- migrate old "off" and "inside" values to new vocabulary
    if settings.verticalPercentSide == "off" then
        settings.verticalPercentSide = "center"
    elseif settings.verticalPercentSide == "inside" then
        settings.verticalPercentSide = "center"
    end
    if settings.verticalPercentSide ~= "left"
        and settings.verticalPercentSide ~= "center"
        and settings.verticalPercentSide ~= "right"
    then
        settings.verticalPercentSide = "center"
    end

    local verticalPercentDisplay = settings.verticalPercentDisplay
    if verticalPercentDisplay == PERCENT_DISPLAY_INSIDE_BELOW then
        verticalPercentDisplay = PERCENT_DISPLAY_INSIDE
    end
    if verticalPercentDisplay ~= PERCENT_DISPLAY_INSIDE
        and verticalPercentDisplay ~= PERCENT_DISPLAY_BELOW_BAR
        and verticalPercentDisplay ~= PERCENT_DISPLAY_ABOVE_BAR
        and verticalPercentDisplay ~= PERCENT_DISPLAY_OFF
    then
        settings.verticalPercentDisplay = PERCENT_DISPLAY_INSIDE
    else
        settings.verticalPercentDisplay = verticalPercentDisplay
    end

    if settings.percentDisplay == PERCENT_DISPLAY_INSIDE_BELOW then
        settings.percentDisplay = PERCENT_DISPLAY_INSIDE
    end

    settings.showAlignmentDot = false

    local verticalTextAlign = settings.verticalTextAlign
    if verticalTextAlign ~= "top"
        and verticalTextAlign ~= "middle"
        and verticalTextAlign ~= "bottom"
        and verticalTextAlign ~= "top_prefix_only"
        and verticalTextAlign ~= "top_suffix_only"
        and verticalTextAlign ~= "bottom_prefix_only"
        and verticalTextAlign ~= "bottom_suffix_only"
        and verticalTextAlign ~= "separate"
    then
        settings.verticalTextAlign = "separate"
    end

    local legacyWidth = tonumber(settings.width)
    local legacyHeight = tonumber(settings.height)

    local horizontalWidth = tonumber(settings.horizontalWidth)
    if not horizontalWidth then
        horizontalWidth = legacyWidth or DEFAULTS.horizontalWidth
    end
    settings.horizontalWidth = Clamp(math.floor(horizontalWidth + 0.5), 100, 350)

    local horizontalHeight = tonumber(settings.horizontalHeight)
    if not horizontalHeight then
        horizontalHeight = legacyHeight or DEFAULTS.horizontalHeight
    end
    settings.horizontalHeight = Clamp(math.floor(horizontalHeight + 0.5), 10, 60)

    local verticalWidth = tonumber(settings.verticalWidth)
    if not verticalWidth then
        if settings.orientation == ORIENTATION_VERTICAL and legacyWidth then
            verticalWidth = legacyWidth
        else
            verticalWidth = DEFAULTS.verticalWidth
        end
    end
    settings.verticalWidth = Clamp(math.floor(verticalWidth + 0.5), 10, 60)

    local verticalHeight = tonumber(settings.verticalHeight)
    if not verticalHeight then
        if settings.orientation == ORIENTATION_VERTICAL and legacyHeight then
            verticalHeight = legacyHeight
        else
            verticalHeight = DEFAULTS.verticalHeight
        end
    end
    settings.verticalHeight = Clamp(math.floor(verticalHeight + 0.5), 100, 350)

    local legacySideOffset = tonumber(settings.verticalSideOffset)
    if not legacySideOffset then
        legacySideOffset = 10
    end

    local verticalTextOffset = tonumber(settings.verticalTextOffset)
    if not verticalTextOffset then
        verticalTextOffset = legacySideOffset
    end
    settings.verticalTextOffset = Clamp(math.floor(verticalTextOffset + 0.5), 2, 60)

    local verticalPercentOffset = tonumber(settings.verticalPercentOffset)
    if not verticalPercentOffset then
        verticalPercentOffset = legacySideOffset
    end
    settings.verticalPercentOffset = Clamp(math.floor(verticalPercentOffset + 0.5), 2, 60)

    settings.verticalSideOffset = settings.verticalTextOffset

    if settings.orientation == ORIENTATION_VERTICAL then
        settings.width = settings.verticalWidth
        settings.height = settings.verticalHeight
    else
        settings.width = settings.horizontalWidth
        settings.height = settings.horizontalHeight
    end

    if type(settings.point) ~= "table" then
        settings.point = {}
    end
    settings.point.anchor = "CENTER"
    settings.point.relativePoint = "CENTER"
    if settings.point.x ~= nil then
        settings.point.x = Round(tonumber(settings.point.x) or 0)
    end
    if settings.point.y ~= nil then
        settings.point.y = Round(tonumber(settings.point.y) or 0)
    end

    if type(settings.stageSuffixLabels) ~= "table" then
        settings.stageSuffixLabels = {}
    end
    for i = 1, MAX_STAGE do
        if type(settings.stageSuffixLabels[i]) ~= "string" then
            settings.stageSuffixLabels[i] = ""
        end
    end
end

Preydator.GetRenderedVerticalPercent = function(rawPct, fillDirection)
    if fillDirection == FILL_DIRECTION_DOWN then
        return 100 - rawPct
    end

    return rawPct
end

Preydator.ResolveVerticalTextAnchor = function(side, align, offset, isSuffix)
    local sidePoint = (side == "left") and "LEFT" or "RIGHT"
    local topAnchor = "TOP" .. sidePoint
    local middleAnchor = sidePoint
    local bottomAnchor = "BOTTOM" .. sidePoint

    local relSidePoint = sidePoint
    local topRelative = "TOP" .. relSidePoint
    local middleRelative = relSidePoint
    local bottomRelative = "BOTTOM" .. relSidePoint
    local xOffset = (side == "left") and -(offset + FILL_INSET) or (offset + FILL_INSET)
    local gap = 14

    if align == "top" then
        if side == "left" then
            if isSuffix then
                return "TOPRIGHT", topRelative, xOffset, -2
            end
            return "TOPRIGHT", topRelative, xOffset, -(gap + 10)
        end
        local y = -2
        return "TOPLEFT", topRelative, xOffset, y
    end

    if align == "middle" then
        if side == "left" then
            if isSuffix then
                return "TOPRIGHT", middleRelative, xOffset, math.floor(gap / 2)
            end
            return "BOTTOMLEFT", middleRelative, xOffset, -math.floor(gap / 2)
        end
        if isSuffix then
            return "BOTTOM" .. sidePoint, middleRelative, xOffset, math.floor(gap / 2)
        end
        return "TOP" .. sidePoint, middleRelative, xOffset, -math.floor(gap / 2)
    end

    if align == "bottom" then
        if side == "left" then
            if isSuffix then
                return "TOPRIGHT", bottomRelative, xOffset, -(gap + 10)
            end
            return bottomAnchor, bottomRelative, xOffset, -10
        end
        local y = -10
        return bottomAnchor, bottomRelative, xOffset, y
    end

    if align == "top_prefix_only" then
        if side == "left" then
            if isSuffix then
                return bottomAnchor, bottomRelative, xOffset, -10
            end
            return "TOPRIGHT", topRelative, xOffset, -2
        end
        if isSuffix then
            return bottomAnchor, bottomRelative, xOffset, -10
        end
        return "TOPLEFT", topRelative, xOffset, -2
    end

    if align == "top_suffix_only" then
        if side == "left" then
            if isSuffix then
                return "TOPRIGHT", topRelative, xOffset, -2
            end
            return bottomAnchor, bottomRelative, xOffset, -10
        end
        if isSuffix then
            return "TOPLEFT", topRelative, xOffset, -2
        end
        return bottomAnchor, bottomRelative, xOffset, -10
    end

    if align == "bottom_prefix_only" then
        if side == "left" then
            if isSuffix then
                return "TOPRIGHT", topRelative, xOffset, -2
            end
            return bottomAnchor, bottomRelative, xOffset, -10
        end
        if isSuffix then
            return "TOPLEFT", topRelative, xOffset, -2
        end
        return bottomAnchor, bottomRelative, xOffset, -10
    end

    if align == "bottom_suffix_only" then
        if side == "left" then
            if isSuffix then
                return bottomAnchor, bottomRelative, xOffset, -10
            end
            return "TOPRIGHT", topRelative, xOffset, -2
        end
        if isSuffix then
            return bottomAnchor, bottomRelative, xOffset, -10
        end
        return "TOPLEFT", topRelative, xOffset, -2
    end

    if side == "left" then
        if isSuffix then
            return "TOPRIGHT", topRelative, xOffset, -2
        end
        return bottomAnchor, bottomRelative, xOffset, -10
    end

    if isSuffix then
        return bottomAnchor, bottomRelative, xOffset, -10
    end

    return "TOPLEFT", topRelative, xOffset, -2
end

local function NormalizeProgressSettings()
    local runtime = GetRuntimeModule("SettingsRuntime")
    if runtime and type(runtime.NormalizeProgressSettings) == "function" then
        runtime:NormalizeProgressSettings(settings, {
            constants = Preydator.Constants,
        })
        return
    end

    local mode = settings.progressSegments
    if mode ~= PROGRESS_SEGMENTS_QUARTERS and mode ~= PROGRESS_SEGMENTS_THIRDS then
        settings.progressSegments = PROGRESS_SEGMENTS_QUARTERS
        return
    end

    settings.progressSegments = mode
end

local function NormalizeTransientSettings()
    local runtime = GetRuntimeModule("SettingsRuntime")
    if runtime and type(runtime.NormalizeTransientSettings) == "function" then
        runtime:NormalizeTransientSettings(settings)
        return
    end

    -- Legacy migration: older builds persisted this debug/session flag in SavedVariables.
    -- Keep an explicit false value so stale true values are always corrected on next save.
    settings.forceShowBar = false
end

local function NormalizeAmbushSettings()
    local runtime = GetRuntimeModule("SettingsRuntime")
    if runtime and type(runtime.NormalizeAmbushSettings) == "function" then
        runtime:NormalizeAmbushSettings(settings, {
            killSoundPath = KILL_SOUND_PATH,
            getSoundPathForKey = GetSoundPathForKey,
        })
        return
    end

    settings.ambushSoundEnabled = settings.ambushSoundEnabled ~= false
    settings.ambushVisualEnabled = settings.ambushVisualEnabled ~= false
    settings.bloodyCommandSoundEnabled = settings.bloodyCommandSoundEnabled ~= false
    settings.bloodyCommandVisualEnabled = settings.bloodyCommandVisualEnabled ~= false

    if type(settings.ambushSoundPath) ~= "string" or settings.ambushSoundPath == "" then
        local legacySoundKey = settings.ambushSoundKey
        settings.ambushSoundPath = GetSoundPathForKey(legacySoundKey, KILL_SOUND_PATH)
    end

    if type(settings.bloodyCommandSoundPath) ~= "string" or settings.bloodyCommandSoundPath == "" then
        settings.bloodyCommandSoundPath = KILL_SOUND_PATH
    end

    settings.ambushSoundKey = nil
    settings.ambushCustomSoundPath = nil
end

local function IsPreyQuestOnCurrentMap(questID)
    local runtime = GetRuntimeModule("PreyContextRuntime")
    if runtime and type(runtime.IsPreyQuestOnCurrentMap) == "function" then
        return runtime:IsPreyQuestOnCurrentMap(questID, {
            questLog = C_QuestLog,
        })
    end

    if not (questID and C_QuestLog and C_QuestLog.GetLogIndexForQuestID and C_QuestLog.GetInfo) then
        return nil
    end

    local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
    if not logIndex then
        return nil
    end

    local info = C_QuestLog.GetInfo(logIndex)
    if type(info) ~= "table" then
        return nil
    end

    if info.isOnMap == nil then
        return nil
    end

    return info.isOnMap == true
end

local function RefreshInPreyZoneStatus(questID, force)
    local runtime = GetRuntimeModule("PreyContextRuntime")
    if runtime and type(runtime.RefreshInPreyZoneStatus) == "function" then
        return runtime:RefreshInPreyZoneStatus(questID, force, state, {
            isValidQuestID = IsValidQuestID,
            getTime = GetTime,
            mapApi = C_Map,
            questLog = C_QuestLog,
        })
    end

    if not IsValidQuestID(questID) then
        state.inPreyZone = nil
        return nil
    end

    local now = GetTime and GetTime() or 0
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
    if state.preyZoneMapID then
        if C_Map and C_Map.GetBestMapForUnit and C_Map.GetMapInfo then
            if state.zoneCacheDirty == true or type(state.playerMapHierarchy) ~= "table" then
                local okPlayerMapID, rawPlayerMapID = pcall(C_Map.GetBestMapForUnit, "player")
                local okNumericMapID, playerMapID = pcall(function()
                    return tonumber(rawPlayerMapID)
                end)
                playerMapID = (okPlayerMapID and okNumericMapID and playerMapID and playerMapID > 0) and playerMapID or nil
                state.playerMapID = playerMapID
                state.playerMapHierarchy = {}
                state.zoneCacheDirty = false

                local guard = 0
                local currentMapID = playerMapID
                while currentMapID and guard < 20 do
                    state.playerMapHierarchy[currentMapID] = true

                    local okMapInfo, mapInfo = pcall(C_Map.GetMapInfo, currentMapID)
                    mapInfo = okMapInfo and mapInfo or nil
                    local okParentMapID, parentMapID = pcall(function()
                        return tonumber(mapInfo and mapInfo.parentMapID)
                    end)
                    parentMapID = (okParentMapID and parentMapID and parentMapID > 0) and parentMapID or nil
                    if not parentMapID then
                        break
                    end

                    currentMapID = parentMapID
                    guard = guard + 1
                end
            end

            if state.playerMapID then
                inPreyZone = state.playerMapHierarchy[state.preyZoneMapID] == true
            end
        end
    else
        inPreyZone = IsPreyQuestOnCurrentMap(questID)
        -- For quests with no task-quest map ID, treat this as our zone snapshot.
        state.zoneCacheDirty = false
    end

    if inPreyZone == nil then
        inPreyZone = IsPreyQuestOnCurrentMap(questID)
        state.zoneCacheDirty = false
    end

    state.inPreyZone = inPreyZone
    state.lastZoneStatusRefreshAt = now
    return inPreyZone
end

GetSoundPathForKey = function(soundKey, fallbackPath)
    local runtime = GetRuntimeModule("SoundsRuntime")
    if runtime and type(runtime.GetSoundPathForKey) == "function" then
        return runtime:GetSoundPathForKey(soundKey, fallbackPath, {
            soundKeys = {
                alert = AMBUSH_SOUND_ALERT,
                ambush = AMBUSH_SOUND_AMBUSH,
                torment = AMBUSH_SOUND_TORMENT,
                kill = AMBUSH_SOUND_KILL,
            },
            soundPaths = {
                alert = ALERT_SOUND_PATH,
                ambush = AMBUSH_SOUND_PATH,
                torment = TORMENT_SOUND_PATH,
                kill = KILL_SOUND_PATH,
            },
        })
    end

    return fallbackPath
end

local function GetCurrentActivePreyQuest()
    local runtime = GetRuntimeModule("PreyContextRuntime")
    if runtime and type(runtime.GetCurrentActivePreyQuest) == "function" then
        return runtime:GetCurrentActivePreyQuest({
            questLog = C_QuestLog,
        })
    end

    if C_QuestLog and C_QuestLog.GetActivePreyQuest then
        return C_QuestLog.GetActivePreyQuest()
    end

    return nil
end

local function RefreshCurrentActivePreyQuestCache()
    local runtime = GetRuntimeModule("PreyContextRuntime")
    if runtime and type(runtime.RefreshCurrentActivePreyQuestCache) == "function" then
        return runtime:RefreshCurrentActivePreyQuestCache(state, {
            getTime = GetTime,
            getCurrentActivePreyQuest = GetCurrentActivePreyQuest,
        })
    end

    local now = GetTime and GetTime() or 0
    state.cachedActivePreyQuestID = GetCurrentActivePreyQuest()
    state.cachedActivePreyQuestAt = now
    return state.cachedActivePreyQuestID
end

local function GetCurrentActivePreyQuestCached(maxAgeSeconds)
    local runtime = GetRuntimeModule("PreyContextRuntime")
    if runtime and type(runtime.GetCurrentActivePreyQuestCached) == "function" then
        return runtime:GetCurrentActivePreyQuestCached(maxAgeSeconds, state, {
            getTime = GetTime,
            defaultMaxAgeSeconds = ACTIVE_PREY_QUEST_CACHE_SECONDS,
            getCurrentActivePreyQuest = GetCurrentActivePreyQuest,
        })
    end

    local now = GetTime and GetTime() or 0
    local maxAge = tonumber(maxAgeSeconds)
    if not maxAge or maxAge < 0 then
        maxAge = ACTIVE_PREY_QUEST_CACHE_SECONDS
    end

    if (now - (state.cachedActivePreyQuestAt or 0)) > maxAge then
        return RefreshCurrentActivePreyQuestCache()
    end

    return state.cachedActivePreyQuestID
end

local function ArmQuestListenBurst(durationSeconds)
    local runtime = GetRuntimeModule("PreyContextRuntime")
    if runtime and type(runtime.ArmQuestListenBurst) == "function" then
        runtime:ArmQuestListenBurst(durationSeconds, state, {
            getTime = GetTime,
            defaultBurstSeconds = QUEST_LISTEN_BURST_SECONDS,
            getCurrentActivePreyQuest = GetCurrentActivePreyQuest,
        })
        return
    end

    local now = GetTime and GetTime() or 0
    local duration = tonumber(durationSeconds)
    if not duration or duration <= 0 then
        duration = QUEST_LISTEN_BURST_SECONDS
    end
    local untilTime = now + duration
    if untilTime > (state.questListenUntil or 0) then
        state.questListenUntil = untilTime
    end
    -- Force a fresh quest sample when a relevant interaction starts.
    RefreshCurrentActivePreyQuestCache()
end

local function GetQuestTitle(questID)
    if not (C_QuestLog and C_QuestLog.GetTitleForQuestID) then
        return nil
    end

    local titleInfo = C_QuestLog.GetTitleForQuestID(questID)
    if type(titleInfo) == "table" then
        return titleInfo.title
    end

    return titleInfo
end

local function ExtractPreyTargetFromQuestTitle(questID)
    if type(questID) ~= "number" or questID < 1 then
        return nil, nil
    end

    local title = GetQuestTitle(questID)
    if type(title) ~= "string" or title == "" then
        return nil, nil
    end

    local preyName, difficulty = title:match("^%s*[Pp]rey:%s*(.-)%s*%((.-)%)%s*$")
    if preyName and preyName ~= "" then
        return preyName, difficulty
    end

    preyName = title:match("^%s*[Pp]rey:%s*(.-)%s*$")
    if preyName and preyName ~= "" then
        return preyName, nil
    end

    return nil, nil
end

local function IsRestrictedInstanceForPreyBar()
    local inInstance = false
    local instanceType = nil

    if IsInInstance then
        local ok, inInst, instType = pcall(IsInInstance)
        if ok then
            inInstance = inInst == true
            instanceType = instType
        end
    end

    if inInstance then
        return instanceType == "party"
            or instanceType == "raid"
            or instanceType == "scenario"
            or instanceType == "delve"
    end

    -- Fallback: some Delve transitions can report inconsistent IsInInstance states
    -- while the player map is already a dungeon-type map.
    if C_Map and C_Map.GetBestMapForUnit and C_Map.GetMapInfo then
        local okPlayerMapID, rawPlayerMapID = pcall(C_Map.GetBestMapForUnit, "player")
        local okNumericMapID, playerMapID = pcall(function()
            return tonumber(rawPlayerMapID)
        end)
        playerMapID = (okPlayerMapID and okNumericMapID and playerMapID and playerMapID > 0) and playerMapID or nil
        if playerMapID then
            local okMapInfo, mapInfo = pcall(C_Map.GetMapInfo, playerMapID)
            mapInfo = okMapInfo and mapInfo or nil
            local okMapType, mapType = pcall(function()
                return tonumber(mapInfo and mapInfo.mapType)
            end)
            mapType = (okMapType and mapType and mapType > 0) and mapType or nil
            if mapType == 4 then
                return true
            end
        end
    end

    return false
end

local function TriggerAmbushAlert(message, source)
    local now = GetTime and GetTime() or 0
    state.lastAmbushSystemMessage = message

    if settings.ambushVisualEnabled ~= false then
        state.ambushAlertUntil = now + AMBUSH_ALERT_DURATION_SECONDS
    end

    if settings.ambushSoundEnabled ~= false then
        local nextSoundAt = (state.lastAmbushSoundAt or 0) + AMBUSH_SOUND_COOLDOWN_SECONDS
        if now >= nextSoundAt then
            local ambushPath = Preydator.API.ResolveAmbushSoundPath()
            TryPlaySound(ambushPath)
            state.lastAmbushSoundAt = now
        end
    end

    AddDebugLog("Ambush", "Detected from " .. tostring(source) .. ": " .. tostring(message), true)
    UpdateBarDisplay()
end

local function ClearBloodyCommandAlert()
    state.bloodyCommandAlertUntil = 0
    state.bloodyCommandSourceName = nil
    state.lastBloodyCommandSpellID = nil
end

local function TriggerBloodyCommandAlert(spellID, sourceName, source)
    local now = GetTime and GetTime() or 0

    state.lastBloodyCommandSpellID = tonumber(spellID)
    state.bloodyCommandSourceName = sourceName

    if settings.bloodyCommandVisualEnabled ~= false then
        state.bloodyCommandAlertUntil = now + 20
    else
        state.bloodyCommandAlertUntil = 0
    end

    if settings.bloodyCommandSoundEnabled ~= false then
        local path = Preydator.API.ResolveBloodyCommandSoundPath()
        if path then
            TryPlaySound(path)
        end
    end

    AddDebugLog("BloodyCommand", "Detected from " .. tostring(source) .. " | spellID=" .. tostring(spellID) .. " | sourceName=" .. tostring(sourceName), true)
    UpdateBarDisplay()
end

local function IsQuestStillActive(questID)
    if not questID or questID < 1 then
        return false
    end

    if C_QuestLog and C_QuestLog.IsOnQuest then
        return C_QuestLog.IsOnQuest(questID) and true or false
    end

    return true
end

IsValidQuestID = function(questID)
    return type(questID) == "number" and questID > 0
end

local function EnsureDebugDB()
    _G.PreydatorDebugDB = _G.PreydatorDebugDB or {}
    debugDB = _G.PreydatorDebugDB
    if type(debugDB.entries) ~= "table" then
        debugDB.entries = {}
    end
    if debugDB.enabled == nil then
        debugDB.enabled = true
    end
end

AddDebugLog = function(kind, message, forcePrint)
    if not debugDB then
        return
    end

    if not debugDB.enabled then
        return
    end

    local now = GetTime and GetTime() or 0
    local entry = string.format("%0.3f | %s | %s", now, tostring(kind or "?"), tostring(message or ""))
    table.insert(debugDB.entries, entry)

    while #debugDB.entries > DEBUG_LOG_LIMIT do
        table.remove(debugDB.entries, 1)
    end

    if forcePrint then
        print("Preydator DEBUG: " .. entry)
    end
end

TryPlaySound = function(path, ignoreSoundToggle)
    local runtime = GetRuntimeModule("SoundsRuntime")
    if runtime and type(runtime.TryPlaySound) == "function" then
        return runtime:TryPlaySound(path, ignoreSoundToggle, settings, {
            isSoundsModuleEnabled = function()
                local customization = Preydator and Preydator.GetModule and Preydator:GetModule("CustomizationStateV2")
                if customization and type(customization.IsModuleEnabled) == "function" then
                    return customization:IsModuleEnabled("sounds") == true
                end
                return true
            end,
            addDebugLog = AddDebugLog,
            playSoundFile = PlaySoundFile,
            timerAfter = C_Timer and C_Timer.After or nil,
            warnedMissingSoundPaths = warnedMissingSoundPaths,
            printFn = print,
        })
    end

    local customization = Preydator and Preydator.GetModule and Preydator:GetModule("CustomizationStateV2")
    if customization and type(customization.IsModuleEnabled) == "function" and customization:IsModuleEnabled("sounds") ~= true then
        AddDebugLog("TryPlaySound", "blocked by sounds module disabled | path=" .. tostring(path), false)
        return false
    end

    if not ignoreSoundToggle and settings and settings.soundsEnabled == false then
        AddDebugLog("TryPlaySound", "blocked by soundsEnabled=false | path=" .. tostring(path), false)
        return false
    end

    local channel = (settings and settings.soundChannel) or "SFX"
    local willPlay = PlaySoundFile(path, channel)
    AddDebugLog("TryPlaySound", "path=" .. tostring(path) .. " | channel=" .. tostring(channel) .. " | ignoreToggle=" .. tostring(ignoreSoundToggle) .. " | result=" .. tostring(willPlay), false)
    if willPlay then
        local enhance = (settings and tonumber(settings.soundEnhance)) or 0
        if enhance > 0 and C_Timer and C_Timer.After then
            local extraPlays = math.min(4, math.max(0, math.floor(enhance / 25)))
            for i = 1, extraPlays do
                local delay = i * 0.03
                C_Timer.After(delay, function()
                    PlaySoundFile(path, channel)
                end)
            end
            if extraPlays > 0 then
                AddDebugLog("TryPlaySound", "enhance=" .. tostring(enhance) .. " | extraPlays=" .. tostring(extraPlays), false)
            end
        end
        return true
    end

    local warnedKey = tostring(path or "")
    if warnedMissingSoundPaths[warnedKey] ~= true then
        warnedMissingSoundPaths[warnedKey] = true
        print("Preydator: Sound failed to play: '" .. warnedKey .. "'. Ensure the .ogg exists in Interface\\AddOns\\Preydator\\sounds\\ and is listed in Custom Sound Files.")
    end

    return false
end

TryPlayStageSound = function(stage, ignoreSoundToggle)
    local path = Preydator.API.ResolveStageSoundPath(stage)
    if not path then
        AddDebugLog("TryPlayStageSound", "stage=" .. tostring(stage) .. " | no resolved path", true)
        return false
    end

    if state.stageSoundPlayed[stage] then
        AddDebugLog("TryPlayStageSound", "stage=" .. tostring(stage) .. " | skipped already played", false)
        return false
    end

    if state.stageSoundAttempted[stage] then
        return false
    end

    state.stageSoundAttempted[stage] = true

    if TryPlaySound(path, ignoreSoundToggle) then
        state.stageSoundPlayed[stage] = true
        AddDebugLog("TryPlayStageSound", "stage=" .. tostring(stage) .. " | success", false)
        return true
    end

    if stage == MAX_STAGE then
        local fallbackPath = Preydator.API.ResolveStageSoundPath(MAX_STAGE - 1)
        if fallbackPath then
            AddDebugLog("TryPlayStageSound", "stage=" .. tostring(MAX_STAGE) .. " | primary failed, trying fallback stage=" .. tostring(MAX_STAGE - 1) .. " | path=" .. tostring(fallbackPath), true)
            if TryPlaySound(fallbackPath, ignoreSoundToggle) then
                state.stageSoundPlayed[stage] = true
                AddDebugLog("TryPlayStageSound", "stage=" .. tostring(MAX_STAGE) .. " | fallback stage=" .. tostring(MAX_STAGE - 1) .. " success", true)
                return true
            end
            AddDebugLog("TryPlayStageSound", "stage=" .. tostring(MAX_STAGE) .. " | fallback stage=" .. tostring(MAX_STAGE - 1) .. " also failed", true)
        end
    end

    local channel = (settings and settings.soundChannel) or "SFX"
    AddDebugLog("TryPlayStageSound", "stage=" .. tostring(stage) .. " | path=" .. tostring(path) .. " | channel=" .. tostring(channel) .. " | PlaySoundFile returned false", true)

    return false
end

local barPositionUtil = {
    defaultX = 0,
    defaultY = 472,
}

function barPositionUtil.GetDefaultPoint(frameWidth, frameHeight)
    return barPositionUtil.defaultX, barPositionUtil.defaultY
end

function barPositionUtil.ClampToScreen(x, y, frameWidth, frameHeight)
    local parentWidth = UIParent and UIParent.GetWidth and UIParent:GetWidth() or 0
    local parentHeight = UIParent and UIParent.GetHeight and UIParent:GetHeight() or 0
    local width = math.max(1, tonumber(frameWidth) or 0)
    local height = math.max(1, tonumber(frameHeight) or 0)
    local margin = 8

    if parentWidth <= 0 or parentHeight <= 0 then
        local defaultX, defaultY = barPositionUtil.GetDefaultPoint(width, height)
        return Round(tonumber(x) or defaultX), Round(tonumber(y) or defaultY)
    end

    local maxX = math.max(0, math.floor(((parentWidth - width) / 2) - margin))
    local maxY = math.max(0, math.floor(((parentHeight - height) / 2) - margin))
    local defaultX, defaultY = barPositionUtil.GetDefaultPoint(width, height)
    local clampedX = Clamp(Round(tonumber(x) or defaultX), -maxX, maxX)
    local clampedY = Clamp(Round(tonumber(y) or defaultY), -maxY, maxY)
    return clampedX, clampedY
end

function barPositionUtil.GetCurrentDimensions()
    local orientation = settings and settings.orientation or ORIENTATION_HORIZONTAL
    local frameScale
    local baseWidth
    local baseHeight

    if orientation == ORIENTATION_VERTICAL then
        frameScale = Clamp(tonumber(settings and settings.verticalScale) or DEFAULTS.verticalScale, 0.5, 2)
        baseWidth = Clamp(math.floor((tonumber(settings and settings.verticalWidth) or DEFAULTS.verticalWidth) + 0.5), 10, 60)
        baseHeight = Clamp(math.floor((tonumber(settings and settings.verticalHeight) or DEFAULTS.verticalHeight) + 0.5), 100, 350)
    else
        frameScale = Clamp(tonumber(settings and settings.scale) or DEFAULTS.scale, 0.5, 2)
        baseWidth = Clamp(math.floor((tonumber(settings and settings.horizontalWidth) or DEFAULTS.horizontalWidth) + 0.5), 100, 350)
        baseHeight = Clamp(math.floor((tonumber(settings and settings.horizontalHeight) or DEFAULTS.horizontalHeight) + 0.5), 10, 60)
    end

    return math.max(1, Round(baseWidth * frameScale)), math.max(1, Round(baseHeight * frameScale))
end

function barPositionUtil.Reset()
    settings.point = settings.point or {}
    settings.point.anchor = "CENTER"
    settings.point.relativePoint = "CENTER"

    local width, height = barPositionUtil.GetCurrentDimensions()
    settings.point.x, settings.point.y = barPositionUtil.GetDefaultPoint(width, height)
    do
        local runtime = GetRuntimeModule("SettingsRuntime")
        if runtime and type(runtime.SyncBarPointToBackup) == "function" then
            runtime:SyncBarPointToBackup(settings)
        end
    end

    ApplyBarSettings()
    UpdateBarDisplay()
end

ApplyBarSettings = function()
    if type(BarRuntimeApplyHandler) == "function" then
        return BarRuntimeApplyHandler()
    end

    if Preydator and type(Preydator.PrintDebug) == "function" then
        Preydator:PrintDebug("Bar runtime handler missing; skipping ApplyBarSettings delegate.")
    end
end

local function EnsureBar()
    local customizationV2 = Preydator:GetModule("CustomizationStateV2")
    local barEnabled = true
    if customizationV2 and type(customizationV2.IsModuleEnabled) == "function" then
        barEnabled = customizationV2:IsModuleEnabled("bar") == true
    end
    if not barEnabled then
        if UI.barFrame then
            UI.barFrame:Hide()
        end
        return
    end

    if UI.barFrame then
        return
    end

    local createdBar = CreateFrame("Frame", "PreydatorProgressBar", UIParent)
    if not createdBar then
        return
    end

    createdBar:SetSize(260, 18)
    createdBar:SetFrameStrata("MEDIUM")
    createdBar:SetFrameLevel(5)
    do
        local defaultX, defaultY = barPositionUtil.GetDefaultPoint(260, 18)
        createdBar:SetPoint("CENTER", UIParent, "CENTER", defaultX, defaultY)
    end
    createdBar:Hide()
    createdBar:SetClampedToScreen(true)
    createdBar:RegisterForDrag("LeftButton")
    UI.barFrame = createdBar

    local function SaveBarPosition(self)
        settings.point.anchor = "CENTER"
        settings.point.relativePoint = "CENTER"

        local frameWidth = self and self.GetWidth and self:GetWidth() or 0
        local frameHeight = self and self.GetHeight and self:GetHeight() or 0

        local frameCenterX, frameCenterY = self:GetCenter()
        local parentCenterX, parentCenterY = UIParent:GetCenter()
        if frameCenterX and frameCenterY and parentCenterX and parentCenterY then
            settings.point.x, settings.point.y = barPositionUtil.ClampToScreen(frameCenterX - parentCenterX, frameCenterY - parentCenterY, frameWidth, frameHeight)
            do
                local runtime = GetRuntimeModule("SettingsRuntime")
                if runtime and type(runtime.SyncBarPointToBackup) == "function" then
                    runtime:SyncBarPointToBackup(settings)
                end
            end
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "CENTER", settings.point.x, settings.point.y)
            return
        end

        local _, _, _, x, y = self:GetPoint(1)
        settings.point.x, settings.point.y = barPositionUtil.ClampToScreen(x, y, frameWidth, frameHeight)
        do
            local runtime = GetRuntimeModule("SettingsRuntime")
            if runtime and type(runtime.SyncBarPointToBackup) == "function" then
                runtime:SyncBarPointToBackup(settings)
            end
        end
        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "CENTER", settings.point.x, settings.point.y)
    end

    UI.barFrame:SetScript("OnMouseDown", function(self, button)
        self.PreydatorWasDragging = false
        self.PreydatorHandledMapClick = false
        self.PreydatorClickStartX = nil
        self.PreydatorClickStartY = nil
        self.PreydatorClickStartTime = nil

        if button ~= "LeftButton" then
            return
        end

        local editModeFrame = _G.EditModeManagerFrame
        local isEditModePreview = editModeFrame and editModeFrame.IsShown and editModeFrame:IsShown()
        local allowStageFourMapClickFallback = settings
            and settings.disableDefaultPreyIcon == true
            and state
            and state.stage == MAX_STAGE

        if allowStageFourMapClickFallback and not isEditModePreview and button == "LeftButton" then
            self.PreydatorHandledMapClick = true
            TryOpenPreyQuestOnMap()
            return
        end

        if isEditModePreview then
            self.PreydatorClickStartX, self.PreydatorClickStartY = _G.GetCursorPosition()
            self.PreydatorClickStartTime = GetTime and GetTime() or 0
        end
    end)

    UI.barFrame:SetScript("OnDragStart", function(self)
        if settings and not settings.locked then
            self.PreydatorWasDragging = true
            self:StartMoving()
        end
    end)

    UI.barFrame:SetScript("OnDragStop", function(self)
        if not self.PreydatorWasDragging then
            return
        end

        self:StopMovingOrSizing()
        self.PreydatorWasDragging = false
        SaveBarPosition(self)
    end)

    UI.barFrame:SetScript("OnMouseUp", function(self, button)
        if self.PreydatorHandledMapClick then
            self.PreydatorHandledMapClick = false
            return
        end

        if button ~= "LeftButton" then
            return
        end

        local editModeFrame = _G.EditModeManagerFrame
        if editModeFrame and editModeFrame.IsShown and editModeFrame:IsShown() then
            local startX = self.PreydatorClickStartX
            local startY = self.PreydatorClickStartY
            local startTime = self.PreydatorClickStartTime or 0
            local endX, endY = GetCursorPosition()
            local now = GetTime and GetTime() or 0

            local dx = (startX and endX) and math.abs(endX - startX) or 999
            local dy = (startY and endY) and math.abs(endY - startY) or 999
            local dt = now - startTime

            if dx <= 3 and dy <= 3 and dt <= 0.20 then
                local editModeModule = Preydator.GetModule and Preydator:GetModule("EditMode")
                if editModeModule and editModeModule.ShowWindow then
                    editModeModule:ShowWindow()
                else
                    OpenOptionsPanel()
                end
            end
            return
        end

        if button == "LeftButton"
            and settings
            and settings.disableDefaultPreyIcon == true
            and state
            and state.stage == MAX_STAGE
        then
            TryOpenPreyQuestOnMap()
        end
    end)

    local bg = UI.barFrame:CreateTexture(nil, "background")
    bg:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", FILL_INSET, FILL_INSET)
    bg:SetPoint("TOPRIGHT", UI.barFrame, "TOPRIGHT", -FILL_INSET, -FILL_INSET)
    bg:SetColorTexture(0, 0, 0, 0.6)
    UI.barFrame.BackgroundTexture = bg

    UI.barFill = UI.barFrame:CreateTexture(nil, "artwork")
    UI.barFill:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", FILL_INSET, FILL_INSET)
    UI.barFill:SetSize(0, 18)
    UI.barFill:SetTexCoord(0, 1, 0, 1)
    UI.barFill:SetHorizTile(false)
    UI.barFill:SetVertTile(false)
    UI.barFill:SetColorTexture(0.85, 0.2, 0.2, 0.95)

    UI.barSpark = UI.barFrame:CreateTexture(nil, "overlay")
    UI.barSpark:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", FILL_INSET, FILL_INSET)
    UI.barSpark:SetSize(2, 18)
    UI.barSpark:SetColorTexture(1, 0.95, 0.75, 0.9)
    UI.barSpark:SetDrawLayer("OVERLAY", 3)
    UI.barSpark:Hide()

    local border = CreateFrame("Frame", nil, UI.barFrame, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    border:SetBackdropBorderColor(0.8, 0.2, 0.2, 0.85)
    UI.barBorder = border

    UI.stageText = UI.barFrame:CreateFontString(nil, "overlay", "GameFontNormal")
    UI.stageText:SetPoint("BOTTOM", UI.barFrame, "TOP", 0, 4)
    UI.stageText:SetJustifyH("CENTER")
    UI.stageText:SetText("Preydator")

    UI.stageSuffixText = UI.barFrame:CreateFontString(nil, "overlay", "GameFontNormal")
    UI.stageSuffixText:SetPoint("BOTTOMRIGHT", UI.barFrame, "TOPRIGHT", -2, 4)
    UI.stageSuffixText:SetJustifyH("RIGHT")
    UI.stageSuffixText:SetText("")
    UI.stageSuffixText:Hide()

    UI.barText = UI.barFrame:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
    UI.barText:SetPoint("center", UI.barFrame, "center", 0, 0)
    UI.barText:SetDrawLayer("OVERLAY", 9)
    UI.barText:SetText("0%")

    UI.barAlignmentDot = UI.barFrame:CreateTexture(nil, "OVERLAY")
    UI.barAlignmentDot:SetSize(6, 6)
    UI.barAlignmentDot:SetColorTexture(0, 1, 0, 1)
    UI.barAlignmentDot:SetPoint("CENTER", UI.barFrame, "CENTER", 0, 0)
    UI.barAlignmentDot:SetDrawLayer("OVERLAY", 7)
    UI.barAlignmentDot:Hide()

    for index = 1, MAX_TICK_MARKS do
        local pct = (index * 25)
        local tickMark = UI.barFrame:CreateTexture(nil, "overlay")
        tickMark:SetColorTexture(1, 1, 1, 0.35)
        tickMark:SetDrawLayer("OVERLAY", 4)
        UI.barTickMarks[index] = tickMark

        local tickLabel = UI.barFrame:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tickLabel:SetDrawLayer("OVERLAY", 8)
        tickLabel:SetText(tostring(pct))
        UI.barTickLabels[index] = tickLabel
    end

    ApplyBarSettings()
end

local function GetStageFromState(progressState)
    if progressState == nil then
        return 1
    end

    if progressState == 0 then
        return 1
    end

    if progressState == 1 then
        return 2
    end

    if progressState == 2 then
        return 3
    end

    if progressState == PREY_PROGRESS_FINAL then
        return 4
    end

    return 1
end

local function ExtractProgressPercentFromInfoScan(info)
    if type(info) ~= "table" then
        return nil
    end

    for key, value in pairs(info) do
        if type(value) == "number" then
            local keyText = string.lower(tostring(key))
            if string.find(keyText, "percent", 1, true) then
                local pct = nil
                if value >= 0 and value <= 1 then
                    pct = Clamp(value * 100, 0, 100)
                else
                    pct = Clamp(value, 0, 100)
                end
                if pct ~= nil then
                    return pct
                end
            end
        end
    end

    local currentValues = {}
    local maxValues = {}
    for key, value in pairs(info) do
        if type(value) == "number" and value >= 0 then
            local keyText = string.lower(tostring(key))
            if string.find(keyText, "current", 1, true)
                or string.find(keyText, "value", 1, true)
                or string.find(keyText, "progress", 1, true)
                or string.find(keyText, "fulfilled", 1, true)
                or string.find(keyText, "completed", 1, true)
            then
                currentValues[#currentValues + 1] = value
            end

            if string.find(keyText, "max", 1, true)
                or string.find(keyText, "total", 1, true)
                or string.find(keyText, "required", 1, true)
            then
                maxValues[#maxValues + 1] = value
            end
        end
    end

    for _, current in ipairs(currentValues) do
        for _, maxValue in ipairs(maxValues) do
            if maxValue > 0 and current <= maxValue then
                local pct = Clamp((current / maxValue) * 100, 0, 100)
                if pct >= 0 and pct <= 100 then
                    return pct
                end
            end
        end
    end

    return nil
end

local function ExtractProgressPercent(info, tooltipText)
    if type(info) == "table" then
        local directFields = {
            "progressPercentage",
            "progressPercent",
            "fillPercentage",
            "percentage",
            "percent",
            "progress",
            "progressValue",
        }

        for _, fieldName in ipairs(directFields) do
            local rawValue = info[fieldName]
            local pct = nil
            if type(rawValue) == "number" then
                if rawValue >= 0 and rawValue <= 1 then
                    pct = Clamp(rawValue * 100, 0, 100)
                else
                    pct = Clamp(rawValue, 0, 100)
                end
            end
            if pct ~= nil then
                return pct
            end
        end

        local valueFields = { "barValue", "value", "currentValue" }
        local maxFields = { "barMax", "maxValue", "totalValue", "total", "max" }
        for _, valueField in ipairs(valueFields) do
            local current = info[valueField]
            if type(current) == "number" then
                for _, maxField in ipairs(maxFields) do
                    local maxValue = info[maxField]
                    if type(maxValue) == "number" and maxValue > 0 then
                        return Clamp((current / maxValue) * 100, 0, 100)
                    end
                end
            end
        end
    end

    local scannedPct = ExtractProgressPercentFromInfoScan(info)
    if scannedPct ~= nil then
        return scannedPct
    end

    if type(tooltipText) == "string" then
        local pctText = tooltipText:match("(%d+)%s*%%")
        local pctValue = tonumber(pctText)
        if pctValue then
            return Clamp(pctValue, 0, 100)
        end
    end

    return nil
end

local function ExtractQuestObjectivePercent(questID)
    if not IsValidQuestID(questID) then
        return nil
    end

    local questBarPct = nil
    if GetQuestProgressBarPercent then
        local okQuestBarPct, rawQuestBarPct = pcall(function()
            return tonumber(GetQuestProgressBarPercent(questID))
        end)
        if not okQuestBarPct then
            rawQuestBarPct = nil
        end
        if rawQuestBarPct ~= nil then
            questBarPct = Clamp(rawQuestBarPct, 0, 100)
        end
    end

    if not (C_QuestLog and C_QuestLog.GetQuestObjectives) then
        return nil
    end

    local objectives = C_QuestLog.GetQuestObjectives(questID)
    if type(objectives) ~= "table" or #objectives == 0 then
        return nil
    end

    local totalFulfilled = 0
    local totalRequired = 0
    local anyNumericObjective = false

    for _, objective in ipairs(objectives) do
        if type(objective) == "table" then
            local okFulfilled, fulfilled = pcall(function()
                return tonumber(objective.numFulfilled)
            end)
            local okRequired, required = pcall(function()
                return tonumber(objective.numRequired)
            end)

            if not okFulfilled then
                fulfilled = nil
            end
            if not okRequired then
                required = nil
            end

            if fulfilled == nil then
                local okLegacyFulfilled, legacyFulfilled = pcall(function()
                    return tonumber(objective.fulfilled)
                end)
                if okLegacyFulfilled then
                    fulfilled = legacyFulfilled
                end
            end
            if required == nil then
                local okLegacyRequired, legacyRequired = pcall(function()
                    return tonumber(objective.required)
                end)
                if okLegacyRequired then
                    required = legacyRequired
                end
            end

            if fulfilled ~= nil and required == nil and objective.finished ~= nil then
                required = 1
                fulfilled = objective.finished and 1 or math.max(0, fulfilled)
            end

            if fulfilled and required and required > 0 then
                anyNumericObjective = true
                totalFulfilled = totalFulfilled + math.max(0, fulfilled)
                totalRequired = totalRequired + math.max(0, required)
            else
                local text = objective.text
                if type(text) == "string" and text ~= "" then
                    local curText, maxText = text:match("(%d+)%s*/%s*(%d+)")
                    local curValue = tonumber(curText)
                    local maxValue = tonumber(maxText)
                    if curValue and maxValue and maxValue > 0 then
                        anyNumericObjective = true
                        totalFulfilled = totalFulfilled + math.max(0, curValue)
                        totalRequired = totalRequired + math.max(0, maxValue)
                    else
                        local pctText = text:match("(%d+)%s*%%")
                        local pctValue = tonumber(pctText)
                        if pctValue then
                            return Clamp(pctValue, 0, 100)
                        end
                    end
                end
            end
        end
    end

    local objectivePct = nil
    if anyNumericObjective and totalRequired > 0 then
        objectivePct = Clamp((totalFulfilled / totalRequired) * 100, 0, 100)
    end

    if objectivePct ~= nil and questBarPct ~= nil then
        return math.max(objectivePct, questBarPct)
    end

    if objectivePct ~= nil then
        return objectivePct
    end

    if questBarPct ~= nil then
        return questBarPct
    end

    return nil
end

UpdateBarDisplay = function()
    if type(BarRuntimeUpdateHandler) == "function" then
        return BarRuntimeUpdateHandler()
    end

    if Preydator and type(Preydator.PrintDebug) == "function" then
        Preydator:PrintDebug("Bar runtime handler missing; skipping UpdateBarDisplay delegate.")
    end

    RunModuleHook("OnAfterUpdateBarDisplay", {
        shouldShowBar = false,
        forceAmbushAlert = false,
        forceBloodyCommandAlert = false,
        forceKillStage = false,
        hasActiveQuest = false,
        displayPercent = 0,
        stage = state.stage,
    })
end

OpenOptionsPanel = function()
    local settingsModule = Preydator.GetModule and Preydator:GetModule("Settings")
    if settingsModule and settingsModule.OpenOptionsPanel then
        settingsModule:OpenOptionsPanel()
        return
    end

    EnsureOptionsPanel()

    if Settings and Settings.OpenToCategory then
        if type(UI.optionsCategoryID) == "number" then
            Settings.OpenToCategory(UI.optionsCategoryID)
            return
        end

        if UI.optionsPanel and type(UI.optionsPanel.categoryID) == "number" then
            Settings.OpenToCategory(UI.optionsPanel.categoryID)
            return
        end
    end

    if _G.InterfaceOptionsFrame_OpenToCategory then
        _G.InterfaceOptionsFrame_OpenToCategory("Preydator")
    end
end

local function ClearPreyStateAndDisplay()
    state.activeQuestID = nil
    state.progressState = nil
    state.progressPercent = 0
    state.preyZoneName = nil
    state.preyZoneMapID = nil
    state.inPreyZone = nil
    state.preyTooltipText = nil
    state.stage = 1
    state.killStageUntil = 0
    state.lastWidgetSeenAt = 0
    state.stageSoundPlayed = {}
    state.stageSoundAttempted = {}
    state.lastStateDebugSnapshot = nil
    state.preyTargetName = nil
    state.preyTargetDifficulty = nil
    state.ambushAlertUntil = 0
    state.lastAmbushSoundAt = 0
    state.lastAmbushSystemMessage = nil
    state.bloodyCommandAlertUntil = 0
    state.bloodyCommandSourceName = nil
    state.lastBloodyCommandSpellID = nil

    if UI.barFill then
        UI.barFill:SetWidth(0)
    end
end

local function DebugLogPreyState(origin, questID, hasWidgetData, progressState, progressPercent, inPreyZone)
    if not (debugDB and debugDB.enabled) then
        return
    end

    local snapshot = table.concat({
        tostring(origin),
        tostring(questID),
        tostring(hasWidgetData),
        tostring(progressState),
        tostring(progressPercent),
        tostring(inPreyZone),
    }, "|")

    if snapshot == state.lastStateDebugSnapshot then
        return
    end

    state.lastStateDebugSnapshot = snapshot
    AddDebugLog("PreyState", "origin=" .. tostring(origin)
        .. " | questID=" .. tostring(questID)
        .. " | widget=" .. tostring(hasWidgetData)
        .. " | state=" .. tostring(progressState)
        .. " | pct=" .. tostring(progressPercent)
        .. " | inZone=" .. tostring(inPreyZone), false)
end

local function GetCandidateWidgetSetIDs()
    for index = #UI.candidateWidgetSetIDs, 1, -1 do
        UI.candidateWidgetSetIDs[index] = nil
    end

    local function appendWidgetSetID(getter)
        if not getter then
            return
        end
        local okSetID, rawSetID = pcall(getter)
        if not okSetID then
            return
        end
        local okNumericSetID, numericSetID = pcall(function()
            return tonumber(rawSetID)
        end)
        if okNumericSetID and numericSetID and numericSetID > 0 then
            UI.candidateWidgetSetIDs[#UI.candidateWidgetSetIDs + 1] = numericSetID
        end
    end

    if C_UIWidgetManager then
        appendWidgetSetID(C_UIWidgetManager.GetTopCenterWidgetSetID)
        appendWidgetSetID(C_UIWidgetManager.GetObjectiveTrackerWidgetSetID)
        appendWidgetSetID(C_UIWidgetManager.GetBelowMinimapWidgetSetID)
        appendWidgetSetID(C_UIWidgetManager.GetPowerBarWidgetSetID)
    end

    return UI.candidateWidgetSetIDs
end

local function IsLikelyIconName(value)
    if type(value) ~= "string" then
        return false
    end

    return string.find(string.lower(value), "icon", 1, true) ~= nil
end

local function SetRegionShown(region, shouldShow)
    if not region then
        return false
    end

    if region.SetShown then
        region:SetShown(shouldShow)
        return true
    end

    if shouldShow and region.Show then
        region:Show()
        return true
    end

    if (not shouldShow) and region.Hide then
        region:Hide()
        return true
    end

    return false
end

local function ApplyWidgetFrameSuppression(frameRef, suppress)
    if not frameRef then
        return
    end

    if suppress then
        if frameRef.PreydatorWasShown == nil and frameRef.IsShown then
            frameRef.PreydatorWasShown = frameRef:IsShown() and true or false
        end
        if frameRef.Hide then
            pcall(frameRef.Hide, frameRef)
        end
    else
        if frameRef.PreydatorWasShown then
            frameRef.PreydatorWasShown = nil
            if frameRef.Show then
                pcall(frameRef.Show, frameRef)
            end
        elseif frameRef.PreydatorWasShown ~= nil then
            frameRef.PreydatorWasShown = nil
        end
    end

    if frameRef.EnableMouse then
        pcall(frameRef.EnableMouse, frameRef, not suppress)
    end
end

local function ShouldSuppressEncounterNow()
    return settings
        and settings.disableDefaultPreyIcon == true
        and ShouldSuppressDefaultPreyEncounter()
end

local function EnsureWidgetSuppressionHook(frameRef)
    if not frameRef or frameRef.PreydatorSuppressionHooked or not frameRef.HookScript then
        return
    end

    frameRef.PreydatorSuppressionHooked = true
    frameRef:HookScript("OnShow", function(self)
        local ok = pcall(function()
            if ShouldSuppressEncounterNow() then
                ApplyWidgetFrameSuppression(self, true)
            end
        end)

        if not ok then
            -- Keep gameplay stable even if Blizzard updates widget internals.
        end
    end)
end

ShouldSuppressDefaultPreyEncounter = function()
    local hasActiveQuest = IsValidQuestID(state and state.activeQuestID)
    if not hasActiveQuest then
        return false
    end

    -- Suppress default encounter visuals whenever an active prey quest is tracked.
    -- This avoids zone-specific regressions when Blizzard changes map/widget behavior.
    return true
end

local function TryGetPreyQuestWaypoint(questID)
    if not IsValidQuestID(questID) then
        return nil, nil, nil
    end

    if C_QuestLog and C_QuestLog.GetNextWaypoint then
        local waypoint = C_QuestLog.GetNextWaypoint(questID)
        if type(waypoint) == "table" then
            local waypointMapID = tonumber(waypoint.uiMapID or waypoint.mapID)
            local waypointX = tonumber((waypoint.position and waypoint.position.x) or waypoint.x)
            local waypointY = tonumber((waypoint.position and waypoint.position.y) or waypoint.y)
            if waypointMapID and waypointX and waypointY then
                return waypointMapID, waypointX, waypointY
            end
        end
    end

    local mapCandidates = {}
    local seenMapIDs = {}

    local function addMapCandidate(mapID)
        mapID = tonumber(mapID)
        if mapID and mapID > 0 and not seenMapIDs[mapID] then
            seenMapIDs[mapID] = true
            mapCandidates[#mapCandidates + 1] = mapID
        end
    end

    addMapCandidate(state and state.preyZoneMapID)
    if C_Map and C_Map.GetBestMapForUnit then
        local okPlayerMapID, playerMapID = pcall(C_Map.GetBestMapForUnit, "player")
        addMapCandidate(okPlayerMapID and playerMapID or nil)
    end

    if C_TaskQuest and C_TaskQuest.GetQuestLocation then
        for _, mapID in ipairs(mapCandidates) do
            local okCoords, x, y = pcall(C_TaskQuest.GetQuestLocation, questID, mapID)
            if not okCoords then
                x, y = nil, nil
            end
            if x and y then
                return mapID, x, y
            end
        end
    end

    if C_QuestLog and C_QuestLog.GetQuestsOnMap then
        for _, mapID in ipairs(mapCandidates) do
            local okQuests, questsOnMap = pcall(C_QuestLog.GetQuestsOnMap, mapID)
            questsOnMap = okQuests and questsOnMap or nil
            if type(questsOnMap) == "table" then
                for _, questInfo in ipairs(questsOnMap) do
                    if questInfo and questInfo.questID == questID and questInfo.x and questInfo.y then
                        return mapID, questInfo.x, questInfo.y
                    end
                end
            end
        end
    end

    return nil, nil, nil
end

TryOpenPreyQuestOnMap = function()
    if not IsValidQuestID(state and state.activeQuestID) then
        return false
    end

    local questID = state.activeQuestID
    local superTrackedQuest = false

    if C_SuperTrack and type(C_SuperTrack.SetSuperTrackedQuestID) == "function" then
        local ok = pcall(C_SuperTrack.SetSuperTrackedQuestID, questID)
        superTrackedQuest = ok == true
    end

    if _G.OpenQuestMap then
        pcall(_G.OpenQuestMap)
    elseif _G.ToggleWorldMap then
        pcall(_G.ToggleWorldMap)
    elseif _G.WorldMapFrame and _G.WorldMapFrame.Show then
        pcall(_G.WorldMapFrame.Show, _G.WorldMapFrame)
    end

    if _G.QuestMapFrame_OpenToQuestDetails then
        pcall(_G.QuestMapFrame_OpenToQuestDetails, questID)
    end

    -- Prefer quest super-tracking (same behavior as clicking the default icon).
    -- Fall back to user waypoint only when quest super-track API is unavailable.
    if not superTrackedQuest then
        local mapID, x, y = TryGetPreyQuestWaypoint(questID)
        if mapID and x and y and C_Map and C_Map.SetUserWaypoint and _G.UiMapPoint and _G.UiMapPoint.CreateFromCoordinates then
            local okWaypoint, waypointPoint = pcall(_G.UiMapPoint.CreateFromCoordinates, mapID, x, y)
            waypointPoint = okWaypoint and waypointPoint or nil
            if waypointPoint then
                pcall(C_Map.SetUserWaypoint, waypointPoint)
                if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                    pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
                end
            end
        end
    end

    return true
end

local function TryGetWidgetFrameByID(container, widgetID)
    if type(container) ~= "table" and type(container) ~= "userdata" then
        return nil
    end

    if container.GetWidgetFrame then
        local ok, frameRef = pcall(container.GetWidgetFrame, container, widgetID)
        if ok and frameRef then
            return frameRef
        end
    end

    local possibleFrameTables = {
        container.widgetFrames,
        container.WidgetFrames,
        container.activeWidgets,
        container.ActiveWidgets,
    }

    for _, frameTable in ipairs(possibleFrameTables) do
        if type(frameTable) == "table" and frameTable[widgetID] then
            return frameTable[widgetID]
        end
    end

    return nil
end

local function AttachStageFourMapClick(frameRef)
    if not frameRef or frameRef.PreydatorStageFourClickHooked then
        return
    end

    frameRef.PreydatorStageFourClickHooked = true
    if frameRef.RegisterForDrag then
        frameRef:RegisterForDrag()
    end
    if frameRef.EnableMouse then
        frameRef:EnableMouse(true)
    end

    if frameRef.HookScript then
        frameRef:HookScript("OnMouseUp", function(_, button)
            if button ~= "LeftButton" then
                return
            end

            if settings and settings.disableDefaultPreyIcon == true then
                return
            end

            if state and state.stage == MAX_STAGE then
                TryOpenPreyQuestOnMap()
            end
        end)
    end
end

local function SetFrameIconVisible(targetFrame, shouldShow)
    if not targetFrame then
        return false
    end

    local didUpdate = false
    local visited = {}
    local iconFieldNames = {
        "Icon",
        "icon",
        "IconTexture",
        "iconTexture",
        "LeftIcon",
        "leftIcon",
        "SpellIcon",
        "spellIcon",
    }

    local function ScanFrame(frameRef, depth)
        if not frameRef or visited[frameRef] or depth > 3 then
            return
        end

        visited[frameRef] = true

        local frameName = frameRef.GetName and frameRef:GetName() or nil
        if IsLikelyIconName(frameName) and SetRegionShown(frameRef, shouldShow) then
            didUpdate = true
        end

        if frameRef.GetRegions then
            local regions = { frameRef:GetRegions() }
            for _, region in ipairs(regions) do
                local regionType = region and region.GetObjectType and region:GetObjectType() or nil
                if regionType == "Texture" then
                    local regionName = region.GetName and region:GetName() or nil
                    if IsLikelyIconName(regionName) and SetRegionShown(region, shouldShow) then
                        didUpdate = true
                    end
                end
            end
        end

        if frameRef.GetChildren then
            local children = { frameRef:GetChildren() }
            for _, child in ipairs(children) do
                ScanFrame(child, depth + 1)
            end
        end
    end

    for _, fieldName in ipairs(iconFieldNames) do
        local region = targetFrame[fieldName]
        if SetRegionShown(region, shouldShow) then
            didUpdate = true
        end
    end

    ScanFrame(targetFrame, 0)

    return didUpdate
end

local function ApplySuppressionToParentChain(frameRef, suppress, maxDepth)
    -- Emergency safety: parent-chain suppression can cascade into major UI roots.
    -- Keep this disabled unless we can guarantee strict frame whitelisting.
    return
end

local function FindGlobalFramesForWidgetID(widgetID, forceRefresh)
    local okWidgetID, numericWidgetID = pcall(function()
        return tonumber(widgetID)
    end)
    widgetID = okWidgetID and numericWidgetID or nil
    if not widgetID then
        return {}
    end

    if not forceRefresh and type(UI.targetedWidgetGlobalFrameCache[widgetID]) == "table" then
        return UI.targetedWidgetGlobalFrameCache[widgetID]
    end

    local matches = {}
    local widgetText = tostring(widgetID)
    local maxMatches = 30
    local seen = {}

    local function pushMatch(keyText, frameRef)
        if #matches >= maxMatches or not frameRef then
            return
        end

        if seen[frameRef] then
            return
        end

        seen[frameRef] = true
        local name = nil
        if frameRef.GetName then
            local okName, resolvedName = pcall(frameRef.GetName, frameRef)
            if okName then
                name = resolvedName
            end
        end

        matches[#matches + 1] = {
            key = tostring(keyText or "?"),
            name = name,
            frame = frameRef,
        }
    end

    local knownNames = {
        "UIWidgetTopCenterContainerFrameWidget" .. widgetText,
        "UIWidgetObjectiveTrackerContainerFrameWidget" .. widgetText,
        "UIWidgetBelowMinimapContainerFrameWidget" .. widgetText,
        "UIWidgetPowerBarContainerFrameWidget" .. widgetText,
    }

    for _, keyText in ipairs(knownNames) do
        local frameRef = _G[keyText]
        if frameRef then
            pushMatch(keyText, frameRef)
        end
    end

    local containerNames = {
        "UIWidgetTopCenterContainerFrame",
        "UIWidgetObjectiveTrackerContainerFrame",
        "UIWidgetBelowMinimapContainerFrame",
        "UIWidgetPowerBarContainerFrame",
    }

    local function scanContainerForWidgetID(root, rootKey)
        if not root or not root.GetChildren then
            return
        end

        local visited = {}
        local function scan(node, depth)
            if not node or visited[node] or depth > 6 or #matches >= maxMatches then
                return
            end

            visited[node] = true
            local nodeName = nil
            if node.GetName then
                local okName, resolvedName = pcall(node.GetName, node)
                if okName then
                    nodeName = resolvedName
                end
            end

            if type(nodeName) == "string" and string.find(nodeName, widgetText, 1, true) ~= nil then
                pushMatch((rootKey or "container") .. ":" .. nodeName, node)
            end

            if node.GetChildren then
                local okChildren, children = pcall(function()
                    return { node:GetChildren() }
                end)
                if okChildren and type(children) == "table" then
                    for _, child in ipairs(children) do
                        scan(child, depth + 1)
                        if #matches >= maxMatches then
                            break
                        end
                    end
                end
            end
        end

        scan(root, 0)
    end

    for _, containerKey in ipairs(containerNames) do
        local container = _G[containerKey]
        scanContainerForWidgetID(container, containerKey)
    end

    UI.targetedWidgetGlobalFrameCache[widgetID] = matches
    return matches
end

ApplyDefaultPreyIconVisibility = function()
    if not settings then
        return
    end

    if not (C_UIWidgetManager and C_UIWidgetManager.GetAllWidgetsBySetID) then
        return
    end

    local preyWidgetType = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.PreyHuntProgress)
        or PREY_WIDGET_TYPE
    local suppressEncounter = settings.disableDefaultPreyIcon == true and ShouldSuppressDefaultPreyEncounter()

    local containerGlobals = {
        "UIWidgetTopCenterContainerFrame",
        "UIWidgetObjectiveTrackerContainerFrame",
        "UIWidgetBelowMinimapContainerFrame",
        "UIWidgetPowerBarContainerFrame",
    }

    for _, setID in ipairs(GetCandidateWidgetSetIDs()) do
        local okWidgets, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, C_UIWidgetManager, setID)
        if not okWidgets or type(widgets) ~= "table" then
            okWidgets, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
        end
        if type(widgets) == "table" then
            for _, widget in ipairs(widgets) do
                local okType, widgetType = pcall(function() return widget and widget.widgetType end)
                local okID, rawWidgetID = pcall(function() return widget and widget.widgetID end)
                local numericWidgetID = okID and tonumber(rawWidgetID) or nil
                if okType and widgetType == preyWidgetType and numericWidgetID then
                    for _, globalName in ipairs(containerGlobals) do
                        local container = _G[globalName]
                        local widgetFrame = TryGetWidgetFrameByID(container, numericWidgetID)
                        AttachStageFourMapClick(widgetFrame)
                        EnsureWidgetSuppressionHook(widgetFrame)
                        ApplyWidgetFrameSuppression(widgetFrame, suppressEncounter)

                        local namedFrame = _G[globalName .. "Widget" .. tostring(numericWidgetID)]
                        AttachStageFourMapClick(namedFrame)
                        EnsureWidgetSuppressionHook(namedFrame)
                        ApplyWidgetFrameSuppression(namedFrame, suppressEncounter)
                    end
                end
            end
        end
    end
end

NormalizeSoundSettings = function()
    if type(settings.soundFileNames) ~= "table" then
        settings.soundFileNames = {}
    end

    local runtime = GetRuntimeModule("SoundsRuntime")

    local mergedNames = {}
    local seen = {}

    local function pushFileName(fileName)
        local normalized = nil
        if runtime and type(runtime.NormalizeSoundFileName) == "function" then
            normalized = runtime:NormalizeSoundFileName(fileName, {
                soundFolderPrefix = SOUND_FOLDER_PREFIX,
            })
        end
        if not normalized or seen[normalized] then
            return
        end
        seen[normalized] = true
        table.insert(mergedNames, normalized)
    end

    for _, defaultName in ipairs(DEFAULT_SOUND_FILENAMES) do
        pushFileName(defaultName)
    end

    for _, configuredName in ipairs(settings.soundFileNames) do
        pushFileName(configuredName)
    end

    for stage = 1, MAX_STAGE do
        local existingPath = settings.stageSounds and settings.stageSounds[stage]
        local extracted = nil
        if runtime and type(runtime.ExtractAddonSoundFileName) == "function" then
            extracted = runtime:ExtractAddonSoundFileName(existingPath, {
                soundFolderPrefix = SOUND_FOLDER_PREFIX,
            })
        end
        pushFileName(extracted)
    end

    local extractedAmbush = nil
    if runtime and type(runtime.ExtractAddonSoundFileName) == "function" then
        extractedAmbush = runtime:ExtractAddonSoundFileName(settings.ambushSoundPath, {
            soundFolderPrefix = SOUND_FOLDER_PREFIX,
        })
    end
    pushFileName(extractedAmbush)
    settings.soundFileNames = mergedNames

    local allowedPathLower = {}
    for _, fileName in ipairs(settings.soundFileNames) do
        local fullPath = nil
        if runtime and type(runtime.BuildAddonSoundPath) == "function" then
            fullPath = runtime:BuildAddonSoundPath(fileName, {
                soundFolderPrefix = SOUND_FOLDER_PREFIX,
            })
        end
        if type(fullPath) == "string" and fullPath ~= "" then
            allowedPathLower[string.lower(fullPath)] = true
        end
    end

    if type(settings.stageSounds) ~= "table" then
        settings.stageSounds = {}
    end

    for stage = 1, MAX_STAGE do
        local configuredPath = settings.stageSounds[stage]
        if type(configuredPath) ~= "string" or configuredPath == "" then
            local legacyPath = settings.stageSounds[tostring(stage)]
            if type(legacyPath) == "string" and legacyPath ~= "" then
                configuredPath = legacyPath
            end
        end

        if type(configuredPath) == "string" and string.find(string.lower(configuredPath), "predator%-idle%.ogg", 1, false) then
            configuredPath = nil
        end

        if configuredPath ~= "__NONE__" then
            if type(configuredPath) ~= "string" or configuredPath == "" then
                configuredPath = (stage == 1 and ALERT_SOUND_PATH)
                    or (stage == 2 and AMBUSH_SOUND_PATH)
                    or (stage == 3 and TORMENT_SOUND_PATH)
                    or (stage == 4 and KILL_SOUND_PATH)
            end

            if type(configuredPath) ~= "string" or not allowedPathLower[string.lower(configuredPath)] then
                configuredPath = (stage == 1 and ALERT_SOUND_PATH)
                    or (stage == 2 and AMBUSH_SOUND_PATH)
                    or (stage == 3 and TORMENT_SOUND_PATH)
                    or (stage == 4 and KILL_SOUND_PATH)
            end
        end

        settings.stageSounds[stage] = configuredPath
    end

    if settings.ambushSoundPath ~= "__NONE__"
        and (type(settings.ambushSoundPath) ~= "string" or not allowedPathLower[string.lower(settings.ambushSoundPath)])
    then
        settings.ambushSoundPath = KILL_SOUND_PATH
    end

    if settings.bloodyCommandSoundPath ~= "__NONE__"
        and (type(settings.bloodyCommandSoundPath) ~= "string" or not allowedPathLower[string.lower(settings.bloodyCommandSoundPath)])
    then
        settings.bloodyCommandSoundPath = KILL_SOUND_PATH
    end

    settings.stageSounds[5] = nil
end

local function ResetAllSettings()
    for key in pairs(settings) do
        settings[key] = nil
    end

    ApplyDefaults(settings, DEFAULTS)
    NormalizeTransientSettings()
    NormalizeLabelSettings()
    NormalizeColorSettings()
    NormalizeDisplaySettings()
    NormalizeProgressSettings()
    NormalizeAmbushSettings()
    NormalizeSoundSettings()

    state.forceShowBar = false
    state.stageSoundPlayed = {}
    state.stageSoundAttempted = {}
    ClearBloodyCommandAlert()

    ApplyBarSettings()
    UpdateBarDisplay()

    if UI.optionsPanel and UI.optionsPanel.PreydatorRefreshControls then
        UI.optionsPanel.PreydatorRefreshControls()
    end
end

ExtractWidgetQuestID = function(info)
    if type(info) ~= "table" then
        return nil
    end

    local possibleFields = {
        "questID",
        "questId",
        "associatedQuestID",
        "associatedQuestId",
    }

    for _, fieldName in ipairs(possibleFields) do
        local value = info[fieldName]
        if type(value) == "number" and value > 0 then
            return value
        end
    end

    return nil
end

local function FindPreyWidgetProgressState(activeQuestID)
    if not (C_UIWidgetManager and C_UIWidgetManager.GetAllWidgetsBySetID and C_UIWidgetManager.GetPreyHuntProgressWidgetVisualizationInfo) then
        return nil
    end

    local preyWidgetType = (Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.PreyHuntProgress)
        or PREY_WIDGET_TYPE
    local shownStateShown = (Enum and Enum.WidgetShownState and Enum.WidgetShownState.Shown) or WIDGET_SHOWN
    local fallbackState, fallbackTooltip, fallbackPct = nil, nil, nil

    for _, setID in ipairs(GetCandidateWidgetSetIDs()) do
        local okWidgets, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, C_UIWidgetManager, setID)
        if not okWidgets or type(widgets) ~= "table" then
            okWidgets, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, setID)
        end
        if type(widgets) == "table" then
            for _, widget in ipairs(widgets) do
                local okType, widgetType = pcall(function() return widget and widget.widgetType end)
                local okID, rawWidgetID = pcall(function() return widget and widget.widgetID end)
                local numericWidgetID = okID and tonumber(rawWidgetID) or nil
                if okType and widgetType == preyWidgetType and numericWidgetID then
                    local okInfo, info = pcall(C_UIWidgetManager.GetPreyHuntProgressWidgetVisualizationInfo, numericWidgetID)
                    if okInfo and info and info.shownState == shownStateShown then
                        local pct = ExtractProgressPercent(info, info.tooltip)
                        if IsValidQuestID(activeQuestID) then
                            local widgetQuestID = ExtractWidgetQuestID(info)
                            if widgetQuestID == activeQuestID then
                                return info.progressState, info.tooltip, pct
                            end

                            if widgetQuestID == nil and fallbackState == nil then
                                fallbackState, fallbackTooltip, fallbackPct = info.progressState, info.tooltip, pct
                            end
                        else
                            return info.progressState, info.tooltip, pct
                        end
                    end
                end
            end
        end
    end

    if IsValidQuestID(activeQuestID) then
        return fallbackState, fallbackTooltip, fallbackPct
    end

    return nil, nil, nil
end

local function ResetStateForNewQuest(questID)
    if state.activeQuestID ~= questID then
        state.activeQuestID = questID
        state.lastNotifiedPreyEndQuestID = nil
        state.progressState = nil
        state.progressPercent = nil
        state.stageSoundPlayed = {}
        state.stageSoundAttempted = {}
        state.stage = 1
        local runtime = GetRuntimeModule("PreyContextRuntime")
        if runtime and type(runtime.GetPreyZoneInfo) == "function" then
            state.preyZoneName, state.preyZoneMapID = runtime:GetPreyZoneInfo(questID, {
                taskQuestApi = C_TaskQuest,
                mapApi = C_Map,
            })
        else
            if questID and C_TaskQuest and C_TaskQuest.GetQuestZoneID and C_Map and C_Map.GetMapInfo then
                local okMapID, rawMapID = pcall(C_TaskQuest.GetQuestZoneID, questID)
                local okNumericMapID, mapID = pcall(function()
                    return tonumber(rawMapID)
                end)
                mapID = (okMapID and okNumericMapID and mapID and mapID > 0) and mapID or nil
                if mapID then
                    local okMapInfo, mapInfo = pcall(C_Map.GetMapInfo, mapID)
                    mapInfo = okMapInfo and mapInfo or nil
                    state.preyZoneName = mapInfo and mapInfo.name or nil
                    state.preyZoneMapID = mapID
                else
                    state.preyZoneName = nil
                    state.preyZoneMapID = nil
                end
            else
                state.preyZoneName = nil
                state.preyZoneMapID = nil
            end
        end
        state.inPreyZone = nil
        RefreshInPreyZoneStatus(questID, true)
        state.preyTooltipText = nil
        state.preyTargetName, state.preyTargetDifficulty = ExtractPreyTargetFromQuestTitle(questID)
        state.ambushAlertUntil = 0
        state.lastAmbushSoundAt = 0
        state.lastAmbushSystemMessage = nil
    end
end

local function UpdatePreyState()
    local now = GetTime and GetTime() or 0
    local questID = GetCurrentActivePreyQuestCached(0)
    local hasActiveQuest = IsValidQuestID(questID)
    local forceKillStage = (state.killStageUntil or 0) > now
    local forceAmbushAlert = (state.ambushAlertUntil or 0) > now

    if not hasActiveQuest and not forceKillStage then
        local endingQuestID = state.activeQuestID or questID
        local completedTransition = tonumber(state.stage) == MAX_STAGE
        if endingQuestID and endingQuestID > 0 then
            if completedTransition ~= true or state.lastNotifiedPreyEndQuestID ~= endingQuestID then
                RunModuleHook("OnPreyQuestEnded", {
                    questID = endingQuestID,
                    completed = completedTransition == true,
                    stage = tonumber(state.stage),
                    difficulty = state.preyTargetDifficulty,
                })
                if completedTransition == true then
                    state.lastNotifiedPreyEndQuestID = endingQuestID
                end
            end
        end
        DebugLogPreyState("clear", questID, false, state.progressState, state.progressPercent, state.inPreyZone)
        ClearPreyStateAndDisplay()
        ApplyDefaultPreyIconVisibility()
        UpdateBarDisplay()
        return
    end

    if hasActiveQuest then
        ResetStateForNewQuest(questID)
        RefreshInPreyZoneStatus(questID, false)

        -- While out of prey zone, skip expensive widget/objective scans.
        if state.inPreyZone == false and not forceKillStage and not forceAmbushAlert then
            state.lastPercentSource = "none"
            state.preyTooltipText = nil
            ApplyDefaultPreyIconVisibility()
            UpdateBarDisplay()
            return
        end
    end

    local newProgressState, tooltipText, newProgressPercent = nil, nil, nil
    if hasActiveQuest then
        newProgressState, tooltipText, newProgressPercent = FindPreyWidgetProgressState(questID)
    end
    local hasWidgetData = newProgressState ~= nil

    if hasWidgetData then
        state.lastWidgetSeenAt = now
    end

    local effectiveQuestID = hasActiveQuest and questID or nil

    local questCompleted = false
    if questID and C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        questCompleted = C_QuestLog.IsQuestFlaggedCompleted(questID) and true or false
    end

    local questStillActive = IsQuestStillActive(questID)
    if questCompleted or (hasActiveQuest and not questStillActive and not hasWidgetData) then
        local endingQuestID = effectiveQuestID or state.activeQuestID or questID
        local completedTransition = questCompleted or (((not hasActiveQuest) or (not questStillActive)) and tonumber(state.stage) == MAX_STAGE)
        if endingQuestID and endingQuestID > 0 then
            if completedTransition ~= true or state.lastNotifiedPreyEndQuestID ~= endingQuestID then
                RunModuleHook("OnPreyQuestEnded", {
                    questID = endingQuestID,
                    completed = completedTransition == true,
                    stage = tonumber(state.stage),
                    difficulty = state.preyTargetDifficulty,
                })
                if completedTransition == true then
                    state.lastNotifiedPreyEndQuestID = endingQuestID
                end
            end
        end
        DebugLogPreyState("clear", questID, hasWidgetData, state.progressState, state.progressPercent, state.inPreyZone)
        ClearPreyStateAndDisplay()
        ApplyDefaultPreyIconVisibility()
        UpdateBarDisplay()
        return
    end

    if hasWidgetData then
        state.inPreyZone = true
    end

    local oldProgressState = state.progressState
    local percentSource = "none"
    if newProgressState ~= nil then
        state.progressState = newProgressState
        state.inPreyZone = true
    end
    if newProgressPercent ~= nil then
        state.progressPercent = newProgressPercent
        percentSource = "widget"
    else
        local objectivePercent = ExtractQuestObjectivePercent(questID)
        if objectivePercent ~= nil and (objectivePercent > 0 or newProgressState == PREY_PROGRESS_FINAL) then
            state.progressPercent = objectivePercent
            percentSource = "objective"
        end
    end

    if newProgressPercent == nil and percentSource == "none" and newProgressState ~= nil then
        if newProgressState == PREY_PROGRESS_FINAL then
            state.progressPercent = 100
            percentSource = "final"
        else
            state.progressPercent = nil
        end
    elseif newProgressPercent == nil and percentSource == "none" and (now - (state.lastWidgetSeenAt or 0)) > 2 then
        state.progressPercent = nil
        state.progressState = nil
    end
    state.lastPercentSource = percentSource
    state.preyTooltipText = tooltipText
    DebugLogPreyState("update", effectiveQuestID, hasWidgetData, state.progressState, state.progressPercent, state.inPreyZone)

    local oldStage = state.stage
    local newStage = GetStageFromState(state.progressState)

    local stageChanged = newStage ~= oldStage
    if stageChanged then
        TryPlayStageSound(newStage)
    end

    if newProgressState ~= PREY_PROGRESS_FINAL or oldProgressState == PREY_PROGRESS_FINAL then
        ApplyDefaultPreyIconVisibility()
        UpdateBarDisplay()
        return
    end

    if state.stageSoundPlayed[MAX_STAGE] or state.stageSoundAttempted[MAX_STAGE] then
        ApplyDefaultPreyIconVisibility()
        UpdateBarDisplay()
        return
    end

    TryPlayStageSound(MAX_STAGE)

    ApplyDefaultPreyIconVisibility()
    UpdateBarDisplay()
end

function Preydator:ShouldUseActivePolling()
    local customizationV2 = Preydator:GetModule("CustomizationStateV2")
    local barModuleEnabled = true
    local soundsModuleEnabled = true
    if customizationV2 and type(customizationV2.IsModuleEnabled) == "function" then
        barModuleEnabled = customizationV2:IsModuleEnabled("bar") == true
        soundsModuleEnabled = customizationV2:IsModuleEnabled("sounds") == true
    end

    local soundsRuntimeEnabled = soundsModuleEnabled and settings and settings.soundsEnabled ~= false
    if not barModuleEnabled and not soundsRuntimeEnabled then
        return false
    end

    local now = GetTime and GetTime() or 0
    local trackedQuestID = state and state.activeQuestID or nil
    local hasTrackedQuest = IsValidQuestID(trackedQuestID) and IsQuestStillActive(trackedQuestID)
    local liveQuestID = GetCurrentActivePreyQuestCached(ACTIVE_PREY_QUEST_CACHE_SECONDS)
    local hasLiveQuest = IsValidQuestID(liveQuestID) and IsQuestStillActive(liveQuestID)
    local needsQuestBootstrap = hasLiveQuest and not hasTrackedQuest
    local inKillCarry = ((state and state.killStageUntil) or 0) > now
    local inAmbushAlert = ((state and state.ambushAlertUntil) or 0) > now
    local inBloodyCommandAlert = ((state and state.bloodyCommandAlertUntil) or 0) > now
    local inQuestListenBurst = ((state and state.questListenUntil) or 0) > now
    local editModeFrame = _G.EditModeManagerFrame
    local inEditPreview = settings
        and settings.showInEditMode == true
        and editModeFrame
        and editModeFrame.IsShown
        and editModeFrame:IsShown()
    local forceShowBar = state and state.forceShowBar == true
    local hasHotQuestContext = hasTrackedQuest and state and state.inPreyZone == true

    return needsQuestBootstrap
        or inKillCarry
        or inAmbushAlert
        or inBloodyCommandAlert
        or inQuestListenBurst
        or inEditPreview
        or forceShowBar
        or hasHotQuestContext
end

function Preydator:SetPollingActive(enabled)
    if not frame then
        return
    end

    local customizationV2 = Preydator:GetModule("CustomizationStateV2")
    if customizationV2 and type(customizationV2.IsModuleEnabled) == "function" then
        local barModuleEnabled = customizationV2:IsModuleEnabled("bar") == true
        local soundsModuleEnabled = customizationV2:IsModuleEnabled("sounds") == true
        local soundsRuntimeEnabled = soundsModuleEnabled and settings and settings.soundsEnabled ~= false
        if not barModuleEnabled and not soundsRuntimeEnabled then
            enabled = false
        end
    end

    local shouldEnable = enabled == true
    if shouldEnable == (state.pollingActive == true) then
        return
    end

    state.pollingActive = shouldEnable

    if shouldEnable then
        state.nextPollingEligibilityCheckAt = 0
        frame:SetScript("OnUpdate", function(_, elapsed)
            state.elapsedSinceUpdate = (state.elapsedSinceUpdate or 0) + (elapsed or 0)
            local now = GetTime and GetTime() or 0
            local inKillCarry = ((state and state.killStageUntil) or 0) > now
            local inAmbushAlert = ((state and state.ambushAlertUntil) or 0) > now
            local inBloodyCommandAlert = ((state and state.bloodyCommandAlertUntil) or 0) > now
            local inQuestListenBurst = ((state and state.questListenUntil) or 0) > now
            local editModeFrame = _G.EditModeManagerFrame
            local inEditPreview = settings
                and settings.showInEditMode == true
                and editModeFrame
                and editModeFrame.IsShown
                and editModeFrame:IsShown()
            local recentlySawWidget = (now - ((state and state.lastWidgetSeenAt) or 0)) <= 2.0
            local progressState = tonumber(state and state.progressState)
            local isIdleInZone = IsValidQuestID(state and state.activeQuestID)
                and state.inPreyZone == true
                and (progressState == nil or progressState == 0)
                and not recentlySawWidget
                and not inKillCarry
                and not inAmbushAlert
                and not inBloodyCommandAlert
                and not inQuestListenBurst
                and not (state and state.forceShowBar == true)
                and not inEditPreview
            local interval = isIdleInZone and 2.0 or UPDATE_INTERVAL_SECONDS
            if state.elapsedSinceUpdate < interval then
                return
            end

            state.elapsedSinceUpdate = 0
            UpdatePreyState()

            if now >= (state.nextPollingEligibilityCheckAt or 0) then
                state.nextPollingEligibilityCheckAt = now + 2.0
                if not Preydator:ShouldUseActivePolling() then
                    Preydator:SetPollingActive(false)
                end
            end
        end)
    else
        state.elapsedSinceUpdate = 0
        state.nextPollingEligibilityCheckAt = 0
        frame:SetScript("OnUpdate", nil)
    end
end

function Preydator:ApplyRuntimeSettings(nextSettings, emitProfileHook, refreshUi)
    if type(nextSettings) == "table" then
        settings = nextSettings
    end

    if type(settings) ~= "table" then
        return
    end

    ApplyDefaults(settings, DEFAULTS)
    EnsureDebugDB()
    debugDB.enabled = settings.debugSounds and true or false

    NormalizeTransientSettings()
    NormalizeSoundSettings()
    NormalizeLabelSettings()
    NormalizeColorSettings()
    do
        local runtime = GetRuntimeModule("SettingsRuntime")
        if runtime and type(runtime.RestoreBarPointFromBackup) == "function" then
            runtime:RestoreBarPointFromBackup(settings)
        end
    end
    NormalizeDisplaySettings()
    NormalizeProgressSettings()
    NormalizeAmbushSettings()
    ApplyDefaultPreyIconVisibility()

    state.forceShowBar = false

    if refreshUi then
        ApplyBarSettings()
        UpdateBarDisplay()
        Preydator:SetPollingActive(Preydator:ShouldUseActivePolling())
    end

    if emitProfileHook then
        RunModuleHook("OnProfileChanged", settings)
    end
end

local function OnAddonLoaded()
    _G.PreydatorDB = _G.PreydatorDB or {}
    local profileSystem = Preydator and Preydator.ProfileSystem
    if profileSystem and type(profileSystem.EnsureProfiles) == "function" then
        profileSystem:EnsureProfiles()
        if type(profileSystem.GetActiveProfileTable) == "function" then
            settings = profileSystem:GetActiveProfileTable()
        end
    end
    if type(settings) ~= "table" then
        settings = _G.PreydatorDB
    end

    Preydator:ApplyRuntimeSettings(settings, false, false)
    AddDebugLog("OnAddonLoaded", "debug=" .. tostring(debugDB.enabled) .. " | stage" .. tostring(MAX_STAGE) .. "=" .. tostring(settings.stageSounds[MAX_STAGE]), true)

    state.pollingActive = false

    RunModuleHook("OnAddonLoaded")
end

local function AddCheckbox(parent, label, x, y, getter, setter)
    local checkbox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    checkbox.Text:SetText(label)
    checkbox:SetChecked(getter())
    checkbox:SetScript("OnClick", function(self)
        setter(self:GetChecked())
    end)
    return checkbox
end

local function AddSlider(parent, label, x, y, minValue, maxValue, step, getter, setter)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    slider:SetWidth(240)
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(getter())
    slider.Text:SetText(label)
    slider.Low:SetText(tostring(minValue))
    slider.High:SetText(tostring(maxValue))
    slider:SetScript("OnValueChanged", function(self, value)
        setter(value)
    end)
    return slider
end

local function AddDropdown(parent, label, x, y, width, options, getter, setter)
    local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    title:SetText(label)

    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -16, -4)

    local function GetOptions()
        if type(options) == "function" then
            return options() or {}
        end
        return options or {}
    end

    local function RefreshText()
        local key = getter()
        local entry = GetOptions()[key]
        UIDropDownMenu_SetText(dropdown, entry and entry.text or "Select")
    end

    UIDropDownMenu_SetWidth(dropdown, width)
    UIDropDownMenu_Initialize(dropdown, function(_, _, _)
        local optionList = {}
        for key, entry in pairs(GetOptions()) do
            table.insert(optionList, { key = key, entry = entry })
        end

        table.sort(optionList, function(a, b)
            local left = tostring(a.entry and a.entry.text or "")
            local right = tostring(b.entry and b.entry.text or "")
            return left < right
        end)

        for _, item in ipairs(optionList) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = item.entry.text
            info.func = function()
                setter(item.key)
                RefreshText()
            end
            info.checked = getter() == item.key
            UIDropDownMenu_AddButton(info)
        end
    end)

    dropdown.PreydatorRefreshText = RefreshText
    RefreshText()
    return dropdown
end

local function AddColorSwatch(parent, x, y, getter, setter, allowAlpha)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(28, 22)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    button:SetText("")

    local swatch = button:CreateTexture(nil, "ARTWORK")
    swatch:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
    swatch:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)

    local function Refresh()
        local c = getter()
        local a = (allowAlpha and c[4]) or 1
        swatch:SetColorTexture(c[1], c[2], c[3], a)
    end

    local function NormalizeColorInput(value, fallback)
        local fb = fallback or { 1, 1, 1, 1 }
        local r = value and (value[1] or value.r) or fb[1]
        local g = value and (value[2] or value.g) or fb[2]
        local b = value and (value[3] or value.b) or fb[3]

        local a = fb[4]
        if allowAlpha then
            if value then
                if value[4] ~= nil then
                    a = value[4]
                elseif value.a ~= nil then
                    a = value.a
                elseif value.opacity ~= nil then
                    a = 1 - value.opacity
                end
            end
        else
            a = 1
        end

        r = Clamp(tonumber(r) or fb[1] or 1, 0, 1)
        g = Clamp(tonumber(g) or fb[2] or 1, 0, 1)
        b = Clamp(tonumber(b) or fb[3] or 1, 0, 1)
        a = Clamp(tonumber(a) or fb[4] or 1, 0, 1)

        return { r, g, b, a }
    end

    local function GetPickerColor(defaultA)
        local r, g, b
        if ColorPickerFrame.GetColorRGB then
            r, g, b = ColorPickerFrame:GetColorRGB()
        elseif ColorPickerFrame.Content and ColorPickerFrame.Content.ColorPicker and ColorPickerFrame.Content.ColorPicker.GetColorRGB then
            r, g, b = ColorPickerFrame.Content.ColorPicker:GetColorRGB()
        else
            r, g, b = 1, 1, 1
        end

        local a = defaultA
        if allowAlpha then
            if ColorPickerFrame.GetColorAlpha then
                a = ColorPickerFrame:GetColorAlpha()
            elseif OpacitySliderFrame and OpacitySliderFrame.GetValue then
                a = 1 - OpacitySliderFrame:GetValue()
            end
        end

        return r, g, b, a
    end

    button:SetScript("OnClick", function()
        if not ColorPickerFrame then
            return
        end

        UI.colorPickerSessionCounter = UI.colorPickerSessionCounter + 1
        local sessionID = UI.colorPickerSessionCounter
        ColorPickerFrame.preydatorSessionID = sessionID

        local start = getter()
        local startColor = {
            start[1] or 1,
            start[2] or 1,
            start[3] or 1,
            start[4] or 1,
        }

        local function ApplyColor()
            if ColorPickerFrame.preydatorSessionID ~= sessionID then
                return
            end

            local r, g, b, a = GetPickerColor(startColor[4])

            setter(NormalizeColorInput({ r, g, b, a }, startColor))
            Refresh()
        end

        local function CancelColor(previousValues)
            if ColorPickerFrame.preydatorSessionID ~= sessionID then
                return
            end

            local pr, pg, pb, pa = nil, nil, nil, nil
            if type(previousValues) == "table" then
                pr = previousValues.r or previousValues[1]
                pg = previousValues.g or previousValues[2]
                pb = previousValues.b or previousValues[3]
                pa = previousValues.a or previousValues[4]
            elseif ColorPickerFrame.GetPreviousValues then
                pr, pg, pb, pa = ColorPickerFrame:GetPreviousValues()
            end

            if pr == nil or pg == nil or pb == nil then
                pr, pg, pb, pa = startColor[1], startColor[2], startColor[3], startColor[4]
            end

            setter(NormalizeColorInput({ pr, pg, pb, pa }, startColor))
            Refresh()
        end

        if ColorPickerFrame.SetupColorPickerAndShow then
            local info = {
                r = startColor[1],
                g = startColor[2],
                b = startColor[3],
                opacity = allowAlpha and startColor[4] or 0,
                hasOpacity = allowAlpha and true or false,
                func = ApplyColor,
                swatchFunc = ApplyColor,
                opacityFunc = ApplyColor,
                cancelFunc = CancelColor,
            }
            ColorPickerFrame:SetupColorPickerAndShow(info)
            return
        end

        ColorPickerFrame.hasOpacity = allowAlpha and true or false
        ColorPickerFrame.opacity = allowAlpha and (1 - startColor[4]) or 0
        ColorPickerFrame.previousValues = { startColor[1], startColor[2], startColor[3], startColor[4] }
        if ColorPickerFrame.SetColorRGB then
            ColorPickerFrame:SetColorRGB(startColor[1], startColor[2], startColor[3])
        elseif ColorPickerFrame.Content and ColorPickerFrame.Content.ColorPicker and ColorPickerFrame.Content.ColorPicker.SetColorRGB then
            ColorPickerFrame.Content.ColorPicker:SetColorRGB(startColor[1], startColor[2], startColor[3])
        end
        ColorPickerFrame.func = ApplyColor
        ColorPickerFrame.swatchFunc = ApplyColor
        ColorPickerFrame.opacityFunc = ApplyColor
        ColorPickerFrame.cancelFunc = CancelColor

        ColorPickerFrame:Hide()
        ColorPickerFrame:Show()
    end)

    button.PreydatorRefresh = Refresh
    Refresh()
    return button
end

EnsureOptionsPanel = function()
    local settingsModule = Preydator.GetModule and Preydator:GetModule("Settings")
    if settingsModule and settingsModule.EnsureOptionsPanel then
        local panelRef, categoryID = settingsModule:EnsureOptionsPanel()
        if panelRef then
            UI.optionsPanel = panelRef
        end
        if categoryID ~= nil then
            UI.optionsCategoryID = categoryID
        end
        return
    end

    if UI.optionsPanel then
        return
    end

    local panel = CreateFrame("Frame", "PreydatorOptionsPanel")
    panel.name = "Preydator"
    local panelRoot = panel

    local scrollFrame = CreateFrame("ScrollFrame", "PreydatorOptionsScrollFrame", panelRoot, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", panelRoot, "TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", panelRoot, "BOTTOMRIGHT", -30, 8)

    local content = CreateFrame("Frame", "PreydatorOptionsContent", scrollFrame)
    content:SetSize(760, 900)
    scrollFrame:SetScrollChild(content)

    UI.optionsScrollFrame = scrollFrame
    UI.optionsContentFrame = content
    panel = content

    NormalizeLabelSettings()

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Preydator")

    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Bar movement, scale, font, texture, and sound settings.")
    subtitle:SetWidth(700)
    subtitle:SetJustifyH("LEFT")
    subtitle:SetWordWrap(true)

    local lockCheckbox = AddCheckbox(panel, "Lock Bar", 20, -55, function() return settings.locked end, function(value)
        settings.locked = value
        ApplyBarSettings()
        UpdateBarDisplay()
    end)

    local onlyShowInPreyZoneCheckbox = AddCheckbox(panel, "Only show in prey zone", 20, -83, function() return settings.onlyShowInPreyZone end, function(value)
        settings.onlyShowInPreyZone = value
        UpdateBarDisplay()
    end)

    local showInEditModeCheckbox = AddCheckbox(panel, "Show in Edit Mode preview", 20, -195, function() return settings.showInEditMode ~= false end, function(value)
        settings.showInEditMode = value
        NormalizeDisplaySettings()
        UpdateBarDisplay()
    end)

    local disableDefaultPreyIconCheckbox = AddCheckbox(panel, "Disable Default Prey Icon", 20, -139, function() return settings.disableDefaultPreyIcon == true end, function(value)
        settings.disableDefaultPreyIcon = value
        ApplyDefaultPreyIconVisibility()
    end)

    local scaleSlider = AddSlider(panel, "Scale", 20, -435, 0.5, 2, 0.05, function() return settings.scale end, function(value)
        settings.scale = Clamp(value, 0.5, 2)
        ApplyBarSettings()
    end)

    local widthSlider = AddSlider(panel, "Width", 20, -470, 160, 500, 1, function() return settings.width end, function(value)
        settings.width = Clamp(math.floor(value + 0.5), 160, 500)
        ApplyBarSettings()
        UpdateBarDisplay()
    end)

    local heightSlider = AddSlider(panel, "Height", 20, -505, 10, 40, 1, function() return settings.height end, function(value)
        settings.height = Clamp(math.floor(value + 0.5), 10, 40)
        ApplyBarSettings()
        UpdateBarDisplay()
    end)

    local fontSizeSlider = AddSlider(panel, "Font Size", 20, -540, 8, 24, 1, function() return settings.fontSize end, function(value)
        settings.fontSize = Clamp(math.floor(value + 0.5), 8, 24)
        ApplyBarSettings()
    end)

    local stageNamesTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    stageNamesTitle:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, -407)
    stageNamesTitle:SetText("Stage Names")

    local stageNameEdits = {}
    for stageIndex = 1, (MAX_STAGE - 1) do
        local rowY = -442 - ((stageIndex - 1) * 35)
        local label = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        label:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, rowY)
        label:SetText(tostring(stageIndex) .. ":")

        local edit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
        edit:SetSize(180, 20)
        edit:SetAutoFocus(false)
        edit:SetTextInsets(6, 6, 0, 0)
        edit:SetPoint("TOPLEFT", panel, "TOPLEFT", 350, -441 - ((stageIndex - 1) * 35))
        edit:SetText(GetStageLabel(stageIndex))
        edit:SetScript("OnEnterPressed", function(self)
            settings.stageLabels[stageIndex] = self:GetText()
            NormalizeLabelSettings()
            self:SetText(settings.stageLabels[stageIndex])
            self:ClearFocus()
            UpdateBarDisplay()
        end)
        edit:SetScript("OnEditFocusLost", function(self)
            settings.stageLabels[stageIndex] = self:GetText()
            NormalizeLabelSettings()
            self:SetText(settings.stageLabels[stageIndex])
            UpdateBarDisplay()
        end)
        stageNameEdits[stageIndex] = edit
    end

    local outZoneRowY = -547
    local outZoneLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    outZoneLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, outZoneRowY)
    outZoneLabel:SetText("Zone:")

    local outZoneEdit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    outZoneEdit:SetSize(156, 20)
    outZoneEdit:SetAutoFocus(false)
    outZoneEdit:SetTextInsets(6, 6, 0, 0)
    outZoneEdit:SetPoint("TOPLEFT", panel, "TOPLEFT", 365, -546)
    outZoneEdit:SetText(settings.outOfZoneLabel or DEFAULT_OUT_OF_ZONE_LABEL)
    outZoneEdit:SetScript("OnEnterPressed", function(self)
        settings.outOfZoneLabel = self:GetText()
        NormalizeLabelSettings()
        self:SetText(settings.outOfZoneLabel)
        self:ClearFocus()
        UpdateBarDisplay()
    end)
    outZoneEdit:SetScript("OnEditFocusLost", function(self)
        settings.outOfZoneLabel = self:GetText()
        NormalizeLabelSettings()
        self:SetText(settings.outOfZoneLabel)
        UpdateBarDisplay()
    end)

    local ambushLabelText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    ambushLabelText:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, -575)
    ambushLabelText:SetText("Ambush:")

    local ambushLabelEdit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    ambushLabelEdit:SetSize(156, 20)
    ambushLabelEdit:SetAutoFocus(false)
    ambushLabelEdit:SetTextInsets(6, 6, 0, 0)
    ambushLabelEdit:SetPoint("TOPLEFT", panel, "TOPLEFT", 380, -574)
    ambushLabelEdit:SetText(settings.ambushCustomText or "")
    ambushLabelEdit:SetScript("OnEnterPressed", function(self)
        settings.ambushCustomText = self:GetText()
        NormalizeLabelSettings()
        self:SetText(settings.ambushCustomText)
        self:ClearFocus()
        UpdateBarDisplay()
    end)
    ambushLabelEdit:SetScript("OnEditFocusLost", function(self)
        settings.ambushCustomText = self:GetText()
        NormalizeLabelSettings()
        self:SetText(settings.ambushCustomText)
        UpdateBarDisplay()
    end)

    local restoreNamesButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    restoreNamesButton:SetSize(180, 24)
    restoreNamesButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, -764)
    restoreNamesButton:SetText("Restore Default Names")
    restoreNamesButton:SetScript("OnClick", function()
        for stageIndex = 1, (MAX_STAGE - 1) do
            settings.stageLabels[stageIndex] = DEFAULT_STAGE_LABELS[stageIndex]
            stageNameEdits[stageIndex]:SetText(DEFAULT_STAGE_LABELS[stageIndex])
        end
        settings.outOfZoneLabel = DEFAULT_OUT_OF_ZONE_LABEL
        settings.ambushCustomText = ""
        outZoneEdit:SetText(DEFAULT_OUT_OF_ZONE_LABEL)
        ambushLabelEdit:SetText("")
        UpdateBarDisplay()
    end)

    local restoreSoundsButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    restoreSoundsButton:SetSize(180, 24)
    restoreSoundsButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, -793)
    restoreSoundsButton:SetText("Restore Default Sounds")
    restoreSoundsButton:SetScript("OnClick", function()
        settings.soundsEnabled = DEFAULTS.soundsEnabled
        settings.soundChannel = DEFAULTS.soundChannel
        settings.soundEnhance = DEFAULTS.soundEnhance
        settings.ambushSoundEnabled = DEFAULTS.ambushSoundEnabled
        settings.ambushVisualEnabled = DEFAULTS.ambushVisualEnabled
        settings.ambushSoundPath = DEFAULTS.ambushSoundPath
        settings.soundFileNames = {}
        for _, fileName in ipairs(DEFAULT_SOUND_FILENAMES) do
            table.insert(settings.soundFileNames, fileName)
        end
        for stageIndex = 1, MAX_STAGE do
            settings.stageSounds[stageIndex] = DEFAULTS.stageSounds[stageIndex]
        end
        NormalizeSoundSettings()
        NormalizeAmbushSettings()
        if panel.PreydatorRefreshControls then
            panel.PreydatorRefreshControls()
        end
    end)

    local resetAllButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetAllButton:SetSize(180, 24)
    resetAllButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, -821)
    resetAllButton:SetText("Reset All Defaults")
    resetAllButton:SetScript("OnClick", function()
        ResetAllSettings()
        if panel.PreydatorRefreshControls then
            panel.PreydatorRefreshControls()
        end
    end)

    local customSoundTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    customSoundTitle:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -659)
    customSoundTitle:SetText("Custom Sound Files: No Spaces")

    local customSoundPathLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    customSoundPathLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -687)
    customSoundPathLabel:SetText("Interface\\AddOns\\Preydator\\sounds\\")

    local customSoundEdit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    customSoundEdit:SetSize(210, 20)
    customSoundEdit:SetAutoFocus(false)
    customSoundEdit:SetTextInsets(6, 6, 0, 0)
    customSoundEdit:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -715)
    customSoundEdit:SetText("")

    local addCustomSoundButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    addCustomSoundButton:SetSize(100, 22)
    addCustomSoundButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -743)
    addCustomSoundButton:SetText("Add File")
    addCustomSoundButton:SetScript("OnClick", function()
        local ok, message = Preydator.API.AddSoundFileName(customSoundEdit:GetText())
        if not ok then
            print("Preydator: " .. tostring(message))
            return
        end

        customSoundEdit:SetText("")
        if panel.PreydatorRefreshControls then
            panel.PreydatorRefreshControls()
        end
        print("Preydator: Added sound file '" .. tostring(message) .. "'.")
    end)

    local removeCustomSoundButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    removeCustomSoundButton:SetSize(110, 22)
    removeCustomSoundButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 130, -743)
    removeCustomSoundButton:SetText("Remove File")
    removeCustomSoundButton:SetScript("OnClick", function()
        local ok, message = Preydator.API.RemoveSoundFileName(customSoundEdit:GetText())
        if not ok then
            print("Preydator: " .. tostring(message))
            return
        end

        customSoundEdit:SetText("")
        if panel.PreydatorRefreshControls then
            panel.PreydatorRefreshControls()
        end
        print("Preydator: Removed sound file '" .. tostring(message) .. "'.")
    end)

    panelRoot:SetScript("OnShow", function()
        NormalizeLabelSettings()
        if panelRoot.PreydatorRefreshControls then
            panelRoot.PreydatorRefreshControls()
        end
    end)

    local textureOptions = {
        default = { text = "Default" },
        flat = { text = "Flat" },
        raid = { text = "Raid HP Fill" },
        classic = { text = "Classic Skill Bar" },
    }

    local fontOptions = {
        frizqt = { text = "Friz Quadrata" },
        arialn = { text = "Arial Narrow" },
        skurri = { text = "Skurri" },
        morpheus = { text = "Morpheus" },
    }

    local channelOptions = {
        Master = { text = "Master" },
        SFX = { text = "SFX" },
        Dialog = { text = "Dialog" },
        Ambience = { text = "Ambience" },
    }

    local percentDisplayOptions = {
        [PERCENT_DISPLAY_INSIDE] = { text = "In Bar" },
        [PERCENT_DISPLAY_UNDER_TICKS] = { text = "Under Ticks" },
        [PERCENT_DISPLAY_BELOW_BAR] = { text = "Below Bar" },
        [PERCENT_DISPLAY_OFF] = { text = "Off" },
    }

    local layerModeOptions = {
        [LAYER_MODE_ABOVE] = { text = "Above Fill" },
        [LAYER_MODE_BELOW] = { text = "Below Fill" },
    }

    local progressSegmentOptions = {
        [PROGRESS_SEGMENTS_QUARTERS] = { text = "Quarters (25/50/75/100)" },
        [PROGRESS_SEGMENTS_THIRDS] = { text = "Thirds (33/66/100)" },
    }

    local textureDropdown = AddDropdown(panel, "Texture", 20, -271, 170, textureOptions, function()
        return settings.textureKey
    end, function(key)
        settings.textureKey = key
        ApplyBarSettings()
    end)
    local fillColorSwatch = AddColorSwatch(panel, 230, -291, function()
        return settings.fillColor
    end, function(color)
        settings.fillColor = { color[1], color[2], color[3], color[4] }
        ApplyBarSettings()
    end, true)

    local titleFontDropdown = AddDropdown(panel, "Title Font", 20, -323, 170, fontOptions, function()
        return settings.titleFontKey
    end, function(key)
        settings.titleFontKey = key
        ApplyBarSettings()
    end)
    local titleColorSwatch = AddColorSwatch(panel, 230, -343, function()
        return settings.titleColor
    end, function(color)
        settings.titleColor = { color[1], color[2], color[3], color[4] }
        ApplyBarSettings()
        UpdateBarDisplay()
    end, true)

    local percentFontDropdown = AddDropdown(panel, "Percent Font", 20, -375, 170, fontOptions, function()
        return settings.percentFontKey
    end, function(key)
        settings.percentFontKey = key
        ApplyBarSettings()
    end)
    local percentColorSwatch = AddColorSwatch(panel, 230, -395, function()
        return settings.percentColor
    end, function(color)
        settings.percentColor = { color[1], color[2], color[3], color[4] }
        ApplyBarSettings()
        UpdateBarDisplay()
    end, true)

    local soundsCheckbox = AddCheckbox(panel, "Enable sounds", 20, -111, function() return settings.soundsEnabled end, function(value)
        settings.soundsEnabled = value
    end)

    local ambushSoundCheckbox = AddCheckbox(panel, "Ambush sound alert", 320, -55, function() return settings.ambushSoundEnabled ~= false end, function(value)
        settings.ambushSoundEnabled = value
    end)

    local ambushVisualCheckbox = AddCheckbox(panel, "Ambush visual alert", 320, -83, function() return settings.ambushVisualEnabled ~= false end, function(value)
        settings.ambushVisualEnabled = value
        if not value then
            state.ambushAlertUntil = 0
            UpdateBarDisplay()
        end
    end)

    local stage1SoundDropdown = AddDropdown(panel, "Stage 1 Sound", 320, -191, 170, function()
        return Preydator.API.BuildSoundDropdownOptions()
    end, function()
        return settings.stageSounds[1]
    end, function(key)
        settings.stageSounds[1] = key
        NormalizeSoundSettings()
    end)

    local stage2SoundDropdown = AddDropdown(panel, "Stage 2 Sound", 320, -243, 170, function()
        return Preydator.API.BuildSoundDropdownOptions()
    end, function()
        return settings.stageSounds[2]
    end, function(key)
        settings.stageSounds[2] = key
        NormalizeSoundSettings()
    end)

    local stage3SoundDropdown = AddDropdown(panel, "Stage 3 Sound", 320, -295, 170, function()
        return Preydator.API.BuildSoundDropdownOptions()
    end, function()
        return settings.stageSounds[3]
    end, function(key)
        settings.stageSounds[3] = key
        NormalizeSoundSettings()
    end)

    local ambushSoundDropdown = AddDropdown(panel, "Ambush Sound", 320, -347, 170, function()
        return Preydator.API.BuildSoundDropdownOptions()
    end, function()
        return settings.ambushSoundPath
    end, function(key)
        settings.ambushSoundPath = key
        NormalizeAmbushSettings()
    end)

    local testAmbushAlertButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    testAmbushAlertButton:SetSize(170, 24)
    testAmbushAlertButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, -715)
    testAmbushAlertButton:SetText("Test Ambush")
    testAmbushAlertButton:SetScript("OnClick", function()
        TriggerAmbushAlert("Manual test", "options")
    end)

    local soundChannelDropdown = AddDropdown(panel, "Sound Channel", 320, -139, 170, channelOptions, function()
        return settings.soundChannel
    end, function(key)
        settings.soundChannel = key
    end)

    local enhanceSlider = AddSlider(panel, "Enhance Sounds", 20, -575, 0, 100, 5, function()
        return settings.soundEnhance or 0
    end, function(value)
        settings.soundEnhance = Clamp(math.floor(value + 0.5), 0, 100)
    end)

    local showTicksCheckbox = AddCheckbox(panel, "Show tick marks", 320, -111, function() return settings.showTicks end, function(value)
        settings.showTicks = value
        ApplyBarSettings()
        UpdateBarDisplay()
    end)

    local tickLayerDropdown = AddDropdown(panel, "Tick Mark Layer", 320, -399, 170, layerModeOptions, function()
        return settings.tickLayerMode
    end, function(key)
        settings.tickLayerMode = key
        NormalizeDisplaySettings()
        ApplyBarSettings()
        UpdateBarDisplay()
    end)

    local percentDisplayDropdown = AddDropdown(panel, "Percent Display", 20, -219, 170, percentDisplayOptions, function()
        return settings.percentDisplay
    end, function(key)
        settings.percentDisplay = key
        NormalizeDisplaySettings()
        ApplyBarSettings()
        UpdateBarDisplay()
    end)

    local progressSegmentsDropdown = AddDropdown(panel, "Progress Segments", 20, -167, 170, progressSegmentOptions, function()
        return settings.progressSegments
    end, function(key)
        settings.progressSegments = key
        NormalizeProgressSettings()
        ApplyBarSettings()
        UpdateBarDisplay()
    end)

    local function RefreshOptionsControls()
        if lockCheckbox then lockCheckbox:SetChecked(settings.locked) end
        if onlyShowInPreyZoneCheckbox then onlyShowInPreyZoneCheckbox:SetChecked(settings.onlyShowInPreyZone) end
        if showInEditModeCheckbox then showInEditModeCheckbox:SetChecked(settings.showInEditMode ~= false) end
        if disableDefaultPreyIconCheckbox then disableDefaultPreyIconCheckbox:SetChecked(settings.disableDefaultPreyIcon == true) end
        if soundsCheckbox then soundsCheckbox:SetChecked(settings.soundsEnabled) end
        if ambushSoundCheckbox then ambushSoundCheckbox:SetChecked(settings.ambushSoundEnabled ~= false) end
        if ambushVisualCheckbox then ambushVisualCheckbox:SetChecked(settings.ambushVisualEnabled ~= false) end
        if showTicksCheckbox then showTicksCheckbox:SetChecked(settings.showTicks) end

        if scaleSlider then scaleSlider:SetValue(settings.scale) end
        if widthSlider then widthSlider:SetValue(settings.width) end
        if heightSlider then heightSlider:SetValue(settings.height) end
        if fontSizeSlider then fontSizeSlider:SetValue(settings.fontSize) end
        if enhanceSlider then enhanceSlider:SetValue(settings.soundEnhance or 0) end

        if textureDropdown and textureDropdown.PreydatorRefreshText then textureDropdown.PreydatorRefreshText() end
        if titleFontDropdown and titleFontDropdown.PreydatorRefreshText then titleFontDropdown.PreydatorRefreshText() end
        if percentFontDropdown and percentFontDropdown.PreydatorRefreshText then percentFontDropdown.PreydatorRefreshText() end
        if soundChannelDropdown and soundChannelDropdown.PreydatorRefreshText then soundChannelDropdown.PreydatorRefreshText() end
        if percentDisplayDropdown and percentDisplayDropdown.PreydatorRefreshText then percentDisplayDropdown.PreydatorRefreshText() end
        if tickLayerDropdown and tickLayerDropdown.PreydatorRefreshText then tickLayerDropdown.PreydatorRefreshText() end
        if progressSegmentsDropdown and progressSegmentsDropdown.PreydatorRefreshText then progressSegmentsDropdown.PreydatorRefreshText() end
        if ambushSoundDropdown and ambushSoundDropdown.PreydatorRefreshText then ambushSoundDropdown.PreydatorRefreshText() end
        if stage1SoundDropdown and stage1SoundDropdown.PreydatorRefreshText then stage1SoundDropdown.PreydatorRefreshText() end
        if stage2SoundDropdown and stage2SoundDropdown.PreydatorRefreshText then stage2SoundDropdown.PreydatorRefreshText() end
        if stage3SoundDropdown and stage3SoundDropdown.PreydatorRefreshText then stage3SoundDropdown.PreydatorRefreshText() end

        if fillColorSwatch and fillColorSwatch.PreydatorRefresh then fillColorSwatch.PreydatorRefresh() end
        if titleColorSwatch and titleColorSwatch.PreydatorRefresh then titleColorSwatch.PreydatorRefresh() end
        if percentColorSwatch and percentColorSwatch.PreydatorRefresh then percentColorSwatch.PreydatorRefresh() end

        for stageIndex = 1, (MAX_STAGE - 1) do
            stageNameEdits[stageIndex]:SetText(settings.stageLabels[stageIndex])
        end
        outZoneEdit:SetText(settings.outOfZoneLabel)
        ambushLabelEdit:SetText(settings.ambushCustomText)
    end

    panelRoot.PreydatorRefreshControls = RefreshOptionsControls

    local function AddSoundTestButton(text, x, y, stageIndex)
        local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        button:SetSize(140, 24)
        button:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
        button:SetText(text)
        button:SetScript("OnClick", function()
            state.stageSoundPlayed[stageIndex] = nil
            state.stageSoundAttempted[stageIndex] = nil
            local path = Preydator.API.ResolveStageSoundPath(stageIndex)
            if not path then
                print("Preydator: No stage " .. stageIndex .. " sound configured.")
                return
            end

            if not TryPlayStageSound(stageIndex, true) then
                print("Preydator: Stage " .. stageIndex .. " sound file failed to play. Ensure this file exists as .ogg: " .. tostring(path))
            end
        end)
    end

    AddSoundTestButton("Test Stage 1", 320, -631, 1)
    AddSoundTestButton("Test Stage 2", 320, -659, 2)
    AddSoundTestButton("Test Stage 3", 320, -687, 3)

    local note = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -603)
    note:SetWidth(260)
    note:SetJustifyH("LEFT")
    note:SetWordWrap(true)
    note:SetText("Enhance Sounds layers extra plays for perceived loudness. WoW does not expose true per-addon file volume.")

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panelRoot, "Preydator", "Preydator")
        Settings.RegisterAddOnCategory(category)
        if type(category) == "table" then
            UI.optionsCategoryID = category.ID or (category.GetID and category:GetID())
            panelRoot.categoryID = UI.optionsCategoryID
        end
    elseif _G.InterfaceOptions_AddCategory then
        _G.InterfaceOptions_AddCategory(panelRoot)
    end

    UI.optionsPanel = panelRoot
end

Preydator.Constants = {
    MAX_STAGE = MAX_STAGE,
    DEFAULT_OUT_OF_ZONE_LABEL = DEFAULT_OUT_OF_ZONE_LABEL,
    DEFAULT_AMBUSH_LABEL = DEFAULT_AMBUSH_LABEL,
    DEFAULT_STAGE_LABELS = DEFAULT_STAGE_LABELS,
    DEFAULT_SOUND_FILENAMES = DEFAULT_SOUND_FILENAMES,
    PROTECTED_SOUND_FILENAMES = PROTECTED_SOUND_FILENAMES,
    PROGRESS_SEGMENTS_QUARTERS = PROGRESS_SEGMENTS_QUARTERS,
    PROGRESS_SEGMENTS_THIRDS = PROGRESS_SEGMENTS_THIRDS,
    PERCENT_DISPLAY_INSIDE = PERCENT_DISPLAY_INSIDE,
    PERCENT_DISPLAY_INSIDE_BELOW = PERCENT_DISPLAY_INSIDE_BELOW,
    PERCENT_DISPLAY_BELOW_BAR = PERCENT_DISPLAY_BELOW_BAR,
    PERCENT_DISPLAY_ABOVE_BAR = PERCENT_DISPLAY_ABOVE_BAR,
    PERCENT_DISPLAY_ABOVE_TICKS = PERCENT_DISPLAY_ABOVE_TICKS,
    PERCENT_DISPLAY_UNDER_TICKS = PERCENT_DISPLAY_UNDER_TICKS,
    PERCENT_DISPLAY_OFF = PERCENT_DISPLAY_OFF,
    LAYER_MODE_ABOVE = LAYER_MODE_ABOVE,
    LAYER_MODE_BELOW = LAYER_MODE_BELOW,
    LABEL_MODE_CENTER = LABEL_MODE_CENTER,
    LABEL_MODE_LEFT = LABEL_MODE_LEFT,
    LABEL_MODE_LEFT_COMBINED = LABEL_MODE_LEFT_COMBINED,
    LABEL_MODE_RIGHT = LABEL_MODE_RIGHT,
    LABEL_MODE_RIGHT_COMBINED = LABEL_MODE_RIGHT_COMBINED,
    LABEL_MODE_SEPARATE = LABEL_MODE_SEPARATE,
    LABEL_MODE_LEFT_SUFFIX = LABEL_MODE_LEFT_SUFFIX,
    LABEL_MODE_RIGHT_PREFIX = LABEL_MODE_RIGHT_PREFIX,
    LABEL_MODE_NONE = LABEL_MODE_NONE,
    LABEL_ROW_ABOVE = LABEL_ROW_ABOVE,
    LABEL_ROW_BELOW = LABEL_ROW_BELOW,
    ORIENTATION_HORIZONTAL = ORIENTATION_HORIZONTAL,
    ORIENTATION_VERTICAL = ORIENTATION_VERTICAL,
    FILL_DIRECTION_UP = FILL_DIRECTION_UP,
    FILL_DIRECTION_DOWN = FILL_DIRECTION_DOWN,
    TEXTURE_PRESETS = TEXTURE_PRESETS,
    FONT_PRESETS = FONT_PRESETS,
}

Preydator.API = {
    GetSettings = function()
        return settings
    end,
    GetDefaults = function()
        return DEFAULTS
    end,
    GetState = function()
        return state
    end,
    Clamp = Clamp,
    RoundToStep = RoundToStep,
    NormalizeSliderValue = NormalizeSliderValue,
    CreateCheckboxControl = CreateCheckboxControl,
    CreateSliderControl = CreateSliderControl,
    ApplyBarSettings = function()
        ApplyBarSettings()
    end,
    UpdateBarDisplay = function()
        UpdateBarDisplay()
    end,
    RequestBarRefresh = function()
        ApplyBarSettings()
        UpdateBarDisplay()
    end,
    ApplyRuntimeSettings = function(nextSettings, emitProfileHook, refreshUi)
        Preydator:ApplyRuntimeSettings(nextSettings, emitProfileHook == true, refreshUi == true)
    end,
    ResetBarPosition = function()
        barPositionUtil.Reset()
    end,
    NormalizeSoundSettings = function()
        NormalizeSoundSettings()
    end,
    NormalizeLabelSettings = function()
        NormalizeLabelSettings()
    end,
    NormalizeColorSettings = function()
        NormalizeColorSettings()
    end,
    NormalizeDisplaySettings = function()
        NormalizeDisplaySettings()
    end,
    NormalizeProgressSettings = function()
        NormalizeProgressSettings()
    end,
    NormalizeAmbushSettings = function()
        NormalizeAmbushSettings()
    end,
    ApplyDefaultPreyIconVisibility = function()
        ApplyDefaultPreyIconVisibility()
    end,
    ResetAllSettings = function()
        ResetAllSettings()
    end,
    BuildSoundDropdownOptions = function()
        local runtime = GetRuntimeModule("SoundsRuntime")
        if runtime and type(runtime.BuildSoundDropdownOptions) == "function" then
            return runtime:BuildSoundDropdownOptions(settings, {
                defaultSoundFileNames = DEFAULT_SOUND_FILENAMES,
                noneLabel = _G.PreydatorL["None"],
                soundFolderPrefix = SOUND_FOLDER_PREFIX,
            })
        end

        local options = {}
        local files = (settings and settings.soundFileNames) or DEFAULT_SOUND_FILENAMES
        options["__NONE__"] = { text = _G.PreydatorL["None"] }
        for _, fileName in ipairs(files) do
            local path = SOUND_FOLDER_PREFIX .. tostring(fileName or "")
            options[path] = { text = tostring(fileName or "") }
        end
        return options
    end,
    AddSoundFileName = function(fileName)
        local runtime = GetRuntimeModule("SoundsRuntime")
        if runtime and type(runtime.AddSoundFileName) == "function" then
            return runtime:AddSoundFileName(fileName, settings, {
                soundFolderPrefix = SOUND_FOLDER_PREFIX,
                normalizeSoundSettings = NormalizeSoundSettings,
            })
        end

        return false, "Sound runtime is unavailable"
    end,
    RemoveSoundFileName = function(fileName)
        local runtime = GetRuntimeModule("SoundsRuntime")
        if runtime and type(runtime.RemoveSoundFileName) == "function" then
            return runtime:RemoveSoundFileName(fileName, settings, {
                soundFolderPrefix = SOUND_FOLDER_PREFIX,
                protectedSoundFileNames = PROTECTED_SOUND_FILENAMES,
                normalizeSoundSettings = NormalizeSoundSettings,
            })
        end

        return false, "Sound runtime is unavailable"
    end,
    ResolveStageSoundPath = function(stage)
        local runtime = GetRuntimeModule("SoundsRuntime")
        if runtime and type(runtime.ResolveStageSoundPath) == "function" then
            return runtime:ResolveStageSoundPath(stage, settings, {
                addDebugLog = AddDebugLog,
                getDefaultStageSoundPath = function(stageIndex)
                    return (stageIndex == 1 and ALERT_SOUND_PATH)
                        or (stageIndex == 2 and AMBUSH_SOUND_PATH)
                        or (stageIndex == 3 and TORMENT_SOUND_PATH)
                        or (stageIndex == 4 and KILL_SOUND_PATH)
                end,
            })
        end

        stage = tonumber(stage)
        if not stage then
            AddDebugLog("ResolveStageSoundPath", "invalid stage", false)
            return nil
        end

        local defaultPath = (stage == 1 and ALERT_SOUND_PATH)
            or (stage == 2 and AMBUSH_SOUND_PATH)
            or (stage == 3 and TORMENT_SOUND_PATH)
            or (stage == 4 and KILL_SOUND_PATH)
        if not settings then
            return defaultPath
        end

        settings.stageSounds = settings.stageSounds or {}
        local sounds = settings.stageSounds
        local savedPath = sounds[stage]
        if savedPath == "__NONE__" then
            AddDebugLog("ResolveStageSoundPath", "stage=" .. stage .. " | source=saved | path=none", false)
            return nil
        end
        if type(savedPath) == "string" and savedPath ~= "" then
            AddDebugLog("ResolveStageSoundPath", "stage=" .. stage .. " | source=saved | path=" .. savedPath, false)
            return savedPath
        end
        if defaultPath and defaultPath ~= "" then
            sounds[stage] = defaultPath
            AddDebugLog("ResolveStageSoundPath", "stage=" .. stage .. " | source=default | path=" .. defaultPath, false)
            return defaultPath
        end

        AddDebugLog("ResolveStageSoundPath", "stage=" .. stage .. " | source=none | default=nil", true)
        return nil
    end,
    ResolveAmbushSoundPath = function()
        local runtime = GetRuntimeModule("SoundsRuntime")
        if runtime and type(runtime.ResolveAmbushAlertSoundPath) == "function" then
            return runtime:ResolveAmbushAlertSoundPath(settings, {
                killSoundPath = KILL_SOUND_PATH,
            })
        end

        local path = settings and settings.ambushSoundPath
        if path == "__NONE__" then
            return nil
        end
        if type(path) == "string" and path ~= "" then
            return path
        end

        return KILL_SOUND_PATH
    end,
    ResolveBloodyCommandSoundPath = function()
        local runtime = GetRuntimeModule("SoundsRuntime")
        if runtime and type(runtime.ResolveBloodyCommandAlertSoundPath) == "function" then
            return runtime:ResolveBloodyCommandAlertSoundPath(settings, {
                killSoundPath = KILL_SOUND_PATH,
            })
        end

        local path = settings and settings.bloodyCommandSoundPath
        if path == "__NONE__" then
            return nil
        end
        if type(path) == "string" and path ~= "" then
            return path
        end

        return KILL_SOUND_PATH
    end,
    PlayTestSound = function(path)
        return TryPlaySound(path, true)
    end,
    TryPlayStageSound = function(stageIndex, force)
        return TryPlayStageSound(stageIndex, force)
    end,
    GetModuleRuntimeState = function()
        local runtime = {
            settings = settings,
            barEnabled = true,
            soundsEnabled = true,
            soundsRuntimeEnabled = (settings and settings.soundsEnabled ~= false) and true or false,
        }

        local customization = Preydator.GetModule and Preydator:GetModule("CustomizationStateV2")
        if customization and type(customization.IsModuleEnabled) == "function" then
            runtime.barEnabled = customization:IsModuleEnabled("bar") == true
            runtime.soundsEnabled = customization:IsModuleEnabled("sounds") == true
            runtime.soundsRuntimeEnabled = runtime.soundsEnabled and runtime.soundsRuntimeEnabled
        end

        return runtime
    end,
    SetBarRuntimeHandlers = function(handlers)
        if type(handlers) ~= "table" then
            return
        end

        if type(handlers.ApplyBarSettings) == "function" then
            BarRuntimeApplyHandler = handlers.ApplyBarSettings
        end

        if type(handlers.UpdateBarDisplay) == "function" then
            BarRuntimeUpdateHandler = handlers.UpdateBarDisplay
        end
    end,
    GetBarRuntimeContext = function()
        return {
            UI = UI,
            settings = settings,
            state = state,
            defaults = DEFAULTS,
            constants = Preydator.Constants,
            fillInset = FILL_INSET,
            maxTickMarks = MAX_TICK_MARKS,
            clamp = Clamp,
            round = Round,
            getTime = function()
                return (GetTime and GetTime()) or 0
            end,
            getModule = function(moduleName)
                return Preydator:GetModule(moduleName)
            end,
            runModuleHook = RunModuleHook,
            ensureBar = EnsureBar,
            applyDefaultPreyIconVisibility = ApplyDefaultPreyIconVisibility,
            isEditModePreviewActive = function()
                local editModeFrame = _G.EditModeManagerFrame
                return editModeFrame and editModeFrame.IsShown and editModeFrame:IsShown()
            end,
            isRestrictedInstanceForPreyBar = IsRestrictedInstanceForPreyBar,
            getStageFromState = GetStageFromState,
            getStageFallbackPercent = function(stage)
                local mode = (settings and settings.progressSegments) or PROGRESS_SEGMENTS_QUARTERS
                local stagePercents = STAGE_PCT_BY_SEGMENT[mode] or STAGE_PCT_BY_SEGMENT[PROGRESS_SEGMENTS_QUARTERS]
                return stagePercents[stage] or 0
            end,
            getStageLabel = GetStageLabel,
            getProgressTickPercents = function()
                local mode = (settings and settings.progressSegments) or PROGRESS_SEGMENTS_QUARTERS
                local tickPercents = BAR_TICK_PCTS_BY_SEGMENT[mode]
                if type(tickPercents) ~= "table" then
                    return BAR_TICK_PCTS_BY_SEGMENT[PROGRESS_SEGMENTS_QUARTERS]
                end

                return tickPercents
            end,
            getPercentTextLayerSettings = function()
                local mode = settings and settings.percentDisplay or PERCENT_DISPLAY_INSIDE
                if settings and settings.orientation == ORIENTATION_VERTICAL and type(settings.verticalPercentDisplay) == "string" then
                    mode = settings.verticalPercentDisplay
                end

                if mode == PERCENT_DISPLAY_INSIDE_BELOW then
                    mode = PERCENT_DISPLAY_INSIDE
                end

                if mode == PERCENT_DISPLAY_ABOVE_TICKS then
                    return "OVERLAY", 10
                end

                return "OVERLAY", 7
            end,
            getTickLayerSettings = function()
                return "OVERLAY", 4
            end,
            maxStage = MAX_STAGE,
            getCurrentActivePreyQuestCached = GetCurrentActivePreyQuestCached,
            refreshInPreyZoneStatus = RefreshInPreyZoneStatus,
            isValidQuestID = IsValidQuestID,
            barPositionUtil = barPositionUtil,
        }
    end,
    TriggerAmbushAlert = function(message, source)
        TriggerAmbushAlert(message, source)
    end,
    TriggerBloodyCommandAlert = function(spellID, sourceName, source)
        TriggerBloodyCommandAlert(spellID, sourceName, source)
    end,
    ClearBloodyCommandAlert = function()
        ClearBloodyCommandAlert()
    end,
    AddDebugLog = function(kind, message, forcePrint)
        AddDebugLog(kind, message, forcePrint)
    end,
    OpenLegacyOptionsPanel = function()
        if Settings and Settings.OpenToCategory then
            if type(UI.optionsCategoryID) == "number" then
                Settings.OpenToCategory(UI.optionsCategoryID)
                return true
            end

            if UI.optionsPanel and type(UI.optionsPanel.categoryID) == "number" then
                Settings.OpenToCategory(UI.optionsPanel.categoryID)
                return true
            end
        end

        return false
    end,
}

local function HandleSlashCommand(message)
    local slashModule = GetRuntimeModule("SlashCommands")
    if slashModule and type(slashModule.HandleSlashCommand) == "function" then
        slashModule:HandleSlashCommand(message, {
            ensureDebugDB = EnsureDebugDB,
            settings = settings,
            debugDB = debugDB,
            state = state,
            updateBarDisplay = UpdateBarDisplay,
            openOptionsPanel = OpenOptionsPanel,
            printMemoryUsage = function()
                local runtime = GetRuntimeModule("DebugRuntime")
                if runtime and type(runtime.PrintMemoryUsage) == "function" then
                    runtime:PrintMemoryUsage({
                        collectgarbageFn = _G.collectgarbage,
                        printFn = print,
                    })
                    return
                end

                print("Preydator: Debug runtime is unavailable.")
            end,
            modules = Preydator.modules,
            printFn = print,
        })
        return
    end

    print("Preydator: Slash command module is unavailable.")
end

frame:SetScript("OnEvent", function(_, event, arg1, arg2)
    local runtime = GetRuntimeModule("EventRuntime")
    if runtime and type(runtime.HandleEvent) == "function" then
        runtime:HandleEvent(event, arg1, arg2, {
            addonName = ADDON_NAME,
            state = state,
            ui = UI,
            preyProgressFinal = PREY_PROGRESS_FINAL,
            activePreyQuestCacheSeconds = ACTIVE_PREY_QUEST_CACHE_SECONDS,
            onAddonLoaded = OnAddonLoaded,
            ensureOptionsPanel = EnsureOptionsPanel,
            handleSlashCommand = HandleSlashCommand,
            applyBarSettings = ApplyBarSettings,
            updateBarDisplay = UpdateBarDisplay,
            runModuleHook = RunModuleHook,
            ensureBar = EnsureBar,
            getCustomizationModule = function()
                return Preydator:GetModule("CustomizationStateV2")
            end,
            armQuestListenBurst = ArmQuestListenBurst,
            getCurrentActivePreyQuestCached = GetCurrentActivePreyQuestCached,
            updatePreyState = UpdatePreyState,
            isValidQuestID = IsValidQuestID,
            isRestrictedInstanceForPreyBar = IsRestrictedInstanceForPreyBar,
            getTime = GetTime,
            setPollingActive = function(enabled)
                Preydator:SetPollingActive(enabled)
            end,
            shouldUseActivePolling = function()
                return Preydator:ShouldUseActivePolling()
            end,
        })
        return
    end

    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        OnAddonLoaded()
        EnsureOptionsPanel()
        SlashCmdList["PREYDATOR"] = HandleSlashCommand
    end
end)

-- Register addon events once during file load so we do not call RegisterEvent from runtime initialization paths.
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UPDATE_UI_WIDGET")
frame:RegisterEvent("UPDATE_ALL_UI_WIDGETS")
frame:RegisterEvent("QUEST_TURNED_IN")
frame:RegisterEvent("CHAT_MSG_SYSTEM")
frame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
frame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
frame:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
frame:RegisterEvent("RAID_BOSS_EMOTE")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
frame:RegisterEvent("QUEST_DETAIL")
frame:RegisterEvent("QUEST_ACCEPTED")
frame:RegisterEvent("ZONE_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_INDOORS")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

