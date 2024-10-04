local _G, setmetatable = _G, setmetatable
local TMW = _G.TMW
local CNDT = TMW.CNDT
local Env = CNDT.Env
local Action = _G.Action
local Create = Action.Create
local Unit = Action.Unit
local IsUnitEnemy = Action.IsUnitEnemy
local IsUnitFriendly = Action.IsUnitFriendly
local HealingEngine = Action.HealingEngine
local Player = Action.Player
local BurstIsON = Action.BurstIsON
local MultiUnits = Action.MultiUnits

local GetTotemInfo, IsIndoors, UnitIsUnit = _G.GetTotemInfo, _G.IsIndoors,
                                            _G.UnitIsUnit

local player = "player"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

local vivifyHP = 80
local sheilunsHP = 70

Action[ACTION_CONST_MONK_MISTWEAVER] = {
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
    Paralysis = Create({Type = "Spell", ID = 115078}),
    Vivify = Create({Type = "Spell", ID = 116670}),

    -- Spec Tree
    RenewingMist = Create({Type = "Spell", ID = 115151}),
    EnvelopingMist = Create({Type = "Spell", ID = 124682}),
    SheilunsGift = Create({Type = "Spell", ID = 399491}),
    EssenceFont = Create({Type = "Spell", ID = 191837}),
    SoothingMist = Create({Type = "Spell", ID = 115175}),
    ZenPulse = Create({Type = "Spell", ID = 124081}),
    FaelineStomp = Create({Type = "Spell", ID = 388193}),
    Detox = Create({Type = "Spell", ID = 115450}),
    ThunderFocusTea = Create({Type = "Spell", ID = 116680}),
    ManaTea = Create({Type = "Spell", ID = 115294}),

    -- Buffs
    AncientTeachings = Create({Type = "Spell", ID = 388026, Hidden = true}),
    AwakenedFaeline = Create({Type = "Spell", ID = 389387, Hidden = true}),
    InvocationOfYulon = Create({Type = "Spell", ID = 389422, Hidden = true}),
    TeachingsOfTheMonastery = Create({Type = "Spell", ID = 202090}),
    InvokeChiJitheRedCrane = Create({Type = "Spell", ID = 343820}),

    -- Amirdrassil Debuffs
    FyrakkAflame = Create({Type = "Spell", ID = 417807, Hidden = true})

}

local A = setmetatable(Action[ACTION_CONST_MONK_MISTWEAVER], {__index = Action})

local function ChiJiActive()
    -- SummonJadeSerpentStatue
    for i = 1, MAX_TOTEMS do
        local have, name, start, duration = GetTotemInfo(i)

        if name == "Chi-Ji" then return true end

    end
    return false
end

TMW:RegisterCallback("TMW_ACTION_HEALINGENGINE_UNIT_UPDATE",
                     function(callbackEvent, thisUnit, db, QueueOrder)
    local unitID = thisUnit.Unit
    local Role = thisUnit.Role
    local unitHP = thisUnit.realHP
    local HP = thisUnit.HP

    -- Target Aflame Target
    if thisUnit.Unit and
        (Unit(thisUnit.Unit):HasDeBuffs(A.FyrakkAflame.ID) ~= 0) then
        thisUnit.isSelectAble = false
    end

    -- Spread Renewing Mists
    if thisUnit.useHoTs and not QueueOrder.useHoTs[Role] and
        A.RenewingMist:IsReady(unitID) and
        Unit(unitID):HasBuffs(A.RenewingMist.ID, true) == 0 and unitHP <= 100 then
        QueueOrder.useHoTs[Role] = true
        local default = HP - 25
        if Role == "HEALER" then
            thisUnit:SetupOffsets(db.OffsetHealersHoTs, default)
        elseif Role == "TANK" then
            thisUnit:SetupOffsets(db.OffsetTanksHoTs, default)
        else
            thisUnit:SetupOffsets(db.OffsetDamagersHoTs, default)
        end
        return
    end

    -- Spread Evenloping Mists during Yulon
    if thisUnit.useHoTs and not QueueOrder.useHoTs[Role] and
        A.EnvelopingMist:IsReady(unitID) and
        Unit(unitID):HasBuffs(A.EnvelopingMist.ID, true) == 0 and unitHP <= 100 and
        Unit(player):HasBuffs(A.InvocationOfYulon.ID) ~= 0 then
        QueueOrder.useHoTs[Role] = true
        local default = HP - 25
        if Role == "HEALER" then
            thisUnit:SetupOffsets(db.OffsetHealersHoTs, default)
        elseif Role == "TANK" then
            thisUnit:SetupOffsets(db.OffsetTanksHoTs, default)
        else
            thisUnit:SetupOffsets(db.OffsetDamagersHoTs, default)
        end
        return
    end

end)

local function HealCalc(heal)

    local healamount = 0

    if heal == A.EnvelopingMist then
        healamount = A.EnvelopingMist:GetSpellDescription()[1]
    end

    -- print("(healamount * 1000): ", (healamount * 1000))

    return (healamount * 1000)

end

