-- GMGPT.lua
-- TWW 1/3/25

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

local ACTION_CONST_HUNTER_BEASTMASTERY = CONST.HUNTER_BEASTMASTERY
local ACTION_CONST_AUTOTARGET = CONST.AUTOTARGET

local IsIndoors, UnitIsUnit = _G.IsIndoors, _G.UnitIsUnit

Action[ACTION_CONST_HUNTER_BEASTMASTERY] = {
	-- Rotation
	-- bestial_wrath = Create({Type = "Spell", ID })
	MultiShot = Create({ Type = "Spell", ID = 2643 }),
	BarbedShot = Create({ Type = "Spell", ID = 217200 }),
	KillCommand = Create({ Type = "Spell", ID = 34026 }),
	KillShot = Create({ Type = "Spell", ID = 53351 }),
	CobraShot = Create({ Type = "Spell", ID = 193455 }),
	BestialWrath = Create({ Type = "Spell", ID = 19574 }),
	DeathChakram = Create({ Type = "Spell", ID = 375891 }),
	DireBeast = Create({ Type = "Spell", ID = 120679 }),
	Bloodshed = Create({ Type = "Spell", ID = 321530 }),
	CallOfTheWild = Create({ Type = "Spell", ID = 359844 }),
	BlackArrow = Create({ Type = "Spell", ID = 430703 }),
	ExplosiveShot = Create({ Type = "Spell", ID = 212431 }),

	-- Defensives
	Exhilaration = Create({ Type = "Spell", ID = 109304 }),
	MendPet = Action.Create({ Type = "Spell", ID = 136, Texture = 136 }),

	-- Buffs
	BeastCleaveBuff = Action.Create({ Type = "Spell", ID = 268877 }),
	FrenzyBuff = Action.Create({ Type = "Spell", ID = 272790 }),
	AspectOfTheWildBuff = Action.Create({ Type = "Spell", ID = 193530 }),
	CallOfTheWildBuff = Action.Create({ Type = "Spell", ID = 359844 }),
    

	-- Talents
	ScentOfBlood = Action.Create({ Type = "Spell", ID = 193532, isTalent = true }),
	KillCleave = Action.Create({ Type = "Spell", ID = 378207, isTalent = true }),
	WildCall = Action.Create({ Type = "Spell", ID = 185789, isTalent = true }),
	AlphaPredator = Action.Create({ Type = "Spell", ID = 269737, isTalent = true }),
	WildInstincts = Action.Create({ Type = "Spell", ID = 378442, isTalent = true }),
    BloodyFrenzy = Action.Create({ Type = "Spell", ID = 407412, isTalent = true }),
    FuriousAssault = Create({ Type = "Spell", ID = 445699, isTalent = true }),
    BarbedScales = Create({ Type = "Spell", ID = 469880, isTalent = true }),
    Savagery = Create({ Type = "Spell", ID = 424557, isTalent = true }),

	-- Racials
	ArcaneTorrent = Create({ Type = "Spell", ID = 50613 }),

	-- Pets
	Claw = Action.Create({ Type = "Spell", ID = 16827, Texture = 16827 }),
}

local A = setmetatable(Action[ACTION_CONST_HUNTER_BEASTMASTERY], { __index = Action })

local player = "player"
local pet = "pet"

Pet:AddActionsSpells(253, {

	-- number accepted
	17253, -- Bite
	16827, -- Claw
	49966, -- Smack
}, true)

