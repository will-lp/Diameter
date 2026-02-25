local _, Diameter = ...


--[[
    The options available on Blizzard's own damage meter.
]]
Diameter.BlizzardDamageMeter = {
    Mode = {
        DamageDone = 0,
        Dps = 1,
        HealingDone = 2,
        Hps = 3,
        Absorbs = 4,
        Interrupts = 5,
        Dispels = 6,
        DamageTaken = 7,
        AvoidableDamageTaken = 8,
    },
    SessionType = {
        Overall = 0,
        Current = 1,
        Expired = 2,
    },
	Restriction = {
		None = 0,
		Combat = 1,
		Encounter = 2,
	},
}


--[[
    Pages used in navigation.
]]
Diameter.Pages = {
    MODES = "MODES",
    GROUP = "GROUP",
    SPELL = "SPELL",
    PLAYER_SELECTION = "PLAYER_SELECTION"
}


local muteColor = 0.6

--[[
    A pool of colors so we don't keep creating colors on every loop iteration.
]]
Diameter.Color = { 
    Gray = {r=0.5, g=0.5, b=0.5},
    Blue = {r=0.3, g=0.3, b=0.9},
    ShadowViolet = {r=0.3, g=0.0, b=0.5},
    BlackCherry = {r=0.5, g=0.2, b=0.3},
    LightSteelBlue = {r=0.65, g=0.85, b=0.85},
    SteelBlue = {r=0.5, g=0.7, b=0.7},
}

-- here we apply the muteColor to dim the colors a bit
for colorName, color in pairs(Diameter.Color) do
    for key, value in pairs(color) do
        color[key] = value * muteColor
    end
end


Diameter.ClassColors = {}

for class, color in pairs(RAID_CLASS_COLORS) do
    Diameter.ClassColors[class] = {
        r = color.r * muteColor,
        g = color.g * muteColor,
        b = color.b * muteColor
    }
end