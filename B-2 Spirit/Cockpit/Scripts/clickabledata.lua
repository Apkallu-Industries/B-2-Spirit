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


dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")
--dofile(LockOn_Options.script_path.."sounds.lua")

local gettext = require("i_18n")
_ = gettext.translate

cursor_mode = 
{ 
    CUMODE_CLICKABLE = 0,
    CUMODE_CLICKABLE_AND_CAMERA  = 1,
    CUMODE_CAMERA = 2,
};

clickable_mode_initial_status  = cursor_mode.CUMODE_CLICKABLE
use_pointer_name			   = true

function default_button(hint_,device_,command_,arg_,arg_val_,arg_lim_)

	local   arg_val_ = arg_val_ or 1
	local   arg_lim_ = arg_lim_ or {0,1}

	return  {	
				class 				= {class_type.BTN},
				hint  				= hint_,
				device 				= device_,
				action 				= {command_},
				stop_action 		= {command_},
				arg 				= {arg_},
				arg_value			= {arg_val_}, 
				arg_lim 			= {arg_lim_},
				use_release_message = {false},
				updatable 	= true, 
			}
end

-- default_1_position_tumb = bouton 2 positions 0 et 1 souris gauche, souris droite inop�rante
function default_1_position_tumb(hint_, device_, command_, arg_, arg_val_, arg_lim_, sound_)
	local   arg_val_ = arg_val_ or 1
	local   arg_lim_ = arg_lim_ or {0,1}
	return  {	
				class 		= {class_type.TUMB},
				hint  		= hint_,
				device 		= device_,
				action 		= {command_},
				arg 	  	= {arg_},
				arg_value 	= {arg_val_}, 
				arg_lim   	= {arg_lim_},
				updatable 	= true, 
				use_OBB 	= true,
				sound = sound_ and {{sound_,sound_}} or nil
			}
end

-- default_2_position_tumb = bouton 2 positions 0 et 1 souris gauche ou souris droite indiff�remment
function default_2_position_tumb(hint_, device_, command_, arg_, sound_)
	return  {	
				class 		= {class_type.TUMB,class_type.TUMB},
				hint  		= hint_,
				device 		= device_,
				action 		= {command_,command_},
				arg 	  	= {arg_,arg_},
				arg_value 	= {-1,1}, 
				arg_lim   	= {{0,1},{0,1}},
				updatable 	= true, 
				use_OBB 	= true,
				sound = sound_ and {{sound_,sound_}} or nil
			}
end

-- default_3_position_tumb = bouton 3 positions -1,0,1 souris gauche ou souris droite indiff�remment
function default_3_position_tumb(hint_,device_,command_,arg_,cycled_,inversed_)
	local cycled = true
	local val =  1
	if inversed_ then
	      val = -1
	end
	if cycled_ ~= nil then
	   cycled = cycled_
	end
	return  {	
				class 		= {class_type.TUMB,class_type.TUMB},
				hint  		= hint_,
				device 		= device_,
				action 		= {command_,command_},
				arg 	  	= {arg_,arg_},
				arg_value 	= {val,-val}, 
				arg_lim   	= {{-1,1},{-1,1}},
				updatable 	= true, 
				use_OBB 	= true,
				cycle       = cycled
			}
end

-- default_axis = bouton rotatif
-- relative_ important
-- de 0 � 1
function default_axis(hint_,device_,command_,arg_, default_, gain_,updatable_,relative_)
	
	local default = default_ or 1
	local gain = gain_ or 0.1
	local updatable = updatable_ or false
	local relative  = relative_ or false
	
	return  {	
				class 		= {class_type.LEV},
				hint  		= hint_,
				device 		= device_,
				action 		= {command_},
				arg 	  	= {arg_},
				arg_value 	= {default}, 
				arg_lim   	= {{0,1}},
				updatable 	= updatable, 
				use_OBB 	= true,
				gain		= {gain},
				relative    = {relative}, 				
			}
end

