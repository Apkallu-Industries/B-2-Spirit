local diff = {
	["axisDiffs"] = {
		-- Left Stick Pitch
		["a2001cdnil"] = {
			["name"] = "Pitch",
			["changed"] = {
				[1] = {
					["key"] = "JOY_Y",
					["filter"] = {
						["deadzone"] = 0.05,
						["curvature"] = { [1] = 0.15 },
						["invert"] = false,
						["saturationX"] = 1,
						["saturationY"] = 1,
						["slider"] = false,
					},
				},
			},
		},
		-- Left Stick Roll
		["a2002cdnil"] = {
			["name"] = "Roll",
			["changed"] = {
				[1] = {
					["key"] = "JOY_X",
					["filter"] = {
						["deadzone"] = 0.05,
						["curvature"] = { [1] = 0.15 },
						["invert"] = false,
						["saturationX"] = 1,
						["saturationY"] = 1,
						["slider"] = false,
					},
				},
			},
		},
		-- Right Thumbstick Horizontal: Gimbal Camera Pan Left / Right (Tuned curve & saturation: no extreme whipping)
		["a2010cdnil"] = {
			["name"] = "Absolute Camera Horizontal View",
			["changed"] = {
				[1] = {
					["key"] = "JOY_RX",
					["filter"] = {
						["deadzone"] = 0.08,
						["curvature"] = { [1] = 0.45 },
						["invert"] = false,
						["saturationX"] = 1,
						["saturationY"] = 0.40,
						["slider"] = false,
					},
				},
			},
		},
		-- Right Thumbstick Vertical: Gimbal Camera Tilt Up / Down
		["a2011cdnil"] = {
			["name"] = "Absolute Camera Vertical View",
			["changed"] = {
				[1] = {
					["key"] = "JOY_RY",
					["filter"] = {
						["deadzone"] = 0.08,
						["curvature"] = { [1] = 0.45 },
						["invert"] = true,
						["saturationX"] = 1,
						["saturationY"] = 0.40,
						["slider"] = false,
					},
				},
			},
		},
	},
	["keyDiffs"] = {
		-- [RS Click] (Right Stick Click): Recenter Camera to Forward Flight View
		["d49pnilunilcdnilvdnilvpnilvunil"] = {
			["name"] = "Center Camera View",
			["added"] = {
				[1] = {
					["key"] = "JOY_BTN10",
				},
			},
		},
		-- [A] Button: Weapon Release (Launch Hellfire)
		["d85pnilu86cdnilvdnilvpnilvunil"] = {
			["name"] = "Weapon Release",
			["added"] = {
				[1] = {
					["key"] = "JOY_BTN1",
				},
			},
		},
		-- [B] Button: Optical Sensor On/Off
		["d87pnilunilcdnilvdnilvpnilvunil"] = {
			["name"] = "Electro-Optical System On/Off",
			["added"] = {
				[1] = {
					["key"] = "JOY_BTN2",
				},
			},
		},
		-- [X] Button: Target Lock
		["d83pnilu84cdnilvdnilvpnilvunil"] = {
			["name"] = "Target Lock",
			["added"] = {
				[1] = {
					["key"] = "JOY_BTN3",
				},
			},
		},
		-- [Y] Button: Laser Ranger / Designator On/Off
		["d136pnilunilcdnilvdnilvpnilvunil"] = {
			["name"] = "Laser Ranger On/Off",
			["added"] = {
				[1] = {
					["key"] = "JOY_BTN4",
					["reformers"] = {},
				},
			},
		},
		-- [LB] Button: Sensor Zoom Out
		["d408pnilunilcdnilvdnilvpnilvunil"] = {
			["name"] = "Sensor Zoom Out",
			["added"] = {
				[1] = {
					["key"] = "JOY_BTN5",
				},
			},
		},
		-- [RB] Button: Sensor Zoom In
		["d407pnilunilcdnilvdnilvpnilvunil"] = {
			["name"] = "Sensor Zoom In",
			["added"] = {
				[1] = {
					["key"] = "JOY_BTN6",
				},
			},
		},
		-- D-Pad Up: Sensor Zoom In
		["d407pnilunilcdnilvdnilvpnilvunil_dpad"] = {
			["name"] = "Sensor Zoom In",
			["added"] = {
				[1] = {
					["key"] = "JOY_POV1_U",
				},
				[2] = {
					["key"] = "JOY_BTN_POV1_U",
				},
			},
		},
		-- D-Pad Down: Sensor Zoom Out
		["d408pnilunilcdnilvdnilvpnilvunil_dpad"] = {
			["name"] = "Sensor Zoom Out",
			["added"] = {
				[1] = {
					["key"] = "JOY_POV1_D",
				},
				[2] = {
					["key"] = "JOY_BTN_POV1_D",
				},
			},
		},
		-- D-Pad Left: Night Vision / FLIR Thermal WHOT/BHOT
		["d1410pnilunilcdnilvdnilvpnilvunil"] = {
			["name"] = "Night Vision / FLIR",
			["added"] = {
				[1] = {
					["key"] = "JOY_POV1_L",
				},
				[2] = {
					["key"] = "JOY_BTN_POV1_L",
				},
			},
		},
		-- EXPLICIT REMOVAL: Strip default View Slew off D-Pad so it no longer turns the camera
		["dnilp32u214cdnilvdnilvpnilvunil"] = {
			["name"] = "View Left slow",
			["removed"] = {
				[1] = {
					["key"] = "JOY_BTN_POV1_L",
				},
				[2] = {
					["key"] = "JOY_POV1_L",
				},
			},
		},
		["dnilp33u214cdnilvdnilvpnilvunil"] = {
			["name"] = "View Right slow",
			["removed"] = {
				[1] = {
					["key"] = "JOY_BTN_POV1_R",
				},
				[2] = {
					["key"] = "JOY_POV1_R",
				},
			},
		},
		["dnilp34u214cdnilvdnilvpnilvunil"] = {
			["name"] = "View Up slow",
			["removed"] = {
				[1] = {
					["key"] = "JOY_BTN_POV1_U",
				},
				[2] = {
					["key"] = "JOY_POV1_U",
				},
			},
		},
		["dnilp35u214cdnilvdnilvpnilvunil"] = {
			["name"] = "View Down slow",
			["removed"] = {
				[1] = {
					["key"] = "JOY_BTN_POV1_D",
				},
				[2] = {
					["key"] = "JOY_POV1_D",
				},
			},
		},
	},
}
return diff
