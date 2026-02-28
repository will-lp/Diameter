local _, Diameter = ...

--[[
    This module provides the main loop-able functionality for Diameter.
    It updates the meter display based on the current view (modes, group, or spell).
    It binds together UI components with Data and Navigation modules.
]]

local Pages = Diameter.Pages
local EVT = Diameter.EventBus.Events
local color = Diameter.Color

local Presenter = {}
Presenter.__index = Presenter

function Presenter:New(id)
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

    obj.secretCleanupDone = true
    
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

    --[[
        When a page is changed we store that data and do a 
        single UpdateBars in case we are not in combat.

        @type data { page, targetGUID, targetName, targetIndex }
    ]]
    obj.eventBus:Listen(EVT.PAGE_CHANGED, function(data)
        obj.viewState = data
        obj:UpdateBars()
    end)

    --[[
        These Listen() calls are subscribing to the global EventBus, 
        hence the third parameter to be able to unsubscribe when the
        window is closed.
    ]]
    Diameter.EventBus:Listen(EVT.DATA_RESET, function(_)
        local data = {
            SessionType = Diameter.BlizzardDamageMeter.SessionType.Current,
            SessionID = nil
        }
        obj.eventBus:Fire(EVT.SESSION_TYPE_ID_CHANGED, data)
        obj:ClearBars()
    end, obj)

    return obj
end


--[[
    This is the main loop being executed by C_Timer on Diameter.lua.

    If we are not in combat, we have to pull data one more time to 
    clear the secrets from the data, hence the flag 'secretCleanupDone'.
]]
function Presenter:UpdateMeter()
    if InCombatLockdown() then
        self.secretCleanupDone = false
        self:UpdateBars()
    elseif self.secretCleanupDone == false then
        self:UpdateBars()
        self.secretCleanupDone = true
    end
end


--[[
    Invoked when the window is closed. 
    Currently cascading down to UI.
]]--
function Presenter:TearDown() 
    self.uiInstance:TearDown()
    Diameter.EventBus:Unregister(self)
    Diameter.Database:Remove(self.id)
end


function Presenter:UpdateBars() 
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


function Presenter:PrintPlayerSelection()
    local playersList = Diameter.PlayerList:GetPlayerList()

    for _, data in ipairs(playersList) do
        data.originalName = data.name
        data.name = "Select " .. data.originalName
    end

    self:UpdateBarsFromDataArray(playersList)
end


function Presenter:PrintModesMenu()
    local modes = { topValue = "1" }

    for _, mode in ipairs(Diameter.Menu.MenuOrder) do
        local label = Diameter.Menu.Labels[mode]
        local data = {
            name = label,
            mode = mode, -- this will be used by Navigation to set the mode
            value = 1, -- used to draw a bar according to the top value, but it's actually a visual bug.
            icon = nil,
            color = color.Blue,
            sourceGUID = nil,
        }
        table.insert(modes, data)
    end

    self:UpdateBarsFromDataArray(modes)

    self.eventBus:Fire(EVT.PAGE_DATA_LOADED, Diameter.Menu.MenuOrder)
end


function Presenter:UpdateGroupMeter(sessionID, mode, sessionType)
    local dataArray = Diameter.Data:GetGroupMeter(sessionID, mode, sessionType)

    self:UpdateBarsFromDataArray(dataArray)
end


function Presenter:UpdatePlayerSpellMeter(sessionID, mode, sessionType)
    local dataArray = Diameter.Data:GetSpellMeter(
            self.viewState, 
            mode, 
            sessionID, 
            sessionType)

    self:UpdateBarsFromDataArray(dataArray)
end


function Presenter:ClearBars()
    self:UpdateBarsFromDataArray({})
end


function Presenter:UpdateBarsFromDataArray(dataArray)
    self.uiInstance:UpdateBars(dataArray)
end


Diameter.Presenter = Presenter