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

Action[ACTION_CONST_PRIEST_SHADOW] = {

    -- Class Tree
    Smite = Create({Type = "Spell", ID = 585}),

    -- Spec Tree


    -- Racials
    ArcaneTorrent = Create({Type = "Spell", ID = 50613}), -- Tyrs Deliverance
    GiftoftheNaaru = Create({Type = "Spell", ID = 59542}), -- Daybreak
    Fireblood = Create({Type = "Spell", ID = 265221}), -- Attack Holyshock
    Stoneform = Create({Type = "Spell", ID = 20594}), -- Barrier of Faith

    -- Buffs


    -- Debuffs

    -- Trinkets

    -- Talents

}

local A = setmetatable(Action[ACTION_CONST_PRIEST_SHADOW], {__index = Action})

local player = "player"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

-- function isInRange(unit) return A.Purify:IsInRange(unit) end

-- TODO

A[3] = function(icon)

    local getMembersAll = HealingEngine.GetMembersAll()
    local inCombat = Unit(player):CombatTime() > 0
    local isMoving = A.Player:IsMoving()

    local function DamageRotation(unit)

        if A.Smite:IsReady(unit) and inRange then
            return A.Smite:Show(icon)
        end

    end

    if IsUnitEnemy(target) then
        unit = target

        if DamageRotation(unit) then return true end
    end

end
