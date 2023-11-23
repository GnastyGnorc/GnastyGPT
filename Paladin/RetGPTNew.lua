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

    AvengingWrath = Create({Type = "Spell", ID = 31884}),
    CrusaderStrike = Create({Type = "Spell", ID = 35395}),
    Judgment = Create({Type = "Spell", ID = 20271}),
    HammerOfWrath = Create({Type = "Spell", ID = 24275}),
    Seraphim = Create({Type = "Spell", ID = 152262}),
    Consecration = Create({Type = "Spell", ID = 26573}),
    WordOfGlory = Create({Type = "Spell", ID = 85673}),
    ShieldOfTheRighteous = Create({Type = "Spell", ID = 53600}),
    BlessingOfFreedom = Create({Type = "Spell", ID = 1044}),
    Rebuke = Create({Type = "Spell", ID = 96231}),

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
    EchoesOfWrath = Create({Type = "Spell", ID = 423590}),

    -- Debuffs
    JudgmentDebuff = Create({Type = "Spell", ID = 197277}),
    ExecutionSentenceDebuff = Create({Type = "Spell", ID = 343527}),
    Entangle = Create({Type = "Spell", ID = 408556, Hidden = true}),
    Expurgation = Create({Type = "Spell", ID = 383346, Hidden = true}),

    -- Talents
    ConsecratedBlade = Create({Type = "Spell", ID = 404834}),
    TemplarStrike = Create({Type = "Spell", ID = 406646}),
    DivineAuxiliary = Create({Type = "Spell", ID = 406158}),
    HolyBlade = Create({Type = "Spell", ID = 383342}),
    BlessedChampion = Create({Type = "Spell", ID = 403010}),
    VanguardsMomentum = Create({Type = "Spell", ID = 383314}),
    BoundlessJudgment = Create({Type = "Spell", ID = 405278}),
    CrusadingStrikes = Create({Type = "Spell", ID = 404542}),
    ExecutionersWill = Create({Type = "Spell", ID = 406940}),

    -- Racials
    ArcaneTorrent = Create({Type = "Spell", ID = 50613}) -- Crusader Strike
}

local A = setmetatable(Action[ACTION_CONST_PALADIN_RETRIBUTION],
                       {__index = Action})

local function isInRange(unit) return A.Detox:IsInRange(unit) end

local function isInRangeMelee(unit) return A.Rebuke:IsInRange(unit) end

