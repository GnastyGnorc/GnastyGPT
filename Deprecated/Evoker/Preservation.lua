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

Action[ACTION_CONST_EVOKER_PRESERVATION] = {

    -- Class Tree
    

    -- Spec Tree


    -- Buffs


    -- Debuffs


    -- Racial

}

local A = setmetatable(Action[ACTION_CONST_EVOKER_PRESERVATION],
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
-- Handle Clearcasting

A[3] = function(icon)

    local getMembersAll = HealingEngine.GetMembersAll()
    local PartyGroup = not A.IsInPvP and TeamCache.Friendly.Size <= 5
    local RaidGroup = not A.IsInPvP and TeamCache.Friendly.Size > 5
    local inCombat = Unit(player):CombatTime() > 0

    local comboPoints = Player:ComboPoints()

    -- print("HealingEngine.GetHealthAVG(): ", HealingEngine.GetHealthAVG())

    local function HealingRotation(unit)

        

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
