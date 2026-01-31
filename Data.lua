local addonName, Diameter = ...

Diameter.Data = {}

local ModeToField ={
    [BlizzardDamageMeter.Mode.DamageDone] = "totalAmount",
    [BlizzardDamageMeter.Mode.Dps] = "amountPerSecond",
    [BlizzardDamageMeter.Mode.HealingDone] = "totalAmount",
    [BlizzardDamageMeter.Mode.Hps] = "amountPerSecond",

    -- I am guessing all of these:
    [BlizzardDamageMeter.Mode.Absorbs] = "amountPerSecond",
    [BlizzardDamageMeter.Mode.Interrupts] = "totalAmount",
    [BlizzardDamageMeter.Mode.Dispels] = "totalAmount",
    [BlizzardDamageMeter.Mode.DamageTaken] = "amountPerSecond",
    [BlizzardDamageMeter.Mode.AvoidableDamageTaken] = "amountPerSecond",
}

Diameter.Data.ModeToField = ModeToField

function Diameter.Data:GetGroupMeter(sessionID, mode)

    local container = C_DamageMeter.GetCombatSessionFromID(sessionID, mode)
    
    local dataArray = {}

    if container and container.combatSources then
        local sources = container.combatSources
        
        dataArray.topValue = sources[1] and sources[1][ModeToField[Diameter.Current.Mode]]

        for i = 1, #sources do
            local data = {
                value = sources[i][ModeToField[Diameter.Current.Mode]],
                icon = sources[i].specIconID,
                name = sources[i].name,
                color = RAID_CLASS_COLORS[sources[i].classFilename] or {r=0.5, g=0.5, b=0.5},
                sourceGUID = sources[i].sourceGUID,
            }
            
            table.insert(dataArray, data)
        end
        
    end

    return dataArray
end


--[[
    Obtains and returns the spell meter data for a given targetGUID (player).

    @param targetGUID The GUID of the player whose spell meter is to be retrieved.
    @param mode The current mode of the damage meter (e.g., Damage Done, Healing Done).
    @param sessionID The ID of the combat session.
    @return A table containing spell meter data formatted for the UI.
]]--
function Diameter.Data:GetSpellMeter(targetGUID, mode, sessionID)
    
    local details = C_DamageMeter.GetCombatSessionSourceFromID(sessionID, mode, targetGUID)

    local dataArray = {}

    if details and details.combatSpells and #details.combatSpells > 0 then
        -- Transform Blizzard's spell details into a format UpdateBar understands
        local fieldName = ModeToField[Diameter.Current.Mode]
        
        dataArray.topValue = details.combatSpells[1][fieldName]

        for i, combatSpell in ipairs(details.combatSpells) do
            
            local data = {
                name = C_Spell.GetSpellName(combatSpell.spellID) or "Unknown",
                value = combatSpell[ModeToField[Diameter.Current.Mode]] or "",
                icon = C_Spell.GetSpellTexture(combatSpell.spellID),
                color = {r=0.5, g=0.5, b=0.5},
                sourceGUID = combatSpell.sourceGUID,
            }
            
            table.insert(dataArray, data)
        end
    end

    return dataArray
end