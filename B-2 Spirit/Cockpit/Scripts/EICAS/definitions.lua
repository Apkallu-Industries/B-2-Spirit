-- B-2 Spirit EICAS Definitions
-- Screen geometry and layout constants for engine display

dofile(LockOn_Options.common_script_path.."elements_defs.lua")

tex_scale = 0.004
SetScale(MILLYRADIANS)

DEFAULT_LEVEL = 8
NOCLIP_LEVEL  = DEFAULT_LEVEL - 1
CLIP_LEVEL    = DEFAULT_LEVEL + 1

Centrex = 0
Centrey = 0

ClippingPlaneSize = 1.2
ClippingWidth     = 1.2

-- Font sizing
font_LARGE  = {0.008, 0.008, 0.0004, 0.001}
font_MEDIUM = {0.006, 0.006, 0.0004, 0.001}
font_SMALL  = {0.005, 0.005, 0.0004, 0.001}
font_TINY   = {0.004, 0.004, 0.0000, 0.000}

B2_SCREEN_BG = MakeMaterial(nil, {8, 12, 10, 255})
