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
local IsUnitEnemy = Action.IsUnitEnemy

local player = "player"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"
local unit = "target"

Action[ACTION_CONST_SHAMAN_ENHANCEMENT] = {

    -- Spec Abilities

    CounterStrikeTotem = Create({Type = "Spell", ID = 204331}),
    FeralLunge = Create({Type = "Spell", ID = 196884}),
    FlameShock = Create({Type = "Spell", ID = 188389}),
    FlametongueWeapon = Create({Type = "Spell", ID = 318038}),
    FlametongueWeaponBuff = Create({Type = "Spell", ID = 5400}),
    FrostShock = Create({Type = "Spell", ID = 196840}),
    HealingStreamTotem = Create({Type = "Spell", ID = 5394}),
    HealingSurge = Create({Type = "Spell", ID = 8004}),
    LavaBlast = Create({Type = "Spell", ID = 51505}),
    LightningBolt = Create({Type = "Spell", ID = 188196}),
    LightningShield = Create({Type = "Spell", ID = 192106}),
    MaelstromWeapon = Create({Type = "Spell", ID = 187880, Hidden = true}),
    PrimalStrike = Create({Type = "Spell", ID = 73899}),
    ChainLightning = Create({Type = "Spell", ID = 188443}),

    -- Class Abilities

    CrashLightning = Create({Type = "Spell", ID = 187874}),
    FeralSpirit = Create({Type = "Spell", ID = 51533}),
    IceStrike = Create({Type = "Spell", ID = 342240}),
    LavaLash = Create({Type = "Spell", ID = 60103}),
    PrimordialWave = Create({Type = "Spell", ID = 375982}),
    Stormstrike = Create({Type = "Spell", ID = 17364}),
    Sundering = Create({Type = "Spell", ID = 197214}),
    WindfuryTotem = Create({Type = "Spell", ID = 8512}),
    WindfuryWeapon = Create({Type = "Spell", ID = 33757}),
    ElementalBlast = Create({Type = "Spell", ID = 117014}),
    FireNova = Action.Create({Type = "Spell", ID = 333974}),

    -- Buffs

    AshenCatalyst = Create({Type = "Spell", ID = 390371}),
    HailStormBuff = Create({Type = "Spell", ID = 334196}),
    HotHandsBuff = Create({Type = "Spell", ID = 215785}),
    MaelstromWeaponBuff = Create({Type = "Spell", ID = 344179}),
    PrimordialWaveBuff = Create({Type = "Spell", ID = 375986}),
    WindfuryTotemBuff = Create({Type = "Spell", ID = 327942}),
    WindfuryWeaponBuff = Create({Type = "Spell", ID = 5401}),
    DoomWindsBuff = Action.Create({Type = "Spell", ID = 204945}), -- wrong id
    IceStrikeBuff = Action.Create({Type = "Spell", ID = 384357}),
    -- ClCrashLightning = Action.Create({Type = "Spell", ID = 187874}),

    -- Talents
    MoltenAssault = Action.Create({Type = "Spell", ID = 334033, isTalent = true}),
    LashingFlames = Action.Create({Type = "Spell", ID = 334046, isTalent = true}),
    Hailstorm = Action.Create({Type = "Spell", ID = 334195, isTalent = true}),
    CrashingStorms = Action.Create({
        Type = "Spell",
        ID = 334308,
        isTalent = true
    }),
    AlphaWolf = Action.Create({Type = "Spell", ID = 198434, isTalent = true})

}

local A = setmetatable(Action[ACTION_CONST_SHAMAN_ENHANCEMENT],
                       {__index = Action})

