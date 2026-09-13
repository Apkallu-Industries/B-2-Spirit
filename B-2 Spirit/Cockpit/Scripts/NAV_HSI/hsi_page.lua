--[[
    B-2 Spirit Stealth Bomber — HSI / Navigation Display (Horizontal Situation Indicator)
    Pilot MFD 4 (Lower Center Screen) & Copilot MFD 8 (Lower WSO Screen)
    Features: 360° Rotating Compass Rose, Bearing Pointer, CDI Needle, Steerpoint Data, Wind Vector
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
-- TOP HEADER & CORNER DATA
-- ═══════════════════════════════════════════════════════════════════════════════

create_rect(0, 0.90, 1.94, 0.12, 0.003, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("B-2A HSI NAV", -0.65, 0.90, ScreenBase, fonts["WHITE"], strdefs_MED, "CenterCenter")

-- Digital Heading Box
create_rect(0, 0.90, 0.28, 0.08, 0.003, ScreenBase, materials["WHITE"], materials["SCREEN_BG"])
add_text_param(0, 0.90, "NAV", "%03.0f°", ScreenBase, fonts["GREEN"], strdefs_LARGE, "CenterCenter")

add_text("MODE: STEERPOINT", 0.60, 0.90, ScreenBase, fonts["GREEN"], strdefs_SML, "CenterCenter")

-- ═══════════════════════════════════════════════════════════════════════════════
-- ROTATING COMPASS ROSE (Center Flight Navigation)
-- ═══════════════════════════════════════════════════════════════════════════════

local compass_center_x = 0.0
local compass_center_y = 0.0
local compass_r        = 0.52

-- Compass Rotating Root (rotates counter to heading: HEADINGCOMPASS)
local compass_rot = CreateElement "ceSimple"
compass_rot.name           = create_guid_string()
compass_rot.init_pos       = {compass_center_x, compass_center_y, 0}
compass_rot.parent_element = ScreenBase.name
compass_rot.element_params = {"HEADINGCOMPASS"}
compass_rot.controllers    = {{"rotate_using_parameter", 0, 1.0}}
AddElement(compass_rot)

-- Outer Compass Ring
local outer_ring = CreateElement "ceMeshPoly"
outer_ring.name           = create_guid_string()
outer_ring.primitivetype  = "triangles"
outer_ring.material       = materials["WHITE"]
outer_ring.parent_element = compass_rot.name
set_circle(outer_ring, compass_r, compass_r - 0.006, 360, 48)
AddElement(outer_ring)

-- Inner Range Circle
local inner_ring = CreateElement "ceMeshPoly"
inner_ring.name           = create_guid_string()
inner_ring.primitivetype  = "triangles"
inner_ring.material       = materials["GRAY"]
inner_ring.parent_element = compass_rot.name
set_circle(inner_ring, compass_r * 0.5, compass_r * 0.5 - 0.003, 360, 36)
AddElement(inner_ring)

-- Compass Ticks and Cardinal Letters (N, E, S, W, 30° numbers)
local cardinals = {
	[0]   = "N",
	[30]  = "3",
	[60]  = "6",
	[90]  = "E",
	[120] = "12",
	[150] = "15",
	[180] = "S",
	[210] = "21",
	[240] = "24",
	[270] = "W",
	[300] = "30",
	[330] = "33",
}

for deg = 0, 350, 10 do
	local rad = math.rad(-deg + 90)
	local is_major = (deg % 30 == 0)
	local is_five  = (deg % 5 == 0)
	local tick_len = is_major and 0.035 or 0.018

	local tick = CreateElement "ceSimpleLineObject"
	tick.name           = create_guid_string()
	tick.material       = is_major and materials["WHITE"] or materials["GRAY"]
	tick.vertices       = {{0, 0}, {0, -tick_len}}
	tick.width          = is_major and 0.004 or 0.0025
	tick.init_pos       = {compass_r * math.cos(rad), compass_r * math.sin(rad)}
	tick.init_rot       = {-deg}
	tick.parent_element = compass_rot.name
	AddElement(tick)

	if cardinals[deg] ~= nil then
		local lbl_rad = math.rad(-deg + 90)
		local lbl_dist = compass_r - 0.065
		local card_txt = add_text(cardinals[deg], lbl_dist * math.cos(lbl_rad), lbl_dist * math.sin(lbl_rad), compass_rot, (deg == 0) and fonts["AMBER"] or fonts["WHITE"], strdefs_TINY, "CenterCenter")
		card_txt.init_rot = {-deg}
	end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- COURSE DEVIATION INDICATOR (CDI) & BEARING NEEDLE
-- ═══════════════════════════════════════════════════════════════════════════════

-- Bearing Pointer (Green needle pointing to steerpoint)
local bearing_needle = CreateElement "ceSimpleLineObject"
bearing_needle.name           = create_guid_string()
bearing_needle.material       = materials["GREEN"]
bearing_needle.vertices       = {{0, compass_r * 0.8}, {0, -compass_r * 0.8}}
bearing_needle.width          = 0.004
bearing_needle.parent_element = compass_rot.name
AddElement(bearing_needle)

-- Arrowhead on bearing pointer
local arrow = CreateElement "ceSimpleLineObject"
arrow.name           = create_guid_string()
arrow.material       = materials["GREEN"]
arrow.vertices       = {{-0.03, compass_r * 0.72}, {0, compass_r * 0.82}, {0.03, compass_r * 0.72}}
arrow.width          = 0.004
arrow.parent_element = compass_rot.name
AddElement(arrow)

-- Course Deviation Dots (±5°, ±10°)
for _, d in ipairs({-0.16, -0.08, 0.08, 0.16}) do
	local dot = CreateElement "ceMeshPoly"
	dot.name           = create_guid_string()
	dot.primitivetype  = "triangles"
	dot.init_pos       = {d, 0, 0}
	dot.material       = materials["WHITE"]
	dot.parent_element = compass_rot.name
	set_circle(dot, 0.008)
	AddElement(dot)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- FIXED AIRCRAFT SYMBOL (B-2 Flying Wing silhouette at center)
-- ═══════════════════════════════════════════════════════════════════════════════

local b2_sym = CreateElement "ceSimpleLineObject"
b2_sym.name           = create_guid_string()
b2_sym.material       = materials["GREEN"]
b2_sym.vertices       = {
	{0, 0.04}, {-0.12, -0.04}, {-0.04, -0.02}, {0, -0.05},
	{0.04, -0.02}, {0.12, -0.04}, {0, 0.04}
}
b2_sym.width          = 0.004
b2_sym.parent_element = ScreenBase.name
AddElement(b2_sym)

-- Top Fixed Lubber Line (White triangle pointing down)
local lubber = CreateElement "ceSimpleLineObject"
lubber.name           = create_guid_string()
lubber.material       = materials["AMBER"]
lubber.vertices       = {{-0.025, compass_r + 0.03}, {0.025, compass_r + 0.03}, {0, compass_r + 0.005}, {-0.025, compass_r + 0.03}}
lubber.width          = 0.003
lubber.parent_element = ScreenBase.name
AddElement(lubber)

-- ═══════════════════════════════════════════════════════════════════════════════
-- FOUR CORNER TACTICAL DATA BLOCKS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Top Left: Airspeed Data
create_rect(-0.68, 0.68, 0.52, 0.22, 0.002, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("TAS", -0.88, 0.74, ScreenBase, fonts["WHITE"], strdefs_TINY, "LeftCenter")
add_text_param(-0.60, 0.74, "TAS", "%03.0f KTS", ScreenBase, fonts["GREEN"], strdefs_SML, "LeftCenter")
add_text("GS", -0.88, 0.62, ScreenBase, fonts["WHITE"], strdefs_TINY, "LeftCenter")
add_text_param(-0.60, 0.62, "IAS", "%03.0f KTS", ScreenBase, fonts["GREEN"], strdefs_SML, "LeftCenter")

-- Top Right: Steerpoint & Waypoint Data
create_rect(0.68, 0.68, 0.52, 0.22, 0.002, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("WPT 01 (TARGET)", 0.45, 0.74, ScreenBase, fonts["CYAN"], strdefs_TINY, "LeftCenter")
add_text("DIST: 38.4 NM", 0.45, 0.66, ScreenBase, fonts["WHITE"], strdefs_TINY, "LeftCenter")
add_text("ETE:  04:48", 0.45, 0.58, ScreenBase, fonts["WHITE"], strdefs_TINY, "LeftCenter")

-- Bottom Left: Wind Data
create_rect(-0.68, -0.68, 0.52, 0.22, 0.002, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("WIND VECTOR", -0.88, -0.62, ScreenBase, fonts["WHITE"], strdefs_TINY, "LeftCenter")
add_text("275° / 18 KTS", -0.88, -0.72, ScreenBase, fonts["GREEN"], strdefs_SML, "LeftCenter")

-- Bottom Right: Radio & Nav Aid
create_rect(0.68, -0.68, 0.52, 0.22, 0.002, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("TACAN: 074X (WHITEMAN)", 0.45, -0.62, ScreenBase, fonts["WHITE"], strdefs_TINY, "LeftCenter")
add_text("ILS:   RWY 01 (109.90)", 0.45, -0.72, ScreenBase, fonts["GREEN"], strdefs_TINY, "LeftCenter")
