-- LightForged Avenger Paladin Rotation v1.0.1
-- Last Update: 10/15/2024

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

Action[ACTION_CONST_PALADIN_HOLY] = {

	-- Class Tree
	BlessingOfFreedom = Create({ Type = "Spell", ID = 1044 }),
	BlessingofProtection = Create({ Type = "Spell", ID = 1022 }),
	BlessingofSacrifice = Create({ Type = "Spell", ID = 6940 }),
	BlindingLight = Create({ Type = "Spell", ID = 115750 }),
	ConcentrationAura = Create({ Type = "Spell", ID = 317920 }),
	Consecration = Create({ Type = "Spell", ID = 26573 }),
	CrusaderStrike = Create({ Type = "Spell", ID = 35395 }),
	DevotionAura = Create({ Type = "Spell", ID = 465 }),
	DivineShield = Create({ Type = "Spell", ID = 642 }),
	DivineSteed = Create({ Type = "Spell", ID = 190784 }),
	DivineToll = Create({ Type = "Spell", ID = 375576 }),
	FlashofLight = Create({ Type = "Spell", ID = 19750 }),
	HammerofJustice = Create({ Type = "Spell", ID = 853 }),
	HammerofWrath = Create({ Type = "Spell", ID = 24275 }),
	HandOfReckoning = Create({ Type = "Spell", ID = 62124 }),
	Intercession = Create({ Type = "Spell", ID = 391054 }),
	Judgment = Create({ Type = "Spell", ID = 275773 }),
	LayOnHands = Create({ Type = "Spell", ID = 633 }),
	Rebuke = Create({ Type = "Spell", ID = 96231 }),
	Redemption = Create({ Type = "Spell", ID = 7328 }),
	RetributionAura = Create({ Type = "Spell", ID = 183435 }),
	SenseUndead = Create({ Type = "Spell", ID = 5502 }),
	ShieldOfTheRighteous = Create({ Type = "Spell", ID = 53600 }),
	WordOfGlory = Create({ Type = "Spell", ID = 85673, Texture = 5502 }),
	HolyBulwark = Create({ Type = "Spell", ID = 432459 }),
	SacredWeapon = Create({ Type = "Spell", ID = 432472 }),



	-- Spec Tree
	Absolution = Create({ Type = "Spell", ID = 212056 }),
	AuraMaster = Create({ Type = "Spell", ID = 31821 }),
	AvengingCrusader = Create({ Type = "Spell", ID = 216331 }),
	BeaconOfVirtue = Create({ Type = "Spell", ID = 200025 }),
	Cleanse = Create({ Type = "Spell", ID = 4987 }),
	DivineProtection = Create({ Type = "Spell", ID = 498 }),
	HolyLight = Create({ Type = "Spell", ID = 82326 }),
	HolyShock = Create({ Type = "Spell", ID = 20473 }),
	HolyShockDamage = Create({ Type = "Spell", ID = 20473 , Texture = 236216}),
	HolyPrism = Create({ Type = "Spell", ID = 114165 }),
	LightOfDawn = Create({ Type = "Spell", ID = 85222 }),
	LightsHammer = Create({ Type = "Spell", ID = 114158 }),
	Daybreak = Create({ Type = "Spell", ID = 414170 }),
	BlessingofSummer = Action.Create({
		Type = "Spell",
		ID = 388007,
		Texture = 328620,
	}),
	BlessingofAutumn = Action.Create({
		Type = "Spell",
		ID = 388010,
		Texture = 328620,
	}),
	BlessingofSpring = Action.Create({
		Type = "Spell",
		ID = 388013,
		Texture = 328620,
	}),
	BlessingofWinter = Action.Create({
		Type = "Spell",
		ID = 388011,
		Texture = 328620,
	}),

	-- Racials
	GiftoftheNaaru = Create({ Type = "Spell", ID = 59542 }),
	Fireblood = Create({ Type = "Spell", ID = 265221 }),
	ArcaneTorrent = Create({ Type = "Spell", ID = 50613 }),

	-- Buffs
	ShiningLightBuff = Create({ Type = "Spell", ID = 414445, Hidden = true }),
	DivineFavor = Create({ Type = "Spell", ID = 210294 }),
	InfusionOfLight = Create({ Type = "Spell", ID = 54149 }),

	-- Debuffs

	-- Trinkets
}

local A = setmetatable(Action[ACTION_CONST_PALADIN_HOLY], { __index = Action })

local player = "player"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

local function HealCalc(heal)
	local healamount = 0
	local spellDescriptions = {
		[A.HolyShock] = A.HolyShock:GetSpellDescription(),
		[A.WordOfGlory] = A.WordOfGlory:GetSpellDescription(),
		[A.LayOnHands] = A.LayOnHands:GetSpellDescription(),
	}

	if spellDescriptions[heal] then
		healamount = spellDescriptions[heal][1]
	end

	return tonumber((tostring(healamount):gsub("%.", "")))
end

