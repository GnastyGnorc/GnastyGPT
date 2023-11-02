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
local player = "player"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

Action[ACTION_CONST_PALADIN_RETRIBUTION] = {
    -- Class Abilities

    AvengingWrath = Create({Type = "Spell", ID = 31884}),
    CrusaderStrike = Create({Type = "Spell", ID = 35395}),
    Judgment = Create({Type = "Spell", ID = 20271}),
    HammerOfWrath = Create({Type = "Spell", ID = 24275}),
    Seraphim = Create({Type = "Spell", ID = 152262}),
    Consecration = Create({Type = "Spell", ID = 26573}),
    WordOfGlory = Create({Type = "Spell", ID = 85673}),
    ShieldOfTheRighteous = Create({Type = "Spell", ID = 53600}),

    -- Spec Abilities

    BladeOfJustice = Create({Type = "Spell", ID = 184575}),
    TemplarsVerdict = Create({Type = "Spell", ID = 85256}),
    Crusade = Create({Type = "Spell", ID = 231895}),
    DivineStorm = Create({Type = "Spell", ID = 53385}),
    RadiantDecree = Create({Type = "Spell", ID = 383469}),
    FinalReckoning = Create({Type = "Spell", ID = 343721}),
    DivineToll = Create({Type = "Spell", ID = 375576}),
    WakeOfAshes = Create({Type = "Spell", ID = 255937}),
    ExecutionSentence = Create({Type = "Spell", ID = 343527}),
    FinalVerdict = Create({Type = "Spell", ID = 383328}),
    ShieldOfVengeance = Create({Type = "Spell", ID = 184662}),

    -- Buffs

    EmpyreanPower = Create({Type = "Spell", ID = 326733}),
    TemplarSlash = Create({Type = "Spell", ID = 406647}),
    AvengingWrathBuff = Create({Type = "Spell", ID = 31884}),

    -- Debuffs
    JudgmentDebuff = Create({Type = "Spell", ID = 197277}),
    ExecutionSentenceDebuff = Create({Type = "Spell", ID = 343527}),

    -- Talents
    ConsecratedBlade = Create({Type = "Spell", ID = 404834}),
    TemplarStrike = Create({Type = "Spell", ID = 406646}),
    DivineAuxiliary = Create({Type = "Spell", ID = 406158}),
    HolyBlade = Create({Type = "Spell", ID = 383342}),
    BlessedChampion = Create({Type = "Spell", ID = 403010}),
    VanguardsMomentum = Create({Type = "Spell", ID = 383314}),
    BoundlessJudgment = Create({Type = "Spell", ID = 405278}),
    CrusadingStrikes = Create({Type = "Spell", ID = 404542}),

    -- Racials
    ArcaneTorrent = Create({Type = "Spell", ID = 50613}) -- Crusader Strike
}

local A = setmetatable(Action[ACTION_CONST_PALADIN_RETRIBUTION],
                       {__index = Action})

