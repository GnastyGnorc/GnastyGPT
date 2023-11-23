local _G, setmetatable = _G, setmetatable
local TMW = TMW
local CNDT = TMW.CNDT
local Env = CNDT.Env
local A = Action
local GetToggle = A.GetToggle

A.Data.ProfileEnabled[Action.CurrentProfile] = true

A.Data.ProfileUI = {
    DateTime = "v1 (6/26/20)",
    [2] = {
        [ACTION_CONST_PALADIN_HOLY] = {
            {{E = "Header", L = {ANY = "General"}}}, { -- [7]
                {
                    E = "Checkbox",
                    DB = "mouseover",
                    DBV = false,
                    L = {ANY = "Use @mouseover"}
                }
            }, { -- [7]
                {E = "Header", L = {ANY = " -- Holy Power Dump --"}}
            }, { -- [3]
                {
                    E = "Checkbox",
                    DB = "LoDDump",
                    DBV = true,
                    L = {enUS = "LoD Dump"},
                    TT = {},
                    M = {}
                }, {
                    E = "Checkbox",
                    DB = "SotRDump",
                    DBV = false,
                    L = {enUS = "SotR Dump"},
                    TT = {},
                    M = {}
                }
            }, { -- [7] 
                {E = "Header", L = {ANY = " -- Heal Settings --"}}
            }, { -- [3]
                {
                    E = "Slider",
                    MIN = -1,
                    MAX = 100,
                    DB = "WordOfGloryHP",
                    DBV = 80,
                    L = {ANY = A.GetSpellInfo(85673) .. " (%HP)"},
                    M = {}
                }
            }, {
                {
                    E = "Checkbox",
                    DB = "UseBlessing",
                    DBV = false,
                    L = {enUS = "Use Blessing of Summer"},
                    M = {}
                }
            }
        },
        [ACTION_CONST_PALADIN_RETRIBUTION] = {
            {{E = "Header", L = {ANY = "General"}}}, { -- [7]
                {
                    E = "Checkbox",
                    DB = "mouseover",
                    DBV = false,
                    L = {ANY = "Use @mouseover"}
                }
            }, {{E = "Header", L = {ANY = "General"}}}, { -- [7]
                {
                    E = "Checkbox",
                    DB = "AoE",
                    DBV = true,
                    L = {ANY = "Use @AoE"}
                }
            }, { -- [7]
                {E = "Header", L = {ANY = " -- Holy Power Dump --"}}
            }, { -- [3]
                {
                    E = "Checkbox",
                    DB = "LoDDump",
                    DBV = true,
                    L = {enUS = "LoD Dump"},
                    TT = {},
                    M = {}
                }, {
                    E = "Checkbox",
                    DB = "SotRDump",
                    DBV = false,
                    L = {enUS = "SotR Dump"},
                    TT = {},
                    M = {}
                }
            }, { -- [7] 
                {E = "Header", L = {ANY = " -- Heal Settings --"}}
            }, { -- [3]
                {
                    E = "Slider",
                    MIN = -1,
                    MAX = 100,
                    DB = "WordOfGloryHP",
                    DBV = 80,
                    L = {ANY = A.GetSpellInfo(85673) .. " (%HP)"},
                    M = {}
                }
            }, {
                {
                    E = "Checkbox",
                    DB = "UseBlessing",
                    DBV = false,
                    L = {enUS = "Use Blessing of Summer"},
                    M = {}
                }
            }
        }
    }
}
