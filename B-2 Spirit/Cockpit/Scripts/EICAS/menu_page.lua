-- B-2 Spirit EICAS — Menu Page

dofile(LockOn_Options.script_path.."EICAS/definitions.lua")
dofile(LockOn_Options.script_path.."fonts.lua")

local BGROUND                = CreateElement "ceTexPoly"
BGROUND.name                 = "EICAS_MENU_BG"
BGROUND.material             = B2_SCREEN_BG
BGROUND.init_pos             = {0, 0, 0}
BGROUND.element_params       = {"MFD_OPACITY", "EICAS_MENU_PAGE"}
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

local ENGTEXT                   = CreateElement "ceStringPoly"
ENGTEXT.name                    = "eicas_menu_eng"
ENGTEXT.material                = B2_FONT_WHT
ENGTEXT.value                   = "ENG"
ENGTEXT.stringdefs              = font_LARGE
ENGTEXT.alignment               = "CenterCenter"
ENGTEXT.formats                 = {"%s"}
ENGTEXT.h_clip_relation         = h_clip_relations.COMPARE
ENGTEXT.level                   = 2
ENGTEXT.init_pos                = {-0.9, 0.42, 0}
ENGTEXT.element_params          = {"MFD_OPACITY", "EICAS_MENU_PAGE"}
ENGTEXT.controllers             = {
	{"opacity_using_parameter", 0},
	{"parameter_in_range", 1, 0.9, 1.1},
}
Add(ENGTEXT)
