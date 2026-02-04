local addonName, Diameter = ...

Diameter.UIHeader = {}


function Diameter.UIHeader:CreateHeader(mainFrame)
    -- 2. Header Bar (Drag this to move)
    mainFrame.Header = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    mainFrame.Header:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 4, -4)
    mainFrame.Header:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -4, -4)
    mainFrame.Header:SetHeight(Diameter.UI.step)
    mainFrame.Header:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"})
    mainFrame.Header:SetBackdropColor(0.2, 0.2, 0.2, 0.9)

    self:CreateMenuButton(mainFrame)
    self:CreateSegmentButton(mainFrame)
    
    mainFrame.HeaderText = mainFrame.Header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    mainFrame.HeaderText:SetPoint("LEFT", mainFrame.MenuBtn, "RIGHT", 5, 0)
    mainFrame.HeaderText:SetText("Diameter: Damage Done")
end


function Diameter.UIHeader:CreateMenuButton(mainFrame)
    -- 3. Menu Button (The Skada-style Icon)
    mainFrame.MenuBtn = CreateFrame("Button", nil, mainFrame.Header)
    mainFrame.MenuBtn:SetSize(16, 16)
    mainFrame.MenuBtn:SetPoint("LEFT", 2, 0)
    mainFrame.MenuBtn:SetNormalTexture("Interface\\Icons\\INV_Misc_Gear_01") -- Cogwheel icon

    mainFrame.MenuBtn:SetScript("OnClick", function(self)
        Diameter.Menu:ShowMenu(self)
    end)
end


--[[function Diameter.UIHeader:CreateSegmentButton(mainFrame)
    mainFrame.SegmentBtn = CreateFrame("Button", nil, mainFrame.Header)
    mainFrame.SegmentBtn:SetSize(16, 16)
    mainFrame.SegmentBtn:SetPoint("RIGHT", mainFrame.Header, "RIGHT", -2, 0)
    
    -- Force the button to be on a higher layer than the header background
    mainFrame.SegmentBtn:SetFrameLevel(mainFrame.Header:GetFrameLevel() + 1)

    local tex = mainFrame.SegmentBtn:CreateTexture(nil, "ARTWORK")
    tex:SetTexture("Interface\\Icons\\INV_Misc_Statue_02")
    tex:SetAllPoints()
    mainFrame.SegmentBtn:SetNormalTexture(tex)

    mainFrame.SegmentBtn:SetScript("OnClick", function(self, button)
        Diameter.Menu:ShowSessions(self)
    end)
end]]

local function GetIndicatorText()
    local cur = Diameter.Current
    if cur.SessionType == Diameter.BlizzardDamageMeter.SessionType.Overall then 
        return "O" 
    end
    
    -- Check if it's the latest session
    if cur.SessionID == #Diameter.Data:GetSessions() then 
        return "C" 
    end
    
    return cur.SessionID
end

function Diameter.UIHeader:UpdateTypeAndSessionIndicator()
    Diameter.UI.mainFrame.SessionIndicator:SetText(GetIndicatorText())
end




function Diameter.UIHeader:CreateSegmentButton(mainFrame)

    -- 1. Create the badge button
    mainFrame.SegmentBtn = CreateFrame("Button", nil, mainFrame.Header, "BackdropTemplate")
    mainFrame.SegmentBtn:SetHeight(18)
    mainFrame.SegmentBtn:SetPoint("RIGHT", mainFrame.Header, "RIGHT", -8, 0)

    mainFrame.SegmentBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    mainFrame.SegmentBtn:SetBackdropColor(0, 0, 0, 0.5)
    mainFrame.SegmentBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

    -- 2. The Chevron (Now anchored to the LEFT of the button)
    mainFrame.Chevron = mainFrame.SegmentBtn:CreateTexture(nil, "OVERLAY")
    mainFrame.Chevron:SetSize(10, 10)
    mainFrame.Chevron:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    mainFrame.Chevron:SetPoint("LEFT", mainFrame.SegmentBtn, "LEFT", 4, 0) -- 4px padding from left edge

    -- 3. The Indicator Text (Now anchored to the RIGHT of the chevron)
    mainFrame.SessionIndicator = mainFrame.SegmentBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainFrame.SessionIndicator:SetFont(mainFrame.SessionIndicator:GetFont(), 13, "OUTLINE")
    -- Pull it close to the chevron with a small offset
    mainFrame.SessionIndicator:SetPoint("LEFT", mainFrame.Chevron, "RIGHT", -1, 0)
    mainFrame.SessionIndicator:SetText("C")

    -- 4. Dynamic Resizing logic
    mainFrame.UpdateBadgeSize = function()
        local textWidth = mainFrame.SessionIndicator:GetStringWidth()
        -- [Left Padding (4)] + [Chevron (10)] + [Offset (-1)] + [TextWidth] + [Right Padding (5)]
        local totalWidth = 4 + 10 - 1 + textWidth + 5
        mainFrame.SegmentBtn:SetWidth(totalWidth)
    end

    mainFrame.UpdateBadgeSize()

    -- Attach your existing menu logic
    mainFrame.SegmentBtn:SetScript("OnClick", function(self)
        Diameter.Menu:ShowSessions(self)
    end)
end