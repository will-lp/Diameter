local addonName, Diameter = ...

--[[
    This module provides the building of the User Interface for Diameter.
    It creates the main frame, header, scrollable area, and data bars.
    
    Ideally it should only handle UI-related tasks and not data manipulation.
]]

local EVT = Diameter.EventBus.Events

Diameter.UI = {
    -- Unholy + Riders of apocalypse made 40 Bars go boom. Probably should be dynamic.
    MaxBars = 60,
    step = 19,
    spacing = 1
}
Diameter.UI.__index = Diameter.UI


function Diameter.UI:New(id, eventChannel)
    local obj = setmetatable({}, self)

    obj.id = id
    obj.filledBars = 0
    obj.currentScrollPos = 0
    obj.eventChannel = eventChannel
    obj.navigation = Diameter.Navigation:New(eventChannel)
    obj.mainFrame = obj:Boot()

    --[[
        Here we listen for changes in the page content and set the vertical
        scroll accordingly. 
    ]]
    obj.eventChannel:Listen(EVT.PAGE_DATA_LOADED, function(dataArray)
        obj.filledBars = #dataArray
        local scrollFrame = obj.mainFrame.ScrollFrame
        local maxHeight = obj:CalculateMaxHeight(scrollFrame)
        if obj.currentScrollPos > maxHeight then obj.currentScrollPos = maxHeight end

        scrollFrame:SetVerticalScroll(obj.currentScrollPos)

    end)

    return obj
end


--[[
    Creates the mainFrame.

    @returns mainFrame
]]
function Diameter.UI:Boot()
    -- 1. Main Frame
    local mainFrame = CreateFrame("Frame", "DiameterMainFrame" .. self.id, UIParent, "BackdropTemplate")
    mainFrame:SetSize(280, 180)
    mainFrame:SetPoint("BOTTOMRIGHT")
    mainFrame:SetMovable(true)
    mainFrame:SetResizable(true)
    mainFrame:SetResizeBounds(150, 50, 600, 800)
    mainFrame:SetClampedToScreen(true)
    mainFrame:SetFrameStrata("LOW")

    -- Background
    mainFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = nil,
        tile = true, 
        tileSize = 16, 
        edgeSize = 16,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    
    mainFrame:SetBackdropColor(0, 0, 0, 0.7)

    -- 2. Header Bar and button
    self.Header = Diameter.UIHeader:New(mainFrame, self.id, self.eventChannel)

    local scrollFrame, scrollChild = self:CreateScrollEngine(mainFrame)

    -- Make the Header the handle for moving
    mainFrame:SetScript("OnMouseDown", function(self, button) 
        if button == "LeftButton" then self:StartMoving() end 
    end)
    mainFrame:SetScript("OnMouseUp", mainFrame.StopMovingOrSizing)
    
    -- 4. Resize Handle (Bottom Right)
    mainFrame.Resizer = CreateFrame("Button", nil, mainFrame)
    mainFrame.Resizer:SetSize(12, 12)
    mainFrame.Resizer:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 0, 0) -- Inset it slightly
    mainFrame.Resizer:SetFrameLevel(scrollFrame:GetFrameLevel() + 5) 
    mainFrame.Resizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    mainFrame.Resizer:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    
    mainFrame.Resizer:SetScript("OnMouseDown", function() mainFrame:StartSizing("BOTTOMRIGHT") end)
    mainFrame.Resizer:SetScript("OnMouseUp", function() mainFrame:StopMovingOrSizing() end)
    
    mainFrame:SetScript("OnSizeChanged", function(self, width, height)
        -- 1. Update the ScrollFrame width
        scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -4, 4)
        
        -- 2. Force the ScrollChild to match the new width.
        -- Will pull bars wider
        scrollChild:SetWidth(scrollFrame:GetWidth())
        
        -- 3. Trigger a refresh of the scroll logic
        -- I kinda wanna ditch this one
        scrollFrame:UpdateScrollChildRect()
    end)

    return mainFrame
end


function Diameter.UI:CalculateMaxHeight(frame) 
    local contentHeight = self.filledBars * (self.step + self.spacing)
    local windowHeight = frame:GetHeight()
    local manualMax = math.max(0, contentHeight - windowHeight)
    
    return manualMax
end


