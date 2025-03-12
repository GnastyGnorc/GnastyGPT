-- Map locals to get faster performance
local _G, setmetatable = _G, setmetatable
local TMW = _G.TMW
local A = _G.Action

-- Create UI for current profile
A.Data.ProfileEnabled[A.CurrentProfile] = true

A.Data.ProfileUI = {
    DateTime = "v1.0 (Feb 29, 2024)",
    -- Class settings tab
    [2] = {
        -- Layout configuration
        LayoutOptions = {
            gutter = 3,
            padding = { left = 3, right = 3 }
        },
        -- General Header
        {
            {
                E = "Header",
                L = {
                    ANY = "General Settings",
                },
                S = 14,
            },
        },
        -- General Settings Row
        {
            {
                E = "Checkbox",
                DB = "AutoTargeting",
                DBV = true,
                L = {
                    ANY = "Auto Targeting",
                },
                TT = {
                    ANY = "Automatically target nearest enemy when in combat and no target selected",
                },
                M = {},
            },
            {
                E = "Checkbox",
                DB = "InterruptEnabled",
                DBV = true,
                L = {
                    ANY = "Interrupt Enabled",
                },
                TT = {
                    ANY = "Use Wind Shear to interrupt enemy casts",
                },
                M = {},
            },
        },
        -- Offensive Cooldowns Header
        {
            {
                E = "Header",
                L = {
                    ANY = "Offensive Cooldowns",
                },
                S = 14,
            },
        },
        -- Offensive Settings Row
        {
            {
                E = "Checkbox",
                DB = "FaeTransfusion",
                DBV = true,
                L = {
                    ANY = "Use Fae Transfusion",
                },
                TT = {
                    ANY = "Automatically use Fae Transfusion when available",
                },
                M = {},
            },
            {
                E = "Checkbox",
                DB = "Ascendance",
                DBV = true,
                L = {
                    ANY = "Use Ascendance",
                },
                TT = {
                    ANY = "Automatically use Ascendance",
                },
                M = {},
            },
        },
        -- Defensive Header
        {
            {
                E = "Header",
                L = {
                    ANY = "Defensive Settings",
                },
                S = 14,
            },
        },
        -- Defensive Settings Row
        {
            {
                E = "Slider",
                DB = "AstralShiftHP",
                DBV = 50,
                L = {
                    ANY = "Astral Shift HP",
                },
                TT = {
                    ANY = "Use Astral Shift when HP falls below this value",
                },
                MIN = 0,
                MAX = 100,
                M = {},
            },
            {
                E = "Slider",
                DB = "HealingSurgeHP",
                DBV = 40,
                L = {
                    ANY = "Healing Surge HP",
                },
                TT = {
                    ANY = "Use Healing Surge when HP falls below this value",
                },
                MIN = 0,
                MAX = 100,
                M = {},
            },
        },
        -- Utility Header
        {
            {
                E = "Header",
                L = {
                    ANY = "Utility Settings",
                },
                S = 14,
            },
        },
        -- Utility Settings Row
        {
            {
                E = "Dropdown",
                DB = "WindShearInterrupt",
                DBV = "All",
                L = {
                    ANY = "Wind Shear Usage",
                },
                TT = {
                    ANY = "Select which spells to interrupt",
                },
                OT = {
                    { text = "All Spells", value = "All" },
                    { text = "Important Only", value = "Important" },
                    { text = "Off", value = "Off" },
                },
                M = {},
            },
            {
                E = "Checkbox",
                DB = "PurgeEnabled",
                DBV = true,
                L = {
                    ANY = "Auto Purge",
                },
                TT = {
                    ANY = "Automatically use Purge on enemies with magic buffs",
                },
                M = {},
            },
        },
    },
    -- Message tab for party coordination
    [7] = {
        ["bloodlust"] = {
            Enabled = true,
            Key = "Bloodlust",
            LUAVER = 1,
            LUA = [[
                return Action[PlayerClass].Bloodlust:IsReadyM(thisunit)
            ]],
        },
    },
}
