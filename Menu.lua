local addonName, Diameter = ...

local M = BlizzardDamageMeter.Mode

local Labels = {
    [M.DamageDone] = "Damage Done",
    [M.Dps] = "DPS",
    [M.HealingDone] = "Healing Done",
    [M.Hps] = "HPS",
    [M.Absorbs] = "Absorbs",
    [M.Interrupts] = "Interrupts",
    [M.Dispels] = "Dispels",
    [M.DamageTaken] = "Damage Taken",
    [M.AvoidableDamageTaken] = "Avoidable Damage Taken",
}

local MenuOrder = {
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

function Diameter:ShowMenu(anchor)
    
    MenuUtil.CreateContextMenu(anchor, function(owner, rootDescription)
        rootDescription:CreateTitle("Select Mode")

        for _, value in ipairs(MenuOrder) do
            local label = Labels[value]
            rootDescription:CreateButton(label, function() 
                Diameter.UI.mainFrame.HeaderText:SetText("Diameter: " .. label)
                Diameter.Current.Mode = value
            end)
        end

        
        rootDescription:CreateDivider()
        
        rootDescription:CreateButton("Reset Data", function() 
            C_DamageMeter.ResetAllCombatSessions()
        end)
    end)
end