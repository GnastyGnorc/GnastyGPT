local _G, setmetatable = _G, setmetatable
local TMW = _G.TMW
local UnitAura, UnitStagger, UnitGUID = _G.UnitAura, _G.UnitStagger, _G.UnitGUID
local ACTION = _G.Action
local Create = Action.Create
local Unit = Action.Unit
local Player = Action.Player
local BurstIsON = Action.BurstIsON
local MultiUnits = Action.MultiUnits
local GetToggle = Action.GetToggle

local Action = _G.Action
local IsUnitEnemy = Action.IsUnitEnemy
local BurstIsON = Action.BurstIsON

local player = "player"
local unit = "target"

Action[ACTION_CONST_MAGE_FIRE] = {
    -- Class Tree

    AlterTime = Create({Type = "Spell", ID = 342245}),
    ArcaneIntellect = Create({Type = "Spell", ID = 1459}),
    BlastWave = Create({Type = "Spell", ID = 157981}),
    ConeOfCold = Create({Type = "Spell", ID = 120}),
    IceFloes = Create({Type = "Spell", ID = 108839}),
    IceNova = Create({Type = "Spell", ID = 157997}),
    SpellSteal = Create({Type = "Spell", ID = 30449}),

    -- Spec Tree

    BlazingBarrier = Create({Type = "Spell", ID = 235313}),
    Combustion = Create({Type = "Spell", ID = 190319}),
    FireBlast = Create({Type = "Spell", ID = 108853}),
    Fireball = Create({Type = "Spell", ID = 133}),
    PhoenixFlames = Create({Type = "Spell", ID = 257541}),
    Pyroblast = Create({Type = "Spell", ID = 11366}),
    Scorch = Create({Type = "Spell", ID = 2948}),
    FlameStrike = Create({Type = "Spell", ID = 2120}),

    -- Buffs
    HeatingUp = Create({Type = "Spell", ID = 48107}),
    HotStreak = Create({Type = "Spell", ID = 48108}),
    SunKingsBlessing = Create({Type = "Spell", ID = 383882}),
    FuryOfTheSunKing = Create({Type = "Spell", ID = 383883}),
    Combustion = Create({Type = "Spell", ID = 190319}),
    Pyroclasm = Create({Type = "Spell", ID = 269651}),
    FeelTheBurn = Create({Type = "Spell", ID = 383395}),
    FlamesFury = Create({Type = "Spell", ID = 409964}),

    -- Debuffs
    CharringEmbers = Create({Type = "Spell", ID = 408665}),
    ImprovedScorch = Create({Type = "Spell", ID = 383604}),

    -- Racial
    -- Using for Mage Shields
    Stoneform = Create({Type = "Spell", ID = 20594}),

    -- Trinket
    IrideusFragment = Create({Type = "Trinket", ID = 193743}),

    -- Talents
    AlexstraszasFury = Create({Type = "Spell", ID = 235870})
}

local A = setmetatable(Action[ACTION_CONST_MAGE_FIRE], {__index = Action})
local FBDelay = 0

A[3] = function(icon)

    local isAoE = GetToggle(2, "AoE")
    local isMoving = A.Player:IsMoving()
    local bankPhoenixFlames = false
    local bankFireBlast = false
    local lastCast = A.LastPlayerCastID

    --------------------
    local fireStarterActive = Unit(unit):HealthPercent() > 90
    local searingTouchActive = Unit(unit):HealthPercent() < 30
    local hotStreakActive = Unit(player):HasBuffs(A.HotStreak.ID, true) > 0
    local heatingUpActive = Unit(player):HasBuffs(A.HeatingUp.ID, true) > 0
    local flamesFuryActive = Unit(player):HasBuffs(A.FlamesFury.ID, true) > 0
    local combustionActive = Unit(player):HasBuffs(A.Combustion.ID, true) > 0
    local furyOfTheSunKingActive = Unit(player):HasBuffs(A.FuryOfTheSunKing.ID,
                                                         true) > 0

    if FBDelay > 0 then FBDelay = FBDelay - 1 end

    local function BasicDamageRotation(unit)

        if lastCast == A.FireBlast.ID then
            -- print("Fireblast Just Cast")
            FBDelay = 6
        end

        if combustionActive then

            if A.Pyroblast:IsReadyByPassCastGCD(unit) and
                Unit(player):IsCastingRemains() < 0.5 and furyOfTheSunKingActive then
                return A.Pyroblast:Show(icon)
            end

            if A.Pyroblast:IsReadyByPassCastGCD(unit) and
                Unit(player):IsCastingRemains() < 0.5 and hotStreakActive then
                return A.Pyroblast:Show(icon)
            end

            if A.PhoenixFlames:IsReady(unit) and heatingUpActive and
                not A.PhoenixFlames:IsSpellInFlight() and
                Unit(unit):HasDeBuffs(A.CharringEmbers.ID, player) < 3 then
                return A.PhoenixFlames:Show(icon)
            end

            if A.FireBlast:IsReadyByPassCastGCD(unit) and FBDelay == 0 and
                heatingUpActive then return A.FireBlast:Show(icon) end

            if A.PhoenixFlames:IsReady(unit) and heatingUpActive and
                flamesFuryActive then
                return A.PhoenixFlames:Show(icon)
            end

            if A.Scorch:IsReady(unit) and Unit(player):HasBuffs(A.Combustion.ID) >
                A.Scorch:GetSpellCastTime() and A.Scorch:GetSpellCastTime() >=
                A.GetGCD() then return A.Scorch:Show(icon) end

        end

        if A.Combustion:IsReadyByPassCastGCD(player) and furyOfTheSunKingActive and
            A.Pyroblast:IsSpellInCasting() and Unit(player):IsCastingRemains() <
            0.5 then return A.Combustion:Show(icon) end


        if A.PhoenixFlames:IsReady(unit) and
            Unit(unit):HasDeBuffs(A.CharringEmbers.ID, player) < 3 and
            not hotStreakActive and not A.PhoenixFlames:IsSpellInFlight() then
            return A.PhoenixFlames:Show(icon)
        end

        if A.Pyroblast:IsReadyByPassCastGCD(unit) and
            Unit(player):IsCastingRemains() < 0.5 and furyOfTheSunKingActive then
            return A.Pyroblast:Show(icon)
        end

        if A.PhoenixFlames:IsReady(unit) and
            A.PhoenixFlames:GetSpellChargesFullRechargeTime() < A.GetGCD() * 2 then
            return A.PhoenixFlames:Show(icon)
        end


        if A.FireBlast:IsReady(unit) and
            A.FireBlast:GetSpellChargesFullRechargeTime() < A.GetGCD ()* 2 then
            return A.FireBlast:Show(icon)
    end

        if A.Pyroblast:IsReadyByPassCastGCD(unit) and
            Unit(player):IsCastingRemains() < 0.5 and hotStreakActive then
            return A.Pyroblast:Show(icon)
        end

        if A.FireBlast:IsReadyByPassCastGCD(unit) and FBDelay == 0 and
            heatingUpActive then return A.FireBlast:Show(icon) end

        if A.Scorch:IsReady(unit) and searingTouchActive then
            return A.Scorch:Show(icon)
        end

        if A.Fireball:IsReady(unit) then return A.Fireball:Show(icon) end

    end

    if A.IsUnitEnemy("target") then
        unit = "target"
        if BasicDamageRotation(unit) then return true end
    end

end
