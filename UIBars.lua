local _, Diameter = ...


Diameter.UI = Diameter.UI or {}


function Diameter.UI:CreateBars(scrollChild)
    local bars = {}
    
    -- Creating bars
    for i = 1, Diameter.UI.MaxBars do
        local bar = CreateFrame("StatusBar", nil, scrollChild)
        bar:SetHeight(self.step)

        local uiInstance = self
        -- Handling breakdown on click and coming back
        bar:EnableMouse(true)
        bar:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                -- Tell the meter to navigate down into group data or breakdown of the player.
                -- will navigate into Player Selection Mode if is in combat lockdown
                uiInstance.navigation:NavigateDown(self.data)
            elseif button == "RightButton" then
                -- Right click goes "Back" to the group data or modes list
                uiInstance.navigation:NavigateUp(self.data)
            end
        end)

        -- Create the Icon Texture
        bar.icon = bar:CreateTexture(nil, "OVERLAY")
        bar.icon:SetSize(self.step-2, self.step-2) -- Slightly smaller than the bar height
        bar.icon:SetPoint("LEFT", bar, "LEFT", 1, 0)

        -- This crops the outer 7% of the icon to remove the built-in border
        bar.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        -- Stack them vertically
        if i == 1 then
            -- Note: Using TOPLEFT/TOPRIGHT ensures the bar stretches to the width of the scrollChild
            bar:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
            bar:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, 0)
        else
            bar:SetPoint("TOPLEFT", bars[i-1], "BOTTOMLEFT", 0, -self.spacing)
            bar:SetPoint("TOPRIGHT", bars[i-1], "BOTTOMRIGHT", 0, -self.spacing)
        end
        
        bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")

        -- this is the starting point, the "bottle with a top light". I don't love it
        -- Diameter.UI:AddStatusBarGlow(bar)

        -- this adds a very sweet gradient
        Diameter.UI:AddVerticalGradient(bar)

        -- this adds a white line at the right edge. I don't hate it.
        Diameter.UI:AddSparkLine(bar)


        bar:SetStatusBarColor(0.8, 0.2, 0.2)
        
        bar.nameText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        -- Adjust the Name Text so it doesn't overlap the icon
        bar.nameText:ClearAllPoints()
        bar.nameText:SetPoint("LEFT", bar.icon, "RIGHT", 4, 0)
        
        bar.valueText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        bar.valueText:SetPoint("RIGHT", -5, 0)


        bar:Hide() -- Hide them until we have data
        bars[i] = bar
    end

    -- set a sensible initial height (MaxBars * step + (MaxBars - 1) * spacing)
    scrollChild:SetHeight(Diameter.UI.MaxBars * self.step + math.max(0, Diameter.UI.MaxBars - 1) * self.spacing)

    return bars
end


function Diameter.UI:AddVerticalGradient(bar)
    local barTexture = bar:GetStatusBarTexture()

    bar.overlay = bar:CreateTexture(nil, "ARTWORK")
    -- Anchor the gradient specifically to the moving colored bar
    bar.overlay:SetPoint("TOPLEFT", barTexture, "TOPLEFT")
    bar.overlay:SetPoint("BOTTOMRIGHT", barTexture, "BOTTOMRIGHT")

    bar.overlay:SetTexture("Interface\\Buttons\\WHITE8X8")
    -- This makes the gradient only exist where the color is!
    bar.overlay:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0.15), CreateColor(0, 0, 0, 0.15))
end


function Diameter.UI:AddSparkLine(bar)
    -- Create the Leading Edge (The "Spark")
    bar.spark = bar:CreateTexture(nil, "OVERLAY")
    bar.spark:SetWidth(1) -- The 1-pixel magic
    bar.spark:SetTexture("Interface\\Buttons\\WHITE8X8")
    bar.spark:SetVertexColor(1, 1, 1, 0.5) -- Semi-transparent white

    -- Anchor it to the leading edge of the bar
    bar.spark:SetPoint("TOP", barTexture, "TOPRIGHT", 0, 0)
    bar.spark:SetPoint("BOTTOM", barTexture, "BOTTOMRIGHT", 0, 0)

end


function Diameter.UI:AddStatusBarGlow(bar)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar-Glow")
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