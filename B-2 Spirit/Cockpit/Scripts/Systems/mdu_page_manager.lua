--[[
    B-2 SPIRIT PUBLIC-REFERENCE COCKPIT — MDU PAGE MANAGER & DISPLAY OBSERVER
    Reference-backed reconstruction based on publicly available imagery and USAF documentation
    
    PROVENANCE CLASSIFICATION:
    - REFERENCE_BACKED:
        * 8 physical Multipurpose Display Units (4 pilot left-station, 4 copilot right-station).
        * 20 perimeter softkeys (OSB 01–20) per unit (5 Top, 5 Right, 5 Bottom, 5 Left).
        * Top OSB 1–5 system select tabs: FUEL, FCH, ELEC, ECS, ENG.
        * Primary flight presentation (PFD) on center units; System/Status on outboard/inboard units.
    - PUBLIC_TECHNICAL_INFERENCE:
        * Synoptic page layouts for Electrical single-line, Fuel tank manifold, and 4-Engine matrix.
        * Context-sensitive softkey page transitions and device command dispatching.
    - DCS_SIMULATION_ABSTRACTION:
        * ccIndicator display integration and parameter string buffers.

    ARCHITECTURAL PRINCIPLE:
    "The display never owns the aircraft state."
    MDU Page Manager is strictly an observer of SYSTEM_BUS.
--]]

local script_path = (LockOn_Options and LockOn_Options.script_path) or "B-2 Spirit/Cockpit/Scripts/"
pcall(dofile, script_path.."devices.lua")
pcall(dofile, script_path.."command_defs.lua")
pcall(dofile, script_path.."Systems/system_bus.lua")

local dev = (GetSelf and GetSelf()) or nil
local update_time_step = 0.05 -- 20 Hz display refresh loop
if make_default_activity then
    make_default_activity(update_time_step)
end

MDU_MANAGER = {}

MDU_MANAGER.DISPLAY_ORDER = {
    "MDU_L_UPPER_OUTBOARD",
    "MDU_L_UPPER_CENTRE",
    "MDU_L_UPPER_INBOARD",
    "MDU_L_LOWER",
    "MDU_R_UPPER_INBOARD",
    "MDU_R_UPPER_CENTRE",
    "MDU_R_UPPER_OUTBOARD",
    "MDU_R_LOWER"
}

-- 8 Physical Multipurpose Display Units with default assigned roles
MDU_MANAGER.DISPLAYS = {
    ["MDU_L_UPPER_OUTBOARD"] = { display_id = 1, page = "ENG",    brightness = 1.0, powered = true, default_page = "ENG",    last_osb = 0, frame_count = 0 },
    ["MDU_L_UPPER_CENTRE"]   = { display_id = 2, page = "FLIGHT", brightness = 1.0, powered = true, default_page = "FLIGHT", last_osb = 0, frame_count = 0 },
    ["MDU_L_UPPER_INBOARD"]  = { display_id = 3, page = "FCH",    brightness = 1.0, powered = true, default_page = "FCH",    last_osb = 0, frame_count = 0 },
    ["MDU_L_LOWER"]          = { display_id = 4, page = "NAV",    brightness = 1.0, powered = true, default_page = "NAV",    last_osb = 0, frame_count = 0 },
    ["MDU_R_UPPER_INBOARD"]  = { display_id = 5, page = "ELEC",   brightness = 1.0, powered = true, default_page = "ELEC",   last_osb = 0, frame_count = 0 },
    ["MDU_R_UPPER_CENTRE"]   = { display_id = 6, page = "FLIGHT", brightness = 1.0, powered = true, default_page = "FLIGHT", last_osb = 0, frame_count = 0 },
    ["MDU_R_UPPER_OUTBOARD"] = { display_id = 7, page = "STATUS", brightness = 1.0, powered = true, default_page = "STATUS", last_osb = 0, frame_count = 0 },
    ["MDU_R_LOWER"]          = { display_id = 8, page = "NAV",    brightness = 1.0, powered = true, default_page = "NAV",    last_osb = 0, frame_count = 0 },
}

-- Page Controllers (Observer View Models)
local PAGES = {}

