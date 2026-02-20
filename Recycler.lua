local _, Diameter = ...

--[[
    Implements a pool pattern for tables.
    This is mostly used on Data.lua, since we make a lot of tables to
    normalize data form C_DamageMeter. It should be generic enough to 
    be used elsewhere, though.
]]

Diameter.Recycler = {}
local pool = {}

--[[
    Pull from pool or create new
]]
function Diameter.Recycler:Acquire()
    
    return table.remove(pool) or {}
end

--[[
    Clear the tables/arrays that hold normalized data coming
    from C_DamageMeter, but not the array itself.
]]
function Diameter.Recycler:ClearArray(targetArray)
    for i = #targetArray, 1, -1 do
        local child = table.remove(targetArray, i)
        -- 2. Put the CHILD into the pool
        self:Release(child)
    end
end

--[[
    After use, returns the table to the pool.
]]
function Diameter.Recycler:Release(tbl)
    if not tbl then return end
    wipe(tbl)
    table.insert(pool, tbl)

end
