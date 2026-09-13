-- B-2 Spirit EICAS (Engine Indication & Crew Alerting System) — Indicator Init

dofile(LockOn_Options.common_script_path.."devices_defs.lua")

indicator_type = indicator_types.COMMON
purposes 	   = {render_purpose.GENERAL}
init_pageID	   = 1

-------PAGE IDs-------
ENG     = 1
MENU    = 2

page_subsets = {
	[ENG]    = LockOn_Options.script_path.."EICAS/eng_page.lua",
	[MENU]   = LockOn_Options.script_path.."EICAS/menu_page.lua",
}

pages = {
	{
		ENG,
		MENU,
	},
}
