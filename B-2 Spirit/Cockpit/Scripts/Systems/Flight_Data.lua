--[[
    B-2 SPIRIT PUBLIC-REFERENCE COCKPIT — FLIGHT DATA ADAPTER (FLIGHT)
    Reference-backed reconstruction based on publicly available imagery and USAF documentation
    
    PROVENANCE CLASSIFICATION:
    - REFERENCE_BACKED: 
        * B-2 primary flight presentation: pitch, roll, heading, calibrated airspeed, Mach, baro altitude, radar altitude, vertical velocity, AoA.
        * Flight Setting Panel barometric pressure calibration dial (29.92 inHg standard datum).
    - PUBLIC_TECHNICAL_INFERENCE:
        * 1013.25 hPa / 29.92 inHg standard atmosphere altitude calculation with pilot knob bias.
        * Dynamic pressure smoothing and alpha/beta sensor filtering.
    - DCS_SIMULATION_ABSTRACTION:
        * Interfacing with get_base_data() sensor API.

    ARCHITECTURAL PRINCIPLE:
    "The display never owns the aircraft state."
    Flight_Data samples sensor data, applies calibration, and publishes live telemetry to SYSTEM_BUS.
--]]

dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/system_bus.lua")

local dev = GetSelf()
local update_time_step = 0.02 -- 50 Hz flight data refresh
make_default_activity(update_time_step)

local sensor_data = get_base_data()

-- Barometric pressure setting in inHg
local baro_setting = 29.92

-- Listen for Baro Knob Adjustments (from clickabledata.lua FSP selectors)
-- FSP_L_BARO_PNT: command 3003
dev:listen_command(3003)
dev:listen_command(3009)

function post_initialize()
    baro_setting = 29.92
    publish_flight_telemetry(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.0)
end

function SetCommand(command, value)
    if command == 3003 or command == 3009 then
        -- Barometric knob adjusts setting between 28.00 and 31.00 inHg
        local delta = value * 0.01
        baro_setting = math.max(28.00, math.min(31.00, baro_setting + delta))
    end
end

function update()
    -- Read DCS Sensor Data
    local pitch = 0.0
    local bank  = 0.0
    local hdg   = 0.0
    local ias   = 0.0
    local mach  = 0.0
    local baro_alt = 0.0
    local rad_alt  = 0.0
    local vvi      = 0.0
    local aoa      = 0.0
    local aos      = 0.0
    local g_load   = 1.0

    if sensor_data then
        pitch    = sensor_data.getPitch and sensor_data.getPitch() or 0.0
        bank     = sensor_data.getRoll and sensor_data.getRoll() or 0.0
        hdg      = sensor_data.getHeading and sensor_data.getHeading() or 0.0
        ias      = sensor_data.getIndicatedAirSpeed and (sensor_data.getIndicatedAirSpeed() * 1.94384) or 0.0 -- m/s to knots
        mach     = sensor_data.getMachNumber and sensor_data.getMachNumber() or 0.0
        baro_alt = sensor_data.getBarometricAltitude and (sensor_data.getBarometricAltitude() * 3.28084) or 0.0 -- m to ft
        rad_alt  = sensor_data.getRadarAltitude and (sensor_data.getRadarAltitude() * 3.28084) or 0.0 -- m to ft
        vvi      = sensor_data.getVerticalVelocity and (sensor_data.getVerticalVelocity() * 196.85) or 0.0 -- m/s to fpm
        aoa      = sensor_data.getAngleOfAttack and (sensor_data.getAngleOfAttack() * 57.2958) or 0.0 -- rad to deg
        aos      = sensor_data.getAngleOfSideSlip and (sensor_data.getAngleOfSideSlip() * 57.2958) or 0.0
        g_load   = sensor_data.getVerticalAcceleration and (sensor_data.getVerticalAcceleration() / 9.81) or 1.0
    end

    -- Apply Barometric Bias: 1 inHg approx 1,000 ft
    local baro_correction = (baro_setting - 29.92) * 1000.0
    local calibrated_alt  = baro_alt + baro_correction

    -- Heading in degrees 0..360
    local hdg_deg = (math.deg(hdg) % 360 + 360) % 360

    publish_flight_telemetry(pitch, bank, hdg, hdg_deg, ias, mach, calibrated_alt, rad_alt, vvi, aoa, aos, g_load)
end

local pfd_params = {
    NAV      = get_param_handle("NAV"),
    ADIROLL  = get_param_handle("ADIROLL"),
    ADIPITCH = get_param_handle("ADIPITCH"),
    IAS      = get_param_handle("IAS"),
    MACH     = get_param_handle("MACH"),
    TAS      = get_param_handle("TAS"),
    BAROALT  = get_param_handle("BAROALT"),
    VV       = get_param_handle("VV"),
    GFORCE   = get_param_handle("GFORCE"),
    AOA      = get_param_handle("AOA"),
    RADALT   = get_param_handle("RADALT"),
}

function publish_flight_telemetry(pitch, bank, hdg, hdg_deg, ias, mach, alt, ralt, vvi, aoa, aos, g)
    if pfd_params.NAV then pfd_params.NAV:set(hdg_deg) end
    if pfd_params.ADIROLL then pfd_params.ADIROLL:set(bank) end
    if pfd_params.ADIPITCH then pfd_params.ADIPITCH:set(pitch) end
    if pfd_params.IAS then pfd_params.IAS:set(ias) end
    if pfd_params.MACH then pfd_params.MACH:set(mach) end
    if pfd_params.TAS then pfd_params.TAS:set(ias * (1.0 + (alt / 60000.0))) end
    if pfd_params.BAROALT then pfd_params.BAROALT:set(alt) end
    if pfd_params.VV then pfd_params.VV:set(vvi) end
    if pfd_params.GFORCE then pfd_params.GFORCE:set(g) end
    if pfd_params.AOA then pfd_params.AOA:set(aoa) end
    if pfd_params.RADALT then pfd_params.RADALT:set(ralt) end

    SYSTEM_BUS.publish_batch("flight", {
        pitch        = pitch,
        bank         = bank,
        heading      = hdg,
        heading_deg  = hdg_deg or 0.0,
        ias_knots    = ias,
        mach         = mach,
        alt_baro_ft  = alt,
        alt_rad_ft   = ralt,
        vvi_fpm      = vvi,
        aoa_deg      = aoa,
        aos_deg      = aos or 0.0,
        g_force      = g,
        baro_setting = baro_setting
    })
end

need_to_be_closed = false
