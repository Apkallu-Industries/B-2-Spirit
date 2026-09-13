local res = external_profile("Config/Input/Aircrafts/base_joystick_binding.lua")

join(res.keyCommands,{

-- Xbox Controller & Hotas Dedicated Bindings for MQ-9 Reaper
{combos = {{key = 'JOY_BTN1'}}, down = iCommandPlanePickleOn, up = iCommandPlanePickleOff, name = _('Weapon Release / Launch Hellfire (Controller [A])'), category = _('Weapons')},
{combos = {{key = 'JOY_BTN2'}}, down = iCommandPlaneEOSOnOff, name = _('Optical Sensor / Camera On-Off (Controller [B])'), category = _('Sensors')},
{combos = {{key = 'JOY_BTN3'}}, down = iCommandPlaneChangeLock, up = iCommandPlaneChangeLockUp, name = _('Target Lock / Tracking Gate (Controller [X])'), category = _('Sensors')},
{combos = {{key = 'JOY_BTN4'}}, down = iCommandPlaneLaserRangerOnOff, name = _('Laser Ranger & Designator PRF 1688 (Controller [Y])'), category = _('Sensors')},
{combos = {{key = 'JOY_BTN5'}}, down = iCommandPlaneZoomOut, name = _('Sensor Zoom Out (Controller [LB])'), category = _('Sensors')},
{combos = {{key = 'JOY_BTN6'}}, down = iCommandPlaneZoomIn, name = _('Sensor Zoom In (Controller [RB])'), category = _('Sensors')},
{combos = {{key = 'JOY_BTN7'}}, down = iCommandViewHUDOnlyOnOff, name = _('Toggle Drone 2-View: Clean Sensor / Chase (Controller [View/Back])'), category = _('View')},
{combos = {{key = 'JOY_BTN8'}}, down = iCommandPlaneSAUHBarometric, name = _('Barometric Altitude Hold Autopilot (Controller [Menu/Start])'), category = _('Autopilot')},
{combos = {{key = 'JOY_BTN9'}}, down = iCommandPlaneModeGround, name = _('Air-To-Ground Combat Mode 7 (Controller [LS Click])'), category = _('Modes')},
{combos = {{key = 'JOY_BTN10'}}, down = iCommandViewCameraCenter, name = _('Recenter Camera / Flight Seat View (Controller [RS Click])'), category = _('View')},

-- D-Pad Tactical Controls (Zoom & Thermal / Night Vision)
{combos = {{key = 'JOY_POV1_U'}}, down = iCommandPlaneZoomIn, name = _('Sensor Zoom In (Controller [D-Pad Up])'), category = _('Sensors')},
{combos = {{key = 'JOY_POV1_D'}}, down = iCommandPlaneZoomOut, name = _('Sensor Zoom Out (Controller [D-Pad Down])'), category = _('Sensors')},
{combos = {{key = 'JOY_POV1_L'}}, down = iCommandPlaneNightTVOnOff, name = _('Night Vision / FLIR Thermal WHOT/BHOT (Controller [D-Pad Left])'), category = _('Sensors')},
{combos = {{key = 'JOY_POV1_R'}}, down = iCommandPlaneLaserRangerOnOff, name = _('Laser Designator PRF 1688 Toggle (Controller [D-Pad Right])'), category = _('Sensors')},

-- Autopilot
{down = iCommandPlaneAutopilot, name = _('Autopilot'), category = _('Autopilot')},
{down = iCommandPlaneSAUHBarometric, name = _('Autopilot - Barometric Altitude Hold \'H\''), category = _('Autopilot')},
{down = iCommandPlaneAutopilotOverrideOn, up = iCommandPlaneAutopilotOverrideOff, name = _('Autopilot override'), category = _('Autopilot')},
{down = iCommandPlaneStabTangBank, name = _('Autopilot - Attitude Hold'), category = _('Autopilot')},
{down = iCommandPlaneStabHbarBank, name = _('Autopilot - Altitude And Roll Hold'), category = _('Autopilot')},
{down = iCommandPlaneStabHorizon, name = _('Autopilot - Transition To Level Flight Control'), category = _('Autopilot')},
{down = iCommandPlaneStabHbar, name = _('Autopilot - Barometric Altitude Hold'), category = _('Autopilot')},
{down = iCommandPlaneStabHrad, name = _('Autopilot - Radar Altitude Hold'), category = _('Autopilot')},
{down = iCommandPlaneRouteAutopilot, name = _('Autopilot - \'Route following\''), category = _('Autopilot')},
{down = iCommandPlaneStabCancel, name = _('Autopilot Disengage'), category = _('Autopilot')},

-- Modes & Systems
{down = iCommandPlaneModeFI0, name = _('(6) Longitudinal Missile Aiming Mode'), category = _('Modes')},
{down = iCommandPlaneModeGround, name = _('(7) Air-To-Ground Mode'), category = _('Modes')},
{down = iCommandPlaneModeGrid, name = _('(8) Gunsight Reticle Switch'), category = _('Modes')},
{down = iCommandSensorReset, name = _('Target Unlock'), category = _('Sensors')},
{down = iCommandPlaneRadarCenter, name = _('Target Designator To Center'), category = _('Sensors')},

-- Weapons
{down = iCommandPlaneSalvoOnOff, name = _('Salvo Mode'), category = _('Weapons')},
{down = iCommandChangeGunRateOfFire, name = _('Cut Of Burst select'), category = _('Weapons')},
{down = iCommandChangeRippleQuantity, name = _('Ripple Quantity Select/SPPU select'), category = _('Weapons')},
{down = iCommandChangeRippleInterval, name = _('Ripple Interval Increase'), category = _('Weapons')},
{down = iCommandChangeRippleIntervalDown, name = _('Ripple Interval Decrease'), category = _('Weapons')},

-- Countermeasures
{down = iCommandActiveIRJamming, name = _('IR Jamming'), category = _('Countermeasures')},
})

-- Joystick & Gamepad Axes: Left Stick = Flight, Right Stick = Gimbal Camera Slew
join(res.axisCommands,{
{combos = defaultDeviceAssignmentFor("roll"), action = iCommandPlaneRoll, name = _('Roll (Left Stick X)')},
{combos = defaultDeviceAssignmentFor("pitch"), action = iCommandPlanePitch, name = _('Pitch (Left Stick Y)')},
{combos = defaultDeviceAssignmentFor("thrust"), action = iCommandPlaneThrustCommon, name = _('Throttle / Power')},
{action = iCommandPlaneRudder, name = _('Yaw / Rudder')},

-- Dedicated Right Thumbstick Gimbal Camera Slew Axes
{combos = {{key = 'JOY_RX'}}, action = iCommandViewHorizontalAbs, name = _('Camera / Sensor Slew Horizontal (Right Stick X)')},
{combos = {{key = 'JOY_RY'}}, action = iCommandViewVerticalAbs,   name = _('Camera / Sensor Slew Vertical (Right Stick Y)')},
{action = iCommandPlaneSelecterHorizontalAbs, name = _('TDC / Sensor Target Slew Horizontal')},
{action = iCommandPlaneSelecterVerticalAbs,   name = _('TDC / Sensor Target Slew Vertical')},
{action = iCommandViewZoomAbs, name = _('Camera Zoom View')},
{action = iCommandPlaneMFDZoomAbs, name = _('Sensor Zoom')},
})

return res
