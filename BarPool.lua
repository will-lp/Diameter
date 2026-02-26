local _, Diameter = ...


Diameter.BarPool = {}


-- use a bar pool instead of creating a bunch of bars.
Diameter.BarPool.pool = CreateFramePool("StatusBar", nil, "BackdropTemplate", function(pool, bar)
    Diameter.BarPool:InitializeBar(bar)
end)


function Diameter.BarPool:InitializeBar(bar)
    local step = Diameter.UI.step

    bar:SetHeight(step)

    -- Handling breakdown on click and coming back
    bar:EnableMouse(true)
    bar:SetScript("OnMouseDown", function(self, button)
        -- Every Acquire() bar will need to set the uiInstance
        local uiInstance = self.uiInstance
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
    bar.icon:SetSize(step - 2, step - 2) -- Slightly smaller than the bar height
    bar.icon:SetPoint("LEFT", bar, "LEFT", 1, 0)

    -- This crops the outer 7% of the icon to remove the built-in border
    bar.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    Diameter.BarPool:AddVerticalGradient(bar)

    -- this adds a white line at the right edge. I don't hate it.
    Diameter.BarPool:AddSparkLine(bar)

    bar:SetStatusBarColor(0.8, 0.2, 0.2)
    
    bar.nameText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- Adjust the Name Text so it doesn't overlap the icon
    bar.nameText:ClearAllPoints()
    bar.nameText:SetPoint("LEFT", bar.icon, "RIGHT", 4, 0)
    
    bar.valueText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bar.valueText:SetPoint("RIGHT", -5, 0)
end


--[[
    Clears every bar of their content and puts them back in the pool.
]]--
function Diameter.BarPool:ReleaseAll(bars)
    for _, bar in pairs(bars) do
        bar.nameText:SetText(nil)
        bar.valueText:SetText(nil)
        bar.icon:SetTexture(nil)
        bar:Hide()
        bar:ClearAllPoints()
        bar:SetParent(nil)
        bar.data = nil
        bar.uiInstance = nil
        self.pool:Release(bar)
    end
end


--[[
    Acquires a bunch of bars from the pool. One per table in the dataArray.
    The uiInstance is required to grab some stuff:
     - mainFrame
     - mainFrame.ScrollChild
     - setting up the uiInstance field for the mouseDown event

     @returns a table with the bars created
]]--
function Diameter.BarPool:AcquireAll(uiInstance, dataArray)

    local spacing = Diameter.UI.spacing
    local bars = {}

    local scrollChild = uiInstance.mainFrame.ScrollChild
    
    for i, _ in ipairs(dataArray) do

        local bar = self.pool:Acquire()

        -- not sure this is needed as it happens on ReleaseAll already.
        bar:ClearAllPoints()

        bar.uiInstance = uiInstance
        bar:SetParent(scrollChild)

        -- Stack them vertically
        if i == 1 then
            -- Note: Using TOPLEFT/TOPRIGHT ensures the bar stretches to the width of the scrollChild
            bar:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
            bar:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, 0)
        else
            bar:SetPoint("TOPLEFT", bars[i-1], "BOTTOMLEFT", 0, -spacing)
            bar:SetPoint("TOPRIGHT", bars[i-1], "BOTTOMRIGHT", 0, -spacing)
        end
        
        bar:SetStatusBarColor(0.8, 0.2, 0.2)
        
        table.insert(bars, bar)
    end

    return bars
end


function Diameter.BarPool:AddVerticalGradient(bar)
    if not bar.overlay then
        local barTexture = bar:GetStatusBarTexture()

        bar.overlay = bar:CreateTexture(nil, "ARTWORK")
        -- Anchor the gradient specifically to the moving colored bar
        bar.overlay:SetPoint("TOPLEFT", barTexture, "TOPLEFT")
        bar.overlay:SetPoint("BOTTOMRIGHT", barTexture, "BOTTOMRIGHT")

        bar.overlay:SetTexture("Interface\\Buttons\\WHITE8X8")
        -- This makes the gradient only exist where the color is!
        bar.overlay:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0.15), CreateColor(0, 0, 0, 0.15))
    end
end


function Diameter.BarPool:AddSparkLine(bar)
    if not bar.spark then
        local barTexture = bar:GetStatusBarTexture()
        -- Create the Leading Edge (The "Spark")
        bar.spark = bar:CreateTexture(nil, "OVERLAY")
        bar.spark:SetWidth(1) -- The 1-pixel magic
        bar.spark:SetTexture("Interface\\Buttons\\WHITE8X8")
        bar.spark:SetVertexColor(1, 1, 1, 0.5) -- Semi-transparent white

        -- Anchor it to the leading edge of the bar
        bar.spark:SetPoint("TOP", barTexture, "TOPRIGHT", 0, 0)
        bar.spark:SetPoint("BOTTOM", barTexture, "BOTTOMRIGHT", 0, 0)
    end
end


function Diameter.BarPool:AddStatusBarGlow(bar)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar-Glow")
end