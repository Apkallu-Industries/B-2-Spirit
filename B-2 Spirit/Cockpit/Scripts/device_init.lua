--[[
    Grinnelli Designs F-22A Raptor
    Copyright (C) 2024, Joseph Grinnelli
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see https://www.gnu.org/licenses.
--]]


mount_vfs_texture_archives("Bazar/Textures/AvionicsCommon")

dofile(LockOn_Options.common_script_path.."tools.lua")
dofile(LockOn_Options.script_path.."devices.lua")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
layoutGeometry = {}
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
MainPanel = {"ccMainPanel",LockOn_Options.script_path.."mainpanel_init.lua"}
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
attributes = {
	"support_for_cws",
}
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
creators = {}
creators[devices.AVIONICS]			 	 = {"avLuaDevice"		    ,LockOn_Options.script_path.."Systems/Avionics.lua"}
creators[devices.ELECTRICAL_SYSTEM]		 = {"avLuaDevice"		    ,LockOn_Options.script_path.."Systems/Electrical_System.lua"}
creators[devices.ENGINE_SYSTEM]			 = {"avLuaDevice"		    ,LockOn_Options.script_path.."Systems/Engine_System.lua"}
creators[devices.WEAPON_SYSTEM]			 = {"avLuaDevice"		    ,LockOn_Options.script_path.."Systems/Weapon_System.lua"}
creators[devices.MFD_SYSTEM]			 = {"avLuaDevice"		    ,LockOn_Options.script_path.."Systems/MFD_System.lua"}
creators[devices.PMFD_SYSTEM]			 = {"avLuaDevice"		    ,LockOn_Options.script_path.."Systems/PMFD_System.lua"}
creators[devices.ICP_SYSTEM]			 = {"avLuaDevice"		    ,LockOn_Options.script_path.."Systems/ICP_System.lua"}
--creators[devices.FCS]					 = {"avLuaDevice"			,LockOn_Options.script_path.."Systems/FCS.lua"}

--creators[devices.KNEEBOARD] = {"avKneeboard",LockOn_Options.common_script_path.."KNEEBOARD/device/init.lua"}

indicators = {}
-- Pilot MFD 1 (Left): EICAS / Engine Status Matrix
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."EICAS/init.lua",
	nil,
	{
		{"B2_MFD1_CENTER", "B2_MFD1_DOWN", "B2_MFD1_RIGHT"}
	}
}
-- Pilot MFD 2 (Center): PFD / Primary Flight Display (Attitude / Speed / Alt)
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."PFD/init.lua",
	nil,
	{
		{"B2_MFD2_CENTER", "B2_MFD2_DOWN", "B2_MFD2_RIGHT"}
	}
}
-- Pilot MFD 3 (Right): Flight Controls & Systems Status
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."FCS/init.lua",
	nil,
	{
		{"B2_MFD3_CENTER", "B2_MFD3_DOWN", "B2_MFD3_RIGHT"}
	}
}
-- Pilot MFD 4 (Lower): NAV / HSI Compass Rose & Waypoint Steerpoints
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."NAV_HSI/init.lua",
	nil,
	{
		{"B2_MFD4_CENTER", "B2_MFD4_DOWN", "B2_MFD4_RIGHT"}
	}
}
-- Center Instrument Display (CID): Tactical Moving Map / TSD
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."TSD/init.lua",
	nil,
	{
		{"B2_CID_CENTER", "B2_CID_DOWN", "B2_CID_RIGHT"}
	}
}
-- Copilot MFD 5 (Left): Tactical / Defensive Management System (DMS / RWR)
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."DMS_RWR/init.lua",
	nil,
	{
		{"B2_MFD5_CENTER", "B2_MFD5_DOWN", "B2_MFD5_RIGHT"}
	}
}
-- Copilot MFD 6 (Center): Copilot PFD Repeater
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."PFD/init.lua",
	nil,
	{
		{"B2_MFD6_CENTER", "B2_MFD6_DOWN", "B2_MFD6_RIGHT"}
	}
}
-- Copilot MFD 7 (Right): Stores Management System (SMS / Weapons & Rotary Bays)
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."SMS/init.lua",
	nil,
	{
		{"B2_MFD7_CENTER", "B2_MFD7_DOWN", "B2_MFD7_RIGHT"}
	}
}
-- Copilot MFD 8 (Lower): Mission Route & Timeline Navigation
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."NAV_HSI/init.lua",
	nil,
	{
		{"B2_MFD8_CENTER", "B2_MFD8_DOWN", "B2_MFD8_RIGHT"}
	}
}
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
dofile(LockOn_Options.common_script_path.."KNEEBOARD/declare_kneeboard_device.lua")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
