local _, Diameter = ...


--[[
    Module responsible to handle the bars acquisition, releasing and updating them.

]]--

Diameter.UI = Diameter.UI or {}

local EVT = Diameter.EventBus.Events


function Diameter.UI:ReleaseBars()
    local bars = self.mainFrame.ScrollChild.Bars
    Diameter.BarPool:ReleaseAll(bars)
    table.wipe(bars)
end


--[[
    Updates bars based on a dataArray.

    The bars are pooled with BarPool. If we don't have enough bars to 
    cover #dataArray, we start to Acquire() from the BarPool.
]]--
function Diameter.UI:UpdateBars(dataArray)
    local mainFrame = self.mainFrame

    local bars = mainFrame.ScrollChild.Bars
    local spacing = Diameter.UI.spacing
    local scrollChild = mainFrame.ScrollChild

    -- fill the bars with data
    for i, _ in ipairs(dataArray) do

        local data = dataArray[i]
        local bar = bars[i]

        if not bar then
            bar = Diameter.BarPool:Acquire(self)
            bars[i] = bar
            bar.uiInstance = self
            bar:SetParent(scrollChild)

            if i == 1 then
                bar:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
                bar:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, 0)
            else
                bar:SetPoint("TOPLEFT", bars[i-1], "BOTTOMLEFT", 0, -spacing)
                bar:SetPoint("TOPRIGHT", bars[i-1], "BOTTOMRIGHT", 0, -spacing)
            end
            bar:SetStatusBarColor(0.8, 0.2, 0.2)
        end
        
        self:UpdateBar(bar, data, dataArray.topValue)
    end

    for i = #dataArray + 1, #bars do
        bars[i]:Hide()
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
