local _G, setmetatable, unpack, select, table, pairs, ipairs, type, math = 
_G, setmetatable, unpack, select, table, pairs, ipairs, type, math  

local huge                                     = math.huge   
local tsort                                    = table.sort     
local wipe                                     = _G.wipe   

local TMW                                     = _G.TMW 
local Action                                = _G.Action
local CONST                                 = Action.Const
local Create                                 = Action.Create
local Listener                                = Action.Listener
local TeamCache                                = Action.TeamCache
local EnemyTeam                                = Action.EnemyTeam
local FriendlyTeam                            = Action.FriendlyTeam
local HealingEngine                            = Action.HealingEngine
local LoC                                     = Action.LossOfControl
local Player                                = Action.Player 
local MultiUnits                            = Action.MultiUnits
local UnitCooldown                            = Action.UnitCooldown
local Unit                                    = Action.Unit 
local LibCC                                 = _G.LibStub("LibClassicCasterino", true)

local GetToggle                                = Action.GetToggle
local GetAuraList                            = Action.GetAuraList
local GetSpellInfo                            = Action.GetSpellInfo
local GetPing                                = Action.GetPing
local GetGCD                                = Action.GetGCD
local GetCurrentGCD                            = Action.GetCurrentGCD
local GetLatency                            = Action.GetLatency
local DetermineUsableObject                    = Action.DetermineUsableObject
local DetermineHealObject                    = Action.DetermineHealObject
local AuraIsValid                            = Action.AuraIsValid
local InterruptIsValid                        = Action.InterruptIsValid
local BurstIsON                                = Action.BurstIsON
local IsUnitFriendly                        = Action.IsUnitFriendly
local IsUnitEnemy                            = Action.IsUnitEnemy

local CanUseStoneformDefense                = Action.CanUseStoneformDefense
local CanUseStoneformDispel                    = Action.CanUseStoneformDispel
local CanUseHealingPotion                    = Action.CanUseHealingPotion
local CanUseLivingActionPotion                = Action.CanUseLivingActionPotion
local CanUseLimitedInvulnerabilityPotion    = Action.CanUseLimitedInvulnerabilityPotion
local CanUseRestorativePotion                = Action.CanUseRestorativePotion
local CanUseSwiftnessPotion                    = Action.CanUseSwiftnessPotion
local CanUseManaRune                        = Action.CanUseManaRune

local TeamCacheFriendly                        = TeamCache.Friendly
local TeamCacheFriendlyGUIDs                = TeamCacheFriendly.GUIDs -- unitGUID to unitID
local TeamCacheFriendlyIndexToPLAYERs        = TeamCacheFriendly.IndexToPLAYERs
local TeamCacheFriendlyIndexToPETs            = TeamCacheFriendly.IndexToPETs
local TeamCacheEnemy                        = TeamCache.Enemy
local TeamCacheEnemyIndexToPLAYERs            = TeamCacheEnemy.IndexToPLAYERs
local HealingEngineGetOptionsByUnitID        = HealingEngine.GetOptionsByUnitID
--local HealingEngineIsManaSave                = HealingEngine.IsManaSave
local nameplates                             = MultiUnits:GetActiveUnitPlates()

local ACTION_CONST_AUTOTARGET                = CONST.AUTOTARGET      
local ACTION_CONST_STOPCAST                    = CONST.STOPCAST          

local GetTrackingTexture                    = _G.GetTrackingTexture     
local UIParent                                = _G.UIParent 
local CreateFrame                            = _G.CreateFrame      

local UnitAura                                = TMW.UnitAura

local      UnitGUID,       UnitIsUnit,      UnitBuff,       UnitAttackSpeed,       UnitCreatureType =
_G.UnitGUID, _G.UnitIsUnit, _G.UnitBuff, _G.UnitAttackSpeed, _G.UnitCreatureType                    

Action[Action.PlayerClass]                     = {
    -- Racials 
    Perception                                = Create({ Type = "Spell", ID = 20600, FixedTexture = CONST.HUMAN                                         }), 
    Stoneform                                  = Create({ Type = "Spell", ID = 20594                                                                    }), 
    -- Core API
    AntiFakeCC                                = Create({ Type = "SpellSingleColor",     ID = 853,      useMaxRank = true,  Color = "GREEN", Desc = "[1] CC",                     QueueForbidden = true, BlockForbidden = true                        }),         -- Hammer of Justice 
    AntiFakeInterrupt                        = Create({ Type = "Spell",                  ID = 20066,                                        Desc = "[2] Interrupt",             QueueForbidden = true, BlockForbidden = true,  isTalent = true         }),            -- Repentance
    -- Equipment    
    MajorManaPotion                            = Create({ Type = "Potion",             ID = 13444                                                        }),
    -- Class spells
    -- Damager 
    Exorcism5                                = Create({ Type = "Spell", ID = 10313,     isRank = 5                                                         }), 
    Exorcism4                                = Create({ Type = "Spell", ID = 10312,     isRank = 4                                                         }), 
    Exorcism3                                = Create({ Type = "Spell", ID = 5615,     isRank = 3                                                         }), 
    Exorcism2                                = Create({ Type = "Spell", ID = 5614,     isRank = 2                                                         }), 
    Exorcism1                                = Create({ Type = "Spell", ID = 879,     isRank = 1                                                         }), 
    Exorcism                                = Create({ Type = "Spell", ID = 10314,     useMaxRank = true, Desc = "Max Rank"                            }),
    HammerofWrath2                            = Create({ Type = "Spell", ID = 24274,     isRank = 2                                                         }),
    HammerofWrath1                            = Create({ Type = "Spell", ID = 24275,     isRank = 1                                                         }),
    HammerofWrath                            = Create({ Type = "Spell", ID = 24239,     useMaxRank = true, Desc = "Max Rank"                            }),
    HolyWrath1                                = Create({ Type = "Spell", ID = 2812,     isRank = 1                                                         }),
    HolyWrath                                = Create({ Type = "Spell", ID = 10318,     useMaxRank = true, Desc = "Max Rank"                            }),
    Judgement                                = Create({ Type = "Spell", ID = 20271                                                                    }), 
    Consecration4                            = Create({ Type = "Spell", ID = 20923,     isRank = 4, isTalent = true                                        }), 
    Consecration3                            = Create({ Type = "Spell", ID = 20922,     isRank = 3, isTalent = true                                        }), 
    Consecration2                            = Create({ Type = "Spell", ID = 20116,     isRank = 2, isTalent = true                                        }), 
    Consecration1                            = Create({ Type = "Spell", ID = 26573,     isRank = 1, isTalent = true                                        }), 
    Consecration                            = Create({ Type = "Spell", ID = 20924,     useMaxRank = true, isTalent = true, Desc = "Max Rank"            }),
    -- Tank
    RighteousFury                            = Create({ Type = "Spell", ID = 25780                                                                    }), 
    HolyShield                                = Create({ Type = "Spell", ID = 20925,     useMaxRank = true, isTalent = true                                 }),
    -- Healer 
    FlashofLight1                            = Create({ Type = "Spell", ID = 19750,     isRank = 1                                                         }), 
    FlashofLight2                            = Create({ Type = "Spell", ID = 19939,     isRank = 2                                                         }), 
    FlashofLight3                            = Create({ Type = "Spell", ID = 19940,     isRank = 3                                                         }), 
    FlashofLight4                            = Create({ Type = "Spell", ID = 19941,     isRank = 4                                                         }), 
    FlashofLight5                            = Create({ Type = "Spell", ID = 19942,     isRank = 5                                                         }), 
    FlashofLight                            = Create({ Type = "Spell", ID = 19943,     useMaxRank = true, Desc = "Max Rank"                            }), 
    HolyLight1                                = Create({ Type = "Spell", ID = 635,     isRank = 1                                                         }),
    HolyLight2                                = Create({ Type = "Spell", ID = 639,     isRank = 2                                                         }),
    HolyLight3                                = Create({ Type = "Spell", ID = 647,     isRank = 3                                                         }),
    HolyLight4                                = Create({ Type = "Spell", ID = 1026,     isRank = 4                                                         }),
    HolyLight5                                = Create({ Type = "Spell", ID = 1042,     isRank = 5                                                         }),
    HolyLight6                                = Create({ Type = "Spell", ID = 3472,     isRank = 6                                                         }),
    HolyLight7                                = Create({ Type = "Spell", ID = 10328,     isRank = 7                                                         }),
    HolyLight8                                = Create({ Type = "Spell", ID = 10329,     isRank = 8                                                         }),
    HolyLight                                = Create({ Type = "Spell", ID = 25292,     useMaxRank = true, Desc = "Max Rank"                            }),
    LayonHands                                = Create({ Type = "Spell", ID = 633,     useMaxRank = true, Desc = "Max Rank"                            }),
    DivineFavor                                = Create({ Type = "Spell", ID = 633,     isTalent = true                                                 }),
    HolyShock1                                = Create({ Type = "Spell", ID = 20473,     isRank = 1,           isTalent = true                                }),
    HolyShock2                                = Create({ Type = "Spell", ID = 20929,     isRank = 2,           isTalent = true                                }),
    HolyShock                                = Create({ Type = "Spell", ID = 20930,     useMaxRank = true, isTalent = true, Desc = "Max Rank"            }),
    -- Defense
    DivineProtection                        = Create({ Type = "Spell", ID = 498,     useMaxRank = true                                                 }),
    DivineShield                            = Create({ Type = "Spell", ID = 642,     useMaxRank = true                                                 }),        
    -- Supportive
    Redemption                                = Create({ Type = "Spell", ID = 7328,     useMaxRank = true                                                }),
    BlessingofFreedom                        = Create({ Type = "Spell", ID = 1044                                                                     }),    
    BlessingofLight                            = Create({ Type = "Spell", ID = 19977,     useMaxRank = true                                                 }),
    BlessingofMight                            = Create({ Type = "Spell", ID = 19740,     useMaxRank = true                                                 }),
    BlessingofProtection                    = Create({ Type = "Spell", ID = 1022,     useMaxRank = true                                                 }),
    BlessingofSacrifice                        = Create({ Type = "Spell", ID = 6940,     useMaxRank = true                                                 }),
    BlessingofSalvation                        = Create({ Type = "Spell", ID = 1038                                                                    }),
    BlessingofSanctuary                        = Create({ Type = "Spell", ID = 20911,     useMaxRank = true, isTalent = true                                 }),
    BlessingofWisdom                        = Create({ Type = "Spell", ID = 19742,     useMaxRank = true                                                }),
    BlessingofKings                            = Create({ Type = "Spell", ID = 20217,     isTalent = true                                                 }),
    Cleanse                                    = Create({ Type = "Spell", ID = 4987                                                                    }),
    Purify                                    = Create({ Type = "Spell", ID = 1152                                                                    }),    
    DivineIntervention                        = Create({ Type = "Spell", ID = 19752                                                                    }),
    GreaterBlessingofKings                    = Create({ Type = "Spell", ID = 25898                                                                    }),
    GreaterBlessingofLight                    = Create({ Type = "Spell", ID = 25890,     useMaxRank = true                                                }),
    GreaterBlessingofMight                    = Create({ Type = "Spell", ID = 25782,     useMaxRank = true                                                }),
    GreaterBlessingofSalvation                = Create({ Type = "Spell", ID = 25895                                                                    }),
    GreaterBlessingofSanctuary                = Create({ Type = "Spell", ID = 25899,     useMaxRank = true                                                }),
    GreaterBlessingofWisdom                    = Create({ Type = "Spell", ID = 25894,     useMaxRank = true                                                }),
    -- Stances 
    ConcentrationAura                        = Create({ Type = "Spell", ID = 19746                                                                    }),
    DevotionAura                            = Create({ Type = "Spell", ID = 10293,     useMaxRank = true                                                }),
    FireResistanceAura                        = Create({ Type = "Spell", ID = 19891,     useMaxRank = true                                                }),
    FrostResistanceAura                        = Create({ Type = "Spell", ID = 19888,     useMaxRank = true                                                }),
    RetributionAura                            = Create({ Type = "Spell", ID = 7294,     useMaxRank = true                                                }),
    ShadowResistanceAura                    = Create({ Type = "Spell", ID = 19876,     useMaxRank = true                                                }),
    SanctityAura                            = Create({ Type = "Spell", ID = 20218,     isTalent = true                                                    }),
    -- Seals 
    SealofCommand                            = Create({ Type = "Spell", ID = 20375,     useMaxRank = true, isTalent = true                                 }),
    SealofJustice                            = Create({ Type = "Spell", ID = 20164                                                                    }),
    SealofLight                                = Create({ Type = "Spell", ID = 20165,     useMaxRank = true                                                }),
    SealofRighteousness                        = Create({ Type = "Spell", ID = 21084,     useMaxRank = true                                                }),
    SealoftheCrusader                        = Create({ Type = "Spell", ID = 21082,     useMaxRank = true                                                }),
    SealofWisdom                            = Create({ Type = "Spell", ID = 20166,     useMaxRank = true                                                }),
    -- CrownControl
    HammerofJustice                            = Create({ Type = "Spell", ID = 853,     useMaxRank = true                                                 }), 
    TurnUndead                                = Create({ Type = "Spell", ID = 2878,     useMaxRank = true                                                 }), 
    Repentance                                = Create({ Type = "Spell", ID = 20066,     isTalent = true                                                 }), 
    -- Misc 
    SenseUndead                                = Create({ Type = "Spell", ID = 5502                                                                    }),
    -- Hidden 
    CancelAura                                = Create({ Type = "Spell", ID = 1022,     Color = "BLUE",  Hidden = true                                     }),    -- DivineProtection BlessingofProtection DivineShield
    CancelAuraRighteousFury                    = Create({ Type = "Spell", ID = 25780,     Color = "BLUE",  Hidden = true                                     }),    -- RighteousFury
    Vengeance                                = Create({ Type = "Spell", ID = 20049,     useMaxRank = true, isTalent = true, Hidden = true                }), 
    Reckoning                                = Create({ Type = "Spell", ID = 20177,     useMaxRank = true, isTalent = true, Hidden = true                 }), 
    ImprovedDevotionAura                    = Create({ Type = "Spell", ID = 20138,     useMaxRank = true, isTalent = true, Hidden = true                }), 
    ImprovedRetributionAura                    = Create({ Type = "Spell", ID = 20091,     useMaxRank = true, isTalent = true, Hidden = true                }), 
    ImprovedConcentrationAura                = Create({ Type = "Spell", ID = 20254,     useMaxRank = true, isTalent = true, Hidden = true                }), 
    ImprovedBlessingofMight                    = Create({ Type = "Spell", ID = 20042,     useMaxRank = true, isTalent = true, Hidden = true                }), 
    ImprovedBlessingofWisdom                = Create({ Type = "Spell", ID = 20244,     useMaxRank = true, isTalent = true, Hidden = true                }), 
    ImprovedSealofRighteousness                = Create({ Type = "Spell", ID = 20224,     useMaxRank = true, isTalent = true, Hidden = true                }), 
    Forbearance                                = Create({ Type = "Spell", ID = 25771,                                         Hidden = true                }), 
    DeBuffSealofJustice                        = Create({ Type = "Spell", ID = 20184,                                         Hidden = true                }), 
    DeBuffSealofLight                        = Create({ Type = "Spell", ID = 20185,                                         Hidden = true                }), 
    DeBuffSealoftheCrusader                    = Create({ Type = "Spell", ID = 21183,                                         Hidden = true                }), 
    DeBuffSealofWisdom                        = Create({ Type = "Spell", ID = 20268,                                         Hidden = true                }), 
}

