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
local TeamCache = Action.TeamCache

local player = "player"
local unit = "target"

-- Create actions table for Enhancement
Action[Action.PlayerClass] = {
	-- Basic Spells
	LavaLash = Create({ Type = "Spell", ID = 60103 }),
	PrimalStrike = Create({ Type = "Spell", ID = 73899 }),
	EarthShock = Create({ Type = "Spell", ID = 8042 }),
	Stormstrike = Create({ Type = "Spell", ID = 173882 }),
	LightningBolt = Create({ Type = "Spell", ID = 403 }),
	FlameShock = Create({ Type = "Spell", ID = 8050 }),
	-- Buffs
	LightningShield = Create({ Type = "Spell", ID = 324 }),
	FlametongueWeapon = Create({ Type = "Spell", ID = 8024 }),
	FlameTongueWeaponBuff = Create({ Type = "Spell", ID = 4563 }),
	-- Racials
	BloodFury = Create({ Type = "Spell", ID = 20572 }), -- Orc
	Berserking = Create({ Type = "Spell", ID = 26297 }), -- Troll
	WarStomp = Create({ Type = "Spell", ID = 20549 }), -- Tauren
}

-- Create a shorter access to Action[Action.PlayerClass]
local A = setmetatable(Action[Action.PlayerClass], { __index = Action })

-- Map useful functions for faster access

-- [3] Single Rotation
A[3] = function(icon)
	local GetToggle = A.GetToggle
	local Unit = A.Unit
	local Player = A.Player
	local IsUnitEnemy = A.IsUnitEnemy
	local IsUnitFriendly = A.IsUnitFriendly
	local inMelee = A.LavaLash:IsInRange(unit)

	-- if Unit(player):HasBuffs(A.FlameTongueWeaponBuff.ID) == 0 then
	-- 	return A.FlametongueWeapon:Show(icon)
	-- end

	if Unit(player):HasBuffs(A.LightningShield.ID) == 0 then
		return A.LightningShield:Show(icon)
	end

	local function BasicDamageRotation(unit)
		if A.LavaLash:IsReady(unit) then
			return A.LavaLash:Show(icon)
		end

		if A.PrimalStrike:IsReady(unit) then
			return A.LightningBolt:Show(icon)
		end

		if A.FlameShock:IsReady(unit) and Unit(unit):HasDeBuffs(A.FlameShock.ID, true) == 0 then
			return A.FlameShock:Show(icon)
		end

		if A.EarthShock:IsReady(unit) then
			return A.EarthShock:Show(icon)
		end
	end

	if A.IsUnitEnemy(unit) then
		if BasicDamageRotation(unit) then
			return true
		end
	end
end

-- [4] AoE Rotation
A[4] = A[3]

-- [5] Essence Rotation
A[5] = A[3]

-- [6] Potions
A[6] = A[3]

-- [7] Trinkets
A[7] = A[3]

-- [8] Racial
A[8] = A[3]
