-- Frost TWW
-- TWW 11/2/24

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

local player = "player"
local unit = "target"

Action[ACTION_CONST_MAGE_FROST] = {
	-- Class Tree
	IceBarrier = Create({ Type = "Spell", ID = 11426 }),
	MirrorImage = Create({ Type = "Spell", ID = 55342 }),
	IceNova = Create({ Type = "Spell", ID = 157997 }),
	Polymorph = Create({ Type = "Spell", ID = 118 }),
	ShiftingPower = Create({ Type = "Spell", ID = 382440 }),
	ConeOfCold = Create({ Type = "Spell", ID = 120 }),

	-- Spec Tree
	FrozenOrb = Create({ Type = "Spell", ID = 84714 }),
	Flurry = Create({ Type = "Spell", ID = 44614 }),
	IceLance = Create({ Type = "Spell", ID = 30455 }),
	Frostbolt = Create({ Type = "Spell", ID = 116 }),
	Blizzard = Create({ Type = "Spell", ID = 190356 }),
	IcyVeins = Create({ Type = "Spell", ID = 12472 }),
	GlacialSpike = Create({ Type = "Spell", ID = 199786 }),
	CometStorm = Create({ Type = "Spell", ID = 153595 }),
	RayOfFrost = Create({ Type = "Spell", ID = 205021 }),

	-- Buffs
	FingersOfFrost = Create({ Type = "Spell", ID = 44544, Hidden = true }),
	ArcaneIntellect = Create({ Type = "Spell", ID = 1459, Hidden = true }),
	BrainFreezeBuff = Create({ Type = "Spell", ID = 190446, Hidden = true }),
	IciclesBuff = Create({ Type = "Spell", ID = 205473, Hidden = true }),
	DeathsChill = Create({ Type = "Spell", ID = 454371 }),

	-- Debuffs
	WintersChill = Create({ Type = "Spell", ID = 228358 }),
	CursedSpirit = Create({ Type = "Spell", ID = 409465 }),

	-- Racial
	ArcaneTorrent = Create({ Type = "Spell", ID = 50613 }), -- Wake of Ashes
	GiftoftheNaaru = Action.Create({ Type = "Spell", ID = 59544 }),
	WarStomp = Action.Create({ Type = "Spell", ID = 20549 }),
	Stoneform = Action.Create({ Type = "Spell", ID = 20594 }),
	Fireblood = Action.Create({ Type = "Spell", ID = 265221 }),
	Regeneratin = Create({ Type = "Spell", ID = 291944 }),

	-- Talents
	FreezingWinds = Create({ Type = "Spell", ID = 382103 }),
	ColdestSnap = Create({ Type = "Spell", ID = 417493 }),
	DeathsChillTalent = Create({ Type = "Spell", ID = 450331 }),
}

local A = setmetatable(Action[ACTION_CONST_MAGE_FROST], { __index = Action })

