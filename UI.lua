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


function Diameter.UI:CreateScrollEngine(mainFrame)
    -- We use a template to get a standard WoW scrollbar for free
    local scrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", mainFrame)
    --Diameter.Debug:Frame(scrollFrame)
    scrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 3, -24) -- to stay below header
    scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -4, 0)

    -- This is the 'Long Paper' that holds the bars
    local scrollChild = CreateFrame("Frame", "$parentScrollChild", scrollFrame, "BackdropTemplate")

    

    -- Anchor the child flush to the scroll frame so there are no secret insets
    scrollChild:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
    scrollChild:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, 0)
    scrollChild:SetSize(scrollFrame:GetWidth() or 170, 1) -- updated dynamically by UpdateScrollChildHeight()
    scrollFrame:SetScrollChild(scrollChild)

    local uiInstance = self

    scrollFrame:SetScript("OnMouseWheel", function(frame, delta)
        
        -- 1. calculate the max height based on dataArray
        local manualMax = uiInstance:CalculateMaxHeight(frame)

        -- 2. modify a local variable and not a "Secret" value
        if delta > 0 then
            uiInstance.currentScrollPos = uiInstance.currentScrollPos - uiInstance.step
        else
            uiInstance.currentScrollPos = uiInstance.currentScrollPos + uiInstance.step
        end

        -- 3. upper and lower limits
        if uiInstance.currentScrollPos < 0 then uiInstance.currentScrollPos = 0 end
        if uiInstance.currentScrollPos > manualMax then uiInstance.currentScrollPos = manualMax end
        
        -- 4. set the height with our own variable
        -- Blizzard allows SetVerticalScroll with a tainted number, 
        -- they just won't let you perform math ON a secret value.
        frame:SetVerticalScroll(uiInstance.currentScrollPos)
    end)

    mainFrame.ScrollFrame = scrollFrame
    mainFrame.ScrollChild = scrollChild
    
    -- 4. Mouse Wheel Support
    scrollFrame:EnableMouseWheel(true)

    -- 5. Data Bars
    scrollChild.Bars = self:CreateBars(scrollChild)

    -- So we can go back up the navigation stack clicking anywhere in the scroll area
    scrollFrame:SetScript("OnMouseDown", function(frame, button)
        if button == "RightButton" then
            uiInstance.navigation:NavigateUp(frame.data)
        end
    end)

    scrollChild:SetBackdropColor(0, 0, 0, 0)

    return scrollFrame, scrollChild
end


function Diameter.UI:CalculateMaxHeight(frame) 
    local contentHeight = self.filledBars * (self.step + self.spacing)
    local windowHeight = frame:GetHeight()
    local manualMax = math.max(0, contentHeight - windowHeight)
    
    return manualMax
end



--[[
    Calculates and returns the height of the scroll child based on shown bars.
    Also updates the scroll child's height to ensure proper scrolling behavior.

    If there are no shown bars, the height will be set to the size of the screen,
    this way, we prevent the error that sometimes, combat will start, the data
    will be fetched, but the scroll child height will remain 0, causing a black frame.
]]
function Diameter.UI:UpdateScrollChildHeight()

    local scrollChild = self.mainFrame.ScrollChild

    -- total content height based on shown bars
    local amountOfShownBars = Diameter.Util.count(scrollChild.Bars, function(bar)
        return bar:IsShown()
    end)

    -- account for spacing between bars so the calculated range matches GetVerticalScrollRange()
    local contentHeight = amountOfShownBars * self.step + math.max(0, amountOfShownBars - 1) * self.spacing


    if not contentHeight or contentHeight == 0 then
        -- This is needed when the game just started (or after /reload) and there's 
        -- no meter data. Then combat starts, and the UI will stay black forever,
        -- unless there's some interaction like a click or scrolling.
        contentHeight = self.mainFrame.ScrollFrame:GetHeight()
    end

    -- update scroll range dynamically
    scrollChild:SetHeight(contentHeight)

    return contentHeight

end



