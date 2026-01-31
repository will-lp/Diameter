

local addonName, Diameter = ...

Diameter.UI.mainFrame = Diameter.UI:Boot()

-- This makes Diameter accessible to the Chat Frame and other files
_G["Diameter"] = Diameter

Diameter.Current = {
    Mode = BlizzardDamageMeter.Mode.DamageDone,
    SessionType = BlizzardDamageMeter.SessionType.Current,
}

Diameter.UI.mainFrame.MenuBtn:SetScript("OnClick", function(self)
    Diameter.Menu:ShowMenu(self)
end)

-- 5. Main loop
C_Timer.NewTicker(0.5, function() 
    Diameter.Loop:UpdateMeter(Diameter.UI.mainFrame) 
end)

function Diameter:SetMode(value)
    local label = Diameter.Menu.Labels[value]
    Diameter.UI.mainFrame.HeaderText:SetText("Diameter: " .. label)
    Diameter.Current.Mode = value
end