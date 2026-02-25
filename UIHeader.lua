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

function Diameter.UIHeader:New(mainFrame, id, eventBus)
    local obj = setmetatable({}, Diameter.UIHeader)

    obj.id = id
    obj.mainFrame = mainFrame
    obj.eventBus = eventBus
    obj.menu = Diameter.Menu:New(eventBus)

    obj.Header = obj:CreateHeader(mainFrame)
    obj.MenuBtn = obj:CreateMenuButton(obj.Header)
    obj.SegmentBtn = obj:CreateSegmentButton(obj.Header)
    obj.HeaderText = obj:CreateHeaderText(obj.Header)

    obj.eventBus:Listen(EVT.CURRENT_CHANGED, function(data)
        obj.SegmentBtn:SetText(obj:GetIndicatorText(data))
    end)

    obj.eventBus:Listen(EVT.SESSION_TYPE_CHANGED, function(data)
        obj.SegmentBtn:SetText(obj:GetIndicatorText({ SessionType = data }))
    end)

    obj.eventBus:Listen(EVT.SESSION_TYPE_ID_CHANGED, function(data)
        obj.SegmentBtn:SetText(obj:GetIndicatorText(data))
    end)

    obj.eventBus:Listen(EVT.MODE_CHANGED, function (mode)
        local label = Diameter.Menu.Labels[mode]
        obj.HeaderText:SetText(addonName .. ": " .. label)
    end)

    return obj
end


function Diameter.UIHeader:CreateHeader(mainFrame)
    
    -- Draggable Header Bar
    local Header = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    Header:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)
    Header:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, 0)
    Header:SetHeight(Diameter.UI.step + 3)
    Header:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        insets = { left = 0, right = 0, top = 0, bottom = 1 }
    })
    Header:SetBackdropColor(0.3, 0.3, 0.3, 0.8)

    return Header
end

function Diameter.UIHeader:CreateHeaderText(Header)
    local HeaderText = Header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    HeaderText:SetPoint("LEFT", self.MenuBtn, "RIGHT", 5, 0)

    return HeaderText
end


local highlightBorder = function(self) self:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) end
local restoreBorder = function(self) self:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8) end


function Diameter.UIHeader:CreateMenuButton(Header)
    local MenuBtn = CreateFrame("Button", nil, Header, "BackdropTemplate")
    MenuBtn:SetSize(18, 18)
    MenuBtn:SetPoint("LEFT", Header, "LEFT", 2, 0)

    MenuBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    MenuBtn:SetBackdropColor(0, 0, 0, 0.5)
    MenuBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

    local icon = MenuBtn:CreateTexture(nil, "OVERLAY")
    icon:SetSize(14, 14) -- Slightly smaller to fit inside the border
    icon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
    icon:SetPoint("CENTER", MenuBtn, "CENTER", 0, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    MenuBtn:SetScript("OnEnter", highlightBorder)
    MenuBtn:SetScript("OnLeave", restoreBorder)

    local obj = self
    MenuBtn:SetScript("OnClick", function(self)
        obj.menu:ShowMenu(self, obj.id)
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


function Diameter.UIHeader:CreateSegmentButton(Header)

    -- 1. Create the badge button
    local segmentBtn = CreateFrame("Button", nil, Header, "BackdropTemplate")
    segmentBtn:SetSize(35, 18)
    segmentBtn:SetPoint("RIGHT", Header, "RIGHT", -2, 0)

    segmentBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    segmentBtn:SetBackdropColor(0, 0, 0, 0.5)
    segmentBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

    segmentBtn:SetScript("OnEnter", highlightBorder)
    segmentBtn:SetScript("OnLeave", restoreBorder)

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
    local obj = self
    segmentBtn:SetScript("OnClick", function(self)
        obj.menu:ShowSessions(self)
    end)

    function segmentBtn:SetText(text)
        sessionIndicator:SetText(text)
    end

    return segmentBtn
end