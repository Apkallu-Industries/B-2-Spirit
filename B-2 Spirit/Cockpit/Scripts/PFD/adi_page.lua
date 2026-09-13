--[[
    B-2 Spirit Stealth Bomber — Primary Flight Display (PFD)
    Pilot MFD 2 (Center Upper Screen) & Copilot MFD 6 (Repeater)
    Hijacked & Adapted from Gripen JAS-39 ADI / PFD Vector Architecture
    Features: Dynamic Artificial Horizon, Pitch Ladder, Velocity Vector, Airspeed Tape, Altimeter Tape, Heading Ribbon
--]]

dofile(LockOn_Options.script_path .. "B2_MFD_def.lua")

-- Screen Base
local aspect = 1.0
local ScreenBase = CreateElement "ceMeshPoly"
ScreenBase.name           = create_guid_string()
ScreenBase.primitivetype  = "triangles"
ScreenBase.vertices       = {{-aspect, aspect}, {aspect, aspect}, {aspect, -aspect}, {-aspect, -aspect}}
ScreenBase.indices        = {0, 1, 2, 0, 2, 3}
ScreenBase.init_pos       = {0, 0, 0}
ScreenBase.material       = materials["SCREEN_BG"]
ScreenBase.h_clip_relation = h_clip_relations.REWRITE_LEVEL
ScreenBase.level          = MFD_DEFAULT_LEVEL
ScreenBase.element_params = {"MFD_OPACITY"}
ScreenBase.controllers    = {{"opacity_using_parameter", 0}}
AddElement(ScreenBase)

-- ═══════════════════════════════════════════════════════════════════════════════
-- TOP HEADING RIBBON (000° to 360°)
-- ═══════════════════════════════════════════════════════════════════════════════

create_rect(0, 0.88, 1.80, 0.12, 0.003, ScreenBase, materials["GREEN"], materials["DIAL_BG"])

-- Heading lubber line / center pointer
local hdg_pointer = CreateElement "ceSimpleLineObject"
hdg_pointer.name           = create_guid_string()
hdg_pointer.material       = materials["WHITE"]
hdg_pointer.vertices       = {{-0.02, 0.82}, {0.02, 0.82}, {0, 0.85}, {-0.02, 0.82}}
hdg_pointer.width          = 0.003
hdg_pointer.parent_element = ScreenBase.name
AddElement(hdg_pointer)

-- Digital Heading Box
create_rect(0, 0.92, 0.22, 0.055, 0.002, ScreenBase, materials["WHITE"], materials["SCREEN_BG"])
add_text_param(0, 0.92, "NAV", "%03.0f°", ScreenBase, fonts["GREEN"], strdefs_MED, "CenterCenter")

-- ═══════════════════════════════════════════════════════════════════════════════
-- ARTIFICIAL HORIZON / ADI SPHERE (Central Flight Instrument)
-- ═══════════════════════════════════════════════════════════════════════════════

local adi_center_x = 0.0
local adi_center_y = 0.08
local adi_radius   = 0.44

-- Circular clipping mask for the ADI window
local adi_clip = AddCircleClip(adi_center_x, adi_center_y, adi_radius, ScreenBase, MFD_DEFAULT_LEVEL)

-- Rotating / Pitching ADI Base (tied to ADIROLL and ADIPITCH)
local adi_rot_base = CreateElement "ceSimple"
adi_rot_base.name           = create_guid_string()
adi_rot_base.init_pos       = {adi_center_x, adi_center_y, 0}
adi_rot_base.parent_element = ScreenBase.name
adi_rot_base.element_params = {"ADIROLL"}
adi_rot_base.controllers    = {{"rotate_using_parameter", 0, 1.0}} -- rolls with aircraft
AddElement(adi_rot_base)

-- Pitch translation root
local adi_pitch_base = CreateElement "ceSimple"
adi_pitch_base.name           = create_guid_string()
adi_pitch_base.init_pos       = {0, 0, 0}
adi_pitch_base.parent_element = adi_rot_base.name
adi_pitch_base.element_params = {"ADIPITCH"}
adi_pitch_base.controllers    = {{"move_up_down_using_parameter", 0, -1.2}} -- translates vertically with pitch
AddElement(adi_pitch_base)

