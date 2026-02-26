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
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 1 }
    })
    Header:SetBackdropBorderColor(0, 0, 0, 1)
    Header:SetBackdropColor(0.2, 0.2, 0.2, 0.8)

    return Header
end

function Diameter.UIHeader:CreateHeaderText(Header)
    local HeaderText = Header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    HeaderText:SetPoint("LEFT", self.MenuBtn, "RIGHT", 5, 0)

    return HeaderText
end


function Diameter.UIHeader:ApplyHighlight(component)
    component:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
    
    local highlight = component:GetHighlightTexture()
    highlight:SetVertexColor(0.5, 0.5, 0.8, 0.2)
    highlight:SetPoint("TOPLEFT", component, "TOPLEFT", 1, -1)
    highlight:SetPoint("BOTTOMRIGHT", component, "BOTTOMRIGHT", -1, 1)
end


function Diameter.UIHeader:CreateMenuButton(Header)
    local pixel = 1 / self.mainFrame:GetEffectiveScale()

    local menuBtn = CreateFrame("Button", nil, Header, "BackdropTemplate")
    menuBtn:SetSize(18 * pixel, 18 * pixel)
    menuBtn:SetPoint("LEFT", Header, "LEFT", 2, 0)

    menuBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = pixel,
        insets = { left = pixel, right = pixel, top = pixel, bottom = pixel }
    })
    menuBtn:SetBackdropColor(0, 0, 0, 0.5)
    menuBtn:SetBackdropBorderColor(0, 0, 0, 0.7)

    self:ApplyHighlight(menuBtn)

    local icon = menuBtn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(16 * pixel, 16 * pixel) -- Slightly smaller to fit inside the border
    icon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
    icon:SetPoint("TOPLEFT", menuBtn, "TOPLEFT", pixel, -pixel)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    local obj = self
    menuBtn:SetScript("OnClick", function(self)
        obj.menu:ShowMenu(self, obj.id)
    end)

    return menuBtn
end


function Diameter.UIHeader:CreateSegmentButton(Header)

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
    segmentBtn:SetBackdropBorderColor(0, 0, 0, 0.7)

    local chevron = self:CreateChevron(segmentBtn)

    local sessionIndicator = segmentBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sessionIndicator:SetFont(sessionIndicator:GetFont(), 13, "OUTLINE")
    sessionIndicator:SetPoint("LEFT", chevron, "RIGHT", 1, 0)
    sessionIndicator:SetText("C")

    local obj = self
    segmentBtn:SetScript("OnClick", function(self)
        obj.menu:ShowSessions(self)
    end)

    function segmentBtn:SetText(text)
        sessionIndicator:SetText(text)
    end

    return segmentBtn
end


function Diameter.UIHeader:CreateChevron(segmentBtn)

    local GLOW_COLOR = CreateColor(0.6, 0.6, 1, 0.8)
    local ACTIVE_COLOR = CreateColor(1, 1, 1, 1)
    local DIM_COLOR = CreateColor(1, 1, 1, 0.8)

    local chevronGlow = segmentBtn:CreateTexture(nil, "ARTWORK")
    chevronGlow:SetSize(16, 16) -- 4px larger than the actual chevron
    chevronGlow:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    chevronGlow:SetVertexColor(GLOW_COLOR:GetRGBA())
    chevronGlow:SetBlendMode("ADD")
    chevronGlow:Hide() -- Hide it by default

    local chevron = segmentBtn:CreateTexture(nil, "OVERLAY")
    chevron:SetSize(12, 12)
    chevron:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    chevron:SetPoint("LEFT", segmentBtn, "LEFT", 3, 0) -- 4px padding from left edge
    chevron:SetVertexColor(DIM_COLOR:GetRGBA())
    chevronGlow:SetPoint("CENTER", chevron, "CENTER", 0, 0)

    segmentBtn:SetScript("OnEnter", function(self)
        chevronGlow:Show()
        chevron:SetVertexColor(ACTIVE_COLOR:GetRGBA()) 
    end)

    segmentBtn:SetScript("OnLeave", function(self)
        chevronGlow:Hide()
        chevron:SetVertexColor(DIM_COLOR:GetRGBA())
    end)
    return chevron
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