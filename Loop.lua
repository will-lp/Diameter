
local addonName, Diameter = ...

Diameter.Loop = {}


-- 4. The Update Function
-- @param f = CreateFrame
function Diameter.Loop:UpdateMeter(frame)
    -- Get the most recent combat session
    print("frame", frame)
    local sessions = C_DamageMeter.GetAvailableCombatSessions()
    if #sessions == 0 then return end
    
    local sessionID = sessions[#sessions].sessionID
    local container = C_DamageMeter.GetCombatSessionFromID(sessionID, BlizzardDamageMeter.Type.DamageDone)
    
    if container and container.combatSources and #container.combatSources > 0 then
        -- Blizzard sorts these for us. Index 1 is the top damage.
        local topSource = container.combatSources[1]

        -- NO TOSTRING, NO MATH. 
        -- We pass the Secret Values directly to the UI.
        frame.nameText:SetText(topSource.name)
        frame.valueText:SetText(topSource.totalAmount)

        -- Set the bar to full since it's the top source (Max / Max = 1)
        -- In a multi-bar setup, you'd use topSource.totalAmount as the Max for everyone.
        frame.bar:SetMinMaxValues(0, topSource.totalAmount)
        frame.bar:SetValue(topSource.totalAmount)
    end
end


