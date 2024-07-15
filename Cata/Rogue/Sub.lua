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

    -- Subtlety

    Stealth = Create({Type = "Spell", ID = 1784, useMaxRank = true}),
   
    -- Buffs

    -- Debuffs

}

local A = setmetatable(Action[Action.PlayerClass], {__index = Action})

-- local function InMelee(unitID)
--     -- @return boolean 
--     return A.CrusaderStrike:IsInRange(unitID)
-- end

-- local function isInRange(unit) return A.Detox:IsInRange(unit) end

A[3] = function(icon)

    local inCombat = Unit(player):CombatTime() > 0

    if Unit(player):HealthPercent() < 80 and A.HolyLight:IsReady(player) and
        not inCombat then return A.HolyLight:Show(icon) end

    local function DamageRotation(unit)

        -- local inMelee = InMelee(unit)

        if not inCombat and A.Stealth:IsReady(player) then
            return A.Stealth:Show(icon)
        end
    
    end

    if IsUnitEnemy(target) then
        unit = target

        if DamageRotation(unit) then return true end
    end
end

