-- Arcane GPT 7/24/24
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

Action[ACTION_CONST_MAGE_ARCANE] = {
	-- Class Tree
	ShiftingPower = Create({ Type = "Spell", ID = 382440 }),
	-- Spec Tree
	ArcaneBlast = Create({ Type = "Spell", ID = 30451 }),
	ArcaneBarrage = Create({ Type = "Spell", ID = 44425 }),
	ArcaneMissiles = Create({ Type = "Spell", ID = 5143 }),
	ArcaneExplosion = Create({ Type = "Spell", ID = 1449 }),
	ArcaneSurge = Create({ Type = "Spell", ID = 365350 }),
	ArcaneOrb = Create({ Type = "Spell", ID = 153626 }),
	Evocation = Create({ Type = "Spell", ID = 12051 }),
	TouchOfTheMagi = Create({ Type = "Spell", ID = 321507 }),
	PresenceOfMind = Create({ Type = "Spell", ID = 205025 }),
	-- Buffs
	Clearcasting = Create({ Type = "Spell", ID = 263725 }),
	NetherPrecision = Create({ Type = "Spell", ID = 383783 }),
	ArcaneSurgeBuff = Create({ Type = "Spell", ID = 365362 }),
	-- Debuffs
	-- Racial
	-- Talents
	SplinteringSorcery = Create({ Type = "Spell", ID = 387807 }),
	ArcaneTempo = Create({ Type = "Spell", ID = 383997 }),
	ArcaneBombardment = Create({ Type = "Spell", ID = 384581 }),
}

local A = setmetatable(Action[ACTION_CONST_MAGE_ARCANE], { __index = Action })

A[3] = function(icon)
	local function BasicDamageRotation(unit)
		local arcaneCharges = Player:ArcaneCharges()
		local mana = Player:ManaPercentage()

		if A.ArcaneOrb:IsReady(player) and arcaneCharges < 2 then
			return A.ArcaneOrb:Show(icon)
		end

		if mana < 70 and A.Evocation:GetCooldown() > 45 and A.ArcaneBarrage:IsReady(unit) then
			return A.ArcaneBarrage:Show(icon)
		end

		if
			A.ArcaneBarrage:IsReady(unit)
			and arcaneCharges == 3
			and Unit(player):HasBuffsStacks(A.NetherPrecision.ID) == 1
			and (Unit(player):HasBuffs(A.Clearcasting.ID) > 0 or A.ArcaneOrb:GetSpellCharges() > 0)
			and (A.Player:PrevGCD(1, A.ArcaneBlast))
		then
			print("Queueing Arcane Barrage after Arcane Blast")
			return A.ArcaneBarrage:Show(icon)
		end

		if Unit(player):HasBuffsStacks(A.NetherPrecision.ID) > 0 and A.ArcaneBlast:IsReady(unit) then
			return A.ArcaneBlast:Show(icon)
		end

		if A.ArcaneMissiles:IsReady(unit) and Unit(player):HasBuffs(A.Clearcasting.ID) > 0 then
			print("Casting Arcane Missiles with Clearcasting")
			return A.ArcaneMissiles:Show(icon)
		end

		if A.ArcaneBlast:IsReady(unit) then
			print("Casting Arcane Blast")
			return A.ArcaneBlast:Show(icon)
		end

		-- 9. Arcane Barrage if out of mana
		if A.ArcaneBarrage:IsReady(unit) and mana < 10 then
			print("Casting Arcane Barrage due to low mana")
			return A.ArcaneBarrage:Show(icon)
		end
	end

	if A.IsUnitEnemy("target") then
		unit = "target"
		if BasicDamageRotation(unit) then
			return true
		end
	end
end
