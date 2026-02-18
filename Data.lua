local addonName, Diameter = ...

--[[
    This module is responsible for obtaining and formatting data from Blizzard's Damage Meter API
    into a format that Diameter's UI can utilize.

    It provides functions to retrieve group and spell meter data based on the current mode and session.

    There are the functions available on C_DamageMeter:

    GetCombatSessionFromType
    ResetAllCombatSessions
    GetCombatSessionFromID
    GetAvailableCombatSessions
    GetCombatSessionSourceFromID
    IsDamageMeterAvailable
    GetCombatSessionSourceFromType
]]--

Diameter.Data = {}

local BDM = Diameter.BlizzardDamageMeter

local ModeToField ={
    [BDM.Mode.DamageDone] = "totalAmount",
    [BDM.Mode.Dps] = "amountPerSecond",
    [BDM.Mode.HealingDone] = "totalAmount",
    [BDM.Mode.Hps] = "amountPerSecond",

    -- I am guessing all of these:
    [BDM.Mode.Absorbs] = "amountPerSecond",
    [BDM.Mode.Interrupts] = "totalAmount",
    [BDM.Mode.Dispels] = "totalAmount",
    [BDM.Mode.DamageTaken] = "amountPerSecond",
    [BDM.Mode.AvoidableDamageTaken] = "amountPerSecond",
}

Diameter.Data.ModeToField = ModeToField


--[[
    Returns the group meter; the data with the player's names and their
    dps, but no details.
    
    @return dataArray in a format Loop can understand.
]]--
function Diameter.Data:GetGroupMeter(sessionID, mode, sessionType)

    local SessionType = Diameter.BlizzardDamageMeter.SessionType
    local container

    if sessionType == SessionType.Overall or sessionType == SessionType.Current then
        container = C_DamageMeter.GetCombatSessionFromType(sessionType, mode) 
    else
        container = C_DamageMeter.GetCombatSessionFromID(sessionID, mode)
    end
    
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
                sourceCreatureID = sources[i].sourceCreatureID
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
function Diameter.Data:GetSpellMeter(targetGUID, mode, sessionID, sessionType, sourceCreatureID)
    
    local SessionType = Diameter.BlizzardDamageMeter.SessionType
    local details

    if sessionType == SessionType.Overall or sessionType == SessionType.Current then
        details = C_DamageMeter.GetCombatSessionSourceFromType(sessionType, mode, targetGUID, sourceCreatureID)
    else 
        details = C_DamageMeter.GetCombatSessionSourceFromID(sessionID, mode, targetGUID, sourceCreatureID)
    end

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


--[[
    Returns the available combat sessions.

    @return @type name=string, sessionID=number
]]--
function Diameter.Data:GetSessions()
    local sessions = C_DamageMeter.GetAvailableCombatSessions()

    return sessions
end