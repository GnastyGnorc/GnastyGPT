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

local player = "player"
local unit = "target"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

Action[ACTION_CONST_MONK_BREWMASTER] = {
    -- Class Tree

    BlackoutKick = Action.Create({Type = "Spell", ID = 205523}),
    ChiWave = Action.Create({Type = "Spell", ID = 115098}),
    DampenHarm = Action.Create({Type = "Spell", ID = 122278}),
    DiffuseMagic = Action.Create({Type = "Spell", ID = 122783}),
    ExpelHarm = Action.Create({Type = "Spell", ID = 322101}),
    FortifyingBrew = Action.Create({Type = "Spell", ID = 115203}),
    RisingSunKick = Action.Create({Type = "Spell", ID = 107428}),
    SpinningCraneKick = Action.Create({Type = "Spell", ID = 322729}),
    SummonWhiteTigerStatue = Action.Create({Type = "Spell", ID = 388686}),
    TigerPalm = Action.Create({Type = "Spell", ID = 100780}),
    TouchOfDeath = Action.Create({Type = "Spell", ID = 322109}),
    Paralysis = Create({Type = "Spell", ID = 115078}),

    -- Spec Tree

    BonedustBrew = Action.Create({Type = "Spell", ID = 386276}),
    BreathOfFire = Action.Create({Type = "Spell", ID = 115181}),
    CelestialBrew = Action.Create({Type = "Spell", ID = 322507}),
    Detox = Action.Create({Type = "Spell", ID = 218164}),
    ExplodingKeg = Action.Create({Type = "Spell", ID = 325153}),
    HealingElixir = Action.Create({Type = "Spell", ID = 122281}),
    KegSmash = Action.Create({Type = "Spell", ID = 121253}),
    PurifyingBrew = Action.Create({Type = "Spell", ID = 119582}),
    RushingJadeWind = Action.Create({Type = "Spell", ID = 116847}),
    WeaponsOfOrder = Action.Create({Type = "Spell", ID = 387184}),
    ZenMeditation = Action.Create({Type = "Spell", ID = 115176}),
    InvokeNiuzao = Action.Create({Type = "Spell", ID = 132578}),

    -- Buffs
    WeaponsOfOrderBuff = Action.Create({
        Type = "Spell",
        ID = 322695,
        Hidden = true
    }),
    BlackoutComboBuff = Action.Create({
        Type = "Spell",
        ID = 196736,
        Hidden = true
    }),
    CharredPassionsBuff = Action.Create({
        Type = "Spell",
        ID = 386963,
        Hidden = true
    }),

    -- Debuffs
    StaggerHeavy = Action.Create({Type = "Spell", ID = 124273, Hidden = true}),
    StaggerModerate = Action.Create({Type = "Spell", ID = 124274, Hidden = true}),
    StaggerLight = Action.Create({Type = "Spell", ID = 124275, Hidden = true}),
    WeaponsOfOrderDebuff = Action.Create({
        Type = "Spell",
        ID = 387179,
        Hidden = true
    }),

    -- Talents
    BlackoutCombo = Action.Create({Type = "Spell", ID = 196736})
}

local A = setmetatable(Action[ACTION_CONST_MONK_BREWMASTER], {__index = Action})

local function HasStagger() return UnitStagger(player) > 0 end