Player:RegisterShield()
local A                                     = setmetatable(Action[Action.PlayerClass], { __index = Action })

local BlessingofProtectionUnits, BlessingofSacrificeUnits, BlessingofFreedomUnits, DispelUnits
local additionalBoP, additionalBoS, additionalBoF, additionalDispel
local BlessingofKingsPvP, BlessingofLightPvP, BlessingofMightPvP, BlessingofSalvationPvP, BlessingofSanctuaryPvP, BlessingofWisdomPvP
local BlessingofKingsPvE, BlessingofLightPvE, BlessingofMightPvE, BlessingofSalvationPvE, BlessingofSanctuaryPvE, BlessingofWisdomPvE
local player                                 = "player"
local targettarget                            = "targettarget"
local Temp                                     = {
    LastStanceTime                            = 0,
    LastSeal                                = "",
    AttackTypes                             = {"TotalImun", "DamageMagicImun"},    
    AuraForStun                                = {"TotalImun", "CCTotalImun", "StunImun", "Reflect"},    
    AuraForCC                                = {"TotalImun", "CCTotalImun", "Reflect"},
    AuraForFear                                = {"TotalImun", "CCTotalImun", "FearImun", "Reflect"},
    CastIsAbleBoS                            = {},
    ClassHasResurrect                        = {
        PALADIN                                = true,
        PRIEST                                 = true,
        SHAMAN                                 = true,        
    },
    GetIndexByClass                            = {
        WARRIOR                                = 1,
        PALADIN                                = 2,
        HUNTER                                = 3,
        ROGUE                                = 4,
        PRIEST                                = 5,
        MAGE                                = 6,
        WARLOCK                                = 7,
        DRUID                                = 8,
    },
    IsSpellIsCast                            = {
        [A.HolyLight:Info()]                = "HolyLight",
        [A.FlashofLight:Info()]                = "FlashofLight",
    },
    IsUndeadOrDemon                         = {
        ["Undead"]                            = true, 
        ["Untoter"]                            = true, 
        ["No-muerto"]                        = true, 
        ["No-muerto"]                        = true, 
        ["Mort-vivant"]                        = true, 
        ["Non Morto"]                        = true, 
        ["Renegado"]                        = true, 
        ["Нежить"]                            = true,  
        ["언데드"]                                = true,
        ["亡灵"]                            = true,
        ["不死族"]                            = true,
        ["Demon"]                            = true,
        ["Dämon"]                            = true,
        ["Demonio"]                            = true,
        ["Démon"]                            = true,
        ["Demone"]                            = true,
        ["Demônio"]                            = true,
        ["Демон"]                            = true,
        ["악마"]                                = true,
        ["恶魔"]                            = true,
        ["惡魔"]                            = true,
        [""]                                = false,
    },
    IsAuraIsCancelAura                         = {
        [A.DivineProtection:Info()]            = true,
        [A.BlessingofProtection:Info()]        = true,
        [A.DivineShield:Info()]                = true,
    },
    -- All blessings (total, they are shared - only one can be up at same time per Paladin)
    IsAuraIsBlessing                        = {
        [A.BlessingofFreedom:Info()]            = true,
        [A.BlessingofLight:Info()]                = true,
        [A.BlessingofMight:Info()]                = true,        
        [A.BlessingofProtection:Info()]            = true,        
        [A.BlessingofSacrifice:Info()]            = true,        
        [A.BlessingofSalvation:Info()]            = true,        
        [A.BlessingofSanctuary:Info()]            = true,        
        [A.BlessingofWisdom:Info()]                = true,        
        [A.BlessingofKings:Info()]                = true,        
        [A.GreaterBlessingofKings:Info()]        = true,        
        [A.GreaterBlessingofLight:Info()]        = true,        
        [A.GreaterBlessingofMight:Info()]        = true,        
        [A.GreaterBlessingofSalvation:Info()]    = true,        
        [A.GreaterBlessingofSanctuary:Info()]    = true,        
        [A.GreaterBlessingofWisdom:Info()]        = true,        
    },
    -- "Buff" is category with 5-15min duration 
    IsAuraIsBlessingBuff                    = { 
        [A.BlessingofLight:Info()]                = true,
        [A.BlessingofMight:Info()]                = true,            
        [A.BlessingofSalvation:Info()]            = true,
        [A.BlessingofSanctuary:Info()]            = true,
        [A.BlessingofWisdom:Info()]                = true,
        [A.BlessingofKings:Info()]                = true,
        [A.GreaterBlessingofKings:Info()]        = true,
        [A.GreaterBlessingofLight:Info()]        = true,
        [A.GreaterBlessingofMight:Info()]        = true,
        [A.GreaterBlessingofSalvation:Info()]    = true,    
        [A.GreaterBlessingofSanctuary:Info()]    = true,    
        [A.GreaterBlessingofWisdom:Info()]        = true,
    },
    -- We will use these tables to get ID to compare if not applied higher rank and after that if need then getting name of toggle taken from UI which we will concat by rotation mode
    IsAuraIsBlessingofKings                    = {
        [A.GreaterBlessingofKings:Info()]        = "BlessingofKings",    
        [A.BlessingofKings:Info()]                = "BlessingofKings",        
    },
    IsAuraIsBlessingofLight                 = {
        [A.GreaterBlessingofLight:Info()]        = "BlessingofLight",        
        [A.BlessingofLight:Info()]                = "BlessingofLight",
    },
    IsAuraIsBlessingofMight                 = {
        [A.GreaterBlessingofMight:Info()]        = "BlessingofMight",        
        [A.BlessingofMight:Info()]                = "BlessingofMight",
    },
    IsAuraIsBlessingofSalvation                = {
        [A.GreaterBlessingofSalvation:Info()]    = "BlessingofSalvation",        
        [A.BlessingofSalvation:Info()]            = "BlessingofSalvation",
    },
    IsAuraIsBlessingofSanctuary                = {
        [A.GreaterBlessingofSanctuary:Info()]    = "BlessingofSanctuary",        
        [A.BlessingofSanctuary:Info()]            = "BlessingofSanctuary",
    },
    IsAuraIsBlessingofWisdom                = {
        [A.GreaterBlessingofWisdom:Info()]        = "BlessingofWisdom",        
        [A.BlessingofWisdom:Info()]                = "BlessingofWisdom",
    },
    -- Get by regular blessing object the greater blessing object 
    -- Note: Used in Solo by IsAppliedHigherBlessingBuff func 
    GetGreaterBlessingByNormal                = {
        [A.BlessingofLight]                        = A.GreaterBlessingofLight,
        [A.BlessingofMight]                        = A.GreaterBlessingofMight,                        
        [A.BlessingofSalvation]                    = A.GreaterBlessingofSalvation,        
        [A.BlessingofSanctuary]                    = A.GreaterBlessingofSanctuary,        
        [A.BlessingofWisdom]                    = A.GreaterBlessingofWisdom,        
        [A.BlessingofKings]                        = A.GreaterBlessingofKings,    
    },
    IsSealIsDeBuff                            = {
        -- Buffs
        [A.SealofJustice:Info()]            = A.SealofJustice:Info(),
        [A.SealofLight:Info()]                = A.SealofLight:Info(),
        [A.SealoftheCrusader:Info()]        = A.SealoftheCrusader:Info(),
        [A.SealofWisdom:Info()]                = A.SealofWisdom:Info(),
        -- DeBuffs converted to buff name 
        [A.DeBuffSealofJustice:Info()]        = A.SealofJustice:Info(),
        [A.DeBuffSealofLight:Info()]        = A.SealofLight:Info(),
        [A.DeBuffSealoftheCrusader:Info()]    = A.SealoftheCrusader:Info(),
        [A.DeBuffSealofWisdom:Info()]        = A.SealofWisdom:Info(),
    },
    IsAuraIsSeal                            = {
        [A.SealofCommand:Info()]            = true,
        [A.SealofJustice:Info()]            = true,
        [A.SealofLight:Info()]                = true,
        [A.SealofRighteousness:Info()]        = true,
        [A.SealoftheCrusader:Info()]        = true,
        [A.SealofWisdom:Info()]                = true,
    },
    IsAuraIsStance                            = {
        [A.ConcentrationAura:Info()]        = true,
        [A.DevotionAura:Info()]                = true,
        [A.FireResistanceAura:Info()]        = true,
        [A.FrostResistanceAura:Info()]        = true,
        [A.RetributionAura:Info()]            = true,
        [A.ShadowResistanceAura:Info()]        = true,
        [A.SanctityAura:Info()]                = true,
    },
    IsAuraIsShield                            = {
        [A.DivineShield:Info()]                = true,
        [A.DivineProtection:Info()]            = true,
    },
    IsStanceExists                            = {}, -- by others  
    PriorityAuraUse                            = {
        { obj = A.ConcentrationAura,     priority = 0,     modTalent = A.ImprovedConcentrationAura },        
        { obj = A.DevotionAura,         priority = 0,    modTalent = A.ImprovedDevotionAura         },        
        { obj = A.FireResistanceAura,     priority = 0                                             },        
        { obj = A.FrostResistanceAura,     priority = 0                                             },        
        { obj = A.RetributionAura,         priority = 0,      modTalent = A.ImprovedRetributionAura     },        
        { obj = A.ShadowResistanceAura, priority = 0                                             },        
        { obj = A.SanctityAura,         priority = 0                                             },        
    },
    PriorityOrderBlessingSolo                = {    A.BlessingofMight,              A.BlessingofKings,                A.BlessingofWisdom,               A.BlessingofSanctuary,             A.BlessingofLight,           A.BlessingofSalvation            },
    PriorityOrderBlessingOther                = {    A.GreaterBlessingofMight,     A.GreaterBlessingofKings,     A.GreaterBlessingofWisdom,         A.GreaterBlessingofSanctuary,     A.GreaterBlessingofLight, A.GreaterBlessingofSalvation,
    A.BlessingofMight,              A.BlessingofKings,               A.BlessingofWisdom,               A.BlessingofSanctuary,             A.BlessingofLight,           A.BlessingofSalvation            },
    PriorityOrderSeal                        = {},
}

local function sortByPriority(x, y) 
    return x.priority > y.priority
end 

-- Tracks destination unit of the casting spells to prevent by stopcasting overhealing 
local function CastStart(event, ...)
    local unitID, _, spellID = ...
    if unitID == player and spellID then 
        local spellName = GetSpellInfo(spellID)
        if spellName and Temp.IsSpellIsCast[spellName] then 
            Temp.LastPrimaryUnitGUID     = (IsUnitFriendly("mouseover") and UnitGUID("mouseover")) or (IsUnitFriendly("target") and UnitGUID("target")) or UnitGUID(player)
            Temp.LastPrimaryUnitID        = TeamCacheFriendlyGUIDs[Temp.LastPrimaryUnitGUID]
            Temp.LastPrimarySpellName     = spellName 
            Temp.LastPrimarySpellID        = spellID
        end 
    end 
end 

local function CastStop(event, ...)
    if Temp.LastPrimaryUnitGUID then     
        local unitID = ...
        if unitID == player then 
            Temp.LastPrimaryUnitGUID     = nil 
            Temp.LastPrimaryUnitID        = nil 
            Temp.LastPrimarySpellName     = nil 
            Temp.LastPrimarySpellID        = nil 
        end 
    end 
end 

local f = CreateFrame("Frame", nil, UIParent)
LibCC.RegisterCallback(f, "UNIT_SPELLCAST_START",             CastStart    )
LibCC.RegisterCallback(f, "UNIT_SPELLCAST_STOP",             CastStop    )
LibCC.RegisterCallback(f, "UNIT_SPELLCAST_FAILED",             CastStop    )
LibCC.RegisterCallback(f, "UNIT_SPELLCAST_INTERRUPTED",     CastStop    )
LibCC.RegisterCallback(f, "UNIT_SPELLCAST_CHANNEL_START",     CastStart    )
LibCC.RegisterCallback(f, "UNIT_SPELLCAST_CHANNEL_STOP",     CastStop    )

