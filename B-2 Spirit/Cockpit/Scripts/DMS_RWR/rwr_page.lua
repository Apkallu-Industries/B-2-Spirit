--[[
    B-2 Spirit Stealth Bomber — DMS Display (Defensive Management System / RWR)
    Copilot MFD 5 (Upper Left Screen)
    Features: 360° Threat Azimuth Scope, Lethal Rings, SAM/AI Emitters,
              Chaff/Flare Countermeasures, ZSR-63 DECM Jammer Status, EMCON Mode
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
add_text("B-2A DEFENSIVE MANAGEMENT (DMS)", -0.40, 0.90, ScreenBase, fonts["WHITE"], strdefs_MED, "CenterCenter")
add_text("RWR: ALL-BAND ESM", 0.55, 0.90, ScreenBase, fonts["GREEN"], strdefs_SML, "CenterCenter")

-- ═══════════════════════════════════════════════════════════════════════════════
-- 360° CIRCULAR RWR THREAT SCOPE
-- ═══════════════════════════════════════════════════════════════════════════════

local scope_x = 0.0
local scope_y = 0.08
local r_outer = 0.52
local r_lethal= 0.32
local r_inner = 0.14

-- Outer Surveillance Ring (Green)
local scope_ring_out = CreateElement "ceMeshPoly"
scope_ring_out.name           = create_guid_string()
scope_ring_out.primitivetype  = "triangles"
scope_ring_out.init_pos       = {scope_x, scope_y, 0}
scope_ring_out.material       = materials["GREEN"]
scope_ring_out.parent_element = ScreenBase.name
set_circle(scope_ring_out, r_outer, r_outer - 0.004, 360, 48)
AddElement(scope_ring_out)

-- Middle Lethal Threat Ring (Amber)
local scope_ring_mid = CreateElement "ceMeshPoly"
scope_ring_mid.name           = create_guid_string()
scope_ring_mid.primitivetype  = "triangles"
scope_ring_mid.init_pos       = {scope_x, scope_y, 0}
scope_ring_mid.material       = materials["AMBER"]
scope_ring_mid.parent_element = ScreenBase.name
set_circle(scope_ring_mid, r_lethal, r_lethal - 0.003, 360, 36)
AddElement(scope_ring_mid)

-- Inner Critical / Launch Warning Ring (Red)
local scope_ring_in = CreateElement "ceMeshPoly"
scope_ring_in.name           = create_guid_string()
scope_ring_in.primitivetype  = "triangles"
scope_ring_in.init_pos       = {scope_x, scope_y, 0}
scope_ring_in.material       = materials["RED"]
scope_ring_in.parent_element = ScreenBase.name
set_circle(scope_ring_in, r_inner, r_inner - 0.003, 360, 24)
AddElement(scope_ring_in)

-- Azimuth Crosshairs (000°, 090°, 180°, 270°)
create_line(scope_x, scope_y + r_inner, scope_x, scope_y + r_outer, 0.002, ScreenBase, materials["GRAY"])
create_line(scope_x, scope_y - r_inner, scope_x, scope_y - r_outer, 0.002, ScreenBase, materials["GRAY"])
create_line(scope_x + r_inner, scope_y, scope_x + r_outer, scope_y, 0.002, ScreenBase, materials["GRAY"])
create_line(scope_x - r_inner, scope_y, scope_x - r_outer, scope_y, 0.002, ScreenBase, materials["GRAY"])

-- 45° Diagonal Ticks
for _, ang in ipairs({45, 135, 225, 315}) do
	local rad = math.rad(-ang + 90)
	create_line(scope_x + r_outer * 0.85 * math.cos(rad), scope_y + r_outer * 0.85 * math.sin(rad),
	            scope_x + r_outer * math.cos(rad), scope_y + r_outer * math.sin(rad), 0.002, ScreenBase, materials["GRAY"])
end

-- Center B-2 Stealth Silhouette
local ownship = CreateElement "ceSimpleLineObject"
ownship.name           = create_guid_string()
ownship.material       = materials["GREEN"]
ownship.vertices       = {
	{scope_x, scope_y + 0.035}, {scope_x - 0.065, scope_y - 0.02}, {scope_x - 0.02, scope_y - 0.01},
	{scope_x, scope_y - 0.025}, {scope_x + 0.02, scope_y - 0.01}, {scope_x + 0.065, scope_y - 0.02},
	{scope_x, scope_y + 0.035}
}
ownship.width          = 0.004
ownship.parent_element = ScreenBase.name
AddElement(ownship)

-- ═══════════════════════════════════════════════════════════════════════════════
-- DETECTED RADAR EMITTERS / THREAT SYMBOLOGY
-- ═══════════════════════════════════════════════════════════════════════════════

-- SA-10 / S-300 Grumble (Bearing 035° at lethal range)
local sa10_rad = math.rad(-35 + 90)
local sa10_x   = scope_x + 0.40 * math.cos(sa10_rad)
local sa10_y   = scope_y + 0.40 * math.sin(sa10_rad)
create_rect(sa10_x, sa10_y, 0.07, 0.06, 0.003, ScreenBase, materials["AMBER"], materials["DIAL_BG"])
add_text("10", sa10_x, sa10_y, ScreenBase, fonts["AMBER"], strdefs_TINY, "CenterCenter")

-- EWR Early Warning Radar (Bearing 110° outer range)
local ewr_rad = math.rad(-110 + 90)
local ewr_x   = scope_x + 0.48 * math.cos(ewr_rad)
local ewr_y   = scope_y + 0.48 * math.sin(ewr_rad)
create_rect(ewr_x, ewr_y, 0.08, 0.06, 0.002, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("EW", ewr_x, ewr_y, ScreenBase, fonts["GREEN"], strdefs_TINY, "CenterCenter")

-- Interceptor Airborne Radar (Bearing 310° outer range)
local ai_rad = math.rad(-310 + 90)
local ai_x   = scope_x + 0.46 * math.cos(ai_rad)
local ai_y   = scope_y + 0.46 * math.sin(ai_rad)
create_rect(ai_x, ai_y, 0.08, 0.06, 0.003, ScreenBase, materials["RED"], materials["DIAL_BG"])
add_text("29", ai_x, ai_y, ScreenBase, fonts["RED"], strdefs_TINY, "CenterCenter")

-- ═══════════════════════════════════════════════════════════════════════════════
-- COUNTERMEASURES & JAMMER STATUS (Sides & Bottom)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Left Box: Chaff & Flare Countermeasures
create_rect(-0.72, -0.62, 0.46, 0.36, 0.003, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("COUNTERMEASURES", -0.72, -0.48, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")
add_text("CHAFF: 120", -0.72, -0.57, ScreenBase, fonts["GREEN"], strdefs_MED, "CenterCenter")
add_text("FLARE:  60", -0.72, -0.66, ScreenBase, fonts["GREEN"], strdefs_MED, "CenterCenter")
add_text("MODE: AUTO-STANDBY", -0.72, -0.74, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")

-- Right Box: ZSR-63 DECM Jammer Status
create_rect(0.72, -0.62, 0.46, 0.36, 0.003, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("ZSR-63 DECM JAMMER", 0.72, -0.48, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")
add_text("RF JAM: STANDBY", 0.72, -0.57, ScreenBase, fonts["AMBER"], strdefs_MED, "CenterCenter")
add_text("IR SUPPR: ACTIVE", 0.72, -0.66, ScreenBase, fonts["GREEN"], strdefs_MED, "CenterCenter")
add_text("LPI RADAR: SILENT", 0.72, -0.74, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")

-- Bottom Center: Stealth EMCON Status
create_rect(0, -0.86, 0.74, 0.08, 0.003, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("EMCON LEVEL 1: EMISSION SILENT", 0, -0.86, ScreenBase, fonts["GREEN"], strdefs_SML, "CenterCenter")
