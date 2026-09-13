--[[
    B-2 Spirit Stealth Bomber — TSD / Tactical Moving Map (Center Instrument Display)
    Center CID (Center Large Screen between Pilot and Mission Commander)
    Features: Tactical Moving Map, Range Rings (20/40/80 NM), B-2 Silhouette, 
              30-sec Velocity Vector, Waypoint Flight Plan Legs, Threat Radar SAM Rings
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
-- TOP HEADER BAR
-- ═══════════════════════════════════════════════════════════════════════════════

create_rect(0, 0.90, 1.94, 0.12, 0.003, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("B-2A TACTICAL SITUATION DISPLAY", -0.30, 0.90, ScreenBase, fonts["WHITE"], strdefs_MED, "CenterCenter")
add_text("MAP: NORTH-UP", 0.60, 0.90, ScreenBase, fonts["GREEN"], strdefs_SML, "CenterCenter")

-- ═══════════════════════════════════════════════════════════════════════════════
-- TACTICAL RANGE RINGS (Centered slightly below center at aircraft position)
-- ═══════════════════════════════════════════════════════════════════════════════

local ac_x = 0.0
local ac_y = -0.15

-- Range Rings: 15 NM (Inner), 30 NM (Mid), 45 NM (Outer)
local r_inner = 0.25
local r_mid   = 0.48
local r_outer = 0.72

local ring1 = CreateElement "ceMeshPoly"
ring1.name           = create_guid_string()
ring1.primitivetype  = "triangles"
ring1.init_pos       = {ac_x, ac_y, 0}
ring1.material       = materials["GRAY"]
ring1.parent_element = ScreenBase.name
set_circle(ring1, r_inner, r_inner - 0.003, 360, 36)
AddElement(ring1)
add_text("15 NM", ac_x + r_inner + 0.04, ac_y, ScreenBase, fonts["WHITE"], strdefs_TINY, "LeftCenter")

local ring2 = CreateElement "ceMeshPoly"
ring2.name           = create_guid_string()
ring2.primitivetype  = "triangles"
ring2.init_pos       = {ac_x, ac_y, 0}
ring2.material       = materials["GRAY"]
ring2.parent_element = ScreenBase.name
set_circle(ring2, r_mid, r_mid - 0.003, 360, 48)
AddElement(ring2)
add_text("30 NM", ac_x + r_mid + 0.04, ac_y, ScreenBase, fonts["WHITE"], strdefs_TINY, "LeftCenter")

local ring3 = CreateElement "ceMeshPoly"
ring3.name           = create_guid_string()
ring3.primitivetype  = "triangles"
ring3.init_pos       = {ac_x, ac_y, 0}
ring3.material       = materials["GREEN"]
ring3.parent_element = ScreenBase.name
set_circle(ring3, r_outer, r_outer - 0.004, 360, 48)
AddElement(ring3)
add_text("45 NM", ac_x + r_outer + 0.04, ac_y, ScreenBase, fonts["WHITE"], strdefs_TINY, "LeftCenter")

-- Cardinal Heading Ticks on Outer Ring (N, S, E, W)
add_text("N", ac_x, ac_y + r_outer + 0.04, ScreenBase, fonts["AMBER"], strdefs_SML, "CenterCenter")
add_text("S", ac_x, ac_y - r_outer - 0.04, ScreenBase, fonts["WHITE"], strdefs_SML, "CenterCenter")
add_text("E", ac_x + r_outer + 0.05, ac_y, ScreenBase, fonts["WHITE"], strdefs_SML, "CenterCenter")
add_text("W", ac_x - r_outer - 0.05, ac_y, ScreenBase, fonts["WHITE"], strdefs_SML, "CenterCenter")

-- ═══════════════════════════════════════════════════════════════════════════════
-- FLIGHT PLAN ROUTE LEGS & STEERPOINTS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Waypoint 1 (Ingress Point)
local wp1_x = -0.18
local wp1_y =  0.15
create_rect(wp1_x, wp1_y, 0.035, 0.035, 0.003, ScreenBase, materials["CYAN"])
add_text("WP 1 (IP)", wp1_x, wp1_y + 0.04, ScreenBase, fonts["CYAN"], strdefs_TINY, "CenterCenter")

-- Waypoint 2 (Target Point)
local wp2_x = 0.22
local wp2_y = 0.48
create_rect(wp2_x, wp2_y, 0.045, 0.045, 0.004, ScreenBase, materials["AMBER"])
-- Target crosshair in box
create_line(wp2_x - 0.03, wp2_y, wp2_x + 0.03, wp2_y, 0.002, ScreenBase, materials["AMBER"])
create_line(wp2_x, wp2_y - 0.03, wp2_x, wp2_y + 0.03, 0.002, ScreenBase, materials["AMBER"])
add_text("TGT (FACTORY)", wp2_x, wp2_y + 0.05, ScreenBase, fonts["AMBER"], strdefs_TINY, "CenterCenter")

-- Waypoint 3 (Egress Point)
local wp3_x = -0.32
local wp3_y =  0.62
create_rect(wp3_x, wp3_y, 0.035, 0.035, 0.003, ScreenBase, materials["CYAN"])
add_text("WP 3 (EGR)", wp3_x, wp3_y + 0.04, ScreenBase, fonts["CYAN"], strdefs_TINY, "CenterCenter")

-- Flight Route Lines
create_line(ac_x, ac_y, wp1_x, wp1_y, 0.004, ScreenBase, materials["CYAN"])
create_line(wp1_x, wp1_y, wp2_x, wp2_y, 0.004, ScreenBase, materials["CYAN"])
create_line(wp2_x, wp2_y, wp3_x, wp3_y, 0.003, ScreenBase, materials["GRAY"])

-- ═══════════════════════════════════════════════════════════════════════════════
-- THREAT SAM RADAR ENVELOPES (Red Threat Rings)
-- ═══════════════════════════════════════════════════════════════════════════════

-- SA-10 / S-300 Threat Zone around Target
local sam_x = 0.30
local sam_y = 0.38
local sam_r = 0.28
local sam_ring = CreateElement "ceMeshPoly"
sam_ring.name           = create_guid_string()
sam_ring.primitivetype  = "triangles"
sam_ring.init_pos       = {sam_x, sam_y, 0}
sam_ring.material       = materials["RED"]
sam_ring.parent_element = ScreenBase.name
set_circle(sam_ring, sam_r, sam_r - 0.003, 360, 36)
AddElement(sam_ring)
add_text("SA-10 ENVELOPE", sam_x, sam_y - sam_r - 0.02, ScreenBase, fonts["RED"], strdefs_TINY, "CenterCenter")

-- ═══════════════════════════════════════════════════════════════════════════════
-- AIRCRAFT SYMBOL & VELOCITY VECTOR (Center)
-- ═══════════════════════════════════════════════════════════════════════════════

-- B-2 Stealth Chevron Silhouette
local b2_chevron = CreateElement "ceSimpleLineObject"
b2_chevron.name           = create_guid_string()
b2_chevron.material       = materials["GREEN"]
b2_chevron.vertices       = {
	{ac_x, ac_y + 0.045}, {ac_x - 0.09, ac_y - 0.025}, {ac_x - 0.03, ac_y - 0.010},
	{ac_x, ac_y - 0.030}, {ac_x + 0.03, ac_y - 0.010}, {ac_x + 0.09, ac_y - 0.025},
	{ac_x, ac_y + 0.045}
}
b2_chevron.width          = 0.005
b2_chevron.parent_element = ScreenBase.name
AddElement(b2_chevron)

-- Center Datum Dot
local b2_center = CreateElement "ceMeshPoly"
b2_center.name           = create_guid_string()
b2_center.primitivetype  = "triangles"
b2_center.init_pos       = {ac_x, ac_y, 0}
b2_center.material       = materials["GREEN"]
b2_center.parent_element = ScreenBase.name
set_circle(b2_center, 0.008)
AddElement(b2_center)

-- 60-Second Projected Velocity Vector Line (Ahead of nose)
create_line(ac_x, ac_y + 0.045, ac_x, ac_y + 0.22, 0.003, ScreenBase, materials["GREEN"])
create_line(ac_x - 0.015, ac_y + 0.13, ac_x + 0.015, ac_y + 0.13, 0.003, ScreenBase, materials["GREEN"]) -- 30 sec mark
create_line(ac_x - 0.020, ac_y + 0.22, ac_x + 0.020, ac_y + 0.22, 0.003, ScreenBase, materials["GREEN"]) -- 60 sec mark

-- ═══════════════════════════════════════════════════════════════════════════════
-- CORNER TACTICAL DATA
-- ═══════════════════════════════════════════════════════════════════════════════

-- Top Left: Flight State
create_rect(-0.68, 0.72, 0.48, 0.16, 0.002, ScreenBase, materials["GRAY"], materials["DIAL_BG"])
add_text("HDG / GS", -0.88, 0.76, ScreenBase, fonts["WHITE"], strdefs_TINY, "LeftCenter")
add_text_param(-0.55, 0.76, "NAV", "%03.0f°", ScreenBase, fonts["GREEN"], strdefs_SML, "LeftCenter")
add_text("ALT", -0.88, 0.66, ScreenBase, fonts["WHITE"], strdefs_TINY, "LeftCenter")
add_text_param(-0.55, 0.66, "BAROALT", "%05.0f FT", ScreenBase, fonts["GREEN"], strdefs_SML, "LeftCenter")

-- Top Right: Mission Timeline
create_rect(0.68, 0.72, 0.48, 0.16, 0.002, ScreenBase, materials["GRAY"], materials["DIAL_BG"])
add_text("NEXT: WP 1", 0.48, 0.76, ScreenBase, fonts["CYAN"], strdefs_TINY, "LeftCenter")
add_text("DIST: 24.2 NM", 0.48, 0.66, ScreenBase, fonts["WHITE"], strdefs_TINY, "LeftCenter")

-- Bottom Center: Stealth RCS Status
create_rect(0, -0.86, 0.70, 0.08, 0.003, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("STEALTH CONFIG: ALL BAYS CLOSED", 0, -0.86, ScreenBase, fonts["GREEN"], strdefs_SML, "CenterCenter")
