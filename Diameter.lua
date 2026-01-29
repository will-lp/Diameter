

local addonName, Diameter = ...

local frame = Diameter.UI:Boot()

frame.MenuBtn:SetScript("OnClick", function(self)
    Diameter:ShowMenu(self)
end)

-- 5. Set it to update every second
C_Timer.NewTicker(1.0, function() 
    Diameter.Loop:UpdateMeter(frame) 
end)