A[3] = function(icon)

    local HolyPower = Player:HolyPower()
    local inMelee = true
    local unitCount = MultiUnits:GetByRange(8, 5)

    -- print("inMelee: ", inMelee)

    local function DamageRotation(unit)

        if BurstIsON(player) and inMelee then

            -- shield_of_vengeance,if=fight_remains>15&(!talent.execution_sentence|!debuff.execution_sentence.up)

            -- Using Shield of Vengeance
            if A.ShieldOfVengeance:IsReady(unit) then
                local executionSentenceLearned =
                    A.ExecutionSentence:IsTalentLearned()
                local executionSentenceUp =
                    Unit(unit):HasDeBuffs(
                        A.ExecutionSentenceDebuff.ID, true) > 0

                if (not executionSentenceLearned or not executionSentenceUp) then
                    return A.ShieldOfVengeance:Show(icon)
                end
            end

            -- execution_sentence,if=(!buff.crusade.up&cooldown.crusade.remains>15|buff.crusade.stack=10|cooldown.avenging_wrath.remains<0.75|cooldown.avenging_wrath.remains>15)&(holy_power>=3|holy_power>=2&talent.divine_auxiliary)&(target.time_to_die>8|target.time_to_die>12&talent.executioners_will)

            -- Using Execution Sentence
            if A.ExecutionSentence:IsReady(unit) then
                local avengingWrathRemains = A.AvengingWrath:GetCooldown()
                local divineAuxiliaryLearned =
                    A.DivineAuxiliary:IsTalentLearned()

                if ((avengingWrathRemains < 0.75 or avengingWrathRemains > 15) and
                    (HolyPower >= 3 or
                        (HolyPower >= 2 and divineAuxiliaryLearned))) then
                    return A.ExecutionSentence:Show(icon)
                end
            end

            --  	avenging_wrath,if=holy_power>=4&time<5|holy_power>=3&time>5|holy_power>=2&talent.divine_auxiliary&(cooldown.execution_sentence.remains=0|cooldown.final_reckoning.remains=0)

            -- Avenging Wrath
            if A.AvengingWrath:IsReady(player) then
                -- Check if Divine Auxiliary talent is learned
                local hasDivineAuxiliary = A.DivineAuxiliary:IsTalentLearned()

                -- Check if Execution Sentence or Final Reckoning is off cooldown
                local executionSentenceReady =
                    A.ExecutionSentence:GetCooldown() == 0
                local finalReckoningReady = A.FinalReckoning:GetCooldown() == 0

                -- Conditions
                if (HolyPower >= 4) or
                    (HolyPower >= 2 and hasDivineAuxiliary and
                        (executionSentenceReady or finalReckoningReady)) then
                    return A.AvengingWrath:Show(icon)
                end
            end

            -- final_reckoning,if=(holy_power>=4&time<8|holy_power>=3&time>=8|holy_power>=2&talent.divine_auxiliary)&(cooldown.avenging_wrath.remains>10|cooldown.crusade.remains&(!buff.crusade.up|buff.crusade.stack>=10))&(time_to_hpg>0|holy_power=5|holy_power>=2&talent.divine_auxiliary)&(!raid_event.adds.exists|raid_event.adds.up|raid_event.adds.in>40)

            -- Final Reckoning
            if A.FinalReckoning:IsReady(player) then

                -- Check if Avenging Wrath or Crusade is on cooldown, and Crusade buff status if applicable
                local avengingWrathCooldown = A.AvengingWrath:GetCooldown() > 10

                -- Conditions
                if (HolyPower >= 4) and avengingWrathCooldown then
                    return A.FinalReckoning:Show(icon)
                end
            end

        end

        -- Use FinalVerdict if in melee, unitCount is 1, and either Burst is not ON or Avenging Wrath is not about to come off cooldown
        if A.FinalVerdict:IsReady(unit) and inMelee and unitCount == 1 then
            if not BurstIsON(player) or A.AvengingWrath:GetCooldown() > 3 then
                -- print("Debug: Using FinalVerdict")
                return A.FinalVerdict:Show(icon)
            else
                -- print(
                --     "Debug: Skipping FinalVerdict due to Burst or Avenging Wrath")
            end
        end

        -- Use DivineStorm if in melee and either Burst is not ON or Avenging Wrath is not about to come off cooldown
        if A.DivineStorm:IsReady(player) and inMelee then
            if not BurstIsON(player) or A.AvengingWrath:GetCooldown() > 3 then
                -- print("Debug: Using DivineStorm")
                return A.DivineStorm:Show(icon)
            else
                -- print(
                --     "Debug: Skipping DivineStorm due to Burst or Avenging Wrath")
            end
        end

        -- wake_of_ashes,if=holy_power<=2&(cooldown.avenging_wrath.remains|cooldown.crusade.remains)&(!talent.execution_sentence|cooldown.execution_sentence.remains>4|target.time_to_die<8)&(!raid_event.adds.exists|raid_event.adds.in>20|raid_event.adds.up)

        -- Using Wake of Ashes
        if A.WakeOfAshes:IsReady(unit) then
            local avengingWrathRemains = A.AvengingWrath:GetCooldown()
            local holyPower = HolyPower -- Assuming you have a variable for this
            local executionSentenceRemains = A.ExecutionSentence:GetCooldown()
            local executionSentenceLearned =
                A.ExecutionSentence:IsTalentLearned()

            if (holyPower <= 2 and avengingWrathRemains > 0 and
                (not executionSentenceLearned or executionSentenceRemains > 4)) then
                -- Assuming you handle raid events separately or they are not a concern
                return A.WakeOfAshes:Show(icon)
            end
        end

        -- Divine Toll
        if A.DivineToll:IsReady(unit) and HolyPower <= 2 and
            Unit(unit):HasDeBuffs(A.JudgmentDebuff.ID, player) == 0 and
            (A.AvengingWrath:GetCooldown() > 15) then
            return A.DivineToll:Show(icon)
        end

        -- blade_of_justice,if=(holy_power<=3|!talent.holy_blade)&(spell_targets.divine_storm>=2&!talent.crusading_strikes|spell_targets.divine_storm>=4)

        -- Blade of Justice
        if A.BladeOfJustice:IsReady(unit) and
            (HolyPower <= 3 or not A.HolyBlade:IsTalentLearned()) and unitCount >=
            3 then return A.BladeOfJustice:Show(icon) end

        -- hammer_of_wrath,if=(spell_targets.divine_storm<2|!talent.blessed_champion|set_bonus.tier30_4pc)&(holy_power<=3|target.health.pct>20|!talent.vanguards_momentum)

        -- Hammer of Wrath
        if A.HammerOfWrath:IsReady(unit) and
            (HolyPower <= 3 or Unit(target):HealthPercent() > 20 or
                not A.VanguardsMomentum:IsTalentLearned()) then
            return A.HammerOfWrath:Show(icon)
        end

        -- judgment,if=!buff.avenging_wrath.up&(holy_power<=3|!talent.boundless_judgment)&talent.crusading_strikes

        -- Using Judgment
        if A.Judgment:IsReady(unit) then
            local avengingWrathUp =
                Unit(player):HasBuffs(A.AvengingWrathBuff.ID) > 0
            local boundlessJudgmentLearned =
                A.BoundlessJudgment:IsTalentLearned()
            local crusadingStrikesLearned = A.CrusadingStrikes:IsTalentLearned()

            if (not avengingWrathUp and
                (HolyPower <= 3 or not boundlessJudgmentLearned) and
                crusadingStrikesLearned) then
                return A.Judgment:Show(icon)
            end
        end

        -- Blade of Justice ST

        if A.BladeOfJustice:IsReady(unit) and
            (HolyPower <= 3 or not A.HolyBlade:IsTalentLearned()) then
            return A.BladeOfJustice:Show(icon)
        end

        -- judgment,if=!buff.avenging_wrath.up&(holy_power<=3|!talent.boundless_judgment)&talent.crusading_strikes

        -- Judgment
        if A.Judgment:IsReady(unit) and
            (Unit(player):HasBuffs(A.AvengingWrathBuff.ID) == 0) and
            (HolyPower <= 3 or not A.BoundlessJudgment:IsTalentLearned()) and
            A.CrusadingStrikes:IsTalentLearned() then
            return A.Judgment:Show(icon)
        end

    end

    if A.IsUnitEnemy("target") then
        unit = "target"
        if DamageRotation(unit) then return true end
    end
end
