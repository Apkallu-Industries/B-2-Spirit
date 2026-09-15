--[[
    B-2 SPIRIT PUBLIC-REFERENCE COCKPIT — CENTRAL SYSTEM DATA BUS
    Reference-backed reconstruction based on publicly available imagery and USAF documentation
    
    ARCHITECTURAL PRINCIPLE:
    "The display never owns the aircraft state."
    
    FLOW OF AUTHORITY:
    Aircraft Subsystems (State Owners)
               ↓
    Central System Data Bus (Message Broker & State Repository)
               ↓
    MDU Page Controllers (Observers)
               ↓
    Cockpit Displays (ccIndicator Render Targets)

    PROVENANCE CLASSIFICATION:
    - PUBLIC_TECHNICAL_INFERENCE: Central avionics bus architecture mirroring MIL-STD-1553B / 1760 bus data distribution on B-2 Block 30.
    - DCS_SIMULATION_ABSTRACTION: Low-latency Lua shared state table with publish/subscribe event dispatch.
--]]

SYSTEM_BUS = SYSTEM_BUS or {}

-- Provenance Metadata
SYSTEM_BUS.PROVENANCE = {
    ARCHITECTURE = "PUBLIC_TECHNICAL_INFERENCE",
    SIM_LAYER    = "DCS_SIMULATION_ABSTRACTION"
}

-- Domain State Repository
SYSTEM_BUS.STATE = {
    elec = {
        battery_switch = 0,         -- 0: OFF, 1: ON (REFERENCE_BACKED)
        battery_volts  = 0.0,       -- 24.0V nominal (REFERENCE_BACKED)
        apu_switch     = 0,         -- -1: OFF, 0: STBY, 1: START (REFERENCE_BACKED)
        apu_running    = false,
        apu_rpm        = 0.0,       -- 0..100%
        apu_gen_volts  = 0.0,       -- 115V AC nominal (REFERENCE_BACKED)
        apu_gen_online = false,
        dc_ess_bus_v   = 0.0,       -- 28V DC nominal
        ac_ess_bus_v   = 0.0,       -- 115V AC nominal
        ac_bus_1_v     = 0.0,       -- 115V AC nominal
        ac_bus_2_v     = 0.0,
        ac_bus_3_v     = 0.0,
        ac_bus_4_v     = 0.0,
        gen1_switch    = 0,         -- Left Gen switch
        gen2_switch    = 0,
        gen3_switch    = 0,
        gen4_switch    = 0,         -- Right Gen switch
        gen1_online    = false,
        gen2_online    = false,
        gen3_online    = false,
        gen4_online    = false,
        tie_bus_closed = false
    },
    fuel = {
        total_lbs      = 167000.0,  -- B-2 capacity ~167,000 lbs (REFERENCE_BACKED)
        tank_l_wing    = 41750.0,
        tank_r_wing    = 41750.0,
        tank_fwd_ctr   = 41750.0,
        tank_aft_ctr   = 41750.0,
        boost_pumps_on = false,
        manifold_psi   = 0.0,       -- 35 PSI nominal with boost pumps (PUBLIC_TECHNICAL_INFERENCE)
        crossfeed_open = false,
        dump_active    = false,
        fuel_flow_pph  = 0.0
    },
    engines = {
        [1] = { state = 0, n1 = 0.0, n2 = 0.0, egt = 15.0, ff = 0.0, oil_psi = 0.0, starter = false, gen = false },
        [2] = { state = 0, n1 = 0.0, n2 = 0.0, egt = 15.0, ff = 0.0, oil_psi = 0.0, starter = false, gen = false },
        [3] = { state = 0, n1 = 0.0, n2 = 0.0, egt = 15.0, ff = 0.0, oil_psi = 0.0, starter = false, gen = false },
        [4] = { state = 0, n1 = 0.0, n2 = 0.0, egt = 15.0, ff = 0.0, oil_psi = 0.0, starter = false, gen = false },
        throttle_left  = 0.0,       -- Engines 1 & 2
        throttle_right = 0.0        -- Engines 3 & 4
    },
    flight = {
        pitch          = 0.0,       -- radians
        bank           = 0.0,       -- radians
        heading        = 0.0,       -- radians
        heading_deg    = 0.0,
        ias_knots      = 0.0,
        mach           = 0.0,
        alt_baro_ft    = 0.0,
        alt_rad_ft     = 0.0,
        vvi_fpm        = 0.0,
        aoa_deg        = 0.0,
        aos_deg        = 0.0,
        g_force        = 1.0,
        baro_setting   = 29.92      -- inHg
    }
}

-- Caution and Warning Annunciation Matrix
SYSTEM_BUS.CAUTIONS = {}

-- Subscribers Registry
local subscribers = {}

-- Publish single parameter
function SYSTEM_BUS.publish(domain, key, value)
    if not SYSTEM_BUS.STATE[domain] then
        SYSTEM_BUS.STATE[domain] = {}
    end
    SYSTEM_BUS.STATE[domain][key] = value

    local subs = subscribers[domain]
    if subs then
        for _, callback in ipairs(subs) do
            callback(key, value)
        end
    end
end

-- Publish batch parameters
function SYSTEM_BUS.publish_batch(domain, data)
    if not SYSTEM_BUS.STATE[domain] then
        SYSTEM_BUS.STATE[domain] = {}
    end
    for k, v in pairs(data) do
        SYSTEM_BUS.STATE[domain][k] = v
    end

    local subs = subscribers[domain]
    if subs then
        for _, callback in ipairs(subs) do
            for k, v in pairs(data) do
                callback(k, v)
            end
        end
    end
end

-- Read single parameter
function SYSTEM_BUS.get(domain, key, default)
    if SYSTEM_BUS.STATE[domain] and SYSTEM_BUS.STATE[domain][key] ~= nil then
        return SYSTEM_BUS.STATE[domain][key]
    end
    return default
end

-- Read entire domain table
function SYSTEM_BUS.get_domain(domain)
    return SYSTEM_BUS.STATE[domain]
end

-- Subscribe to domain updates
function SYSTEM_BUS.subscribe(domain, callback)
    subscribers[domain] = subscribers[domain] or {}
    table.insert(subscribers[domain], callback)
end

-- Caution and Warning Management
function SYSTEM_BUS.set_caution(key, active, message, severity)
    if active then
        SYSTEM_BUS.CAUTIONS[key] = {
            message  = message or key,
            severity = severity or "CAUTION", -- "WARNING", "CAUTION", "ADVISORY"
            time     = os.time()
        }
    else
        SYSTEM_BUS.CAUTIONS[key] = nil
    end
end

function SYSTEM_BUS.get_cautions()
    return SYSTEM_BUS.CAUTIONS
end

return SYSTEM_BUS
