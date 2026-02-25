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
local BDM = Diameter.BlizzardDamageMeter


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
        targetClass = nil,
        secretTargetGUID = nil, -- here we hold the secretTargetGUID. No use for it now, though :-(
    }

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


--[[
    Navigate into the pages of Diameter.

    From MODES we go to GROUP.
    From GROUP, if there are secret values, we go to PLAYER_SELECTION
    From GROUP, if there are no secret values, we go to SPELL
    From PLAYER_SELECTION we go to SPELL.
]]--
function Diameter.Navigation:NavigateDown(data)
    local viewState = self.viewState
    
    if self:isModesView() then 
        viewState.page = Pages.GROUP

        -- data.mode comes from the list of BlizzardDamageMeter modes
        self.eventBus:Fire(EVT.MODE_CHANGED, data.mode)
    elseif self:isGroupView() then

        -- if we click another player during battle, it will throw an error because
        -- it's a secret value. We can only look at other players' data after combat 
        -- ends and another round of data was pulled from the API.
        -- Blizzard's own dps meter doesn't seem to have this limitation.
        -- The current "workaround" is using Player Selection Mode.

        if issecretvalue(data.sourceGUID) then
            self.eventBus:Fire(EVT.PLAYER_SELECTION_MODE, true)
            return
        end

        self:FillViewStateWithDataForSpellPage(data)

    elseif self:isPlayerSelectionMode() then
        self:FillViewStateWithDataForSpellPage(data)
    end

    -- Force a UI refresh
    self.eventBus:Fire(EVT.PAGE_CHANGED, viewState)
end

function Diameter.Navigation:FillViewStateWithDataForSpellPage(data)
    local viewState = self.viewState
    viewState.page = Pages.SPELL
    viewState.targetGUID = data.sourceGUID
    viewState.sourceCreatureID = data.sourceCreatureID
    viewState.targetName = data.name
    viewState.targetClass = data.color
end

--[[
    NavigateUp flow:
    
    From SPELL we navigate up to GROUP.
    From PLAYER_SELECTION we move up to GROUP.
    From GROUP we move up to MODES.
]]--
function Diameter.Navigation:NavigateUp(data)
    local viewState = self.viewState
    if self:isSpellView() then
        viewState.page = Pages.GROUP
        viewState.targetGUID = nil
        viewState.targetName = nil
        viewState.targetClass = nil
        viewState.targetIndex = nil
        viewState.secretTargetGUID = nil
    elseif self:isPlayerSelectionMode() then
        viewState.page = Pages.GROUP
    elseif self:isGroupView()  then
        viewState.page = Pages.MODES
    end

    self.eventBus:Fire(EVT.PAGE_CHANGED, viewState)
end