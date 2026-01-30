local addonName, Diameter = ...

local Modes = {
    MODES = "MODES",
    MAIN = "MAIN",
    SPELL = "SPELL"
}

local viewState = {
    mode = Modes.MAIN,
    targetGUID = nil,
    targetName = nil
}

Diameter.Navigation = {}

function Diameter.Navigation:getTargetGUID()
    return viewState.targetGUID
end

function Diameter.Navigation:isSpellView()
    return viewState.mode == Modes.SPELL
end

function Diameter.Navigation:DrillDown(guid, name)
    viewState.mode = Modes.SPELL
    viewState.targetGUID = guid
    viewState.targetName = name
    -- Force a UI refresh
    Diameter.Loop:UpdateMeter(Diameter.UI.mainFrame)
end

function Diameter.Navigation:ResetView()
    viewState.mode = Modes.MAIN
    viewState.targetGUID = nil
    Diameter.Loop:UpdateMeter(Diameter.UI.mainFrame)
end