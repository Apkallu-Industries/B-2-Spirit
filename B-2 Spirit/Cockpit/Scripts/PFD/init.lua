-- B-2 Spirit PFD (Primary Flight Display) — Indicator Init
-- Registers page subsets and default page

dofile(LockOn_Options.common_script_path.."devices_defs.lua")

indicator_type = indicator_types.COMMON
purposes 	   = {render_purpose.GENERAL}
init_pageID	   = 1

-------PAGE IDs-------
ADI     = 1
MENU    = 2

page_subsets = {
	[ADI]    = LockOn_Options.script_path.."PFD/adi_page.lua",
	[MENU]   = LockOn_Options.script_path.."PFD/menu_page.lua",
}

pages = {
	{
		ADI,
		MENU,
	},
}