A[3] = function(icon)
	local function BasicDamageRotation(unit)
		local function InMeleeRange(unitID)
			return Unit(unitID):GetRange() <= 8
		end

		local isAoE = GetToggle(2, "AoE")
		local inCombat = Unit(player):CombatTime() > 0
		local isMoving = A.Player:IsMoving()
		local wintersChillDebuff = Unit(unit):HasDeBuffs(A.WintersChill.ID, player)
		local unitCount = MultiUnits:GetBySpell(A.Frostbolt)
		-- Delete After Testing
		if A.IcyVeins:IsReady(player) and not isMoving then
			return A.IcyVeins:Show(icon)
		end

		-- Manather Rotation
		-- if isAoE then
		-- 	if
		-- 		A.Flurry:IsReadyByPassCastGCD(unit)
		-- 		and A.GlacialSpike:IsSpellInCasting()
		-- 		and Unit(unit):HasDeBuffs(A.WintersChill.ID, player) < 3
		-- 	then
		-- 		return A.Flurry:Show(icon)
		-- 	end

		-- 	if
		-- 		A.ConeOfCold:IsReady(player)
		-- 		and not A.FrozenOrb:IsReady(player)
		-- 		and not A.CometStorm:IsReady(unit)
		-- 		and A.CometStorm:GetCooldown() > 10
		-- 	then
		-- 		return A.ConeOfCold:Show(icon)
		-- 	end

		-- 	if A.FrozenOrb:IsReady(player) then
		-- 		return A.FrozenOrb:Show(icon)
		-- 	end

		-- 	if A.Blizzard:IsReady(player) then
		-- 		return A.Blizzard:Show(icon)
		-- 	end

		-- 	if A.CometStorm:IsReady(unit) and (A.ConeOfCold:IsReady() or A.ConeOfCold:GetCooldown() > 20) then
		-- 		return A.CometStorm:Show(icon)
		-- 	end

		-- 	if A.ShiftingPower:IsReady(player) and A.CometStorm:GetCooldown() >= 14 and not isMoving then
		-- 		return A.ArcaneTorrent:Show(icon)
		-- 	end

		-- 	if A.GlacialSpike:IsReady(unit) and A.Flurry:GetSpellCharges() >= 1 then
		-- 		return A.GlacialSpike:Show(icon)
		-- 	end

		-- 	if A.IceLance:IsReady(unit) and Unit(player):HasBuffs(A.FingersOfFrost.ID) ~= 0 then
		-- 		return A.IceLance:Show(icon)
		-- 	end

		-- 	if A.IceLance:IsReady(unit) and wintersChillDebuff ~= 0 then
		-- 		return A.IceLance:Show(icon)
		-- 	end

		-- 	if A.Flurry:IsReady(unit) then
		-- 		return A.Flurry:Show(icon)
		-- 	end

		-- 	if A.Frostbolt:IsReady(unit) then
		-- 		return A.Frostbolt:Show(icon)
		-- 	end
		-- end

		-- APL Rotation
		if isAoE then
			-- Should I just manually use this and make a big WA?
			-- I need to be in range and 3 targets to hit

			if
				A.ConeOfCold:IsReady(player)
				and not A.FrozenOrb:IsReady(player)
				and not A.CometStorm:IsReady(unit)
				and InMeleeRange(unit)
				and unitCount >= 3
			then
				return A.ConeOfCold:Show(icon)
			end

			if A.Flurry:IsReadyByPassCastGCD(unit) and A.GlacialSpike:IsSpellInCasting() then
				return A.Flurry:Show(icon)
			end

			if
				A.Flurry:IsReadyByPassCastGCD(unit)
				and A.Frostbolt:IsSpellInCasting()
				and Unit(unit):HasDeBuffs(A.WintersChill.ID, player) < 3
			then
				return A.Flurry:Show(icon)
			end

			if A.FrozenOrb:IsReady(player) and inCombat then
				return A.FrozenOrb:Show(icon)
			end

			if A.Blizzard:IsReady(player) then
				return A.Blizzard:Show(icon)
			end

			if A.CometStorm:IsReady(unit) then
				return A.CometStorm:Show(icon)
			end

			-- Could manually cast, Icy Veins CD just needs to be over 10 seconds
			-- Use this to get comet storm
			if
				A.ShiftingPower:IsReady(player)
				and A.IcyVeins:GetCooldown() > 15
				and A.CometStorm:GetCooldown() > 15
				and not isMoving
			then
				return A.ArcaneTorrent:Show(icon)
			end

			if A.GlacialSpike:IsReady(unit) and A.Flurry:GetSpellCharges() > 0 then
				return A.GlacialSpike:Show(icon)
			end

			if A.IceLance:IsReady(unit) and Unit(player):HasBuffs(A.FingersOfFrost.ID) ~= 0 then
				return A.IceLance:Show(icon)
			end

			if A.Flurry:IsReady(unit) and Unit(unit):HasDeBuffs(A.WintersChill.ID, player) == 0 then
				return A.Flurry:Show(icon)
			end

			if A.Frostbolt:IsReady(unit) then
				return A.Frostbolt:Show(icon)
			end
		end

		----------------------------------------------
		-- Start ST Rotation
		----------------------------------------------

		if
			A.Flurry:IsReadyByPassCastGCD(unit)
			and A.GlacialSpike:IsSpellInCasting()
			and Unit(unit):HasDeBuffs(A.WintersChill.ID) < 1
		then
			return A.Flurry:Show(icon)
		end

		if
			A.Flurry:IsReadyByPassCastGCD(unit)
			and A.Frostbolt:IsSpellInCasting()
			and Unit(unit):HasDeBuffs(A.WintersChill.ID) < 1
			and A.DeathsChillTalent:IsTalentLearned()
		then
			return A.Flurry:Show(icon)
		end

		if A.CometStorm:IsReady(unit) and Unit(player):HasBuffs(A.IcyVeins.ID) == 0 then
			return A.CometStorm:Show(icon)
		end

		if
			A.Flurry:IsReady(unit)
			and A.Flurry:GetSpellChargesFrac() > 1.4
			and Unit(unit):HasDeBuffs(A.WintersChill.ID, player) == 0
		then
			return A.Flurry:Show(icon)
		end

		if A.FrozenOrb:IsReady(player) then
			return A.FrozenOrb:Show(icon)
		end

		if
			A.ShiftingPower:IsReady(player)
			and A.IcyVeins:GetCooldown() > 10
			and A.Flurry:GetSpellCharges() == 0
			and not isMoving
			and Unit(unit):HasDeBuffs(A.WintersChill.ID, player) == 0
		then
			return A.ArcaneTorrent:Show(icon)
		end

		if A.GlacialSpike:IsReady(unit) and A.Flurry:GetSpellCharges() > 0 and not isMoving then
			return A.GlacialSpike:Show(icon)
		end

		if
			A.Frostbolt:IsReady(unit)
			and Unit(player):HasBuffs(A.IcyVeins.ID) > 8
			and Unit(player):HasBuffsStacks(A.DeathsChill.ID) < 8
			and not isMoving
		then
			return A.Frostbolt:Show(icon)
		end

		if
			A.IceLance:IsReady(unit)
			and Unit(player):HasBuffs(A.FingersOfFrost.ID) ~= 0
			and not A.DeathsChillTalent:IsTalentLearned()
		then
			return A.IceLance:Show(icon)
		end

		if
			A.IceLance:IsReady(unit)
			and Unit(unit):HasDeBuffsStacks(A.WintersChill.ID) == 2
			and A.DeathsChillTalent:IsTalentLearned()
		then
			return A.IceLance:Show(icon)
		end

		if A.Frostbolt:IsReady(unit) and not isMoving then
			return A.Frostbolt:Show(icon)
		end

		if
			A.IceNova:IsReady(unit)
			and Unit(unit):HasDeBuffsStacks(A.WintersChill.ID) == 0
			and A.Flurry:GetSpellChargesFrac() < 0.8
		then
			return A.IceNova:Show(icon)
		end

		if A.IceBarrier:IsReady(player) then
			return A.IceBarrier:Show(icon)
		end

		if A.IceLance:IsReady(unit) then
			return A.IceLance:Show(icon)
		end

		-- flurry if casting glacial spike
		-- comet storm if no icy veins
		-- flurry if winters chill = 0
		-- frozen orb
		-- shifting power if icy veins cd > 10
		-- glacial spiike and 1 flurry charge
		-- frostbolt if icy veins and deaths chill stack < 8 check if deaths chill is learned
		-- ice lance if fingers of frost (aoe build) probably check if deaths chill is not learned
		-- ice lance if winters chill (deaths chill build) check if deaths chill is learned
		-- frostbolt

		-- what to do with ice nova
	end

	if A.IsUnitEnemy("target") then
		unit = "target"
		if BasicDamageRotation(unit) then
			return true
		end
	end
end