A[3] = function(icon)

    local isMoving = A.Player:IsMoving()
    local lastCast = A.LastPlayerCastID
    local inMelee = A.TigerPalm:IsInRange(target)
    -- local unitCount = MultiUnits:GetByRange(8, 5)
    local unitCount = MultiUnits:GetBySpell(A.TigerPalm)
    local combatTime = Unit("player"):CombatTime()

    -- print("unitCount: ", unitCount)

    -- print("combatTime: ", combatTime)

    -- TODO: Purify when in red stagger

    -- Defensives

    if A.Paralysis:IsReady() and Unit(mouseover):Name() == "Incorporeal Being" then
        return A.Paralysis:Show(icon)
    end

    if A.TouchOfDeath:IsReady(unit) then return A.TouchOfDeath:Show(icon) end

    if A.PurifyingBrew:IsReady(player) and
        (A.PurifyingBrew:GetSpellChargesFrac() > 1.8) and HasStagger() then
        return A.PurifyingBrew:Show(icon)
    end

    if A.CelestialBrew:IsReady(player) and HasStagger() and
        A.PurifyingBrew:GetSpellCharges() ~= 2 then
        return A.CelestialBrew:Show(icon)
    end

    -- if A.ExpelHarm:IsReady(player) and GetSpellCount(A.ExpelHarm.ID) > 2 then
    --     return A.ExpelHarm:Show(icon)
    -- end

    function DamageRotation(unit)

        -- RushingJade Prepull
        if A.RushingJadeWind:IsReady("player") and Unit("target"):IsEnemy() and
            Unit("target"):GetRange() <= 15 and Unit("player"):CombatTime() == 0 then
            return A.RushingJadeWind:Show(icon)
        end

        if not inMelee then return end

        -- Blackout Kick
        if A.BlackoutKick:IsReady(unit) then
            return A.BlackoutKick:Show(icon)
        end

        -- invoke_niuzao_the_black_ox,if=debuff.weapons_of_order_debuff.stack>3
        if A.InvokeNiuzao:IsReady(player) then
            local weaponsOfOrderStacks =
                Unit(unit):HasDeBuffsStacks(
                    A.WeaponsOfOrderDebuff.ID, player) -- Check for Weapons of Order debuff stacks

            if weaponsOfOrderStacks > 3 then -- If Weapons of Order debuff has more than 3 stacks
                return A.InvokeNiuzao:Show(icon)
            end
        end

        -- weapons_of_order,if=(talent.weapons_of_order.enabled)
        if A.WeaponsOfOrder:IsReady(unit) and BurstIsON(player) then
            local weaponsOfOrderEnabled = A.WeaponsOfOrder:IsTalentLearned() -- Check if Weapons of Order talent is enabled

            if weaponsOfOrderEnabled then -- If Weapons of Order talent is enabled
                return A.WeaponsOfOrder:Show(icon)
            end
        end

        -- keg_smash,if=time-action.weapons_of_order.last_used<2&talent.weapons_of_order.enabled
        if A.KegSmash:IsReady(unit) then
            local weaponsOfOrderEnabled = A.WeaponsOfOrder:IsTalentLearned() -- Check if Weapons of Order talent is enabled

            if lastCast == A.WeaponsOfOrder.ID and weaponsOfOrderEnabled then -- If it has been less than 2 seconds since Weapons of Order was last used
                return A.KegSmash:Show(icon)
            end
        end

        -- rising_sun_kick
        if A.RisingSunKick:IsReady(unit) then
            return A.RisingSunKick:Show(icon)
        end

        -- keg_smash,if=buff.weapons_of_order.up&debuff.weapons_of_order_debuff.remains<=gcd*2
        -- Using Keg Smash
        if A.KegSmash:IsReady(unit) then
            local weaponsOfOrderBuff = Unit(player):HasBuffs(
                                           A.WeaponsOfOrderBuff.ID, true) -- Check if Weapons of Order buff is up
            local weaponsOfOrderDebuffRemains =
                Unit(unit):HasDeBuffs(A.WeaponsOfOrderDebuff.ID, player) -- Check the remaining time of Weapons of Order debuff
            local gcd = A.GetGCD() -- Get the global cooldown

            if weaponsOfOrderBuff > 0 and weaponsOfOrderDebuffRemains <= gcd * 2 then -- If Weapons of Order buff is up and debuff remains <= 2*GCD
                return A.KegSmash:Show(icon)
            end
        end

        -- breath_of_fire,if=buff.charred_passions.remains<cooldown.blackout_kick.remains
        if A.BreathOfFire:IsReady(player) then
            local charredPassionsRemains =
                Unit(player):HasBuffs(A.CharredPassionsBuff.ID, true) -- Check remaining duration of Charred Passions buff
            local blackoutKickCooldown = A.BlackoutKick:GetCooldown() -- Get the cooldown of Blackout Kick

            if charredPassionsRemains < blackoutKickCooldown then -- If Charred Passions buff remains for less time than Blackout Kick cooldown
                return A.BreathOfFire:Show(icon)
            end
        end

        -- keg_smash,if=buff.weapons_of_order.up&debuff.weapons_of_order_debuff.stack<=3
        if A.KegSmash:IsReady(unit) then
            local weaponsOfOrderBuff = Unit(player):HasBuffs(
                                           A.WeaponsOfOrderBuff.ID, true) -- Check if Weapons of Order buff is up
            local weaponsOfOrderDebuffStack =
                Unit(unit):HasDeBuffsStacks(
                    A.WeaponsOfOrderDebuff.ID, player) -- Check the stack of Weapons of Order debuff

            if weaponsOfOrderBuff > 0 and weaponsOfOrderDebuffStack <= 3 then -- If Weapons of Order buff is up and debuff stack <= 3
                return A.KegSmash:Show(icon)
            end
        end

        -- summon_white_tiger_statue,if=debuff.weapons_of_order_debuff.stack>3
        if A.SummonWhiteTigerStatue:IsReady(player) then
            local weaponsOfOrderDebuffStack =
                Unit(unit):HasDeBuffsStacks(
                    A.WeaponsOfOrderDebuff.ID, player) -- Get the stack count of Weapons of Order debuff

            if weaponsOfOrderDebuffStack > 3 then -- If Weapons of Order debuff has more than 3 stacks
                return A.SummonWhiteTigerStatue:Show(icon)
            end
        end

        -- bonedust_brew,if=(time<10&debuff.weapons_of_order_debuff.stack>3)|(time>10&talent.weapons_of_order.enabled)
        if A.BonedustBrew:IsReady(player) and BurstIsON(player) then
            local weaponsOfOrderDebuffStack =
                Unit(unit):HasDeBuffsStacks(
                    A.WeaponsOfOrderDebuff.ID, player) -- Get the stack count of Weapons of Order debuff

            -- Cast Bonedust Brew if time < 10 and Weapons of Order debuff has more than 3 stacks
            if combatTime < 10 and weaponsOfOrderDebuffStack > 3 then
                return A.BonedustBrew:Show(icon)
            end

            -- Cast Bonedust Brew if time > 10 and Weapons of Order talent is enabled
            if combatTime > 10 and A.WeaponsOfOrder:IsTalentLearned() then
                return A.BonedustBrew:Show(icon)
            end
        end

        -- exploding_keg,if=(buff.bonedust_brew.up)
        if A.ExplodingKeg:IsReady(player) then
            local bonedustBrewBuff = Unit(player):HasBuffs(A.BonedustBrew.ID,
                                                           true) -- Get the duration of Bonedust Brew buff

            -- Cast Exploding Keg if Bonedust Brew buff is up
            if bonedustBrewBuff > 0 then
                return A.ExplodingKeg:Show(icon)
            end
        end

        -- keg_smash
        if A.KegSmash:IsReady(unit) then return A.KegSmash:Show(icon) end

        -- rushing_jade_wind,if=talent.rushing_jade_wind.enabled

        -- Using Rushing Jade Wind
        if A.RushingJadeWind:IsReady(player) and
            A.RushingJadeWind:IsTalentLearned() then
            return A.RushingJadeWind:Show(icon)
        end

        -- breath_of_fire

        if A.BreathOfFire:IsReady(player) then
            return A.BreathOfFire:Show(icon)
        end

        -- tiger_palm,if=active_enemies=1&!talent.blackout_combo.enabled

        if A.TigerPalm:IsReady(unit) and unitCount == 1 and
            not A.BlackoutCombo:IsTalentLearned() then
            return A.TigerPalm:Show(icon)
        end

        -- spinning_crane_kick,if=active_enemies>1

        if A.SpinningCraneKick:IsReady(unit) and unitCount > 1 then
            return A.SpinningCraneKick:Show(icon)
        end

    end

    if IsUnitEnemy(unit) then if DamageRotation(unit) then return true end end

end
