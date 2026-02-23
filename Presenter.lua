
local _, Diameter = ...

--[[
    This module provides the main loop-able functionality for Diameter.
    It updates the meter display based on the current view (modes, group, or spell).
    It binds together UI components with Data and Navigation modules.
]]

local Pages = Diameter.Pages
local EVT = Diameter.EventBus.Events
local color = Diameter.Color

Diameter.Presenter = {}
Diameter.Presenter.__index = Diameter.Presenter

function Diameter.Presenter:New(id)
    local obj = setmetatable({}, self)

    obj.viewState = { 
        page = Pages.GROUP
    }

    obj.id = id
    obj.eventBus = Diameter.EventBusClass:New()
    obj.uiInstance = Diameter.UI:New(id, obj.eventBus)
    obj.mainFrame = obj.uiInstance.mainFrame
    obj.playerList = Diameter.PlayerList:GetPlayerList()

    -- these are the options loaded when the addon is booted on the very first time
    -- or a new window is created.
    obj.current = Diameter.Database:Get(obj.id)
    obj.current.Mode = obj.current.Mode or Diameter.BlizzardDamageMeter.Mode.DamageDone
    obj.current.SessionType = obj.current.SessionType or Diameter.BlizzardDamageMeter.SessionType.Current
    obj.current.SessionID = obj.current.SessionID or nil

    obj:UpdateBars()
    obj.eventBus:Fire(EVT.CURRENT_CHANGED, obj.current)
    obj.eventBus:Fire(EVT.MODE_CHANGED, obj.current.Mode)

    obj.uiInstance:UpdateScrollChildHeight()
    obj.uiInstance:ResetScrollPosition()
    
    obj.eventBus:Listen(EVT.MODE_CHANGED, function(data)
        obj.current.Mode = data
        obj:UpdateBars()
    end)

    obj.eventBus:Listen(EVT.SESSION_TYPE_CHANGED, function(data)
        obj.current.SessionType = data
        obj:UpdateBars()
    end)

    obj.eventBus:Listen(EVT.SESSION_TYPE_ID_CHANGED, function(data)
        obj.current.SessionType = data.SessionType
        obj.current.SessionID = data.SessionID
        obj:UpdateBars()
    end)

    obj.eventBus:Listen(EVT.PLAYER_SELECTION_MODE, function(playerSelectionMode)
        if playerSelectionMode == true then 
            obj.viewState.page = Pages.PLAYER_SELECTION
        else 
            obj.viewState.page = Pages.GROUP
        end
        obj:UpdateBars()
    end)

    --[[
        When a page is changed we store that data and do a 
        single UpdateBars in case we are not in combat.

        @type data { page, targetGUID, targetName, targetIndex }
    ]]
    obj.eventBus:Listen(EVT.PAGE_CHANGED, function(data)
        obj.viewState = data
        obj:UpdateBars()
    end)

    Diameter.EventBus:Listen(EVT.DATA_RESET, function(_)
        local data = {
            SessionType = Diameter.BlizzardDamageMeter.SessionType.Current,
            SessionID = nil
        }
        obj.eventBus:Fire(EVT.SESSION_TYPE_ID_CHANGED, data)
        obj:ClearBars()
    end, obj)

    Diameter.EventBus:Listen(EVT.GROUP_CHANGED, function(_)
        obj.playerList = Diameter.PlayerList:GetPlayerList()
    end, obj)

    return obj
end


--[[
    This is the main loop being executed by C_Timer on Diameter.lua.
    It returns early if not in combat; before this, it used to keep
    updating the DPS meter while out of combat and lowering your DPS.
]]
function Diameter.Presenter:UpdateMeter()
    local inCombat = UnitAffectingCombat("player")
    if not inCombat then
        return
    end

    self:UpdateBars()
end


function Diameter.Presenter:TearDown() 
    self.uiInstance.mainFrame:Hide() -- Make it invisible
    self.uiInstance.mainFrame:UnregisterAllEvents()
    Diameter.EventBus:Unregister(self)
    Diameter.Database:Remove(self.id)
end