-- default_movable_axis se d�place avec la souris gauche et renvoie la valeur atteinte
-- default_ mieux si �gal � 0
-- de 0 � 1
function default_movable_axis(hint_,device_,command_,arg_, default_, gain_,updatable_,relative_)
	
	local default = default_ or 1
	local gain = gain_ or 0.1
	local updatable = updatable_ or false
	local relative  = relative_ or false
	
	return  {	
				class 		= {class_type.MOVABLE_LEV},
				hint  		= hint_,
				device 		= device_,
				action 		= {command_},
				arg 	  	= {arg_},
				arg_value 	= {default}, 
				arg_lim   	= {{0,1}},
				updatable 	= updatable, 
				use_OBB 	= true,
				gain		= {gain},
				relative    = {relative}, 				
			}
end

-- default_axis_limited = bouton rotatif
-- relative_ important
-- arg_lim definissable
--[[function default_axis_limited(hint_,device_,command_,arg_, default_, gain_,updatable_,relative_, arg_lim_)
	
	local relative = false
	local default = default_ or 0
	local updatable = updatable_ or false
	if relative_ ~= nil then
		relative = relative_
	end

	local gain = gain_ or 0.1
	return  {	
				class 		= {class_type.LEV},
				hint  		= hint_,
				device 		= device_,
				action 		= {command_},
				arg 	  	= {arg_},
				arg_value 	= {default}, 
				arg_lim   	= {arg_lim_},
				updatable 	= updatable, 
				use_OBB 	= false,
				gain		= {gain},
				relative    = {relative},  
			}
end]]

function default_axis_limited(hint_,device_,command_,arg_, default_, gain_,updatable_,relative_, arg_lim_)
	
	
	local default = default_ or 0
	local gain = gain_ or 0.1
	local updatable = updatable_ or false
	local relative  = relative_ or false
	--[[
	local relative = false
	if relative_ ~= nil then
		relative = relative_
	end
	]]

	return  {	
				class 		= {class_type.LEV},
				hint  		= hint_,
				device 		= device_,
				action 		= {command_},
				arg 	  	= {arg_},
				arg_value 	= {default}, 
				arg_lim   	= {arg_lim_},
				updatable 	= updatable, 
				use_OBB 	= true,--false,
				gain		= {gain},
				relative    = {relative},
				cycle     	= false,
			}
end
-- multiposition_switch = bouton multi-position
-- count_ = nb positions
-- delta_ = valeur entre deux positions
function multiposition_switch(hint_,device_,command_,arg_,count_,delta_,inversed_, min_)
    local min_   = min_ or 0
	local delta_ = delta_ or 0.5
	
	local inversed = 1
	if	inversed_ then
		inversed = -1
	end
	
	return  {	
				class 		= {class_type.TUMB,class_type.TUMB},
				hint  		= hint_,
				device 		= device_,
				action 		= {command_,command_},
				arg 	  	= {arg_,arg_},
				arg_value 	= {-delta_ * inversed,delta_ * inversed}, 
				arg_lim   	= {{min_, min_ + delta_ * (count_ -1)},
							   {min_, min_ + delta_ * (count_ -1)}},
				updatable 	= true, 
				use_OBB 	= true
			}
end
-- multiposition_switch_limited = bouton multi-position non cycled
function multiposition_switch_limited(hint_,device_,command_,arg_,count_,delta_,inversed_,min_,sound_)
    local min_   = min_ or 0
	local delta_ = delta_ or 0.5
	
	local inversed = 1
	if	inversed_ then
		inversed = -1
	end
	
	return  {	
				class 		= {class_type.TUMB,class_type.TUMB},
				hint  		= hint_,
				device 		= device_,
				action 		= {command_,command_},
				arg 	  	= {arg_,arg_},
				arg_value 	= {-delta_ * inversed,delta_ * inversed}, 
				arg_lim   	= {{min_, min_ + delta_ * (count_ -1)},
							   {min_, min_ + delta_ * (count_ -1)}},
				updatable 	= true, 
				use_OBB 	= true,
				cycle     	= false, 
				sound = sound_ and {{sound_,sound_}} or nil
			}
end
-- default_button_axis = bouton rotatif � deux commandes ???
function default_button_axis(hint_, device_,command_1, command_2, arg_1, arg_2, limit_1, limit_2)
	local limit_1_   = limit_1 or 1.0
	local limit_2_   = limit_2 or 1.0
