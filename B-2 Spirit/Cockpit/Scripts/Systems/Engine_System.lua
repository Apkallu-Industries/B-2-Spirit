--[[
    B-2 SPIRIT PUBLIC-REFERENCE COCKPIT — ENGINE SUBSYSTEM (ENG)
    Reference-backed reconstruction based on publicly available imagery and USAF documentation
    
    PROVENANCE CLASSIFICATION:
    - REFERENCE_BACKED: 
        * 4x General Electric F118-GE-100 non-afterburning turbofan engines (approx 19,000 lbf each).
        * F118 turbofan parameters: N1 fan %, N2 core %, EGT °C, Fuel Flow (pph), Oil Pressure (PSI).
        * Throttle quadrant layout: Left lever (Engines 1 & 2), Right lever (Engines 3 & 4).
    - PUBLIC_TECHNICAL_INFERENCE:
        * Starter cut-out at 50% N2.
        * Generator cut-in at 58% N2.
        * Ground idle stabilization: N1 ~22%, N2 ~62%, EGT ~420°C, FF ~800 pph, Oil ~55 PSI.
        * Start dependency on APU bleed air, DC bus power for igniters, and pressurized fuel manifold.
    - DCS_SIMULATION_ABSTRACTION:
        * Aerodynamic thrust and gear/brake kinematics interfacing with DCS flight model.

    ARCHITECTURAL PRINCIPLE:
    "The display never owns the aircraft state."
    Engine_System owns engine thermodynamics/spool physics and publishes live telemetry to SYSTEM_BUS.
--]]

dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/system_bus.lua")

local dev = GetSelf()
local update_time_step = 0.024 -- ~40 Hz engine physics loop
make_default_activity(update_time_step)

local sensor_data = get_base_data()

-- Parameter Handles
local IAS            = get_param_handle("IAS")
local PARK           = get_param_handle("PARK")
local L_THROTTLE_POS = get_param_handle("L_THROTTLE_POS")
local R_THROTTLE_POS = get_param_handle("R_THROTTLE_POS")
local L_THROTTLE_CUT = get_param_handle("L_THROTTLE_CUT")
local R_THROTTLE_CUT = get_param_handle("R_THROTTLE_CUT")

-- EICAS Display Parameter Handles
local eicas_rpm = {
    get_param_handle("RPM_1"), get_param_handle("RPM_2"),
    get_param_handle("RPM_3"), get_param_handle("RPM_4")
}
local eicas_egt = {
    get_param_handle("EGT_1"), get_param_handle("EGT_2"),
    get_param_handle("EGT_3"), get_param_handle("EGT_4")
}
local eicas_ff = {
    get_param_handle("FF_1"), get_param_handle("FF_2"),
    get_param_handle("FF_3"), get_param_handle("FF_4")
}
local eicas_oil = {
    get_param_handle("OIL_1"), get_param_handle("OIL_2"),
    get_param_handle("OIL_3"), get_param_handle("OIL_4")
}

-- Commands
local EnginesStart   = Keys.EnginesStart
local EnginesStop    = Keys.EnginesStop
local L_Eng_Start    = Keys.LeftEngineStart
local R_Eng_Start    = Keys.RightEngineStart
local L_Eng_Stop     = Keys.LeftEngineStop
local R_Eng_Stop     = Keys.RightEngineStop
local PlaneGear      = Keys.PlaneGear

dev:listen_command(EnginesStart)
dev:listen_command(EnginesStop)
dev:listen_command(L_Eng_Start)
dev:listen_command(R_Eng_Start)
dev:listen_command(L_Eng_Stop)
dev:listen_command(R_Eng_Stop)
dev:listen_command(PlaneGear)

-- Clickable commands from clickabledata.lua
local CMD_L_ENG_CLICK = device_commands.Button_9
local CMD_R_ENG_CLICK = device_commands.Button_10
local CMD_GEAR_CLICK  = device_commands.Button_11
local CMD_PARK_BRAKE  = device_commands.Button_12
local CMD_EMER_GEAR   = 3500

dev:listen_command(CMD_L_ENG_CLICK)
dev:listen_command(CMD_R_ENG_CLICK)
dev:listen_command(CMD_GEAR_CLICK)
dev:listen_command(CMD_PARK_BRAKE)
dev:listen_command(CMD_EMER_GEAR)

-- Keybind commands
dev:listen_command(10019) -- Park Brake ON
dev:listen_command(10020) -- Park Brake OFF
dev:listen_command(10028) -- L Cutoff
dev:listen_command(10029) -- R Cutoff
dev:listen_command(2004)  -- Throttle Axis
dev:listen_command(2005)  -- L Throttle
dev:listen_command(2006)  -- R Throttle
dev:listen_command(74)    -- Brakes On
dev:listen_command(75)    -- Brakes Off

