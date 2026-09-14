--[[
    B-2 SPIRIT PUBLIC-REFERENCE COCKPIT — ELECTRICAL SUBSYSTEM (ELEC)
    Reference-backed reconstruction based on publicly available imagery and USAF documentation
    
    PROVENANCE CLASSIFICATION:
    - REFERENCE_BACKED: 
        * B-2 24V DC emergency battery and 115V AC 400Hz 4-channel primary electrical generation.
        * 4 engine-driven generators (Gen 1–4) matching 4x F118-GE-100 engines.
        * Dual cockpit Gen switches (L GEN controls Gen 1/2, R GEN controls Gen 3/4).
    - PUBLIC_TECHNICAL_INFERENCE:
        * Generator cut-in threshold at 58% N2 core RPM based on accessory gearbox drive ratios.
        * Bus tie contactors auto-closing when single generator is online.
        * APU generator cut-in at 95% APU RPM.
    - DCS_SIMULATION_ABSTRACTION:
        * Re-entrancy guarded SetCommand dispatch and parameter handles.

    ARCHITECTURAL PRINCIPLE:
    "The display never owns the aircraft state."
    Electrical_System owns electrical physics and publishes live telemetry to SYSTEM_BUS.
--]]

dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/system_bus.lua")

local dev = GetSelf()
local sensor_data = get_base_data()

local update_time_step = 0.02 -- 50 Hz electrical simulation loop
make_default_activity(update_time_step)

-- DCS Parameter Handles
local params = {
    BATTERY_POWER    = get_param_handle("BATTERY_POWER"),
    APU_POWER        = get_param_handle("APU_POWER"),
    MAIN_POWER       = get_param_handle("MAIN_POWER"),
    APU_RPM_STATE    = get_param_handle("APU_RPM_STATE"),
    L_GEN_POWER      = get_param_handle("L_GEN_POWER"),
    R_GEN_POWER      = get_param_handle("R_GEN_POWER"),
    AAR              = get_param_handle("AAR"),
    AAR_KNOB         = get_param_handle("AAR_KNOB"),
    FORM_KNOB        = get_param_handle("FORM_KNOB"),
    TAXI_SWITCH      = get_param_handle("TAXI_SWITCH"),
    NAV_LIGHT_SWITCH = get_param_handle("NAV_LIGHT_SWITCH"),
    AAR_READY        = get_param_handle("AAR_READY"),
}

-- Command IDs
local PlaneAirRefuel = Keys.PlaneAirRefuel
local PowerOnOff     = Keys.PowerOnOff

-- Cockpit Clickable Commands (from clickabledata.lua)
-- Note: BATTERY_PNT, APU_PNT, LGEN_PNT, RGEN_PNT can be sent to ENGINE_SYSTEM or ELECTRICAL_SYSTEM
local CMD_BATTERY   = device_commands.Button_1
local CMD_APU       = device_commands.Button_2
local CMD_L_GEN     = device_commands.Button_3
local CMD_R_GEN     = device_commands.Button_4
local CMD_AAR_SW    = device_commands.Button_5 or 3005
local CMD_AAR_LIGHT = device_commands.Button_6 or 3006
local CMD_TAXI_LT   = device_commands.Button_7 or 3007
local CMD_FORM_LT   = device_commands.Button_8 or 3008

-- Register Listeners
dev:listen_command(PowerOnOff)
dev:listen_command(CMD_BATTERY)
dev:listen_command(CMD_APU)
dev:listen_command(CMD_L_GEN)
dev:listen_command(CMD_R_GEN)
dev:listen_command(10009) -- BAT ON
dev:listen_command(10010) -- BAT TOGGLE
dev:listen_command(10011) -- L GEN ON
dev:listen_command(10012) -- L GEN TOGGLE
dev:listen_command(10013) -- R GEN ON
dev:listen_command(10014) -- R GEN TOGGLE
dev:listen_command(10025) -- APU TOGGLE
dev:listen_command(PlaneAirRefuel)

-- Subsystem State Variables
local battery_switch   = 0     -- 0: OFF, 1: ON
local battery_charge   = 1.0   -- 100% capacity
local battery_volts    = 0.0

local apu_switch_state = 0     -- -1: OFF, 0: STBY, 1: START
local apu_rpm          = 0.0
local apu_gen_online   = false

local l_gen_switch     = 0     -- Controls Gen 1 & Gen 2
local r_gen_switch     = 0     -- Controls Gen 3 & Gen 4
local gen1_online      = false
local gen2_online      = false
local gen3_online      = false
local gen4_online      = false

