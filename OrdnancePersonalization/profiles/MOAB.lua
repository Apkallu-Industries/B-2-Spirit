-- GBU-43/B MOAB Ordnance Personalization Profile
local MOAB_Profile = {
    id                   = "GBU_43",
    display_name         = "GBU-43/B MOAB (21,600 lb Heavy Blast Ordnance)",
    base_shape           = "GBU-43_MOAB",
    weight_kg            = 9797.6,  -- 21,600 lbs
    explosive_kg         = 8482.2,  -- 18,700 lbs H-6
    blast_radius_m       = 400.0,
    supported_deliveries = {
        INTERNAL_BAY = true,  -- B-2 Spirit Internal Bay (Station 1 & 2)
        CARGO_DROP   = true,  -- C-130J-30 Palletized Rear Ramp Extraction
    },
    slots = {
        slot1 = {
            clsid        = "{GBU-43_MOAB_SLOT1}",
            shape_name   = "GBU-43_MOAB_Slot1",
            diffuse_map  = "MOAB_Slot1_Diffuse",
            roughmet_map = "MOAB_Slot1_RoughMet",
            normal_map   = "MOAB_Slot1_Normal",
            default_text = "EAT SHIT!\n— 13th Bomb Squadron",
        },
        slot2 = {
            clsid        = "{GBU-43_MOAB_SLOT2}",
            shape_name   = "GBU-43_MOAB_Slot2",
            diffuse_map  = "MOAB_Slot2_Diffuse",
            roughmet_map = "MOAB_Slot2_RoughMet",
            normal_map   = "MOAB_Slot2_Normal",
            default_text = "ENJOY!\nDirect Airmail Delivery",
        },
    },
}

return MOAB_Profile
