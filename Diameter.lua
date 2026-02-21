local addonName, Diameter = ...

--[[
    This module is the basis and the starter point for Diameter. 
    It contains the main loop, the current mode and session, and bridges the other 
    modules together.
]]--

local EVT = Diameter.EventBus.Events

-- This makes Diameter accessible to the Chat Frame and other files
_G["Diameter"] = Diameter


-- Diameter's "Main()": Initial operations needed for the addon to run properly.

-- we use this Frame just to listen to events
Diameter.Anchor = CreateFrame("Frame")
Diameter.Anchor:RegisterEvent("GROUP_ROSTER_UPDATE")
Diameter.Anchor:RegisterEvent("PLAYER_ENTERING_WORLD")
Diameter.Anchor:RegisterEvent("ADDON_LOADED")

Diameter.Anchor:SetScript("OnEvent", function(self, event, loadedAddon)
    if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" then
        Diameter.EventBus:Fire(EVT.GROUP_CHANGED)
    elseif event == "ADDON_LOADED" and loadedAddon == addonName then

        -- 1. Initialize DB if it doesn't exist
        -- to inspec the database in game:
        -- /run DevTools_Dump(DiameterDB)
        DiameterDB = DiameterDB or {}

        local presenters = {}

        if #DiameterDB == 0 then
            table.insert(presenters, Diameter.Presenter:New(1))
        else
            for id, _ in ipairs(DiameterDB) do
                table.insert(presenters, Diameter.Presenter:New(id))
            end
        end

        
        self:UnregisterEvent("ADDON_LOADED")

        -- start the main loop
        C_Timer.NewTicker(0.3, function() 
            for _, presenter in ipairs(presenters) do
                presenter:UpdateMeter()
            end
        end)

    end
end)
