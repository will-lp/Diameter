
local addonName, Diameter = ...

Diameter.Loop = {}



-- 4. The Update Function
-- @param f = CreateFrame
function Diameter.Loop:UpdateMeter(frame)
    local sessions = C_DamageMeter.GetAvailableCombatSessions()
    if #sessions == 0 then return end
    
    local sessionID = sessions[#sessions].sessionID
    
    local mode = Diameter.Current.Mode or 0

    if (Diameter.Navigation.isSpellView()) then
        self:UpdatePlayerSpellMeter(frame, sessionID, mode)
    else
        self:UpdateGroupMeter(frame, sessionID, mode)
    end
    
end

function Diameter.Loop:UpdatePlayerSpellMeter(frame, sessionID, mode)
    
    local dataArray = Diameter.Data:GetSpellMeter(Diameter.Navigation.getTargetGUID(), mode, sessionID)

    -- local dataArray = Diameter.Data:GetGroupMeter(sessionID, mode)[Diameter.Navigation:getTargetIndex()].breakdown

    self:UpdateBarsFromDataArray(frame, dataArray)

end

function Diameter.Loop:UpdateGroupMeter(frame, sessionID, mode)
    
    local dataArray = Diameter.Data:GetGroupMeter(sessionID, mode)

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