-- -------------------------------------------------------------------------
-- 1. FLIGHT PAGE (Primary Flight Display)
-- -------------------------------------------------------------------------
PAGES["FLIGHT"] = {
    title = "PRIMARY FLIGHT DISPLAY",
    on_osb = function(mdu, osb)
        if osb == 1 then mdu.page = "NAV"
        elseif osb == 20 then mdu.page = mdu.default_page end
    end,
    render_text = function(mdu)
        local flt = SYSTEM_BUS.get_domain("flight") or {}
        return string.format(
            "=== PRIMARY FLIGHT DISPLAY ===\n" ..
            "IAS: %03d KTS    MACH: %.2f\n" ..
            "ALT: %05d FT    RALT: %04d FT\n" ..
            "PITCH: %+03.1f°  BANK: %+03.1f°\n" ..
            "HDG: %03.0f°     VVI: %+04d FPM\n" ..
            "AOA: %02.1f°     G: %1.2f\n" ..
            "BARO: %2.2f inHg",
            math.floor(flt.ias_knots or 0),
            flt.mach or 0.0,
            math.floor(flt.alt_baro_ft or 0),
            math.floor(flt.alt_rad_ft or 0),
            math.deg(flt.pitch or 0),
            math.deg(flt.bank or 0),
            flt.heading_deg or 0.0,
            math.floor(flt.vvi_fpm or 0),
            flt.aoa_deg or 0.0,
            flt.g_force or 1.0,
            flt.baro_setting or 29.92
        )
    end
}

-- -------------------------------------------------------------------------
-- 2. ENGINE STATUS PAGE (4x F118-GE-100 Turbofans)
-- -------------------------------------------------------------------------
PAGES["ENG"] = {
    title = "ENGINE STATUS MATRIX",
    on_osb = function(mdu, osb)
        -- Top row page navigation (OSB 1..5)
        if osb == 1 then mdu.page = "FUEL"
        elseif osb == 2 then mdu.page = "FCH"
        elseif osb == 3 then mdu.page = "ELEC"
        elseif osb == 4 then mdu.page = "ECS"
        elseif osb == 5 then mdu.page = "ENG"
        elseif osb == 12 then mdu.page = "STATUS"
        elseif osb == 20 then mdu.page = mdu.default_page end
    end,
    render_text = function(mdu)
        local eng = SYSTEM_BUS.get_domain("engines") or {}
        local e1 = eng[1] or { n1 = 0, n2 = 0, egt = 0, ff = 0, oil_psi = 0 }
        local e2 = eng[2] or { n1 = 0, n2 = 0, egt = 0, ff = 0, oil_psi = 0 }
        local e3 = eng[3] or { n1 = 0, n2 = 0, egt = 0, ff = 0, oil_psi = 0 }
        local e4 = eng[4] or { n1 = 0, n2 = 0, egt = 0, ff = 0, oil_psi = 0 }

        return string.format(
            "=== ENGINE STATUS (4x F118-GE-100) ===\n" ..
            "PARAM   ENG 1   ENG 2   ENG 3   ENG 4\n" ..
            "N1 %%   %5.1f   %5.1f   %5.1f   %5.1f\n" ..
            "N2 %%   %5.1f   %5.1f   %5.1f   %5.1f\n" ..
            "EGT°C   %5.0f   %5.0f   %5.0f   %5.0f\n" ..
            "FF pph  %5.0f   %5.0f   %5.0f   %5.0f\n" ..
            "OIL psi %5.1f   %5.1f   %5.1f   %5.1f\n" ..
            "THROTTLE L: %02d%%   R: %02d%%",
            e1.n1, e2.n1, e3.n1, e4.n1,
            e1.n2, e2.n2, e3.n2, e4.n2,
            e1.egt, e2.egt, e3.egt, e4.egt,
            e1.ff, e2.ff, e3.ff, e4.ff,
            e1.oil_psi, e2.oil_psi, e3.oil_psi, e4.oil_psi,
            math.floor((eng.throttle_left or 0) * 100),
            math.floor((eng.throttle_right or 0) * 100)
        )
    end
}

-- -------------------------------------------------------------------------
-- 3. ELECTRICAL SYSTEM PAGE
-- -------------------------------------------------------------------------
PAGES["ELEC"] = {
    title = "ELECTRICAL SYSTEM SYNOPTIC",
    on_osb = function(mdu, osb)
        if osb == 1 then mdu.page = "FUEL"
        elseif osb == 2 then mdu.page = "FCH"
        elseif osb == 3 then mdu.page = "ELEC"
        elseif osb == 4 then mdu.page = "ECS"
        elseif osb == 5 then mdu.page = "ENG"
        elseif osb == 20 then mdu.page = mdu.default_page end
    end,
    render_text = function(mdu)
        local el = SYSTEM_BUS.get_domain("elec") or {}
        return string.format(
            "=== ELECTRICAL SYSTEM SYNOPTIC ===\n" ..
            "BATTERY: %s (%2.1fV)  DC ESS: %2.1fV\n" ..
            "APU GEN: %s (%3.0fV)  RPM: %02d%%\n" ..
            "GEN 1: %-7s  AC BUS 1: %3.0fV\n" ..
            "GEN 2: %-7s  AC BUS 2: %3.0fV\n" ..
            "GEN 3: %-7s  AC BUS 3: %3.0fV\n" ..
            "GEN 4: %-7s  AC BUS 4: %3.0fV\n" ..
            "AC ESS BUS: %3.0fV  BUS TIE: %s",
            el.battery_switch == 1 and "ON" or "OFF",
            el.battery_volts or 0.0,
            el.dc_ess_bus_v or 0.0,
            el.apu_gen_online and "ONLINE" or "OFFLINE",
            el.apu_gen_volts or 0.0,
            math.floor(el.apu_rpm or 0),
            el.gen1_online and "ONLINE" or "OFF",
            el.ac_bus_1_v or 0.0,
            el.gen2_online and "ONLINE" or "OFF",
            el.ac_bus_2_v or 0.0,
            el.gen3_online and "ONLINE" or "OFF",
            el.ac_bus_3_v or 0.0,
            el.gen4_online and "ONLINE" or "OFF",
            el.ac_bus_4_v or 0.0,
            el.ac_ess_bus_v or 0.0,
            el.tie_bus_closed and "CLOSED" or "OPEN"
        )
    end
}

