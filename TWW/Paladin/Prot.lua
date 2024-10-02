-- Prot Paladin Rotation v1.0.1
-- Last Update: 10/01/2024

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

Action[ACTION_CONST_PALADIN_PROTECTION] = {
	-- Class Abilities
	ShieldOfTheRighteous = Create({ Type = "Spell", ID = 53600 }),
	Consecration = Create({ Type = "Spell", ID = 26573 }),
	WordOfGlory = Create({ Type = "Spell", ID = 85673 }),
	Judgement = Create({ Type = "Spell", ID = 275779 }),
	HammerOfWrath = Create({ Type = "Spell", ID = 24275 }),
	BlessingOfFreedom = Create({ Type = "Spell", ID = 1044 }),

	-- Spec Abilities
	AvengersShield = Create({ Type = "Spell", ID = 31935 }),
	BlessedHammer = Create({ Type = "Spell", ID = 204019 }),
	EyeOfTyr = Create({ Type = "Spell", ID = 387174 }),

	-- Hero Talents
	HolyBulwark = Create({ Type = "Spell", ID = 432459 }),
	SacredWeapon = Create({ Type = "Spell", ID = 432472 }),

	-- Buffs
	ConsecrationBuff = Create({ Type = "Spell", ID = 188370, Hidden = true }),
	ShiningLight = Create({ Type = "Spell", ID = 327510, Hidden = true }),
	DivinePurpose = Create({ Type = "Spell", ID = 223819, Hidden = true }),
	BastionOfLight = Create({ Type = "Spell", ID = 378974, Hidden = true }),

	-- Debuffs
	Entangle = Create({ Type = "Spell", ID = 408556, Hidden = true }),
	DecayStrike = Create({ Type = "Spell", ID = 373917, Hidden = true }),

	-- Racials
	Regeneratin = Create({ Type = "Spell", ID = 291944 }),
}

local A = setmetatable(Action[ACTION_CONST_PALADIN_PROTECTION], { __index = Action })

local function IsInMelee(unit)
	return true
end

A[3] = function(icon)
	local HolyPower = Player:HolyPower()
	local inMelee = true

	function DamageRotation(unit)
		if
			A.WordOfGlory:IsReady(player)
			and Unit(player):HasBuffs(A.ShiningLight.ID) ~= 0
			and Unit(player):HealthPercent() < 50
		then
			return A.WordOfGlory:Show(icon)
		end

		if A.SacredWeapon:IsReady(player) then
			return A.Regeneratin:Show(icon)
		end

		if
			A.ShieldOfTheRighteous:IsReady(player)
			and IsInMelee(unit)
			and HolyPower >= 3
			or (Unit(player):HasBuffs(A.DivinePurpose.ID) ~= 0)
		then
			return A.ShieldOfTheRighteous:Show(icon)
		end

		if A.AvengersShield:IsReady(unit) then
			return A.AvengersShield:Show(icon)
		end

		if A.Consecration:IsReady(player) and IsInMelee(unit) and Unit(player):HasBuffs(A.ConsecrationBuff.ID) == 0 then
			return A.Consecration:Show(icon)
		end

		if A.HammerOfWrath:IsReady(unit) then
			return A.HammerOfWrath:Show(icon)
		end

		if A.Judgement:IsReady(unit) then
			return A.Judgement:Show(icon)
		end

		-- if A.EyeOfTyr:IsReady(player) and MultiUnits:GetByRange(4) >= 2 then
		-- 	return A.EyeOfTyr:Show(icon)
		-- end

		if A.HolyBulwark:IsReady(player) then
			return A.Regeneratin:Show(icon)
		end

		if A.BlessedHammer:IsReady(player) and IsInMelee(unit) then
			return A.BlessedHammer:Show(icon)
		end

		if
			A.WordOfGlory:IsReady(player)
			and Unit(player):HasBuffs(A.ShiningLight.ID) ~= 0
			and Unit(player):HealthPercent() < 50
		then
			return A.WordOfGlory:Show(icon)
		end

		-- if A.Judgement:IsReady(unit) then return A.Judgement:Show(icon) end

		if A.Consecration:IsReady(player) and IsInMelee(unit) then
			return A.Consecration:Show(icon)
		end
	end

	if IsUnitEnemy(unit) then
		if DamageRotation(unit) then
			return true
		end
	end
end
