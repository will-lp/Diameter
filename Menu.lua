local addonName, Diameter = ...

--[[
    This module provides the menu functionality for Diameter, allowing users to select modes and reset data.

    Should also provide segment selection in the future.
    Should also provide session type selection in the future.
    Should also provide settings in the future.
]]--

local M = Diameter.BlizzardDamageMeter.Mode

Diameter.Menu = {
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

function Diameter.Menu:ShowMenu(anchor)
    
    MenuUtil.CreateContextMenu(anchor, function(owner, rootDescription)
        rootDescription:CreateTitle("Select Mode")

        for _, value in ipairs(Diameter.Menu.MenuOrder) do
            local label = Diameter.Menu.Labels[value]
            rootDescription:CreateButton(label, function() 
                Diameter:SetMode(value)
                Diameter.Navigation:NavigateToGroup()
            end)
        end

        
        rootDescription:CreateDivider()
        
        rootDescription:CreateButton("Reset Data", function() 
            C_DamageMeter.ResetAllCombatSessions()
        end)
    end)
end


function Diameter.Menu:ShowSessions(anchor)
    MenuUtil.CreateContextMenu(anchor, function(owner, rootDescription)

        local sessions = Diameter.Data:GetSessions()

        rootDescription:CreateTitle("Segments")

        rootDescription:CreateButton("Current", function() 
            Diameter.SetSessionType(Diameter.BlizzardDamageMeter.SessionType.Current)
            Diameter.UIHeader:UpdateTypeAndSessionIndicator()
        end)

        rootDescription:CreateButton("Overall", function() 
            Diameter:SetSessionType( Diameter.BlizzardDamageMeter.SessionType.Overall )
            Diameter.UIHeader:UpdateTypeAndSessionIndicator()
        end)

        rootDescription:CreateDivider()

        -- @type name=string, sessionID=number
        for _, value in ipairs(sessions) do
            local label = value.sessionID .. ": " .. value.name
            rootDescription:CreateButton(label, function() 
                Diameter:SetSessionType(Diameter.BlizzardDamageMeter.SessionType.Expired)
                Diameter:SetSessionID(value.sessionID)
                Diameter.UIHeader:UpdateTypeAndSessionIndicator()
            end)
        end
    end)
end

