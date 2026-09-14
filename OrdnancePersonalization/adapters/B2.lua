-- B-2 Spirit Aircraft Ordnance Personalization Adapter
-- Delivery Mode: INTERNAL_BAY (Rotary Launcher Assembly / Bomb Rack Assembly)

local B2_Adapter = {
    aircraft_name = "B-2_Spirit",
    delivery_mode = "INTERNAL_BAY",
}

-- Pylon CLSID Whitelist for B-2 Internal Bays (Station 1 & 2)
B2_Adapter.bay1_clsids = {
    "{GBU_31_SLOT1}",
    "{GBU-43_MOAB_SLOT1}",
}

B2_Adapter.bay2_clsids = {
    "{GBU_31_SLOT2}",
    "{GBU-43_MOAB_SLOT2}",
}

-- Declare Personalized GBU-31 JDAM Loadouts for B-2
function B2_Adapter.register_weapons()
    if not declare_weapon or not declare_loadout then return end

    -- Base GBU-31 Weapon Descriptor from DCS core
    local function make_jdam_loadout(slot_num, clsid, display_name, shape_name)
        declare_loadout({
            category         = CAT_BOMBS,
            CLSID            = clsid,
            attribute        = {4, 5, 36, WSTYPE_PLACEHOLDER}, -- wsType_Bomb
            Count            = 1,
            Cx_pil           = 0.0001,
            Picture          = "gbu31.png",
            displayName      = _(display_name),
            Weight           = 934.4,
            kind_of_shipping = 2,
            Elements         = {
                {
                    Position  = {0, 0, 0},
                    ShapeName = shape_name,
                },
            },
        })
    end

    -- Register GBU-31 Slot 1 & 2
    make_jdam_loadout(1, "{GBU_31_SLOT1}", "GBU-31 JDAM [Bay 1 Personalized Slot]", "gbu-31")
    make_jdam_loadout(2, "{GBU_31_SLOT2}", "GBU-31 JDAM [Bay 2 Personalized Slot]", "gbu-31")
end

return B2_Adapter
