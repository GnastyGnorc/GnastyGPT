local _G, setmetatable = _G, setmetatable
local TMW = _G.TMW
local Action = _G.Action
local Create = Action.Create
local Player = Action.Player
local Unit = Action.Unit
local IsUnitEnemy = Action.IsUnitEnemy
local GetToggle = Action.GetToggle

local player = "player"
local unit = "target"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

Action[Action.PlayerClass] = {

    -- Class

    -- Holy
    SealOfRighteousness = Create({Type = "Spell", ID = 20289, useMaxRank = true}),
    Exorcism = Create({Type = "Spell", ID = 415069, useMaxRank = true}),
    HolyLight = Create({Type = "Spell", ID = 1026, useMaxRank = true}),
    Purify = Create({Type = "Spell", ID = 1152, useMaxRank = true}),

    -- Protection

    -- Ret
    CrusaderStrike = Create({Type = "Spell", ID = 407676, useMaxRank = true}),
    BlessingOfMight = Create({Type = "Spell", ID = 19835, useMaxRank = true}),
    SealOfTheCrusader = Create({Type = "Spell", ID = 20305, useMaxRank = true}),
    Judgement = Create({Type = "Spell", ID = 20271, useMaxRank = true}),
    DivineStorm = Create({Type = "Spell", ID = 407778, useMaxRank = true}),

    -- Buffs

    -- Debuffs

}

local A = setmetatable(Action[Action.PlayerClass], {__index = Action})

local function InMelee(unitID)
    -- @return boolean 
    return A.CrusaderStrike:IsInRange(unitID)
end

-- local function isInRange(unit) return A.Detox:IsInRange(unit) end

A[3] = function(icon)

    local inCombat = Unit(player):CombatTime() > 0

    if Unit(player):HealthPercent() < 80 and A.HolyLight:IsReady(player) and
        not inCombat then return A.HolyLight:Show(icon) end

    local function DamageRotation(unit)

        local inMelee = InMelee(unit)

        if Unit(player):HasBuffs(A.BlessingOfMight.ID, true) == 0 and
            A.BlessingOfMight:IsReady(player) then
            return A.BlessingOfMight:Show(icon)
        end

        if A.SealOfRighteousness:IsReady(player) and
            Unit(player):HasBuffs(A.SealOfRighteousness.ID, true) == 0 then
            return A.SealOfRighteousness:Show(icon)
        end

        if A.CrusaderStrike:IsReady(unit) and inMelee then
            return A.SealOfTheCrusader:Show(icon)
        end

        if A.Exorcism:IsReady(unit) and A.Exorcism:IsInRange(unit) then
            return A.Exorcism:Show(icon)
        end

        -- Divine Storm

        if A.DivineStorm:IsReady(unit) and inMelee then
            return A.Purify:Show(icon)
        end

        -- Judgement

        if A.Judgement:IsReady(unit) and A.Judgement:IsInRange(unit) then
            return A.Judgement:Show(icon)
        end

    end

    if IsUnitEnemy(target) then
        unit = target

        if DamageRotation(unit) then return true end
    end
end

