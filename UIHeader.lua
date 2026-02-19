local addonName, Diameter = ...

Diameter.UIHeader = {}

local EVT = Diameter.EventBus.Events

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
    self:CreatePlayerToggle(mainFrame)
    
    mainFrame.HeaderText = mainFrame.Header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    mainFrame.HeaderText:SetPoint("LEFT", mainFrame.MenuBtn, "RIGHT", 5, 0)
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


local function GetIndicatorText(current)
    
    if current.SessionType == Diameter.BlizzardDamageMeter.SessionType.Overall then 
        return "O" 
    end
    
    -- Check if it's the latest session
    if current.SessionType == Diameter.BlizzardDamageMeter.SessionType.Current then 
        return "C" 
    end
    
    return current.SessionID
end

Diameter.EventBus:Listen(EVT.CURRENT_CHANGED, function(data)
    Diameter.UI.mainFrame.SessionIndicator:SetText(GetIndicatorText(data))
end)

Diameter.EventBus:Listen(EVT.SESSION_TYPE_CHANGED, function(data)
    Diameter.UI.mainFrame.SessionIndicator:SetText(GetIndicatorText({ SessionType = data }))
end)

Diameter.EventBus:Listen(EVT.SESSION_TYPE_ID_CHANGED, function(data)
    Diameter.UI.mainFrame.SessionIndicator:SetText(GetIndicatorText(data))
end)


--[[
    If we are on playerSelectionMode and the page is changed, we disable
    playerSelectionMode.
]]
Diameter.EventBus:Listen(EVT.PAGE_CHANGED, function()
    local btn = Diameter.UI.mainFrame.PlayerSelectionBtn
    btn:SetBackdropColor(0, 0, 0, 0.5) -- Back to default
    btn.isActive = false
end)

function Diameter.UIHeader:CreatePlayerToggle(mainFrame)
    mainFrame.PlayerSelectionBtn = CreateFrame("Button", nil, mainFrame.Header, "BackdropTemplate")
    mainFrame.PlayerSelectionBtn:SetSize(18, 18)
    mainFrame.PlayerSelectionBtn:SetPoint("RIGHT", mainFrame.SegmentBtn, "LEFT", -5, 0)

    mainFrame.PlayerSelectionBtn.isActive = false

    mainFrame.PlayerSelectionBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })

    local tex = mainFrame.PlayerSelectionBtn:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints()
    tex:SetAtlas("socialqueuing-icon-group") -- A nice "group" icon


    mainFrame.PlayerSelectionBtn:SetBackdropColor(0, 0, 0, 0.5)
    mainFrame.PlayerSelectionBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
    mainFrame.PlayerSelectionBtn:SetScript("OnClick", function(self)
        if not self.isActive then
            self:SetBackdropColor(0.2, 0.9, 0.2, 0.7)
            self.isActive = true
        else
            self:SetBackdropColor(0, 0, 0, 0.5) -- Back to default
            self.isActive = false
        end
        Diameter.EventBus:Fire(EVT.PLAYER_SELECTION_MODE, self.isActive)
    end)
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