A[3] = function(icon)
	-- print(Unit(player):Name())
	-- print(Unit(unit):Name())

	local getMembersAll = HealingEngine.GetMembersAll()
	local LightOfDawnHP = 90
	local LightofDawnUnits = 4
	local WordOfGloryHP = 85
	local HolyShockHP = 90
	local LightOfDawnDump = true
	local inCombat = Unit(player):CombatTime() > 0
	local ForceWoGHP = 60
	local inMelee = A.CrusaderStrike:IsInRange(target)
	local isMoving = A.Player:IsMoving()

	local HolyPower = Player:HolyPower()

	local AvengingCrusaderActive = Unit(player):HasBuffs(A.AvengingCrusader.ID, true) > 0

	local function isInRange(unit)
		return A.Cleanse:IsInRange(unit)
	end

	local function HealingRotation(unit)
		function isUnitValid(unit)
			return isInRange(unit) and not Unit(unit):IsDead() and IsUnitFriendly(unit)
		end

		if
			A.BeaconOfVirtue:IsReady(unit)
			and A.BeaconOfVirtue:IsSpellLearned()
			and CheckMembersBelowHealthPercent(getMembersAll, 80, 3)
		then
			return A.BeaconOfVirtue:Show(icon)
		end

		-- Emergency Lay on Hands
		if
			A.LayOnHands:IsReady(unit)
			and (Unit(unit):HealthPercent() <= 30 or Unit(unit):HealthDeficit() >= Unit(player):HealthMax())
		then
			return A.LayOnHands:Show(icon)
		end

		-- Blessings

		if A.BlessingofSummer:IsReady(player) then
			return A.BlessingofSummer:Show(icon)
		end

		if A.BlessingofAutumn:IsReady(player) then
			return A.BlessingofSummer:Show(icon)
		end

		if A.BlessingofSpring:IsReady(player) then
			return A.BlessingofSummer:Show(icon)
		end

		if A.BlessingofWinter:IsReady(player) then
			return A.BlessingofSummer:Show(icon)
		end

		if A.HolyBulwark:IsReady(player) or A.SacredWeapon:IsReady(player) then
			return A.GiftoftheNaaru:Show(icon)
		end

		if HolyPower == 5 and isUnitValid(unit) then
			if A.WordOfGlory:IsReady(unit) and Unit(unit):HealthDeficit() >= HealCalc(A.WordOfGlory) then
				return A.WordOfGlory:Show(icon)
			end

			-- LoD in Raid

			-- if A.LightOfDawn:IsReady(player) then
			-- 	return A.LightOfDawn:Show(icon)
			-- end

			-- SotR in M+
			if A.ShieldOfTheRighteous:IsReady(player) and IsUnitEnemy(target) then
				return A.ShieldOfTheRighteous:Show(icon)
			end
		end

		if AvengingCrusaderActive then
			if A.CrusaderStrike:IsReady(target) and IsUnitEnemy(target) and not Unit(target):IsDead() then
				return A.CrusaderStrike:Show(icon)
			end

			if A.Judgment:IsReady(target) and IsUnitEnemy(target) and not Unit(target):IsDead() then
				return A.Judgment:Show(icon)
			end
		end

		-- if A.AvengingCrusader:IsReady(player) and not AvengingCrusaderActive and inCombat then
		-- 	return A.AvengingCrusader:Show(icon)
		-- end

		if A.HolyPrism:IsReady(target) and IsUnitEnemy(target) and not Unit(target):IsDead() then
			return A.HolyPrism:Show(icon)
		end

		if A.Judgment:IsReady(target) and IsUnitEnemy(target) and not Unit(target):IsDead() then
			return A.Judgment:Show(icon)
		end

		if
			isMoving == false
			and inCombat
			and A.Consecration:IsReady(player)
			and Unit(player):HasBuffs(A.Consecration.ID) == 0
		then
			return A.Consecration:Show(icon)
		end

		if
			A.HolyShock:IsReady(unit)
			and Unit(unit):HealthDeficit() >= HealCalc(A.HolyShock)
			and not IsUnitEnemy(unit)
		then
			return A.HolyShock:Show(icon)
		end

		if A.CrusaderStrike:IsReady(target) and IsUnitEnemy(target) and not Unit(target):IsDead() then
			return A.CrusaderStrike:Show(icon)
		end

		-- Spend Holy Power

		if HolyPower >= 3 and isUnitValid(unit) then
			if A.WordOfGlory:IsReady(unit) and Unit(unit):HealthDeficit() >= HealCalc(A.WordOfGlory) then
				return A.WordOfGlory:Show(icon)
			end

			-- LoD in Raid

			-- if A.LightOfDawn:IsReady(player) then
			-- 	return A.LightOfDawn:Show(icon)
			-- end

			-- SotR in M+
			if A.ShieldOfTheRighteous:IsReady(player) and IsUnitEnemy(target) then
				return A.ShieldOfTheRighteous:Show(icon)
			end
		end

		-- Attack Holy Shock

		if A.HolyShock:IsReady(unit) and IsUnitEnemy(target) then
			return A.Fireblood:Show(icon)
		end

		if A.HammerofWrath:IsReady(target) and IsUnitEnemy(target) and not Unit(target):IsDead() then
			return A.HammerofWrath:Show(icon)
		end
	end

	HealingRotation = Action.MakeFunctionCachedDynamic(HealingRotation)

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
