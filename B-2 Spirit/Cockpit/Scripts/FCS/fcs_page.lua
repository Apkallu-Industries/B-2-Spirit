--[[
    B-2 Spirit Stealth Bomber — FCS & Hydraulic Systems Display
    Pilot MFD 3 (Upper Right Screen)
    Features: Quad Fly-by-Wire Status, Flying Wing Elevon/Rudder Schematic, 
              4-Channel Hydraulic System (3000 PSI), 4-Channel Electrical Bus
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
add_text("B-2A FLIGHT CONTROLS", -0.55, 0.90, ScreenBase, fonts["WHITE"], strdefs_MED, "CenterCenter")
add_text("FBW: QUAD CH 1-4 NORM", 0.40, 0.90, ScreenBase, fonts["GREEN"], strdefs_SML, "CenterCenter")

-- ═══════════════════════════════════════════════════════════════════════════════
-- B-2 FLYING WING AEROSURFACE SCHEMATIC
-- ═══════════════════════════════════════════════════════════════════════════════

-- Wing planform outline (W-tail / flying wing trailing edge)
local wing_wire = CreateElement "ceSimpleLineObject"
wing_wire.name           = create_guid_string()
wing_wire.material       = materials["GRAY"]
wing_wire.vertices       = {
	{0, 0.65}, {-0.88, 0.15}, {-0.84, 0.05}, {-0.55, 0.18}, {-0.28, 0.28},
	{-0.15, 0.20}, {0, 0.28}, {0.15, 0.20}, {0.28, 0.28}, {0.55, 0.18},
	{0.84, 0.05}, {0.88, 0.15}, {0, 0.65}
}
wing_wire.width          = 0.003
wing_wire.parent_element = ScreenBase.name
AddElement(wing_wire)

-- Elevon Control Surface Indicators (Left Wing)
-- Outboard Elevon
create_rect(-0.70, 0.12, 0.14, 0.05, 0.003, ScreenBase, materials["GREEN"], materials["DARK_GREEN"])
add_text("L O/B", -0.70, 0.18, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")
add_text("0.0°", -0.70, 0.12, ScreenBase, fonts["GREEN"], strdefs_TINY, "CenterCenter")

-- Mid Elevon
create_rect(-0.45, 0.22, 0.14, 0.05, 0.003, ScreenBase, materials["GREEN"], materials["DARK_GREEN"])
add_text("L MID", -0.45, 0.28, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")
add_text("0.0°", -0.45, 0.22, ScreenBase, fonts["GREEN"], strdefs_TINY, "CenterCenter")

-- Inboard Elevon
create_rect(-0.22, 0.26, 0.14, 0.05, 0.003, ScreenBase, materials["GREEN"], materials["DARK_GREEN"])
add_text("L I/B", -0.22, 0.32, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")
add_text("0.0°", -0.22, 0.26, ScreenBase, fonts["GREEN"], strdefs_TINY, "CenterCenter")

-- Elevon Control Surface Indicators (Right Wing)
-- Inboard Elevon
create_rect(0.22, 0.26, 0.14, 0.05, 0.003, ScreenBase, materials["GREEN"], materials["DARK_GREEN"])
add_text("R I/B", 0.22, 0.32, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")
add_text("0.0°", 0.22, 0.26, ScreenBase, fonts["GREEN"], strdefs_TINY, "CenterCenter")

-- Mid Elevon
create_rect(0.45, 0.22, 0.14, 0.05, 0.003, ScreenBase, materials["GREEN"], materials["DARK_GREEN"])
add_text("R MID", 0.45, 0.28, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")
add_text("0.0°", 0.45, 0.22, ScreenBase, fonts["GREEN"], strdefs_TINY, "CenterCenter")

-- Outboard Elevon
create_rect(0.70, 0.12, 0.14, 0.05, 0.003, ScreenBase, materials["GREEN"], materials["DARK_GREEN"])
add_text("R O/B", 0.70, 0.18, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")
add_text("0.0°", 0.70, 0.12, ScreenBase, fonts["GREEN"], strdefs_TINY, "CenterCenter")

-- Split Drag Rudders (Wing Tips)
create_rect(-0.84, 0.00, 0.12, 0.04, 0.002, ScreenBase, materials["CYAN"], materials["DIAL_BG"])
add_text("L SPLIT 0%", -0.84, -0.05, ScreenBase, fonts["CYAN"], strdefs_TINY, "CenterCenter")

create_rect(0.84, 0.00, 0.12, 0.04, 0.002, ScreenBase, materials["CYAN"], materials["DIAL_BG"])
add_text("R SPLIT 0%", 0.84, -0.05, ScreenBase, fonts["CYAN"], strdefs_TINY, "CenterCenter")

-- Center Pitch Flap (Beaver Tail)
create_rect(0, 0.24, 0.12, 0.04, 0.003, ScreenBase, materials["GREEN"], materials["DARK_GREEN"])
add_text("BEAVER TAIL", 0, 0.18, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")

-- ═══════════════════════════════════════════════════════════════════════════════
-- HYDRAULIC SYSTEMS MATRIX (Systems A, B, C, D — 3000 PSI)
-- ═══════════════════════════════════════════════════════════════════════════════

create_line(-0.95, -0.15, 0.95, -0.15, 0.002, ScreenBase, materials["GRAY"])
add_text("--- 4-CHANNEL HYDRAULIC MATRIX ---", 0, -0.20, ScreenBase, fonts["CYAN"], strdefs_TINY, "CenterCenter")

local hyd_x = {-0.69, -0.23, 0.23, 0.69}
local hyd_names = {"HYD A", "HYD B", "HYD C", "HYD D"}

for i = 1, 4 do
	create_rect(hyd_x[i], -0.38, 0.38, 0.26, 0.003, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
	add_text(hyd_names[i], hyd_x[i], -0.30, ScreenBase, fonts["WHITE"], strdefs_SML, "CenterCenter")
	add_text("3000 PSI", hyd_x[i], -0.38, ScreenBase, fonts["GREEN"], strdefs_LARGE, "CenterCenter")
	add_text("QTY: 98% NORM", hyd_x[i], -0.46, ScreenBase, fonts["WHITE"], strdefs_TINY, "CenterCenter")
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- ELECTRICAL GENERATOR BUS MATRIX (GEN 1, 2, 3, 4)
-- ═══════════════════════════════════════════════════════════════════════════════

create_line(-0.95, -0.56, 0.95, -0.56, 0.002, ScreenBase, materials["GRAY"])
add_text("--- 400 HZ AC / 28V DC ELECTRICAL BUS ---", 0, -0.61, ScreenBase, fonts["CYAN"], strdefs_TINY, "CenterCenter")

local gen_names = {"GEN 1", "GEN 2", "GEN 3", "GEN 4"}
for i = 1, 4 do
	create_rect(hyd_x[i], -0.76, 0.38, 0.20, 0.003, ScreenBase, materials["GREEN"], materials["DIAL_BG"])
	add_text(gen_names[i], hyd_x[i], -0.70, ScreenBase, fonts["WHITE"], strdefs_SML, "CenterCenter")
	add_text("115V / 400Hz", hyd_x[i], -0.76, ScreenBase, fonts["GREEN"], strdefs_SML, "CenterCenter")
	add_text("BUS: ONLINE", hyd_x[i], -0.82, ScreenBase, fonts["GREEN"], strdefs_TINY, "CenterCenter")
end
