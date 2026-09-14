-- B-2 Spirit Heavy Ordnance Extension
-- GBU-43/B MOAB (Massive Ordnance Air Blast) — Personalized Marker-Pen Graffiti Editions
-- Reference-backed reconstruction for Autonomous Drone Asset Pack & B-2 Spirit

local POUNDS_TO_KG = 0.453592
local INCHES_TO_M  = 0.0254

local moab_mass      = 21600.0 * POUNDS_TO_KG  -- 9,797.59 kg total
local moab_expl_mass = 18700.0 * POUNDS_TO_KG  -- 8,482.17 kg H-6 high explosive (~11 tons TNT equivalent)

-- Base MOAB weapon physics descriptor
local function register_moab_variant(name_id, display_label, shape_file, clsid)
    local wpn = {
        category        = CAT_BOMBS,
        name            = name_id,
        user_name       = _(display_label),
        displayName     = _(display_label),
        model           = shape_file,
        wsTypeOfWeapon  = {wsType_Weapon, wsType_Bomb, wsType_Bomb_Guided, WSTYPE_PLACEHOLDER},
        scheme          = "guided_bomb",
        class_name      = "wAmmunition",
        type            = 0,
        mass            = moab_mass,
        hMin            = 1500.0,
        hMax            = 15000.0,
        Cx              = 0.0018,
        VyHold          = -120.0,
        Ag              = -1.23,
        fm = {
            mass        = moab_mass,
            caliber     = 40.5 * INCHES_TO_M, -- 1.0287 m diameter
            cx_coeff    = {1.0, 0.28, 0.65, 0.12, 1.25},
            L           = 360.0 * INCHES_TO_M, -- 9.144 m length
            I           = (1.0 / 12.0) * moab_mass * (9.144 * 9.144),
            Ma          = 2.0,
            Mw          = 1.5,
            wind_sigma  = 180,
            cx_factor   = 60,
        },
        warhead = {
            mass                = moab_expl_mass,
            expl_mass           = moab_expl_mass,
            other_factors       = {2.0, 2.0, 2.0},
            concrete_factors    = {8.0, 6.0, 4.0},
            concrete_obj_factor = 6.0,
            obj_factors         = {5.0, 4.0},
            cumulative_factor   = 3.0,
            transversal_radius  = 400.0,  -- 400m massive air blast destruction sphere
            piercing_mass       = 1500.0,
            default_fuze_delay  = 0.0,
        },
        control = {
            delay        = 1.0,
            speed_factor = 1.0,
        },
        targeting_data = {
            char_time = 20.8,
        },
    }

    declare_weapon(wpn)

    -- Pylon Loadout Descriptor
    declare_loadout({
        category         = CAT_BOMBS,
        CLSID            = clsid,
        attribute        = wpn.wsTypeOfWeapon,
        Count            = 1,
        Cx_pil           = 0.0001, -- Internal bay carriage
        Picture          = "gbu31.png",
        displayName      = _(display_label),
        Weight           = moab_mass,
        kind_of_shipping = 2,
        Elements         = {
            {
                Position  = {0, 0, 0},
                ShapeName = shape_file,
            },
        },
    })
end

-- 1. Standard 13th BS Grim Reapers
register_moab_variant("GBU-43_MOAB", "GBU-43/B MOAB (13th BS 'Grim Reapers')", "GBU-43_MOAB", "{GBU-43_MOAB}")

-- 2. "Eat Shit!"
register_moab_variant("GBU-43_MOAB_EatShit", "GBU-43/B MOAB ('Eat Shit!' — 13th BS)", "GBU-43_MOAB_EatShit", "{GBU-43_MOAB_EATSHIT}")

-- 3. "Enjoy!"
register_moab_variant("GBU-43_MOAB_Enjoy", "GBU-43/B MOAB ('Enjoy!' — Whiteman Airmail)", "GBU-43_MOAB_Enjoy", "{GBU-43_MOAB_ENJOY}")

-- 4. "Present from the USA"
register_moab_variant("GBU-43_MOAB_PresentUSA", "GBU-43/B MOAB ('Present from the USA ★')", "GBU-43_MOAB_PresentUSA", "{GBU-43_MOAB_PRESENT}")

-- 5. "Hope you like our new toy! (USAF)"
register_moab_variant("GBU-43_MOAB_NewToy", "GBU-43/B MOAB ('Hope You Like Our New Toy! — USAF')", "GBU-43_MOAB_NewToy", "{GBU-43_MOAB_NEWTOY}")

-- 6. Custom Pilot Inscription (32-character dynamic texture)
register_moab_variant("GBU-43_MOAB_Custom", "GBU-43/B MOAB (Custom Pilot Inscription)", "GBU-43_MOAB_Custom", "{GBU-43_MOAB_CUSTOM}")

-- 7. Dual-Slot Personalized Ordnance Suite (Phase 14 Master Architecture)
register_moab_variant("GBU-43_MOAB_Slot1", "GBU-43/B MOAB [Bay 1 Personalized Slot]", "GBU-43_MOAB_Slot1", "{GBU-43_MOAB_SLOT1}")
register_moab_variant("GBU-43_MOAB_Slot2", "GBU-43/B MOAB [Bay 2 Personalized Slot]", "GBU-43_MOAB_Slot2", "{GBU-43_MOAB_SLOT2}")

-- 8. Phase 15: Generic Personalized JDAM Stores (B-2 Rotary Launcher)
local function register_personalized_jdam(shape_file, display_label, clsid)
    declare_loadout({
        category         = CAT_BOMBS,
        CLSID            = clsid,
        attribute        = {4, 5, 36, WSTYPE_PLACEHOLDER},
        Count            = 1,
        Cx_pil           = 0.0001,
        Picture          = "gbu31.png",
        displayName      = _(display_label),
        Weight           = 934.4,
        kind_of_shipping = 2,
        Elements         = {
            {
                Position  = {0, 0, 0},
                ShapeName = shape_file,
            },
        },
    })
end

register_personalized_jdam("gbu-31", "GBU-31 JDAM [Bay 1 Personalized Slot]", "{GBU_31_SLOT1}")
register_personalized_jdam("gbu-31", "GBU-31 JDAM [Bay 2 Personalized Slot]", "{GBU_31_SLOT2}")



