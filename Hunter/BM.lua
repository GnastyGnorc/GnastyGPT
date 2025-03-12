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

	-- print(Pet:GetInRange(49966))
	-- print(Pet:GetInRange(17253))
	-- print(Pet:GetInRange(16827))

	

	local function BasicDamageRotation(unit)
		local petHP = Unit(pet):HealthPercent()

		if A.Exhilaration:IsReady(player) and Pet:IsActive() and Unit(pet):HealthPercent() <= 30 then
			return A.Exhilaration:Show(icon)
		elseif A.MendPet:IsReady(player) and Pet:IsActive() and Unit(pet):HealthPercent() <= 60 then
			return A.MendPet:Show(icon)
		end

		-- ST Rotation
		if not isAoE then
			-- barbed_shot,target_if=min:dot.barbed_shot.remains,if=pet.main.buff.frenzy.up&pet.main.buff.frenzy.remains<=gcd+0.25|talent.scent_of_blood&pet.main.buff.frenzy.stack<3&cooldown.bestial_wrath.ready
			if A.BarbedShot:IsReady(unit) then
				local frenzyRemains = Unit(pet):HasBuffs(A.FrenzyBuff.ID, true) -- Frenzy buff remaining time on pet
				local frenzyStacks = Unit(pet):HasBuffsStacks(A.FrenzyBuff.ID, true) -- Frenzy buff stacks on pet
				local bestialWrathCooldownReady = A.BestialWrath:GetCooldown() == 0 -- Bestial Wrath cooldown check

				-- Check if the pet's frenzy buff is up and is about to expire
				local shouldUseForFrenzy = (frenzyRemains > 0) and (frenzyRemains <= (GetGCD() + 0.25))

				-- Check if we should use Barbed Shot for Scent of Blood talent
				local shouldUseForScentOfBlood = A.ScentOfBlood:IsTalentLearned()
					and (frenzyStacks < 3)
					and bestialWrathCooldownReady

				if shouldUseForFrenzy or shouldUseForScentOfBlood then
					-- Assuming 'minDebuffTarget' is a function that returns the target unitID with minimum barbed shot debuff
					return A.BarbedShot:Show(icon)
				end
			end

			if A.CallOfTheWild:IsReady(player) then
				return A.CallOfTheWild:Show(icon)
			end

			-- kill_command,if=full_recharge_time<gcd&talent.alpha_predator
			if
				A.KillCommand:IsReady(unit)
				and A.KillCommand:GetCooldown() < GetGCD()
				and A.AlphaPredator:IsTalentLearned()
			then
				return A.KillCommand:Show(icon)
			end

			-- death_chakram

			if A.DeathChakram:IsReady(unit) then
				return A.DeathChakram:Show(icon)
			end

			-- bloodshed
			if A.Bloodshed:IsReady(unit) then
				return A.Bloodshed:Show(icon)
			end

			-- bestial_wrath
			if A.BestialWrath:IsReady(player) and not Unit(unit):IsDead() then
				return A.BestialWrath:Show(icon)
			end

			-- kill_command,if=talent.kill_cleave

			if A.KillCommand:IsReady(player) then
				-- Check if the Kill Cleave talent is learned
				if A.KillCleave:IsTalentLearned() then
					return A.KillCommand:Show(icon)
				end
			end

			-- barbed_shot,target_if=min:dot.barbed_shot.remains,if=talent.wild_instincts&buff.call_of_the_wild.up|talent.wild_call&charges_fractional>1.4|full_recharge_time<gcd&cooldown.bestial_wrath.remains|talent.scent_of_blood&(cooldown.bestial_wrath.remains<12+gcd|full_recharge_time+gcd<8&cooldown.bestial_wrath.remains<24+(8-gcd)+full_recharge_time)|fight_remains<9
			if A.BarbedShot:IsReady(unit) then
				local bestialWrathCooldown = A.BestialWrath:GetCooldown() -- Bestial Wrath cooldown
				local barbedShotRecharge = A.BarbedShot:GetSpellChargesFrac() -- Barbed Shot charges fractional
				local barbedShotFullRecharge = A.BarbedShot:GetCooldown() -- Barbed Shot full recharge time

				-- Check various conditions for casting Barbed Shot
				local shouldUseForWildInstincts = A.WildInstincts:IsTalentLearned()
					and Unit(player):HasBuffs(A.CallOfTheWildBuff.ID) > 0
				local shouldUseForWildCall = A.WildCall:IsTalentLearned() and barbedShotRecharge > 1.4
				local shouldUseForBestialWrath = barbedShotFullRecharge < GetGCD() and bestialWrathCooldown < GetGCD()
				local shouldUseForScentOfBlood = A.ScentOfBlood:IsTalentLearned()
					and (
						bestialWrathCooldown < (12 + GetGCD())
						or (
							barbedShotFullRecharge + GetGCD() < 8
							and bestialWrathCooldown < (24 + (8 - GetGCD()) + barbedShotFullRecharge)
						)
					)

				if
					shouldUseForWildInstincts
					or shouldUseForWildCall
					or shouldUseForBestialWrath
					or shouldUseForScentOfBlood
				then
					-- Assuming 'minDebuffTarget' is a function that returns the target unitID with minimum barbed shot debuff

					return A.BarbedShot:Show(icon)
				end
			end

			-- dire_beast
			if A.DireBeast:IsReady(unit) then
				return A.DireBeast:Show(icon)
			end

			if A.KillShot:IsReady(unit) then
				return A.KillShot:Show(icon)
			end

			-- cobra_shot
			if A.CobraShot:IsReady(unit) then
				return A.CobraShot:Show(icon)
			end
		end

		-- barbed_shot,target_if=min:dot.barbed_shot.remains,if=pet.main.buff.frenzy.up&pet.main.buff.frenzy.remains<=gcd+0.25|talent.scent_of_blood&cooldown.bestial_wrath.remains<12+gcd|full_recharge_time<gcd&cooldown.bestial_wrath.remains

		if A.BarbedShot:IsReady(player) then
			-- Check for pet's frenzy buff and its duration
			if
				Unit(pet):HasBuffs(A.FrenzyBuff.ID) > 0
				and Unit(pet):HasBuffs(A.FrenzyBuff.ID) <= (A.GetGCD() + 0.3)
			then
				return A.BarbedShot:Show(icon)
			end

			-- Check for the scent of blood talent and bestial wrath cooldown
			if A.ScentOfBlood:IsTalentLearned() and A.BestialWrath:GetCooldown() < (12 + A.GetGCD()) then
				return A.BarbedShot:Show(icon)
			end

			-- Check for full recharge time and bestial wrath cooldown
			if A.BarbedShot:GetSpellChargesFullRechargeTime() < A.GetGCD() and A.BestialWrath:GetCooldown() then
				return A.BarbedShot:Show(icon)
			end
		end

		if A.BlackArrow:IsReady(unit) then
			return A.ArcaneTorrent:Show(icon)
		end

		-- multishot,if=gcd-pet.main.buff.beast_cleave.remains>0.25

		if
			A.MultiShot:IsReady(player)
			and (
				Pet:GetInRange(17253) >= 2 -- Bite
				or Pet:GetInRange(16827) >= 2 -- Claw
				or Pet:GetInRange(49966) >= 2 -- Smack
			)
		then
			-- Check if the remaining duration of the beast cleave buff on the pet is less than the gcd minus 0.25
			if (A.GetGCD() - Unit(pet):HasBuffs(A.BeastCleaveBuff.ID)) > 0.25 then
				return A.MultiShot:Show(icon)
			end
		end

		if A.DireBeast:IsReady(unit) then
			return A.DireBeast:Show(icon)
		end

		if A.CallOfTheWild:IsReady(player) then
			return A.CallOfTheWild:Show(icon)
		end

		-- bestial_wrath

		if A.BestialWrath:IsReady(player) and not Unit(unit):IsDead() then
			return A.BestialWrath:Show(icon)
		end

		-- kill_command,if=talent.kill_cleave

		if A.KillCommand:IsReady(player) then
			-- Check if the Kill Cleave talent is learned
			if A.KillCleave:IsTalentLearned() then
				return A.KillCommand:Show(icon)
			end
		end

		-- barbed_shot,talent.wild_call&charges_fractional>1.2

		if A.BarbedShot:IsReady(unit) and A.WildCall:IsTalentLearned() then
			if A.BarbedShot:GetSpellChargesFrac() > 1.2 then
				return A.BarbedShot:Show(icon)
			end
		end

		-- -- multishot,if=pet.main.buff.beast_cleave.remains<gcd*2

		-- if A.MultiShot:IsReady(unit) and (Pet:GetInRange(17253) >= 2 or -- Bite
		--     Pet:GetInRange(16827) >= 2 or -- Claw
		-- Pet:GetInRange(49966) >= 2 -- Smack
		-- ) then
		--     if Unit(pet):HasBuffs(A.BeastCleaveBuff.ID) < A.GetGCD() * 2 then
		--         return A.MultiShot:Show(icon)
		--     end
		-- end

		-- kill_shot

		if A.CobraShot:IsReady(unit) and Unit(player):HasBuffs(A.BestialWrath.ID) ~= 0 then
			return A.CobraShot:Show(icon)
		end

		if A.KillShot:IsReady(unit) then
			return A.KillShot:Show(icon)
		end

        if A.ExplosiveShot:IsReady(unit) then
            return A.ExplosiveShot:Show(icon)
        end

		-- cobra_shot,if=focus.time_to_max<gcd*2|buff.aspect_of_the_wild.up&focus.time_to_max<gcd*4

		if A.CobraShot:IsReady(unit) then
			if
				Player:FocusTimeToMax() < A.GetGCD() * 2
				or (Unit(player):HasBuffs(A.AspectOfTheWildBuff.ID) > 0 and Player:FocusTimeToMax() < A.GetGCD() * 4)
			then
				return A.CobraShot:Show(icon)
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
