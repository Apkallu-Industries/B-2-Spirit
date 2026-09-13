local unitPayloads = {
    ["name"]   = "B-2_Spirit",
    ["payloads"] = {
        [1] = {
            ["name"]      = "Empty",
            ["pylons"]    = {},
            ["tasks"]     = { [1] = "CAS", [2] = "Ground Attack", [3] = "Pinpoint Strike" },
        },
        [2] = {
            ["name"]      = "16x GBU-31 JDAM",
            ["pylons"]    = {
                [1] = { ["CLSID"] = "{GBU-31}", ["num"] = 1 },
                [2] = { ["CLSID"] = "{GBU-31}", ["num"] = 2 },
            },
            ["tasks"]     = { [1] = "Ground Attack", [2] = "Pinpoint Strike", [3] = "Runway Attack" },
        },
        [3] = {
            ["name"]      = "GBU-38 JDAM",
            ["pylons"]    = {
                [1] = { ["CLSID"] = "{GBU-38}", ["num"] = 1 },
                [2] = { ["CLSID"] = "{GBU-38}", ["num"] = 2 },
            },
            ["tasks"]     = { [1] = "Ground Attack", [2] = "CAS" },
        },
    },
}

return unitPayloads