return {
			class		=	{class_type.BTN, class_type.LEV},
			hint		=	hint_,
			device		=	device_,
			action		=	{command_1, command_2},
			stop_action =   {command_1, 0},
			arg			=	{arg_1, arg_2},
			arg_value	= 	{1, 0.5},
			arg_lim		= 	{{0, limit_1_}, {0,limit_2_}},
			animated        = {false,true},
			animation_speed = {0, 0.4},
			gain = {0, 0.1},
			relative	= 	{false, true},
			updatable 	= 	true, 
			use_OBB 	= 	true,
			use_release_message = {true, false}
	}
end
-- default_animated_lever = levier anim�
-- animation_speed_ 0.5 plus lent que 0.8
-- la valeur n'est retourn�e qu'apr�s l'animation
function default_animated_lever(hint_, device_, command_, arg_, animation_speed_,arg_lim_)
local arg_lim__ = arg_lim_ or {0.0,1.0}
return  {	
	class  = {class_type.TUMB, class_type.TUMB},
	hint   	= hint_, 
	device 	= device_,
	action 	= {command_, command_},
	arg 		= {arg_, arg_},
	arg_value 	= {1, 0},
	arg_lim 	= {arg_lim__, arg_lim__},
	updatable  = true, 
	gain 		= {0.1, 0.1},
	animated 	= {true, true},
	animation_speed = {animation_speed_, 0},
	cycle = true
}
end
-- default_button_tumb = bouton � deux commandes
-- bouton gauche commande 1
-- bouton droit commande 2
-- stop_action = {command1_,0}, => le bouton gauche revient au 0, alors que le bouton droit non/ the left button returns to 0, while the right button does not
-- stop_action = {command1_,command2_}, => le bouton gauche et le bouton droit reviennent au 0/ left button and right button return to 0
function default_button_tumb(hint_, device_, command1_, command2_, arg_,style)
	if style == 1 or style == nil then
		stop_action_ = {command1_,0}
	elseif style == 2 then -- speedbrake
		stop_action_ = {command1_,command2_}
	end
	return  {	
				class 		= {class_type.BTN,class_type.TUMB},
				hint  		= hint_,
				device 		= device_,
				action 		= {command1_,command2_},
				stop_action = stop_action_,
				arg 	  	= {arg_,arg_},
				arg_value 	= {-1,1},
				arg_lim   	= {{-1,0},{0,1}},
				updatable 	= true, 
				use_OBB 	= true,
				use_release_message = {true,false}
			}
end

function Switch_Up_Down_Release(hint_, command_, arg_, sound_)
    return {
        class           = {class_type.TUMB, class_type.TUMB},
        hint            = hint_,
        device          = devices.ENGINE_SYSTEM,
		arg 			= {arg_, arg_},
        action          = {command_, command_}, --right click no | left yes up
        stop_action     = {nil, command_},
        arg_value       = {-1,1},
		arg_lim   		= {{-1,0},{0,1}},
        updatable       = true,
		sound = sound_ and {{sound_,sound_}} or nil
    }
end

elements = {}

-- =========================================================================
-- B-2 SPIRIT PUBLIC-REFERENCE COCKPIT — PHYSICAL CLICKABLE CONTRACT
-- All elements map 1:1 to verified physical connectors in B2_DCS_Cockpit_Phase12.EDM
-- =========================================================================

-- 1. Multipurpose Display Units (8 MDUs x 20 OSBs = 160 Perimeter Softkeys)
local mdu_names = {
    "MDU_L_UPPER_OUTBOARD",
    "MDU_L_UPPER_CENTRE",
    "MDU_L_UPPER_INBOARD",
    "MDU_L_LOWER",
    "MDU_R_UPPER_INBOARD",
    "MDU_R_UPPER_CENTRE",
    "MDU_R_UPPER_OUTBOARD",
    "MDU_R_LOWER"
}

local base_osb_cmd = 1000
for mdu_idx, mdu in ipairs(mdu_names) do
    for osb = 1, 20 do
        local connector_name = string.format("%s_OSB_%02d_PNT", mdu, osb)
        local cmd = base_osb_cmd + (mdu_idx - 1) * 20 + osb
        local hint = string.format("%s OSB %02d", mdu, osb)
        local arg_id = 800 + (mdu_idx - 1) * 20 + osb
        elements[connector_name] = default_button(_(hint), devices.MDU_MANAGER or devices.AVIONICS, cmd, arg_id, 1, {0,1}, TOGGLECLICK)
    end
