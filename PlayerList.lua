local addonName, Diameter = ...

local EVT = Diameter.EventBus.Events

Diameter.PlayerList = {}

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
        color = RAID_CLASS_COLORS[classFileName] or {r=0.5, g=0.5, b=0.5},
    }
end


function Diameter.PlayerList:LoopThroughPlayers()
    local numMembers = GetNumGroupMembers() -- "0" means solo
    local isRaid = IsInRaid()

    local players = {}

    table.insert(players, self:BuildPlayerData("player"))

    if numMembers <= 1 then 
        return players
    end
    
    local unitPrefix
    if isRaid == true then
        unitPrefix = "raid"
    else
        unitPrefix = "party"
    end

    for i = 1, numMembers - 1 do
        local unit = unitPrefix .. i
        table.insert(players, self:BuildPlayerData(unit))
    end

    return players
end