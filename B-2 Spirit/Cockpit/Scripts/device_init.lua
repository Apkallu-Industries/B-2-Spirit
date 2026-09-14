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
creators[devices.MDU_MANAGER]			 = {"avLuaDevice"		    ,LockOn_Options.script_path.."Systems/mdu_page_manager.lua"}
creators[devices.FUEL_SYSTEM]			 = {"avLuaDevice"		    ,LockOn_Options.script_path.."Systems/Fuel_System.lua"}
creators[devices.FLIGHT_DATA]			 = {"avLuaDevice"		    ,LockOn_Options.script_path.."Systems/Flight_Data.lua"}
--creators[devices.FCS]					 = {"avLuaDevice"			,LockOn_Options.script_path.."Systems/FCS.lua"}

--creators[devices.KNEEBOARD] = {"avKneeboard",LockOn_Options.common_script_path.."KNEEBOARD/device/init.lua"}

indicators = {}
-- Pilot MDU 1 (Left / Upper Outboard): EICAS / Engine Status Matrix
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."EICAS/init.lua",
	nil,
	{
		{"MDU_L_UPPER_OUTBOARD_CENTER", "MDU_L_UPPER_OUTBOARD_DOWN", "MDU_L_UPPER_OUTBOARD_RIGHT"}
	}
}
-- Pilot MDU 2 (Center / Upper Centre): PFD / Primary Flight Display (Attitude / Speed / Alt)
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."PFD/init.lua",
	nil,
	{
		{"MDU_L_UPPER_CENTRE_CENTER", "MDU_L_UPPER_CENTRE_DOWN", "MDU_L_UPPER_CENTRE_RIGHT"}
	}
}
-- Pilot MDU 3 (Right / Upper Inboard): Flight Controls & Systems Status
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."FCS/init.lua",
	nil,
	{
		{"MDU_L_UPPER_INBOARD_CENTER", "MDU_L_UPPER_INBOARD_DOWN", "MDU_L_UPPER_INBOARD_RIGHT"}
	}
}
-- Pilot MDU 4 (Lower): NAV / HSI Compass Rose & Waypoint Steerpoints
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."NAV_HSI/init.lua",
	nil,
	{
		{"MDU_L_LOWER_CENTER", "MDU_L_LOWER_DOWN", "MDU_L_LOWER_RIGHT"}
	}
}
-- Center Instrument Display (CID): Tactical Moving Map / TSD
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."TSD/init.lua",
	nil,
	{
		{"B2_CID_CENTER", "B2_CID_DOWN", "B2_CID_RIGHT"}
	}
}
-- Copilot MDU 5 (Left / Upper Inboard): Tactical / Defensive Management System (DMS / RWR)
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."DMS_RWR/init.lua",
	nil,
	{
		{"MDU_R_UPPER_INBOARD_CENTER", "MDU_R_UPPER_INBOARD_DOWN", "MDU_R_UPPER_INBOARD_RIGHT"}
	}
}
-- Copilot MDU 6 (Center / Upper Centre): Copilot PFD Repeater
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."PFD/init.lua",
	nil,
	{
		{"MDU_R_UPPER_CENTRE_CENTER", "MDU_R_UPPER_CENTRE_DOWN", "MDU_R_UPPER_CENTRE_RIGHT"}
	}
}
-- Copilot MDU 7 (Right / Upper Outboard): Stores Management System (SMS / Weapons & Rotary Bays)
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."SMS/init.lua",
	nil,
	{
		{"MDU_R_UPPER_OUTBOARD_CENTER", "MDU_R_UPPER_OUTBOARD_DOWN", "MDU_R_UPPER_OUTBOARD_RIGHT"}
	}
}
-- Copilot MDU 8 (Lower): Mission Route & Timeline Navigation
indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."NAV_HSI/init.lua",
	nil,
	{
		{"MDU_R_LOWER_CENTER", "MDU_R_LOWER_DOWN", "MDU_R_LOWER_RIGHT"}
	}
}
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
dofile(LockOn_Options.common_script_path.."KNEEBOARD/declare_kneeboard_device.lua")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
