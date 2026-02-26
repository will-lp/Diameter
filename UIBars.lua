local _, Diameter = ...


Diameter.UI = Diameter.UI or {}

local EVT = Diameter.EventBus.Events


--[[
    Updates bars based on a dataArray.

    The bars are pooled with BarPool.
]]--
function Diameter.UI:UpdateBars(dataArray)
    local mainFrame = self.mainFrame

    Diameter.BarPool:ReleaseAll(mainFrame.ScrollChild.Bars)
    mainFrame.ScrollChild.Bars = Diameter.BarPool:AcquireAll(self, dataArray)

    -- fill the bars with data
    for i, _ in ipairs(dataArray) do
        local data = dataArray[i]
        
        local bar = mainFrame.ScrollChild.Bars[i]
        self:UpdateBar(bar, data, dataArray.topValue)
    end

    self.eventBus:Fire(EVT.PAGE_DATA_LOADED, dataArray)
end


--[[
    Update a single bar in the meter.

    @param bar = the StatusBar object itself
    @param data = table { name=string, value=number, icon=textureID, color={r,g,b} }
    @param topValue = number used as a reference to 100% fill
]]--
function Diameter.UI:UpdateBar(bar, data, topValue)
    
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