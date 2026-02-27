local _, Diameter = ...


Diameter.BarPool = {}


-- use a bar pool instead of creating a bunch of bars.
Diameter.BarPool.pool = CreateFramePool(
    "StatusBar", 
    nil, 
    "BackdropTemplate", 
    function(pool, bar) Diameter.BarPool:InitializeBar(bar) end
)


--[[
    Initialize a fresh bar harvested from the pool.

    If any weird behaviours comes up, this can debug the source of calls:
    print ("InitializeBar", bar, debugstack(1, 10, 10))
]]--
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

    bar:SetStatusBarColor(0.8, 0.2, 0.2)

    self:AddVerticalGradient(bar)
    self:AddSparkLine(bar)

    bar.nameText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- Adjust the Name Text so it doesn't overlap the icon
    bar.nameText:ClearAllPoints()
    bar.nameText:SetPoint("LEFT", bar.icon, "RIGHT", 4, 0)
    
    bar.valueText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bar.valueText:SetPoint("RIGHT", -5, 0)
end


function Diameter.BarPool:ReleaseBar(bar)
    bar.nameText:SetText(nil)
    bar.valueText:SetText(nil)
    bar.icon:SetTexture(nil)
    bar:Hide()
    bar:ClearAllPoints()
    bar:SetParent(nil)
    bar.data = nil
    bar.uiInstance = nil
end


--[[
    Clears every bar of their content and puts them back in the pool.
]]--
function Diameter.BarPool:ReleaseAll(bars)
    for _, bar in pairs(bars) do
        self:ReleaseBar(bar)
        self.pool:Release(bar)
    end
end


function Diameter.BarPool:Acquire(uiInstance)
    return self.pool:Acquire()
end


function Diameter.BarPool:AddVerticalGradient(bar)
    if not bar.overlay then
        local barTexture = bar:GetStatusBarTexture()

        -- the "nil, 1" arguments is to try to fix an error where
        -- the gradient would stop showing on some bars.
        -- this way we force a sub-layer to stay above the bar, hopefully.
        bar.overlay = bar:CreateTexture(nil, "ARTWORK", nil, 1)
        bar.overlay:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
        bar.overlay:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
        bar.overlay:SetPoint("RIGHT", barTexture, "RIGHT", 0, 0)

        bar.overlay:SetTexture("Interface\\Buttons\\WHITE8X8")
        bar.overlay:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0.15), CreateColor(0, 0, 0, 0.15))
    end
end


function Diameter.BarPool:SetGradientPoints(bar)
    local barTexture = bar:GetStatusBarTexture()
    bar.overlay:ClearAllPoints() -- wipe the "broken" state
    bar.overlay:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
    bar.overlay:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    bar.overlay:SetPoint("RIGHT", barTexture, "RIGHT", 0, 0)
end


function Diameter.BarPool:AddSparkLine(bar)
    if not bar.spark then
        local barTexture = bar:GetStatusBarTexture()
        -- Create the Leading Edge ("Spark")
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