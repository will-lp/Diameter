
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