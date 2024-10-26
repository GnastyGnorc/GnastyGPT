-- Elemental Shaman Rotation
-- Last Update: 10/07/2024

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

Action[ACTION_CONST_SHAMAN_ELEMENTAL] = {

	-- Class Tree
	LavaBurst = Create({ Type = "Spell", ID = 51505 }),
	LightningBolt = Create({ Type = "Spell", ID = 188196 }),
	ChainLightning = Create({ Type = "Spell", ID = 188443 }),
	EarthQuake = Create({ Type = "Spell", ID = 462620 }),
	PrimordialWave = Create({ Type = "Spell", ID = 375982 }),
	LiquidMagmaTotem = Create({ Type = "Spell", ID = 192222 }),
	Stormkeeper = Create({ Type = "Spell", ID = 191634 }),
	StormElemental = Create({ Type = "Spell", ID = 192249 }),

	-- Spec Tree

	-- Buffs
	LavaSurge = Create({ Type = "Spell", ID = 77762 }),
	MasteroftheElements = Create({ Type = "Spell", ID = 260734 }),

	-- Debuffs

	-- Racials
	Darkflight = Create({ Type = "Spell", ID = 68992 }),
	GiftofNaaru = Action.Create({ Type = "Spell", ID = 59544 }),
}

local A = setmetatable(Action[ACTION_CONST_SHAMAN_ELEMENTAL], { __index = Action })

A[3] = function(icon)
	local isAoE = GetToggle(2, "AoE")
	local MaelstromPower = Player:Maelstrom()

	local function BasicDamageRotation(unit)
		if A.Stormkeeper:IsReady(player) then
			return A.Stormkeeper:Show(icon)
		end

		if A.PrimordialWave:IsReady(unit) then
			return A.GiftofNaaru:Show(icon)
		end

		if A.LiquidMagmaTotem:IsReady(player) then
			return A.LiquidMagmaTotem:Show(icon)
		end

		-- Insta Cast
		if A.LavaBurst:IsReady(unit) and Unit(player):HasBuffs(A.LavaSurge.ID) ~= 0 then
			return A.LavaBurst:Show(icon)
		end

		if A.EarthQuake:IsReady(unit) and MaelstromPower >= 130 then
			return A.EarthQuake:Show(icon)
		end

		if A.EarthQuake:IsReady(unit) and Unit(player):HasBuffs(A.Stormkeeper.ID) ~= 0 then
			return A.EarthQuake:Show(icon)
		end

		if A.EarthQuake:IsReady(unit) and Unit(player):HasBuffs(A.MasteroftheElements.ID) ~= 0 then
			return A.EarthQuake:Show(icon)
		end

		-- Tempest when I learn it, it's just chain lightning

		if A.ChainLightning:IsReady(unit) and isAoE then
			return A.ChainLightning:Show(icon)
		end

		if A.LightningBolt:IsReady(unit) then
			return A.Darkflight:Show(icon)
		end
	end

	if A.IsUnitEnemy("target") then
		unit = "target"
		if BasicDamageRotation(unit) then
			return true
		end
	end
end