-- Engine Physical States (Engines 1..4)
-- State: 0 = SHUTDOWN, 1 = CRANKING, 2 = IGNITION/LIGHTOFF, 3 = RUNNING
local engines = {
    [1] = { state = 0, n1 = 0.0, n2 = 0.0, egt = 15.0, ff = 0.0, oil_psi = 0.0, starter = false, cutoff = 0 },
    [2] = { state = 0, n1 = 0.0, n2 = 0.0, egt = 15.0, ff = 0.0, oil_psi = 0.0, starter = false, cutoff = 0 },
    [3] = { state = 0, n1 = 0.0, n2 = 0.0, egt = 15.0, ff = 0.0, oil_psi = 0.0, starter = false, cutoff = 0 },
    [4] = { state = 0, n1 = 0.0, n2 = 0.0, egt = 15.0, ff = 0.0, oil_psi = 0.0, starter = false, cutoff = 0 }
}

local throttle_left  = 0.0 -- 0.0 (Idle) to 1.0 (Military power)
local throttle_right = 0.0
local park_brake_on  = true
local gear_down      = 1.0

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth == "GROUND_HOT" or birth == "AIR_HOT" then
        for i = 1, 4 do
            engines[i].state   = 3
            engines[i].n1      = 22.0
            engines[i].n2      = 62.0
            engines[i].egt     = 420.0
            engines[i].ff      = 800.0
            engines[i].oil_psi = 55.0
            engines[i].cutoff  = 1
        end
        park_brake_on = (birth == "GROUND_HOT")
        gear_down     = (birth == "GROUND_HOT") and 1.0 or 0.0
    else
        for i = 1, 4 do
            engines[i].state   = 0
            engines[i].n1      = 0.0
            engines[i].n2      = 0.0
            engines[i].egt     = 15.0
            engines[i].ff      = 0.0
            engines[i].oil_psi = 0.0
            engines[i].cutoff  = 0
        end
        park_brake_on = true
        gear_down     = 1.0
    end

    publish_telemetry()
end

function SetCommand(command, value)
    -- Left Engine Pair Start (Engines 1 & 2)
    if command == L_Eng_Start or command == CMD_L_ENG_CLICK then
        start_engine_pair(1, 2)
    elseif command == L_Eng_Stop or command == 10028 then
        stop_engine_pair(1, 2)
    end

    -- Right Engine Pair Start (Engines 3 & 4)
    if command == R_Eng_Start or command == CMD_R_ENG_CLICK then
        start_engine_pair(3, 4)
    elseif command == R_Eng_Stop or command == 10029 then
        stop_engine_pair(3, 4)
    end

    -- Master Start All
    if command == EnginesStart then
        start_engine_pair(1, 2)
        start_engine_pair(3, 4)
    elseif command == EnginesStop then
        stop_engine_pair(1, 2)
        stop_engine_pair(3, 4)
    end

    -- Throttles
    if command == 2004 then
        local t = math.max(0.0, math.min(1.0, (value + 1.0) * 0.5))
        throttle_left = t
        throttle_right = t
    elseif command == 2005 then
        throttle_left = math.max(0.0, math.min(1.0, (value + 1.0) * 0.5))
    elseif command == 2006 then
        throttle_right = math.max(0.0, math.min(1.0, (value + 1.0) * 0.5))
    end

    -- Landing Gear & Brakes
    if command == PlaneGear or command == CMD_GEAR_CLICK then
        gear_down = (gear_down > 0.5) and 0.0 or 1.0
    elseif command == CMD_EMER_GEAR then
        gear_down = 1.0 -- Emergency gravity drop
    end

    if command == CMD_PARK_BRAKE or command == 10019 then
        park_brake_on = true
    elseif command == 10020 then
        park_brake_on = false
    end
end

function start_engine_pair(e1, e2)
    for _, idx in ipairs({e1, e2}) do
        local eng = engines[idx]
        if eng.state == 0 then
            eng.state = 1 -- Crank
            eng.starter = true
            eng.cutoff = 1
        end
    end
end

function stop_engine_pair(e1, e2)
    for _, idx in ipairs({e1, e2}) do
        local eng = engines[idx]
        eng.state = 0
        eng.starter = false
        eng.cutoff = 0
    end
end

