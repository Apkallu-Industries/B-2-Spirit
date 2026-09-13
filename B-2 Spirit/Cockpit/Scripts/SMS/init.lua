-- B-2 Spirit Stores Management System (SMS Display)
-- Copilot MFD 7 (Upper Right WSO Screen)

dofile(LockOn_Options.common_script_path.."devices_defs.lua")

indicator_type = indicator_types.COMMON
purposes       = {render_purpose.GENERAL}
init_pageID    = 1

SMS_PAGE = 1

page_subsets = {
	[SMS_PAGE] = LockOn_Options.script_path.."SMS/sms_page.lua",
}

pages = {
	{
		SMS_PAGE,
	},
}
