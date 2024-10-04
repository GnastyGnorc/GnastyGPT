-- WW TWW Prepatch
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
local GetToggle = Action.GetToggle
local ActiveUnitPlates = MultiUnits:GetActiveUnitPlates()
local player = "player"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

Action[ACTION_CONST_MONK_WINDWALKER] = {

	-- Class Tree
	BlackoutKick = Create({ Type = "Spell", ID = 100784 }),
	ChiWave = Create({ Type = "Spell", ID = 115098 }),
	ExpelHarm = Create({ Type = "Spell", ID = 322101 }),
	RisingSunKick = Create({ Type = "Spell", ID = 107428 }),
	RisingSunKick1 = Create({ Type = "Spell", ID = 107428, desc = "RSK 1" }),
	RisingSunKick2 = Create({ Type = "Spell", ID = 107428, desc = "RSK 2" }),
	SpinningCraneKick = Create({ Type = "Spell", ID = 101546 }),
	SummonWhiteTigerStatue = Create({ Type = "Spell", ID = 388686 }),
	TigerPalm = Create({ Type = "Spell", ID = 100780 }),
	TigerPalm1 = Create({ Type = "Spell", ID = 100780, desc = "TigerPalm 1" }),
	TigersLust = Create({ Type = "Spell", ID = 116841 }),
	TouchofDeath = Create({ Type = "Spell", ID = 322109 }),
	WhirlingDragonPunch = Create({ Type = "Spell", ID = 152175 }),
	ChiBurst = Create({ Type = "Spell", ID = 461404 }),

	-- Spec Tree

	BoneDustBrew = Action.Create({ Type = "Spell", ID = 386276 }),
	Detox = Action.Create({ Type = "Spell", ID = 115450 }),
	FistsOfFury = Create({ Type = "Spell", ID = 113656 }),
	InvokeXuentheWhiteTiger = Action.Create({ Type = "Spell", ID = 123904 }),
	StormEarthAndFire = Action.Create({ Type = "Spell", ID = 137639 }),
	StrikeOfTheWindlord = Create({ Type = "Spell", ID = 392983 }),
	FaelineStomp = Action.Create({ Type = "Spell", ID = 388193 }),

	-- Buffs
	TeachingsOfTheMonastery = Create({ Type = "Spell", ID = 202090 }),
	DanceOfChiJi = Create({ Type = "Spell", ID = 325202 }),
	SEF = Create({ Type = "Spell", ID = 137639 }),
	freeBlackoutKick = Create({ Type = "Spell", ID = 116768 }),

	-- Debuffs
	Entangle = Create({ Type = "Spell", ID = 408556, Hidden = true }),
	FaeExposure = Create({ Type = "Spell", ID = 395414, Hidden = true }),

	StopCast = Action.Create({ Type = "Spell", ID = 61721, Hidden = true }),
}

local A = setmetatable(Action[ACTION_CONST_MONK_WINDWALKER], { __index = Action })

local function ComboStrike(SpellObject)
	return (not Player:PrevGCD(1, SpellObject))
end

-- add touch of death for bosses
-- cancel fof

-- paralysis/leg sweep some adds/casts

A[3] = function(icon)
	local Chi = Player:Chi()
	local inMelee = A.TigerPalm:IsInRange(target)
	local isMoving = Player:IsMoving()
	local inFoF = Player:IsChanneling() == "Fists of Fury"
	local unitCount = MultiUnits:GetBySpell(A.TigerPalm)
	local totmStacks = Unit(player):HasBuffsStacks(A.TeachingsOfTheMonastery.ID)

	local function BasicDamageRotation(unit)
		if Unit(player):HasDeBuffs(A.Entangle.ID) > 0 and A.TigersLust:IsReady(player) then
			return A.TigersLust:Show(icon)
		end

		if
			A.TouchofDeath:IsReadyByPassCastGCD(unit)
			and ComboStrike(A.TouchofDeath)
			and (Unit(target):HealthPercent() <= 15 or Unit(target):Health() <= Unit(player):Health())
		then
			return A.TouchofDeath:Show(icon)
		end

		if BurstIsON(player) and inMelee then
			if A.InvokeXuentheWhiteTiger:IsReady(player) then
				return A.InvokeXuentheWhiteTiger:Show(icon)
			end

			if A.StormEarthAndFire:IsReady(player) and Unit(player):HasBuffs(A.SEF.ID) == 0 then
				return A.StormEarthAndFire:Show(icon)
			end
		end

		if Chi < 5 and A.TigerPalm:IsReady(unit) and Player:EnergyTimeToMaxPredicted() < 1 then
			return A.TigerPalm:Show(icon)
		end

		if A.WhirlingDragonPunch:IsReady(unit) and inMelee then
			return A.WhirlingDragonPunch:Show(icon)
		end

		if A.StrikeOfTheWindlord:IsReady(unit) and inMelee then
			return A.StrikeOfTheWindlord:Show(icon)
		end

		if A.RisingSunKick:IsReady(unit) and ComboStrike(A.RisingSunKick) and inMelee then
			return A.RisingSunKick:Show(icon)
		end

		if A.FistsOfFury:IsReady(unit) and ComboStrike(A.FistsOfFury) and inMelee then
			return A.FistsOfFury:Show(icon)
		end

		-- Do not overcap teachings of the monastery
		if
			A.BlackoutKick:IsReady(unit)
			and ComboStrike(A.BlackoutKick)
			and (totmStacks == 8 or Unit(player):HasBuffs(A.freeBlackoutKick.ID) ~= 0)
			and inMelee
		then
			return A.BlackoutKick:Show(icon)
		end

		if
			A.SpinningCraneKick:IsReady(unit)
			and ComboStrike(A.SpinningCraneKick)
			and Unit(player):HasBuffs(A.DanceOfChiJi.ID) ~= 0
			and inMelee
		then
			return A.SpinningCraneKick:Show(icon)
		end

		if A.SpinningCraneKick:IsReady(unit) and ComboStrike(A.SpinningCraneKick) and inMelee and unitCount >= 2 then
			return A.SpinningCraneKick:Show(icon)
		end

		if A.ChiBurst:IsReady(player) and inMelee and not isMoving then
			return A.ChiBurst:Show(icon)
		end

		if
			A.BlackoutKick:IsReady(unit)
			and ComboStrike(A.BlackoutKick)
			and A.FistsOfFury:GetCooldown() > 2
			and inMelee
		then
			return A.BlackoutKick:Show(icon)
		end

		-- if A.BlackoutKick:IsReady(unit) and ComboStrike(A.BlackoutKick) and inMelee then
		-- 	return A.BlackoutKick:Show(icon)
		-- end

		if A.TigerPalm:IsReady(unit) and ComboStrike(A.TigerPalm) and inMelee then
			return A.TigerPalm:Show(icon)
		end
	end

	if A.IsUnitEnemy("target") then
		unit = "target"
		if BasicDamageRotation(unit) then
			return true
		end
	end
end
