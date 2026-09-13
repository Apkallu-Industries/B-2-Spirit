-- B-2 Spirit FCS (Flight Control System & Hydraulics Display)
-- Pilot MFD 3 (Upper Right Screen)

dofile(LockOn_Options.common_script_path.."devices_defs.lua")

indicator_type = indicator_types.COMMON
purposes       = {render_purpose.GENERAL}
init_pageID    = 1

FCS_PAGE = 1

page_subsets = {
	[FCS_PAGE] = LockOn_Options.script_path.."FCS/fcs_page.lua",
}

pages = {
	{
		FCS_PAGE,
	},
}
