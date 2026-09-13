-- B-2 Spirit Main Panel Init
-- References the external 3D shape for cockpit rendering

shape_name   = "B-2_Spirit"
is_internal  = false

ambient_light                = {255, 255, 255}
ambient_color_day_texture    = {72, 82, 61}
ambient_color_night_texture  = {40, 60, 150}
ambient_color_from_devices   = {50, 50, 40}
ambient_color_from_panels    = {35, 25, 25}

dofile(LockOn_Options.common_script_path.."elements_defs.lua")

params = {}
controllers = {}
need_to_be_closed = false
