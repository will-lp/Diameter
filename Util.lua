
local _, Diameter = ...

Diameter.Util = {

    any = function (t, predicate)
        for _, v in pairs(t) do
            if predicate(v) then
                return true
            end
        end
        return false
    end,

    filter = function (t, predicate)
        local result = {}
        for _, v in pairs(t) do
            if predicate(v) then
                table.insert(result, v)
            end
        end
        return result
    end,

    max = function(list, predicate)
        local max = nil
        for key, value in pairs(list) do
            local currentValue = predicate(key, value)
            if max == nil or max < currentValue then
                max = currentValue
            end
        end
        return max
    end,

    count = function (t, predicate)
        local count = 0
        for _, v in pairs(t) do

            if not predicate or predicate(v) then
                count = count + 1
            end
        end
        return count
    end,

}