-- -------------------------------------------------------------------------
-- 4. FUEL SYSTEM PAGE
-- -------------------------------------------------------------------------
PAGES["FUEL"] = {
    title = "FUEL SYSTEM SYNOPTIC",
    on_osb = function(mdu, osb)
        if osb == 1 then mdu.page = "FUEL"
        elseif osb == 2 then mdu.page = "FCH"
        elseif osb == 3 then mdu.page = "ELEC"
        elseif osb == 4 then mdu.page = "ECS"
        elseif osb == 5 then mdu.page = "ENG"
        elseif osb == 6 then
            -- OSB 6 action: Command Crossfeed Toggle via System Bus
            local f = SYSTEM_BUS.get_domain("fuel") or {}
            local dev_fuel = GetDevice(devices.FUEL_SYSTEM or 0)
            if dev_fuel then
                dev_fuel:SetCommand(4002, 0)
            end
        elseif osb == 20 then mdu.page = mdu.default_page end
    end,
    render_text = function(mdu)
        local f = SYSTEM_BUS.get_domain("fuel") or {}
        return string.format(
            "=== FUEL SYSTEM SYNOPTIC ===\n" ..
            "TOTAL FUEL: %06d LBS\n" ..
            "L WING: %05d LBS   R WING: %05d LBS\n" ..
            "FWD CTR: %05d LBS  AFT CTR: %05d LBS\n" ..
            "MANIFOLD PRESS: %02d PSI\n" ..
            "BOOST PUMPS: %-8s CROSSFEED: %s\n" ..
            "TOTAL BURN RATE: %04d PPH",
            math.floor(f.total_lbs or 0),
            math.floor(f.tank_l_wing or 0),
            math.floor(f.tank_r_wing or 0),
            math.floor(f.tank_fwd_ctr or 0),
            math.floor(f.tank_aft_ctr or 0),
            math.floor(f.manifold_psi or 0),
            f.boost_pumps_on and "ENERGIZED" or "OFF",
            f.crossfeed_open and "OPEN" or "CLOSED",
            math.floor(f.fuel_flow_pph or 0)
        )
    end
}

-- -------------------------------------------------------------------------
-- 5. OTHER PAGES & DIAGNOSTIC TEST PAGE
-- -------------------------------------------------------------------------
PAGES["NAV"] = {
    title = "NAVIGATION / SITUATION",
    on_osb = function(mdu, osb)
        if osb == 1 then mdu.page = "FLIGHT"
        elseif osb == 20 then mdu.page = mdu.default_page end
    end,
    render_text = function(mdu)
        local flt = SYSTEM_BUS.get_domain("flight") or {}
        return string.format(
            "=== NAVIGATION & SITUATION ===\n" ..
            "HEADING: %03.0f°  SPEED: %03d KTS\n" ..
            "ALTITUDE: %05d FT\n" ..
            "NAV MODE: STEERPOINT 01\n" ..
            "ROUTE: AUTO-WP ADVANCE",
            flt.heading_deg or 0.0,
            math.floor(flt.ias_knots or 0),
            math.floor(flt.alt_baro_ft or 0)
        )
    end
}

