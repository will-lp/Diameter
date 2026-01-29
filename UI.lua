local addonName, Diameter = ...
Diameter.UI = {}

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

    -- 2. Header Bar (Drag this to move)
    f.Header = CreateFrame("Frame", nil, f, "BackdropTemplate")
    f.Header:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4)
    f.Header:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    f.Header:SetHeight(20)
    f.Header:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"})
    f.Header:SetBackdropColor(0.2, 0.2, 0.2, 0.9)
    
    -- Make the Header the handle for moving
    f:SetScript("OnMouseDown", function(self, button) 
        if button == "LeftButton" then self:StartMoving() end 
    end)
    f:SetScript("OnMouseUp", f.StopMovingOrSizing)

    -- 3. Menu Button (The Skada-style Icon)
    f.MenuBtn = CreateFrame("Button", nil, f.Header)
    f.MenuBtn:SetSize(16, 16)
    f.MenuBtn:SetPoint("LEFT", 2, 0)
    f.MenuBtn:SetNormalTexture("Interface\\Icons\\INV_Misc_Gear_01") -- Cogwheel icon
    
    f.HeaderText = f.Header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.HeaderText:SetPoint("LEFT", f.MenuBtn, "RIGHT", 5, 0)
    f.HeaderText:SetText("Gravy: Damage Done")

    -- 4. Resize Handle (Bottom Right)
    f.Resizer = CreateFrame("Button", nil, f)
    f.Resizer:SetSize(16, 16)
    f.Resizer:SetPoint("BOTTOMRIGHT")
    f.Resizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    f.Resizer:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    
    f.Resizer:SetScript("OnMouseDown", function() f:StartSizing("BOTTOMRIGHT") end)
    f.Resizer:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

    -- 5. Data Bar (Container for your current bar)
    -- We'll just update your existing bar logic to anchor to the Header
    f.bar = CreateFrame("StatusBar", nil, f)
    f.bar:SetPoint("TOPLEFT", f.Header, "BOTTOMLEFT", 0, -2)
    f.bar:SetPoint("TOPRIGHT", f.Header, "BOTTOMRIGHT", 0, -2)
    f.bar:SetHeight(20)
    f.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    f.bar:SetStatusBarColor(0.8, 0.2, 0.2)

    f.nameText = f.bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.nameText:SetPoint("LEFT", 5, 0)
    f.valueText = f.bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.valueText:SetPoint("RIGHT", -5, 0)

    return f
end