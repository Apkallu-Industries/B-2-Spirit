-- B-2 Spirit PFD — Menu Page
-- Root menu with available sub-page labels

dofile(LockOn_Options.script_path.."PFD/definitions.lua")
dofile(LockOn_Options.script_path.."fonts.lua")

-- Menu background
local BGROUND                = CreateElement "ceTexPoly"
BGROUND.name    			 = "PFD_MENU_BG"
BGROUND.material			 = B2_SCREEN_BG
BGROUND.change_opacity 		 = false
BGROUND.collimated 			 = false
BGROUND.isvisible 			 = true
BGROUND.init_pos 			 = {0, 0, 0}
BGROUND.element_params 		 = {"MFD_OPACITY", "PFD_MENU_PAGE"}
BGROUND.controllers			 = {
	{"opacity_using_parameter", 0},
	{"parameter_in_range", 1, 0.9, 1.1},
}
BGROUND.level 				 = 2
BGROUND.h_clip_relation      = h_clip_relations.COMPARE
local bgW = 2.4
local bgH = 2.0
BGROUND.vertices = {{-bgW/2, bgH/2}, {bgW/2, bgH/2}, {bgW/2, -bgH/2}, {-bgW/2, -bgH/2}}
BGROUND.indices  = {0, 1, 2, 2, 3, 0}
BGROUND.tex_coords = {{0,0}, {1,0}, {1,1}, {0,1}}
Add(BGROUND)

-- ADI label
local ADITEXT                       = CreateElement "ceStringPoly"
ADITEXT.name                        = "pfd_menu_adi"
ADITEXT.material                    = B2_FONT_WHT
ADITEXT.value                       = "ADI"
ADITEXT.stringdefs                  = font_LARGE
ADITEXT.alignment                   = "CenterCenter"
ADITEXT.formats                     = {"%s"}
ADITEXT.h_clip_relation             = h_clip_relations.COMPARE
ADITEXT.level                       = 2
ADITEXT.init_pos                    = {-0.9, 0.42, 0}
ADITEXT.element_params              = {"MFD_OPACITY", "PFD_MENU_PAGE"}
ADITEXT.controllers                 = {
	{"opacity_using_parameter", 0},
	{"parameter_in_range", 1, 0.9, 1.1},
}
Add(ADITEXT)
