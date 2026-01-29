
local addonName, Diameter = ...

Diameter.Loop = {}


-- 4. The Update Function
-- @param f = CreateFrame
function Diameter.Loop:UpdateMeter(frame)
    local sessions = C_DamageMeter.GetAvailableCombatSessions()
    if #sessions == 0 then return end
    
    local sessionID = sessions[#sessions].sessionID
    -- Using the current mode from your Modes file
    local mode = Diameter.Modes.CurrentMode or 0
    local container = C_DamageMeter.GetCombatSessionFromID(sessionID, mode)
    
    if container and container.combatSources then
        local sources = container.combatSources
        local topValue = sources[1] and sources[1].totalAmount

        -- Loop through your 10 UI bars
        for i = 1, 10 do
            local bar = frame.Bars[i]
            local data = sources[i]

            if data and topValue then
                -- Update bar labels
                bar.nameText:SetText(data.name)
                bar.valueText:SetText(data.totalAmount)
                
                -- Update bar fill relative to the top player
                bar:SetMinMaxValues(0, topValue)
                bar:SetValue(data.totalAmount)
                
                bar:Show()
            else
                -- Hide bars if there's no player data for this slot
                bar:Hide()
            end
        end
    end
end