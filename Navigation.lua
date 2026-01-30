local addonName, Diameter = ...

local Modes = {
    MODES = "MODES",
    MAIN = "MAIN",
    SPELL = "SPELL"
}

local viewState = {
    mode = Modes.MAIN,
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

function Diameter.Navigation:isSpellView()
    return viewState.mode == Modes.SPELL
end

function Diameter.Navigation:DrillDown(guid, name, i)
    viewState.mode = Modes.SPELL

    if (issecretvalue(guid)) then
        viewState.secretTargetGUID = guid
    end
    
    viewState.targetGUID = issecretvalue(guid) and UnitGUID("player") or guid
    viewState.targetName = name
    viewState.targetIndex = i

    -- Force a UI refresh
    Diameter.Loop:UpdateMeter(Diameter.UI.mainFrame)
end

function Diameter.Navigation:ResetView()
    viewState.mode = Modes.MAIN
    viewState.targetGUID = nil
    Diameter.Loop:UpdateMeter(Diameter.UI.mainFrame)
end