local function CanStopCastingOverHeal(unitID, unitGUID)
    -- @return boolean 
    if GetToggle(1, "StopCast") and Temp.LastPrimaryUnitGUID then
        local castLeftSeconds, castDonePercent, _, spellName = Unit(player):IsCastingRemains()
        if castLeftSeconds > 0 and castLeftSeconds <= 0.35 and spellName == Temp.LastPrimarySpellName and (Temp.LastPrimaryUnitID or (unitID and ((unitGUID or UnitGUID(unitID)) == Temp.LastPrimaryUnitGUID))) then
            local unit = Temp.LastPrimaryUnitID or unitID
            if Unit(unit):HealthPercent() >= 100 then 
                return true 
            end 
            
            local Key = Temp.IsSpellIsCast[spellName]
            local ObjKey
            for i = 0, huge do 
                if i == 0 then 
                    ObjKey = Key
                else 
                    ObjKey = Key .. i
                end 
                
                if A[ObjKey] then 
                    if A[ObjKey].ID == Temp.LastPrimarySpellID then 
                        return not A[ObjKey]:PredictHeal(unit, nil, unitGUID)
                    end 
                else 
                    break 
                end 
            end 
        end 
    end 
end 

-- Tracks Invisible in PvP (3 sec cooldown is enough)
Temp.InvisAuras    = {1784, 1856, 5215, 20580}
-- Rogue: Stealth
UnitCooldown:Register(1784, 3, false, true)
-- Rogue: Vanish 
UnitCooldown:Register(1856, 3, false, true)
-- Druid: Prowl 
UnitCooldown:Register(5215, 3, false, true)
-- NightElf: Shadowmeld
UnitCooldown:Register(20580, 3, false, true)

local function IsInvisAffected()
    -- @return boolean
    for i = 1, #Temp.InvisAuras do 
        if UnitCooldown:GetCooldown("arena", Temp.InvisAuras[i]) > 0 then 
            return true 
        end 
    end 
end 

Listener:Add("ACTION_EVENT_PALADIN_INVISIBLE", "PLAYER_REGEN_ENABLED", function()     
        if A.Zone ~= "pvp" then 
            Temp.hasInvisibleUnits, Temp.invisibleUnitID = nil, nil 
        end 
end) 

Listener:Add("ACTION_EVENT_PALADIN_LOG_LAST_CAST", "UNIT_SPELLCAST_SUCCEEDED", function(...)
        local unitID, _, spellID = ...
        if unitID == player then 
            local spellName = GetSpellInfo(spellID)
            if Temp.IsAuraIsSeal[spellName] then 
                Temp.LastSeal = spellName
            elseif Temp.IsAuraIsStance[spellName] then 
                Temp.LastStanceTime = TMW.time
            end         
        end 
end)

local function IsSchoolHolyUP()
    return LoC:Get("SILENCE") == 0 and LoC:Get("SCHOOL_INTERRUPT", "HOLY") == 0
end 

local function IsUndeadOrDemon(unitID)
    local unitType = UnitCreatureType(unitID) or ""
    return Temp.IsUndeadOrDemon[unitType]      
end 

local function IsBossFight(isPlayer)
    -- @return boolean 
    if not isPlayer and Unit("target"):IsBoss() then 
        return true 
    else 
        for i = 1, MAX_BOSS_FRAMES do 
            if Unit("boss" .. i):IsExists() then 
                return true 
            end 
        end 
    end 
end

local function IsRaidWipePvE(combatTime)
    -- @return boolean 
    if not A.IsInPvP and TeamCacheFriendly.Type == "raid" and TeamCacheFriendly.Size > 2 and combatTime > 20 then 
        local count = 0
        for i = 1, TeamCacheFriendly.MaxSize do 
            local member = TeamCacheFriendlyIndexToPLAYERs[i]
            if member and Unit(member):IsDead() then  
                count = count + 1
            end 
            
            if count >= TeamCacheFriendly.Size * 0.6 then 
                return true 
            end 
        end 
    end 
end 

local function UseStanceAura(icon, pStance, pStanceToggle)
    -- @return boolean  
    -- Note: true if can use stance (next return in APL must be true also to keep shown frame)
    if pStanceToggle ~= "OFF" then 
        if pStanceToggle == "AUTO" then 
            if TMW.time - Temp.LastStanceTime < GetGCD() * 5 then 
                return 
            end 
            
            local modTalent = 0
            for _, v in ipairs(Temp.PriorityAuraUse) do
                modTalent = v.modTalent and v.modTalent:GetTalentRank() or 0
                
                if v.obj == A.ConcentrationAura then 
                    if A.IamHealer and Player:IsStayingTime() > 1.5 and MultiUnits:GetByRangeIsFocused(player, 10, 1) >= 1 then 
                        v.priority = 6 + modTalent
                    else
                        v.priority = 2 + modTalent
                    end 
                elseif v.obj == A.DevotionAura then 
                    if A.IamHealer or A.Role == "TANK" then 
                        v.priority = 5 + modTalent
                    else 
                        v.priority = 2 + modTalent
                    end 
                elseif v.obj == A.RetributionAura then 
                    if not A.IamHealer then 
                        v.priority = 3 + modTalent
                    else 
                        v.priority = 2 + modTalent
                    end 
                elseif v.obj == A.SanctityAura then 
                    v.priority = 4 + modTalent
                else 
                    if v.obj == A.FireResistanceAura and Unit(player):GetSchoolDMG(2) > 0 then 
                        v.priority = 1 + modTalent
                    elseif v.obj == A.FrostResistanceAura and Unit(player):GetSchoolDMG(4) > 0 then 
                        v.priority = 1 + modTalent
                    elseif v.obj == A.ShadowResistanceAura and Unit(player):GetSchoolDMG(5) > 0 then 
                        v.priority = 1 + modTalent    
                    else 
                        v.priority = 0 + modTalent
                    end 
                end             
            end 
            
            tsort(Temp.PriorityAuraUse, sortByPriority) 
            for _, v in ipairs(Temp.PriorityAuraUse) do
                -- Note: IsReady
                if not Temp.IsStanceExists[v.obj:Info()] then 
                    if v.obj:Info() == pStance then 
                        return 
                    end 
                    
                    if v.obj:IsReadyByPassCastGCD(player, true, nil, true) then 
                        return v.obj:IsReady(player) and v.obj:Show(icon)
                    end 
                end 
            end 
        else
            -- Note: IsReadyP
            local Stance = A[pStanceToggle]
            if Stance and Stance:Info() ~= pStance and not Temp.IsStanceExists[Stance:Info()] and Stance:IsReadyP(player) then 
                return Stance:Show(icon)
            end 
        end 
    end 
end 

local function GetMyActiveSealDeBuff(unitID)
    -- @return number (in sec, remain time), number (in sec, total duration), nil or string (auraName)
    -- Note: This function checks only player's (own) seal debuffs on a unitID 
    if unitID then 
        local auraName, auraDuration, auraExpirationTime, _
        for i = 1, huge do 
            auraName, _, _, _, auraDuration, auraExpirationTime = UnitAura(unitID, i, "HARMFUL PLAYER")
            if not auraName then 
                break 
            elseif Temp.IsSealIsDeBuff[auraName] then 
                return auraExpirationTime == 0 and huge or auraExpirationTime - TMW.time, auraDuration, Temp.IsSealIsDeBuff[auraName]
            end 
        end 
    end 
    
    return 0, 0, nil 
end 

local function GetSealInfo(unitID, pSealToggle, pSeal, pSealRemain, pReckoningRemain)
    -- @return object or nil, number, string or nil  
    -- Note: Returns obj of Seal, remain debuff of active seal in seconds, name debuff of active seal
    if pSealToggle ~= "OFF" then 
        local sealDeBuffRemain, sealDeBuffDuration, sealDeBuffName = GetMyActiveSealDeBuff(unitID) 
        
        if not Temp.IsSealIsDeBuff[Temp.LastSeal] or (sealDeBuffRemain > 0 and sealDeBuffRemain + 1 >= sealDeBuffDuration) or A.Judgement:GetSpellTimeSinceLastCast() > 1 then -- It has delay to apply debuff
            local mainhand_speed          = UnitAttackSpeed(player) or 0
            
            if pSealToggle == "AUTO" then     
                local hasSealofJusticeDeBuff = sealDeBuffName == A.SealofJustice:Info() 
                local canApplyDeBuff         = (not sealDeBuffName or (hasSealofJusticeDeBuff and Unit(unitID):GetMaxSpeed() <= 100 and Unit(unitID):GetCurrentSpeed() > 0 and Unit(unitID):GetCurrentSpeed() < 100)) and (not A.IsInPvP or Unit(unitID):IsBoss() or Unit(unitID):TimeToDie() > 10)
                local isReachedSlots         = not A.IsInPvP and not sealDeBuffName and Unit(unitID):IsDeBuffsLimited()                                
                
                -- SealofJustice
                if A.IsInPvP and A.SealofJustice:IsReady(player) and Unit(unitID):IsPlayer() and Unit(unitID):GetMaxSpeed() > 100 and (not hasSealofJusticeDeBuff or sealDeBuffRemain < GetGCD() + GetCurrentGCD()) then 
                    if A.SealofJustice:Info() ~= pSeal then
                        return A.SealofJustice, sealDeBuffRemain, sealDeBuffName
                    end 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end 
                
                -- SealoftheCrusader
                if A.SealoftheCrusader:IsReady(player) and not A.IamHealer and not isReachedSlots and canApplyDeBuff then 
                    if A.SealoftheCrusader:Info() ~= pSeal then
                        return A.SealoftheCrusader, sealDeBuffRemain, sealDeBuffName
                    end 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end 
                
                -- SealofLight
                if A.SealofLight:IsReady(player) and A.IamHealer and not isReachedSlots and canApplyDeBuff then 
                    if A.SealofLight:Info() ~= pSeal then
                        return A.SealofLight, sealDeBuffRemain, sealDeBuffName
                    end 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end 
                
                -- SealofWisdom
                if A.SealofWisdom:IsReady(player) and not isReachedSlots and canApplyDeBuff then 
                    if A.SealofWisdom:Info() ~= pSeal then
                        return A.SealofWisdom, sealDeBuffRemain, sealDeBuffName
                    end 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end 
                
                -- SealofRighteousness
                if A.SealofRighteousness:IsReady(player) and (A.ImprovedSealofRighteousness:GetTalentRank() > 0 or pReckoningRemain > 0 or mainhand_speed <= 3.4 or not A.SealofCommand:IsReady(player)) then 
                    if A.SealofRighteousness:Info() ~= pSeal then
                        return A.SealofRighteousness, sealDeBuffRemain, sealDeBuffName
                    end 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end 
                
                -- SealofCommand
                if A.SealofCommand:IsReady(player) then 
                    if A.SealofCommand:Info() ~= pSeal then
                        return A.SealofCommand, sealDeBuffRemain, sealDeBuffName
                    end 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end             
            elseif pSealToggle == "SealofCommand/SealofRighteousness + SealoftheCrusader" then 
                -- SealoftheCrusader
                if (A.SealoftheCrusader:Info() ~= sealDeBuffName or (unitID == targettarget and sealDeBuffRemain <= A.Judgement:GetCooldown())) and A.SealoftheCrusader:IsReadyP(player) then 
                    if A.SealoftheCrusader:Info() ~= pSeal then 
                        return A.SealoftheCrusader, sealDeBuffRemain, sealDeBuffName
                    end                 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end 
                
                -- SealofCommand
                if A.SealofCommand:IsReadyP(player) and (pReckoningRemain == 0 or not A.SealofRighteousness:IsReadyP(player)) then 
                    if A.SealofCommand:Info() ~= pSeal then 
                        return A.SealofCommand, sealDeBuffRemain, sealDeBuffName
                    end                 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end
                
                -- SealofRighteousness
                if A.SealofRighteousness:IsReadyP(player) then 
                    if A.SealofRighteousness:Info() ~= pSeal then 
                        return A.SealofRighteousness, sealDeBuffRemain, sealDeBuffName
                    end                 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end
            elseif pSealToggle == "SealofCommand/SealofRighteousness + SealofWisdom" then 
                -- SealofWisdom
                if (A.SealofWisdom:Info() ~= sealDeBuffName or (unitID == targettarget and sealDeBuffRemain <= A.Judgement:GetCooldown())) and A.SealofWisdom:IsReadyP(player) then 
                    if A.SealofWisdom:Info() ~= pSeal then 
                        return A.SealofWisdom, sealDeBuffRemain, sealDeBuffName
                    end                 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end 
                
                -- SealofCommand
                if A.SealofCommand:IsReadyP(player) and (pReckoningRemain == 0 or mainhand_speed > 3.4 or not A.SealofRighteousness:IsReadyP(player)) then 
                    if A.SealofCommand:Info() ~= pSeal then 
                        return A.SealofCommand, sealDeBuffRemain, sealDeBuffName
                    end                 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end
                
                -- SealofRighteousness
                if A.SealofRighteousness:IsReadyP(player) then 
                    if A.SealofRighteousness:Info() ~= pSeal then 
                        return A.SealofRighteousness, sealDeBuffRemain, sealDeBuffName
                    end                 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end
            elseif pSealToggle == "SealofCommand/SealofRighteousness + SealofLight" then 
                -- SealofLight
                if (A.SealofLight:Info() ~= sealDeBuffName or (unitID == targettarget and sealDeBuffRemain <= A.Judgement:GetCooldown())) and A.SealofLight:IsReadyP(player) then 
                    if A.SealofLight:Info() ~= pSeal then 
                        return A.SealofLight, sealDeBuffRemain, sealDeBuffName
                    end                 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end 
                
                -- SealofCommand
                if A.SealofCommand:IsReadyP(player) and (pReckoningRemain == 0 or mainhand_speed > 3.4 or not A.SealofRighteousness:IsReadyP(player)) then 
                    if A.SealofCommand:Info() ~= pSeal then 
                        return A.SealofCommand, sealDeBuffRemain, sealDeBuffName
                    end                 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end
                
                -- SealofRighteousness
                if A.SealofRighteousness:IsReadyP(player) then 
                    if A.SealofRighteousness:Info() ~= pSeal then 
                        return A.SealofRighteousness, sealDeBuffRemain, sealDeBuffName
                    end                 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end
            elseif pSealToggle == "SealofCommand/SealofRighteousness + SealofJustice" then 
                -- SealofJustice
                if (A.SealofJustice:Info() ~= sealDeBuffName or (unitID == targettarget and sealDeBuffRemain <= A.Judgement:GetCooldown())) and A.SealofJustice:IsReadyP(player) then 
                    if A.SealofJustice:Info() ~= pSeal then 
                        return A.SealofJustice
                    end                 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end 
                
                -- SealofCommand
                if A.SealofCommand:IsReadyP(player) and (pReckoningRemain == 0 or mainhand_speed > 3.4 or not A.SealofRighteousness:IsReadyP(player)) then 
                    if A.SealofCommand:Info() ~= pSeal then 
                        return A.SealofCommand, sealDeBuffRemain, sealDeBuffName
                    end                 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end
                
                -- SealofRighteousness
                if A.SealofRighteousness:IsReadyP(player) then 
                    if A.SealofRighteousness:Info() ~= pSeal then 
                        return A.SealofRighteousness, sealDeBuffRemain, sealDeBuffName
                    end                 
                    return nil, sealDeBuffRemain, sealDeBuffName
                end
            else
                -- Note: IsReadyP            
                if A[pSealToggle] and (A[pSealToggle]:Info() ~= pSeal or pSealRemain <= GetGCD() + GetCurrentGCD()) and A[pSealToggle]:IsReadyP(player) then                     
                    return A[pSealToggle], sealDeBuffRemain, sealDeBuffName                     
                end 
            end
        end 
        
        return nil, sealDeBuffRemain, sealDeBuffName
    end 
