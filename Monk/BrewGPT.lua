-- Brew Wowhead Paladin Rotation v1.0.0
-- Last Update: 10/19/2024

-- TODO: Vivacious Vivify
-- Don't brew when pulling
-- 

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
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

Action[ACTION_CONST_MONK_BREWMASTER] = {
	-- Class Tree

	BlackoutKick = Action.Create({ Type = "Spell", ID = 205523 }),
	ChiWave = Action.Create({ Type = "Spell", ID = 115098 }),
	DampenHarm = Action.Create({ Type = "Spell", ID = 122278 }),
	DiffuseMagic = Action.Create({ Type = "Spell", ID = 122783 }),
	ExpelHarm = Action.Create({ Type = "Spell", ID = 322101 }),
	FortifyingBrew = Action.Create({ Type = "Spell", ID = 115203 }),
	RisingSunKick = Action.Create({ Type = "Spell", ID = 107428 }),
	SpinningCraneKick = Action.Create({ Type = "Spell", ID = 322729 }),
	SummonWhiteTigerStatue = Action.Create({ Type = "Spell", ID = 388686 }),
	TigerPalm = Action.Create({ Type = "Spell", ID = 100780 }),
	TouchOfDeath = Action.Create({ Type = "Spell", ID = 322109 }),
	Paralysis = Create({ Type = "Spell", ID = 115078 }),

	-- Spec Tree

	BonedustBrew = Action.Create({ Type = "Spell", ID = 386276 }),
	BreathOfFire = Action.Create({ Type = "Spell", ID = 115181 }),
	CelestialBrew = Action.Create({ Type = "Spell", ID = 322507 }),
	Detox = Action.Create({ Type = "Spell", ID = 218164 }),
	ExplodingKeg = Action.Create({ Type = "Spell", ID = 325153 }),
	HealingElixir = Action.Create({ Type = "Spell", ID = 122281 }),
	KegSmash = Action.Create({ Type = "Spell", ID = 121253 }),
	PurifyingBrew = Action.Create({ Type = "Spell", ID = 119582 }),
	RushingJadeWind = Action.Create({ Type = "Spell", ID = 116847 }),
	WeaponsOfOrder = Action.Create({ Type = "Spell", ID = 387184 }),
	ZenMeditation = Action.Create({ Type = "Spell", ID = 115176 }),
	InvokeNiuzao = Action.Create({ Type = "Spell", ID = 132578 }),

	-- Buffs
	WeaponsOfOrderBuff = Action.Create({
		Type = "Spell",
		ID = 322695,
		Hidden = true,
	}),
	BlackoutComboBuff = Action.Create({
		Type = "Spell",
		ID = 196736,
		Hidden = true,
	}),
	CharredPassionsBuff = Action.Create({
		Type = "Spell",
		ID = 386963,
		Hidden = true,
	}),
	PurifiedChi = Action.Create({
		Type = "Spell",
		ID = 325092,
		Hidden = true,
	}),

	-- Debuffs
	StaggerHeavy = Action.Create({ Type = "Spell", ID = 124273, Hidden = true }),
	StaggerModerate = Action.Create({ Type = "Spell", ID = 124274, Hidden = true }),
	StaggerLight = Action.Create({ Type = "Spell", ID = 124275, Hidden = true }),
	WeaponsOfOrderDebuff = Action.Create({
		Type = "Spell",
		ID = 387179,
		Hidden = true,
	}),

	-- Talents
	BlackoutCombo = Action.Create({ Type = "Spell", ID = 196736 }),
	SpiritOfTheOx = Action.Create({ Type = "Spell", ID = 400629 }),

	-- Racials
	ArcaneTorrent = Create({ Type = "Spell", ID = 50613 }),
	GiftoftheNaaru = Action.Create({ Type = "Spell", ID = 59544 }),
	WarStomp = Action.Create({ Type = "Spell", ID = 20549 }),
	Stoneform = Action.Create({ Type = "Spell", ID = 20594 }),
	Fireblood = Action.Create({ Type = "Spell", ID = 265221 }),
	Regeneratin = Create({ Type = "Spell", ID = 291944 }),


}