end

-- 2. Right-Station Control & Display Unit (CDU) Keys, LSKs and Brightness
local cdu_cmd_base = 2000
local cdu_keys = {
    ["CDU_KEY_0_PNT"]    = {"0", 0},
    ["CDU_KEY_1_PNT"]    = {"1", 1},
    ["CDU_KEY_2_PNT"]    = {"2", 2},
    ["CDU_KEY_3_PNT"]    = {"3", 3},
    ["CDU_KEY_4_PNT"]    = {"4", 4},
    ["CDU_KEY_5_PNT"]    = {"5", 5},
    ["CDU_KEY_6_PNT"]    = {"6", 6},
    ["CDU_KEY_7_PNT"]    = {"7", 7},
    ["CDU_KEY_8_PNT"]    = {"8", 8},
    ["CDU_KEY_9_PNT"]    = {"9", 9},
    ["CDU_KEY_CLR_PNT"]  = {"CLR", 10},
    ["CDU_KEY_ENT_PNT"]  = {"ENT", 11},
    ["CDU_KEY_COMM_PNT"] = {"COMM", 12},
    ["CDU_KEY_NAV_PNT"]  = {"NAV", 13},
    ["CDU_KEY_IFF_PNT"]  = {"IFF", 14},
    ["CDU_KEY_FPLN_PNT"] = {"FPLN", 15},
    ["CDU_KEY_WPN_PNT"]  = {"WPN", 16},
    ["CDU_KEY_INDX_PNT"] = {"INDX", 17},
    ["CDU_KEY_PWR_PNT"]  = {"PWR", 18},
    ["CDU_LSK_L_1_PNT"]  = {"LSK L1", 19},
    ["CDU_LSK_L_2_PNT"]  = {"LSK L2", 20},
    ["CDU_LSK_L_3_PNT"]  = {"LSK L3", 21},
    ["CDU_LSK_L_4_PNT"]  = {"LSK L4", 22},
    ["CDU_LSK_R_1_PNT"]  = {"LSK R1", 23},
    ["CDU_LSK_R_2_PNT"]  = {"LSK R2", 24},
    ["CDU_LSK_R_3_PNT"]  = {"LSK R3", 25},
    ["CDU_LSK_R_4_PNT"]  = {"LSK R4", 26},
}

for pnt, data in pairs(cdu_keys) do
    local hint = "CDU " .. data[1]
    local cmd = cdu_cmd_base + data[2]
    local arg_id = 900 + data[2]
    elements[pnt] = default_button(_(hint), devices.CDU_SYSTEM or devices.AVIONICS, cmd, arg_id, 1, {0,1}, TOGGLECLICK)
end
elements["CDU_BRT_PNT"] = default_axis_limited(_("CDU Display Brightness"), devices.CDU_SYSTEM or devices.AVIONICS, cdu_cmd_base + 30, 930, 1.0, 0.2, false, false, {0,1})

-- 3. Flight Setting Panels (Dual Pilot/Copilot Autopilot & Nav Selectors)
local fsp_controls = {
    ["FSP_L_CRS_SEL_PNT"]  = {"Pilot Course Select", 1},
    ["FSP_L_HDG_SEL_PNT"]  = {"Pilot Heading Select", 2},
    ["FSP_L_BARO_PNT"]     = {"Pilot Barometric Setting", 3},
    ["FSP_L_CMD_ALT_PNT"]  = {"Pilot Commanded Altitude", 4},
    ["FSP_L_AS_SET_PNT"]   = {"Pilot Airspeed Set", 5},
    ["FSP_L_RALT_SET_PNT"] = {"Pilot Radar Altimeter Min", 6},
    ["FSP_R_CRS_SEL_PNT"]  = {"Copilot Course Select", 7},
    ["FSP_R_HDG_SEL_PNT"]  = {"Copilot Heading Select", 8},
    ["FSP_R_BARO_PNT"]     = {"Copilot Barometric Setting", 9},
    ["FSP_R_CMD_ALT_PNT"]  = {"Copilot Commanded Altitude", 10},
    ["FSP_R_AS_SET_PNT"]   = {"Copilot Airspeed Set", 11},
    ["FSP_R_RALT_SET_PNT"] = {"Copilot Radar Altimeter Min", 12},
}

