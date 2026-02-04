
local addonName, Diameter = ...

--[[
    This module provides the main loop functionality for Diameter.
    It updates the meter display based on the current view (modes, group, or spell).
    It binds together UI components with Data and Navigation modules.
]]

Diameter.Loop = {}

local EVT = Diameter.EventBus.Events
local viewState = { page = 'GROUP' }


local current = {}

--[[
    On addon boot we grab values from DiameterDB (sessionID, sessionType and mode)
    and do a single UpdateBars because we are probably not in combat.
]]
Diameter.EventBus:Listen(EVT.CURRENT_CHANGED, function(data)
    current = data
    Diameter.Loop:UpdateBars(Diameter.UI.mainFrame)
end)

Diameter.EventBus:Listen(EVT.MODE_CHANGED, function(data)
    current.Mode = data
    Diameter.Loop:UpdateBars(Diameter.UI.mainFrame)
end)

Diameter.EventBus:Listen(EVT.SESSION_TYPE_CHANGED, function(data)
    current.SessionType = data
    Diameter.Loop:UpdateBars(Diameter.UI.mainFrame)
end)

Diameter.EventBus:Listen(EVT.SESSION_TYPE_ID_CHANGED, function(data)
    current.SessionType = data.SessionType
    current.SessionID = data.SessionID
    Diameter.Loop:UpdateBars(Diameter.UI.mainFrame)
end)

--[[
    When a page is changed we store that data and do a 
    single UpdateBars in case we are not in combat.

    @type data { page, targetGUID, targetName, targetIndex }
]]
Diameter.EventBus:Listen(EVT.PAGE_CHANGED, function(data)
    viewState = data
    Diameter.Loop:UpdateBars(Diameter.UI.mainFrame)
end)



function Diameter.Loop:UpdateMeter(frame)

    local inCombat = UnitAffectingCombat("player")
    if not inCombat then
        return
    end
    
    self:UpdateBars(frame)
end

function Diameter.Loop:UpdateBars(frame) 
    
    if viewState.page == 'MODES' then
        self:PrintModesMenu(frame)
        return
    end
    
    local sessionID = current.SessionID
    local mode = current.Mode
    local sessionType = current.SessionType

    --print("Loop:sessionID", sessionID, "mode", mode, "sessionType", sessionType)

    if viewState.page == 'SPELL' then
        self:UpdatePlayerSpellMeter(frame, sessionID, mode, sessionType)
    elseif viewState.page == 'GROUP' then
        self:UpdateGroupMeter(frame, sessionID, mode, sessionType)
    end
end

function Diameter.Loop:PrintEmptyBars(frame)
    for i = 1, Diameter.UI.MaxBars do
        local bar = frame.ScrollChild.Bars[i]
        self:UpdateBar(bar, nil, nil)
    end
end

function Diameter.Loop:PrintModesMenu(frame)
    for index, mode in ipairs(Diameter.Menu.MenuOrder) do
        local label = Diameter.Menu.Labels[mode]
        local data = {
            name = label,
            mode = mode, -- this will be used by Navigation to set the mode
            value = 1, -- this is used to draw a bar according to the top value
            icon = nil,
            color = {r=0.3, g=0.3, b=0.9},
            sourceGUID = nil,
        }
        local bar = frame.ScrollChild.Bars[index]
        self:UpdateBar(bar, data, 1)
    end
end

function Diameter.Loop:UpdatePlayerSpellMeter(frame, sessionID, mode, sessionType)
    
    local dataArray = Diameter.Data:GetSpellMeter(Diameter.Navigation.getTargetGUID(), mode, sessionID, sessionType)

    self:UpdateBarsFromDataArray(frame, dataArray)

end

function Diameter.Loop:UpdateGroupMeter(frame, sessionID, mode, sessionType)
    
    local dataArray = Diameter.Data:GetGroupMeter(sessionID, mode, sessionType)

    self:UpdateBarsFromDataArray(frame, dataArray)
    
end

function Diameter.Loop:UpdateBarsFromDataArray(frame, dataArray)

    -- fill the bars with data
    for i, _ in ipairs(dataArray) do
        local data = dataArray[i]
        local bar = frame.ScrollChild.Bars[i]
        self:UpdateBar(bar, data, dataArray.topValue)
    end

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
function Diameter.Loop:UpdateBar(bar, data, topValue)
    
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