end 

local function GetInfoActiveBlessings(unitID)
    -- @return variables with ID and information what it's applied by other paladins
    -- Note: Getting info about blessing buffs applied by other paladins 
    local     LightID,         MightID,         SalvationID,         SanctuaryID,         WisdomID,         KingsID,        
    LightByOthers,     MightByOthers,     SalvationByOthers,     SanctuaryByOthers,     WisdomByOthers, KingsByOthers
    
    local count = 0
    local auraName, auraID, auraCaster, _
    for i = 1, huge do 
        auraName, _, _, _, _, _, auraCaster, _, _, auraID = UnitBuff(unitID, i)
        if not auraName then 
            break 
        elseif Temp.IsAuraIsBlessingBuff[auraName] then 
            count = count + 1
            if Temp.IsAuraIsBlessingofKings[auraName] then 
                KingsID = auraID
                if auraCaster ~= player then 
                    KingsByOthers = true 
                end 
            elseif Temp.IsAuraIsBlessingofLight[auraName] then 
                LightID = auraID
                if auraCaster ~= player then 
                    LightByOthers = true 
                end 
            elseif Temp.IsAuraIsBlessingofMight[auraName] then 
                MightID = auraID
                if auraCaster ~= player then 
                    MightByOthers = true 
                end 
            elseif Temp.IsAuraIsBlessingofSalvation[auraName] then 
                SalvationID = auraID
                if auraCaster ~= player then 
                    SalvationByOthers = true 
                end 
            elseif Temp.IsAuraIsBlessingofSanctuary[auraName] then 
                SanctuaryID = auraID
                if auraCaster ~= player then 
                    SanctuaryByOthers = true 
                end 
            elseif Temp.IsAuraIsBlessingofWisdom[auraName] then 
                WisdomID = auraID
                if auraCaster ~= player then 
                    WisdomByOthers = true 
                end 
            end 
        end
        
        if count >= 6 then 
            break 
        end 
    end 
    
    return     LightID,         MightID,         SalvationID,         SanctuaryID,         WisdomID,         KingsID,        
    LightByOthers,     MightByOthers,     SalvationByOthers,     SanctuaryByOthers,     WisdomByOthers, KingsByOthers
end 

local function GetMyActiveBlessing(unitID)
    -- @return number (in sec, remain time), nil or string (auraName)
    -- Note: This function checks only player's (own) blessings buffs on a unitID 
    local auraName, auraExpirationTime, _
    for i = 1, huge do 
        auraName, _, _, _, _, auraExpirationTime = UnitAura(unitID, i, "HELPFUL PLAYER")
        if not auraName then 
            break 
        elseif Temp.IsAuraIsBlessing[auraName] then 
            return auraExpirationTime == 0 and huge or auraExpirationTime - TMW.time, auraName
        end 
    end 
    
    return 0, nil 
end 
GetMyActiveBlessing = A.MakeFunctionCachedDynamic(GetMyActiveBlessing)

local function IsAppliedHigherBlessingBuff(unitID, Obj)
    -- @return boolean 
    -- Note: Solo with non AUTO toggle 
    local firstBuffName, secondBuffName 
    
    firstBuffName = Obj:Info()
    if Temp.GetGreaterBlessingByNormal[Obj] then 
        secondBuffName = Temp.GetGreaterBlessingByNormal[Obj]:Info()
    end 
    
    local auraName, auraID, _
    for i = 1, huge do 
        auraName, _, _, _, _, _, _, _, _, auraID = UnitBuff(unitID, i)
        if not auraName then 
            break 
        elseif (auraName == firstBuffName or auraName == secondBuffName) and auraID > Obj.ID then 
            return true
        end 
    end 
end 

local function GetInRangeValidUndeadsOrDemons(count)
    -- @return boolean     
    local c = 0 
    for unitID in pairs(nameplates) do 
        if IsUndeadOrDemon(unitID) and A.TurnUndead:IsInRange(unitID) and A.AbsentImun(nil, unitID, Temp.AttackTypes) then 
            c = c + 1
            
            if c >= count then 
                return true 
            end 
        end 
    end         
end 

local function GetByRange(count, range, isCheckEqual, isCheckCombat)
    -- @return boolean 
    local c = 0 
    for unitID in pairs(nameplates) do 
        if (not isCheckEqual or not UnitIsUnit("target", unitID)) and (not isCheckCombat or Unit(unitID):CombatTime() > 0) and not Unit(unitID):IsTotem() then 
            local r = Unit(unitID):GetRange()
            if r > 0 and r <= range then 
                c = c + 1
            end 
            
            if c >= count then 
                return true 
            end 
        end 
    end     
end 

local function CanTargetNearest(inCombat, isNotEqual, isCheckCombat)
    -- @return boolean 
    return inCombat and GetToggle(1, "AutoTarget") and GetByRange(1, 10, isNotEqual, isCheckCombat) 
end 

-- PvP - Catch by BoS breakable enemy casts
-- Get data from API and reorganize for profile 
do 
    local list = GetAuraList("Premonition")
    for i = 1, #list do 
        -- Note: [castName] = range
        Temp.CastIsAbleBoS[_G.GetSpellInfo(list[i][1])] = list[i][2]
    end 
end 

local function SomeOneCastingOnMeCC()
    -- @return boolean 
    if A.IsInPvP then
        local unitID
        if A.Zone == "pvp" then 
            if TeamCacheEnemy.Type then     
                local _, castRemains, castName
                for i = 1, TeamCacheEnemy.MaxSize do 
                    unitID = TeamCacheEnemyIndexToPLAYERs[i]
                    if unitID then 
                        castRemains, _, _, castName = Unit(unitID):IsCastingRemains()
                        if castName and Temp.CastIsAbleBoS[castName] and castRemains <= GetGCD() + GetCurrentGCD() and UnitIsUnit(unitID .. "target", player) and Unit(unitID):GetRange() <= Temp.CastIsAbleBoS[castName] then 
                            return true 
                        end 
                    end 
                end 
            end 
        else                
            local _, castRemains, castName
            for unitID in pairs(nameplates) do 
                castRemains, _, _, castName = Unit(unitID):IsCastingRemains()
                if castName and Temp.CastIsAbleBoS[castName] and castRemains <= GetGCD() + GetCurrentGCD() and UnitIsUnit(unitID .. "target", player) and Unit(unitID):GetRange() <= Temp.CastIsAbleBoS[castName] then 
                    return true 
                end 
            end              
        end 
    end 
end 
SomeOneCastingOnMeCC = A.MakeFunctionCachedStatic(SomeOneCastingOnMeCC, 0.05)

local function MyActiveBleessingsofSacrifice(count)
    -- @return boolean 
    -- Note: Returns true / false on count (how much applied BoS you have on group members included their pets)
    if TeamCacheFriendly.Type then     
        local c = 0
        local unitID, petID
        for i = 1, TeamCacheFriendly.MaxSize do 
            unitID = TeamCacheFriendlyIndexToPLAYERs[i]
            if unitID then 
                if Unit(unitID):HasBuffs(A.BlessingofSacrifice.ID, true) > GetGCD() + GetCurrentGCD() + 1 then 
                    c = c + 1
                elseif GetToggle(1, "HE_Pets") then  
                    petID = TeamCacheFriendlyIndexToPETs[i]
                    if petID and Unit(petID):HasBuffs(A.BlessingofSacrifice.ID, true) > GetGCD() + GetCurrentGCD() + 1 then 
                        c = c + 1
                    end 
                end 
            end 
            
            if c >= count then 
                return true 
            end 
        end 
    end 
end 
MyActiveBleessingsofSacrifice = A.MakeFunctionCachedDynamic(MyActiveBleessingsofSacrifice, 1)

-------------------------------------------
-- [[ GLOBAL API ]] 
-------------------------------------------
function Action.IsAbleBoP(unitID, isPlayer, isMsg) 
    -- @return object or nil
    if not additionalBoP then 
        additionalBoP = GetToggle(2, "BlessingofProtectionAdditional")
        -- [1] PvE Threat 
        -- [2] PvE Skip Tanks   
        -- [3] Auras         
        -- [4] Only Self              (false default)                
    end 
    
    if IsSchoolHolyUP() and (isPlayer or (type(isPlayer) == "nil" and Unit(unitID):IsPlayer())) and (not additionalBoP[4] or isMsg or UnitIsUnit(unitID, player)) and A.BlessingofProtection:IsReady(unitID) and Unit(unitID):HasDeBuffs(A.Forbearance.ID) == 0 and Unit(unitID):CombatTime() > (A.IsInPvP and 0 or 2.5) and (A.IsInPvP or not additionalBoP[2] or isMsg or not Unit(unitID):IsTank()) and (A.Zone ~= "pvp" or not Unit(unitID):HasFlags()) then
        -- MSG
        if isMsg then 
            return A.BlessingofProtection
        end 
        
        -- Dying
        local operator     = GetToggle(2, "BlessingofProtectionOperator")
        local HP         = GetToggle(2, "BlessingofProtectionHP")
        local TTD        = GetToggle(2, "BlessingofProtectionTTD")
        if HP >= 0 or TTD >= 0 then 
            local unitHP     = Unit(unitID):HealthPercent()
            local unitTTD     = Unit(unitID):TimeToDie()
            if operator == "AND" then 
                if (HP < 0 or unitHP <= HP) and (TTD < 0 or unitTTD <= TTD) then 
                    return A.BlessingofProtection
                end 
            else 
                if (HP >= 0 and unitHP <= HP) or (TTD >= 0 and unitTTD <= TTD) then 
                    return A.BlessingofProtection
                end 
            end 
        end 
        
        -- Auras 
        if AuraIsValid(unitID, additionalBoP[3], "BlessingofProtection") then 
            return A.BlessingofProtection
        end 
        
        -- Threat 
        if additionalBoP[1] and not A.IsInPvP then 
            local status, percent = Unit(unitID):ThreatSituation()
            if status >= 3 and percent >= 100 then 
                return A.BlessingofProtection
            end 
        end  
    end 
end 

