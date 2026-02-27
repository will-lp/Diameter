local _, Diameter = ...

--[[
    Implements a pool pattern for tables.
    This is mostly used on Data.lua, since we make a lot of tables to
    normalize data form C_DamageMeter. It should be generic enough to 
    be used elsewhere, though.
]]

local Recycler = { pool = {} }

--[[
    Pull from pool or create new
]]
function Recycler:Acquire()
    
    return table.remove(self.pool) or {}
end

--[[
    Clear the tables/arrays that hold normalized data coming
    from C_DamageMeter, but not the array itself.
]]
function Recycler:ClearArray(targetArray)
    for i = #targetArray, 1, -1 do
        local child = table.remove(targetArray, i)
        -- 2. Put the CHILD into the pool
        self:Release(child)
    end
end

--[[
    After use, returns the table to the pool.
]]
function Recycler:Release(tbl)
    if not tbl then return end
    wipe(tbl)
    table.insert(self.pool, tbl)

end


Diameter.Recycler = Recycler