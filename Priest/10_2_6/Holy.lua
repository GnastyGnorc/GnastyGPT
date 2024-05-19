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

Action[ACTION_CONST_PRIEST_HOLY] = {

    -- Class Tree
    PrayerOfMending = Create({Type = "Spell", ID = 33076}),
    Rewnew = Create({Type = "Spell", ID = 139}),
    FlashHeal = Create({Type = "Spell", ID = 2061}),
    Smite = Create({Type = "Spell", ID = 585}),
    ShadowWordPain = Create({Type = "Spell", ID = 589}),
    HolyFire = Create({Type = "Spell", ID = 14914}),

    -- Spec Tree
    HolyWordSanctify = Create({Type = "Spell", ID = 34861}),
    CircleOfHealing = Create({Type = "Spell", ID = 204883}),
    Halo = Create({Type = "Spell", ID = 120517}),
    PrayerOfHealing = Create({Type = "Spell", ID = 596}),
    Purify = Create({Type = "Spell", ID = 527}),
    HolyWordSerenity = Create({Type = "Spell", ID = 2050}),
    Heal = Create({Type = "Spell", ID = 2060}),
    PowerWordLife = Create({Type = "Spell", ID = 373481}),
    DivineStar = Create({Type = "Spell", ID = 110744}),
    DivineWord = Create({Type = "Spell", ID = 372760}),
    HolyWordChastise = Create({Type = "Spell", ID = 88625}),
    HolyNova = Create({Type = "Spell", ID = 132157}),

    -- Racials
    ArcaneTorrent = Create({Type = "Spell", ID = 50613}), -- Tyrs Deliverance
    GiftoftheNaaru = Create({Type = "Spell", ID = 59542}), -- Daybreak
    Fireblood = Create({Type = "Spell", ID = 265221}), -- Attack Holyshock
    Stoneform = Create({Type = "Spell", ID = 20594}), -- Barrier of Faith

    -- Buffs

    SurgeOfLight = Create({Type = "Spell", ID = 114255}),
    Rhapsody = Create({Type = "Spell", ID = 390636})

    -- Debuffs

    -- Trinkets

    -- Talents

}

local A = setmetatable(Action[ACTION_CONST_PRIEST_HOLY], {__index = Action})

local player = "player"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

local function HealCalc(heal)

    local healamount = 0

    if heal == A.FlashHeal then
        healamount = A.FlashHeal:GetSpellDescription()[1]
    elseif heal == A.Heal then
        healamount = A.Heal:GetSpellDescription()[1]
    elseif heal == A.PrayerOfHealing then
        healamount = A.PrayerOfHealing:GetSpellDescription()[2]
    elseif heal == A.CircleOfHealing then
        healamount = A.CircleOfHealing:GetSpellDescription()[2]
    elseif heal == A.Halo then
        healamount = A.Halo:GetSpellDescription()[3]
    elseif heal == A.DivineStar then
        healamount = A.DivineStar:GetSpellDescription()[3] * 2
    elseif heal == A.HolyWordSanctify then
        healamount = A.HolyWordSanctify:GetSpellDescription()[1]
    elseif heal == A.HolyWordSerenity then
        healamount = A.HolyWordSerenity:GetSpellDescription()[1]
    end

    -- print("(healamount * 1000): ", (healamount * 1000))

    return (healamount * 1000)

end

function isInRange(unit) return A.Purify:IsInRange(unit) end

-- TODO
-- -- Use HealingEngine.GetHealthAVG() to determine when to use Aposthosis

A[3] = function(icon)

    local getMembersAll = HealingEngine.GetMembersAll()
    local inCombat = Unit(player):CombatTime() > 0
    local isMoving = A.Player:IsMoving()
    local inMelee = true

    local HolyWordSanctifyHP = 90

    local function HealingRotation(unit)

        local inRange = isInRange(unit)

        if A.Purify:IsReady(unit) and inRange and
            A.AuraIsValid(unit, true, "Dispel") then
            return A.Purify:Show(icon)
        end

        if A.HolyWordSerenity:IsReady(unit) and inRange and
            Unit(unit):HealthDeficit() >= HealCalc(A.HolyWordSerenity) then
            return A.HolyWordSerenity:Show(icon)
        end

        if A.PrayerOfMending:IsReady(unit) and inRange then
            return A.PrayerOfMending:Show(icon)
        end

        if A.PowerWordLife:IsReady(unit) and Unit(unit):HealthPercent() < 35 and
            inRange then return A.PowerWordLife:Show(icon) end

        if A.DivineStar:IsReady(player) and inCombat and inRange then
            return A.DivineStar:Show(icon)
        end

        if A.FlashHeal:IsReady(unit) and inRange and Unit(unit):HealthDeficit() >=
            HealCalc(A.FlashHeal) and Unit(player):HasBuffs(A.SurgeOfLight.ID) ~=
            0 then return A.FlashHeal:Show(icon) end

        if A.FlashHeal:IsReady(unit) and inRange and Unit(unit):HealthDeficit() >=
            HealCalc(A.FlashHeal) then return A.FlashHeal:Show(icon) end

        if A.Heal:IsReady(unit) and inRange and Unit(unit):HealthDeficit() >=
            HealCalc(A.Heal) then return A.Heal:Show(icon) end

        -- if A.DivineWord:IsReady(player) and A.IsUnitEnemy(target) and inCombat then
        --     return A.DivineWord:Show(icon)
        -- end

        if A.HolyWordChastise:IsReady(target) and inRange then
            return A.HolyWordChastise:Show(icon)
        end

        if A.ShadowWordPain:IsReady(target) and
            Unit(target):HasDeBuffs(A.ShadowWordPain.ID, true) == 0 and inRange then
            return A.ShadowWordPain:Show(icon)
        end

        if A.HolyFire:IsReady(target) and inRange then
            return A.HolyFire:Show(icon)
        end

        if A.Smite:IsReady(target) and inRange then
            return A.Smite:Show(icon)
        end

        
    end

    HealingRotation = Action.MakeFunctionCachedDynamic(HealingRotation)

    if IsUnitFriendly(target) then
        unit = target

        if HealingRotation(unit) then return true end
    elseif IsUnitFriendly(focus) then
        unit = focus

        if HealingRotation(unit) then return true end

    elseif IsUnitEnemy(target) then
        unit = target

        if HealingRotation(unit) then return true end
    end

end
