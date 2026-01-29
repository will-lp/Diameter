
local addonName, Diameter = ...

Diameter.Loop = {}


local ModeToField ={
    [BlizzardDamageMeter.Mode.DamageDone] = "totalAmount",
    [BlizzardDamageMeter.Mode.Dps] = "amountPerSecond",
    [BlizzardDamageMeter.Mode.HealingDone] = "totalHealing",
    [BlizzardDamageMeter.Mode.Hps] = "hps",
    [BlizzardDamageMeter.Mode.Absorbs] = "totalAbsorbs",
    [BlizzardDamageMeter.Mode.Interrupts] = "interrupts",
    [BlizzardDamageMeter.Mode.Dispels] = "dispels",
    [BlizzardDamageMeter.Mode.DamageTaken] = "totalDamageTaken",
    [BlizzardDamageMeter.Mode.AvoidableDamageTaken] = "avoidableDamageTaken",
}

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

            self:ConfigureBar(bar, data, topValue)
        end
    end
end


function Diameter.Loop:ConfigureBar(bar, data, topValue)
    if data and topValue then

        Diameter.Debug:dumpTable(data)

        local displayValue = data[ModeToField[Diameter.Modes.CurrentMode]] or 0
        
        -- Update bar labels
        bar.nameText:SetText(data.name)
        
        bar.valueText:SetText(AbbreviateLargeNumbers(displayValue))

        if data.specIconID and data.specIconID > 0 then
            bar.icon:SetTexture(data.specIconID)
            bar.icon:Show()
        else
            -- If no spec data, maybe show a generic class icon or hide it
            bar.icon:Hide()
        end
        
        local color = RAID_CLASS_COLORS[data.classFilename]
        if color then
            bar:SetStatusBarColor(color.r, color.g, color.b)
        else
            bar:SetStatusBarColor(0.5, 0.5, 0.5) -- Gray fallback
        end

        -- Update bar fill relative to the top player
        bar:SetMinMaxValues(0, topValue)
        bar:SetValue(displayValue)
        
        bar:Show()
    else
        -- Hide bars if there's no player data for this slot
        bar:Hide()
    end
end