--mounting 3d model paths and texture paths 

mount_vfs_model_path	(current_mod_path.."/Shapes")
mount_vfs_liveries_path (current_mod_path.."/Liveries")
mount_vfs_texture_path  (current_mod_path.."/Textures/Avionics")
mount_vfs_texture_path  (current_mod_path.."/Textures/F-104T.zip")


F_104T =  {
        
	Name 				=   'F-104T',
	DisplayName			= _('F-104T'),
	
	HumanCockpit 		= true,
	HumanCockpitPath    = current_mod_path..'/Cockpit/Scripts/',
	
	Picture 			= "../../../../../Mods/aircraft/F-104T/F-104T.png",
	Rate 				= 40, -- RewardPoint in Multiplayer
	Shape 				= "F-104T",
	
	shape_table_data 	= 
	{
		{
			file  	 = 'F-104T';
			life  	 = 18; -- lifebar
			vis   	 = 3; -- visibility gain.
			desrt    = 'F-104T_destr'; -- Name of destroyed object file name
			fire  	 = { 300, 2}; -- Fire on the ground after destoyed: 300sec 2m
			username = 'F-104T';
			index    =  WSTYPE_PLACEHOLDER;
		},
		{
			name  = "F-104T_destr";
			file  = "F-104T-destr";
			fire  = { 240, 2};
		},

	},
	mapclasskey 		= "P0091000025",
	attribute  			= {wsType_Air, wsType_Airplane, wsType_Fighter, WSTYPE_PLACEHOLDER ,"Battleplanes",},
	Categories 			= {"{78EFB7A2-FD52-4b57-A6A6-3BF0E1D6555F}", "Interceptor",},	
	-------------------------
	M_empty 					= 6350, -- kg
	M_nominal 					= 7393, -- kg ~ %50 fuel, combat load
	M_max 						= 13170, -- kg
	M_fuel_max 					= 2641, -- kg --2225
	H_max 					 	= 15000, -- m
	average_fuel_consumption 	= 0.41, -- this is highly relative, but good estimates are 36-40l/min = 28-31kg/min = 0.47-0.52kg/s -- 45l/min = 35kg/min = 0.583kg/s
	CAS_min 					= 50, -- if this is not OVERAL FLIGHT TIME, but jus LOITER TIME, than it sholud be 10-15 minutes.....CAS capability in minute (for AI)
	V_opt 						= 253, -- cruise m/s (for AI) M0.8 @ 20,000 ft
	V_take_off 					= 98, -- Take off speed in m/s (for AI) ~ 190 kts
	V_land 						= 113, -- Land speed in m/s (for AI) ~ 220 kts
	V_max_sea_level 			= 408, -- Max speed at sea level in m/s (for AI) ~ 1.2 Mach
	V_max_h 					= 649, -- Max speed at max altitude in m/s (for AI) ~ 2.2 Mach @ 36000' = 1262 kts = 649 m / s
	Vy_max 						= 206, -- Max climb speed in m/s (for AI) ~ 400 kts TAS @ 10000'
	Mach_max 					= 2.35, -- Max speed in Mach (for AI)
	Ny_min 						= -2.8, -- Min G (for AI)
	Ny_max 						= 7.33,  -- Max G (for AI)
	Ny_max_e 					= 7.33,  -- Max G (for AI)
	AOA_take_off 				= 0.17, -- AoA in take off (for AI)
	bank_angle_max 				= 60, -- Max bank angle (for AI)


	has_afteburner 				= true, -- AFB yes/no
	has_speedbrake 				= true, -- Speedbrake yes/no
	nose_gear_pos 				= {  3.3,	-1.448,	0}, -- nosegear coord 
	main_gear_pos 				= { -1.5,	-1.45,	2}, -- main gear coords 
	tand_gear_max 				= 0.466, -- +/- 25 degrees
	tanker_type 				= 0, -- Tanker type if the plane is airrefuel capable
	wing_area 					= 18.22, -- wing area in m2
	wing_span 					= 6.36, -- wing spain in m
	wing_type 					= 0,	-- FIXED
	thrust_sum_max 				= 5394, -- thrust in kg (52.9 kN)
	thrust_sum_ab 				= 8086, -- thrust inkg (79.3 kN)
	length 						= 16.66, -- full lenght in m
	height 						= 4.09, -- height in m
	flaps_maneuver 				= 0.5, -- Max flaps in take-off and maneuver (0.5 = 1st stage; 1.0 = 2nd stage) (for AI)
	range 						= 2623, -- Max range in km (for AI)
	RCS 						= 3.38, -- Radar Cross Section m2
	IR_emission_coeff 			= 0.5, -- Normal engine -- IR_emission_coeff = 1 is Su-27 without afterburner. It is reference.
	IR_emission_coeff_ab 		= 2, -- With afterburner
	wing_tip_pos 				=  {-1.268,	-0.69, 4.014}, -- wingtip coords for visual effects
	nose_gear_wheel_diameter 	= 0.400, -- in m
	main_gear_wheel_diameter 	= 0.400, -- in m
	brakeshute_name 			= 3, -- Landing - brake chute visual shape after separation
	is_tanker 					= false, -- Tanker yes/no
	air_refuel_receptacle_pos 	= {0, 0, 0}, -- refuel coords
	engines_count				= 1, -- Engines count
	engines_nozzles = {
		[1] = 
		{
			pos 		=  {-6.027,	0.46,	0}, -- nozzle coords
			elevation   =  2.5, -- AFB cone elevation (positive is flame goes up)
			diameter	 = 1, -- AFB cone diameter
			exhaust_length_ab   = 5.5, -- length in m
			exhaust_length_ab_K = 0.76, -- AB animation
			smokiness_level = 0.5,
		}, -- end of [1]
	}, -- end of engines_nozzles
	crew_size	 = 1,
	crew_members = 
	{
		[1] = 
		{
			ejection_seat_name = 18,	-- Martin Baker seat object model
			drop_canopy_name = "F-104T_canopy",
			pos =  {4,	1,	0},
			canopy_pos = {0,	0,	0},
		}, -- end of [1]
	}, -- end of crew_members

	fires_pos = 
		{
			[1] = 	{-2.117,	-0.9,	0},
			[2] = 	{-1.584,	0.176,	2.693},
			[3] = 	{-1.645,	0.213,	-2.182},
			[4] = 	{-0.82,	0.265,	2.774},
			[5] = 	{-0.82,	0.265,	-2.774},
			[6] = 	{-0.82,	0.255,	4.274},
			[7] = 	{-0.82,	0.255,	-4.274},
			[8] = 	{-6.027,	0.46,	0},		-- engine contrail positions, engines 1
			[9] = 	{-6.548,	-0.248,	0},		-- engine 2
			[10] = 	{0.304,	-0.748,	0.442},		-- engine 3
			[11] = 	{0.304,	-0.748,	-0.442},	-- engine 4
		}, -- end of fires_pos
	
	
	-- Countermeasures
	SingleChargeTotal	 	= 60,
	CMDS_Incrementation 	= 15,
	ChaffDefault 			= 30, 
	ChaffChargeSize 		= 1,
	FlareDefault 			= 15, 
	FlareChargeSize 		= 2,
	CMDS_Edit 				= false,
	chaff_flare_dispenser 	= {
		[1] = 
		{
			dir =  {-1,0,0},	-- dispenses to rear
			pos =  {-6, 0, -0.8},	-- left rear of fuselage
		}, -- end of [1]
	}, -- end of chaff_flare_dispenser

	--sensors
	
	detection_range_max		 = 60,
	radar_can_see_ground 	 = false, -- this should be examined (what is this exactly?)
	CanopyGeometry = {
		azimuth   = {-160.0, 160.0}, -- pilot view horizontal (AI)
		elevation = {-40.0, 90.0} -- pilot view vertical (AI)
	},
	Sensors = {
		RWR = "Abstract RWR", -- RWR type
		RADAR = "AN/APQ-120", -- Radar type
	},
	HumanRadio = {
		frequency = 251.0,  -- Radio Freq
		editable = true,
		minFrequency = 225.000,
		maxFrequency = 399.975,
		modulation = MODULATION_AM
	},
	
	
	Guns = {gun_mount("M_61", { count = 725 }, 
							  { muzzle_pos_connector = "GUN_POINT", muzzle_pos = {6.103, -0.496, -0.406}, elevation_initial = 2.000}
					 )
		   },
	
	Pylons =     {
		-- center of left wing tip
        pylon(1, 0, -0.513, -0.355, -3.398,
            {
				use_full_connector_position=true,
            },
            {
				{ CLSID = "{9BFD8C90-F7AE-4e90-833B-BFD0CED0E536}" }, --    AIM-9P
            }
        ),
		-- left wing pylon
        pylon(2, 0, -0.128, -0.571, -1.95,
            {
				use_full_connector_position=true,
            },
            {
				{ CLSID = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}" }, -- "Mk-82"
				{ CLSID = "{7A44FF09-527C-4B7E-B42B-3F111CFE50FB}" }, -- "Mk-83"
				{ CLSID = "{FD90A1DC-9147-49FA-BF56-CB83EF0BD32B}"}, -- LAU-61 2.75x19 (closest LAU-3 equiv)
            }
        ),
		-- fuselage ventral
        pylon(3, 1, -0.555000, -0.884000, 0,
            {
				use_full_connector_position=true,
            },
            {
				{ CLSID = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}" }, -- "Mk-82"
				{ CLSID = "{7A44FF09-527C-4B7E-B42B-3F111CFE50FB}" }, -- "Mk-83"
                { CLSID = "{AB8B8299-F1CC-4359-89B5-2172E0CF4A5A}" }, -- Mk-84
            }
        ),
		-- right wing pylon
		pylon(4, 0, -0.128, -0.571, 1.95,
            {
				use_full_connector_position=true,
			},
            {
				{ CLSID = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}" }, -- "Mk-82"
				{ CLSID = "{7A44FF09-527C-4B7E-B42B-3F111CFE50FB}" }, -- "Mk-83"
				{ CLSID = "{FD90A1DC-9147-49FA-BF56-CB83EF0BD32B}"}, -- LAU-61 2.75x19 (closest LAU-3 equiv)
            }
		),
		-- right wing tip
		pylon(5, 0, -0.514, -0.355, 3.398,
            {
				use_full_connector_position=true,
			},
            {
				{ CLSID = "{9BFD8C90-F7AE-4e90-833B-BFD0CED0E536}" }, --    AIM-9P
            }
		),
    },
	
	Tasks = {
        aircraft_task(GroundAttack),
        --aircraft_task(RunwayAttack),
        --aircraft_task(PinpointStrike),
        --aircraft_task(CAS),
        --aircraft_task(AFAC),
		--aircraft_task(CAP),
        --aircraft_task(Escort),
        aircraft_task(FighterSweep),
        aircraft_task(Intercept),
    },	
	DefaultTask = aircraft_task(Intercept),
	
	SFM_Data = {
		aerodynamics = -- Cx = Cx_0 + Cy^2*B2 +Cy^4*B4
		{
			Cy0			=	0,      -- zero AoA lift coefficient
			Mzalfa		=	2, -- 4.355,	-- tail pitch coefficient M0.9
			Mzalfadt	=	0.5, -- 0.8,	-- wing pitch coefficient M0.9
			kjx			=	2.150,	-- roll acceleration rate in rad/sec
			kjz			=	0.00125, -- 0.0011, -- elevator or stab control power coefficient / pitch damping coefficient
			Czbe		=	-0.34,  -- directional stability coefficient, along Z axis (perpendicular), affects yaw, negative value means force orientation in FC coordinate system
			cx_gear		=	0.006,  -- coefficient, drag, gear
			cx_flap		=	0.184,  -- coefficient, drag, full flaps
			cy_flap		=	0.37,   -- coefficient, normal force, lift, flaps
			cx_brk		=	0.014,  -- coefficient, drag, breaks
			table_data  = 
			{	--      M		Cx0		 Cya		B	B4	    Omxmax		Aldop		Cymax
				[1] = 	{0,	    0.015,	0.009,	0.175,	0,		0,			15,			1.17},
				[2] = 	{0.2,	0.015,	0.043,	0.175,	0,		3.197,		15,			1.17},
				[3] = 	{0.4,	0.015,	0.064,	0.175,	0,		3.014,		15,			0.935},
				[4] = 	{0.6,	0.015,	0.065,	0.175,	0,		1.911,		15,			0.875},
				[5] = 	{0.7,	0.015,	0.071,	0.175,	0,		2.243,		15,			0.845},
				[6] = 	{0.8,	0.015,	0.072,	0.175,	0,		2.580,		15,			0.865},
				[7] = 	{0.9,	0.018,	0.078,	0.175,	0,		2.923,		15,			0.985},
				[8] = 	{1	,	0.045,	0.089,	0.175,	0,		3.161,		15,			1.185},
				[9] = 	{1.05,	0.046,	0.087,	0.189,	0,		3.049,		15,			1.185},
				[10] = 	{1.1,	0.047,	0.086,	0.204,	0,		2.938,		15,			1.185},
				[11] = 	{1.2,	0.047,	0.080,	0.218,	0,		3.210,		15,			1},
				[12] = 	{1.3,	0.048,	0.074,	0.235,	0,		2.056,		15,			1},
				[13] = 	{1.5,	0.050,	0.063,	0.278,	0,		2.180,		13,			1},
				[14] = 	{1.7,	0.04,	0.051,	0.339,	0,		2.113,		12,			0.8},
				[15] = 	{1.8,	0.035,	0.046,	0.381,	0,		2.219,		11.4,		0.7},
				[16] = 	{2,	    0.025,	0.034,	0.506,	0,		2.399,		10.2,		0.6},
				[17] = 	{2.1,	0.02,	0.029,	0.606,	0,		2.47,		9.6,		0.6},
				[18] = 	{2.2,	0.015,	0.023,	0.755,	0,		2.525,		9,			0.6},
				[19] = 	{3.9,	0.035,	0.033,	0.35,	0,		0.7,		9,			0.6},
			}, -- end of table_data
			-- M - Mach number
			-- Cx0 - Coefficient, drag, profile, of the airplane
			-- Cya - Normal force coefficient of the wing and body of the aircraft in the normal direction to that of flight. Inversely proportional to the available G-loading at any Mach value. (lower the Cya value, higher G available) per 1 degree AOA
			-- B - Polar quad coeff
			-- B4 - Polar 4th power coeff
			-- Omxmax - roll rate, rad/s
			-- Aldop - Alfadop Max AOA at current M - departure threshold
			-- Cymax - Coefficient, lift, maximum possible (ignores other calculations if current Cy > Cymax)
		}, -- end of aerodynamics
		engine = 
		{
			Nmg	=	67.5, -- RPM at idle
			MinRUD	=	0, -- Min state of the throttle
			MaxRUD	=	1, -- Max state of the throttle
			MaksRUD	=	0.85, -- Military power state of the throttle
			ForsRUD	=	0.91, -- Afterburner state of the throttle
			typeng	=	1,
			--[[
				E_TURBOJET = 0
				E_TURBOJET_AB = 1
				E_PISTON = 2
				E_TURBOPROP = 3
				E_TURBOFAN				= 4
				E_TURBOSHAFT = 5
			--]]
			
			hMaxEng	=	22, -- Max altitude for safe engine operation in km
			dcx_eng	=	0.0144, -- Engine drag coeficient
			cemax	=	0.85, -- not used for fuel calulation , only for AI routines to check flight time ( fuel calculation algorithm is built in )
			cefor	=	1.112, -- not used for fuel calulation , only for AI routines to check flight time ( fuel calculation algorithm is built in )
			dpdh_m	=	2250, --  altitude coefficient for max thrust
			dpdh_f	=	5000,  --  altitude coefficient for AB thrust
			table_data = 
			{		--   M		Pmax		 Pfor	
				[1] = 	{0,	    48445,	68781},	
				[2] = 	{0.2,	44059,	67776},	
				[3] = 	{0.4,	41157,	69410},	
				[4] = 	{0.6,	42467,	74549},	
				[5] = 	{0.7,	41004,	78947},	
				[6] = 	{0.8,	41763,	84276},	
				[7] = 	{0.9,	42718,	85153},	
				[8] = 	{1,	    41852,	87507},	
				[9] = 	{1.1,	38910,	87777}, 
				[10] = 	{1.2,	38964,	92411}, 
				[11] = 	{1.3,	39026,	97503}, 
				[12] = 	{1.5,	39097,	109155}, 
				[13] = 	{1.8,	38451,	109458}, 
				[14] = 	{2,	    36851,	109219}, 
				[15] = 	{2.1,	15516,	109219}, 
				[16] = 	{2.5,	14972,	27800}, 
				[17] = 	{3,	    13611,	27800}, 
			}, -- end of table_data
			-- M - Mach number
			-- Pmax - Engine thrust at military power
			-- Pfor - Engine thrust at AFB
		}, -- end of engine
	},
	--damage , index meaning see in  Scripts\Aircrafts\_Common\Damage.lua
	Damage = {
				[0]		= {critical_damage = 5, args = {146}},
				[3]		= {critical_damage = 20,args = {65}}  ,
				[4]		= {critical_damage = 20, args = {150}},
				[5]		= {critical_damage = 20, args = {147}},
				[7]		= {critical_damage = 4, args = {249}} ,
				[9]		= {critical_damage = 3, args = {154}},
				[10]	= {critical_damage = 3, args = {153}},
				[11]	= {critical_damage = 3, args = {167}},
				[12]	= {critical_damage = 3, args = {161}},
				[15]	= {critical_damage = 5, args = {267}},
				[16]	= {critical_damage = 5, args = {266}},
				[23]	= {critical_damage = 8, args = {223}, deps_cells = {25}},
				[24]	= {critical_damage = 8, args = {213}, deps_cells = {26, 60}},
				[25]	= {critical_damage = 3, args = {226}},
				[26]	= {critical_damage = 3, args = {216}},
				[29]	= {critical_damage = 9, args = {224}, deps_cells = {31, 25, 23}},
				[30]	= {critical_damage = 9, args = {214}, deps_cells = {32, 26, 24, 60}},
				[31]	= {critical_damage = 4, args = {229}},
				[32]	= {critical_damage = 4, args = {219}},
				[35]	= {critical_damage = 10, args = {225}, deps_cells = {29, 31, 25, 23}},
				[36]	= {critical_damage = 10, args = {215}, deps_cells = {30, 32, 26, 24, 60}} ,
				[37]	= {critical_damage = 4, args = {227}},
				[38]	= {critical_damage = 4, args = {217}},
				[39]	= {critical_damage = 7,	args = {244}, deps_cells = {53}},
				[40]	= {critical_damage = 7, args = {241}, deps_cells = {54}},
				[45]	= {critical_damage = 9, args = {235}, deps_cells = {39, 51, 53}},
				[46]	= {critical_damage = 9, args = {233}, deps_cells = {40, 52, 54}},
				[51]	= {critical_damage = 3, args = {239}},
				[52]	= {critical_damage = 3, args = {237}},
				[53]	= {critical_damage = 3, args = {248}},
				[54]	= {critical_damage = 3, args = {247}},
				[55]	= {critical_damage = 20, args = {81}, deps_cells = {39, 40, 45, 46, 51, 52, 53, 54}},
				[59]	= {critical_damage = 5, args = {148}},
				[60]	= {critical_damage = 1, args = {144}},

				[83]	= {critical_damage = 3, args = {134}} ,-- nose wheel
				[84]	= {critical_damage = 3, args = {136}}, -- left wheel
				[85]	= {critical_damage = 3, args = {135}} ,-- right wheel
	},
	
	DamageParts = 
	{  
--DAMAGEOFF		[1] = "F-104T-part-wing-R", -- wing R
--DAMAGEOFF		[2] = "F-104T-part-wing-L", -- wing L
--DAMAGEOFF		[3] = "F-104T-part-nose", -- nose
--DAMAGEOFF		[4] = "F-104T-part-tail", -- tail
	},
	
	lights_data = {
	typename = "collection",
	lights = {
    [1] = { typename = "collection",
						lights = {-- Top Anticollision Light (red)
								  {typename = "natostrobelight",
								   connector = "RED_BEACON_T",
								   argument_1 = 198,
								   period = 1.2,
								   phase_shift = 0
								  },
								  -- Bottom Anticollision Light (red)
								  {typename = "natostrobelight",
								   connector = "RED_BEACON_B",
								   argument_1 = 199,
								   period = 1.2,
								   phase_shift = 0
								  }
								 }
		  },
	[2] = { typename = "collection",
							lights = {-- Left Landing light
									  {typename = "spotlight",
									   connector = "LEFT_MAIN_SPOT",
									   argument = 209,
									   dir_correction = {elevation = math.rad(-1)}
									  },
									  -- Right Landing light
									  {typename = "spotlight",
									   connector = "RIGHT_MAIN_SPOT",
									   argument = 209,
									   dir_correction = {elevation = math.rad(-1)}
									  },
									  -- Nose Landing/Taxi light
									  {typename = "spotlight",
									   connector = "NOSE_TAXI_SPOT",
									   argument = 208,
									   dir_correction = {elevation = math.rad(3)}
									  }
									 }
		  },
    [3]	= {	typename = "collection",
						lights = {
								  { typename = "collection",
									lights = {
									  -- Left Position Light (red)
									  {typename = "omnilight",
										connector = "RED_POS_L",
										color = {0.99, 0.11, 0.3},
										pos_correction  = {0, 0, -0.2},
										argument  = 190
									  },
									  -- Right Position Light (green)
									  {typename = "omnilight",
										connector = "GREEN_POS_R",
										color = {0, 0.894, 0.6},
										pos_correction = {0, 0, 0.2},
										argument  = 191
									  }
									}
								  },
								  { typename = "collection",
								    lights = {
									  -- Left rear upper nav Light (red)
									  {typename = "omnilight",
										connector = "RED_UP_L_REAR",
										color = {0.99, 0.11, 0.3},
										pos_correction  = {0, 0, -0.2},
										argument  = 192
									  },
									  -- Right rear upper nav Light (red)
									  {typename = "omnilight",
										connector = "RED_UP_R_REAR",
										color = {0.99, 0.11, 0.3},
										pos_correction  = {0, 0, -0.2},
										argument  = 193
									  }
									}
								  },
								  { typename = "collection",
								    lights = {
									  -- Left rear lower nav Light (white)
									  {typename = "omnilight",
										connector = "WHITE_DN_L_REAR",
										color = {1, 1, 1},
										pos_correction  = {0, 0, -0.2},
										argument  = 194
									  },
									  -- Right rear lower nav Light (white)
									  {typename = "omnilight",
										connector = "WHITE_DN_R_REAR",
										color = {1, 1, 1},
										pos_correction  = {0, 0, -0.2},
										argument  = 195
									  }
									}
								  }
						}
		  },
    [4] = {	typename = "collection",
						   lights = {
									 -- Top Formation Light (white)
									 {typename = "omnilight",
									  connector = "WHITE_FORM_TOP",
									  color = {1, 1, 1},
									  argument = 200
									 }
									}
		  }
		}
	}
}

add_aircraft(F_104T)
