-- GBU-31(V)1/B and GBU-31(V)3/B JDAM Ordnance Personalization Profile
local GBU31_Profile = {
    id                   = "GBU_31",
    display_name         = "GBU-31 JDAM (2,000 lb GPS/INS Guided Munition)",
    base_shape           = "gbu-31",
    weight_kg            = 934.4,   -- 2,060 lbs
    explosive_kg         = 428.6,   -- Tritonal / PBXN-109
    blast_radius_m       = 75.0,
    supported_deliveries = {
        INTERNAL_BAY = true,  -- B-2 Spirit Rotary Launcher Assembly (RLA)
        PYLON        = true,  -- F-15E, F-16C, F/A-18C, A-10C Hardpoints
    },
    materials = {
        casing_standard = "GBU_31",
        casing_thermal  = "GBU_31T",
    },
    slots = {
        slot1 = {
            clsid        = "{GBU_31_SLOT1}",
            shape_name   = "GBU-31_Slot1",
            diffuse_map  = "GBU31_Slot1_Diffuse",
            roughmet_map = "GBU31_Slot1_RoughMet",
            normal_map   = "GBU31_Slot1_Normal",
            default_text = "NIGHT SHIFT ★\nWhiteman AFB • 13th BS",
        },
        slot2 = {
            clsid        = "{GBU_31_SLOT2}",
            shape_name   = "GBU-31_Slot2",
            diffuse_map  = "GBU31_Slot2_Diffuse",
            roughmet_map = "GBU31_Slot2_RoughMet",
            normal_map   = "GBU31_Slot2_Normal",
            default_text = "SPECIAL DELIVERY\nCourtesy of 509th BW",
        },
    },
}

return GBU31_Profile
