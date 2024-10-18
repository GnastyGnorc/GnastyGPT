local _G, setmetatable = _G, setmetatable
local TMW = _G.TMW
local UnitAura, UnitStagger, UnitGUID = _G.UnitAura, _G.UnitStagger, _G.UnitGUID
local ACTION = _G.Action
local Create = Action.Create
local Unit = Action.Unit
local Player = Action.Player
local BurstIsON = Action.BurstIsON
local MultiUnits = Action.MultiUnits

local Action = _G.Action
local IsUnitEnemy = Action.IsUnitEnemy
local BurstIsON = Action.BurstIsON

local player = "player"
local unit = "target"

Action[ACTION_CONST_WARRIOR_PROTECTION] = {
	-- Class Abilities
	ShieldSlam = Action.Create({ Type = "Spell", ID = 23922 }),
	ImpendingVictory = Action.Create({ Type = "Spell", ID = 202168 }),
	ThunderClap = Action.Create({ Type = "Spell", ID = 6343 }),
	Execute = Action.Create({ Type = "Spell", ID = 5308 }),
	ShieldBlock = Action.Create({ Type = "Spell", ID = 2565 }),
	Pummel = Action.Create({ Type = "Spell", ID = 6552 }),
    Ravager = Action.Create({ Type = "Spell", ID = 228920 }),
    Avatar = Action.Create({ Type = "Spell", ID = 401150 }),
    ChampionsSpear = Action.Create({ Type = "Spell", ID = 376079 }),

	-- Spec Abilities
	Revenge = Action.Create({ Type = "Spell", ID = 6572 }),
	IgnorePain = Action.Create({ Type = "Spell", ID = 190456 }),

	-- Buffs
	RevengeBuff = Action.Create({ Type = "Spell", ID = 5302 }),
	ShieldBlockBuff = Action.Create({ Type = "Spell", ID = 132404 }),
	ViolentOutburst = Action.Create({ Type = "Spell", ID = 313255 }),

	-- Racials
	ArcaneTorrent = Create({ Type = "Spell", ID = 50613 }),
}

local A = setmetatable(Action[ACTION_CONST_WARRIOR_PROTECTION], { __index = Action })

local function IsInMelee()
	return A.ShieldSlam:IsInRange("target")
end

A[3] = function(icon)
	local rage = Player:Rage()
	local unitCount = MultiUnits:GetBySpell(A.Pummel)
	local inMelee = A.Pummel:IsInRange(target)

	function DamageRotation(unit)
		if BurstIsON(player) and inMelee then
			-- Ravager
			-- Avatar
			-- Champions Spear
			-- Shield Charge

            if A.Ravager:IsReady(player) then
                return A.Ravager:Show(icon)
            end

            if A.Avatar:IsReady(player) then
                return A.Avatar:Show(icon)
            end

            if A.ChampionsSpear:IsReady(player) then
                return A.ChampionsSpear:Show(icon)
            end
		end

		if A.ImpendingVictory:IsReady(unit) and Unit(player):HealthPercent() < 50 then
			return A.ImpendingVictory:Show(icon)
		end

		if A.ShieldBlock:IsReady(player) and Unit(player):HasBuffs(A.ShieldBlockBuff.ID) < 2 and inMelee then
			return A.ArcaneTorrent:Show(icon)
		end

		if A.IgnorePain:IsReady(player) and rage >= 60 then
			return A.IgnorePain:Show(icon)
		end

		-- Consume Violent Outburst w/ Shield Slam  or Thunderclap with 4+ targets

		if A.ShieldSlam:IsReady(unit) then
			return A.ShieldSlam:Show(icon)
		end

		if A.ThunderClap:IsReady(player) and inMelee then
			return A.ThunderClap:Show(icon)
		end

		-- Revenge on aoe or fish for shield slam resets

		if A.Revenge:IsReady(player) and IsInMelee() then
			return A.Revenge:Show(icon)
		end

		-- Execute vs 4 or less targets
	end

	if IsUnitEnemy(unit) then
		if DamageRotation(unit) then
			return true
		end
	end
end
