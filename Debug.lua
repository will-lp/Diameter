
local _, Diameter = ...

local Debug = {}

function Debug:dump(val, indent)
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

function Debug:Frame(frame, color)
    
    local r, g, b = unpack(color or {1, 0, 0}) -- Default Red
    
    local line = frame:CreateTexture(nil, "OVERLAY")
    line:SetAllPoints(frame)
    line:SetColorTexture(r, g, b, 0.3) -- 30% alpha so you can see through it
    
    -- Add a bright border
    local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    border:SetAllPoints(frame)
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 2,
    })
    border:SetBackdropBorderColor(r, g, b, 1)
end


Diameter.Debug = Debug