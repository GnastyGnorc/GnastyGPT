-- Frost GPT
-- TWW 9/2/24

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

Action[ACTION_CONST_MAGE_FROST] = {
    -- Class Tree
    IceBarrier = Create({Type = "Spell", ID = 11426}),
    MirrorImage = Create({Type = "Spell", ID = 55342}),
    IceNova = Create({Type = "Spell", ID = 157997}),
    Polymorph = Create({Type = "Spell", ID = 118}),
    ShiftingPower = Create({Type = "Spell", ID = 382440}),
    ConeOfCold = Create({Type = "Spell", ID = 120}),

    -- Spec Tree        
    FrozenOrb = Create({Type = "Spell", ID = 84714}),
    Flurry = Create({Type = "Spell", ID = 44614}),
    IceLance = Create({Type = "Spell", ID = 30455}),
    Frostbolt = Create({Type = "Spell", ID = 116, Texture = 50613}),
    Blizzard = Create({Type = "Spell", ID = 190356}),
    IcyVeins = Create({Type = "Spell", ID = 12472}),
    GlacialSpike = Create({Type = "Spell", ID = 199786}),
    CometStorm = Create({Type = "Spell", ID = 153595}),
    RayOfFrost = Create({Type = "Spell", ID = 205021}),

    -- Buffs
    FingersOfFrost = Create({Type = "Spell", ID = 44544, Hidden = true}),
    ArcaneIntellect = Create({Type = "Spell", ID = 1459, Hidden = true}),
    BrainFreezeBuff = Create({Type = "Spell", ID = 190446, Hidden = true}),
    IciclesBuff = Create({Type = "Spell", ID = 205473, Hidden = true}),

    -- Debuffs
    WintersChill = Create({Type = "Spell", ID = 228358}),
    CursedSpirit = Create({Type = "Spell", ID = 409465}),

    -- Racial
    ArcaneTorrent = Create({Type = "Spell", ID = 50613}),
    Shadowmeld = Create({Type = "Spell", ID = 58984}),

    -- Talents
    FreezingWinds = Create({Type = "Spell", ID = 382103}),
    ColdestSnap = Create({Type = "Spell", ID = 417493})

}

local A = setmetatable(Action[ACTION_CONST_MAGE_FROST], {__index = Action})