A[3] = function(icon)


	local function GetEnemiesInRangeOfPetAttack()
		local petAttackSpellIDs = {16827, 17253, 49966}  -- Claw, Bite, Smack
		local enemyCount = 0
	
		for i = 1, 40 do
			local unitID = "nameplate" .. i
			if UnitExists(unitID) and UnitCanAttack("player", unitID) then
				for _, spellID in ipairs(petAttackSpellIDs) do
					if C_Spell.IsSpellInRange(spellID, unitID) == true then
						enemyCount = enemyCount + 1
						break
					end
				end
			end
		end
	
		return enemyCount
	end

	local isAoE = GetEnemiesInRangeOfPetAttack() >= 2
	
	local function BasicDamageRotation(unit)
		local petHP = Unit(pet):HealthPercent()

		if A.Exhilaration:IsReady(player) and Pet:IsActive() and Unit(pet):HealthPercent() <= 30 then
			return A.Exhilaration:Show(icon)
		elseif A.MendPet:IsReady(player) and Pet:IsActive() and Unit(pet):HealthPercent() <= 60 then
			return A.MendPet:Show(icon)
		end

        if isAoE then
            
            if A.BarbedShot:IsReady(unit) then
                -- Check for pet's Frenzy buff and remaining time
                local frenzyUp = Unit(pet):HasBuffs(A.FrenzyBuff.ID, true) > 0
                local frenzyRemains = Unit(pet):HasBuffs(A.FrenzyBuff.ID, true)
                local frenzyStacks = Unit(pet):HasBuffsStacks(A.FrenzyBuff.ID, true)
                
                -- Check cooldown states
                local bestialWrathReady = A.BestialWrath:GetCooldown() == 0
                local callOfTheWildReady = A.CallOfTheWild:GetCooldown() == 0
                
                -- Get Barbed Shot charge info
                local barbedShotCharges = A.BarbedShot:GetSpellChargesFrac()
            
                -- Main conditions
                if (frenzyUp and frenzyRemains <= GetGCD() + 0.25) or -- Maintain Frenzy buff
                   (frenzyStacks < 3 and ( -- Build Frenzy stacks with BW or CotW
                       (bestialWrathReady and (not frenzyUp or A.ScentOfBlood:IsTalentLearned())) or
                       (A.CallOfTheWild:IsTalentLearned() and callOfTheWildReady)
                   )) or
                   (A.WildCall:IsTalentLearned() and barbedShotCharges > 1.8) -- Use charges with Wild Call
                then
                    return A.BarbedShot:Show(icon)
                end
            end

            if A.MultiShot:IsReady(player) then
                -- Check pet's Beast Cleave buff remaining duration
                local beastCleaveRemains = Unit(pet):HasBuffs(A.BeastCleaveBuff.ID)
                
                -- Check if we should refresh Beast Cleave
                if beastCleaveRemains < (0.25 + GetGCD()) and 
                   (not A.BloodyFrenzy:IsTalentLearned() or A.CallOfTheWild:GetCooldown() > 0) -- Add BloodyFrenzy talent const
                then
                    return A.MultiShot:Show(icon)
                end
            end

            if A.CallOfTheWild:IsReady(player) then
                return A.CallOfTheWild:Show(icon)
            end

            if A.BestialWrath:IsReady(player) then
                return A.BestialWrath:Show(icon)
            end

            if A.KillCommand:IsReady(unit) then
                return A.KillCommand:Show(icon)
            end

            if A.BarbedShot:IsReady(unit) then
                -- Check conditions for using Barbed Shot
                local callOfTheWildActive = Unit(player):HasBuffs(A.CallOfTheWildBuff.ID) > 0
                
                -- Combine talent checks
                local shouldUseByTalents = A.FuriousAssault:IsTalentLearned() or 
                                          (A.BlackArrow:IsTalentLearned() and 
                                           (A.BarbedScales:IsTalentLearned() or 
                                            A.Savagery:IsTalentLearned()))
                
                -- Use if any condition is met
                if callOfTheWildActive or shouldUseByTalents then
                    return A.BarbedShot:Show(icon)
                end
            end

            if A.KillShot:IsReady(unit) then
                return A.KillShot:Show(icon)
            end

            if A.ExplosiveShot:IsReady(unit) then
                return A.ExplosiveShot:Show(icon)
            end

            if A.DireBeast:IsReady(unit) then
                return A.DireBeast:Show(icon)
            end

            if A.CobraShot:IsReady(unit) then
                -- Check if time to max focus is less than 2 GCDs
                if Player:FocusTimeToMax() < GetGCD() * 2 then
                    return A.CobraShot:Show(icon) 
                end
            end
            
        end

       
        


	end

	if A.IsUnitEnemy("target") then
		unit = "target"
		if BasicDamageRotation(unit) then
			return true
		end
	end
end
