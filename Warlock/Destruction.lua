local _G, setmetatable = _G, setmetatable
local TMW = _G.TMW
local UnitAura, UnitStagger, UnitGUID = _G.UnitAura, _G.UnitStagger, _G.UnitGUID
local ACTION = _G.Action
local Create = Action.Create
local Unit = Action.Unit
local Player = Action.Player
local BurstIsON = Action.BurstIsON
local MultiUnits = Action.MultiUnits
local Action = _G.Action
local IsUnitEnemy = Action.IsUnitEnemy
local BurstIsON = Action.BurstIsON
local GetToggle = Action.GetToggle

local player = "player"
local unit = "target"

Action[ACTION_CONST_WARLOCK_DESTRUCTION] = {
    -- Class Tree

    -- Spec Tree

    Cataclysm = Action.Create({Type = "Spell", ID = 152108}),
    ChaosBolt = Action.Create({Type = "Spell", ID = 116858}),
    Conflagrate = Action.Create({Type = "Spell", ID = 17962}),
    Havoc = Action.Create({Type = "Spell", ID = 80240}),
    Immolate = Action.Create({Type = "Spell", ID = 348}),
    Incinerate = Action.Create({Type = "Spell", ID = 29722}),
    RainOfFire = Action.Create({Type = "Spell", ID = 5740}),
    Shadowburn = Action.Create({Type = "Spell", ID = 17877}),
    SoulFire = Action.Create({Type = "Spell", ID = 6353}),
    SummonInfernal = Action.Create({Type = "Spell", ID = 1122}),
    ChannelDemonfire = Action.Create({Type = "Spell", ID = 196447}),
    DimensionalRift = Action.Create({Type = "Spell", ID = 387976}),

    -- Debuffs

    ImmolateDebuff = Action.Create({Type = "Spell", ID = 157736, Hidden = true}),
    ConflagrateDebuff = Action.Create({
        Type = "Spell",
        ID = 265931,
        Hidden = true
    })
}

local A = setmetatable(Action[ACTION_CONST_WARLOCK_DESTRUCTION],
                       {__index = Action})

A[3] = function(icon)

    local isAoE = GetToggle(2, "AoE")

    function DamageRotation(unit)

        if A.Immolate:IsReady(unit) and
            Unit(unit):HasDeBuffs(A.ImmolateDebuff.ID, player) == 0 then
            return A.Immolate:Show(icon)
        end

        if A.RainOfFire:IsReady(player) and isAoE then
            return A.RainOfFire:Show(icon)
        end

        if A.ChaosBolt:IsReady(unit) and not isAoE then
            return A.ChaosBolt:Show(icon)
        end

        if A.Conflagrate:IsReady(unit) and
            Unit(unit):HasDeBuffs(A.ConflagrateDebuff.ID, player) == 0 then
            return A.Conflagrate:Show(icon)
        end

        if A.DimensionalRift:IsReady(unit) then
            return A.DimensionalRift:Show(icon)
        end

        if A.ChannelDemonfire:IsReady(player) then
            return A.ChannelDemonfire:Show(icon)
        end

        if A.Conflagrate:IsReady(unit) then
            return A.Conflagrate:Show(icon)
        end

        if A.Incinerate:IsReady(unit) then return A.Incinerate:Show(icon) end

    end

    if IsUnitEnemy(unit) then if DamageRotation(unit) then return true end end

end
