

local addonName, Diameter = ...

Diameter.UI.mainFrame = Diameter.UI:Boot()

-- This makes Diameter accessible to the Chat Frame and other files
_G["Diameter"] = Diameter

Diameter.Current = {
    Mode = BlizzardDamageMeter.Mode.DamageDone,
    SessionType = BlizzardDamageMeter.SessionType.Current,
}

Diameter.UI.mainFrame.MenuBtn:SetScript("OnClick", function(self)
    Diameter:ShowMenu(self)
end)

-- 5. Main loop
C_Timer.NewTicker(0.5, function() 
    Diameter.Loop:UpdateMeter(Diameter.UI.mainFrame) 
end)
