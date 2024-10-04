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
local IsUnitFriendly = Action.IsUnitFriendly
local BurstIsON = Action.BurstIsON

local player = "player"
local unit = "target"
local targettarget = "targettarget"
local target = "target"
local mouseover = "mouseover"
local focustarget = "focustarget"
local focus = "focus"

Action[ACTION_CONST_EVOKER_AUGMENTATION] = {
    -- Class Tree
    FireBreath = Create({Type = "Spell", ID = 382266}),
    LivingFlame = Create({ Type = "Spell", ID = 361469, Color = "BLUE" }),
    AzureStrike = Create({Type = "Spell", ID = 362969}),
    SleepWalk = Create({Type = "Spell", ID = 360806}),

    -- Spec Tree
    Prescience = Create({Type = "Spell", ID = 409311}),
    EbonMight = Create({Type = "Spell", ID = 395152}),
    Upheaval = Create({Type = "Spell", ID = 408092}),
    BlisteringScales = Create({Type = "Spell", ID = 360827}),
    Eruption = Create({Type = "Spell", ID = 395160}),

    -- Buffs

    EbonMightBuff = Create({Type = "Spell", ID = 395296}),

    -- Debuffs

    -- Trinket

    -- Dev Icons
    EternitySurge = Create({Type = "Spell", ID = 359073}),
    ShatteringStar = Create({Type = "Spell", ID = 370452}),
    Disintegrate = Create({Type = "Spell", ID = 356995}),

    -- Racials
    ArcaneTorrent = Action.Create({Type = "Spell", ID = 50613}),
    BloodFury = Action.Create({Type = "Spell", ID = 20572}),
    Fireblood = Action.Create({Type = "Spell", ID = 265221}),
    AncestralCall = Action.Create({Type = "Spell", ID = 274738}),
    Berserking = Action.Create({Type = "Spell", ID = 26297}),
    ArcanePulse = Action.Create({Type = "Spell", ID = 260364}),
    QuakingPalm = Action.Create({Type = "Spell", ID = 107079}),
    Haymaker = Action.Create({Type = "Spell", ID = 287712}),
    WarStomp = Action.Create({Type = "Spell", ID = 20549}),
    BullRush = Action.Create({Type = "Spell", ID = 255654}),
    GiftofNaaru = Action.Create({Type = "Spell", ID = 59544}),
    Shadowmeld = Action.Create({Type = "Spell", ID = 58984}), -- usable in Action Core 
    Stoneform = Action.Create({Type = "Spell", ID = 20594}),
    BagofTricks = Action.Create({Type = "Spell", ID = 312411}),
    WilloftheForsaken = Action.Create({Type = "Spell", ID = 7744}), -- not usable in APL but user can Queue it   
    EscapeArtist = Action.Create({Type = "Spell", ID = 20589}), -- not usable in APL but user can Queue it
    EveryManforHimself = Action.Create({Type = "Spell", ID = 59752}), -- not usable in APL but user can Queu
    RocketJump = Action.Create({Type = "Spell", ID = 69070})
}

local A = setmetatable(Action[ACTION_CONST_EVOKER_AUGMENTATION],
                       {__index = Action})

A[3] = function(icon)

    local Essence = Player:Essence()
    local isMoving = A.Player:IsMoving()

    local function BasicDamageRotation(unit)

        if A.SleepWalk:IsReady() and
            (Unit(mouseover):Name() == "Incorporeal Being" or Unit(unit):Name() ==
                "Incorporeal Being") then return A.SleepWalk:Show(icon) end

        if A.Prescience:IsReady(player) then
            return A.Prescience:Show(icon)
        end

        if A.IsUnitFriendly(targettarget) and A.BlisteringScales:IsReady(player) then
            return A.BlisteringScales:Show(icon)
        end

        if A.EbonMight:IsReady(player) then return A.EbonMight:Show(icon) end

        if A.FireBreath:IsReady(player) then
            return A.FireBreath:Show(icon)
        end

        if A.Upheaval:IsReady(unit) then return A.Upheaval:Show(icon) end

        if A.Eruption:IsReady(unit) and
            Unit(player):HasBuffs(A.EbonMightBuff.ID) ~= 0 then
            return A.Eruption:Show(icon)
        end

        if A.LivingFlame:IsReady(unit) then return A.LivingFlame:Show(icon) end

    end

    if not A.IsUnitEnemy(targettarget) then
        unit = "mouseover"
        if BasicDamageRotation(unit) then return true end
    end

    if A.IsUnitEnemy("target") then
        unit = "target"
        if BasicDamageRotation(unit) then return true end
    end

end