for pnt, data in pairs(fsp_controls) do
    elements[pnt] = default_axis(_(data[1]), devices.AVIONICS, 3000 + data[2], 940 + data[2], 0.5, 0.1, true, true)
end

-- 4. Aircraft Primary Controls & Subsystem Switches
elements["BATTERY_PNT"]        = default_2_position_tumb(_("Battery Power Switch"), devices.ENGINE_SYSTEM, device_commands.Button_1, 700, TOGGLECLICK)
elements["APU_PNT"]            = Switch_Up_Down_Release(_("Auxiliary Power Unit (APU) Start"), device_commands.Button_2, 701, TOGGLECLICK)
elements["LGEN_PNT"]           = default_2_position_tumb(_("Left Generator Control"), devices.ENGINE_SYSTEM, device_commands.Button_3, 702, TOGGLECLICK)
elements["RGEN_PNT"]           = default_2_position_tumb(_("Right Generator Control"), devices.ENGINE_SYSTEM, device_commands.Button_4, 703, TOGGLECLICK)
elements["MASTER_PNT"]         = default_2_position_tumb(_("Master Arm Switch"), devices.WEAPON_SYSTEM, device_commands.Button_1, 708, 1, {0,1}, TOGGLECLICK)
elements["GEAR_PNT"]           = default_1_position_tumb(_("Landing Gear Handle"), devices.ENGINE_SYSTEM, device_commands.Button_11, 720, 1, {0,1}, TOGGLECLICK)
elements["GEAR_EMERGENCY_PNT"] = default_button(_("Emergency Landing Gear Extension"), devices.ENGINE_SYSTEM, 3500, 721, 1, {0,1}, TOGGLECLICK)
elements["HYD1_PNT"]           = default_2_position_tumb(_("Hydraulic System 1 Isolator"), devices.ENGINE_SYSTEM, 3501, 722, TOGGLECLICK)
elements["HYD2_PNT"]           = default_2_position_tumb(_("Hydraulic System 2 Isolator"), devices.ENGINE_SYSTEM, 3502, 723, TOGGLECLICK)
elements["NAV_PNT"]            = default_2_position_tumb(_("Inertial Navigation Align Switch"), devices.AVIONICS, 3503, 724, TOGGLECLICK)
elements["BIT_PNT"]            = default_button(_("Initiate Built-In Test (BIT)"), devices.AVIONICS, 3504, 725, 1, {0,1}, TOGGLECLICK)
elements["SPEEDBRAKE_PNT"]     = default_1_position_tumb(_("Speedbrake Control Handle"), devices.ENGINE_SYSTEM, 3505, 726, 1, {0,1}, TOGGLECLICK)
elements["FLAP_PNT"]           = default_1_position_tumb(_("Flap Control Handle"), devices.ENGINE_SYSTEM, 3506, 727, 1, {0,1}, TOGGLECLICK)

-- 5. Annunciators
elements["ANN_MASTER_CAUTION_PNT"]   = default_button(_("Master Caution Acknowledge/Reset"), devices.AVIONICS, Keys.PlaneMasterCautionOff or 379, 728, 1, {0,1}, TOGGLECLICK)
elements["ANN_HUD_VALID_PNT"]        = default_button(_("HUD / Display Valid Acknowledge"), devices.AVIONICS, 3507, 729, 1, {0,1}, TOGGLECLICK)
elements["ANN_DISPLAY_DEGRADED_PNT"] = default_button(_("Display Degraded Mode Clear"), devices.AVIONICS, 3508, 730, 1, {0,1}, TOGGLECLICK)

for i,o in pairs(elements) do
	if  o.class[1] == class_type.TUMB or 
	   (o.class[2]  and o.class[2] == class_type.TUMB) or
	   (o.class[3]  and o.class[3] == class_type.TUMB)  then
	   o.updatable = true
	   o.use_OBB   = true
	end
end
