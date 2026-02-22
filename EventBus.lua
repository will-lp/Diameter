local _, Diameter = ...

--[[
    EventBus is a pub/sub pattern to decouple modules. 
    It is instance based just so we can create channels for instances
    to talk.
]]--


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

    -- I am not explaining those two, c'mon >:(
    "NEW_WINDOW",
    "CLOSE_WINDOW"
})


local function validateEventExists(evt) 
    if not events[evt] then 
        error("Event does not exist: " .. tostring(evt))
    end
end


local EventBus = { Events = events }
EventBus.__index = EventBus


function EventBus:New()
    local obj = setmetatable({}, self)
    obj.listeners = {}
    return obj
end


function EventBus:Listen(evt, fn, owner)
    validateEventExists(evt)
    self.listeners[evt] = self.listeners[evt] or {}
    if owner then
        self.listeners[evt][owner] = fn
    else
        table.insert(self.listeners[evt], fn)

    end
end


function EventBus:Fire(evt, data)
    validateEventExists(evt)
    if not self.listeners[evt] then return end

    for _, fn in pairs(self.listeners[evt]) do
        fn(data)
    end
end


function EventBus:Unregister(owner)
    for evt, _ in pairs(events) do
        if self.listeners[evt] then
            self.listeners[evt][owner] = nil
        end
    end
end

Diameter.EventBusClass = EventBus
Diameter.EventBus = EventBus:New()
