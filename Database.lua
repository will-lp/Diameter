local _, Diameter = ...

--[[
    An abstraction for database handling.
    An ID may or may not be informed in New()

    to inspec the database in game:
    /run DevTools_Dump(DiameterDB)

    to clear the DB in game
    /run DiameterDB = {}; ReloadUI()
]]--

local Database = {}
Database.__index = Database


function Database:Initialize()
    DiameterDB = DiameterDB or {}

    -- wiping legacy v1.x data
    if DiameterDB.Mode or DiameterDB.SessionType then
        DiameterDB = {}
    end

    -- wiping legacy v2.0 data with account-wide keys
    if DiameterDB.Windows then
        DiameterDB.Windows = nil
    end

    if not DiameterDB.Profiles then
        DiameterDB.Profiles = {}
    end

    DiameterDB.DBVersion = 3
    
end


function Database:GetProfile()
    local guid = UnitGUID("player")
    if not DiameterDB.Profiles[guid] then
        DiameterDB.Profiles[guid] = { Windows = {} }
    end

    return DiameterDB.Profiles[guid]
end

function Database:GetPresenters()
    return self:GetProfile().Windows
end


function Database:IsEmpty()
    return next(self:GetProfile().Windows) == nil
end


function Database:Get(id)
    self:GetProfile().Windows[id] = self:GetProfile().Windows[id] or {}
    return self:GetProfile().Windows[id]
end


local maxId

function Database:GetMaxId()

    if not maxId then
        maxId = Diameter.Util.max(self:GetPresenters(), function(key, _) 
            return key end
        ) or 0
    end

    maxId = maxId + 1
    return maxId
end

function Database:Remove(id)
    self:GetProfile().Windows[id] = nil
end


Diameter.Database = Database