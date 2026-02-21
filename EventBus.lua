local addonName, Diameter = ...

--[[
    EventBus is a pub/sub pattern to decouple modules. 
]]

Diameter.EventBus = {}


local createEventTable = function (eventsNames)
    local events = {}
    for _, eventName in ipairs(eventsNames) do
        if events[eventName] then
            error("Duplicate event registered: " .. eventName)
        end
        events[eventName] = eventName
    end
    return events
end


local events = createEventTable({

    -- user navigated to a different page
    "PAGE_CHANGED",

    -- a combo of session/mode/sessionType changed. this name is awful.
    "CURRENT_CHANGED", 

    -- just the mode changed
    "MODE_CHANGED",

    -- just the session type changed (history or current or overall)
    "SESSION_TYPE_CHANGED",

    -- both sessionType and ID changed; user wants to look at an older fight
    "SESSION_TYPE_ID_CHANGED",

    -- When new data was loaded. Loop fires it and UI listens to it.
    "PAGE_DATA_LOADED",

    -- user clicked on data reset
    "DATA_RESET",

    -- new people joined or left the group
    "GROUP_CHANGED",

    -- user clicked the "Player Selection" toggle
    "PLAYER_SELECTION_MODE",

    -- used right at the start of the addon, modules will need to save a reference to mainFrame
    "ADDON_BOOTED"
})


Diameter.EventBus.Events = events


local listeners = {}

for evt, _ in pairs(events) do
    listeners[evt] = {}
end


local function validateEventExists(evt) 
    if not events[evt] then 
        error("Event does not exist: " .. tostring(evt))
    end
end


function Diameter.EventBus:Listen(evt, fn)
    validateEventExists(evt)
    table.insert(listeners[evt], fn)
end


function Diameter.EventBus:Fire(evt, data)
    validateEventExists(evt)

    local fireTo = listeners[evt]
    for _, fn in pairs(fireTo) do
        fn(data)
    end
end
