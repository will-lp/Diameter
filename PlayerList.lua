local addonName, Diameter = ...

local EVT = Diameter.EventBus.Events

Diameter.PlayerList = {}

local color = Diameter.Color

function Diameter.PlayerList:GetPlayerList()
    
    local players = self:LoopThroughPlayers()
    players.topValue = 1
    return players
end


function Diameter.PlayerList:BuildPlayerData(unit)
    local _, classFileName = UnitClass(unit)
    return {
        unit = unit,
        sourceGUID = UnitGUID(unit),
        name = UnitName(unit),
        classFileName = classFileName,
        value = 1,
        icon = "classicon-" .. string.lower(classFileName),
        color = RAID_CLASS_COLORS[classFileName] or color.Gray,
    }
end


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