PAGES["FCH"] = {
    title = "FLIGHT CONTROLS / AIR DATA",
    on_osb = function(mdu, osb)
        if osb == 1 then mdu.page = "FUEL"
        elseif osb == 2 then mdu.page = "FCH"
        elseif osb == 3 then mdu.page = "ELEC"
        elseif osb == 4 then mdu.page = "ECS"
        elseif osb == 5 then mdu.page = "ENG"
        elseif osb == 12 then mdu.page = "STATUS"
        elseif osb == 20 then mdu.page = mdu.default_page end
    end,
    render_text = function(mdu)
        return "=== FLIGHT CONTROLS & AIR DATA ===\n" ..
               "FCC CHANNELS: 1:OK  2:OK  3:OK  4:OK\n" ..
               "CONTROL LAWS: NORMAL DIGITAL FBW\n" ..
               "RUDDER ELEVONS: ACTIVE TRIM BALANCED\n" ..
               "DRAG RUDDERS: CALIBRATED"
    end
}

PAGES["STATUS"] = {
    title = "SUBSYSTEM ADVISORY STATUS",
    on_osb = function(mdu, osb)
        if osb == 1 then mdu.page = "FUEL"
        elseif osb == 2 then mdu.page = "FCH"
        elseif osb == 3 then mdu.page = "ELEC"
        elseif osb == 4 then mdu.page = "ECS"
        elseif osb == 5 then mdu.page = "ENG"
        elseif osb == 20 then mdu.page = mdu.default_page end
    end,
    render_text = function(mdu)
        local cautions = SYSTEM_BUS.get_cautions()
        local lines = {"=== CAUTION & STATUS ADVISORIES ==="}
        for k, v in pairs(cautions) do
            table.insert(lines, string.format("[%s] %s", v.severity, v.message))
        end
        if #lines == 1 then
            table.insert(lines, "NO ACTIVE CAUTIONS OR WARNINGS")
        end
        return table.concat(lines, "\n")
    end
}

PAGES["TEST"] = {
    title = "DIAGNOSTIC TEST PAGE",
    on_osb = function(mdu, osb)
        mdu.last_osb = osb
        if osb == 20 then
            mdu.page = mdu.default_page
        end
    end,
    render_text = function(mdu)
        return MDU_MANAGER.get_diagnostic_text(mdu.name or "MDU_L_UPPER_OUTBOARD")
    end
}

-- Context-Sensitive Softkey Dispatch
function dispatch_mdu_osb(mdu_id, osb)
    local display = MDU_MANAGER.DISPLAYS[mdu_id]
    if not display or not display.powered then return end
    
    display.last_osb = osb
    display.name = mdu_id
    
    -- OSB 10 toggles diagnostic TEST page from any active page
    if osb == 10 and display.page ~= "TEST" then
        display.page = "TEST"
        return
    end

    local page_def = PAGES[display.page]
    if page_def and page_def.on_osb then
        page_def.on_osb(display, osb)
    end
end

-- Returns exact diagnostic text format required for in-sim verification (Gate 5)
function MDU_MANAGER.get_diagnostic_text(mdu_id)
    local d = MDU_MANAGER.DISPLAYS[mdu_id]
    if not d then return "INVALID DISPLAY" end
    return string.format(
        "%s\nDISPLAY ID: %02d\nPAGE: %s\nOSB PRESSED: %02d\nFRAME: %d",
        mdu_id,
        d.display_id or 0,
        d.page or "OFF",
        d.last_osb or 0,
        d.frame_count or 0
    )
end

-- Returns rendered page content for the display
function MDU_MANAGER.get_page_content(mdu_id)
    local d = MDU_MANAGER.DISPLAYS[mdu_id]
    if not d or not d.powered then return "" end
    d.name = mdu_id
    local page_def = PAGES[d.page]
    if page_def and page_def.render_text then
        return page_def.render_text(d)
    end
    return "PAGE: " .. (d.page or "UNKNOWN")
end

function SetCommand(command, value)
    if command >= 1001 and command <= 1160 then
        local idx = math.floor((command - 1001) / 20) + 1
        local osb = ((command - 1001) % 20) + 1
        local mdu_id = MDU_MANAGER.DISPLAY_ORDER[idx]
        if mdu_id then
            dispatch_mdu_osb(mdu_id, osb)
        end
    end
end

function post_initialize()
    if dev then
        for cmd = 1001, 1160 do
            dev:SetCommandCallback(cmd)
        end
    end
end

function update()
    local has_power = true
    if SYSTEM_BUS and SYSTEM_BUS.get_domain then
        local elec = SYSTEM_BUS.get_domain("elec")
        if elec and elec.active_simulation then
            has_power = (elec.dc_ess_bus_v and elec.dc_ess_bus_v > 18.0) or
                        (elec.ac_ess_bus_v and elec.ac_ess_bus_v > 80.0)
        end
    end

    for _, d in pairs(MDU_MANAGER.DISPLAYS) do
        d.powered = has_power
        if d.powered then
            d.frame_count = (d.frame_count or 0) + 1
        end
    end
end

return MDU_MANAGER
