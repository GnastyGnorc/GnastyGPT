local A                                                = _G.Action

A.Data.ProfileEnabled[A.CurrentProfile]              = true
A.Data.ProfileUI                                     = {
    DateTime = "v9 (27.07.2020)",
    [2] = {
        { -- [1]                             
            {
                E = "Checkbox", 
                DB = "mouseover",
                DBV = true,
                L = { 
                    enUS = "Use\n@mouseover", 
                    ruRU = "Использовать\n@mouseover", 
                }, 
                TT = { 
                    enUS = "Will unlock use actions for @mouseover units\nExample: Resuscitate, Healing", 
                    ruRU = "Разблокирует использование действий для @mouseover юнитов\nНапример: Воскрешение, Хилинг", 
                }, 
                M = {},
            },
            {
                E = "Checkbox", 
                DB = "targettarget",
                DBV = true,
                L = { 
                    enUS = "Use\n@targettarget", 
                    ruRU = "Использовать\n@targettarget", 
                }, 
                TT = { 
                    enUS = "Will unlock use actions\nfor enemy @targettarget units", 
                    ruRU = "Разблокирует использование\nдействий для вражеских @targettarget юнитов", 
                }, 
                M = {},
            },    
        },
        { -- [2]
            {
                E = "Checkbox", 
                DB = "UseRacial-LoC",
                DBV = true,
                L = { 
                    enUS = "Loss of Control\nUse Racial", 
                    ruRU = "Потеря контроля\nИспользовать Расовую", 
                },                 
                M = {},
            },
            {
                E         = "Dropdown",                                                         
                OT         = {
                    { text = { enUS = "OFF", ruRU = "Выкл." },             value = "OFF"                             },
                    { text = (A.HealingPotion:Info()),                     value = "HealingPotion"                 },
                    { text = (A.LimitedInvulnerabilityPotion:Info()),     value = "LimitedInvulnerabilityPotion"     },
                    { text = (A.LivingActionPotion:Info()),             value = "LivingActionPotion"             },
                    { text = (A.RestorativePotion:Info()),                 value = "RestorativePotion"             },
                    { text = (A.SwiftnessPotion:Info()),                 value = "SwiftnessPotion"                 },
                },
                DB         = "PotionToUse",
                DBV     = "HealingPotion", 
                L         = {
                    enUS = "Potion",
                    ruRU = "Зелье",
                },
                TT         = {
                    enUS = A.LTrim([[    Use the selected potion as the main
                                        Do not forget to update the macro!
                                        
                                        HealingPotion macro:
                                        /use Major Healing Potion
                                        /use Superior Healing Potion
                                        /use Greater Healing Potion
                                        /use Healing Potion
                                        /use Lesser Healing Potion
                                        /use Minor Healing Potion
                    ]]),
                    ruRU = A.LTrim([[    Использовать выбранное зeлье в качестве основного
                                        Не забудьте обновить макрос!
                                        
                                        Макрос зелья исцеления:
                                        /use Хорошее лечебное зелье
                                        /use Наилучшее лечебное зелье
                                        /use Сильное лечебное зелье
                                        /use Лечебное зелье
                                        /use Простое лечебное зелье
                                        /use Слабое лечебное зелье
                    ]]),
                },
                M = {},                                    
            },    
        },
        { -- [3]    
            RowOptions = { margin = { top = 10 } },
            {
                E = "Slider",                                                     
                MIN = 0, 
                MAX = 100,                            
                DB = "TrinketBurstHealing",                    
                DBV = 50,
                ONOFF = false,
                L = { 
                    enUS = "Heal Trinkets\nHealth Percent",                        
                    ruRU = "Исц. Аксессуары\nПроцент Здоровья",                                
                },                     
                M = {},
            },
            {
                E = "Slider",                                                     
                MIN = 0, 
                MAX = 100,                            
                DB = "TrinketBurstDamaging",                    
                DBV = 95,
                ONOFF = false,
                L = { 
                    enUS = "Damage Trinkets\nHealth Percent",                        
                    ruRU = "Урон Аксессуары\nПроцент Здоровья",                        
                },                     
                M = {},
            },
        },    
        { -- [4]     
            {
                E = "Slider",                                                     
                MIN = -1, 
                MAX = 100,                            
                DB = "Runes",
                DBV = 100,
                ONOFF = true,
                L = { 
                    enUS = "Mana runes\nMana Percent",
                    ruRU = "Мана руны\nПроцент Маны",                    
                }, 
                M = {},
            },
            {                    
                E = "Slider",                                                     
                MIN = -1, 
                MAX = 100,                            
                DB = "Stoneform",
                DBV = 100,
                ONOFF = true,
                L = { 
                    enUS = A.GetSpellInfo(20594) .. "\nHealth Percent",                    
                    ruRU = A.GetSpellInfo(20594) .. "\nПроцент Здоровья",                    
                }, 
                M = {},
            },
        }, 
    },
}

