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
        DiameterDB = { Windows = {} }
    end
    
    DiameterDB.Windows = DiameterDB.Windows or {}
end


function Database:GetPresenters()
    return DiameterDB.Windows
end


function Database:IsEmpty()
    return next(DiameterDB.Windows) == nil
end


function Database:Get(id)
    DiameterDB.Windows[id] = DiameterDB.Windows[id] or {}
    return DiameterDB.Windows[id]
end


function Database:Remove(id)
    DiameterDB.Windows[id] = nil
end


Diameter.Database = Database