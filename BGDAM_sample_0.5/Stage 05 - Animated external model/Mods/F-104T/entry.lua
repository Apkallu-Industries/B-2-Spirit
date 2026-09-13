declare_plugin("F-104T by Jim Knutson",
{
installed 	 = true, -- if false that will be place holder , or advertising
dirName	  	 = current_mod_path,
version		 = "0.5.0 alpha",		 
state		 = "installed",
info		 = _("The F-104T is a tutorial aircraft loosely based on the F-104 Starfighter.  It is designed simply to illustrate the process of creating your own Mod."),

Skins	= 
	{
		{
			name	= "F-104T",
			dir		= "Theme"
		},
	},
Missions =
	{
		{
			name		= _("F-104T"),
			dir			= "Missions",
			-- CLSID		= "{CLSID5456456346CLSID}",	
		},
	},	
LogBook =
	{
		{
			name		= _("F-104T"),
			type		= "F-104T",
		},
	},	
InputProfiles =
	{
		["F-104T"]     = current_mod_path .. '/Input',
	},
})
---------------------------------------------------------------------------------------
dofile(current_mod_path..'/F-104T.lua')

----------------------------------------------------------------------------------------
make_flyable('F-104T',current_mod_path..'/Cockpit/Scripts/', nil, nil) -- ,{"F-104T Starfighter by Jim Knutson",'F104T'},current_mod_path..'/comm.lua')--make_flyable(obj_name,optional_cockpit path,optional_fm = {mod_of_fm_origin,dll_with_fm})
----------------------------------------------------------------------------------------
plugin_done()-- finish declaration , clear temporal data