A[3] = function(icon)

    local HolyPower = Player:HolyPower()
    local inMelee = true
    local isAoE = GetToggle(2, "AoE")
    local unitCount = MultiUnits:GetBySpell(A.Rebuke)

    local avengingWrathRemains = A.AvengingWrath:GetCooldown()

    local function DamageRotation(unit)

        if Unit(player):HasDeBuffs(A.Entangle.ID) > 0 and
            Unit(player):HasDeBuffs(A.Entangle.ID) <= 7.7 and
            A.BlessingOfFreedom:IsReady(player) then
            return A.BlessingOfFreedom:Show(icon)
        end

        if BurstIsON(player) and isInRangeMelee(unit) then

            -- shield_of_vengeance,if=fight_remains>15&(!talent.execution_sentence|!debuff.execution_sentence.up)

            if A.ShieldOfVengeance:IsReady(player) and
                Unit(target):HasDeBuffs(A.ExecutionSentence.ID, true) == 0 then
                return A.ShieldOfVengeance:Show(icon)
            end

            -- avenging_wrath,if=holy_power>=4&time<5|holy_power>=3&time>5|holy_power>=2&talent.divine_auxiliary&(cooldown.execution_sentence.remains=0|cooldown.final_reckoning.remains=0)

            if A.AvengingWrath:IsReady(unit) and HolyPower >= 3 then
                return A.AvengingWrath:Show(icon)
            end

            -- st
            -- execution_sentence,if=(!buff.crusade.up&cooldown.crusade.remains>15|buff.crusade.stack=10|cooldown.avenging_wrath.remains<0.75|cooldown.avenging_wrath.remains>15)&(holy_power>=4&time<5|holy_power>=3&time>5|holy_power>=2&talent.divine_auxiliary)&(target.time_to_die>8&!talent.executioners_will|target.time_to_die>12)

            -- Cast Execution Sentence if conditions are met
            if A.ExecutionSentence:IsReady(unit) and
                ((avengingWrathRemains < 0.75 or avengingWrathRemains > 15) and
                    HolyPower >= 3 and
                    ((Unit(unit):TimeToDie() > 8 and
                        not A.ExecutionersWill:IsTalentLearned()) or
                        Unit(unit):TimeToDie() > 12)) then
                return A.ExecutionSentence:Show(icon)
            end

            -- mt
            -- final_reckoning,if=(holy_power>=4&time<8|holy_power>=3&time>=8|holy_power>=2&talent.divine_auxiliary)&(cooldown.avenging_wrath.remains>10|cooldown.crusade.remains&(!buff.crusade.up|buff.crusade.stack>=10))&(time_to_hpg>0|holy_power=5|holy_power>=2&talent.divine_auxiliary)&(!raid_event.adds.exists|raid_event.adds.up|raid_event.adds.in>40)

            -- Cast Final Reckoning if conditions are met
            if A.FinalReckoning:IsReady(player) and isInRangeMelee(unit) and HolyPower >= 3 and
                avengingWrathRemains > 10 then
                return A.FinalReckoning:Show(icon)
            end

        end

        ---- actions.finishers

        -- mt
        -- divine_storm,if=variable.ds_castable&(!talent.crusade|cooldown.crusade.remains>gcd*3|buff.crusade.up&buff.crusade.stack<10)

        if A.DivineStorm:IsReady(unit) and isInRangeMelee(unit) and unitCount >=
            2 then return A.DivineStorm:Show(icon) end

        -- st
        -- templars_verdict,if=!talent.crusade|cooldown.crusade.remains>gcd*3|buff.crusade.up&buff.crusade.stack<10

        if A.TemplarsVerdict:IsReady(unit) and isInRangeMelee(unit) and
            unitCount == 1 then return A.TemplarsVerdict:Show(icon) end

        ---- actions.generators

        -- wake_of_ashes,if=holy_power<=2&(cooldown.avenging_wrath.remains|cooldown.crusade.remains)&(!talent.execution_sentence|cooldown.execution_sentence.remains>4|target.time_to_die<8)&(!raid_event.adds.exists|raid_event.adds.in>20|raid_event.adds.up)

        -- Wake of Ashes
        if A.WakeOfAshes:IsReady(unit) and HolyPower <= 2 and
            (avengingWrathRemains > 0) then
            return A.WakeOfAshes:Show(icon)
        end

        -- blade_of_justice,if=!dot.expurgation.ticking&set_bonus.tier31_2pc

        if A.BladeOfJustice:IsReady(unit) and isInRangeMelee(unit) and
            Unit(unit):HasDeBuffs(A.Expurgation.ID) == 0 then
            return A.BladeOfJustice:Show(icon)
        end

        -- divine_toll,if=holy_power<=2&(!raid_event.adds.exists|raid_event.adds.in>30|raid_event.adds.up)&(cooldown.avenging_wrath.remains>15|cooldown.crusade.remains>15|fight_remains<8)

        -- Divine Toll
        if A.DivineToll:IsReady(unit) and HolyPower <= 2 and
            (avengingWrathRemains > 15) then
            return A.DivineToll:Show(icon)
        end

        -- judgment,if=dot.expurgation.ticking&!buff.echoes_of_wrath.up&set_bonus.tier31_2pc

        if A.Judgment:IsReady(unit) and isInRangeMelee(unit) and
            Unit(unit):HasDeBuffs(A.Expurgation.ID) > 0 and
            Unit(player):HasBuffs(A.EchoesOfWrath.ID) == 0 then
            return A.Judgment:Show(icon)
        end

        -- mt
        -- blade_of_justice,if=(holy_power<=3|!talent.holy_blade)&(spell_targets.divine_storm>=2&!talent.crusading_strikes|spell_targets.divine_storm>=4)

        if A.BladeOfJustice:IsReady(unit) and (Player:HolyPower() <= 3) and
            (unitCount >= 4) then return A.BladeOfJustice:Show(icon) end

        -- st
        -- hammer_of_wrath,if=(spell_targets.divine_storm<2|!talent.blessed_champion|set_bonus.tier30_4pc)&(holy_power<=3|target.health.pct>20|!talent.vanguards_momentum)

        if A.HammerOfWrath:IsReady(unit) and (unitCount < 2) and
            (HolyPower <= 3 or Unit(unit):HealthPercent() > 20 or
                not A.VanguardsMomentum:IsTalentLearned()) then
            return A.HammerOfWrath:Show(icon)
        end

        -- st
        -- blade_of_justice,if=holy_power<=3|!talent.holy_blade

        if A.BladeOfJustice:IsReady(unit) and isInRangeMelee(unit) and HolyPower <=
            3 and unitCount == 1 then return A.BladeOfJustice:Show(icon) end

        -- st
        -- judgment,if=holy_power<=3|!talent.boundless_judgment

        if A.Judgment:IsReady(unit) and isInRangeMelee(unit) and HolyPower <= 3 and
            unitCount == 1 and not A.BoundlessJudgment:IsTalentLearned() then
            return A.Judgment:Show(icon)
        end

        -- mt
        -- hammer_of_wrath,if=holy_power<=3|target.health.pct>20|!talent.vanguards_momentum

        -- Hammer of Wrath
        if A.HammerOfWrath:IsReady(unit) and
            (HolyPower <= 3 or Unit(unit):HealthPercent() > 20 or
                not A.VanguardsMomentum:IsTalentLearned()) then
            return A.HammerOfWrath:Show(icon)
        end

    end

    if A.IsUnitEnemy("target") then
        unit = "target"
        if DamageRotation(unit) then return true end
    end
end
