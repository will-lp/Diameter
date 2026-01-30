
local addonName, Diameter = ...

Diameter.Debug = {}

function Diameter.Debug:dump(val, indent)
    indent = indent or 0
    local spaces = string.rep("  ", indent)

    if type(val) ~= "table" then
        print(spaces, val, type(val))
        return
    end

    print(spaces .. "-------------")

    -- Decide how to iterate
    local isArray = (#val > 0)

    if isArray then
        for i, v in ipairs(val) do
            if type(v) == "table" then
                print(spaces .. "[" .. i .. "]:")
                self:dump(v, indent + 2)
            else
                print(spaces .. "[" .. i .. "]", v)
            end
        end
    else
        for k, v in pairs(val) do
            if type(v) == "table" then
                print(spaces .. k .. ":")
                self:dump(v, indent + 2)
            else
                print(spaces .. k, v)
            end
        end
    end
end
