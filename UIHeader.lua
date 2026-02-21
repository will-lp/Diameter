local addonName, Diameter = ...

--[[
    This module is responsible for creating the header and its components:
    - header
    - title (addon name, which mode I am on)
    - party selection toggle
    - segment button
]]

local EVT = Diameter.EventBus.Events

Diameter.UIHeader = {}
Diameter.UIHeader.__index = Diameter.UIHeader

function Diameter.UIHeader:New(mainFrame)
    local obj = setmetatable({}, Diameter.UIHeader)

    obj.mainFrame = mainFrame
    obj.Header = obj:CreateHeader(mainFrame)
    obj.MenuBtn = obj:CreateMenuButton(obj.Header)
    obj.SegmentBtn = obj:CreateSegmentButton(obj.Header)
    obj.PlayerSelectionBtn = obj:CreatePlayerToggle(obj.Header)
    obj.HeaderText = obj:CreateHeaderText(obj.Header)

    Diameter.EventBus:Listen(EVT.CURRENT_CHANGED, function(data)
        obj.SegmentBtn:SetText(obj:GetIndicatorText(data))
    end)

    Diameter.EventBus:Listen(EVT.SESSION_TYPE_CHANGED, function(data)
        obj.SegmentBtn:SetText(obj:GetIndicatorText({ SessionType = data }))
    end)

    Diameter.EventBus:Listen(EVT.SESSION_TYPE_ID_CHANGED, function(data)
        obj.SegmentBtn:SetText(obj:GetIndicatorText(data))
    end)

    Diameter.EventBus:Listen(EVT.MODE_CHANGED, function (mode)
        local label = Diameter.Menu.Labels[mode]
        obj.HeaderText:SetText(addonName .. ": " .. label)
    end)

    --[[
        If we are on playerSelectionMode and the page is changed, we disable
        playerSelectionMode.
    ]]
    Diameter.EventBus:Listen(EVT.PAGE_CHANGED, function()
        obj.PlayerSelectionBtn:SetBackdropColor(0, 0, 0, 0.5) -- Back to default
        obj.PlayerSelectionBtn.isActive = false
    end)

    return obj
end


function Diameter.UIHeader:CreateHeader(mainFrame)
    
    -- Draggable Header Bar
    local Header = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    Header:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 4, -4)
    Header:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -4, -4)
    Header:SetHeight(Diameter.UI.step)
    Header:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"})
    Header:SetBackdropColor(0.2, 0.2, 0.2, 0.9)

    return Header
end

function Diameter.UIHeader:CreateHeaderText(Header)
    local HeaderText = Header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    HeaderText:SetPoint("LEFT", self.MenuBtn, "RIGHT", 5, 0)

    return HeaderText
end


function Diameter.UIHeader:CreateMenuButton(Header)
    local MenuBtn = CreateFrame("Button", nil, Header)
    MenuBtn:SetSize(16, 16)
    MenuBtn:SetPoint("LEFT", 2, 0)
    MenuBtn:SetNormalTexture("Interface\\Icons\\INV_Misc_Gear_01") -- Cogwheel icon

    MenuBtn:SetScript("OnClick", function(self)
        Diameter.Menu:ShowMenu(self)
    end)

    return MenuBtn
end


function Diameter.UIHeader:GetIndicatorText(current)
    
    if current.SessionType == Diameter.BlizzardDamageMeter.SessionType.Overall then 
        return "O" 
    end
    
    -- Check if it's the latest session
    if current.SessionType == Diameter.BlizzardDamageMeter.SessionType.Current then 
        return "C" 
    end
    
    return current.SessionID
end


--[[
    Creates an icon for the Player Selection Mode. 
    Once clicked, it will show a green background.
    Changing the page (doesn't matter on which directio) must 
    disable this guy, i.e., background is back to gray-ish.
]]
function Diameter.UIHeader:CreatePlayerToggle(Header)
    local PlayerSelectionBtn = CreateFrame("Button", nil, Header, "BackdropTemplate")
    PlayerSelectionBtn:SetSize(18, 18)
    PlayerSelectionBtn:SetPoint("RIGHT", Header, "RIGHT", -40, 0)

    PlayerSelectionBtn.isActive = false

    PlayerSelectionBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })

    local tex = PlayerSelectionBtn:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints()
    tex:SetAtlas("socialqueuing-icon-group") -- A nice "group" icon


    PlayerSelectionBtn:SetBackdropColor(0, 0, 0, 0.5)
    PlayerSelectionBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
    PlayerSelectionBtn:SetScript("OnClick", function(self)
        if not self.isActive then
            self:SetBackdropColor(0.2, 0.9, 0.2, 0.7)
            self.isActive = true
        else
            self:SetBackdropColor(0, 0, 0, 0.5) -- Back to default
            self.isActive = false
        end
        Diameter.EventBus:Fire(EVT.PLAYER_SELECTION_MODE, self.isActive)
    end)

    return PlayerSelectionBtn
end


function Diameter.UIHeader:CreateSegmentButton(Header)

    -- 1. Create the badge button
    local segmentBtn = CreateFrame("Button", nil, Header, "BackdropTemplate")
    segmentBtn:SetSize(35, 18)
    segmentBtn:SetPoint("RIGHT", Header, "RIGHT", -1, 0)

    segmentBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    segmentBtn:SetBackdropColor(0, 0, 0, 0.5)
    segmentBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

    -- 2. The Chevron (Now anchored to the LEFT of the button)
    local chevron = segmentBtn:CreateTexture(nil, "OVERLAY")
    chevron:SetSize(10, 10)
    chevron:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    chevron:SetPoint("LEFT", segmentBtn, "LEFT", 4, 0) -- 4px padding from left edge

    -- 3. The Indicator Text (Now anchored to the RIGHT of the chevron)
    local sessionIndicator = segmentBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sessionIndicator:SetFont(sessionIndicator:GetFont(), 13, "OUTLINE")
    -- Pull it close to the chevron with a small offset
    sessionIndicator:SetPoint("LEFT", chevron, "RIGHT", -1, 0)
    sessionIndicator:SetText("C")

    -- Attach your existing menu logic
    segmentBtn:SetScript("OnClick", function(self)
        Diameter.Menu:ShowSessions(self)
    end)

    function segmentBtn:SetText(text)
        sessionIndicator:SetText(text)
    end

    return segmentBtn
end