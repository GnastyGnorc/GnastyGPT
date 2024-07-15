local _G, setmetatable = _G, setmetatable
local TMW = _G.TMW
local UnitAura, UnitStagger, UnitGUID = _G.UnitAura, _G.UnitStagger, _G.UnitGUID
local Action = _G.Action
local Create = Action.Create
local Unit = Action.Unit
local IsUnitEnemy = Action.IsUnitEnemy
local IsUnitFriendly = Action.IsUnitFriendly
local Player = Action.Player
local BurstIsON = Action.BurstIsON
local MultiUnits = Action.MultiUnits
local ActiveUnitPlates = MultiUnits:GetActiveUnitPlates()
local GetGCD = Action.GetGCD
local GetToggle = Action.GetToggle
local HealingEngine = Action.HealingEngine
local TeamCache = Action.TeamCache
local AuraIsValid = Action.AuraIsValid

local player = "player"
local unit = "target"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

Action[ACTION_CONST_SHAMAN_RESTORATION] = {

    -- Class Tree
    HealingStreamTotem = Create({Type = "Spell", ID = 5394}),
    ChainHeal = Create({Type = "Spell", ID = 1064}),
    FlameShock = Create({Type = "Spell", ID = 188389}),
    LavaBurst = Create({Type = "Spell", ID = 51505}),
    LightningBolt = Create({Type = "Spell", ID = 188196}),
    EarthShield = Create({Type = "Spell", ID = 974}),

    -- Spec Tree
    HealingWave = Create({Type = "Spell", ID = 77472}),
    Riptide = Create({Type = "Spell", ID = 61295}),
    PurifySpirit = Create({Type = "Spell", ID = 77130})

    -- Buffs

    -- Debuffs

}

local A = setmetatable(Action[ACTION_CONST_SHAMAN_RESTORATION],
                       {__index = Action})

local function HealCalc(heal)

    local healamount = 0

    if heal == A.HealingWave then
        healamount = A.HealingWave:GetSpellDescription()[1]
    elseif heal == A.ChainHeal then
        healamount = A.ChainHeal:GetSpellDescription()[1]
    elseif heal == A.Riptide then
        healamount = A.Riptide:GetSpellDescription()[1]
    end

    -- print("(healamount * 1000): ", (healamount * 1000))

    return (healamount * 1000)

end

function isInRange(unit) return A.PurifySpirit:IsInRange(unit) end

A[3] = function(icon)

    local getMembersAll = HealingEngine.GetMembersAll()
    local isMoving = A.Player:IsMoving()
    local inCombat = Unit(player):CombatTime() > 0

    local function HealingRotation(unit)

        local inRange = isInRange(unit)

        if A.PurifySpirit:IsReady(unit) and
            AuraIsValid(unit, "UseDispel", "Dispel") and inRange then
            return A.PurifySpirit:Show(icon)
        end

        if A.HealingStreamTotem:IsReady(player) and
            (A.HealingStreamTotem:GetSpellChargesFrac() > 1.8) and inCombat then
            return A.HealingStreamTotem:Show(icon)
        end

        if A.Riptide:IsReady(unit) and Unit(unit):HealthDeficit() >=
            HealCalc(A.Riptide) and Unit(unit):HasBuffs(A.Riptide.ID) == 0 and
            inRange then return A.Riptide:Show(icon) end

        -- Calc if three targets can be healed with chain heal

        local chTotal = 0
        if A.ChainHeal:IsReady(unit) and Unit(unit):HealthDeficit() >=
            HealCalc(A.ChainHeal) and not isMoving then
            for _, pohUnit in pairs(TeamCache.Friendly.GUIDs) do
                if Unit(pohUnit):HealthDeficit() >= HealCalc(A.ChainHeal) and
                    not Unit(pohUnit):IsDead() and inRange then
                    chTotal = chTotal + 1
                end
                if chTotal >= 3 then
                    -- print("chTotal: ", chTotal)
                    chTotal = 0
                    return A.ChainHeal:Show(icon)
                end
            end
        end

        if A.HealingWave:IsReady(unit) and Unit(unit):HealthDeficit() >=
            HealCalc(A.HealingWave) and inRange then
            return A.HealingWave:Show(icon)
        end

        -- flame shock
        -- lava burst
        -- lightning bolt

        if A.FlameShock:IsReady(target) and
            Unit(target):HasDeBuffs(A.FlameShock.ID) == 0 and
            IsUnitEnemy(target) then return A.FlameShock:Show(icon) end

        if A.LavaBurst:IsReady(target) and IsUnitEnemy(target) then
            return A.LavaBurst:Show(icon)
        end

        if A.LightningBolt:IsReady(target) and IsUnitEnemy(target) then
            return A.LightningBolt:Show(icon)
        end

    end

    if IsUnitFriendly(target) then
        unit = target

        if HealingRotation(unit) then return true end
    elseif IsUnitFriendly(focus) then
        unit = focus

        if HealingRotation(unit) then return true end
    elseif IsUnitEnemy(target) then
        unit = focus

        if HealingRotation(unit) then return true end
    end
end