A[3] = function(icon)

    local isAoE = GetToggle(2, "AoE")

    local function BasicDamageRotation(unit)

     

        if Unit(player):HasBuffs(A.ArcaneIntellect.ID) == 0 and A.ArcaneIntellect:IsReady(player) then
            return A.ArcaneIntellect:Show(icon)
        end

        -- icy_veins

        if A.IcyVeins:IsReady(player) and BurstIsON then
            return A.IcyVeins:Show(icon)
        end

        if isAoE then

            -- cone_of_cold,if=talent.coldest_snap&(prev_gcd.1.comet_storm|prev_gcd.1.frozen_orb&!talent.comet_storm)
            if A.ConeOfCold:IsReady(player) and A.ColdestSnap:IsTalentLearned() then
                if A.Player:PrevGCD(1, A.CometStorm) or
                    (A.Player:PrevGCD(1, A.FrozenOrb) and
                        not A.CometStorm:IsSpellLearned()) then
                    return A.ConeOfCold:Show(icon)
                end
            end

            -- frozen_orb,if=!prev_gcd.1.glacial_spike|!freezable

            if A.FrozenOrb:IsReady(player) then
                if not A.Player:PrevGCD(1, A.GlacialSpike) then
                    return A.FrozenOrb:Show(icon)
                end
            end

            --  blizzard,if=!prev_gcd.1.glacial_spike|!freezable

            if A.Blizzard:IsReady(player) then
                if not A.Player:PrevGCD(1, A.GlacialSpike) then
                    return A.Blizzard:Show(icon)
                end
            end

            -- comet_storm,if=!prev_gcd.1.glacial_spike&(!talent.coldest_snap|cooldown.cone_of_cold.ready&cooldown.frozen_orb.remains>25|cooldown.cone_of_cold.remains>20)

            if A.CometStorm:IsReady(unit) then
                if not A.Player:PrevGCD(1, A.GlacialSpike) and
                    (not A.ColdestSnap:IsTalentLearned() or
                        (A.ConeOfCold:IsReady() and A.FrozenOrb:GetCooldown() >
                            25) or A.ConeOfCold:GetCooldown() > 20) then
                    return A.CometStorm:Show(icon)
                end
            end

            -- shifting_power

            if A.ShiftingPower:IsReady(player) then
                return A.ShiftingPower:Show(icon)
            end

            -- glacial_spike,if=buff.icicles.react=5&cooldown.blizzard.remains>gcd.max

            if A.GlacialSpike:IsReady(player) then
                if A.Blizzard:GetCooldown() > A.GetGCD() then
                    return A.GlacialSpike:Show(icon)
                end
            end

            -- flurry,if=!freezable&cooldown_react&!debuff.winters_chill.remains&(prev_gcd.1.glacial_spike|charges_fractional>1.8)

            if A.Flurry:IsReadyByPassCastGCD(player) then
                if not A.Player:PrevGCD(1, A.GlacialSpike) and
                    Unit(unit):HasDeBuffs(A.WintersChill.ID, player) == 0 and
                    (A.Flurry:GetSpellChargesFrac() > 1.8) and not A.ShiftingPower:IsSpellInCasting() then
                    return A.Flurry:Show(icon)
                end
            end

            -- flurry,if=cooldown_react&!debuff.winters_chill.remains&(buff.brain_freeze.react|!buff.fingers_of_frost.react)

            if A.Flurry:IsReady(player) then
                if Unit(unit):HasDeBuffs(A.WintersChill.ID, player) == 0 and
                    (Unit(player):HasBuffs(A.BrainFreezeBuff.ID) > 0 or
                        Unit(player):HasBuffs(A.FingersOfFrost.ID) == 0) then
                    return A.Flurry:Show(icon)
                end
            end

            -- ice_lance,if=buff.fingers_of_frost.react|debuff.frozen.remains>travel_time|remaining_winters_chill

            if A.IceLance:IsReady(player) then
                if Unit(player):HasBuffs(A.FingersOfFrost.ID) > 0 then
                    return A.IceLance:Show(icon)
                end
            end

            -- ice_nova,if=active_enemies>=4&(!talent.snowstorm&!talent.glacial_spike|!freezable)

            if A.IceNova:IsReady(player) then
                return A.IceNova:Show(icon)
            end

            -- frostbolt

            if A.Frostbolt:IsReady(unit) then
                return A.Frostbolt:Show(icon)
            end

        end

        ----------------------------------------------------------------------------------------------------

        -- comet_storm,if=prev_gcd.1.flurry|prev_gcd.1.cone_of_cold

        if A.CometStorm:IsReady(unit) then
            if A.Player:PrevGCD(1, A.Flurry) or
                A.Player:PrevGCD(1, A.ConeOfCold) then
                return A.CometStorm:Show(icon)
            end
        end

        -- flurry,if=cooldown_react&remaining_winters_chill=0&debuff.winters_chill.down&(prev_gcd.1.frostbolt|prev_gcd.1.glacial_spike|talent.glacial_spike&buff.icicles.react=4&!buff.fingers_of_frost.react)

        if A.Flurry:IsReadyByPassCastGCD(player) then
            if Unit(unit):HasDeBuffs(A.WintersChill.ID, player) == 0 and
                ((A.Player:PrevGCD(1, A.Frostbolt) or (A.Frostbolt:IsSpellInCasting())) or
                    (A.Player:PrevGCD(1, A.GlacialSpike) or (A.GlacialSpike:IsSpellInCasting())) or
                    (A.GlacialSpike:IsTalentLearned() and
                        Unit(player):HasBuffsStacks(A.IciclesBuff.ID) == 4 and
                        not Unit(player):HasBuffs(A.FingersOfFrost.ID))) then
                return A.Flurry:Show(icon)
            end
        end

        -- ice_lance,if=talent.glacial_spike&debuff.winters_chill.down&buff.icicles.react=4&buff.fingers_of_frost.react

        if A.IceLance:IsReady(player) then
            if A.GlacialSpike:IsTalentLearned() and
                Unit(unit):HasDeBuffs(A.WintersChill.ID, player) == 0 and
                Unit(player):HasBuffsStacks(A.IciclesBuff.ID) == 4 and
                Unit(player):HasBuffs(A.FingersOfFrost.ID) > 0 then
                return A.IceLance:Show(icon)
            end
        end

        -- ray_of_frost,if=remaining_winters_chill=1

        if A.RayOfFrost:IsReady(player) then
            if Unit(unit):HasDeBuffs(A.WintersChill.ID, player) > 0 then
                return A.RayOfFrost:Show(icon)
            end
        end

        -- glacial_spike,if=buff.icicles.react=5&(action.flurry.cooldown_react|remaining_winters_chill)

        if A.GlacialSpike:IsReady(player) and
            Unit(player):HasBuffsStacks(A.IciclesBuff.ID) == 5 and
            (A.Flurry:GetCooldown() == 0 or
                Unit(unit):HasDeBuffs(A.WintersChill.ID, player) > 0) then
            return A.GlacialSpike:Show(icon)
        end

        -- frozen_orb,if=buff.fingers_of_frost.react<2&(!talent.ray_of_frost|cooldown.ray_of_frost.remains)

        if A.FrozenOrb:IsReady(player) and
            Unit(player):HasBuffsStacks(A.FingersOfFrost.ID) < 2 and
            (not A.RayOfFrost:IsTalentLearned() or A.RayOfFrost:GetCooldown() >
                0) then return A.FrozenOrb:Show(icon) end

        -- shifting_power,if=cooldown.frozen_orb.remains>10&(!talent.comet_storm|cooldown.comet_storm.remains>10)&(!talent.ray_of_frost|cooldown.ray_of_frost.remains>10)|cooldown.icy_veins.remains<20

        if A.ShiftingPower:IsReady(player) and
            (A.FrozenOrb:GetCooldown() > 10 and
                (A.CometStorm:GetCooldown() > 10) and
                (A.RayOfFrost:GetCooldown() > 10) or
                (A.IcyVeins:GetCooldown() < 20) and
                (A.IcyVeins:GetCooldown() ~= 0)) then
            return A.ShiftingPower:Show(icon)
        end

        -- ice_lance,if=buff.fingers_of_frost.react&!prev_gcd.1.glacial_spike|remaining_winters_chill

        if A.IceLance:IsReady(player) and
            (Unit(player):HasBuffs(A.FingersOfFrost.ID) > 0 and
                not A.Player:PrevGCD(1, A.GlacialSpike) or
                Unit(unit):HasDeBuffs(A.WintersChill.ID, player) > 0) then
            return A.IceLance:Show(icon)
        end

        -- glacial_spike,if=buff.icicles.react=5&buff.icy_veins.up

        if A.GlacialSpike:IsReady(player) and
            Unit(player):HasBuffsStacks(A.IciclesBuff.ID) == 5 and
            Unit(player):HasBuffs(A.IcyVeins.ID) > 0 then
            return A.GlacialSpike:Show(icon)
        end

        -- frostbolt

        if A.Frostbolt:IsReady(unit) then return A.Frostbolt:Show(icon) end

    end

    if A.IsUnitEnemy("target") then
        unit = "target"
        if BasicDamageRotation(unit) then return true end
    end

    if A.IsUnitEnemy("mouseover") then
        unit = "mouseover"
        if BasicDamageRotation(unit) then return true end
    end

end
