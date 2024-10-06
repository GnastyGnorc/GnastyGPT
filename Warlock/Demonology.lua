-- Solar Demonology Rotation v1.0.0
-- Last Update: 10/03/2024

local _G, setmetatable, pairs, type, math = _G, setmetatable, pairs, type, math
local huge = math.huge

local TMW = _G.TMW

local Action = _G.Action

local CONST = Action.Const
local Listener = Action.Listener
local Create = Action.Create
local GetToggle = Action.GetToggle
local GetLatency = Action.GetLatency
local GetGCD = Action.GetGCD
local GetCurrentGCD = Action.GetCurrentGCD
local ShouldStop = Action.ShouldStop
local BurstIsON = Action.BurstIsON
local AuraIsValid = Action.AuraIsValid
local InterruptIsValid = Action.InterruptIsValid
local DetermineUsableObject = Action.DetermineUsableObject
local Pet = LibStub("PetLibrary")

local Utils = Action.Utils
local BossMods = Action.BossMods
local TeamCache = Action.TeamCache
local EnemyTeam = Action.EnemyTeam
local FriendlyTeam = Action.FriendlyTeam
local LoC = Action.LossOfControl
local Player = Action.Player
local MultiUnits = Action.MultiUnits
local UnitCooldown = Action.UnitCooldown
local Unit = Action.Unit
local IsUnitEnemy = Action.IsUnitEnemy
local IsUnitFriendly = Action.IsUnitFriendly
local Combat = Action.Combat

local IsIndoors, UnitIsUnit = _G.IsIndoors, _G.UnitIsUnit
local player = "player"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

Action[ACTION_CONST_WARLOCK_DEMONOLOGY] = {

	-- Class Tree
	SoulStrike = Create({ Type = "Spell", ID = 264057 }),
	MortalCoil = Create({ Type = "Spell", ID = 6789 }),
	BurningRush = Create({ Type = "Spell", ID = 111400 }),
	ShadowBolt = Create({ Type = "Spell", ID = 686 }),
	PowerSiphon = Create({ Type = "Spell", ID = 264130 }),
	DrainLife = Create({ Type = "Spell", ID = 234153 }),

	-- Spec Tree
	CallDreadstalkers = Create({ Type = "Spell", ID = 104316 }),
	DemonBolt = Create({ Type = "Spell", ID = 264178 }),
	DemonicStrength = Create({ Type = "Spell", ID = 267171 }),
	SummonFelguard = Create({ Type = "Spell", ID = 30146 }),
	HandOfGuldan = Create({ Type = "Spell", ID = 105174 }),
	SummonDemonicTyrant = Create({ Type = "Spell", ID = 265187 }),
	NetherPortal = Create({ Type = "Spell", ID = 267217 }),
	GrimoireFelguard = Create({ Type = "Spell", ID = 111898, Texture = 108503 }),
	SummonVilefiend = Create({ Type = "Spell", ID = 264119 }),
    SummonCharhound = Create({ Type = "Spell", ID = 455476 }),

	-- PetSpells
	Felstorm = Create({ Type = "Spell", ID = 89753 }),
	LegionStrike = Create({ Type = "Spell", ID = 30213 }),
	PetSoulStrike = Create({ Type = "Spell", ID = 387502 }),

	-- Talents
	SoulStrike = Create({ Type = "Spell", ID = 428344 }),

	-- Buffs
	DemonicCore = Create({ Type = "Spell", ID = 264173, Hidden = true }),
	DemonicPower = Create({ Type = "Spell", ID = 265273, Hidden = true }),
	HoundmastersStrategem = Create({ Type = "Spell", ID = 270569, Hidden = true }),

	-- Debuffs
	DoomBrand = Create({ Type = "Spell", ID = 423583, Hidden = true }),

	-- Racials
	ArcaneTorrent = Action.Create({ Type = "Spell", ID = 50613 }),
}

local A = setmetatable(Action[ACTION_CONST_WARLOCK_DEMONOLOGY], { __index = Action })

local player = "player"

local function DemonicTyrantTime()
	return Pet:GetRemainDuration(135002) or 0
end

local function RealTyrantIsActive()
	return DemonicTyrantTime() > 6 and true or false
end

local function DemonicTyrantIsActive()
	return DemonicTyrantTime() > 0 and true or false
end

A[3] = function(icon)
	local SoulShards = Player:SoulShards()
	local hasDemonicCore = Unit(player):HasBuffs(A.DemonicCore.ID, player) ~= 0

	local function BasicDamageRotation(unit)
		if BurstIsON(player) then
			if A.GrimoireFelguard:IsReady(unit) then
				return A.GrimoireFelguard:Show(icon)
			end
		end

		if A.SummonCharhound:IsReady(player) then
			return A.ArcaneTorrent:Show(icon)
		end

		if A.CallDreadstalkers:IsReady(unit) then
			return A.CallDreadstalkers:Show(icon)
		end

		if A.DemonBolt:IsReady(unit) and hasDemonicCore and SoulShards < 4 then
			return A.DemonBolt:Show(icon)
		end

		if A.HandOfGuldan:IsReady(unit) and SoulShards > 2 then
			return A.HandOfGuldan:Show(icon)
		end

		-- if A.Demonic

        if A.ShadowBolt:IsReady(unit) then
            return A.ShadowBolt:Show(icon)
        end
	end

	if A.IsUnitEnemy("target") then
		unit = "target"
		if BasicDamageRotation(unit) then
			return true
		end
	end
end