function Action.IsAbleBoS(unitID, isPlayer, isMsg)
    -- @return object or nil
    if not additionalBoS then 
        additionalBoS = GetToggle(2, "BlessingofSacrificeAdditional")
        -- [1] Auras 
        -- [2] PvP Dodge CC casts
        -- [3] PvP Uptime FK (flags)
    end 
    
    if IsSchoolHolyUP() and (isPlayer or (type(isPlayer) == "nil" and Unit(unitID):IsPlayer())) and not UnitIsUnit(unitID, player) and A.BlessingofSacrifice:IsReady(unitID) and Unit(unitID):HasBuffs(A.BlessingofSacrifice.ID) == 0 and Unit(unitID):CombatTime() > (A.IsInPvP and 0 or 2.5) then
        local remainBlessing, nameBlessing = GetMyActiveBlessing(unitID)
        if not nameBlessing or Temp.IsAuraIsBlessingBuff[nameBlessing] or remainBlessing <= GetGCD() + GetCurrentGCD() then 
            -- MSG
            if isMsg then 
                return A.BlessingofSacrifice
            end 
            
            -- Dying
            local operator     = GetToggle(2, "BlessingofSacrificeOperator")
            local HP         = GetToggle(2, "BlessingofSacrificeHP")
            local TTD        = GetToggle(2, "BlessingofSacrificeTTD")
            if HP >= 0 or TTD >= 0 then 
                local unitHP     = Unit(unitID):HealthPercent()
                local unitTTD     = Unit(unitID):TimeToDie()
                if operator == "AND" then 
                    if (HP < 0 or unitHP <= HP) and (TTD < 0 or unitTTD <= TTD) then 
                        return A.BlessingofSacrifice
                    end 
                else 
                    if (HP >= 0 and unitHP <= HP) or (TTD >= 0 and unitTTD <= TTD) then 
                        return A.BlessingofSacrifice
                    end 
                end 
            end 
            
            -- Auras 
            if AuraIsValid(unitID, additionalBoS[1], "BlessingofSacrifice") then 
                return A.BlessingofSacrifice
            end 
            
            -- CC casts 
            if additionalBoS[2] and SomeOneCastingOnMeCC() and not MyActiveBleessingsofSacrifice(1) and MultiUnits:GetByRangeIsFocused(player, nil, 2) < 2 and Unit(unitID):IsFocused() and Unit(unitID):GetRealTimeDMG() > 0 then 
                return A.BlessingofSacrifice
            end  
            
            -- FK 
            if additionalBoS[3] and A.IsInPvP and A.Zone == "pvp" and Unit(unitID):HasFlags() then 
                return A.BlessingofSacrifice
            end 
        end 
    end 
end 

function Action.IsAbleBoF(unitID, isPlayer, isMsg)
    -- @return object or nil
    if not additionalBoF then 
        additionalBoF = GetToggle(2, "BlessingofFreedomAdditional")
        -- [1] Auras 
        -- [2] Slowed 
        -- [3] Only self             (false default)
        -- [4] Without another CC    (false default)
    end 
    
    if IsSchoolHolyUP() and (isPlayer or (type(isPlayer) == "nil" and Unit(unitID):IsPlayer())) and A.BlessingofFreedom:IsReady(unitID) and Unit(unitID):CombatTime() > (A.IsInPvP and 0 or 2.5) and (not additionalBoF[3] or isMsg or UnitIsUnit(unitID, player)) and (not additionalBoF[4] or isMsg or Unit(unitID):InCC(2) == 0) then
        local remainBlessing, nameBlessing = GetMyActiveBlessing(unitID)
        if not nameBlessing or Temp.IsAuraIsBlessingBuff[nameBlessing] or remainBlessing <= GetGCD() + GetCurrentGCD() then 
            -- MSG
            if isMsg then 
                return A.BlessingofFreedom
            end 
            
            -- Slowed 
            if additionalBoF[2] then 
                if UnitIsUnit(unitID, player) then 
                    if LoC:Get("SNARE") > 0 then 
                        return A.BlessingofFreedom
                    end 
                else 
                    local speed = Unit(unitID):GetCurrentSpeed()
                    if speed > 68 and speed <= 90 then -- 68 because that how it works if unit will back moving 
                        return A.BlessingofFreedom
                    end 
                end 
            end 
            
            -- Auras 
            if AuraIsValid(unitID, additionalBoF[1], "BlessingofFreedom") then 
                return A.BlessingofFreedom
            end 
        end 
    end 
end 

function Action.IsAbleBlessingBuff(unitID, isPlayer)
    -- @return object or nil
    -- Additional toggle is applied in HealingEngine such as "BlessingBuffHealingEnginePvP" and "BlessingBuffHealingEnginePvE"
    if IsSchoolHolyUP() and (isPlayer or (type(isPlayer) == "nil" and Unit(unitID):IsPlayer())) then 
        local buffRemains = (A.IsInPvP and GetToggle(2, "BlessingBuffRemainDurationPvP")) or (not A.IsInPvP and GetToggle(2, "BlessingBuffRemainDurationPvE"))
        if buffRemains >= 0 then 
            local myBlessingRemains, myBlessingName = GetMyActiveBlessing(unitID) 
            if not myBlessingName or Temp.IsAuraIsBlessingBuff[myBlessingName] then
                local inGroup = TeamCacheFriendly.Size > 1 and Unit(unitID):InGroup()
                
                -- Solo 
                if not inGroup and UnitIsUnit(unitID, player) then 
                    local toggle = (A.IsInPvP and GetToggle(2, "BlessingBuffSoloPvP")) or (not A.IsInPvP and GetToggle(2, "BlessingBuffSoloPvE"))                    
                    if toggle ~= "OFF" then 
                        if toggle == "AUTO" then 
                            -- Note: IsReady
                            -- Get info to compare 
                            local     LightID,         MightID,         SalvationID,         SanctuaryID,         WisdomID,         KingsID,        
                            LightByOthers,     MightByOthers,     SalvationByOthers,     SanctuaryByOthers,     WisdomByOthers, KingsByOthers = GetInfoActiveBlessings(unitID)
                            
                            -- Get blessing: logic 
                            if A.ImprovedBlessingofMight:GetTalentRank() > 0 and A.BlessingofMight:IsReady(unitID) and (not MightID or A.BlessingofMight.ID >= MightID) and not MightByOthers then 
                                if A.BlessingofMight:Info() == myBlessingName and myBlessingRemains > buffRemains then 
                                    return 
                                end 
                                return A.BlessingofMight  
                            end 
                            
                            if (A.ImprovedBlessingofWisdom:GetTalentRank() > 0 or A.PlayerLevel < 40) and A.BlessingofWisdom:IsReady(unitID) and (not WisdomID or A.BlessingofWisdom.ID >= WisdomID) and not WisdomByOthers then 
                                if A.BlessingofWisdom:Info() == myBlessingName and myBlessingRemains > buffRemains then 
                                    return 
                                end 
                                return A.BlessingofWisdom 
                            end 
                            
                            if Player:HasShield(true) and A.BlessingofSanctuary:IsReady(unitID) and (not SanctuaryID or A.BlessingofSanctuary.ID >= SanctuaryID) and not SanctuaryByOthers then
                                if A.BlessingofSanctuary:Info() == myBlessingName and myBlessingRemains > buffRemains then 
                                    return 
                                end 
                                return A.BlessingofSanctuary 
                            end 
                            
                            if A.IamHealer and A.BlessingofKings:IsReady(unitID) and (not KingsID or A.BlessingofKings.ID >= KingsID) and not KingsByOthers then
                                if A.BlessingofKings:Info() == myBlessingName and myBlessingRemains > buffRemains then 
                                    return 
                                end 
                                return A.BlessingofKings 
                            end 
                            
                            -- Get blessing: any first up able 
                            for i = 1, #Temp.PriorityOrderBlessingSolo do 
                                local obj = Temp.PriorityOrderBlessingSolo[i]
                                local objName = obj:Info()
                                if obj:IsReady(unitID) then 
                                    if Temp.IsAuraIsBlessingofKings[objName] then 
                                        if (not KingsID or obj.ID >= KingsID) and not KingsByOthers then 
                                            if objName == myBlessingName and myBlessingRemains > buffRemains then 
                                                return 
                                            end 
                                            return obj
                                        end 
                                    elseif Temp.IsAuraIsBlessingofLight[objName] then
                                        if (not LightID or obj.ID >= LightID) and not LightByOthers then 
                                            if objName == myBlessingName and myBlessingRemains > buffRemains then 
                                                return 
                                            end 
                                            return obj
                                        end 
                                    elseif Temp.IsAuraIsBlessingofMight[objName] then 
                                        if (not MightID or obj.ID >= MightID) and not MightByOthers then 
                                            if objName == myBlessingName and myBlessingRemains > buffRemains then 
                                                return 
                                            end 
                                            return obj
                                        end 
                                    elseif Temp.IsAuraIsBlessingofSalvation[objName] then 
                                        if (not SalvationID or obj.ID >= SalvationID) and not SalvationByOthers then 
                                            if objName == myBlessingName and myBlessingRemains > buffRemains then 
                                                return 
                                            end 
                                            return obj
                                        end 
                                    elseif Temp.IsAuraIsBlessingofSanctuary[objName] then 
                                        if (not SanctuaryID or obj.ID >= SanctuaryID) and not SanctuaryByOthers then 
                                            if objName == myBlessingName and myBlessingRemains > buffRemains then 
                                                return 
                                            end 
                                            return obj
                                        end 
                                    elseif Temp.IsAuraIsBlessingofWisdom[objName] then 
                                        if (not WisdomID or obj.ID >= WisdomID) and not WisdomByOthers then 
                                            if objName == myBlessingName and myBlessingRemains > buffRemains then 
                                                return 
                                            end 
                                            return obj
                                        end 
                                    end
                                end 
                            end 
                        else 
                            -- Note: IsReadyP
                            if A[toggle] and A[toggle]:IsReadyP(unitID) and (A[toggle]:Info() ~= myBlessingName or myBlessingRemains <= buffRemains) and not IsAppliedHigherBlessingBuff(unitID, A[toggle]) then 
                                return A[toggle]
                            end 
                        end 
                    end                     
                    return 
                end 
                
                -- Others standalone people / Group
                -- Note: IsReady
                local unitClass = Unit(unitID):Class()
                local unitIndex = Temp.GetIndexByClass[unitClass] 
                if unitIndex then 
                    -- Get info to compare 
                    local     LightID,         MightID,         SalvationID,         SanctuaryID,         WisdomID,         KingsID,        
                    LightByOthers,     MightByOthers,     SalvationByOthers,     SanctuaryByOthers,     WisdomByOthers, KingsByOthers = GetInfoActiveBlessings(unitID)
                    
                    -- Get blessing: depends on class toggle 
                    for i = 1, inGroup and #Temp.PriorityOrderBlessingOther or #Temp.PriorityOrderBlessingSolo do 
                        local obj = inGroup and Temp.PriorityOrderBlessingOther[i] or Temp.PriorityOrderBlessingSolo[i]
                        local objName = obj:Info()
                        if obj:IsReady(unitID) then 
                            if Temp.IsAuraIsBlessingofKings[objName] then 
                                if (not KingsID or obj.ID >= KingsID) and not KingsByOthers then -- toggles: "BlessingofKingsPvP" "BlessingofKingsPvE" is numeric table with key as class specified index        
                                    if not BlessingofKingsPvP then 
                                        BlessingofKingsPvP = GetToggle(2, "BlessingofKingsPvP")
                                    end 
                                    if not BlessingofKingsPvE then 
                                        BlessingofKingsPvE = GetToggle(2, "BlessingofKingsPvE")
                                    end 
                                    
                                    if (A.IsInPvP and BlessingofKingsPvP[unitIndex]) or (not A.IsInPvP and BlessingofKingsPvE[unitIndex]) then                                     
                                        if objName == myBlessingName and myBlessingRemains > buffRemains then 
                                            return 
                                        end 
                                        return obj
                                    end 
                                end 
                            elseif Temp.IsAuraIsBlessingofLight[objName] then
                                if (not LightID or obj.ID >= LightID) and not LightByOthers then 
                                    if not BlessingofLightPvP then 
                                        BlessingofLightPvP = GetToggle(2, "BlessingofLightPvP")
                                    end 
                                    if not BlessingofLightPvE then 
                                        BlessingofLightPvE = GetToggle(2, "BlessingofLightPvE")
                                    end 
                                    
                                    if (A.IsInPvP and BlessingofLightPvP[unitIndex]) or (not A.IsInPvP and BlessingofLightPvE[unitIndex]) then     
                                        if objName == myBlessingName and myBlessingRemains > buffRemains then 
                                            return 
                                        end 
                                        return obj
                                    end 
                                end 
                            elseif Temp.IsAuraIsBlessingofMight[objName] then 
                                if (not MightID or obj.ID >= MightID) and not MightByOthers then 
                                    if not BlessingofMightPvP then 
                                        BlessingofMightPvP = GetToggle(2, "BlessingofMightPvP")
                                    end 
                                    if not BlessingofMightPvE then 
                                        BlessingofMightPvE = GetToggle(2, "BlessingofMightPvE")
                                    end 
                                    
                                    if (A.IsInPvP and BlessingofMightPvP[unitIndex]) or (not A.IsInPvP and BlessingofMightPvE[unitIndex]) then     
                                        if objName == myBlessingName and myBlessingRemains > buffRemains then 
                                            return 
                                        end 
                                        return obj
                                    end 
                                end 
                            elseif Temp.IsAuraIsBlessingofSalvation[objName] then 
                                if (not SalvationID or obj.ID >= SalvationID) and not SalvationByOthers then 
                                    if not BlessingofSalvationPvP then 
                                        BlessingofSalvationPvP = GetToggle(2, "BlessingofSalvationPvP")
                                    end 
                                    if not BlessingofSalvationPvE then 
                                        BlessingofSalvationPvE = GetToggle(2, "BlessingofSalvationPvE")
                                    end 
                                    
                                    if (A.IsInPvP and BlessingofSalvationPvP[unitIndex]) or (not A.IsInPvP and BlessingofSalvationPvE[unitIndex]) then     
                                        if objName == myBlessingName and myBlessingRemains > buffRemains then 
                                            return 
                                        end 
                                        return obj
                                    end 
                                end 
                            elseif Temp.IsAuraIsBlessingofSanctuary[objName] then 
                                if (not SanctuaryID or obj.ID >= SanctuaryID) and not SanctuaryByOthers then 
                                    if not BlessingofSanctuaryPvP then 
                                        BlessingofSanctuaryPvP = GetToggle(2, "BlessingofSanctuaryPvP")
                                    end 
                                    if not BlessingofSanctuaryPvE then 
                                        BlessingofSanctuaryPvE = GetToggle(2, "BlessingofSanctuaryPvE")
                                    end 
                                    
                                    if (A.IsInPvP and BlessingofSanctuaryPvP[unitIndex]) or (not A.IsInPvP and BlessingofSanctuaryPvE[unitIndex]) then     
                                        if objName == myBlessingName and myBlessingRemains > buffRemains then 
                                            return 
                                        end 
                                        return obj
                                    end 
                                end 
                            elseif Temp.IsAuraIsBlessingofWisdom[objName] then 
                                if (not WisdomID or obj.ID >= WisdomID) and not WisdomByOthers then 
                                    if not BlessingofWisdomPvP then 
                                        BlessingofWisdomPvP = GetToggle(2, "BlessingofWisdomPvP")
                                    end 
                                    if not BlessingofWisdomPvE then 
                                        BlessingofWisdomPvE = GetToggle(2, "BlessingofWisdomPvE")
                                    end 
                                    
                                    if (A.IsInPvP and BlessingofWisdomPvP[unitIndex]) or (not A.IsInPvP and BlessingofWisdomPvE[unitIndex]) then     
                                        if objName == myBlessingName and myBlessingRemains > buffRemains then 
                                            return 
                                        end 
                                        return obj
                                    end 
                                end 
                            end
                        end 
                    end 
                end 
            end 
        end 
    end 
