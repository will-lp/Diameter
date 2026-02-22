local addonName, Diameter = ...

--[[
    This module provides the menu functionality for Diameter, allowing users to select modes and reset data.

    Should also provide segment selection in the future.
    Should also provide session type selection in the future.
    Should also provide settings in the future.
]]--

local M = Diameter.BlizzardDamageMeter.Mode

local EVT = Diameter.EventBus.Events

local Menu = {
    Labels = {
        [M.DamageDone] = "Damage Done",
        [M.Dps] = "DPS",
        [M.HealingDone] = "Healing Done",
        [M.Hps] = "HPS",
        [M.Absorbs] = "Absorbs",
        [M.Interrupts] = "Interrupts",
        [M.Dispels] = "Dispels",
        [M.DamageTaken] = "Damage Taken",
        [M.AvoidableDamageTaken] = "Avoidable Damage Taken",
    },
    MenuOrder = {
        M.DamageDone,
        M.Dps,
        M.HealingDone,
        M.Hps,
        M.Absorbs,
        M.Interrupts,
        M.Dispels,
        M.DamageTaken,
        M.AvoidableDamageTaken,
    }
}
Menu.__index = Menu


local numberOfWindows = 0

Diameter.EventBus:Listen(EVT.NEW_WINDOW, function()
    numberOfWindows = numberOfWindows + 1
end)

Diameter.EventBus:Listen(EVT.CLOSE_WINDOW, function()
    numberOfWindows = numberOfWindows - 1
end)


function Menu:New(eventBus) 
    local obj = setmetatable({}, self)
    obj.eventBus = eventBus
    return obj
end


function Menu:ShowMenu(anchor, id)
    
    MenuUtil.CreateContextMenu(anchor, function(owner, rootDescription)
        rootDescription:CreateTitle("Select Mode")

        for _, value in ipairs(Diameter.Menu.MenuOrder) do
            local label = Diameter.Menu.Labels[value]
            rootDescription:CreateButton(label, function() 
                self.eventBus:Fire(EVT.MODE_CHANGED, value)
            end)
        end

        rootDescription:CreateDivider()
        
        rootDescription:CreateButton("Reset Data", function() 
            C_DamageMeter.ResetAllCombatSessions()
            Diameter.EventBus:Fire(EVT.DATA_RESET, anchor)
        end)

        rootDescription:CreateDivider()

        rootDescription:CreateButton("New Window", function() 
            Diameter.EventBus:Fire(EVT.NEW_WINDOW)
        end)

        rootDescription:CreateDivider()

        local closeWindowBtn = rootDescription:CreateButton("Close Window", function() 
            Diameter.EventBus:Fire(EVT.CLOSE_WINDOW, id)
        end)

        if numberOfWindows == 1 then
            closeWindowBtn:SetEnabled(false)
        end

    end)
end


function Menu:ShowSessions(anchor)
    MenuUtil.CreateContextMenu(anchor, function(owner, rootDescription)

        local sessions = Diameter.Data:GetSessions()

        rootDescription:CreateTitle("Segments")

        rootDescription:CreateButton("Current", function() 
            self.eventBus:Fire(EVT.SESSION_TYPE_CHANGED, Diameter.BlizzardDamageMeter.SessionType.Current)
        end)

        rootDescription:CreateButton("Overall", function() 
            self.eventBus:Fire(EVT.SESSION_TYPE_CHANGED, Diameter.BlizzardDamageMeter.SessionType.Overall)
        end)

        rootDescription:CreateDivider()

        -- @type name=string, sessionID=number
        for _, value in ipairs(sessions) do
            local label = value.sessionID .. ": " .. value.name
            rootDescription:CreateButton(label, function() 
                self.eventBus:Fire(EVT.SESSION_TYPE_ID_CHANGED, {
                    SessionType = Diameter.BlizzardDamageMeter.SessionType.Expired,
                    SessionID = value.sessionID
                })
            end)
        end
    end)
end


Diameter.Menu = Menu