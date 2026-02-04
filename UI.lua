local addonName, Diameter = ...

--[[
    This module provides the building of the User Interface for Diameter.
    It creates the main frame, header, scrollable area, and data bars.
    
    Ideally it should only handle UI-related tasks and not data manipulation.
]]

Diameter.UI = {
    MaxBars = 40,
    step = 20
}

-- the height of each bar including spacing, used to calculate scroll height
local step = Diameter.UI.step
local spacing = 1

function Diameter.UI:Boot()
    -- 1. Main Frame
    local mainFrame = CreateFrame("Frame", "DiameterMainFrame", UIParent, "BackdropTemplate")
    mainFrame:SetSize(300, 150)
    mainFrame:SetPoint("BOTTOMRIGHT")
    mainFrame:SetMovable(true)
    mainFrame:SetResizable(true)
    mainFrame:SetResizeBounds(150, 50, 600, 800)
    mainFrame:SetClampedToScreen(true)

    -- Background
    mainFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    mainFrame:SetBackdropColor(0, 0, 0, 0.8)

    -- 2. Header Bar and button
    Diameter.UIHeader:CreateHeader(mainFrame)

    local scrollFrame, scrollChild = self:CreateScrollEngine(mainFrame)

    -- Make the Header the handle for moving
    mainFrame:SetScript("OnMouseDown", function(self, button) 
        if button == "LeftButton" then self:StartMoving() end 
    end)
    mainFrame:SetScript("OnMouseUp", mainFrame.StopMovingOrSizing)
    
    -- 4. Resize Handle (Bottom Right)
    mainFrame.Resizer = CreateFrame("Button", nil, mainFrame)
    mainFrame.Resizer:SetSize(16, 16)
    mainFrame.Resizer:SetPoint("BOTTOMRIGHT")
    mainFrame.Resizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    mainFrame.Resizer:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    
    mainFrame.Resizer:SetScript("OnMouseDown", function() mainFrame:StartSizing("BOTTOMRIGHT") end)
    mainFrame.Resizer:SetScript("OnMouseUp", function() mainFrame:StopMovingOrSizing() end)
    
    mainFrame:SetScript("OnSizeChanged", function(self, width, height)
        -- 1. Update the ScrollFrame width (minus room for the scrollbar)
        scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -25, 10) 
        
        -- 2. CRITICAL: Force the ScrollChild to match the new width
        -- This is what will pull your bars wider
        scrollChild:SetWidth(scrollFrame:GetWidth())
        
        -- 3. Optional: Trigger a refresh of the scroll logic
        scrollFrame:UpdateScrollChildRect()
    end)

    

    return mainFrame
end


function Diameter.UI:CreateScrollEngine(mainFrame)
    -- We use a template to get a standard WoW scrollbar for free
    local scrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", mainFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -30) -- -30 to stay below header
    scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -25, 10) -- -25 to leave room for the bar

    -- This is the 'Long Paper' that holds the bars
    local scrollChild = CreateFrame("Frame", "$parentScrollChild", scrollFrame, "BackdropTemplate")
    -- Anchor the child flush to the scroll frame so there are no secret insets
    scrollChild:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
    scrollChild:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, 0)
    scrollChild:SetHeight(1) -- updated dynamically by UpdateScrollChildHeight()
    scrollFrame:SetScrollChild(scrollChild)

    mainFrame.ScrollFrame = scrollFrame
    mainFrame.ScrollChild = scrollChild

    -- 5. Data Bar (Container for your current bar)
    scrollChild.Bars = self:CreateBars(scrollChild)

    -- 4. Mouse Wheel Support (Essential for UX)
    scrollFrame:EnableMouseWheel(true)

    -- So we can go back up the navigation stack clicking anywhere in the scroll area
    scrollFrame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            Diameter.Navigation:NavigateUp(self.data)
        end
    end)

    scrollChild:SetBackdropColor(0, 0, 0, 0)

    return scrollFrame, scrollChild
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
    local contentHeight = amountOfShownBars * step + math.max(0, amountOfShownBars - 1) * spacing


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
        bar:SetHeight(step)

        -- Handling breakdown on click and coming back
        bar:EnableMouse(true)
        bar:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                -- Tell the meter to navigate down into group data or details of the player
                Diameter.Navigation:NavigateDown(self.data)
            elseif button == "RightButton" then
                -- Right click goes "Back" to the group data or modes list
                Diameter.Navigation:NavigateUp(self.data)
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
            -- Note: Using TOPLEFT/TOPRIGHT ensures the bar stretches to the width of the scrollChild
            bar:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
            bar:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, 0)
        else
            bar:SetPoint("TOPLEFT", bars[i-1], "BOTTOMLEFT", 0, -spacing)
            bar:SetPoint("TOPRIGHT", bars[i-1], "BOTTOMRIGHT", 0, -spacing)
        end
        
        bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        bar:SetStatusBarColor(0.8, 0.2, 0.2)
        
        bar.nameText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        -- Adjust the Name Text so it doesn't overlap the icon
        bar.nameText:ClearAllPoints()
        bar.nameText:SetPoint("LEFT", bar.icon, "RIGHT", 4, 0)
        
        bar.valueText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        bar.valueText:SetPoint("RIGHT", -5, 0)

        -- some z-index level of debauchery
        bar:SetFrameLevel(scrollChild:GetFrameLevel() + 5)

        bar:Hide() -- Hide them until we have data
        bars[i] = bar
    end

    -- set a sensible initial height (MaxBars * step + (MaxBars - 1) * spacing)
    scrollChild:SetHeight(Diameter.UI.MaxBars * step + math.max(0, Diameter.UI.MaxBars - 1) * spacing)

    return bars
end