A[3] = function(icon)

    if A.LightningShield:IsReady(unit) and
        Unit(player):HasBuffs(A.LightningShield.ID, true) == 0 then
        return A.LightningShield:Show(icon)
    end

    local function DamageRotation(unit)

        local inMelee = A.Stormstrike:IsInRange(target)
        local unitDead = Unit(unit):IsDead()

        local activeEnemies = MultiUnits:GetByRange(8, 5)
        local buffMaelstromWeaponStack =
            Unit(player):HasBuffsStacks(A.MaelstromWeapon.ID, true)
        local buffMaelstromWeaponMaxStack = 10
        local buffPrimordialWaveUp =
            Unit(player):HasBuffs(A.PrimordialWave.ID) > 0
        local buffDoomWindsUp = Unit(player):HasBuffs(A.DoomWindsBuff.ID) > 0
        local buffIceStrikeUp = Unit(player):HasBuffs(A.IceStrikeBuff.ID) > 0
        local buffHailstormUp = Unit(player):HasBuffs(A.HailStormBuff.ID) > 0
        local talentMoltenAssaultEnabled = A.MoltenAssault:IsTalentLearned()
        local talentPrimordialWaveEnabled = A.PrimordialWave:IsTalentLearned()
        local talentFireNovaEnabled = A.FireNova:IsTalentLearned()
        local talentLashingFlamesEnabled = A.LashingFlames:IsTalentLearned()
        local talentHailstormEnabled = A.Hailstorm:IsTalentLearned()
        local talentCrashingStormsEnabled = A.CrashingStorms:IsTalentLearned()
        local talentAlphaWolfEnabled = A.AlphaWolf:IsTalentLearned()
        -- local buffClCrashLightningUp = Unit(player):HasBuffs(A.ClCrashLightning
        --  .ID) > 0
        local buffWindfuryTotemRemains =
            Unit(player):HasBuffs(A.WindfuryTotem.ID)


        if A.WindfuryTotem:IsReady(player) and
            Unit(player):HasBuffs(A.WindfuryTotemBuff.ID, true) == 0 then
            return A.WindfuryTotem:Show(icon)
        end

        -- feral_spirit

        if A.FeralSpirit:IsReady(unit) and inMelee and not unitDead then
            return A.FeralSpirit:Show(icon)
        end

        -- ========================================================
        -- = Area of Effect Actions (AoE)
        -- ========================================================

        if activeEnemies > 1 then

            -- lightning_bolt,if=(active_dot.flame_shock=active_enemies|active_dot.flame_shock=6)&buff.primordial_wave.up&buff.maelstrom_weapon.stack=buff.maelstrom_weapon.max_stack&(!buff.splintered_elements.up|fight_remains<=12|raid_event.adds.remains<=gcd)

            if A.LightningBolt:IsReady(unit) and buffPrimordialWaveUp and
                buffMaelstromWeaponStack == buffMaelstromWeaponMaxStack then
                return A.LightningBolt:Show(icon)
            end

            -- lava_lash,if=talent.molten_assault.enabled&(talent.primordial_wave.enabled|talent.fire_nova.enabled)&dot.flame_shock.ticking&(active_dot.flame_shock<active_enemies)&active_dot.flame_shock<6

            if A.LavaLash:IsReady(unit) and talentMoltenAssaultEnabled and
                (talentPrimordialWaveEnabled or talentFireNovaEnabled) and
                Unit(unit):HasDeBuffs(A.FlameShock.ID, player) > 0 then
                return A.LavaLash:Show(icon)
            end

            -- primordial_wave,target_if=min:dot.flame_shock.remains,cycle_targets=1,if=!buff.primordial_wave.up

            if A.PrimordialWave:IsReady(unit) and not buffPrimordialWaveUp then
                -- Target the enemy with the lowest Flame Shock duration
                return A.PrimordialWave:Show(icon)
            end

            -- chain_lightning,if=buff.maelstrom_weapon.stack=buff.maelstrom_weapon.max_stack

            if A.ChainLightning:IsReady(unit) and buffMaelstromWeaponStack ==
                buffMaelstromWeaponMaxStack then
                return A.ChainLightning:Show(icon)
            end

            -- crash_lightning,if=buff.doom_winds.up|!buff.crash_lightning.up|(talent.alpha_wolf.enabled&feral_spirit.active&alpha_wolf_min_remains=0)

            if A.CrashLightning:IsReady(player) and inMelee and not unitDead and
                (buffDoomWindsUp or
                    not (Unit(player):HasBuffs(A.CrashLightning.ID) > 0) or
                    (talentAlphaWolfEnabled and A.FeralSpirit:IsSpellInFlight() and
                        alphaWolfMinRemains == 0)) then
                return A.CrashLightning:Show(icon)
            end

            -- sundering,if=buff.doom_winds.up|set_bonus.tier30_2pc

            if A.Sundering:IsReady(player) and inMelee and not unitDead then
                return A.Sundering:Show(icon)
            end

            -- lava_lash,target_if=min:debuff.lashing_flames.remains,cycle_targets=1,if=talent.lashing_flames.enabled

            if A.LavaLash:IsReady(unit) and talentLashingFlamesEnabled then
                -- Target the enemy with the lowest Lashing Flames duration
                return A.LavaLash:Show(icon)
            end

            -- ice_strike,if=talent.hailstorm.enabled&!buff.ice_strike.up

            if A.IceStrike:IsReady(unit) and talentHailstormEnabled and
                not buffIceStrikeUp then
                return A.IceStrike:Show(icon)
            end

            -- frost_shock,if=talent.hailstorm.enabled&buff.hailstorm.up

            if A.FrostShock:IsReady(unit) and talentHailstormEnabled and
                buffHailstormUp then return A.FrostShock:Show(icon) end

            -- flame_shock,if=talent.molten_assault.enabled&!ticking

            if A.FlameShock:IsReady(unit) and talentMoltenAssaultEnabled and
                not (Unit(unit):HasDeBuffs(A.FlameShock.ID, player) > 0) then
                return A.FlameShock:Show(icon)
            end

            -- flame_shock,target_if=min:dot.flame_shock.remains,cycle_targets=1,if=(talent.fire_nova.enabled|talent.primordial_wave.enabled)&(active_dot.flame_shock<active_enemies)&active_dot.flame_shock<6

            if A.FlameShock:IsReady(unit) and
                (talentFireNovaEnabled or talentPrimordialWaveEnabled) then
                -- Target the enemy with the lowest Flame Shock duration
                return A.FlameShock:Show(icon)
            end

            -- crash_lightning,if=talent.crashing_storms.enabled&buff.cl_crash_lightning.up&active_enemies>=4

            if A.CrashLightning:IsReady(player) and inMelee and not unitDead and
                talentCrashingStormsEnabled and activeEnemies >= 4 then
                return A.CrashLightning:Show(icon)
            end

            -- stormstrike

            if A.Stormstrike:IsReady(unit) then
                return A.Stormstrike:Show(icon)
            end

            -- crash_lightning

            if A.CrashLightning:IsReady(player) and inMelee and not unitDead then
                return A.CrashLightning:Show(icon)
            end

            -- chain_lightning,if=buff.maelstrom_weapon.stack>=5

            if A.ChainLightning:IsReady(unit) and buffMaelstromWeaponStack >= 5 then
                return A.ChainLightning:Show(icon)
            end

            -- windfury_totem,if=buff.windfury_totem.remains<30

            if A.WindfuryTotem:IsReady(unit) and buffWindfuryTotemRemains < 30 then
                return A.WindfuryTotem:Show(icon)
            end

        end

        -- ========================================================
        -- = Single Target Actions
        -- ========================================================

    end

    if IsUnitEnemy(unit) then if DamageRotation(unit) then return true end end
end