function Diameter.Presenter:UpdateBars() 
    if self.viewState.page == Pages.MODES then
        self:PrintModesMenu()
        return
    end

    if self.viewState.page == Pages.PLAYER_SELECTION then
        self:PrintPlayerSelection()
        return
    end

    local sessionID = self.current.SessionID
    local mode = self.current.Mode
    local sessionType = self.current.SessionType

    if self.viewState.page == Pages.SPELL then
        self:UpdatePlayerSpellMeter(sessionID, mode, sessionType)
    elseif self.viewState.page == Pages.GROUP then
        self:UpdateGroupMeter(sessionID, mode, sessionType)
    end
end


function Diameter.Presenter:PrintPlayerSelection()
    self:UpdateBarsFromDataArray(self.playerList)
end


function Diameter.Presenter:PrintEmptyBars()
    local frame = self.mainFrame
    for i = 1, Diameter.UI.MaxBars do
        local bar = frame.ScrollChild.Bars[i]
        self:UpdateBar(bar, nil, nil)
    end
end


function Diameter.Presenter:PrintModesMenu()
    local frame = self.mainFrame
    for index, mode in ipairs(Diameter.Menu.MenuOrder) do
        local label = Diameter.Menu.Labels[mode]
        local data = {
            name = label,
            mode = mode, -- this will be used by Navigation to set the mode
            value = 1, -- this is used to draw a bar according to the top value
            icon = nil,
            color = color.Blue,
            sourceGUID = nil,
        }
        local bar = frame.ScrollChild.Bars[index]
        self:UpdateBar(bar, data, 1)
    end

    self.eventBus:Fire(EVT.PAGE_DATA_LOADED, Diameter.Menu.MenuOrder)
end


function Diameter.Presenter:UpdatePlayerSpellMeter(sessionID, mode, sessionType)
    local dataArray = Diameter.Data:GetSpellMeter(
            self.viewState, 
            mode, 
            sessionID, 
            sessionType)

    self:UpdateBarsFromDataArray(dataArray)
end


function Diameter.Presenter:UpdateGroupMeter(sessionID, mode, sessionType)
    local dataArray = Diameter.Data:GetGroupMeter(sessionID, mode, sessionType)

    self:UpdateBarsFromDataArray(dataArray)
end


function Diameter.Presenter:ClearBars()
    self:UpdateBarsFromDataArray({})
end


function Diameter.Presenter:UpdateBarsFromDataArray(dataArray)

    local frame = self.mainFrame

    -- fill the bars with data
    for i, _ in ipairs(dataArray) do
        local data = dataArray[i]
        local bar = frame.ScrollChild.Bars[i]
        self:UpdateBar(bar, data, dataArray.topValue)
    end


    self.eventBus:Fire(EVT.PAGE_DATA_LOADED, dataArray)
    

    -- To hide the bars we don't have data for
    for i = #dataArray + 1, Diameter.UI.MaxBars do
        local bar = frame.ScrollChild.Bars[i]
        self:UpdateBar(bar, nil, nil)
    end
end


--[[
    Update a single bar in the meter.

    @param bar = the StatusBar object itself
    @param data = table { name=string, value=number, icon=textureID, color={r,g,b} }
    @param topValue = number used as a reference to 100% fill
]]--
function Diameter.Presenter:UpdateBar(bar, data, topValue)
    
    if data and topValue then

        local displayValue = data.value or 0

        -- Update bar labels
        bar.nameText:SetText(data.name)

        bar.data = data
        
        bar.valueText:SetText(AbbreviateLargeNumbers(displayValue))

        if data.icon then
            bar.icon:SetTexture(data.icon)
            bar.icon:Show()
        else
            -- If no spec data, hide it
            bar.icon:Hide()
        end
        
        -- Set the bar color
        bar:SetStatusBarColor(data.color.r, data.color.g, data.color.b)

        -- Update bar fill relative to the top player
        bar:SetMinMaxValues(0, topValue)
        bar:SetValue(displayValue)
        
        bar:Show()
    else
        -- Hide bars if there's no player data for this slot
        bar:Hide()
    end
end