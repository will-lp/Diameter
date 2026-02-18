local addonName, Diameter = ...

--[[
    This module is the basis and the starter point for Diameter. 
    It contains the main loop, the current mode and session, and bridges the other 
    modules together.
]]--

Diameter.UI.mainFrame = Diameter.UI:Boot()

local EVT = Diameter.EventBus.Events

-- This makes Diameter accessible to the Chat Frame and other files
_G["Diameter"] = Diameter


-- this is the options loaded when the addon is loaded on the very first time.
Diameter.Current = {
    Mode = Diameter.BlizzardDamageMeter.Mode.DamageDone,
    SessionType = Diameter.BlizzardDamageMeter.SessionType.Current,
    SessionID = nil
}


Diameter.EventBus:Listen(EVT.MODE_CHANGED, function (mode)
    local label = Diameter.Menu.Labels[mode]
    Diameter.UI.mainFrame.HeaderText:SetText("Diameter: " .. label)
    Diameter.Current.Mode = mode
    DiameterDB.LastMode = mode
end)

Diameter.EventBus:Listen(EVT.SESSION_TYPE_CHANGED, function(sessionType)
    Diameter.Current.SessionType = sessionType
    DiameterDB.LastSessionType = sessionType
end)

Diameter.EventBus:Listen(EVT.SESSION_TYPE_ID_CHANGED, function(data)
    Diameter.Current.SessionType = data.SessionType
    Diameter.Current.SessionID = data.SessionID
    DiameterDB.LastSessionType = data.SessionType
    DiameterDB.LastSessionID = data.SessionID
end)

Diameter.EventBus:Listen(EVT.DATA_RESET, function(_)
    local data = {
        SessionType = Diameter.BlizzardDamageMeter.SessionType.Current,
        SessionID = nil
    }
    Diameter.EventBus:Fire(EVT.SESSION_TYPE_ID_CHANGED, data)
end)

function Diameter:RefreshUI()
    Diameter.Loop:UpdateMeter(Diameter.UI.mainFrame)
    Diameter.UI:ResetScrollPosition()
end



-- Diameter's "Main()": Initial operations needed for the addon to run properly.
(function() 
    
    local bootFrame = CreateFrame("Frame")
    bootFrame:RegisterEvent("ADDON_LOADED")
    bootFrame:SetScript("OnEvent", function(self, event, loadedAddon)
        if loadedAddon == addonName then
            -- 1. Initialize DB if it doesn't exist
            DiameterDB = DiameterDB or {}

            -- 2. Load saved Mode (default to DamageDone if nil)
            Diameter.Current = {
                Mode = DiameterDB.LastMode or Diameter.BlizzardDamageMeter.Mode.DamageDone,
                SessionType = DiameterDB.LastSessionType or Diameter.BlizzardDamageMeter.SessionType.Current,
                SessionID = DiameterDB.LastSessionID
            }

            Diameter.EventBus:Fire(EVT.CURRENT_CHANGED, Diameter.Current)
            Diameter.EventBus:Fire(EVT.MODE_CHANGED, Diameter.Current.Mode)
            
            -- Now that data is loaded, refresh everything
            Diameter:RefreshUI()
            self:UnregisterEvent("ADDON_LOADED")
        end
    end)

    -- start the main loop
    C_Timer.NewTicker(0.3, function() 
        Diameter.Loop:UpdateMeter(Diameter.UI.mainFrame) 
    end)

    -- this is needed to properly set the scroll child height initially,
    -- otherwise we can scroll the child frame while it has no content.
    Diameter.UI:UpdateScrollChildHeight()

    -- this is needed to boot the UI, or sometimes it will show a black frame, 
    -- even though there is data in blizzard's dps meter.
    Diameter:RefreshUI()

end)()