--[[
    B-2 SPIRIT PUBLIC-REFERENCE COCKPIT — FUEL SUBSYSTEM (FUEL)
    Reference-backed reconstruction based on publicly available imagery and USAF documentation
    
    PROVENANCE CLASSIFICATION:
    - REFERENCE_BACKED: 
        * B-2 internal fuel capacity: ~167,000 lbs (75,750 kg) JP-8.
        * Multi-cell tank arrangement comprising wing tanks and center fuselage tanks.
    - PUBLIC_TECHNICAL_INFERENCE:
        * 4-tank logical grouping: Left Wing, Right Wing, Forward Center, Aft Center (approx 41,750 lbs each).
        * AC motor-driven submerged boost pumps generating ~35 PSI manifold head.
        * Boost pump electrical dependency on AC Bus 1–4.
        * Crossfeed valve isolating or linking left and right wing collector boxes.
    - DCS_SIMULATION_ABSTRACTION:
        * Consumption integration tied to engine burn rates from SYSTEM_BUS.

    ARCHITECTURAL PRINCIPLE:
    "The display never owns the aircraft state."
    Fuel_System owns fuel fluid physics and publishes live telemetry to SYSTEM_BUS.
--]]

dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/system_bus.lua")

local dev = GetSelf()
local update_time_step = 0.05 -- 20 Hz fuel simulation loop
make_default_activity(update_time_step)

-- Tank Quantities (Pounds)
local MAX_TOTAL_FUEL = 167000.0
local tank_l_wing    = 41750.0
local tank_r_wing    = 41750.0
local tank_fwd_ctr   = 41750.0
local tank_aft_ctr   = 41750.0

-- Boost Pumps & Valves State
local boost_pumps_switch = 1     -- 1: AUTO/ON, 0: OFF
local crossfeed_switch   = 0     -- 0: CLOSED, 1: OPEN
local manifold_psi       = 0.0   -- 0..35 PSI
local total_fuel_flow    = 0.0   -- lbs/hr

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth == "GROUND_HOT" or birth == "AIR_HOT" then
        boost_pumps_switch = 1
        crossfeed_switch   = 0
    else
        boost_pumps_switch = 1   -- Normal position in B-2 checklists is AUTO
        crossfeed_switch   = 0
    end
    update_fuel_state(0.0)
end

function SetCommand(command, value)
    -- System bus or clickable commands for fuel
    if command == 4001 then -- Toggle boost pumps
        boost_pumps_switch = (boost_pumps_switch == 1) and 0 or 1
    elseif command == 4002 then -- Toggle crossfeed
        crossfeed_switch = (crossfeed_switch == 1) and 0 or 1
    end
end

function update()
    local dt = update_time_step
    update_fuel_state(dt)
end

function update_fuel_state(dt)
    -- 1. Check Electrical Bus Power for AC Boost Pumps
    local elec = SYSTEM_BUS.get_domain("elec") or {}
    local ac_powered = (elec.ac_bus_1_v and elec.ac_bus_1_v > 100.0) or
                       (elec.ac_bus_2_v and elec.ac_bus_2_v > 100.0) or
                       (elec.ac_bus_3_v and elec.ac_bus_3_v > 100.0) or
                       (elec.ac_bus_4_v and elec.ac_bus_4_v > 100.0)

    -- 2. Manifold Pressure Physics
    local has_fuel = (tank_l_wing + tank_r_wing + tank_fwd_ctr + tank_aft_ctr) > 100.0
    if boost_pumps_switch == 1 and ac_powered and has_fuel then
        manifold_psi = 35.0 -- Nominal pressurized fuel feed (PUBLIC_TECHNICAL_INFERENCE)
    elseif has_fuel then
        -- Unpowered gravity feed / suction head: ~5.0 PSI (sufficient only for low altitude / low power)
        manifold_psi = 5.0
    else
        manifold_psi = 0.0
    end

    -- 3. Fuel Consumption from 4 F118 Turbofans
    local engines = SYSTEM_BUS.get_domain("engines") or {}
    local ff1 = (engines[1] and engines[1].ff) or 0.0
    local ff2 = (engines[2] and engines[2].ff) or 0.0
    local ff3 = (engines[3] and engines[3].ff) or 0.0
    local ff4 = (engines[4] and engines[4].ff) or 0.0

    total_fuel_flow = ff1 + ff2 + ff3 + ff4 -- lbs/hr
    local burned_lbs = (total_fuel_flow / 3600.0) * dt

    if burned_lbs > 0.0 then
        -- Burn sequence: Center tanks first (CG management), then wing tanks
        local center_fuel = tank_fwd_ctr + tank_aft_ctr
        if center_fuel > 2000.0 then
            local half_burn = burned_lbs * 0.5
            tank_fwd_ctr = math.max(0.0, tank_fwd_ctr - half_burn)
            tank_aft_ctr = math.max(0.0, tank_aft_ctr - half_burn)
        else
            -- Burn from wing tanks (Left: Eng 1 & 2, Right: Eng 3 & 4)
            local l_burn = ((ff1 + ff2) / 3600.0) * dt
            local r_burn = ((ff3 + ff4) / 3600.0) * dt
            if crossfeed_switch == 1 then
                local avg_burn = burned_lbs * 0.5
                tank_l_wing = math.max(0.0, tank_l_wing - avg_burn)
                tank_r_wing = math.max(0.0, tank_r_wing - avg_burn)
            else
                tank_l_wing = math.max(0.0, tank_l_wing - l_burn)
                tank_r_wing = math.max(0.0, tank_r_wing - r_burn)
            end
        end
    end

    local total_lbs = tank_l_wing + tank_r_wing + tank_fwd_ctr + tank_aft_ctr

    local p_total_fuel = get_param_handle("TOTAL_FUEL_LBS")
    if p_total_fuel then
        p_total_fuel:set(total_lbs)
    end

    -- 4. Caution / Advisory Matrix
    SYSTEM_BUS.set_caution("FUEL_LOW", total_lbs < 15000.0, "LOW FUEL QUANTITY", "WARNING")
    SYSTEM_BUS.set_caution("FUEL_PRESS_LOW", manifold_psi < 10.0, "FUEL BOOST PRESS LOW", "CAUTION")
    local imbalance = math.abs(tank_l_wing - tank_r_wing)
    SYSTEM_BUS.set_caution("FUEL_IMBALANCE", imbalance > 3000.0, "WING FUEL IMBALANCE", "ADVISORY")

    -- 5. Publish to Central System Data Bus
    SYSTEM_BUS.publish_batch("fuel", {
        total_lbs      = total_lbs,
        tank_l_wing    = tank_l_wing,
        tank_r_wing    = tank_r_wing,
        tank_fwd_ctr   = tank_fwd_ctr,
        tank_aft_ctr   = tank_aft_ctr,
        boost_pumps_on = (boost_pumps_switch == 1 and ac_powered),
        manifold_psi   = manifold_psi,
        crossfeed_open = (crossfeed_switch == 1),
        fuel_flow_pph  = total_fuel_flow
    })
end

need_to_be_closed = false
