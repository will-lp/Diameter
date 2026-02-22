local addonName, Diameter = ...

--[[
    This module is the basis and the starter point for Diameter. 
    It contains the main loop, the current mode and session, and bridges the other 
    modules together.
]]--


local EVT = Diameter.EventBus.Events

-- This makes Diameter accessible to the Chat Frame and other files
_G["Diameter"] = Diameter

local presenters = {}

local function createNewPresenter(id)
    id = id or GetTime()
    local newPresenter = Diameter.Presenter:New(id)
    presenters[id] = newPresenter
end

Diameter.EventBus:Listen(EVT.NEW_WINDOW, function()
    createNewPresenter()
end)

Diameter.EventBus:Listen(EVT.CLOSE_WINDOW, function(id)
    presenters[id]:TearDown()
    presenters[id] = nil
end)


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

        Diameter.Database:Initialize()

        if Diameter.Database:IsEmpty() then
            createNewPresenter()
        else
            for id, _ in pairs(Diameter.Database:GetPresenters()) do
                createNewPresenter(id)
            end
        end

        self:UnregisterEvent("ADDON_LOADED")

        -- start the main loop
        C_Timer.NewTicker(0.3, function() 
            for _, presenter in pairs(presenters) do
                presenter:UpdateMeter()
            end
        end)

    end
end)