-- Sky Half (Blue Polygon)
local sky_poly = CreateElement "ceMeshPoly"
sky_poly.name           = create_guid_string()
sky_poly.primitivetype  = "triangles"
sky_poly.vertices       = {{-1.2, 1.2}, {1.2, 1.2}, {1.2, 0}, {-1.2, 0}}
sky_poly.indices        = {0, 1, 2, 0, 2, 3}
sky_poly.material       = materials["BLUE_SKY"]
sky_poly.parent_element = adi_pitch_base.name
sky_poly.h_clip_relation = h_clip_relations.DECREASE_IF_LEVEL
sky_poly.level          = MFD_DEFAULT_LEVEL + 1
AddElement(sky_poly)

-- Ground Half (Brown Polygon)
local gnd_poly = CreateElement "ceMeshPoly"
gnd_poly.name           = create_guid_string()
gnd_poly.primitivetype  = "triangles"
gnd_poly.vertices       = {{-1.2, 0}, {1.2, 0}, {1.2, -1.2}, {-1.2, -1.2}}
gnd_poly.indices        = {0, 1, 2, 0, 2, 3}
gnd_poly.material       = materials["BROWN_GND"]
gnd_poly.parent_element = adi_pitch_base.name
gnd_poly.h_clip_relation = h_clip_relations.DECREASE_IF_LEVEL
gnd_poly.level          = MFD_DEFAULT_LEVEL + 1
AddElement(gnd_poly)

-- White Horizon Line
local horizon_line = CreateElement "ceSimpleLineObject"
horizon_line.name           = create_guid_string()
horizon_line.material       = materials["WHITE"]
horizon_line.vertices       = {{-1.2, 0}, {1.2, 0}}
horizon_line.width          = 0.006
horizon_line.parent_element = adi_pitch_base.name
horizon_line.h_clip_relation = h_clip_relations.DECREASE_IF_LEVEL
horizon_line.level          = MFD_DEFAULT_LEVEL + 1
AddElement(horizon_line)

-- Pitch Ladder Rungs (+10°, +20°, -10°, -20°)
local pitch_steps = {
	{deg =  10, y =  0.21, solid = true},
	{deg =  20, y =  0.42, solid = true},
	{deg =  30, y =  0.63, solid = true},
	{deg = -10, y = -0.21, solid = false},
	{deg = -20, y = -0.42, solid = false},
	{deg = -30, y = -0.63, solid = false},
}

for _, rung in ipairs(pitch_steps) do
	local rw = 0.16
	local rung_line = CreateElement "ceSimpleLineObject"
	rung_line.name           = create_guid_string()
	rung_line.material       = materials["WHITE"]
	rung_line.vertices       = {{-rw, rung.y}, {-0.04, rung.y}, {0.04, rung.y}, {rw, rung.y}}
	rung_line.width          = 0.004
	rung_line.parent_element = adi_pitch_base.name
	rung_line.h_clip_relation = h_clip_relations.DECREASE_IF_LEVEL
	rung_line.level          = MFD_DEFAULT_LEVEL + 1
	AddElement(rung_line)

	-- Pitch degree label
	local lbl_l = add_text(string.format("%d", math.abs(rung.deg)), -rw - 0.04, rung.y, adi_pitch_base, fonts["WHITE"], strdefs_TINY, "RightCenter")
	lbl_l.h_clip_relation = h_clip_relations.DECREASE_IF_LEVEL
	lbl_l.level = MFD_DEFAULT_LEVEL + 1

	local lbl_r = add_text(string.format("%d", math.abs(rung.deg)), rw + 0.04, rung.y, adi_pitch_base, fonts["WHITE"], strdefs_TINY, "LeftCenter")
	lbl_r.h_clip_relation = h_clip_relations.DECREASE_IF_LEVEL
	lbl_r.level = MFD_DEFAULT_LEVEL + 1
end

