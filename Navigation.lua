local addonName, Diameter = ...

--[[
    This module provides the navigation functionality for Diameter.
    It manages the current view state (modes, group, or spell) and handles navigation actions.

    Currently it enables navigation of three pages:
    - Modes View: where the user can select the mode (Damage Done, Healing Done, etc.)
    - Group View: where the user can see the group meter for the selected mode.
    - Spell View: where the user can see the spell meter (breakdown) for a selected player.

    Due to Blizzard restrictions spell meter seems to only work on the player while in combat. 

    Future improvements may include:
    - Remembering the last selected mode between sessions.
    - Detailed data of spell breakdown
]]

local Pages = Diameter.Pages

local viewState = {
    page = Pages.GROUP,
    targetGUID = nil,
    targetName = nil,
    targetIndex = nil,
    secretTargetGUID = nil, -- here we hold the secretTargetGUID. No use for now, though :-(
}

local EVT = Diameter.EventBus.Events

Diameter.Navigation = {}

Diameter.EventBus:Listen(EVT.MODE_CHANGED, function(value)
    Diameter.Navigation:NavigateToGroup()
end)

function Diameter.Navigation:getTargetGUID()
    return viewState.targetGUID
end

function Diameter.Navigation:getTargetIndex()
    return viewState.targetIndex
end

function Diameter.Navigation.isSpellView()
    return viewState.page == Pages.SPELL
end

function Diameter.Navigation.isGroupView()
    return viewState.page == Pages.GROUP
end

function Diameter.Navigation.isModesView()
    return viewState.page == Pages.MODES
end

function Diameter.Navigation:NavigateToGroup()
    viewState.page = Pages.GROUP
    viewState.targetGUID = nil
    viewState.targetName = nil

    Diameter:RefreshUI()
    Diameter.EventBus:Fire(EVT.PAGE_CHANGED, viewState)
end

function Diameter.Navigation:NavigateDown(data)
    if self:isModesView() then 
        viewState.page = Pages.GROUP

        -- data.mode comes from the list of BlizzardDamageMeter modes
        Diameter.EventBus:Fire(EVT.MODE_CHANGED, data.mode)
    elseif self:isGroupView() then
        viewState.page = Pages.SPELL
        local guid, name = data.sourceGUID, data.name

        -- if we click another player during battle, that will throw an error because
        -- it's a secret value. We can only look at other players' data after combat ends.
        -- Blizzard's own dps meter doesn't seem to have this limitation.
        
        viewState.targetGUID = issecretvalue(guid) and UnitGUID("player") or guid

        if issecretvalue(data.sourceCreatureID) then
            viewState.sourceCreatureID = nil
        else
            viewState.sourceCreatureID = data.sourceCreatureID
        end

        viewState.targetName = name
    end

    -- Force a UI refresh
    Diameter.EventBus:Fire(EVT.PAGE_CHANGED, viewState)
    Diameter:RefreshUI()
end

function Diameter.Navigation:NavigateUp(data)
    if self:isSpellView() then
        viewState.page = Pages.GROUP
        viewState.targetGUID = nil
        viewState.targetName = nil
    elseif self:isGroupView() then
        viewState.page = Pages.MODES
    end

    Diameter.EventBus:Fire(EVT.PAGE_CHANGED, viewState)
    Diameter:RefreshUI()
end