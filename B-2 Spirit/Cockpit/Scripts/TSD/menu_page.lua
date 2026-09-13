-- B-2 Spirit TSD — Menu Page

dofile(LockOn_Options.script_path.."TSD/definitions.lua")
dofile(LockOn_Options.script_path.."fonts.lua")

local BGROUND                = CreateElement "ceTexPoly"
BGROUND.name                 = "TSD_MENU_BG"
BGROUND.material             = B2_SCREEN_BG
BGROUND.init_pos             = {0, 0, 0}
BGROUND.element_params       = {"MFD_OPACITY", "TSD_MENU_PAGE"}
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

local STATUSTEXT                = CreateElement "ceStringPoly"
STATUSTEXT.name                 = "tsd_menu_status"
STATUSTEXT.material             = B2_FONT_WHT
STATUSTEXT.value                = "STATUS"
STATUSTEXT.stringdefs           = font_LARGE
STATUSTEXT.alignment            = "CenterCenter"
STATUSTEXT.formats              = {"%s"}
STATUSTEXT.h_clip_relation      = h_clip_relations.COMPARE
STATUSTEXT.level                = 2
STATUSTEXT.init_pos             = {-0.9, 0.42, 0}
STATUSTEXT.element_params       = {"MFD_OPACITY", "TSD_MENU_PAGE"}
STATUSTEXT.controllers          = {
	{"opacity_using_parameter", 0},
	{"parameter_in_range", 1, 0.9, 1.1},
}
Add(STATUSTEXT)
