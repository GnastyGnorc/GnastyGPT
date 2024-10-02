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

local player = "player"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

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
	HammerofJustice = Create({ Type = "Spell", ID = 853 }),
	HammerofWrath = Create({ Type = "Spell", ID = 24275 }),
	HandOfReckoning = Create({ Type = "Spell", ID = 62124 }),
	Intercession = Create({ Type = "Spell", ID = 391054 }),
	Judgement = Create({ Type = "Spell", ID = 275779 }),
	LayOnHands = Create({ Type = "Spell", ID = 633 }),
	Rebuke = Create({ Type = "Spell", ID = 96231 }),
	Redemption = Create({ Type = "Spell", ID = 7328 }),
	RetributionAura = Create({ Type = "Spell", ID = 183435 }),
	SenseUndead = Create({ Type = "Spell", ID = 5502 }),
	ShieldOfTheRighteous = Create({ Type = "Spell", ID = 53600 }),
	WordOfGlory = Create({ Type = "Spell", ID = 85673, Texture = 133192 }),
	FlashOfLight = Create({ Type = "Spell", ID = 19750 }),

	-- Spec Tree
	Absolution = Create({ Type = "Spell", ID = 212056 }),
	AuraMaster = Create({ Type = "Spell", ID = 31821 }),
	AvengingCrusader = Create({ Type = "Spell", ID = 216331 }),
	BeaconOfVirtue = Create({ Type = "Spell", ID = 200025 }),
	Cleanse = Create({ Type = "Spell", ID = 4987 }),
	DivineProtection = Create({ Type = "Spell", ID = 498 }),
	HolyLight = Create({ Type = "Spell", ID = 82326 }),
	HolyShock = Create({ Type = "Spell", ID = 20473 }),
	HolyShockAttack = Create({ Type = "Spell", ID = 93402 }),
	HolyPrism = Create({ Type = "Spell", ID = 114165 }),
	LightOfDawn = Create({ Type = "Spell", ID = 85222 }),
	LightsHammer = Create({ Type = "Spell", ID = 114158 }),
	TyrsDeliverance = Create({ Type = "Spell", ID = 200652 }),
	Daybreak = Create({ Type = "Spell", ID = 414170 }),
	DivineFavor = Create({ Type = "Spell", ID = 210294 }),
	HandOfDivinity = Create({ Type = "Spell", ID = 414273 }),
	BarrierOfFaith = Create({ Type = "Spell", ID = 148039 }),
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
	ArcaneTorrent = Create({ Type = "Spell", ID = 50613 }), -- Tyrs Deliverance

	Stoneform = Create({ Type = "Spell", ID = 20594 }), -- Barrier of Faith

	-- Buffs
	GlimmerOfLight = Create({ Type = "Spell", ID = 287280 }),
	InfusionOfLight = Create({ Type = "Spell", ID = 54149 }),
	TyrsDeliverance = Create({ Type = "Spell", ID = 2006054 }),
	ConsecrationBuff = Create({ Type = "Spell", ID = 188370 }),
	BlessingOfDawn = Create({ Type = "Spell", ID = 385127 }),
	DivineFavor = Create({ Type = "Spell", ID = 210294 }),
	Awakening = Create({ Type = "Spell", ID = 414196 }),

	-- Debuffs
	Forbearance = Create({ Type = "Spell", ID = 25771 }),

	-- Trinkets

	-- Talents
}

local A = setmetatable(Action[ACTION_CONST_PALADIN_HOLY], { __index = Action })

local DungeonGroup = TeamCache.Friendly.Size >= 2 and TeamCache.Friendly.Size <= 5
local RaidGroup = TeamCache.Friendly.Size >= 5

local function HealCalc(heal)
	local healamount = 0
	local spellDescriptions = {
		[A.HolyShock] = A.HolyShock:GetSpellDescription(),
		[A.FlashOfLight] = A.FlashOfLight:GetSpellDescription(),
		[A.WordOfGlory] = A.WordOfGlory:GetSpellDescription(),
		[A.LayOnHands] = A.LayOnHands:GetSpellDescription(),
	}

	if spellDescriptions[heal] then
		healamount = spellDescriptions[heal][1]
	end

	return tonumber((tostring(healamount):gsub("%.", "")))
end

