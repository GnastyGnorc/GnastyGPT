-- RetGPT Paladin Rotation v1.0.4
-- Last Update: 10/21/2024

-- TODO: Templar Support

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

Action[ACTION_CONST_PALADIN_RETRIBUTION] = {
	-- Class Abilities

	AvengingWrath = Create({ Type = "Spell", ID = 31884 }),
	CrusaderStrike = Create({ Type = "Spell", ID = 35395 }),
	Judgment = Create({ Type = "Spell", ID = 20271 }),
	HammerOfWrath = Create({ Type = "Spell", ID = 24275 }),
	Seraphim = Create({ Type = "Spell", ID = 152262 }),
	Consecration = Create({ Type = "Spell", ID = 26573 }),
	WordOfGlory = Create({ Type = "Spell", ID = 85673 }),
	ShieldOfTheRighteous = Create({ Type = "Spell", ID = 53600 }),
	BlessingOfFreedom = Create({ Type = "Spell", ID = 1044 }),
	Rebuke = Create({ Type = "Spell", ID = 96231 }),

	-- Spec Abilities

	BladeOfJustice = Create({ Type = "Spell", ID = 184575 }),
	TemplarsVerdict = Create({ Type = "Spell", ID = 85256 }),
	Crusade = Create({ Type = "Spell", ID = 231895 }),
	DivineStorm = Create({ Type = "Spell", ID = 53385 }),
	RadiantDecree = Create({ Type = "Spell", ID = 383469 }),
	FinalReckoning = Create({ Type = "Spell", ID = 343721 }),
	DivineToll = Create({ Type = "Spell", ID = 375576 }),
	WakeOfAshes = Create({ Type = "Spell", ID = 255937 }),
	ExecutionSentence = Create({ Type = "Spell", ID = 343527 }),
	FinalVerdict = Create({ Type = "Spell", ID = 383328 }),
	ShieldOfVengeance = Create({ Type = "Spell", ID = 184662 }),

	-- Buffs

	EmpyreanPower = Create({ Type = "Spell", ID = 326733 }),
	TemplarSlash = Create({ Type = "Spell", ID = 406647 }),

	-- Debuffs
	JudgmentDebuff = Create({ Type = "Spell", ID = 197277 }),
	ExecutionSentenceDebuff = Create({ Type = "Spell", ID = 343527 }),
	Entangle = Create({ Type = "Spell", ID = 408556, Hidden = true }),

	-- Talents
	ConsecratedBlade = Create({ Type = "Spell", ID = 404834 }),
	TemplarStrike = Create({ Type = "Spell", ID = 406646 }),
	DivineAuxiliary = Create({ Type = "Spell", ID = 406158 }),
	HolyBlade = Create({ Type = "Spell", ID = 383342 }),
	BlessedChampion = Create({ Type = "Spell", ID = 403010 }),
	VanguardsMomentum = Create({ Type = "Spell", ID = 383314 }),
	BoundlessJudgment = Create({ Type = "Spell", ID = 405278 }),
	CrusadingStrikes = Create({ Type = "Spell", ID = 404542 }),

	-- Hero Talents
	HammerOfLight = Create({ Type = "Spell", ID = 427453 }),

	-- Racials
	ArcaneTorrent = Create({ Type = "Spell", ID = 50613 }), -- Crusader Strike
}

local A = setmetatable(Action[ACTION_CONST_PALADIN_RETRIBUTION], { __index = Action })

A[3] = function(icon)
	local HolyPower = Player:HolyPower()
	local inMelee = A.Rebuke:IsInRange(target)
	local unitCount = MultiUnits:GetBySpell(A.Rebuke)

	local function DamageRotation(unit)
		if BurstIsON(player) and inMelee then
			if A.ExecutionSentence:IsReady(unit) then
				return A.ExecutionSentence:Show(icon)
			end
		end

		if A.HammerOfLight:IsReady(player) and inMelee then
			return A.WakeOfAshes:Show(icon)
		end

		if A.FinalVerdict:IsReady(unit) and unitCount <= 2 and inMelee and not A.HammerOfLight:IsReady(player) then
			return A.FinalVerdict:Show(icon)
		end

		if A.DivineStorm:IsReady(player) and inMelee and not A.HammerOfLight:IsReady(player) then
			return A.DivineStorm:Show(icon)
		end

		if A.WakeOfAshes:IsReady(player) and inMelee then
			return A.WakeOfAshes:Show(icon)
		end

		if A.DivineToll:IsReady(unit) and HolyPower < 3 then
			return A.DivineToll:Show(icon)
		end

		if A.BladeOfJustice:IsReady(unit) and HolyPower <= 3 then
			return A.BladeOfJustice:Show(icon)
		end

		if A.Judgment:IsReady(unit) and HolyPower <= 3 then
			return A.Judgment:Show(icon)
		end

		if A.HammerOfWrath:IsReady(unit) and HolyPower <= 3 then
			return A.HammerOfWrath:Show(icon)
		end
	end

	if A.IsUnitEnemy("target") then
		unit = "target"
		if DamageRotation(unit) then
			return true
		end
	end
end