-- ADI Outer Precision Bezel Ring (Fixed over clipping mask)
local adi_ring = CreateElement "ceMeshPoly"
adi_ring.name           = create_guid_string()
adi_ring.primitivetype  = "triangles"
adi_ring.init_pos       = {adi_center_x, adi_center_y, 0}
adi_ring.material       = materials["WHITE"]
adi_ring.parent_element = ScreenBase.name
set_circle(adi_ring, adi_radius + 0.008, adi_radius, 360, 48)
AddElement(adi_ring)

-- Fixed Aircraft Reticle (Center Datum)
local reticle = CreateElement "ceSimpleLineObject"
reticle.name           = create_guid_string()
reticle.material       = materials["GREEN"]
reticle.vertices       = {
	{-0.15, adi_center_y}, {-0.06, adi_center_y}, {-0.06, adi_center_y - 0.02},
	{ 0.06, adi_center_y - 0.02}, {0.06, adi_center_y}, {0.15, adi_center_y}
}
reticle.width          = 0.005
reticle.parent_element = ScreenBase.name
AddElement(reticle)

local reticle_dot = CreateElement "ceMeshPoly"
reticle_dot.name           = create_guid_string()
reticle_dot.primitivetype  = "triangles"
reticle_dot.init_pos       = {adi_center_x, adi_center_y, 0}
reticle_dot.material       = materials["GREEN"]
reticle_dot.parent_element = ScreenBase.name
set_circle(reticle_dot, 0.008)
AddElement(reticle_dot)

-- Bank Angle Scale Arc & Pointer at top of ADI (±10°, ±20°, ±30°, ±45°, ±60°)
for _, angle in ipairs({-60, -45, -30, -20, -10, 0, 10, 20, 30, 45, 60}) do
	local rad = math.rad(-angle + 90)
	local tick_len = (angle % 30 == 0) and 0.025 or 0.015
	local b_tick = CreateElement "ceSimpleLineObject"
	b_tick.name           = create_guid_string()
	b_tick.material       = materials["WHITE"]
	b_tick.vertices       = {{0, 0}, {0, tick_len}}
	b_tick.width          = 0.003
	b_tick.init_pos       = {adi_center_x + (adi_radius + 0.01) * math.cos(rad), adi_center_y + (adi_radius + 0.01) * math.sin(rad)}
	b_tick.init_rot       = {-angle}
	b_tick.parent_element = ScreenBase.name
	AddElement(b_tick)
end

-- Roll pointer (triangular bug rotating on ADI perimeter)
local roll_bug_root = CreateElement "ceSimple"
roll_bug_root.name           = create_guid_string()
roll_bug_root.init_pos       = {adi_center_x, adi_center_y, 0}
roll_bug_root.parent_element = ScreenBase.name
roll_bug_root.element_params = {"ADIROLL"}
roll_bug_root.controllers    = {{"rotate_using_parameter", 0, 1.0}}
AddElement(roll_bug_root)

local roll_bug = CreateElement "ceSimpleLineObject"
roll_bug.name           = create_guid_string()
roll_bug.material       = materials["WHITE"]
roll_bug.vertices       = {{-0.015, adi_radius - 0.025}, {0.015, adi_radius - 0.025}, {0, adi_radius - 0.005}, {-0.015, adi_radius - 0.025}}
roll_bug.width          = 0.003
roll_bug.parent_element = roll_bug_root.name
AddElement(roll_bug)

-- ═══════════════════════════════════════════════════════════════════════════════
-- AIRSPEED TAPE & READOUT (Left Side)
-- ═══════════════════════════════════════════════════════════════════════════════

