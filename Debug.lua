
local addonName, Diameter = ...

Diameter.Debug = {}

function Diameter.Debug:dumpTable(dumpTable, indent)
    indent = indent or 0
    local spaces = string.rep("  ", indent)
    print(spaces .. "-------------")
    for k, v in pairs(dumpTable) do
        if (type(v) == "table") then
            print(k .. ":")
            Diameter.Debug.dumpTable(v, indent + 2)
        else    
            print(k, v)
        end
    end
end