function Diameter.UI:ResetScrollPosition()

    if self.mainFrame and self.mainFrame.ScrollFrame then
        self:UpdateScrollChildHeight()
        --self.mainFrame.ScrollFrame:UpdateScrollChildRect()
        self.mainFrame.ScrollFrame:SetVerticalScroll(0)
    end
end



function Diameter.UI:CreateBars(scrollChild)
    local bars = {}
    
    -- Creating bars
    for i = 1, Diameter.UI.MaxBars do
        local bar = CreateFrame("StatusBar", nil, scrollChild)
        bar:SetHeight(self.step)

        local uiInstance = self
        -- Handling breakdown on click and coming back
        bar:EnableMouse(true)
        bar:SetScript("OnMouseDown", function(self, button)
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
        bar.icon:SetSize(self.step-2, self.step-2) -- Slightly smaller than the bar height
        bar.icon:SetPoint("LEFT", bar, "LEFT", 1, 0)

        -- This crops the outer 7% of the icon to remove the built-in border
        bar.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        -- Stack them vertically
        if i == 1 then
            -- Note: Using TOPLEFT/TOPRIGHT ensures the bar stretches to the width of the scrollChild
            bar:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
            bar:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, 0)
        else
            bar:SetPoint("TOPLEFT", bars[i-1], "BOTTOMLEFT", 0, -self.spacing)
            bar:SetPoint("TOPRIGHT", bars[i-1], "BOTTOMRIGHT", 0, -self.spacing)
        end
        
        bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")

        -- this is the starting point, the "bottle with a top light". I don't love it
        -- Diameter.UI:AddStatusBarGlow(bar)

        -- this adds a very sweet gradient
        Diameter.UI:AddVerticalGradient(bar)

        -- this adds a white line at the right edge. I don't hate it.
        Diameter.UI:AddSparkLine(bar)


        bar:SetStatusBarColor(0.8, 0.2, 0.2)
        
        bar.nameText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        -- Adjust the Name Text so it doesn't overlap the icon
        bar.nameText:ClearAllPoints()
        bar.nameText:SetPoint("LEFT", bar.icon, "RIGHT", 4, 0)
        
        bar.valueText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        bar.valueText:SetPoint("RIGHT", -5, 0)


        bar:Hide() -- Hide them until we have data
        bars[i] = bar
    end

    -- set a sensible initial height (MaxBars * step + (MaxBars - 1) * spacing)
    scrollChild:SetHeight(Diameter.UI.MaxBars * self.step + math.max(0, Diameter.UI.MaxBars - 1) * self.spacing)

    return bars
end


function Diameter.UI:AddVerticalGradient(bar)
    local barTexture = bar:GetStatusBarTexture()

    bar.overlay = bar:CreateTexture(nil, "ARTWORK")
    -- Anchor the gradient specifically to the moving colored bar
    bar.overlay:SetPoint("TOPLEFT", barTexture, "TOPLEFT")
    bar.overlay:SetPoint("BOTTOMRIGHT", barTexture, "BOTTOMRIGHT")

    bar.overlay:SetTexture("Interface\\Buttons\\WHITE8X8")
    -- This makes the gradient only exist where the color is!
    bar.overlay:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0.15), CreateColor(0, 0, 0, 0.15))
end


function Diameter.UI:AddSparkLine(bar)
    -- Create the Leading Edge (The "Spark")
    bar.spark = bar:CreateTexture(nil, "OVERLAY")
    bar.spark:SetWidth(1) -- The 1-pixel magic
    bar.spark:SetTexture("Interface\\Buttons\\WHITE8X8")
    bar.spark:SetVertexColor(1, 1, 1, 0.5) -- Semi-transparent white

    -- Anchor it to the leading edge of the bar
    bar.spark:SetPoint("TOP", barTexture, "TOPRIGHT", 0, 0)
    bar.spark:SetPoint("BOTTOM", barTexture, "BOTTOMRIGHT", 0, 0)

end


function Diameter.UI:AddStatusBarGlow(bar)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar-Glow")
end