A[3] = function(icon)
	local getMembersAll = HealingEngine.GetMembersAll()
	local inCombat = Unit(player):CombatTime() > 0
	local isMoving = A.Player:IsMoving()
	local inMelee = A.CrusaderStrike:IsInRange(target)

	local function isInRange(unit)
		return A.Cleanse:IsInRange(unit)
	end

	local HolyPower = Player:HolyPower()

	function isUnitValid(unit)
		return isInRange(unit) and not Unit(unit):IsDead() and IsUnitFriendly(unit)
	end

	function isUnitEnemy(unit)
		return IsUnitEnemy(unit) and not Unit(unit):IsDead()
	end

	local function HealingRotation(unit)
		if
			A.LayOnHands:IsReady(unit)
			and (Unit(unit):HealthPercent() <= 30 or Unit(unit):HealthDeficit() >= Unit(player):HealthMax())
		then 	
			return A.LayOnHands:Show(icon)
		end

		-- Check if talent is learned
		-- if BeaconOfVirtue:IsReady(unit) and CheckMembersBelowHealthPercent(getMembersAll, 80, 4) then
		-- 	return BeaconOfVirtue:Show(icon)
		-- end

		
		if Unit(player):HasBuffsStacks(A.Awakening.ID) == 12 and A.Judgement:IsReady(target) then
			return A.Judgement:Show(icon)
		end

		if
			A.FlashOfLight:IsReady(unit)
			and Unit(unit):HealthDeficit() >= (HealCalc(A.FlashOfLight) * 0.4)
			and Unit(player):HasBuffs(A.DivineFavor.ID) ~= 0
			and not A.Player:PrevGCD(1, A.FlashOfLight)
			and not isMoving
		then
			return A.FlashOfLight:Show(icon)
		end


		-- TODO: Smarter Holy Prism, use on ally for healing and more hopo

		if A.HolyPrism:IsReady(target) and IsUnitEnemy(target) and not Unit(target):IsDead() then
			return A.HolyPrism:Show(icon)
		end

		if
			A.Consecration:IsReady(player)
			and Unit(player):HasBuffs(A.ConsecrationBuff.ID) == 0
			and inCombat
			and not isMoving	
			and HealingEngine.GetHealthAVG() >= 95
		then
			return A.Consecration:Show(icon)
		end

		if HolyPower >= 3 and isUnitValid(unit) then
			if A.WordOfGlory:IsReady(unit) and Unit(unit):HealthDeficit() >= HealCalc(A.WordOfGlory) then
				return A.WordOfGlory:Show(icon)
			end

			-- LoD in Raid

			-- if A.LightOfDawn:IsReady(player) then
			-- 	return A.LightOfDawn:Show(icon)
			-- end

			-- SotR in M+
			if A.ShieldOfTheRighteous:IsReady(player) and isUnitEnemy(target) then
				return A.ShieldOfTheRighteous:Show(icon)
			end
		end

		if A.HolyShock:IsReady(unit) and isUnitValid(unit) and Unit(unit):HealthDeficit() >= HealCalc(A.HolyShock) then
			return A.HolyShock:Show(icon)
		end

		if
			A.Consecration:IsReady(player)
			and Unit(player):HasBuffs(A.ConsecrationBuff.ID) == 0
			and inCombat
			and not isMoving
		then
			return A.Consecration:Show(icon)
		end

		if A.HammerofWrath:IsReady(target) and isUnitEnemy(target) then
			return A.HammerofWrath:Show(icon)
		end

		if A.Judgement:IsReady(target) and isUnitEnemy(target) then
			return A.Judgement:Show(icon)
		end

		if A.CrusaderStrike:IsReady(target) and isUnitEnemy(target) then
			return A.CrusaderStrike:Show(icon)
		end

		if A.HolyShock:IsReady(unit) and isUnitValid(unit) and Unit(unit):HealthPercent() < 100 then
			return A.HolyShock:Show(icon)
		end

		if A.HolyLight:IsReady(unit) and isUnitValid(unit) and Unit(unit):HealthDeficit() >= HealCalc(A.HolyLight) then
			return A.HolyLight:Show(icon)
		end

		if A.HolyShock:IsReady(target) and isUnitEnemy(target) then
			return A.HolyShockAttack:Show(icon)
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
		unitID = target

		if HealingRotation(unitID) then
			return true
		end
	end
end
