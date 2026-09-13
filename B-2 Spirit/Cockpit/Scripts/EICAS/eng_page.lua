--[[
    B-2 Spirit Stealth Bomber — EICAS Display (Engine Indication & Crew Alerting System)
    Pilot MFD 1 (Left Upper Screen)
    Features: 4× F118-GE-100 Turbofan Dynamic Vector Dials, EGT, Fuel Flow, Oil, Fuel Breakdown, Gear
--]]

dofile(LockOn_Options.script_path .. "B2_MFD_def.lua")

-- Screen Base & Clipping
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

create_rect(0, 0.90, 1.94, 0.12, 0.004, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("B-2A EICAS", -0.65, 0.90, ScreenBase, fonts["WHITE"], strdefs_MED, "CenterCenter")
add_text("4x F118-GE-100", 0.0, 0.90, ScreenBase, fonts["GREEN"], strdefs_MED, "CenterCenter")
add_text("SYS NORM", 0.65, 0.90, ScreenBase, fonts["GREEN"], strdefs_SML, "CenterCenter")

-- ═══════════════════════════════════════════════════════════════════════════════
-- ROW 1: 4× N2 RPM GAUGES (Engines 1, 2, 3, 4)
-- ═══════════════════════════════════════════════════════════════════════════════

local eng_x = {-0.69, -0.23, 0.23, 0.69}
local dial_r = 0.16

-- RPM Section Header
create_line(-0.95, 0.81, 0.95, 0.81, 0.002, ScreenBase, materials["GRAY"])
add_text("--- ENGINE N2 RPM (%) ---", 0, 0.77, ScreenBase, fonts["CYAN"], strdefs_TINY, "CenterCenter")

MakeDial(eng_x[1], 0.54, dial_r, 45, 315, "RPM_1", 100, "ENG 1", "% RPM", ScreenBase, materials["GREEN"], materials["DIAL_BG"])
MakeDial(eng_x[2], 0.54, dial_r, 45, 315, "RPM_2", 100, "ENG 2", "% RPM", ScreenBase, materials["GREEN"], materials["DIAL_BG"])
MakeDial(eng_x[3], 0.54, dial_r, 45, 315, "RPM_3", 100, "ENG 3", "% RPM", ScreenBase, materials["GREEN"], materials["DIAL_BG"])
MakeDial(eng_x[4], 0.54, dial_r, 45, 315, "RPM_4", 100, "ENG 4", "% RPM", ScreenBase, materials["GREEN"], materials["DIAL_BG"])

-- ═══════════════════════════════════════════════════════════════════════════════
-- ROW 2: 4× EGT GAUGES (°C)
-- ═══════════════════════════════════════════════════════════════════════════════

create_line(-0.95, 0.32, 0.95, 0.32, 0.002, ScreenBase, materials["GRAY"])
add_text("--- EXHAUST GAS TEMP (EGT °C) ---", 0, 0.28, ScreenBase, fonts["CYAN"], strdefs_TINY, "CenterCenter")

MakeDial(eng_x[1], 0.08, dial_r, 45, 315, "EGT_1", 1000, "EGT 1", "°C", ScreenBase, materials["AMBER"], materials["DIAL_BG"])
MakeDial(eng_x[2], 0.08, dial_r, 45, 315, "EGT_2", 1000, "EGT 2", "°C", ScreenBase, materials["AMBER"], materials["DIAL_BG"])
MakeDial(eng_x[3], 0.08, dial_r, 45, 315, "EGT_3", 1000, "EGT 3", "°C", ScreenBase, materials["AMBER"], materials["DIAL_BG"])
MakeDial(eng_x[4], 0.08, dial_r, 45, 315, "EGT_4", 1000, "EGT 4", "°C", ScreenBase, materials["AMBER"], materials["DIAL_BG"])

-- ═══════════════════════════════════════════════════════════════════════════════
-- ROW 3: FUEL FLOW (PPH) & OIL PRESSURE (PSI) MATRIX
-- ═══════════════════════════════════════════════════════════════════════════════

create_line(-0.95, -0.17, 0.95, -0.17, 0.002, ScreenBase, materials["GRAY"])

-- Fuel Flow row
add_text("FF PPH", -0.88, -0.23, ScreenBase, fonts["WHITE"], strdefs_TINY, "LeftCenter")
for i = 1, 4 do
	create_rect(eng_x[i], -0.23, 0.20, 0.055, 0.002, ScreenBase, materials["GRAY"], materials["DIAL_BG"])
	add_text_param(eng_x[i], -0.23, "FF_" .. i, "%4.0f", ScreenBase, fonts["GREEN"], strdefs_TINY, "CenterCenter")
end

-- Oil Pressure row
add_text("OIL PSI", -0.88, -0.31, ScreenBase, fonts["WHITE"], strdefs_TINY, "LeftCenter")
for i = 1, 4 do
	create_rect(eng_x[i], -0.31, 0.20, 0.055, 0.002, ScreenBase, materials["GRAY"], materials["DIAL_BG"])
	add_text_param(eng_x[i], -0.31, "OIL_" .. i, "%2.0f", ScreenBase, fonts["GREEN"], strdefs_TINY, "CenterCenter")
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- LOWER PANEL: FUEL SYSTEM & AIRFRAME STATUS
-- ═══════════════════════════════════════════════════════════════════════════════

create_line(-0.95, -0.39, 0.95, -0.39, 0.002, ScreenBase, materials["GRAY"])

-- Fuel Status Box (Left)
create_rect(-0.48, -0.66, 0.90, 0.46, 0.003, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("FUEL TOTAL (LBS)", -0.48, -0.48, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")
add_text_param(-0.48, -0.57, "TOTAL_FUEL_LBS", "%6.0f", ScreenBase, fonts["GREEN"], strdefs_LARGE, "CenterCenter")
add_text("L WING: 48,200", -0.48, -0.68, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")
add_text("CTR TANK: 71,000", -0.48, -0.75, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")
add_text("R WING: 48,200", -0.48, -0.82, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")

-- Airframe & Landing Gear (Right)
create_rect(0.48, -0.66, 0.90, 0.46, 0.003, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
add_text("LANDING GEAR & HYD", 0.48, -0.48, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")

-- Gear indicators
add_text("NOSE", 0.48, -0.56, ScreenBase, fonts["GREEN"], strdefs_TINY, "CenterCenter")
create_rect(0.48, -0.63, 0.14, 0.05, 0.003, ScreenBase, materials["GREEN"], materials["DARK_GREEN"])
add_text("DN", 0.48, -0.63, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")

add_text("L MAIN", 0.24, -0.71, ScreenBase, fonts["GREEN"], strdefs_TINY, "CenterCenter")
create_rect(0.24, -0.78, 0.14, 0.05, 0.003, ScreenBase, materials["GREEN"], materials["DARK_GREEN"])
add_text("DN", 0.24, -0.78, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")

add_text("R MAIN", 0.72, -0.71, ScreenBase, fonts["GREEN"], strdefs_TINY, "CenterCenter")
create_rect(0.72, -0.78, 0.14, 0.05, 0.003, ScreenBase, materials["GREEN"], materials["DARK_GREEN"])
add_text("DN", 0.72, -0.78, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")

add_text("HYD 1-4: 3000 PSI NORM", 0.48, -0.85, ScreenBase, fonts["GREEN"], strdefs_TINY, "CenterCenter")
