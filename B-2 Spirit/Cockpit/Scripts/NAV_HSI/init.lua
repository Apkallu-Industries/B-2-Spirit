-- B-2 Spirit NAV/HSI (Navigation / Horizontal Situation Indicator) — Indicator Init

dofile(LockOn_Options.common_script_path.."devices_defs.lua")

indicator_type = indicator_types.COMMON
purposes 	   = {render_purpose.GENERAL}
init_pageID	   = 1

-------PAGE IDs-------
HSI     = 1
MENU    = 2

page_subsets = {
	[HSI]    = LockOn_Options.script_path.."NAV_HSI/hsi_page.lua",
	[MENU]   = LockOn_Options.script_path.."NAV_HSI/menu_page.lua",
}

pages = {
	{
		HSI,
		MENU,
	},
}
