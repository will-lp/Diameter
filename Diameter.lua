

local addonName, Diameter = ...

Diameter.UI.mainFrame = Diameter.UI:Boot()

Diameter.Current = {
    Mode = BlizzardDamageMeter.Mode.DamageDone,
    SessionType = BlizzardDamageMeter.SessionType.Current,
}

Diameter.UI.mainFrame.MenuBtn:SetScript("OnClick", function(self)
    Diameter:ShowMenu(self)
end)

-- 5. Set it to update every second
C_Timer.NewTicker(10.0, function() 
    Diameter.Loop:UpdateMeter(Diameter.UI.mainFrame) 
end)