function update()
    local dt = update_time_step

    -- 1. Check Subsystem Pre-conditions via SYSTEM_BUS
    local elec = SYSTEM_BUS.get_domain("elec") or {}
    local fuel = SYSTEM_BUS.get_domain("fuel") or {}

    local apu_running   = elec.apu_running or false
    local dc_power      = (elec.dc_ess_bus_v or 0.0) >= 18.0
    local fuel_pressure = fuel.manifold_psi or 0.0

    -- 2. Simulate Each of the 4 F118 Turbofans
    for i = 1, 4 do
        local eng = engines[i]
        local thr = (i <= 2) and throttle_left or throttle_right

        if eng.state == 1 then
            -- Phase 1: Cranking via Air Turbine Starter
            -- Requires: APU Bleed Air (or other engines running) + DC Power for starter valve
            local air_available = apu_running or engines_running_count() > 0
            if air_available and dc_power then
                eng.n2 = math.min(22.0, eng.n2 + (dt * 3.5))
                eng.n1 = eng.n2 * 0.25
                eng.oil_psi = math.min(20.0, eng.n2 * 0.8)

                -- Lightoff Transition: Once N2 > 18% and fuel pressure is available
                if eng.n2 >= 18.0 and fuel_pressure >= 10.0 and eng.cutoff == 1 then
                    eng.state = 2 -- Lightoff / Ignition
                end
            else
                -- Spool down if air/power lost
                eng.n2 = math.max(0.0, eng.n2 - (dt * 5.0))
                eng.n1 = math.max(0.0, eng.n1 - (dt * 3.0))
                eng.state = 0
                eng.starter = false
            end

        elseif eng.state == 2 then
            -- Phase 2: Combustion Lightoff & Acceleration
            eng.egt = math.min(480.0, eng.egt + (dt * 85.0)) -- Rapid EGT rise on lightoff
            eng.ff  = 300.0 + (eng.n2 * 8.0)
            eng.n2  = eng.n2 + (dt * 6.0)
            eng.n1  = eng.n2 * 0.35
            eng.oil_psi = math.min(55.0, eng.n2 * 0.9)

            -- Starter Cut-out at 50% N2 (PUBLIC_TECHNICAL_INFERENCE)
            if eng.n2 >= 50.0 then
                eng.starter = false
            end

            -- Idle Stabilization at 62% N2
            if eng.n2 >= 62.0 then
                eng.state = 3 -- Running
            end

        elseif eng.state == 3 then
            -- Phase 3: Operational Engine (Governed by Throttle)
            if eng.cutoff == 0 or fuel_pressure < 2.0 then
                -- Flameout / Shutdown
                eng.state = 0
            else
                -- Target parameters based on throttle (0.0 to 1.0)
                local target_n1  = 22.0 + (thr * 78.0)   -- 22% to 100%
                local target_n2  = 62.0 + (thr * 39.0)   -- 62% to 101%
                local target_egt = 420.0 + (thr * 340.0) -- 420°C to 760°C
                local target_ff  = 800.0 + (thr * 3700.0)-- 800 to 4500 pph
                local target_oil = 55.0 + (thr * 10.0)   -- 55 to 65 PSI

                -- Smoothly approach target values
                eng.n1      = eng.n1 + (target_n1 - eng.n1) * (dt * 2.0)
                eng.n2      = eng.n2 + (target_n2 - eng.n2) * (dt * 2.5)
                eng.egt     = eng.egt + (target_egt - eng.egt) * (dt * 1.5)
                eng.ff      = eng.ff + (target_ff - eng.ff) * (dt * 3.0)
                eng.oil_psi = eng.oil_psi + (target_oil - eng.oil_psi) * (dt * 2.0)
            end

        elseif eng.state == 0 then
            -- Phase 0: Shutdown Spool-down
            eng.n1      = math.max(0.0, eng.n1 - (dt * 3.0))
            eng.n2      = math.max(0.0, eng.n2 - (dt * 4.0))
            eng.egt     = math.max(15.0, eng.egt - (dt * 12.0))
            eng.ff      = 0.0
            eng.oil_psi = math.max(0.0, eng.oil_psi - (dt * 8.0))
            eng.starter = false
        end

        -- Update EICAS parameters
        eicas_rpm[i]:set(eng.n2)
        eicas_egt[i]:set(eng.egt)
        eicas_ff[i]:set(eng.ff)
        eicas_oil[i]:set(eng.oil_psi)
    end

    publish_telemetry()
end

function engines_running_count()
    local cnt = 0
    for i = 1, 4 do
        if engines[i].state == 3 and engines[i].n2 > 55.0 then
            cnt = cnt + 1
        end
    end
    return cnt
end

function publish_telemetry()
    SYSTEM_BUS.publish_batch("engines", {
        [1] = { state = engines[1].state, n1 = engines[1].n1, n2 = engines[1].n2, egt = engines[1].egt, ff = engines[1].ff, oil_psi = engines[1].oil_psi, starter = engines[1].starter },
        [2] = { state = engines[2].state, n1 = engines[2].n1, n2 = engines[2].n2, egt = engines[2].egt, ff = engines[2].ff, oil_psi = engines[2].oil_psi, starter = engines[2].starter },
        [3] = { state = engines[3].state, n1 = engines[3].n1, n2 = engines[3].n2, egt = engines[3].egt, ff = engines[3].ff, oil_psi = engines[3].oil_psi, starter = engines[3].starter },
        [4] = { state = engines[4].state, n1 = engines[4].n1, n2 = engines[4].n2, egt = engines[4].egt, ff = engines[4].ff, oil_psi = engines[4].oil_psi, starter = engines[4].starter },
        throttle_left  = throttle_left,
        throttle_right = throttle_right,
        gear_down      = gear_down,
        park_brake_on  = park_brake_on
    })
end

need_to_be_closed = false
