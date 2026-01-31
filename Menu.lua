local addonName, Diameter = ...

local M = BlizzardDamageMeter.Mode

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