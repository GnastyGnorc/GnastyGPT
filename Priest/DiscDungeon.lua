-- Disc Dungeon Rotation v1.0.0
-- Last Update: 10/23/2024

local _G, setmetatable = _G, setmetatable
local TMW = _G.TMW
local UnitAura, UnitStagger, UnitGUID = _G.UnitAura, _G.UnitStagger, _G.UnitGUID
local Action = _G.Action
local Create = Action.Create
local Unit = Action.Unit
local IsUnitEnemy = Action.IsUnitEnemy
local IsUnitFriendly = Action.IsUnitFriendly
local Player = Action.Player
local BurstIsON = Action.BurstIsON
local MultiUnits = Action.MultiUnits
local ActiveUnitPlates = MultiUnits:GetActiveUnitPlates()
local GetGCD = Action.GetGCD
local GetToggle = Action.GetToggle
local HealingEngine = Action.HealingEngine
local TeamCache = Action.TeamCache

local player = "player"
local unit = "target"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

Action[ACTION_CONST_PRIEST_DISCIPLINE] = {

	-- Class Tree
	FlashHeal = Create({ Type = "Spell", ID = 2061 }),
	Halo = Create({ Type = "Spell", ID = 120517 }),
	MindBlast = Create({ Type = "Spell", ID = 8092 }),
	PowerWordLife = Create({ Type = "Spell", ID = 373481 }),
	PowerWordShield = Create({ Type = "Spell", ID = 17 }),
	Renew = Create({ Type = "Spell", ID = 139 }),
	ShadowWordDeath = Create({ Type = "Spell", ID = 32379 }),
	Smite = Create({ Type = "Spell", ID = 585 }),
	ShadowFiend = Create({ Type = "Spell", ID = 34433 }),
	VoidWraith = Create({ Type = "Spell", ID = 451235 }),

	-- Spec Tree
	Penance = Create({ Type = "Spell", ID = 47540 }),
	PowerWordRadiance = Create({ Type = "Spell", ID = 194509 }),
	PurgeTheWicked = Create({ Type = "Spell", ID = 204197 }),
	Rapture = Create({ Type = "Spell", ID = 47536 }),
	Schism = Create({ Type = "Spell", ID = 214621 }),
	ShadowCovenant = Create({ Type = "Spell", ID = 314867 }),

	-- Buffs
	RadiantProvidenceBuff = Create({ Type = "Spell", ID = 410638, Hidden = true }),
	HarshDisciplineBuff = Create({ Type = "Spell", ID = 373183, Hidden = true }),
	PowerOfTheDarkSideBuff = Create({ Type = "Spell", ID = 198069, Hidden = true }),
	TwilightEquipmentBuff = Create({ Type = "Spell", ID = 390707, Hidden = true }),
	RaptureBuff = Create({ Type = "Spell", ID = 47536, Hidden = true }),
	SurgeOfLight = Create({ Type = "Spell", ID = 114255 }),

	-- Debuffs
	PurgeTheWickedDebuff = Create({ Type = "Spell", ID = 204213, Hidden = true }),
	ShadowWordPainDebuff = Create({ Type = "Spell", ID = 589, Hidden = true }),

	-- Racials
	ArcaneTorrent = Create({ Type = "Spell", ID = 50613 }),
	GiftoftheNaaru = Action.Create({ Type = "Spell", ID = 59544 }),
	WarStomp = Action.Create({ Type = "Spell", ID = 20549 }),
	Stoneform = Action.Create({ Type = "Spell", ID = 20594 }),
	Fireblood = Action.Create({ Type = "Spell", ID = 265221 }),
	Regeneratin = Create({ Type = "Spell", ID = 291944 }),

	-- Talents
	VoidWraithTalent = Create({ Type = "Spell", ID = 451234 }),
}

local A = setmetatable(Action[ACTION_CONST_PRIEST_DISCIPLINE], { __index = Action })

local function HealCalc(heal)
	local healamount = 0

	if heal == A.FlashHeal then
		healamount = A.FlashHeal:GetSpellDescription()[1]
	elseif heal == A.PowerWordShield then
		healamount = A.PowerWordShield:GetSpellDescription()[1]
		return healamount
	elseif heal == A.Renew then
		healamount = A.Renew:GetSpellDescription()[1]
	end

	-- print("(healamount * 1000): ", (healamount * 1000))
	-- print("healamount: ", healamount)
	return healamount
end

-- TODO

-- Use HealingEngine.GetHealthAVG() to determine when to use Power Word Radiance
-- Power Word Radiance only in combat
-- Power Word Radiance tier handling?

A[3] = function(icon)
	local getMembersAll = HealingEngine.GetMembersAll()
	local inCombat = Unit(player):CombatTime() > 0
	local isMoving = A.Player:IsMoving()
	local inMelee = true

	-- print("HealingEngine.GetHealthAVG(): ", HealingEngine.GetHealthAVG())
	-- print("HealingEnging.HealingByRange(10): ", HealingEngine.HealingByRange(10, A.PowerWordRadiance))

	local function HealingRotation(unit)
		if A.PowerWordShield:IsReady(unit) and Unit(unit):HealthDeficit() >= HealCalc(A.PowerWordShield) then
			return A.PowerWordShield:Show(icon)
		end

		if
			A.FlashHeal:IsReady(unit)
			and Unit(unit):HealthDeficit() >= HealCalc(A.FlashHeal)
			and Unit(player):HasBuffs(A.SurgeOfLight.ID) ~= 0
		then
			return A.FlashHeal:Show(icon)
		end

		if
			A.PurgeTheWicked:IsReady(target)
			and IsUnitEnemy(target)
			and Unit(target):HasDeBuffs(A.PurgeTheWickedDebuff.ID) == 0
		then
			return A.PurgeTheWicked:Show(icon)
		end

		if A.PowerWordRadiance:IsReady(player) and (A.PowerWordRadiance:GetSpellChargesFrac() > 1.8) and inCombat then
			return A.PowerWordRadiance:Show(icon)
		end

		if A.ShadowFiend:IsReady(target) and IsUnitEnemy(target) and not A.VoidWraithTalent:IsTalentLearned() then
			return A.WarStomp:Show(icon)
		end

		if A.VoidWraith:IsReady(target) and IsUnitEnemy(target) then
			return A.WarStomp:Show(icon)
		end

		if A.MindBlast:IsReady(target) then
			return A.MindBlast:Show(icon)
		end

		if A.Penance:IsReady(target) then
			return A.Stoneform:Show(icon)
		end

		if A.ShadowWordDeath:IsReady(target) then
			return A.ShadowWordDeath:Show(icon)
		end

		if A.Smite:IsReady(target) then
			return A.ArcaneTorrent:Show(icon)
		end
	end

	local function DamageRotation(unit) end

	if IsUnitFriendly(target) then
		unit = target

		if HealingRotation(unit) then
			return true
		end
	elseif IsUnitFriendly(focus) then
		unit = focus

		if HealingRotation(unit) then
			return true
		end
	end

	if IsUnitEnemy(target) then
		unit = target

		if HealingRotation(unit) then
			return true
		end
	end
end
