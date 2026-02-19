local addonName, Diameter = ...


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
    Used in navigation
]]
Diameter.Pages = {
    MODES = "MODES",
    GROUP = "GROUP",
    SPELL = "SPELL",
    PLAYER_SELECTION = "PLAYER_SELECTION"
}
