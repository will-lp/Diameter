local addonName, Diameter = ...

local Pages = {
    MODES = "MODES",
    GROUP = "GROUP",
    SPELL = "SPELL",
}

local viewState = {
    mode = Pages.GROUP,
    targetGUID = nil,
    targetName = nil,
    targetIndex = nil,
    secretTargetGUID = nil, -- here we hold to the secretTargetGUID. No use for now, though :-(
}

Diameter.Navigation = {}

function Diameter.Navigation:getTargetGUID()
    return viewState.targetGUID
end

function Diameter.Navigation:getTargetIndex()
    return viewState.targetIndex
end

function Diameter.Navigation.isSpellView()
    return viewState.mode == Pages.SPELL
end

function Diameter.Navigation.isGroupView()
    return viewState.mode == Pages.GROUP
end

function Diameter.Navigation.isModesView()
    return viewState.mode == Pages.MODES
end

function Diameter.Navigation:NavigateToGroup()
    viewState.mode = Pages.GROUP
    viewState.targetGUID = nil
    viewState.targetName = nil
    Diameter.Loop:UpdateMeter(Diameter.UI.mainFrame)
end

function Diameter.Navigation:NavigateDown(data)
    if self:isModesView() then 
        viewState.mode = Pages.GROUP

        -- data.mode comes from the list of BlizzardDamageMeter modes
        Diameter:SetMode(data.mode)
    elseif self:isGroupView() then
        viewState.mode = Pages.SPELL
        local guid, name = data.sourceGUID, data.name

        if (issecretvalue(guid)) then
            viewState.secretTargetGUID = guid
        end
        
        viewState.targetGUID = issecretvalue(guid) and UnitGUID("player") or guid
        viewState.targetName = name
    end

    -- Force a UI refresh
    Diameter.Loop:UpdateMeter(Diameter.UI.mainFrame)
end

function Diameter.Navigation:NavigateUp(data)
    if self:isSpellView() then
        viewState.mode = Pages.GROUP
        viewState.targetGUID = nil
        viewState.targetName = nil
    elseif self:isGroupView() then
        viewState.mode = Pages.MODES
    end
    Diameter.Loop:UpdateMeter(Diameter.UI.mainFrame)
end