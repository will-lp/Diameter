
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

    if (Diameter.Navigation.isSpellView()) then
        self:UpdatePlayerSpellMeter(frame, sessionID, mode)
    else
        self:UpdateGroupMeter(frame, sessionID, mode)
    end
    
end

function Diameter.Loop:UpdatePlayerSpellMeter(frame, sessionID, mode)
    
    local details = C_DamageMeter.GetCombatSessionSourceFromType(
        Diameter.Modes.CurrentSessionType, 
        mode, 
        Diameter.Navigation.getTargetGUID())

    if details and details.combatSpells then
        -- Transform Blizzard's spell details into a format UpdateBar understands
        local topValue = details.combatSpells[1][ModeToField[Diameter.Modes.CurrentMode]]

        for i, combatSpell in ipairs(details.combatSpells) do
            
            local bar = frame.Bars[i]
            
            local data = {
                name = C_Spell.GetSpellName(combatSpell.spellID) or "Unknown",
                totalAmount = combatSpell.totalAmount,
                amountPerSecond = combatSpell.amountPerSecond, 
                specIconID = C_Spell.GetSpellTexture(combatSpell.spellID),
                isSpell = true -- Flag for coloring
            }

            data.value = combatSpell[ModeToField[Diameter.Modes.CurrentMode]]

            print(
                "ModeToField[Diameter.Modes.CurrentMode]", ModeToField[Diameter.Modes.CurrentMode], 
                "data.value", data.value,
                "topValue", topValue)

            self:UpdateBar(bar, data, topValue)
        end
    end

    
end

function Diameter.Loop:UpdateGroupMeter(frame, sessionID, mode)
    
    local container = C_DamageMeter.GetCombatSessionFromID(sessionID, mode)
    
    if container and container.combatSources then
        local sources = container.combatSources
        local topValue = sources[1] and sources[1][ModeToField[Diameter.Modes.CurrentMode]]

        -- Loop through UI bars
        for i = 1, Diameter.UI.MaxBars do
            local bar = frame.Bars[i]
            local data = sources[i]

            if data then
                data.value = data[ModeToField[Diameter.Modes.CurrentMode]]
            end

            self:UpdateBar(bar, data, topValue)
        end
    end
end


function Diameter.Loop:UpdateBar(bar, data, topValue)
    
    if data and topValue then

        local displayValue = data.value or 0

        -- Update bar labels
        bar.nameText:SetText(data.name)

        bar.data = data
        
        bar.valueText:SetText(AbbreviateLargeNumbers(displayValue))

        if data.specIconID then
            bar.icon:SetTexture(data.specIconID)
            bar.icon:Show()
        else
            -- If no spec data, hide it
            bar.icon:Hide()
        end
        
        -- Set the bar color
        local color = RAID_CLASS_COLORS[data.classFilename] or {r=0.5, g=0.5, b=0.5} -- Gray fallback
        bar:SetStatusBarColor(color.r, color.g, color.b)

        -- Update bar fill relative to the top player
        bar:SetMinMaxValues(0, topValue)
        bar:SetValue(displayValue)
        
        bar:Show()
    else
        -- Hide bars if there's no player data for this slot
        bar:Hide()
    end
end