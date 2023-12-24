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
    Skyreach = Create({Type = "Spell", ID = 393047}),

    -- Debuffs
    Entangle = Create({Type = "Spell", ID = 408556, Hidden = true}),
    FaeExposure = Create({Type = "Spell", ID = 395414, Hidden = true}),
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

        local skyReachBuff = Unit(target):HasDeBuffs(A.Skyreach.ID)
        local skyReachExhaustion = Unit(target):HasDeBuffs(A.SkyreachExhaustion.ID)

        -- print(Chi)
        -- print('-------')
        -- print("A.RisingSunKick:IsReadyByPassCastGCD(unit) and inFoF: ",
        --       A.RisingSunKick:IsReadyByPassCastGCD(unit) and inFoF)

        -- print("unitCount: ", unitCount)

        -- Dungeon Afixes --
        if Unit(player):HasDeBuffs(A.Entangle.ID) > 0 and
            A.TigersLust:IsReady(player) then
            return A.TigersLust:Show(icon)
        end

        if A.Paralysis:IsReady() and Unit(mouseover):Name() ==
            "Incorporeal Being" then return A.Paralysis:Show(icon) end

        --

        if A.TouchofDeath:IsReadyByPassCastGCD(unit) and
            ComboStrike(A.TouchofDeath) and
            (Unit(target):HealthPercent() <= 15 or Unit(target):Health() <=
                Unit(player):Health()) then
            return A.TouchofDeath:Show(icon)
        end

        -- Add vivacious vivify

        --

        if BurstIsON(player) and inMelee then

            ----
        end

        if Unit(player):HasBuffs(A.SerenityBuff.ID) ~= 0 then

            ----

        end



    end

    if A.IsUnitEnemy("target") then
        unit = "target"
        if BasicDamageRotation(unit) then return true end
    end
end