local dc_ess_bus_v     = 0.0
local ac_ess_bus_v     = 0.0
local ac_bus_1_v       = 0.0
local ac_bus_2_v       = 0.0
local ac_bus_3_v       = 0.0
local ac_bus_4_v       = 0.0
local tie_bus_closed   = true

local aar_state        = 0
local aar_knob         = 0.5
local form_knob        = 0.5
local light_state      = 0

local in_set_command   = false

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth == "GROUND_HOT" or birth == "AIR_HOT" then
        battery_switch   = 1
        l_gen_switch     = 1
        r_gen_switch     = 1
        apu_switch_state = -1
        apu_rpm          = 0.0
        dc_ess_bus_v     = 28.0
        ac_ess_bus_v     = 115.0
        ac_bus_1_v       = 115.0
        ac_bus_2_v       = 115.0
        ac_bus_3_v       = 115.0
        ac_bus_4_v       = 115.0
    else
        battery_switch   = 0
        l_gen_switch     = 0
        r_gen_switch     = 0
        apu_switch_state = -1
        apu_rpm          = 0.0
        dc_ess_bus_v     = 0.0
        ac_ess_bus_v     = 0.0
        ac_bus_1_v       = 0.0
        ac_bus_2_v       = 0.0
        ac_bus_3_v       = 0.0
        ac_bus_4_v       = 0.0
    end
    
    aar_state = 0
    params.BATTERY_POWER:set(battery_switch)
    params.MAIN_POWER:set(ac_ess_bus_v > 100.0 and 1 or 0)
    params.APU_POWER:set(0)
    params.AAR:set(0)
    params.AAR_KNOB:set(aar_knob)
    params.FORM_KNOB:set(form_knob)

    publish_telemetry()
end

function SetCommand(command, value)
    if in_set_command then return end
    in_set_command = true

    -- Battery Switch
    if command == CMD_BATTERY then
        battery_switch = (value > 0) and 1 or 0
    elseif command == 10009 then
        battery_switch = 1
    elseif command == 10010 then
        battery_switch = (battery_switch == 1) and 0 or 1
    elseif command == PowerOnOff then
        battery_switch = (battery_switch == 1) and 0 or 1
    end

    -- APU Switch (Start / Off)
    if command == CMD_APU or command == 10025 then
        if apu_switch_state <= 0 then
            apu_switch_state = 1 -- START command
        else
            apu_switch_state = -1 -- OFF command
        end
    end

    -- Generator Switches
    if command == CMD_L_GEN then
        l_gen_switch = (value > 0) and 1 or 0
    elseif command == 10011 then
        l_gen_switch = 1
    elseif command == 10012 then
        l_gen_switch = (l_gen_switch == 1) and 0 or 1
    end

    if command == CMD_R_GEN then
        r_gen_switch = (value > 0) and 1 or 0
    elseif command == 10013 then
        r_gen_switch = 1
    elseif command == 10014 then
        r_gen_switch = (r_gen_switch == 1) and 0 or 1
    end

    -- Air Refueling Switch
    local AAR_SWITCH = CMD_AAR_SW
    if command == PlaneAirRefuel or command == AAR_SWITCH or command == 10015 or command == 10016 then
        aar_state = (aar_state == 0) and 1 or 0
        if command ~= AAR_SWITCH then
            if dev and dev.performClickableAction then
                dev:performClickableAction(AAR_SWITCH, aar_state, false)
            end
        end
        params.AAR:set(aar_state)
    end

    in_set_command = false
end