end 

function Action.IsAbleDispel(unitID, isPlayer, isMsg)
    -- @return object or nil
    if not additionalDispel then 
        additionalDispel = GetToggle(2, "AdditionalDispel")
        -- [1] Auras Magic 
        -- [2] Auras Poison 
        -- [3] Auras Disease
        -- [4] Only self                (false default)
    end 
    
    if IsSchoolHolyUP() and (isPlayer or (type(isPlayer) == "nil" and Unit(unitID):IsPlayer())) and (not additionalDispel[4] or isMsg or UnitIsUnit(unitID, player)) then 
        if A.Cleanse:IsReady(unitID) then 
            if ((additionalDispel[1] or isMsg) and AuraIsValid(unitID, isMsg or "UseDispel", "Magic")) or ((additionalDispel[2] or isMsg) and AuraIsValid(unitID, isMsg or "UseDispel", "Poison")) or ((additionalDispel[3] or isMsg) and AuraIsValid(unitID, isMsg or "UseDispel", "Disease")) then 
                return A.Cleanse 
            end 
        elseif A.Purify:IsReady(unitID) then 
            if ((additionalDispel[2] or isMsg) and AuraIsValid(unitID, isMsg or "UseDispel", "Poison")) or ((additionalDispel[3] or isMsg) and AuraIsValid(unitID, isMsg or "UseDispel", "Disease")) then 
                return A.Purify 
            end 
        end 
    end 
end 

--[[ Note
A:IsReady(unitID, skipRange, skipLua, skipShouldStop, skipUsable)
A:IsReadyP(unitID, skipRange, skipLua, skipShouldStop, skipUsable)
A:IsReadyM(unitID, skipRange, skipUsable)
A:IsReadyByPassCastGCD(unitID, skipRange, skipLua, skipUsable)
A:IsReadyByPassCastGCDP(unitID, skipRange, skipLua, skipUsable)
A:IsReadyToUse(unitID, skipShouldStop, skipUsable)
]]

-- [1] CC AntiFake Rotation 
A[1] = function(icon)
    local unitID
    if IsUnitEnemy("mouseover") then 
        unitID = "mouseover"
    elseif IsUnitEnemy("target") then 
        unitID = "target"
    end 
    
    if unitID and A.AntiFakeCC:IsReadyByPassCastGCD(unitID) and A.AntiFakeCC:AbsentImun(unitID, Temp.AuraForStun) and Unit(unitID):IsControlAble("stun") then 
        return A.AntiFakeCC:Show(icon)                    
    end 
end 

-- [2] Kick AntiFake Rotation
A[2] = function(icon)    
    local unitID
    if IsUnitEnemy("mouseover") then 
        unitID = "mouseover"
    elseif IsUnitEnemy("target") then 
        unitID = "target"
    end 
    
    if unitID and Unit(unitID):IsCastingRemains() > 0 and A.AntiFakeInterrupt:IsReadyByPassCastGCD(unitID) and A.AntiFakeInterrupt:AbsentImun(unitID, Temp.AuraForCC) and Unit(unitID):IsControlAble("incapacitate") then         
        return A.AntiFakeInterrupt:Show(icon)
    end                                                                         
end

