-- B-2 Spirit Command Definitions
-- Cockpit clickable commands and axis mappings

local cmd = {}

cmd.Button = {}
cmd.Axis   = {}

cmd.Button.MasterCautionReset   = 3001
cmd.Button.LandingGearToggle    = 3002
cmd.Button.ParkingBrakeToggle   = 3003
cmd.Button.CanopyToggle         = 3004
cmd.Button.EngineStart_1        = 3005
cmd.Button.EngineStart_2        = 3006
cmd.Button.EngineStart_3        = 3007
cmd.Button.EngineStart_4        = 3008
cmd.Button.APUToggle            = 3009
cmd.Button.FlapUp               = 3010
cmd.Button.FlapDown             = 3011

cmd.Axis.Throttle               = 3100
cmd.Axis.ThrottleLeft           = 3101
cmd.Axis.ThrottleRight          = 3102

return cmd