local A = setmetatable(Action[ACTION_CONST_MONK_BREWMASTER], { __index = Action })

local function HasStagger()
	return UnitStagger(player) > 0
end

A[3] = function(icon)
	local isMoving = A.Player:IsMoving()
	local lastCast = A.LastPlayerCastID
	local inMelee = A.TigerPalm:IsInRange(target)
	local unitCount = MultiUnits:GetBySpell(A.TigerPalm)
	local combatTime = Unit("player"):CombatTime()
	local energy = Player:Energy()
	local orbCount = A.ExpelHarm:GetCount()
	local orbHealing = A.SpiritOfTheOx:GetSpellDescription()[2]

	if A.TouchOfDeath:IsReady(unit) then
		return A.TouchOfDeath:Show(icon)
	end

	if A.PurifyingBrew:IsReady(player) and (A.PurifyingBrew:GetSpellChargesFrac() > 1.8) and HasStagger() and combatTime > 5 then
		return A.PurifyingBrew:Show(icon)
	end

	if A.CelestialBrew:IsReady(player) and HasStagger() and A.PurifyingBrew:GetSpellCharges() ~= 2 then
		return A.CelestialBrew:Show(icon)
	end

	if
		A.ExpelHarm:IsReady(player)
		and orbCount >= 2
		and ((A.ExpelHarm:GetSpellDescription()[1] + (orbCount * orbHealing)) <= Unit(player):HealthDeficit())
	then
		return A.ExpelHarm:Show(icon)
	end

	function DamageRotation(unit)
		-- RushingJade Prepull
		if
			A.KegSmash:IsReady("player")
			and Unit("target"):IsEnemy()
			and Unit("target"):GetRange() <= 15
			and Unit("player"):CombatTime() == 0
		then
			return A.KegSmash:Show(icon)
		end

		if A.BlackoutKick:IsReady(unit) and inMelee then
			return A.BlackoutKick:Show(icon)
		end

		if A.KegSmash:IsReady(unit) and (A.KegSmash:GetSpellChargesFrac() > 1.8) then
			return A.KegSmash:Show(icon)
		end

		if A.BreathOfFire:IsReady(player) and inMelee then
			return A.BreathOfFire:Show(icon)
		end

		if A.BlackoutKick:IsReady(unit) and Unit(player):HasBuffs(A.CharredPassionsBuff.ID) ~= 0 and inMelee then
			return A.BlackoutKick:Show(icon)
		end

		if A.ExplodingKeg:IsReady(player) and inMelee then
			return A.ExplodingKeg:Show(icon)
		end

		if A.WeaponsOfOrder:IsReady(player) and inMelee then
			return A.WeaponsOfOrder:Show(icon)
		end

		if A.RisingSunKick:IsReady(unit) and inMelee then
			return A.RisingSunKick:Show(icon)
		end

		if
			A.SpinningCraneKick:IsReady(unit)
			and Unit(player):HasBuffs(A.CharredPassionsBuff.ID) ~= 0
			and inMelee
			and unitCount > 2
		then
			return A.SpinningCraneKick:Show(icon)
		end

		if A.KegSmash:IsReady(unit) then
			return A.KegSmash:Show(icon)
		end

		if A.ChiWave:IsReady(unit) then
			return A.ChiWave:Show(icon)
		end

		if A.SpinningCraneKick:IsReady(player) and inMelee and unitCount > 2 and not (A.KegSmash:IsReady()) then
			return A.SpinningCraneKick:Show(icon)
		end

		if A.TigerPalm:IsReady(unit) and inMelee and not (A.KegSmash:IsReady()) then
			return A.TigerPalm:Show(icon)
		end
	end

	if IsUnitEnemy(unit) then
		if DamageRotation(unit) then
			return true
		end
	end
end
