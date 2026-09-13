-- B-2 Spirit TSD (Tactical Situation Display) — Indicator Init

dofile(LockOn_Options.common_script_path.."devices_defs.lua")

indicator_type = indicator_types.COMMON
purposes 	   = {render_purpose.GENERAL}
init_pageID	   = 1

-------PAGE IDs-------
STATUS  = 1
MENU    = 2

page_subsets = {
	[STATUS] = LockOn_Options.script_path.."TSD/status_page.lua",
	[MENU]   = LockOn_Options.script_path.."TSD/menu_page.lua",
}

pages = {
	{
		STATUS,
		MENU,
	},
}
