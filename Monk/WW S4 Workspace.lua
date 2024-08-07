-- WW S4 Workspace
local _G, setmetatable = _G, setmetatable
local TMW = _G.TMW
local CNDT = TMW.CNDT
local Env = CNDT.Env
local Action = _G.Action
local Create = Action.Create
local Unit = Action.Unit
local Player = Action.Player
local BurstIsON = Action.BurstIsON
local MultiUnits = Action.MultiUnits
local GetToggle = Action.GetToggle
local ActiveUnitPlates = MultiUnits:GetActiveUnitPlates()
local player = "player"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

Action[ACTION_CONST_MONK_WINDWALKER] = {

    -- Class Tree
    BlackoutKick = Create({Type = "Spell", ID = 100784}),
    ChiWave = Create({Type = "Spell", ID = 115098}),
    ExpelHarm = Create({Type = "Spell", ID = 322101}),
    RisingSunKick = Create({Type = "Spell", ID = 107428}),
    SpinningCraneKick = Create({Type = "Spell", ID = 101546}),
    SummonWhiteTigerStatue = Create({Type = "Spell", ID = 388686}),
    TigerPalm = Create({Type = "Spell", ID = 100780}),
    TigerPalm1 = Create({Type = "Spell", ID = 100780, desc = "TigerPalm 1"}),
    TigersLust = Create({Type = "Spell", ID = 116841}),
    TouchofDeath = Create({Type = "Spell", ID = 322109}),

    -- Spec Tree

    BoneDustBrew = Action.Create({Type = "Spell", ID = 386276}),
    Detox = Action.Create({Type = "Spell", ID = 115450}),
    FistsOfFury = Create({Type = "Spell", ID = 113656}),
    InvokeXuentheWhiteTiger = Action.Create({Type = "Spell", ID = 123904}),
    Serenity = Action.Create({Type = "Spell", ID = 152173}),
    StormEarthAndFire = Action.Create({Type = "Spell", ID = 137639}),
    StrikeOfTheWindlord = Create({Type = "Spell", ID = 392983}),
    FaelineStomp = Action.Create({Type = "Spell", ID = 388193}),

    -- Buffs
    TeachingsOfTheMonastery = Create({Type = "Spell", ID = 202090}),
    DanceOfChiJi = Create({Type = "Spell", ID = 325202}),
    SerenityBuff = Create({Type = "Spell", ID = 152173}),
    SEF = Create({Type = "Spell", ID = 137639}),

    -- Debuffs
    Entangle = Create({Type = "Spell", ID = 408556, Hidden = true}),
    FaeExposure = Create({Type = "Spell", ID = 395414, Hidden = true}),
    SkyReach = Create({Type = "Spell", ID = 393047, Hidden = true}),
    SkyreachExhaustion = Create({Type = "Spell", ID = 393050, Hidden = true}),

    StopCast = Action.Create({Type = "Spell", ID = 61721, Hidden = true})

}

local A = setmetatable(Action[ACTION_CONST_MONK_WINDWALKER], {__index = Action})

local function ComboStrike(SpellObject)
    return (not Player:PrevGCD(1, SpellObject))
end

-- add touch of death for bosses
-- cancel fof

-- paralysis/leg sweep some adds/casts

