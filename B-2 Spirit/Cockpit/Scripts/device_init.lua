-- B-2 Spirit Device Initialization
-- Mirrors F-22A device_init.lua structure

mount_vfs_texture_archives("Bazar/Textures/AvionicsCommon")

dofile(LockOn_Options.common_script_path.."tools.lua")
dofile(LockOn_Options.script_path.."devices.lua")
--------------------------------------------------------------------------------------------------------------------
layoutGeometry = {}
--------------------------------------------------------------------------------------------------------------------
MainPanel = {"ccMainPanel", LockOn_Options.script_path.."mainpanel_init.lua"}
--------------------------------------------------------------------------------------------------------------------
attributes = {
	"support_for_cws",
}
--------------------------------------------------------------------------------------------------------------------
dofile(LockOn_Options.common_script_path.."KNEEBOARD/declare_kneeboard_device.lua")
--------------------------------------------------------------------------------------------------------------------
creators = {}
indicators = {}
