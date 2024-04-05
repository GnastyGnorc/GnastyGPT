local _G, setmetatable = _G, setmetatable
local TMW = _G.TMW
local UnitAura, UnitStagger, UnitGUID = _G.UnitAura, _G.UnitStagger, _G.UnitGUID
local Action = _G.Action
local Create = Action.Create
local Unit = Action.Unit
local Player = Action.Player
local IsUnitEnemy = Action.IsUnitEnemy
local IsUnitFriendly = Action.IsUnitFriendly
local HealingEngine = Action.HealingEngine
local GetToggle = Action.GetToggle
local TeamCache = Action.TeamCache

Action[ACTION_CONST_DRUID_RESTORATION] = {
    -- Class Tree
    Moonfire = Create({Type = "Spell", ID = 8921}),
    Sunfire = Create({Type = "Spell", ID = 93402}),
    Wrath = Create({Type = "Spell", ID = 190984}),
    Starsurge = Create({Type = "Spell", ID = 78674}),
    Regrowth = Create({Type = "Spell", ID = 8936}),
    Rejuvenation = Create({Type = "Spell", ID = 774}),
    Swiftmend = Create({Type = "Spell", ID = 18562}),

    -- Spec Tree
    NewMoon = Create({Type = "Spell", ID = 274281}),
    Starfall = Create({Type = "Spell", ID = 191034}),
    NaturesCure = Create({Type = "Spell", ID = 88423}),
    AdaptiveSwarm = Create({Type = "Spell", ID = 391888}),
    Lifebloom = Create({Type = "Spell", ID = 33763}),
    Swiftmend = Create({Type = "Spell", ID = 18562}),
    WildGrowth = Create({Type = "Spell", ID = 48438}),
    GroveGuardians = Create({Type = "Spell", ID = 102693}),
    CenarionWard = Create({Type = "Spell", ID = 102351}),

    -- Debuffs
    MoonfireDebuff = Create({Type = "Spell", ID = 164812, Hidden = true}),
    SunfireDebuff = Create({Type = "Spell", ID = 164815, Hidden = true}),

    -- Racial
    Shadowmeld = Action.Create({Type = "Spell", ID = 58984}),
    Darkflight = Create({Type = "Spell", ID = 68992})
}

local A = setmetatable(Action[ACTION_CONST_DRUID_RESTORATION],
                       {__index = Action})

local player = "player"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

local function HealCalc(heal)

    local healamount = 0

    if heal == A.AdaptiveSwarm then
        healamount = A.AdaptiveSwarm:GetSpellDescription()[1]
    elseif heal == A.Lifebloom then
        healamount = A.Lifebloom:GetSpellDescription()[1]
    elseif heal == A.Swiftmend then
        healamount = A.Swiftmend:GetSpellDescription()[1]
    elseif heal == A.Regrowth then
        healamount = A.Regrowth:GetSpellDescription()[1]
    elseif heal == A.Rejuvenation then
        healamount = A.Rejuvenation:GetSpellDescription()[1]
    end

    return (healamount * 1000)

end

function isInRange(unit) return A.NaturesCure:IsInRange(unit) end

-- TODO
-- Keep lifebloom on myself and tank

A[3] = function(icon)

    local getMembersAll = HealingEngine.GetMembersAll()
    local PartyGroup = not A.IsInPvP and TeamCache.Friendly.Size <= 5
    local RaidGroup = not A.IsInPvP and TeamCache.Friendly.Size > 5
    local inCombat = Unit(player):CombatTime() > 0
    local isMoving = A.Player:IsMoving()

    local function HealingRotation(unit)

        -- Dispel Rotation -- 

        for i = 1, #getMembersAll do
            local currentUnit = getMembersAll[i].Unit
            if isInRange(unit) then

                for _, v in ipairs(TMW_GLOBAL_DISPEL_LIST) do
                    if Unit(currentUnit):HasDeBuffs(v) ~= 0 then
                        HealingEngine.SetTarget(currentUnit, 0.5)
                        break
                    end
                end
            end
        end

        if A.NaturesCure:IsReady(unit) and isInRange(unit) then
            for _, v in ipairs(TMW_GLOBAL_DISPEL_LIST) do
                if Unit(unit):HasDeBuffs(v) ~= 0 then
                    return A.NaturesCure:Show(icon)
                end
            end
        end

        -- Dispel Rotation End -- 

        if A.CenarionWard:IsReady(unit) and isInRange(unit) and
            Unit(unit):Role("TANK") then return A.CenarionWard:Show(icon) end

        if A.AdaptiveSwarm:IsReady(unit) and isInRange(unit) and
            Unit(unit):HealthDeficit() >= HealCalc(A.AdaptiveSwarm) and
            Unit(unit):HasBuffs(A.AdaptiveSwarm.ID) == 0 then
            return A.AdaptiveSwarm:Show(icon)
        end

        -- lifebloom me
        if A.Lifebloom:IsReady(player) and
            Unit(player):HasBuffs(A.Lifebloom.ID, true) <= 2 and inCombat then
            return A.Darkflight:Show(icon)
        end

        -- lifebloom tank
        if A.Lifebloom:IsReady(unit) and Unit(unit):Role("TANK") and
            isInRange(unit) and Unit(unit):HasBuffs(A.Lifebloom.ID, true) <= 2 and
            inCombat then return A.Lifebloom:Show(icon) end

        if A.GroveGuardians:IsReady(player) and
            A.GroveGuardians:GetSpellChargesFrac() > 2.8 then
            return A.Shadowmeld:Show(icon)
        end

        -- if A.GroveGuardians:IsReady(player) and
        --     A.GroveGuardians:GetSpellChargesFrac() > 0.8 then
        --     return A.Shadowmeld:Show(icon)
        -- end

        -- and HealingEngine.GetHealthAVG() <= 85

        if A.Swiftmend:IsReady(unit) and isInRange(unit) and
            Unit(unit):HealthDeficit() >= HealCalc(A.Swiftmend) and
            (Unit(unit):HasBuffs(A.Regrowth.ID, true) ~= 0 or
                Unit(unit):HasBuffs(A.Rejuvenation.ID, true) ~= 0) then
            return A.Swiftmend:Show(icon)
        end

        if A.WildGrowth:IsReady(unit) and isInRange(unit) and
            HealingEngine.GetHealthAVG() <= 65 then
            return A.WildGrowth:Show(icon)
        end

        if A.Regrowth:IsReady(unit) and isInRange(unit) and
            Unit(unit):HealthPercent() <= 70 and not isMoving then
            return A.Regrowth:Show(icon)
        end

        if A.Rejuvenation:IsReady(unit) and isInRange(unit) and
            Unit(unit):HealthPercent() <= 99 and
            Unit(unit):HasBuffs(A.Rejuvenation.ID, true) == 0 then
            return A.Rejuvenation:Show(icon)
        end

        if A.Moonfire:IsReady(target) and
            Unit(target):HasDeBuffs(A.MoonfireDebuff.ID, true) <= 1 then
            return A.Moonfire:Show(icon)
        end

        if A.Sunfire:IsReady(target) and
            Unit(target):HasDeBuffs(A.SunfireDebuff.ID, true) <= 1 then
            return A.Sunfire:Show(icon)
        end

        if A.Wrath:IsReady(target) then return A.Wrath:Show(icon) end

    end

    if IsUnitFriendly(target) then
        unit = target

        if HealingRotation(unit) then return true end
    elseif IsUnitFriendly(focus) then
        unit = focus

        if HealingRotation(unit) then return true end
    end

    if IsUnitEnemy(target) then
        unitID = target

        if HealingRotation(unitID) then return true end
    end
end
