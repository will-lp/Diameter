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
    "PAGE_CHANGED",
    "CURRENT_CHANGED", -- this name is awful. it means a combo of session/mode/sessionType
    "MODE_CHANGED",
    "SESSION_TYPE_CHANGED",
    "SESSION_TYPE_ID_CHANGED",
    "PAGE_DATA_LOADED",
    "DATA_RESET"
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
