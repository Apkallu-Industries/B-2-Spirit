-- B-2 Spirit NAV/HSI — Menu Page

dofile(LockOn_Options.script_path.."NAV_HSI/definitions.lua")
dofile(LockOn_Options.script_path.."fonts.lua")

local BGROUND                = CreateElement "ceTexPoly"
BGROUND.name                 = "NAV_MENU_BG"
BGROUND.material             = B2_SCREEN_BG
BGROUND.init_pos             = {0, 0, 0}
BGROUND.element_params       = {"MFD_OPACITY", "NAV_MENU_PAGE"}
BGROUND.controllers          = {
	{"opacity_using_parameter", 0},
	{"parameter_in_range", 1, 0.9, 1.1},
}
BGROUND.level                = 2
BGROUND.h_clip_relation      = h_clip_relations.COMPARE
BGROUND.collimated           = false
BGROUND.isvisible            = true
local bgW = 2.4
local bgH = 2.0
BGROUND.vertices = {{-bgW/2, bgH/2}, {bgW/2, bgH/2}, {bgW/2, -bgH/2}, {-bgW/2, -bgH/2}}
BGROUND.indices  = {0, 1, 2, 2, 3, 0}
BGROUND.tex_coords = {{0,0}, {1,0}, {1,1}, {0,1}}
Add(BGROUND)

local HSITEXT                   = CreateElement "ceStringPoly"
HSITEXT.name                    = "nav_menu_hsi"
HSITEXT.material                = B2_FONT_WHT
HSITEXT.value                   = "HSI"
HSITEXT.stringdefs              = font_LARGE
HSITEXT.alignment               = "CenterCenter"
HSITEXT.formats                 = {"%s"}
HSITEXT.h_clip_relation         = h_clip_relations.COMPARE
HSITEXT.level                   = 2
HSITEXT.init_pos                = {-0.9, 0.42, 0}
HSITEXT.element_params          = {"MFD_OPACITY", "NAV_MENU_PAGE"}
HSITEXT.controllers             = {
	{"opacity_using_parameter", 0},
	{"parameter_in_range", 1, 0.9, 1.1},
}
Add(HSITEXT)