local spd_x = -0.74
create_rect(spd_x, 0.08, 0.32, 1.00, 0.003, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("IAS KTS", spd_x, 0.54, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")

-- Airspeed Digital Box (Center readout)
create_rect(spd_x, 0.08, 0.28, 0.09, 0.004, ScreenBase, materials["WHITE"], materials["SCREEN_BG"])
add_text_param(spd_x, 0.08, "IAS", "%03.0f", ScreenBase, fonts["GREEN"], strdefs_LARGE, "CenterCenter")

-- Airspeed Tape Tick Marks (every 20 kts)
for s = -4, 4 do
	local ty = 0.08 + (s * 0.09)
	create_line(spd_x + 0.10, ty, spd_x + 0.15, ty, 0.003, ScreenBase, materials["WHITE"])
end

-- Mach & Ground Speed Below Airspeed
add_text("M", spd_x - 0.08, -0.48, ScreenBase, fonts["WHITE"], strdefs_SML, "CenterCenter")
add_text_param(spd_x + 0.04, -0.48, "MACH", "%.2f", ScreenBase, fonts["GREEN"], strdefs_MED, "CenterCenter")

add_text("GS", spd_x - 0.08, -0.56, ScreenBase, fonts["WHITE"], strdefs_SML, "CenterCenter")
add_text_param(spd_x + 0.04, -0.56, "TAS", "%03.0f", ScreenBase, fonts["GREEN"], strdefs_MED, "CenterCenter")

-- ═══════════════════════════════════════════════════════════════════════════════
-- ALTIMETER TAPE & READOUT (Right Side)
-- ═══════════════════════════════════════════════════════════════════════════════

local alt_x = 0.74
create_rect(alt_x, 0.08, 0.36, 1.00, 0.003, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("ALT FT", alt_x, 0.54, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")

-- Altitude Digital Box
create_rect(alt_x, 0.08, 0.32, 0.09, 0.004, ScreenBase, materials["WHITE"], materials["SCREEN_BG"])
add_text_param(alt_x, 0.08, "BAROALT", "%05.0f", ScreenBase, fonts["GREEN"], strdefs_LARGE, "CenterCenter")

-- Altitude Tape Tick Marks (every 500 ft)
for a = -4, 4 do
	local ty = 0.08 + (a * 0.09)
	create_line(alt_x - 0.17, ty, alt_x - 0.12, ty, 0.003, ScreenBase, materials["WHITE"])
end

-- Vertical Speed Indicator (VSI tape)
add_text("VSI", alt_x + 0.05, -0.48, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")
add_text_param(alt_x + 0.05, -0.56, "VV", "%+4.0f", ScreenBase, fonts["GREEN"], strdefs_MED, "CenterCenter")

-- ═══════════════════════════════════════════════════════════════════════════════
-- LOWER STATUS & GAUGE DATA
-- ═══════════════════════════════════════════════════════════════════════════════

-- G-Force Readout
create_rect(-0.35, -0.50, 0.22, 0.07, 0.002, ScreenBase, materials["GRAY"], materials["DIAL_BG"])
add_text("G", -0.42, -0.50, ScreenBase, fonts["WHITE"], strdefs_SML, "CenterCenter")
add_text_param(-0.30, -0.50, "GFORCE", "%+3.1f", ScreenBase, fonts["GREEN"], strdefs_MED, "CenterCenter")

-- Angle of Attack (AoA)
create_rect(0.35, -0.50, 0.22, 0.07, 0.002, ScreenBase, materials["GRAY"], materials["DIAL_BG"])
add_text("AOA", 0.27, -0.50, ScreenBase, fonts["WHITE"], strdefs_SML, "CenterCenter")
add_text_param(0.40, -0.50, "AOA", "%4.1f°", ScreenBase, fonts["GREEN"], strdefs_MED, "CenterCenter")

-- Radar Altitude (Bottom Center)
create_rect(0, -0.74, 0.44, 0.09, 0.003, ScreenBase, materials["AMBER"], materials["DIAL_BG"])
add_text("RALT", -0.14, -0.74, ScreenBase, fonts["WHITE"], strdefs_SML, "CenterCenter")
add_text_param(0.06, -0.74, "RADALT", "%4.0f", ScreenBase, fonts["AMBER"], strdefs_LARGE, "CenterCenter")

-- Autopilot Status
add_text("AFCS: NAV / ALT HOLD", 0, -0.86, ScreenBase, fonts["GREEN"], strdefs_SML, "CenterCenter")
