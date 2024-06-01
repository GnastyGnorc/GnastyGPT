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
local GetToggle = Action.GetToggle
local player = "player"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

Action[Action.PlayerClass] = {

    -- Class

    -- SPells

    CrusaderStrike = Create({Type = "Spell", ID = 35395, useMaxRank = true}),
    TemplarsVerdict = Create({Type = "Spell", ID = 85256, useMaxRank = true}),
    Judgment = Create({Type = "Spell", ID = 20271, useMaxRank = true}),
    Rebuke = Create({Type = "Spell", ID = 96231, useMaxRank = true}),
    Exorcism = Create({Type = "Spell", ID = 879, useMaxRank = true}),
    HolyWrath = Create({Type = "Spell", ID = 2812, useMaxRank = true}),
    DivineStorm = Create({Type = "Spell", ID = 53385, useMaxRank = true}),
    Consecration = Create({Type = "Spell", ID = 26573, useMaxRank = true}),
    DivinePlease = Create({Type = "Spell", ID = 54428, useMaxRank = true}),
    DivineProtection = Create({Type = "Spell", ID = 498, useMaxRank = true}),
    Inquisition = Create({Type = "Spell", ID = 84963, useMaxRank = true}),

    -- Buffs

    DivinePurpose = Create({Type = "Spell", ID = 90174, useMaxRank = true}),
    TheArtOfWar = Create({Type = "Spell", ID = 59578, useMaxRank = true}),

    -- Debuffs

    -- Just using icon
    CrusaderAura = Create({Type = "Spell", ID = 32223, useMaxRank = true}), -- Templars Verdict
    RetributionAura = Create({Type = "Spell", ID = 7294, useMaxRank = true}), -- Holy Wrath
    AvengingWrath = Create({Type = "Spell", ID = 31884, useMaxRank = true}), -- DivineStorm
    ArcaneTorrent = Create({Type = "Spell", ID = 28730, useMaxRank = true}) -- Inquisition

}

local A = setmetatable(Action[Action.PlayerClass], {__index = Action})

-- local function InMelee(unitID)
--     -- @return boolean 
--     return A.CrusaderStrike:IsInRange(unitID)
-- end

-- local function isInRange(unit) return A.Detox:IsInRange(unit) end

A[3] = function(icon)

    local inCombat = Unit(player):CombatTime() > 0
    local HolyPower = Player:HolyPower()
    local inMelee = A.CrusaderStrike:IsInRange(target)
    local unitCount = MultiUnits:GetBySpell(A.Rebuke)

    -- print("HolyPower: ", HolyPower)
    -- print("inMelee: ", inMelee)
    -- print("unitCount: ", unitCount)

    -- if Unit(player):HealthPercent() < 80 and A.HolyLight:IsReady(player) and
    --     not inCombat then return A.HolyLight:Show(icon) end

    local function DamageRotation(unit)

        -- local inMelee = InMelee(unit)

        if A.Inquisition:IsReady(player) and HolyPower >= 1 and
            Unit(player):HasBuffs(A.Inquisition.ID) < 2 then
            return A.ArcaneTorrent:Show(icon)
        end

        if A.TemplarsVerdict:IsReady(unit) and HolyPower >= 3 then
            return A.CrusaderAura:Show(icon)
        end

        if A.CrusaderStrike:IsReady(unit) and HolyPower < 3 and unitCount < 4 then
            return A.CrusaderStrike:Show(icon)
        end

        if A.DivineStorm:IsReady(unit) and HolyPower >= 3 and unitCount >= 4 then
            return A.AvengingWrath:Show(icon)
        end

        if A.TemplarsVerdict:IsReady(unit) and
            Unit(player):HasBuffs(A.DivinePurpose.ID) ~= 0 then
            return A.CrusaderAura:Show(icon)
        end

        if A.Exorcism:IsReady(unit) and Unit(player):HasBuffs(A.TheArtOfWar.ID) ~=
            0 then return A.Exorcism:Show(icon) end

        if A.Judgment:IsReady(unit) then return A.Judgment:Show(icon) end

        if A.HolyWrath:IsReady(player) and inMelee then
            return A.RetributionAura:Show(icon)
        end

        if A.Consecration:IsReady(player) and inMelee then
            return A.Consecration:Show(icon)
        end

        if A.DivinePlease:IsReady(player) then
            return A.DivinePlease:Show(icon)
        end

    end

    if A.IsUnitEnemy(target) then
        unit = target

        if DamageRotation(unit) then return true end
    end
end

