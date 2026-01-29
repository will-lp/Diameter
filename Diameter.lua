

local addonName, Diameter = ...

local frame = Diameter.UI:Boot()

Diameter.Modes = {
    CurrentMode = BlizzardDamageMeter.Type.DamageDone
}

frame.MenuBtn:SetScript("OnClick", function(self)
    Diameter:ShowMenu(self)
end)

-- 5. Set it to update every second
C_Timer.NewTicker(10.0, function() 
    Diameter.Loop:UpdateMeter(frame) 
end)
