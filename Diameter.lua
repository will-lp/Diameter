local addonName, Diameter = ...

--[[
    This module is the basis and the starter point for Diameter. 
    It contains the main loop, the current mode and session, and bridges the other 
    modules together.
]]--

Diameter.UI.mainFrame = Diameter.UI:Boot()

-- This makes Diameter accessible to the Chat Frame and other files
_G["Diameter"] = Diameter

Diameter.Current = {
    Mode = Diameter.BlizzardDamageMeter.Mode.DamageDone,
    SessionType = Diameter.BlizzardDamageMeter.SessionType.Current,
}

function Diameter:RefreshUI()
    Diameter.Loop:UpdateMeter(Diameter.UI.mainFrame)
    Diameter.UI:ResetScrollPosition()
end

function Diameter:SetMode(value)
    local label = Diameter.Menu.Labels[value]
    Diameter.UI.mainFrame.HeaderText:SetText("Diameter: " .. label)
    Diameter.Current.Mode = value
end


-- Diameter's "Main()": Initial operations needed for the addon to run properly.
(function() 
    
    Diameter.UI.mainFrame.MenuBtn:SetScript("OnClick", function(self)
        Diameter.Menu:ShowMenu(self)
    end)

    -- start the main loop
    C_Timer.NewTicker(0.5, function() 
        Diameter.Loop:UpdateMeter(Diameter.UI.mainFrame) 
    end)

    -- this is needed to properly set the scroll child height initially,
    -- otherwise we can scroll the child frame while it has no content.
    Diameter.UI:UpdateScrollChildHeight()

    -- this is needed to boot the UI, or sometimes it will show a black frame, 
    -- even though there is data in blizzard's dps meter.
    Diameter:RefreshUI()

end)()