A[3] = function(icon)

    debuffs = {
        417807 -- fyrakk
    }

    local Chi = Player:Chi()
    local inMelee = A.TigerPalm:IsInRange(target)
    local isMoving = Player:IsMoving()
    local isCastingSM = Unit(player):IsCastingRemains(A.SoothingMist.ID) > 0
    local getMembersAll = HealingEngine.GetMembersAll()
    -- local unitCount = MultiUnits:GetByRange(8, 5)
    local unitCount = MultiUnits:GetBySpell(A.TigerPalm)
    local inCombat = Unit("player"):CombatTime() > 0
    local totmStacks = Unit("player"):HasBuffsStacks(
                           A.TeachingsOfTheMonastery.ID)

    local function isInRange(unit) return A.Detox:IsInRange(unit) end

    local function isInRangeMelee(unit) return A.TigerPalm:IsInRange(unit) end

    local function SoothinMistRotation(unit)

        if not isCastingSM and isInRange(unit) and not Unit(unit):IsDead() and
            A.SoothingMist:IsReady(unit) then
            return A.SoothingMist:Show(icon)
        end

        if A.EnvelopingMist:IsReady(unit, nil, nil, isCastingSM) and
            Unit(unit):HasBuffs(A.EnvelopingMist.ID, true) == 0 and
            isInRange(unit) and not Unit(unit):IsDead() then
            return A.EnvelopingMist:Show(icon)
        end

        if Unit(unit):HealthPercent() >= 50 and
            (Unit:Role("TANK") or Unit:Role("HEALER")) and
            A.ZenPulse:IsReady(unit, nil, nil, isCastingSM) and isInRange(unit) and
            not Unit(unit):IsDead() then return A.ZenPulse:Show(icon) end

        if A.Vivify:IsReady(unit, nil, nil, isCastingSM) and isInRange(unit) and
            not Unit(unit):IsDead() then return A.Vivify:Show(icon) end
    end

    local function HealingRotation(unit)

        function isUnitValid(unit)
            return isInRange(unit) and not Unit(unit):IsDead() and
                       IsUnitFriendly(unit)
        end

        if Unit(unit):HasDeBuffs(A.FyrakkAflame.ID) ~= 0 and
            A.Detox:IsReady(unit) and isUnitValid(unit) then
            return A.Detox:Show(icon)
        end

        -- Yulon Rotation
        if Unit(player):HasBuffs(A.InvocationOfYulon.ID) ~= 0 then

            if A.RisingSunKick:IsReady(target) and inMelee and
                not Unit(target):IsDead() then
                return A.RisingSunKick:Show(icon)
            end

            if Unit(unit):HasBuffs(A.EnvelopingMist.ID, true) == 0 and
                A.EnvelopingMist:IsReady(unit) and isUnitValid(unit) then
                return A.EnvelopingMist:Show(icon)
            end
        end

        if ChiJiActive() then

            if A.RisingSunKick:IsReady(target) and inMelee and
                not Unit(target):IsDead() then
                return A.RisingSunKick:Show(icon)
            end

            if A.EnvelopingMist:IsReady(unit) and Unit(unit):HealthDeficit() >=
                HealCalc(A.EnvelopingMist) and
                Unit(unit):HasBuffs(A.EnvelopingMist.ID, true) == 0 and
                isUnitValid(unit) then
                return A.EnvelopingMist:Show(icon)
            end

            if A.BlackoutKick:IsReady(target) and inMelee and
                not Unit(target):IsDead() then
                return A.BlackoutKick:Show(icon)
            end
        end

        if A.Paralysis:IsReady() and Unit(mouseover):Name() ==
            "Incorporeal Being" then return A.Paralysis:Show(icon) end

        if Unit(unit):HasBuffs(A.RenewingMist.ID, true) == 0 and
            A.RenewingMist:IsReady(unit) and isUnitValid(unit) then
            return A.RenewingMist:Show(icon)
        end

        if A.ThunderFocusTea:IsReady(player) and inCombat then
            return A.ThunderFocusTea:Show(icon)
        end

    end

    local function DamageRotation(unitID)

        if A.FaelineStomp:IsReady(player) and not isMoving and
            isInRangeMelee(unitID) and Unit(unitID):IsEnemy() and
            not Unit(unitID):IsDead() and
            Unit(player):HasBuffs(A.AncientTeachings.ID) <= 2 then
            return A.FaelineStomp:Show(icon)
        end

        if A.RisingSunKick:IsReady(unitID) and inMelee and
            not Unit(unitID):IsDead() then
            return A.RisingSunKick:Show(icon)
        end

        if A.BlackoutKick:IsReady(unitID) and
            Unit(player):HasBuffs(A.AwakenedFaeline.ID) ~= 0 and inMelee and
            unitCount >= 3 and totmStacks >= 2 and not Unit(unitID):IsDead() then
            return A.BlackoutKick:Show(icon)
        end

        if A.SpinningCraneKick:IsReady(unitID) and unitCount >= 3 and inMelee and
            not Unit(unitID):IsDead() then
            return A.SpinningCraneKick:Show(icon)
        end

        if A.BlackoutKick:IsReady(unitID) and totmStacks >= 2 and inMelee and
            not Unit(unitID):IsDead() then
            return A.BlackoutKick:Show(icon)
        end

        if A.TigerPalm:IsReady(unitID) and inMelee and not Unit(unitID):IsDead() then
            return A.TigerPalm:Show(icon)
        end

    end

    if IsUnitFriendly(target) then
        unitID = target

        if SoothinMistRotation(unitID) then return true end
    end

    if IsUnitFriendly(focus) then
        unitID = focus

        if HealingRotation(unitID) then return true end
    end

    if IsUnitEnemy(target) then
        unitID = target

        if DamageRotation(unitID) then return true end
    end

end