function update()
    local dt = update_time_step

    -- 1. Battery Voltage & DC Essential Bus
    if battery_switch == 1 and battery_charge > 0.05 then
        battery_volts = 24.0 * math.max(0.8, battery_charge)
        dc_ess_bus_v  = 28.0 -- Powered via TRU or battery
        -- Drain battery slightly when no AC generation is present
        if ac_ess_bus_v < 50.0 then
            battery_charge = math.max(0.0, battery_charge - (dt / 7200.0)) -- 2 hours emergency runtime
        else
            battery_charge = math.min(1.0, battery_charge + (dt / 1800.0)) -- Recharge via TRU
        end
    else
        battery_volts = 0.0
        dc_ess_bus_v  = (ac_ess_bus_v > 100.0) and 28.0 or 0.0
    end

    -- 2. APU Spoolup Physics & APU Generator
    if apu_switch_state == 1 then
        if dc_ess_bus_v >= 18.0 then
            apu_rpm = math.min(100.0, apu_rpm + (dt * 15.0)) -- Spools up in ~6.6 seconds
            if apu_rpm >= 95.0 then
                apu_gen_online = true
            end
        else
            -- Cannot start APU without DC power
            apu_switch_state = -1
        end
    else
        apu_rpm = math.max(0.0, apu_rpm - (dt * 20.0))
        apu_gen_online = false
    end

    -- 3. Engine Generators (Observe Engine Core RPM from SYSTEM_BUS)
    local engines = SYSTEM_BUS.get_domain("engines") or {}
    local eng1_n2 = engines[1] and engines[1].n2 or 0.0
    local eng2_n2 = engines[2] and engines[2].n2 or 0.0
    local eng3_n2 = engines[3] and engines[3].n2 or 0.0
    local eng4_n2 = engines[4] and engines[4].n2 or 0.0

    -- Gen cut-in threshold: 58% N2 (PUBLIC_TECHNICAL_INFERENCE)
    gen1_online = (l_gen_switch == 1) and (eng1_n2 >= 58.0)
    gen2_online = (l_gen_switch == 1) and (eng2_n2 >= 58.0)
    gen3_online = (r_gen_switch == 1) and (eng3_n2 >= 58.0)
    gen4_online = (r_gen_switch == 1) and (eng4_n2 >= 58.0)

    -- 4. AC Distribution Network & Bus Ties
    local ac_source_online = gen1_online or gen2_online or gen3_online or gen4_online or apu_gen_online
    local primary_ac_volts = ac_source_online and 115.0 or 0.0

    -- Bus Ties: With any AC generator online, tie contactors energize all active channels
    ac_bus_1_v = (gen1_online or (tie_bus_closed and ac_source_online)) and 115.0 or 0.0
    ac_bus_2_v = (gen2_online or (tie_bus_closed and ac_source_online)) and 115.0 or 0.0
    ac_bus_3_v = (gen3_online or (tie_bus_closed and ac_source_online)) and 115.0 or 0.0
    ac_bus_4_v = (gen4_online or (tie_bus_closed and ac_source_online)) and 115.0 or 0.0
    ac_ess_bus_v = primary_ac_volts

    -- 5. Set DCS Param Handles
    params.BATTERY_POWER:set(battery_switch)
    params.APU_POWER:set(apu_gen_online and 1 or 0)
    params.APU_RPM_STATE:set(apu_rpm / 100.0)
    params.L_GEN_POWER:set((gen1_online or gen2_online) and 1 or 0)
    params.R_GEN_POWER:set((gen3_online or gen4_online) and 1 or 0)
    params.MAIN_POWER:set((ac_ess_bus_v > 100.0 or dc_ess_bus_v > 20.0) and 1 or 0)

    -- 6. Annunciator Matrix & Cautions
    SYSTEM_BUS.set_caution("BATT_OFF", battery_switch == 0, "BATTERY SWITCH OFF", "CAUTION")
    SYSTEM_BUS.set_caution("ELEC_DISCHARGE", (battery_switch == 1 and not ac_source_online), "MAIN BATTERY DISCHARGING", "CAUTION")
    SYSTEM_BUS.set_caution("GEN1_OFF", not gen1_online, "GENERATOR 1 OFFLINE", "ADVISORY")
    SYSTEM_BUS.set_caution("GEN2_OFF", not gen2_online, "GENERATOR 2 OFFLINE", "ADVISORY")
    SYSTEM_BUS.set_caution("GEN3_OFF", not gen3_online, "GENERATOR 3 OFFLINE", "ADVISORY")
    SYSTEM_BUS.set_caution("GEN4_OFF", not gen4_online, "GENERATOR 4 OFFLINE", "ADVISORY")

    publish_telemetry()
end

function publish_telemetry()
    SYSTEM_BUS.publish_batch("elec", {
        active_simulation = true,
        battery_switch = battery_switch,
        battery_volts  = battery_volts,
        apu_switch     = apu_switch_state,
        apu_running    = (apu_rpm >= 95.0),
        apu_rpm        = apu_rpm,
        apu_gen_volts  = apu_gen_online and 115.0 or 0.0,
        apu_gen_online = apu_gen_online,
        dc_ess_bus_v   = dc_ess_bus_v,
        ac_ess_bus_v   = ac_ess_bus_v,
        ac_bus_1_v     = ac_bus_1_v,
        ac_bus_2_v     = ac_bus_2_v,
        ac_bus_3_v     = ac_bus_3_v,
        ac_bus_4_v     = ac_bus_4_v,
        gen1_switch    = l_gen_switch,
        gen2_switch    = l_gen_switch,
        gen3_switch    = r_gen_switch,
        gen4_switch    = r_gen_switch,
        gen1_online    = gen1_online,
        gen2_online    = gen2_online,
        gen3_online    = gen3_online,
        gen4_online    = gen4_online,
        tie_bus_closed = tie_bus_closed
    })
end

need_to_be_closed = false