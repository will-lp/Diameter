local _, Diameter = ...

Diameter.Recycler = {}
local pool = {}

function Diameter.Recycler:Acquire()
    -- Pull from pool or create new
    return table.remove(pool) or {}
end

-- Add this to Diameter.Recycler
function Diameter.Recycler:ClearArray(targetArray)
    -- 1. Take every 'data' table OUT of the array
    for i = #targetArray, 1, -1 do
        local child = table.remove(targetArray, i)
        -- 2. Put the CHILD into the pool
        self:Release(child)
    end
    -- 3. The targetArray is now empty and ready for its next use!
    -- We do NOT wipe(targetArray) here because we want to keep 
    -- its identity as our permanent data container.
end

function Diameter.Recycler:Release(tbl)
    if not tbl then return end
    wipe(tbl)
    table.insert(pool, tbl)

end
