-- B-2 Spirit PFD Definitions
-- Screen geometry, font sizing, clipping, and layout constants

dofile(LockOn_Options.common_script_path.."elements_defs.lua")

tex_scale = 0.004
SetScale(MILLYRADIANS)

DEFAULT_LEVEL = 8
NOCLIP_LEVEL  = DEFAULT_LEVEL - 1
CLIP_LEVEL    = DEFAULT_LEVEL + 1

-- Screen center offset
Centrex = 0
Centrey = 0

-- Clipping rectangle (half-width/height in milliradians)
local Fond_MFD_sizeX = 125
local Fond_MFD_sizeY = 115

-- Screen clipping polygon
verts_MFD = {
	{0, 0},
	{-Fond_MFD_sizeX,  Fond_MFD_sizeY - 4},
	{-Fond_MFD_sizeX, -Fond_MFD_sizeY + 4},
	{-Fond_MFD_sizeX + 4, -Fond_MFD_sizeY},
	{ Fond_MFD_sizeX - 4, -Fond_MFD_sizeY},
	{ Fond_MFD_sizeX, -Fond_MFD_sizeY + 4},
	{ Fond_MFD_sizeX,  Fond_MFD_sizeY - 4},
	{ Fond_MFD_sizeX - 4,  Fond_MFD_sizeY},
	{-Fond_MFD_sizeX + 4,  Fond_MFD_sizeY},
}

inds_MFD = {
	0,1,2, 0,2,3, 0,3,4, 0,4,5, 0,5,6, 0,6,7, 0,7,8, 0,8,1
}

-- Clipping size for screen overlay
ClippingPlaneSize = 1.2
ClippingWidth     = 1.2

-- Font sizing constants
local hTAC = 0.0105
local lTAC = 0.0120
local eTAC = 0.0017
font_TAC = {hTAC, lTAC, eTAC, 0.0}

-- Standard label font sizes
font_LARGE = {0.008, 0.008, 0.0004, 0.001}
font_MEDIUM = {0.006, 0.006, 0.0004, 0.001}
font_SMALL  = {0.005, 0.005, 0.0004, 0.001}
font_TINY   = {0.004, 0.004, 0.0000, 0.000}

-- Helper function for quad vertices
function make_quad(w, h)
	local hw = w / 2
	local hh = h / 2
	return {{-hw, hh}, {hw, hh}, {hw, -hh}, {-hw, -hh}}
end

B2_SCREEN_BG = MakeMaterial(nil, {8, 12, 10, 255})
