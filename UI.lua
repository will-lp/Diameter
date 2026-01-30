local addonName, Diameter = ...
Diameter.UI = {}
Diameter.UI.MaxBars = 40

function Diameter.UI:Boot()
    -- 1. Main Frame
    local f = CreateFrame("Frame", "DiameterMainFrame", UIParent, "BackdropTemplate")
    f:SetSize(250, 100) -- Taller starting size
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:SetResizable(true)
    f:SetResizeBounds(150, 50, 600, 800)
    f:SetClampedToScreen(true)

    -- Background
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0, 0, 0, 0.8)

    -- 2. Header Bar and button
    self:CreateHeader(f)

    -- Make the Header the handle for moving
    f:SetScript("OnMouseDown", function(self, button) 
        if button == "LeftButton" then self:StartMoving() end 
    end)
    f:SetScript("OnMouseUp", f.StopMovingOrSizing)

    

    -- 4. Resize Handle (Bottom Right)
    f.Resizer = CreateFrame("Button", nil, f)
    f.Resizer:SetSize(16, 16)
    f.Resizer:SetPoint("BOTTOMRIGHT")
    f.Resizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    f.Resizer:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    
    f.Resizer:SetScript("OnMouseDown", function() f:StartSizing("BOTTOMRIGHT") end)
    f.Resizer:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

    -- 5. Data Bar (Container for your current bar)
    self:CreateBars(f)

    return f
end

function Diameter.UI:CreateHeader(f)
    -- 2. Header Bar (Drag this to move)
    f.Header = CreateFrame("Frame", nil, f, "BackdropTemplate")
    f.Header:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4)
    f.Header:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    f.Header:SetHeight(20)
    f.Header:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"})
    f.Header:SetBackdropColor(0.2, 0.2, 0.2, 0.9)

    self:CreateMenuButton(f)
    
    f.HeaderText = f.Header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.HeaderText:SetPoint("LEFT", f.MenuBtn, "RIGHT", 5, 0)
    f.HeaderText:SetText("Diameter: Damage Done")
end


function Diameter.UI:CreateMenuButton(f)
    -- 3. Menu Button (The Skada-style Icon)
    f.MenuBtn = CreateFrame("Button", nil, f.Header)
    f.MenuBtn:SetSize(16, 16)
    f.MenuBtn:SetPoint("LEFT", 2, 0)
    f.MenuBtn:SetNormalTexture("Interface\\Icons\\INV_Misc_Gear_01") -- Cogwheel icon

end


function Diameter.UI:CreateBars(f)
    f.Bars = {} -- This is your Pool
    
    -- Creating bars
    for i = 1, Diameter.UI.MaxBars do
        local bar = CreateFrame("StatusBar", nil, f)
        bar:SetHeight(20)

        -- Handling breakdown on click and coming back
        bar:EnableMouse(true)
        bar:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                -- Tell the meter to drill down into this player
                Diameter.Navigation:DrillDown(self.data.sourceGUID, self.data.name, i)
            elseif button == "RightButton" then
                -- Right click usually goes "Back" to the main list
                Diameter.Navigation:ResetView()
            end
        end)

        -- Create the Icon Texture
        bar.icon = bar:CreateTexture(nil, "OVERLAY")
        bar.icon:SetSize(18, 18) -- Slightly smaller than the bar height
        bar.icon:SetPoint("LEFT", bar, "LEFT", 2, 0)

        -- This crops the outer 7% of the icon to remove the built-in border
        bar.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        -- Stack them vertically
        if i == 1 then
            bar:SetPoint("TOPLEFT", f.Header, "BOTTOMLEFT", 0, -2)
            bar:SetPoint("TOPRIGHT", f.Header, "BOTTOMRIGHT", 0, -2)
        else
            bar:SetPoint("TOPLEFT", f.Bars[i-1], "BOTTOMLEFT", 0, -1)
            bar:SetPoint("TOPRIGHT", f.Bars[i-1], "BOTTOMRIGHT", 0, -1)
        end
        
        bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        bar:SetStatusBarColor(0.8, 0.2, 0.2)
        
        bar.nameText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        -- Adjust the Name Text so it doesn't overlap the icon
        bar.nameText:ClearAllPoints()
        bar.nameText:SetPoint("LEFT", bar.icon, "RIGHT", 4, 0)
        
        bar.valueText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        bar.valueText:SetPoint("RIGHT", -5, 0)

        bar:Hide() -- Hide them until we have data
        f.Bars[i] = bar
    end
end 