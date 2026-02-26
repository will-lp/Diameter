local _, Diameter = ...


Diameter.UI = Diameter.UI or {}


function Diameter.UI:CreateScrollEngine(mainFrame)
    -- We use a template to get a standard WoW scrollbar for free
    local scrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", mainFrame)
    --Diameter.Debug:Frame(scrollFrame)
    scrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 3, -24) -- to stay below header
    scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -4, 0)

    -- This is the 'Long Paper' that holds the bars
    local scrollChild = self:CreateScrollChild(scrollFrame)
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

    -- So we can go back up the navigation stack clicking anywhere in the scroll area
    scrollFrame:SetScript("OnMouseDown", function(frame, button)
        if button == "RightButton" then
            uiInstance.navigation:NavigateUp(frame.data)
        end
    end)

    return scrollFrame, scrollChild
end


function Diameter.UI:CreateScrollChild(scrollFrame)

    local scrollChild = CreateFrame("Frame", "$parentScrollChild", scrollFrame, "BackdropTemplate")

    -- Anchor the child flush to the scroll frame so there are no secret insets
    scrollChild:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
    scrollChild:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, 0)
    scrollChild:SetSize(scrollFrame:GetWidth() or 170, 1) -- updated dynamically by UpdateScrollChildHeight()
    scrollChild:SetBackdropColor(0, 0, 0, 0)

    scrollChild.Bars = {}

    return scrollChild
end


function Diameter.UI:ResetScrollPosition()

    if self.mainFrame and self.mainFrame.ScrollFrame then
        self:UpdateScrollChildHeight()
        --self.mainFrame.ScrollFrame:UpdateScrollChildRect()
        self.mainFrame.ScrollFrame:SetVerticalScroll(0)
    end
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