-- [3] Rotation 
A[3] = function(icon)    
    -- Player     
    local pCancelAuraName
    local pSeal, pStance
    local pSealRemain                = 0 
    local pRighteousFuryRemain        = 0
    local pVengeanceRemain            = 0 
    local pHolyShield                 = 0 
    local pDivineFavorRemain        = 0
    local pPerceptionRemain            = 0 
    local pReckoningRemain            = 0 
    local pDivineShieldRemain        = 0
    local combatTime                = Unit(player):CombatTime()
    local inCombat                     = combatTime > 0
    local isSchoolUP                = IsSchoolHolyUP()
    local pStanceToggle             = (A.IsInPvP and GetToggle(2, "StanceAuraPvP"))     or (not A.IsInPvP and GetToggle(2, "StanceAuraPvE"))
    local pSealToggle                = (A.IsInPvP and GetToggle(2, "SealPvP"))             or (not A.IsInPvP and GetToggle(2, "SealPvE"))
    local potionToUse                = GetToggle(2, "PotionToUse")
    local inAoE                        = GetToggle(2, "AoE")
    -- Other 
    local eTarget, eMouseover, eTargetTarget
    local fTarget, fMouseover    
    local hasUnit, hasMouseover, inMelee
    
    -- Buff Auras  
    wipe(Temp.IsStanceExists)
    local auraName, auraRemain, auraExpirationTime, auraCaster, _
    for i = 1, huge do 
        auraName, _, _, _, _, auraExpirationTime, auraCaster = UnitAura(player, i, "HELPFUL")
        if not auraName then 
            break 
        else
            auraRemain = auraExpirationTime == 0 and huge or auraExpirationTime - TMW.time
            
            if player == auraCaster then 
                if pRighteousFuryRemain == 0 and auraName == A.RighteousFury:Info() then 
                    pRighteousFuryRemain = auraRemain
                end 
                
                if pVengeanceRemain == 0 and A.Vengeance:IsSpellLearned() and auraName == A.Vengeance:Info() then 
                    pVengeanceRemain = auraRemain
                end 
                
                if pHolyShield == 0 and A.HolyShield:IsSpellLearned() and auraName == A.HolyShield:Info() then 
                    pHolyShield = auraRemain
                end 
                
                if pDivineFavorRemain == 0 and A.DivineFavor:IsSpellLearned() and auraName == A.DivineFavor:Info() then 
                    pDivineFavorRemain = huge 
                end 
                
                if pReckoningRemain == 0 and A.Reckoning:IsSpellLearned() and auraName == A.Reckoning:Info() then 
                    pReckoningRemain = auraRemain
                end 
                
                if pPerceptionRemain == 0 and A.PlayerRace == "Human" and auraName == A.Perception:Info() then 
                    pPerceptionRemain = auraRemain
                end 
                
                if Temp.IsAuraIsSeal[auraName] then 
                    pSeal         = auraName
                    pSealRemain = auraRemain
                end 
                
                if pDivineShieldRemain == 0 and Temp.IsAuraIsShield[auraName] then 
                    pDivineShieldRemain = auraRemain
                end 
            end                         
            
            if Temp.IsAuraIsStance[auraName] then                 
                if player == auraCaster then 
                    pStance = auraName
                else 
                    Temp.IsStanceExists[auraName] = true 
                end 
            end 
            
            if not pCancelAuraName and Temp.IsAuraIsCancelAura[auraName] then 
                pCancelAuraName = auraName
            end 
        end 
    end 
    
    -- CancelAuraRighteousFury
    if A.Role ~= "TANK" and pRighteousFuryRemain > 0 and GetToggle(2, "CancelAuraRighteousFury") and not A.IsInPvP and TeamCacheFriendly.Size > 1 and A.Zone ~= "none" then 
        Player:CancelBuff((A.CancelAuraRighteousFury:Info()))
        return A.CancelAuraRighteousFury:Show(icon)
    end     
    
    -- Units 
    if IsUnitEnemy("mouseover") then 
        eMouseover = "mouseover"
        inMelee    = Player:GetSwing(1) > 0 and A.Judgement:IsInRange(eMouseover)
    elseif IsUnitFriendly("mouseover") then 
        fMouseover = "mouseover"
    end 
    
    if IsUnitEnemy("target") then 
        eTarget = "target"
        if not inMelee then 
            inMelee    = Player:GetSwing(1) > 0 and A.Judgement:IsInRange(eTarget)
        end 
    elseif IsUnitFriendly("target") then
        fTarget = "target"
        if not eMouseover and not fMouseover and IsUnitEnemy(targettarget) then 
            eTargetTarget = targettarget
            if not inMelee then 
                inMelee    = A.Judgement:IsInRange(eTargetTarget) -- Player:GetSwing(1) > 0 
            end 
        end         
    end 
    
    hasMouseover = eMouseover or fMouseover
    hasUnit = hasMouseover or eTarget or fTarget or eTargetTarget    
    
    -- Functions 
    local EnemyRotation, FriendlyRotation
    function EnemyRotation(unitID)
        local useDispel, useShields, useHoTs, useUtils     = HealingEngineGetOptionsByUnitID(player) -- player here as self
        local isTargetTarget                             = unitID == targettarget
        local canDownranking                             = GetToggle(2, "DownrankDamage")
        local hp                                          = Unit(unitID):HealthPercent()
        
        -- CancelAura 
        if isSchoolUP and inCombat and not isTargetTarget and pCancelAuraName and GetToggle(2, "CancelAura") and Player:IsMoving() and Unit(player):HealthPercent() > 50 then 
            Player:CancelBuff(pCancelAuraName)        
            return A.CancelAura:Show(icon)
        end     
        
        -- [[ INTERRUPTS ]]
        if isSchoolUP and not isTargetTarget then 
            local _, useCC, useRacial, notInterruptable, castRemainsTime = InterruptIsValid(unitID, nil, nil, true)  
            if useCC and castRemainsTime >= GetLatency() and A.AbsentImun(nil, unitID, Temp.AuraForCC) then 
                -- HammerofJustice
                if A.HammerofJustice:IsReady(unitID) and Unit(unitID):IsControlAble("stun") and A.HammerofJustice:AbsentImun(unitID, "StunImun") then 
                    return A.HammerofJustice:Show(icon)
                end 
                
                -- Repentance
                if A.Repentance:IsReady(unitID) and Unit(unitID):IsControlAble("incapacitate") then 
                    return A.Repentance:Show(icon)
                end 
            end 
        end 
        
        -- [[ CROWN CONTROL ]]
        -- TurnUndead
        if LoC:Get("SILENCE") == 0 and LoC:Get("SCHOOL_INTERRUPT", "NATURE") == 0 and not isTargetTarget and Player:IsStaying() and A.TurnUndead:IsReady(unitID) and Unit(unitID):IsUndead() and (Unit(unitID):IsPlayer() or (Unit(unitID):CombatTime() > 0 and Unit(unitID):GetDMG() == 0)) and A.TurnUndead:AbsentImun(unitID, Temp.AuraForFear) then 
            return A.TurnUndead:Show(icon)
        end         
        
        -- [[ SELF ]]
        -- Blessing of Freedom        
        if not BlessingofFreedomUnits then 
            BlessingofFreedomUnits = GetToggle(2, "BlessingofFreedomUnits")
        end 
        if useUtils and not inMelee and not isTargetTarget and BlessingofFreedomUnits[4] and A.IsAbleBoF(player, true) then 
            return A.BlessingofFreedom:Show(icon)
        end 
        
        -- RighteousFury
        if isSchoolUP and not isTargetTarget and A.Role == "TANK" and pRighteousFuryRemain == 0 and A.RighteousFury:IsReady(player) then 
            return A.RighteousFury:Show(icon)
        end 
        
        -- Stance 
        if isSchoolUP and not isTargetTarget and UseStanceAura(icon, pStance, pStanceToggle) then 
            return true 
        end 
        
        -- HolyShield
        if isSchoolUP and inCombat and Player:HasShield(true) and pHolyShield == 0 and A.HolyShield:IsReady(player) and (A.Role == "TANK" or Unit(player):IsTankingAoE()) then 
            return A.HolyShield:Show(icon)
        end 
        
        -- [[ APL ]]
        local ObjectHammerofWrath
        if isSchoolUP and hp <= 20 and Player:IsStaying() and A.AbsentImun(nil, unitID, Temp.AttackTypes) then 
            if canDownranking then 
                ObjectHammerofWrath = DetermineUsableObject(unitID, nil, nil, nil, nil, A.HammerofWrath, A.HammerofWrath2, A.HammerofWrath1)
            elseif A.HammerofWrath:IsReady(unitID) then 
                ObjectHammerofWrath = A.HammerofWrath
            end 
        end 
        
        -- Seal 
        local sealObj, sealDeBuffRemain, sealDeBuffName = GetSealInfo(unitID, pSealToggle, pSeal, pSealRemain, pReckoningRemain)
        if isSchoolUP and sealObj and not ObjectHammerofWrath then 
            return sealObj:Show(icon)
        end 
        
        -- Trinkets
        if LoC:Get("DISARM") == 0 and isSchoolUP and not isTargetTarget and inMelee and inCombat and BurstIsON(unitID) and A.AbsentImun(nil, unitID, Temp.AttackTypes) then 
            if A.Trinket1:IsReady(unitID) and A.Trinket1:IsItemDamager() then 
                return A.Trinket1:Show(icon)
            end 
            
            if A.Trinket2:IsReady(unitID) and A.Trinket2:IsItemDamager() then 
                return A.Trinket2:Show(icon)
            end 
        end 
        
        -- Judgement
        if isSchoolUP and pSeal and (not Temp.IsSealIsDeBuff[pSeal] or pSeal ~= sealDeBuffName or sealDeBuffRemain <= GetCurrentGCD()) and A.Judgement:IsReady(unitID) and A.Judgement:AbsentImun(unitID, Temp.AttackTypes) then 
            return A.Judgement:Show(icon)
        end 
        
        -- HammerofWrath
        if ObjectHammerofWrath then 
            return ObjectHammerofWrath:Show(icon)
        end         
        
        -- Consecration
        -- Note: Vengeance proc 
        if isSchoolUP and pVengeanceRemain > 0 and inAoE and inMelee then 
            if canDownranking then 
                local ObjConsecration = DetermineUsableObject(unitID, true, nil, nil, nil, A.Consecration, A.Consecration4, A.Consecration3, A.Consecration2, A.Consecration1)
                if ObjConsecration and ObjConsecration:AbsentImun(unitID, Temp.AttackTypes) then 
                    return ObjConsecration:Show(icon)
                end 
            else
                if A.Consecration:IsReady(unitID, true) and A.Consecration:AbsentImun(unitID, Temp.AttackTypes) then 
                    return A.Consecration:Show(icon)
                end 
            end 
        end 
        
        -- HolyWrath
        if isSchoolUP and inAoE and Player:IsStaying() and GetInRangeValidUndeadsOrDemons(1) then 
            if canDownranking then 
                local ObjHolyWrath = DetermineUsableObject(unitID, true, nil, nil, nil, A.HolyWrath, A.HolyWrath1)
                if ObjHolyWrath and (hp > 20 or A.HammerofWrath:GetCooldown() == 0 or ObjectHammerofWrath:GetCooldown() > A.HammerofWrath:GetSpellCastTime()) then 
                    return ObjHolyWrath:Show(icon)
                end 
            else
                if A.HolyWrath:IsReady(unitID, true) and (hp > 20 or A.HammerofWrath:GetCooldown() == 0 or A.HolyWrath:GetCooldown() > A.HammerofWrath:GetSpellCastTime())  then 
                    return A.HolyWrath:Show(icon)
                end 
            end 
        end 
        
        -- Exorcism
        if isSchoolUP and IsUndeadOrDemon(unitID) then 
            if canDownranking then 
                local ObjExorcism = DetermineUsableObject(unitID, nil, nil, nil, nil, A.Exorcism, A.Exorcism5, A.Exorcism4, A.Exorcism3, A.Exorcism2, A.Exorcism1)
                if ObjExorcism and ObjExorcism:AbsentImun(unitID, Temp.AttackTypes) then 
                    return ObjExorcism:Show(icon)
                end 
            else
                if A.Exorcism:IsReady(unitID) and A.Exorcism:AbsentImun(unitID, Temp.AttackTypes) then 
                    return A.Exorcism:Show(icon)
                end 
            end 
        end 
        
        -- Consecration
        -- Note: No Vengeance talent 
        if isSchoolUP and not A.Vengeance:IsSpellLearned() and inAoE and inMelee then 
            if canDownranking then 
                local ObjConsecration = DetermineUsableObject(unitID, true, nil, nil, nil, A.Consecration, A.Consecration4, A.Consecration3, A.Consecration2, A.Consecration1)
                if ObjConsecration and ObjConsecration:AbsentImun(unitID, Temp.AttackTypes) then 
                    return ObjConsecration:Show(icon)
                end 
            else
                if A.Consecration:IsReady(unitID, true) and A.Consecration:AbsentImun(unitID, Temp.AttackTypes) then 
                    return A.Consecration:Show(icon)
                end 
            end 
        end 
        
        -- HolyShock
        if isSchoolUP and not isTargetTarget and not fMouseover and GetToggle(2, "HolyShockCanDamage") then 
            if canDownranking then 
                local ObjHolyShock = DetermineUsableObject(unitID, nil, nil, nil, nil, A.HolyShock, A.HolyShock2, A.HolyShock1)
                if ObjHolyShock and ObjHolyShock:AbsentImun(unitID, Temp.AttackTypes) then 
                    return ObjHolyShock:Show(icon)
                end 
            else
                if A.HolyShock:IsReady(unitID) and A.HolyShock:AbsentImun(unitID, Temp.AttackTypes) then 
                    return A.HolyShock:Show(icon)
                end 
            end 
        end 
        
        -- Blessing Buff 
        if useUtils and not isTargetTarget and not fMouseover then 
            local ObjBlessingBuff = A.IsAbleBlessingBuff(player, true)
            if ObjBlessingBuff then 
                return ObjBlessingBuff:Show(icon)
            end 
        end 
        
        -- [[ MISC ]]        
        -- AutoTarget 
        -- Note: In combat - nearest if out of range or imun
        if not isTargetTarget and ((not inMelee and Unit(unitID):GetRange() > 15) or not A.AbsentImun(nil, unitID, Temp.AttackTypes)) and CanTargetNearest(inCombat, true, true) then 
            return A:Show(icon, ACTION_CONST_AUTOTARGET)
        end 
        
        -- @player 
        if not fMouseover and not eMouseover and eTarget and GetToggle(2, "SelfRotation") and FriendlyRotation(player) then 
            return true
        end 
    end 
    
    function FriendlyRotation(unitID)    
        local useDispel, useShields, useHoTs, useUtils     = HealingEngineGetOptionsByUnitID(unitID)        
        --local isManaSave                                 = HealingEngineIsManaSave(unitID)    
        local unitGUID                                    = UnitGUID(unitID)
        local ttd                                         = Unit(unitID):TimeToDie()
        local hp                                        = Unit(unitID):HealthPercent()
        local isPlayer                                     = unitID == player or Unit(unitID):IsPlayer()
        local isEmergency                                 = hp > 0 and ttd <= GetGCD() + GetCurrentGCD() + (TMW.UPD_INTV or 0) + GetPing()
        local canDivineFavor                            = isPlayer and A.DivineFavor:IsReady(player) and pDivineFavorRemain == 0            
        
        -- Healing objects 
        local ObjHS, ObjHolyLight, ObjFlashofLight
        
        -- StopCast if destination is unknown as unitID 
        if not Temp.LastPrimaryUnitID and CanStopCastingOverHeal(unitID) then 
            return A:Show(icon, ACTION_CONST_STOPCAST)
        end 
        
        -- Redemption
        if isSchoolUP and not inCombat and unitID ~= player and A.Redemption:IsReady(unitID) and Player:IsStaying() and Unit(unitID):IsDead() then
            return A.Redemption:Show(icon)
        end 
        
        -- HolyShock
        -- Note: Emergency
        if isSchoolUP and unitID ~= player and hp <= 35 and isEmergency then
            if not ObjHS then 
                ObjHS = DetermineHealObject(unitID, nil, nil, nil, nil, A.HolyShock, A.HolyShock2, A.HolyShock1)
            end 
            
            if ObjHS then 
                -- DivineFavor 
                if canDivineFavor and ObjHS:PredictHeal(unitID, 2, unitGUID) then 
                    return A.DivineFavor:Show(icon)
                end 
                
                return ObjHS:Show(icon)
            end 
        end                     
        
        -- Blessing of Protection
        if not BlessingofProtectionUnits then 
            BlessingofProtectionUnits = GetToggle(2, "BlessingofProtectionUnits")
        end 
        if useShields and BlessingofProtectionUnits[4] and A.IsAbleBoP(unitID, isPlayer) then 
            return A.BlessingofProtection:Show(icon)
        end 
        
        -- LayonHands
        -- Note: Emergency
        if isSchoolUP and inCombat and (unitID ~= player or (not A.DivineProtection:IsReady(player) and not A.DivineShield:IsReady(player)) or Unit(player):HasDeBuffs(A.Forbearance.ID) > 0) and hp <= 23 and isEmergency and Unit(unitID):IsPlayer() and A.LayonHands:IsReadyByPassCastGCD(unitID) and Unit(unitID):HasBuffs("TotalImun") == 0 and Unit(unitID):HasBuffs(A.BlessingofProtection.ID) == 0 and (unitID == player or A.LayonHands:PredictHeal(unitID, nil, unitGUID)) then 
            return A.LayonHands:Show(icon)
        end 
        
        -- Blessing of Freedom        
        if not BlessingofFreedomUnits then 
            BlessingofFreedomUnits = GetToggle(2, "BlessingofFreedomUnits")
        end 
        if useUtils and unitID ~= player and BlessingofFreedomUnits[4] and A.IsAbleBoF(unitID, isPlayer) then 
            return A.BlessingofFreedom:Show(icon)
        end 
        
        -- Cleanse / Purify
        if not DispelUnits then 
            DispelUnits = GetToggle(2, "DispelUnits")
        end 
        if useDispel and DispelUnits[4] then
            local dispelObj = A.IsAbleDispel(unitID, isPlayer)
            if dispelObj then 
                return dispelObj:Show(icon)
            end 
        end         
        
        -- Blessing of Sacrifice
        if not BlessingofSacrificeUnits then 
            BlessingofSacrificeUnits = GetToggle(2, "BlessingofSacrificeUnits")
        end 
        if useHoTs and unitID ~= player and BlessingofSacrificeUnits[4] and A.IsAbleBoS(unitID, isPlayer) then 
            return A.BlessingofSacrifice:Show(icon)
        end     
        
        -- Seal / Judgement
        -- Note: @targettarget
        if isSchoolUP and unitID ~= player and inCombat and hp > 60 and not fMouseover and not eMouseover and fTarget and eTargetTarget and A.Judgement:IsInRange(eTargetTarget) and not A.Judgement:IsBlocked() and not A.Judgement:IsBlockedBySpellBook() then 
            local nextSeal, sealDeBuffRemain, sealDeBuffName = GetSealInfo(eTargetTarget, pSealToggle, pSeal, pSealRemain, pReckoningRemain)
            if (not sealDeBuffName or (sealDeBuffRemain <= GetGCD() and A.Judgement:GetCooldown() <= GetGCD())) and (A.IsInPvP or sealDeBuffName or not Unit(eTargetTarget):IsDeBuffsLimited()) and A.Judgement:AbsentImun(eTargetTarget, Temp.AttackTypes) then         
                if nextSeal and Temp.IsSealIsDeBuff[nextSeal:Info()] then 
                    return nextSeal:Show(icon)
                end 
                
                if pSeal and Temp.IsSealIsDeBuff[pSeal] and A.Judgement:IsReady(eTargetTarget, true) then 
                    return A.Judgement:Show(icon)
                end 
            end 
        end 
        
        -- #1 Stance 
        if isSchoolUP and hp > 65 and UseStanceAura(icon, pStance, pStanceToggle) then 
            return true 
        end         
        
        -- Trinkets  
        local trinketsHP = GetToggle(2, "HealingTrinketsHP")
        if trinketsHP >= 0 and hp <= trinketsHP then 
            if A.Trinket1:IsReady(unitID) and A.Trinket1:GetItemCategory() ~= "DPS" then 
                return A.Trinket1:Show(icon)
            end 
            
            if A.Trinket2:IsReady(unitID) and A.Trinket2:GetItemCategory() ~= "DPS" then 
                return A.Trinket2:Show(icon)
            end 
        end 
        
        -- Safety healing 
        if isSchoolUP and Player:IsStaying() then 
            -- HolyLight
            -- Note: Safe casting 
            if not ObjHolyLight then 
                ObjHolyLight = DetermineHealObject(unitID, nil, nil, nil, nil, A.HolyLight, A.HolyLight8, A.HolyLight7, A.HolyLight6, A.HolyLight5, A.HolyLight4, A.HolyLight3, A.HolyLight2, A.HolyLight1)
            end 
            
            if ObjHolyLight and ObjHolyLight:CanSafetyCastHeal(unitID) then 
                -- DivineFavor 
                if canDivineFavor and ttd > GetGCD() + GetCurrentGCD() + ObjHolyLight:GetSpellCastTime() and ttd <= 8 and hp <= 40 and ObjHolyLight:PredictHeal(unitID, 2, unitGUID) then 
                    return A.DivineFavor:Show(icon)
                end 
                
                return ObjHolyLight:Show(icon)
            end 
            
            -- FlashofLight
            -- Note: Safe casting 
            if not ObjFlashofLight then 
                ObjFlashofLight = DetermineHealObject(unitID, nil, nil, nil, nil, A.FlashofLight, A.FlashofLight5, A.FlashofLight4, A.FlashofLight3, A.FlashofLight2, A.FlashofLight1)
            end 
            
            if ObjFlashofLight and ObjFlashofLight:CanSafetyCastHeal(unitID) then 
                -- DivineFavor 
                if canDivineFavor and ttd > GetGCD() + GetCurrentGCD() + ObjHolyLight:GetSpellCastTime() and ttd <= 8 and hp <= 40 and ObjFlashofLight:PredictHeal(unitID, 2, unitGUID) then 
                    return A.DivineFavor:Show(icon)
                end 
                
                return ObjFlashofLight:Show(icon)
            end 
        end 
        
        -- HolyShock
        if isSchoolUP and unitID ~= player then 
            if not ObjHS then 
                ObjHS = DetermineHealObject(unitID, nil, nil, nil, nil, A.HolyShock, A.HolyShock2, A.HolyShock1)
            end 
            
            if ObjHS then 
                -- DivineFavor 
                if canDivineFavor and ttd > GetGCD() * 3 and ObjHS:PredictHeal(unitID, 2, unitGUID) then 
                    return A.DivineFavor:Show(icon)
                end 
                
                return ObjHS:Show(icon)
            end 
        end 
        
        -- Any emergency healing 
        if isSchoolUP and Player:IsStaying() then 
            -- FlashofLight
            if not ObjFlashofLight then 
                ObjFlashofLight = DetermineHealObject(unitID, nil, nil, nil, nil, A.FlashofLight, A.FlashofLight5, A.FlashofLight4, A.FlashofLight3, A.FlashofLight2, A.FlashofLight1)
            end 
            
            if ObjFlashofLight then 
                return ObjFlashofLight:Show(icon)
            end 
            
            -- HolyLight
            if not ObjHolyLight then 
                ObjHolyLight = DetermineHealObject(unitID, nil, nil, nil, nil, A.HolyLight, A.HolyLight8, A.HolyLight7, A.HolyLight6, A.HolyLight5, A.HolyLight4, A.HolyLight3, A.HolyLight2, A.HolyLight1)
            end 
            
            if ObjHolyLight then 
                return ObjHolyLight:Show(icon)
            end 
        end 
        
        -- DivineIntervention
        if isSchoolUP and inCombat and isPlayer and not UnitIsUnit(unitID, player) and hp > 0 and A.DivineIntervention:IsReady(unitID) then 
            if GetToggle(2, "DivineInterventionOnRaidWipePvE") and Temp.ClassHasResurrect[Unit(unitID):Class()] and IsBossFight(isPlayer) and IsRaidWipePvE(combatTime) then 
                return A.DivineIntervention:Show(icon)
            end 
            
            local diHP, diTTD, diOperator    = GetToggle(2, "DivineInterventionHP"), GetToggle(2, "DivineInterventionTTD"), GetToggle(2, "DivineInterventionOperator")
            local diMana                    = GetToggle(2, "DivineInterventionMana")
            if (diHP >= 0 or diTTD >= 0) and (diMana < 0 or Unit(player):Power() <= diMana) then 
                if diOperator == "AND" then 
                    if (diHP < 0 or Unit(unitID):HealthPercent() <= diHP) and (diTTD < 0 or Unit(unitID):TimeToDie() <= diTTD) then 
                        return A.DivineIntervention:Show(icon)
                    end 
                else 
                    if (diHP >= 0 and Unit(unitID):HealthPercent() <= diHP) or (diTTD >= 0 and Unit(unitID):TimeToDie() <= diTTD) then 
                        return A.DivineIntervention:Show(icon)
                    end 
                end 
            end             
        end 
        
        -- #2 Stance 
        if isSchoolUP and hp <= 65 and UseStanceAura(icon, pStance, pStanceToggle) then 
            return true 
        end     
        
        -- Blessing Buff 
        if useUtils then 
            local ObjBlessingBuff = A.IsAbleBlessingBuff(unitID, isPlayer)
            if ObjBlessingBuff then 
                return ObjBlessingBuff:Show(icon)
            end 
        end 
        
        -- @targettarget 
        if inCombat and not fMouseover and not eMouseover and fTarget and eTargetTarget and EnemyRotation(eTargetTarget) then 
            return true 
        end 
    end
    
    -- [[ DEFENSE ]]
    if inCombat and pDivineShieldRemain == 0 then  
        local deffBuffs                    = Unit(player):HasBuffs("DeffBuffs")
        
        -- LimitedInvulnerabilityPotion
        if potionToUse == "LimitedInvulnerabilityPotion" and deffBuffs == 0 and combatTime > 2 and CanUseLimitedInvulnerabilityPotion(icon) then 
            return true  
        end 
        
        -- HealingPotion 
        if potionToUse == "HealingPotion" and combatTime > 2 and CanUseHealingPotion(icon) then 
            return true 
        end 
        
        if LoC:Get("SCHOOL_INTERRUPT", "HOLY") == 0 then 
            -- DivineShield
            local dsHP, dsTTD, dsOperator = GetToggle(2, "DivineShieldHP"), GetToggle(2, "DivineShieldTTD"), GetToggle(2, "DivineShieldOperator")
            if A.DivineShield:IsReady(player) then                 
                if dsHP >= 0 or dsTTD >= 0 then 
                    if dsOperator == "AND" then 
                        if (dsHP < 0 or Unit(player):HealthPercent() <= dsHP) and (dsTTD < 0 or Unit(player):TimeToDie() <= dsTTD) and Unit(player):HasDeBuffs(A.Forbearance.ID) == 0 then 
                            return A.DivineShield:Show(icon)
                        end 
                    else 
                        if ((dsHP >= 0 and Unit(player):HealthPercent() <= dsHP) or (dsTTD >= 0 and Unit(player):TimeToDie() <= dsTTD)) and Unit(player):HasDeBuffs(A.Forbearance.ID) == 0 then 
                            return A.DivineShield:Show(icon)
                        end 
                    end 
                end 
            end
            
            -- DivineProtection
            local dpHP, dpTTD, dpOperator = GetToggle(2, "DivineProtectionHP"), GetToggle(2, "DivineProtectionTTD"), GetToggle(2, "DivineProtectionOperator")
            if ((dsHP < 0 and dsTTD < 0) or not A.DivineShield:IsReady(player)) and A.DivineProtection:IsReady(player) then 
                if dpHP >= 0 or dpTTD >= 0 then 
                    if dpOperator == "AND" then 
                        if (dpHP < 0 or Unit(player):HealthPercent() <= dpHP) and (dpTTD < 0 or Unit(player):TimeToDie() <= dpTTD) and Unit(player):HasDeBuffs(A.Forbearance.ID) == 0 then 
                            return A.DivineProtection:Show(icon)
                        end 
                    else 
                        if ((dpHP >= 0 and Unit(player):HealthPercent() <= dpHP) or (dpTTD >= 0 and Unit(player):TimeToDie() <= dpTTD)) and Unit(player):HasDeBuffs(A.Forbearance.ID) == 0 then 
                            return A.DivineProtection:Show(icon)
                        end 
                    end 
                end 
            end 
        end 
        
        -- Stoneform
        if deffBuffs == 0 and CanUseStoneformDefense(icon) then 
            return true 
        end 
    end 
    
    -- [[ LOSS OF CONTROL ]]
    -- Stoneform
    if GetToggle(2, "UseRacial-LoC") and A.Stoneform:AutoRacial() then 
        return A.Stoneform:Show(icon)
    end    
    
    -- LivingActionPotion
    if potionToUse == "LivingActionPotion" and CanUseLivingActionPotion(icon, inMelee) then 
        return true
    end 
    
    -- RestorativePotion
    if potionToUse == "RestorativePotion" and inCombat and CanUseRestorativePotion(icon) then 
        return true 
    end 
    
    -- [[ PVP ]]
    -- Note: Try to find invisible 
    if A.IsInPvP and GetToggle(2, "TryToFindInvisible") then 
        if A.Zone == "pvp" then 
            if not inCombat then 
                if not Temp.hasInvisibleUnits then 
                    Temp.hasInvisibleUnits, Temp.invisibleUnitID = EnemyTeam():HasInvisibleUnits()
                end 
                
                -- Try to catch them by entering combat by someone around while we're not entered 
                if Temp.hasInvisibleUnits and not Unit(Temp.invisibleUnitID):IsVisible() and (MultiUnits:GetByRangeInCombat(nil, 1) >= 1 or FriendlyTeam():PlayersInCombat(25, 5)) then 
                    -- Perception 
                    if A.Perception:IsRacialReady(player) then 
                        return A.Perception:Show(icon)
                    end 
                    
                    -- Consecration
                    if pPerceptionRemain == 0 then 
                        local ObjConsecration = DetermineUsableObject(nil, true, true, nil, nil, A.Consecration, A.Consecration4, A.Consecration3, A.Consecration2, A.Consecration1)
                        if ObjConsecration then 
                            return ObjConsecration:Show(icon)
                        end 
                    end  
                end 
            else
                -- Try to catch them by used stealth  
                -- Perception 
                if A.Perception:IsRacialReady(player) and IsInvisAffected("arena") then 
                    return A.Perception:Show(icon)
                end 
            end 
        else
            -- Try to catch wpvp and duel 
            if inCombat and (A.Zone == "none" or A:GetTimeDuel() > 3) and IsInvisAffected("enemy") then  
                -- Perception
                if A.Perception:IsRacialReady(player) then 
                    return A.Perception:Show(icon) 
                end 
                
                -- Consecration
                if pPerceptionRemain == 0 and not Unit("target"):IsExists() then 
                    local ObjConsecration = DetermineUsableObject(nil, true, true, nil, nil, A.Consecration, A.Consecration4, A.Consecration3, A.Consecration2, A.Consecration1)
                    if ObjConsecration then 
                        return ObjConsecration:Show(icon)
                    end 
                end 
            end 
        end 
    end 
    
    -- [[ ENEMY ROTATION ]] 
    -- @mouseover 
    if eMouseover and EnemyRotation(eMouseover) then 
        return true 
    end 
    
    -- [[ FRIENDLY ROTATION ]]
    -- @mouseover
    if fMouseover and FriendlyRotation(fMouseover) then 
        return true 
    end     
    
    -- [[ ENEMY ROTATION ]] 
    -- @target 
    if eTarget and EnemyRotation(eTarget) then 
        return true 
    end 
    
    -- [[ FRIENDLY ROTATION ]]
    -- @target
    if fTarget and FriendlyRotation(fTarget) then 
        return true 
    end 
    
    -- {[ MISC ]]
    -- SwiftnessPotion
    if potionToUse == "SwiftnessPotion" and inCombat and not inMelee and (eMouseover or fMouseover or eTarget or fTarget) and CanUseSwiftnessPotion(icon, eMouseover or fMouseover or eTarget or fTarget, ((fMouseover or fTarget) and 50) or ((eMouseover or eTarget) and 20) or nil) then 
        return true
    end 
    
    -- Runes 
    if hasUnit and inCombat and CanUseManaRune(icon) then 
        return true 
    end 
    
    -- Mana Potion 
    if hasUnit and potionToUse == "MajorManaPotion" and inCombat and A.MajorManaPotion:IsReady(player) and Unit(player):PowerPercent() <= GetToggle(2, "ManaPotion") then 
        return A.MajorManaPotion:Show(icon)
    end 
    
    -- Stoneform
    -- Note: Dispel Self 
    if not A.IsInPvP and inCombat and CanUseStoneformDispel(icon) then 
        return true
    end 
    
    -- [[ NOTHING TO DO ]]
    -- SenseUndead
    if not inCombat and A.SenseUndead:IsReady(player) and A.SenseUndead:GetSpellIcon() ~= GetTrackingTexture() then  
        return A.SenseUndead:Show(icon) 
    end 
    
    -- Stance 
    if isSchoolUP and not hasUnit and UseStanceAura(icon, pStance, pStanceToggle) then 
        return true 
    end 
