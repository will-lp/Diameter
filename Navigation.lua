local addonName, Diameter = ...

--[[
    This module provides the navigation functionality for Diameter.
    It manages the current view state (modes, group, or spell) and handles navigation actions.

    Currently it enables navigation of three pages:
    - Modes View: where the user can select the mode (Damage Done, Healing Done, etc.)
    - Group View: where the user can see the group meter for the selected mode.
    - Spell View: where the user can see the spell meter (breakdown) for a selected player.
    - Player selection mode: this mode is a toggle for the Group View; it allows the user
    to select a player to watch its breakdown, but it's based off the player list, and not
    the combat data from Blizzard.

    Due to Blizzard restrictions spell meter seems to only work on the player while in combat. 

]]

local EVT = Diameter.EventBus.Events
local Pages = Diameter.Pages



Diameter.Navigation = {}
Diameter.Navigation.__index = Diameter.Navigation

function Diameter.Navigation:New(eventBus)
    local obj = setmetatable({}, self)

    obj.eventBus = eventBus
    obj.viewState = {
        page = Pages.GROUP,
        targetGUID = nil,
        targetName = nil,
        targetIndex = nil,
        secretTargetGUID = nil, -- here we hold the secretTargetGUID. No use for it now, though :-(
    }

    obj.eventBus:Listen(EVT.MODE_CHANGED, function(value)
        obj:NavigateToGroup()
    end)

    obj.eventBus:Listen(EVT.PLAYER_SELECTION_MODE, function(playerSelectionMode)
        if playerSelectionMode == true then 
            obj.viewState.page = Pages.PLAYER_SELECTION
        else 
            obj.viewState.page = Pages.GROUP
        end
    end)

    return obj
end



function Diameter.Navigation:isSpellView()
    return self.viewState.page == Pages.SPELL
end

function Diameter.Navigation:isGroupView()
    return self.viewState.page == Pages.GROUP
end

function Diameter.Navigation:isModesView()
    return self.viewState.page == Pages.MODES
end

function Diameter.Navigation:isPlayerSelectionMode()
    return self.viewState.page == Pages.PLAYER_SELECTION
end

function Diameter.Navigation:NavigateToGroup()
    self.viewState.page = Pages.GROUP
    self.viewState.targetGUID = nil
    self.viewState.targetName = nil

    self.eventBus:Fire(EVT.PAGE_CHANGED, self.viewState)
end

function Diameter.Navigation:NavigateDown(data)
    local viewState = self.viewState
    if self:isModesView() then 
        viewState.page = Pages.GROUP

        -- data.mode comes from the list of BlizzardDamageMeter modes
        self.eventBus:Fire(EVT.MODE_CHANGED, data.mode)
    elseif self:isGroupView() or self:isPlayerSelectionMode() then
        viewState.page = Pages.SPELL
        local guid, name = data.sourceGUID, data.name

        -- if we click another player during battle, that will throw an error because
        -- it's a secret value. We can only look at other players' data after combat ends.
        -- Blizzard's own dps meter doesn't seem to have this limitation.
        -- The current "workaround" is using PlayerList -> a player selection mode.
        
        viewState.targetGUID = issecretvalue(guid) and UnitGUID("player") or guid

        if issecretvalue(data.sourceCreatureID) then
            viewState.sourceCreatureID = nil
        else
            viewState.sourceCreatureID = data.sourceCreatureID
        end

        viewState.targetName = name
    end

    -- Force a UI refresh
    self.eventBus:Fire(EVT.PAGE_CHANGED, viewState)
end

function Diameter.Navigation:NavigateUp(data)
    local viewState = self.viewState
    if self:isSpellView() then
        viewState.page = Pages.GROUP
        viewState.targetGUID = nil
        viewState.targetName = nil
    elseif self:isGroupView() or viewState.page == Pages.PLAYER_SELECTION then
        viewState.page = Pages.MODES
    end

    self.eventBus:Fire(EVT.PAGE_CHANGED, viewState)
end