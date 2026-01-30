local addonName, Diameter = ...

Diameter.Data = {}

local ModeToField ={
    [BlizzardDamageMeter.Mode.DamageDone] = "totalAmount",
    [BlizzardDamageMeter.Mode.Dps] = "amountPerSecond",
    [BlizzardDamageMeter.Mode.HealingDone] = "totalHealing",
    [BlizzardDamageMeter.Mode.Hps] = "hps",
    [BlizzardDamageMeter.Mode.Absorbs] = "totalAbsorbs",
    [BlizzardDamageMeter.Mode.Interrupts] = "interrupts",
    [BlizzardDamageMeter.Mode.Dispels] = "dispels",
    [BlizzardDamageMeter.Mode.DamageTaken] = "totalDamageTaken",
    [BlizzardDamageMeter.Mode.AvoidableDamageTaken] = "avoidableDamageTaken",
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
                --breakdown = Diameter.Data:GetSpellMeter(sources[i].sourceGUID, mode),
            }
            
            table.insert(dataArray, data)
        end
        
    end

    print("-- dataArray --")
    Diameter.Debug:dump(dataArray)

    return dataArray
end

function Diameter.Data:GetSpellMeter(targetGUID, mode)
    print("-- GetSpellMeter for GUID: "..tostring(targetGUID).." Mode: "..tostring(mode).." --")
    local details = C_DamageMeter.GetCombatSessionSourceFromType(
        Diameter.Current.SessionType, 
        mode, 
        targetGUID)

    local dataArray = {}

    if details and details.combatSpells then
        -- Transform Blizzard's spell details into a format UpdateBar understands
        dataArray.topValue = details.combatSpells[1][ModeToField[Diameter.Current.Mode]]

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