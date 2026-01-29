
local addonName, Diameter = ...

Diameter.Debug = {}

function Diameter.Debug:dumpTable(dumpTable)
    for k, v in pairs(dumpTable) do
        if (type(v) == "table") then
            print(k .. ":")
            Diameter.Debug.dumpTable(v)
        else    
            print(k, v)
        end
    end
end

