local _, Diameter = ...

--[[
    Contains the logic to create a list of players based on current group.
    The data that comes from C_DamageMeter has `GUID` and `name` as 
    secretvalues, so they cannot be passed to C_DamageMeter meter again to 
    obtain their breakdown. The "workaround" is working with a second list 
    of players based off the group itself. It is a bit clunky because a click
    on a toggle is needed, but it works.
]]

local EVT = Diameter.EventBus.Events

Diameter.PlayerList = {}

local color = Diameter.Color

function Diameter.PlayerList:GetPlayerList()
    
    local players = self:LoopThroughPlayers()
    players.topValue = 1
    return players
end


--[[
    Builds a table with the player data based off the tag/unit. 
    For example: "player" or "party2" or "raid17".

    @returns player data object: {
        unit, sourceGUID, name, classFileName, value, icon, color
    }
]]
function Diameter.PlayerList:BuildPlayerData(unit)
    local _, classFileName = UnitClass(unit)

    local safeClass = classFileName or "UNKNOWN"
    local name = UnitName(unit) or "Unknown"

    return {
        unit = unit,
        sourceGUID = UnitGUID(unit),
        name = UnitName(unit),
        classFileName = safeClass,
        value = 1,
        icon = "classicon-" .. string.lower(safeClass),
        color = Diameter.ClassColors[safeClass] or color.Gray,
    }
end


--[[
    Build a list based off the players in the group.

    If we are solo, we only use the unit "player".

    If we are in a PARTY group, then we need "player" plus a number
    of "party#", like "party1" to "party4" if in a dungeon.

    If we are in a raid, then we don't add "player", we will
    only iterate through "raid#", as we are assigned a "raid#" for
    ourselves.
]]
function Diameter.PlayerList:LoopThroughPlayers()
    local numMembers = GetNumGroupMembers() -- "0" means solo

    local players = {}

    if IsInRaid() then
        for i = 1, numMembers do
            local unit = "raid" .. i
            table.insert(players, self:BuildPlayerData(unit))
        end
    else
        table.insert(players, self:BuildPlayerData("player"))

        for i = 1, numMembers - 1 do
            local unit = "party" .. i
            table.insert(players, self:BuildPlayerData(unit))
        end
    end

    return players
end