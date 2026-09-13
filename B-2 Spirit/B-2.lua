-- B-2 Spirit Stealth Bomber Aircraft Descriptor for DCS World
-- Developed by Apkallu Industries

print(">>> [B-2 Spirit] Executing B-2.lua...")

B_2_Spirit = {
    Name                = 'B-2_Spirit',
    DisplayName         = _('B-2 Spirit (Flyable)'),
    Picture             = "B-2_Spirit.png",
    Rate                = 100,
    Shape               = "B-2_Spirit",
    shape_table_data    = {
        {
            file        = 'B-2_Spirit',
            life        = 35,
            vis         = 3,
            desrt       = 'self',
            fire        = {300, 4},
            username    = 'B-2_Spirit',
            index       = WSTYPE_PLACEHOLDER,
            classname   = "lLandPlane",
            positioning = "BYNORMAL",
            drawonmap   = true,
        },
    },
    mapclasskey         = "P0091000025",
    attribute           = {wsType_Air, wsType_Airplane, wsType_Fighter, WSTYPE_PLACEHOLDER, "Battleplanes", "Strategic bombers", "Refuelable"},
    Categories          = {"{78EFB7A2-FD52-4b57-A6A6-3BF0E1D6555F}", "Interceptor",},

    country_of_origin   = "USA",

    -- Mass Properties (in kg)
    M_empty             = 71700,    -- 158,000 lb empty
    M_nominal           = 125000,   -- Nominal operational weight
    M_max               = 170600,   -- 376,000 lb MTOW
    M_fuel_max          = 75750,    -- 167,000 lb internal fuel capacity
    H_max               = 15240,    -- 50,000 ft service ceiling
    average_fuel_consumption = 1.25,

    -- Flight Envelope
    CAS_min             = 130 / 3.6,
    V_opt               = 240,       -- High altitude cruise speed (m/s)
    V_take_off          = 160 / 3.6, -- Takeoff speed (m/s)
    V_land              = 140 / 3.6, -- Landing speed (m/s)
    V_max_sea_level     = 850 / 3.6, -- 530 knots at sea level
    V_max_h             = 950 / 3.6, -- High subsonic
    Vy_max              = 25,        -- Initial climb rate (m/s)
    Mach_max            = 0.95,      -- High subsonic limit
    Ny_min              = -1.0,
    Ny_max              = 3.0,
    Ny_max_e            = 2.5,
    AOA_take_off        = 6.0 / 57.3,
    bank_angle_max      = 60,

    -- Propulsion
    has_afteburner      = false,
    has_speedbrake      = true,
    has_differential_stabilizer = true,

    -- Undercarriage Geometry (calibrated from 3D model)
    nose_gear_pos       = {6.80, -2.35,  0.00},
    main_gear_pos       = {-1.80, -2.35,  3.70},

    nose_gear_amortizer_direct_stroke        = 0.0,
    nose_gear_amortizer_reversal_stroke      = -0.35,
    nose_gear_amortizer_normal_weight_stroke = -0.20,

    main_gear_amortizer_direct_stroke        = 0.0,
    main_gear_amortizer_reversal_stroke      = -0.40,
    main_gear_amortizer_normal_weight_stroke = -0.22,

    nose_gear_wheel_diameter = 0.65,
    main_gear_wheel_diameter = 1.05,
    tand_gear_max            = 0.577,

    -- Flying Wing Aerodynamics Geometry
    wing_area           = 478.0,  -- 5,140 sq ft wing area
    wing_span           = 52.42,  -- 172 ft wingspan
    wing_type           = 0,
    length              = 21.0,   -- 69 ft length
    height              = 5.18,   -- 17 ft height
    flaps_maneuver      = 0.5,
    range               = 11100,  -- 6,000 nautical miles unrefueled
    
    -- Stealth Low-Observable Parameters
    RCS                 = 0.0001, -- Ultra-low radar cross-section
    IR_emission_coeff   = 0.08,   -- Heavily shielded exhaust mixing
    IR_emission_coeff_ab = 0,     -- No afterburner

    wing_tip_pos        = {-11.3, 0.20, 26.21},
    brakeshute_name     = 0,

    -- 4x General Electric F118-GE-100 Non-Afterburning Turbofans
    engines_count       = 4,
    engines_nozzles = {
        [1] = { pos = {-4.50, 0.40, -4.20}, elevation = 0, diameter = 0.65, engine_number = 1 },
        [2] = { pos = {-4.50, 0.40, -3.20}, elevation = 0, diameter = 0.65, engine_number = 2 },
        [3] = { pos = {-4.50, 0.40,  3.20}, elevation = 0, diameter = 0.65, engine_number = 3 },
        [4] = { pos = {-4.50, 0.40,  4.20}, elevation = 0, diameter = 0.65, engine_number = 4 },
    },

    thrust_sum_max      = 31400, -- kgf (~308 kN / 69,200 lbf total dry thrust)
    thrust_sum_ab       = 31400,

    crew_size           = 2,
    HumanCockpit        = true,
    HumanCockpitPath    = current_mod_path..'/Cockpit/Scripts/',
    crew_members = {
        [1] = {
            ejection_seat_name = 0,
            drop_canopy_name   = 0,
            pos                = {6.80, 1.85, -0.65}, -- Pilot (Left Seat)
            can_be_playable    = true,
            role               = "pilot",
            role_display_name  = _("Pilot in Command"),
            g_suit             = 5.0,
        },
        [2] = {
            ejection_seat_name = 0,
            drop_canopy_name   = 0,
            pos                = {6.80, 1.85, 0.65}, -- Mission Commander (Right Seat)
            can_be_playable    = true,
            role               = "instructor",
            role_display_name  = _("Mission Commander"),
            g_suit             = 5.0,
        },
    },

    fires_pos = {
        [1] = {-4.50, 0.40, -3.70},
        [2] = {-4.50, 0.40,  3.70},
        [3] = { 0.00, 0.00,  0.00},
    },

    singleInFlight      = false,
    radar_can_see_ground = true,
    detection_range_max = 160000, -- AN/APG-181 SAR range
    CanopyGeometry = {
        azimuth   = {-160.0, 160.0},
        elevation = {-40.0, 90.0},
    },

    Sensors = {
        RADAR = "AN/APG-63",
        OPTIC = {"TADS DTV", "TADS FLIR"},
        RWR   = "Abstract RWR",
    },

    laserEquipment = {
        laserDesignator = true,
    },

    -- Dual Internal Weapons Rotary Launchers (Left and Right Bays)
    Pylons = {
        -- Left Internal Rotary Launcher Bay (Station 1)
        pylon(1, 0, 0.50, -0.80, -1.35, {arg = 86, arg_value = 1, use_full_connector_position = true}, {
            { CLSID = "{GBU-31}" },
            { CLSID = "{GBU-38}" },
            { CLSID = "{DB769D48-67D7-42ED-A2BE-108D566C8B1E}" }, -- GBU-12
        }),
        -- Right Internal Rotary Launcher Bay (Station 2)
        pylon(2, 0, 0.50, -0.80, 1.35, {arg = 87, arg_value = 1, use_full_connector_position = true}, {
            { CLSID = "{GBU-31}" },
            { CLSID = "{GBU-38}" },
            { CLSID = "{DB769D48-67D7-42ED-A2BE-108D566C8B1E}" }, -- GBU-12
        }),
    },

    EPLRS = true,
    Tasks = {
        aircraft_task(CAS),
        aircraft_task(GroundAttack),
        aircraft_task(PinpointStrike),
        aircraft_task(RunwayAttack),
        aircraft_task(AFAC),
        aircraft_task(Reconnaissance),
        aircraft_task(Escort),
        aircraft_task(CAP),
        aircraft_task(FighterSweep),
        aircraft_task(Intercept),
    },
    DefaultTask = aircraft_task(CAS),

    -- Standard Flight Model (SFM) Calibrated for B-2 Flying Wing
    SFM_Data = {
        aerodynamics = {
            Cy0         = 0.22,
            Mzalfa      = 4.5,
            Mzalfadt    = 0.9,
            kjx         = 2.20,
            kjz         = 0.0011,
            Czbe        = -0.015,
            cx_gear     = 0.0035,
            cx_flap     = 0.012,
            cy_flap     = 0.35,
            cx_brk      = 0.035,
            table_data = {
                --  M       Cx0     Cya     B       B4      Omxmax  Aldop   Cymax
                { 0.0,    0.0150, 0.085,  0.0240, 0.0001, 0.8,    18,     1.35 },
                { 0.2,    0.0152, 0.085,  0.0240, 0.0001, 0.8,    18,     1.35 },
                { 0.4,    0.0155, 0.085,  0.0240, 0.0001, 0.8,    18,     1.35 },
                { 0.6,    0.0160, 0.085,  0.0240, 0.0001, 0.8,    18,     1.35 },
                { 0.8,    0.0175, 0.085,  0.0240, 0.0001, 0.8,    18,     1.35 },
                { 0.85,   0.0200, 0.083,  0.0250, 0.0002, 0.7,    17,     1.30 },
                { 0.90,   0.0280, 0.080,  0.0280, 0.0004, 0.6,    16,     1.20 },
                { 0.95,   0.0450, 0.075,  0.0320, 0.0008, 0.5,    14,     1.05 },
                { 1.05,   0.0800, 0.065,  0.0400, 0.0015, 0.4,    12,     0.90 },
            },
        },
        engine = {
            Nmg         = 24.0,
            MinRUD      = 0,
            MaxRUD      = 1,
            MaksRUD     = 1,
            ForsRUD     = 1,
            type        = "TurboFan", -- Must be PascalCase "TurboFan"
            hMaxEng     = 16.0,
            dcx_eng     = 0.012,
            cemax       = 0.45,
            cefor       = 0.45,
            dpdh_m      = 6000,
            dpdh_f      = 6000,
            table_data = {
                -- M      Pmax (N)    Pfor (N)
                { 0.0,    308000,     308000 },
                { 0.2,    305000,     305000 },
                { 0.4,    300000,     300000 },
                { 0.6,    295000,     295000 },
                { 0.8,    285000,     285000 },
                { 0.95,   270000,     270000 },
            },
        },
    },

    ViewSettings = ViewSettings,

    HumanRadio = {
        frequency    = 124.0,
        editable     = true,
        minFrequency = 118,
        maxFrequency = 143.975,
        modulation   = MODULATION_AM,
    },
    panelRadio = {
        [1] = {
            name     = _("VHF AM Radio"),
            range    = {{min = 118.0, max = 143.975}},
            channels = {
                [1] = { name = _("Channel 1"), default = 124.0, modulation = _("AM") },
            },
        },
    },
    Countries = {"USA", "USAF Aggressors", "UK", "France", "Germany", "Italy", "Israel", "Australia", "Canada"},
}

add_aircraft(B_2_Spirit)
print(">>> [B-2 Spirit] add_aircraft(B_2_Spirit) called successfully.")

-- Explicit Country Registration
-- add_aircraft() reads B_2_Spirit.Countries, but if this module loads after a
-- country's unit database has already been cached, the aircraft can silently
-- fail to appear in the Mission Editor's TYPE dropdown for that country.
-- Guard against that by injecting the unit directly if it is missing.
local countries_to_add = {"USA", "USAF Aggressors", "UK", "France", "Germany", "Italy", "Israel", "Australia", "Canada"}
for _, c_name in ipairs(countries_to_add) do
    local c = nil
    if country and country.get then
        c = country:get(c_name)
    end
    if not c and db and db.CountriesByName then
        c = db.CountriesByName[c_name]
    end
    if c and c.Units and c.Units.Planes and c.Units.Planes.Plane then
        local found = false
        for _, p in pairs(c.Units.Planes.Plane) do
            if p.Name == "B-2_Spirit" then
                found = true
                break
            end
        end
        if not found then
            table.insert(c.Units.Planes.Plane, {
                Name = "B-2_Spirit",
                in_service = 0,
                out_of_service = 40000.0,
            })
        end
    end
end


