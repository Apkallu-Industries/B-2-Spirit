-- B-2 Spirit default payload presets for the Mission Editor.
-- All CLSIDs validated against DCS weapon definitions.
-- pylon num 1 = Left internal bay, num 2 = Right internal bay.
local unitPayloads = {
    ["name"] = "B-2_Spirit",
    ["payloads"] = {
        [1] = {
            ["name"]   = "Ferry (Empty Bays)",
            ["pylons"] = {},
            ["tasks"]  = { [1] = 15 },   -- Nothing / ferry
        },
        [2] = {
            ["name"]   = "16x GBU-31 JDAM (Heavy Strike)",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{GBU-31}", ["num"] = 1 },
                [2] = { ["CLSID"] = "{GBU-31}", ["num"] = 2 },
            },
            ["tasks"]  = { [1] = 32, [2] = 34, [3] = 35 }, -- Ground Attack, Pinpoint Strike, Runway Attack
        },
        [3] = {
            ["name"]   = "GBU-31(V)3B Penetrator (Bunker Buster)",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{GBU-31V3B}", ["num"] = 1 },
                [2] = { ["CLSID"] = "{GBU-31V3B}", ["num"] = 2 },
            },
            ["tasks"]  = { [1] = 34, [2] = 32 },
        },
        [4] = {
            ["name"]   = "GBU-38 JDAM (Precision Strike)",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{GBU-38}", ["num"] = 1 },
                [2] = { ["CLSID"] = "{GBU-38}", ["num"] = 2 },
            },
            ["tasks"]  = { [1] = 32, [2] = 31 }, -- Ground Attack, CAS
        },
        [5] = {
            ["name"]   = "GBU-12 Paveway II (Laser Guided)",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{DB769D48-67D7-42ED-A2BE-108D566C8B1E}", ["num"] = 1 },
                [2] = { ["CLSID"] = "{DB769D48-67D7-42ED-A2BE-108D566C8B1E}", ["num"] = 2 },
            },
            ["tasks"]  = { [1] = 32, [2] = 31 },
        },
        [6] = {
            ["name"]   = "AGM-154C JSOW (Standoff)",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{9BCC2A2B-5708-4860-B1F1-053A18442067}", ["num"] = 1 },
                [2] = { ["CLSID"] = "{9BCC2A2B-5708-4860-B1F1-053A18442067}", ["num"] = 2 },
            },
            ["tasks"]  = { [1] = 32, [2] = 34 },
        },
        [7] = {
            ["name"]   = "CBU-87 CEM (Area Cluster)",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{CBU-87}", ["num"] = 1 },
                [2] = { ["CLSID"] = "{CBU-87}", ["num"] = 2 },
            },
            ["tasks"]  = { [1] = 32, [2] = 31 },
        },
        [8] = {
            ["name"]   = "Mixed: GBU-31 + AGM-154C",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{GBU-31}", ["num"] = 1 },
                [2] = { ["CLSID"] = "{9BCC2A2B-5708-4860-B1F1-053A18442067}", ["num"] = 2 },
            },
            ["tasks"]  = { [1] = 32, [2] = 34 },
        },
    },
    ["unitType"] = "B-2_Spirit",
}
return unitPayloads