A[3] = function(icon)

    local Chi = Player:Chi()
    local inMelee = A.TigerPalm:IsInRange(target)
    local inFoF = Player:IsChanneling() == "Fists of Fury"
    local unitCount = MultiUnits:GetBySpell(A.TigerPalm)

    local function BasicDamageRotation(unit)

        -- print(Chi)
        -- print('-------')
        -- print("A.RisingSunKick:IsReadyByPassCastGCD(unit) and inFoF: ",
        --       A.RisingSunKick:IsReadyByPassCastGCD(unit) and inFoF)

        -- print("unitCount: ", unitCount)

        if Unit(player):HasDeBuffs(A.Entangle.ID) > 0 and
            A.TigersLust:IsReady(player) then
            return A.TigersLust:Show(icon)
        end

        if A.TouchofDeath:IsReadyByPassCastGCD(unit) and
            ComboStrike(A.TouchofDeath) and
            (Unit(target):HealthPercent() <= 15 or Unit(target):Health() <=
                Unit(player):Health()) then
            return A.TouchofDeath:Show(icon)
        end

        if BurstIsON(player) and inMelee then

            if A.SummonWhiteTigerStatue:IsReady(player) then
                return A.SummonWhiteTigerStatue:Show(icon)
            end

            if A.FaelineStomp:IsReady(player) and
                Unit(target):HasDeBuffs(A.FaeExposure.ID, player) == 0 and
                inMelee then return A.FaelineStomp:Show(icon) end

            if A.InvokeXuentheWhiteTiger:IsReady(unit) then
                return A.InvokeXuentheWhiteTiger:Show(icon)
            end

            if A.BoneDustBrew:IsReady(player) and 

            if A.Serenity:IsReady(player) and
                not A.InvokeXuentheWhiteTiger:IsReady(unit) and
                Unit(target):HasDeBuffs(A.FaeExposure.ID, player) == 0 then
                return A.Serenity:Show(icon)
            end

            -- if A.BoneDustBrew:IsReady(player) and
            --     (Unit(player):HasBuffs(A.SEF.ID) ~= 0 or
            --         Unit(player):HasBuffs(A.SerenityBuff.ID) ~= 0) then
            --     return A.BoneDustBrew:Show(icon)
            -- end

        end

        if Unit(player):HasBuffs(A.Serenity.ID) ~= 0 then

            if A.FaelineStomp:IsReady(player) and
                Unit(target):HasDeBuffs(A.FaeExposure.ID, player) == 0 and
                inMelee then return A.FaelineStomp:Show(icon) end

            if A.RisingSunKick:IsReadyByPassCastGCD(unit) and inFoF and inMelee then
                return A.StopCast:Show(icon)
            end

            -- if A.BlackoutKick:IsReadyByPassCastGCD(unit) and inFoF and inMelee and
            --     unitCount == 1 then
            --     print("Clipping Fists")
            --     return A.StopCast:Show(icon)
            -- end

            if A.InvokeXuentheWhiteTiger:IsReady(unit) then
                return A.InvokeXuentheWhiteTiger:Show(icon)
            end

            if Unit(player):HasBuffs(A.Serenity.ID) <= 1.5 and
                A.FistsOfFury:IsReady(unit) and inMelee then
                return A.FistsOfFury:Show(icon)
            end

            if A.StrikeOfTheWindlord:IsReady(unit) and inMelee then
                return A.StrikeOfTheWindlord:Show(icon)
            end

            if A.SpinningCraneKick:IsReady(unit) and
                ComboStrike(A.SpinningCraneKick) and
                Unit(player):HasBuffs(A.DanceOfChiJi.ID) ~= 0 and inMelee and
                unitCount >= 2 then
                return A.SpinningCraneKick:Show(icon)
            end

            if A.RisingSunKick:IsReady(unit) and ComboStrike(A.RisingSunKick) and
                inMelee then return A.RisingSunKick:Show(icon) end

            if A.FistsOfFury:IsReady(unit) and ComboStrike(A.FistsOfFury) and
                inMelee then return A.FistsOfFury:Show(icon) end

            if A.SpinningCraneKick:IsReady(unit) and
                ComboStrike(A.SpinningCraneKick) and inMelee and unitCount >= 5 then
                return A.SpinningCraneKick:Show(icon)
            end

            if A.BlackoutKick:IsReady(unit) and ComboStrike(A.BlackoutKick) and
                inMelee then return A.BlackoutKick:Show(icon) end

            if A.SpinningCraneKick:IsReady(unit) and
                ComboStrike(A.SpinningCraneKick) and inMelee and unitCount >= 2 then
                return A.SpinningCraneKick:Show(icon)
            end

            if A.SpinningCraneKick:IsReady(unit) and
                ComboStrike(A.SpinningCraneKick) and
                Unit(player):HasBuffs(A.DanceOfChiJi.ID) ~= 0 and inMelee and
                unitCount == 1 then
                return A.SpinningCraneKick:Show(icon)
            end

            if A.ChiWave:IsReady(unit) then
                return A.ChiWave:Show(icon)
            end

            if A.FaelineStomp:IsReady(player) and
                Unit(target):HasDeBuffs(A.FaeExposure.ID, player) == 0 and
                inMelee then return A.FaelineStomp:Show(icon) end

            if A.TigerPalm:IsReady(unit) and ComboStrike(A.TigerPalm) and
                inMelee then return A.TigerPalm:Show(icon) end
        end

        -- if Chi < 6 and A.ExpelHarm:IsReady(player) and
        --     Player:EnergyTimeToMaxPredicted() < 1 then
        --     return A.ExpelHarm:Show(icon)
        -- end

        if Chi < 5 and A.TigerPalm:IsReady(unit) and
            Player:EnergyTimeToMaxPredicted() < 1 then
            return A.TigerPalm:Show(icon)
        end

        if A.RisingSunKick:IsReady(unit) and ComboStrike(A.RisingSunKick) and
            inMelee then return A.RisingSunKick:Show(icon) end

        if A.FaelineStomp:IsReady(player) and
            Unit(target):HasDeBuffs(A.FaeExposure.ID, player) == 0 and inMelee then
            return A.FaelineStomp:Show(icon)
        end

        if A.StrikeOfTheWindlord:IsReady(unit) and inMelee then
            return A.StrikeOfTheWindlord:Show(icon)
        end

        -- if A.RisingSunKick:IsReady(unit) and ComboStrike(A.RisingSunKick) and
        --     inMelee then return A.RisingSunKick:Show(icon) end

        if A.FistsOfFury:IsReady(unit) and ComboStrike(A.FistsOfFury) and
            inMelee then return A.FistsOfFury:Show(icon) end

        -- if A.WhirlingDragonPunch:IsReady(unit) and inMelee then
        --     return A.WhirlingDragonPunch:Show(icon)
        -- end

        if A.SpinningCraneKick:IsReady(unit) and
            ComboStrike(A.SpinningCraneKick) and
            Unit(player):HasBuffs(A.DanceOfChiJi.ID) ~= 0 and inMelee then
            return A.SpinningCraneKick:Show(icon)
        end
        
        if A.BlackoutKick:IsReady(unit) and ComboStrike(A.BlackoutKick) and
            inMelee then return A.BlackoutKick:Show(icon) end

        if A.SpinningCraneKick:IsReady(unit) and
            ComboStrike(A.SpinningCraneKick) and inMelee then
            return A.SpinningCraneKick:Show(icon)
        end

        if A.ChiWave:IsReady(unit) then return A.ChiWave:Show(icon) end

        if A.FaelineStomp:IsReady(player) and
            Unit(target):HasDeBuffs(A.FaeExposure.ID, player) == 0 and inMelee then
            return A.FaelineStomp:Show(icon)
        end

        if A.TigerPalm:IsReady(unit) and ComboStrike(A.TigerPalm) and inMelee then
            return A.TigerPalm:Show(icon)
        end

    end

    if A.IsUnitEnemy("target") then
        unit = "target"
        if BasicDamageRotation(unit) then return true end
    end
end
