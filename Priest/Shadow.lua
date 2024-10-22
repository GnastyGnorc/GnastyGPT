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
local ActiveUnitPlates = MultiUnits:GetActiveUnitPlates()
local GetToggle = Action.GetToggle
local player = "player"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

Action[ACTION_CONST_PRIEST_SHADOW] = {

	-- Class Tree
	Smite = Create({ Type = "Spell", ID = 585 }),
	Shadowcrash = Create({ Type = "Spell", ID = 457042 }),
	Shadowfiend = Create({ Type = "Spell", ID = 34433 }),
	VoidEruption = Create({ Type = "Spell", ID = 228260 }),
	DevouringPlague = Create({ Type = "Spell", ID = 335467 }),
	VoidTorrent = Create({ Type = "Spell", ID = 263165 }),
	MindBlast = Create({ Type = "Spell", ID = 8092 }),
	VoidBolt = Create({ Type = "Spell", ID = 205448 }),
	MindFlay = Create({ Type = "Spell", ID = 15407 }),
	MindFlayInsanity = Create({ Type = "Spell", ID = 391403 }),

	-- Spec Tree

	-- Racials
	ArcaneTorrent = Create({ Type = "Spell", ID = 50613 }), -- Tyrs Deliverance
	GiftoftheNaaru = Create({ Type = "Spell", ID = 59542 }), -- Daybreak
	Fireblood = Create({ Type = "Spell", ID = 265221 }), -- Attack Holyshock
	Stoneform = Create({ Type = "Spell", ID = 20594 }), -- Barrier of Faith

	-- Buffs

	-- Debuffs

	-- Trinkets

	-- Talents
}

local A = setmetatable(Action[ACTION_CONST_PRIEST_SHADOW], { __index = Action })

local player = "player"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

-- function isInRange(unit) return A.Purify:IsInRange(unit) end

-- TODO

A[3] = function(icon)
	local getMembersAll = HealingEngine.GetMembersAll()
	local inCombat = Unit(player):CombatTime() > 0
	local isMoving = A.Player:IsMoving()
	local insanity = Player:Insanity()

	local function DamageRotation(unit)
		if BurstIsON(player) then
			
		end

		if A.Shadowcrash:IsReady(unit) then
			return A.Shadowcrash:Show(icon)
		end

		if A.Shadowfiend:IsReady(unit) then
			return A.Shadowfiend:Show(icon)
		end

		if A.VoidEruption:IsReady(unit) then
			return A.VoidEruption:Show(icon)
		end

		if A.VoidBolt:IsReady(unit) then
			return A.VoidEruption:Show(icon)
		end

		if A.DevouringPlague:IsReady(unit) and insanity >= 120 then
			return A.DevouringPlague:Show(icon)
		end

		if A.MindBlast:IsReady(unit) then
			return A.MindBlast:Show(icon)
		end

		if A.VoidTorrent:IsReady(unit) then
			return A.VoidTorrent:Show(icon)
		end

		if A.MindFlayInsanity:IsReady(unit) then
			return A.MindFlay:Show(icon)
		end

		if A.DevouringPlague:IsReady(unit) then
			return A.DevouringPlague:Show(icon)
		end

		if A.MindFlay:IsReady(unit) then
			return A.MindFlay:Show(icon)
		end
	end

	if IsUnitEnemy(target) then
		unit = target

		if DamageRotation(unit) then
			return true
		end
	end
end