end 

-- Passive Rotation
local PassiveUnitID     = {
    raid                 = {
        [1]             = "raid1",
        [2]             = "raid2",
        [3]             = "raid3",
    },
    party                 = {
        [1]                = "party1",
        [2]                = "party2",
        [3]                = "party3",
    },
} 
local function RotationPassive(icon, unitID)
    -- [[ All below disable able for units only through UI ]] 
    if Unit(unitID):IsExists() and not UnitIsUnit("target", unitID) and not UnitIsUnit("mouseover", unitID) and not Unit(unitID):InLOS() then      
        local useDispel, useShields, useHoTs, useUtils = HealingEngineGetOptionsByUnitID(unitID)    
        local index = icon.ID - 5
        -- Blessing of Protection
        if not BlessingofProtectionUnits then 
            BlessingofProtectionUnits = GetToggle(2, "BlessingofProtectionUnits")
        end 
        if useShields and BlessingofProtectionUnits[index] and A.IsAbleBoP(unitID, true) then 
            return A.BlessingofProtection:Show(icon)
        end         
        
        -- Blessing of Sacrifice
        if not BlessingofSacrificeUnits then 
            BlessingofSacrificeUnits = GetToggle(2, "BlessingofSacrificeUnits")
        end 
        if useHoTs and BlessingofSacrificeUnits[index] and A.IsAbleBoS(unitID, true) then 
            return A.BlessingofSacrifice:Show(icon)
        end     
        
        -- Blessing of Freedom        
        if not BlessingofFreedomUnits then 
            BlessingofFreedomUnits = GetToggle(2, "BlessingofFreedomUnits")
        end 
        if useUtils and BlessingofFreedomUnits[index] and A.IsAbleBoF(unitID, true) then 
            return A.BlessingofFreedom:Show(icon)
        end 
        
        -- Cleanse / Purify
        if not DispelUnits then 
            DispelUnits = GetToggle(2, "DispelUnits")
        end 
        if useDispel and DispelUnits[index] then
            local dispelObj = A.IsAbleDispel(unitID, true)
            if dispelObj then 
                return dispelObj:Show(icon)
            end 
        end         
    end 
end 

A[6] = function(icon)
    -- StopCast if destination is known as unitID 
    if Temp.LastPrimaryUnitID and CanStopCastingOverHeal() then 
        return A:Show(icon, ACTION_CONST_STOPCAST)
    end
    
    if TeamCacheFriendly.Type and RotationPassive(icon, PassiveUnitID[TeamCacheFriendly.Type][1]) then 
        return true 
    end 
end 

A[7] = function(icon)
    if TeamCacheFriendly.Type and RotationPassive(icon, PassiveUnitID[TeamCacheFriendly.Type][2]) then 
        return true 
    end 
end 

A[8] = function(icon)
    if TeamCacheFriendly.Type and RotationPassive(icon, PassiveUnitID[TeamCacheFriendly.Type][3]) then 
        return true 
    end 
end 

-- Nil (nothing for profile here, just wipe to nil)
A[4] = nil 
A[5] = nil 

