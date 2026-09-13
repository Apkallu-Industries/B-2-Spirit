-- B-2 Spirit DMS / RWR (Defensive Management System Display)
-- Copilot MFD 5 (Upper Left WSO Screen)

dofile(LockOn_Options.common_script_path.."devices_defs.lua")

indicator_type = indicator_types.COMMON
purposes       = {render_purpose.GENERAL}
init_pageID    = 1

DMS_PAGE = 1

page_subsets = {
	[DMS_PAGE] = LockOn_Options.script_path.."DMS_RWR/rwr_page.lua",
}

pages = {
	{
		DMS_PAGE,
	},
}
