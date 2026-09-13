--[[
    B-2 Spirit Stealth Bomber — Common MFD Vector Graphics & Drawing Definitions
    Hijacked & Adapted from Community-JAS-39-C Glass Cockpit Architecture
    Supports: PFD, EICAS, FCS, NAV/HSI, TSD/CID Moving Map, DMS/RWR
--]]

dofile(LockOn_Options.common_script_path.."elements_defs.lua")
dofile(LockOn_Options.common_script_path.."Fonts/symbols_locale.lua")
dofile(LockOn_Options.common_script_path.."Fonts/fonts_cmn.lua")

SetScale(FOV)

MFD_DEFAULT_LEVEL = 4

-- Texture Paths
local MFD_IND_TEX_PATH = LockOn_Options.script_path .. "Resources/MFD/"
local HUD_IND_TEX_PATH = LockOn_Options.script_path .. "Resources/HUD/"

-- Textures
ADI_FRAME_B         = MakeMaterial(MFD_IND_TEX_PATH .. "ADIBALL_frame.tga", {255, 255, 255, 255})
ADI_SPHERE_B        = MakeMaterial(MFD_IND_TEX_PATH .. "ADI_Sphere_Normal.tga", {255, 255, 255, 255})
ADI_VELVEC          = MakeMaterial(MFD_IND_TEX_PATH .. "ADI_VelocityVector.tga", {255, 255, 255, 255})
NAV_WHEEL           = MakeMaterial(MFD_IND_TEX_PATH .. "Navigation_Wheel.tga", {255, 255, 255, 255})
NAV_WHEEL_WHT       = MakeMaterial(MFD_IND_TEX_PATH .. "Navigation_Wheel_White.tga", {255, 255, 255, 255})
PITCH_LINES         = MakeMaterial(HUD_IND_TEX_PATH .. "PitchLines.tga", {255, 255, 255, 255})
PITCH_LINES_NEG     = MakeMaterial(HUD_IND_TEX_PATH .. "PitchLinesNegative.tga", {255, 255, 255, 255})
HUD_HEADING_SCALE   = MakeMaterial(HUD_IND_TEX_PATH .. "HUD_HeadingScale.tga", {255, 255, 255, 255})
HUD_VELOCITY_SCALE  = MakeMaterial(HUD_IND_TEX_PATH .. "HUD_VelocityScale.tga", {255, 255, 255, 255})

-- Color Materials
materials = {}
materials["GREEN"]        = MakeMaterial(nil, {36, 255, 113, 255})
materials["AMBER"]        = MakeMaterial(nil, {255, 194, 0, 255})
materials["CYAN"]         = MakeMaterial(nil, {0, 230, 255, 255})
materials["WHITE"]        = MakeMaterial(nil, {245, 245, 250, 255})
materials["RED"]          = MakeMaterial(nil, {255, 30, 30, 255})
materials["DARK_GREEN"]   = MakeMaterial(nil, {15, 90, 40, 255})
materials["DIAL_BG"]      = MakeMaterial(nil, {20, 26, 22, 220})
materials["SCREEN_BG"]    = MakeMaterial(nil, {8, 12, 10, 255})
materials["TRANSPARENT"]   = MakeMaterial(nil, {0, 0, 0, 0})
materials["GRAY"]         = MakeMaterial(nil, {90, 100, 95, 255})
materials["LIGHT_GRAY"]   = MakeMaterial(nil, {160, 170, 165, 255})
materials["BLUE_SKY"]     = MakeMaterial(nil, {20, 75, 150, 255})
materials["BROWN_GND"]    = MakeMaterial(nil, {95, 60, 25, 255})

-- Font sizing constants (in FOV scale)
strdefs_LARGE = {0.009, 0.009, 0.0005, 0.001}
strdefs_MED   = {0.0065, 0.0065, 0.0004, 0.001}
strdefs_SML   = {0.005, 0.005, 0.0003, 0.001}
strdefs_TINY  = {0.0038, 0.0038, 0.0002, 0.000}

-- Fonts
fonts = {}
fonts["GREEN"] = MakeFont({used_DXUnicodeFontData = "FUI/Fonts/font_arial_17"}, {36, 255, 113, 255}, 50, "B2_F_GRN")
fonts["WHITE"] = MakeFont({used_DXUnicodeFontData = "FUI/Fonts/font_arial_17"}, {245, 245, 250, 255}, 50, "B2_F_WHT")
fonts["CYAN"]  = MakeFont({used_DXUnicodeFontData = "FUI/Fonts/font_arial_17"}, {0, 230, 255, 255}, 50, "B2_F_CYN")
fonts["AMBER"] = MakeFont({used_DXUnicodeFontData = "FUI/Fonts/font_arial_17"}, {255, 194, 0, 255}, 50, "B2_F_YEL")
fonts["RED"]   = MakeFont({used_DXUnicodeFontData = "FUI/Fonts/font_arial_17"}, {255, 30, 30, 255}, 50, "B2_F_RED")

-- ═══════════════════════════════════════════════════════════════════════════════
-- CORE DRAWING HELPERS
-- ═══════════════════════════════════════════════════════════════════════════════

function AddElement(object)
	object.use_mipfilter = true
	Add(object)
end

function create_line(x1, y1, x2, y2, width, parent, material)
	local line = CreateElement "ceSimpleLineObject"
	line.name           = create_guid_string()
	line.material       = material or materials["GREEN"]
	line.vertices       = {{x1, y1}, {x2, y2}}
	line.width          = width or 0.004
	if parent ~= nil then
		line.parent_element = type(parent) == "table" and parent.name or parent
	end
	AddElement(line)
	return line
end

function create_rect(xpos, ypos, width, height, line_w, parent, border_mat, fill_mat)
	local hw = width / 2
	local hh = height / 2
	
	-- Optional solid fill background
	if fill_mat ~= nil then
		local fill = CreateElement "ceMeshPoly"
		fill.name           = create_guid_string()
		fill.primitivetype  = "triangles"
		fill.vertices       = {{-hw, hh}, {hw, hh}, {hw, -hh}, {-hw, -hh}}
		fill.indices        = {0, 1, 2, 0, 2, 3}
		fill.init_pos       = {xpos, ypos, 0}
		fill.material       = fill_mat
		if parent ~= nil then
			fill.parent_element = type(parent) == "table" and parent.name or parent
		end
		AddElement(fill)
	end
	
	-- Outline border
	local box = CreateElement "ceSimpleLineObject"
	box.name           = create_guid_string()
	box.material       = border_mat or materials["GREEN"]
	box.vertices       = {{-hw, hh}, {hw, hh}, {hw, -hh}, {-hw, -hh}, {-hw, hh}}
	box.width          = line_w or 0.003
	box.init_pos       = {xpos, ypos, 0}
	if parent ~= nil then
		box.parent_element = type(parent) == "table" and parent.name or parent
	end
	AddElement(box)
	return box
end

function AddCircle(xpos, ypos, radius, border, fill, parent_element, color_mat)
	local circle = CreateElement "ceMeshPoly"
	circle.name           = create_guid_string()
	circle.primitivetype  = "triangles"
	circle.init_pos       = {xpos, ypos, 0}
	circle.material       = color_mat or materials["GREEN"]
	if parent_element ~= nil then
		circle.parent_element = type(parent_element) == "table" and parent_element.name or parent_element
	end
	if fill == true then
		set_circle(circle, radius)
	else
		local line_th = border or 0.004
		set_circle(circle, radius, radius - line_th, 360, 36)
	end
	AddElement(circle)
	return circle
end

function AddCircleClip(xpos, ypos, radius, parent_element, level)
	local clip = CreateElement "ceMeshPoly"
	clip.name             = create_guid_string()
	clip.primitivetype    = "triangles"
	clip.init_pos         = {xpos, ypos, 0}
	clip.h_clip_relation  = h_clip_relations.INCREASE_IF_LEVEL
	clip.level            = level or MFD_DEFAULT_LEVEL
	set_circle(clip, radius)
	clip.material         = materials["TRANSPARENT"]
	clip.isvisible        = false
	if parent_element ~= nil then
		clip.parent_element = type(parent_element) == "table" and parent_element.name or parent_element
	end
	AddElement(clip)
	return clip
end

function add_text(text, posx, posy, parent, font_obj, strdefs, align)
	local txt = CreateElement "ceStringPoly"
	txt.name           = create_guid_string()
	txt.material       = font_obj or fonts["GREEN"]
	txt.stringdefs     = strdefs or strdefs_MED
	txt.alignment      = align or "CenterCenter"
	txt.value          = text
	txt.init_pos       = {posx, posy, 0}
	if parent ~= nil then
		txt.parent_element = type(parent) == "table" and parent.name or parent
	end
	AddElement(txt)
	return txt
end

function add_text_param(posx, posy, param_name, format_str, parent, font_obj, strdefs, align)
	local txt = CreateElement "ceStringPoly"
	txt.name           = create_guid_string()
	txt.material       = font_obj or fonts["GREEN"]
	txt.stringdefs     = strdefs or strdefs_MED
	txt.alignment      = align or "CenterCenter"
	txt.formats        = {format_str or "%s"}
	txt.init_pos       = {posx, posy, 0}
	txt.element_params = {param_name}
	txt.controllers    = {{"text_using_parameter", 0, 0}}
	if parent ~= nil then
		txt.parent_element = type(parent) == "table" and parent.name or parent
	end
	AddElement(txt)
	return txt
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- DYNAMIC VECTOR DIAL (Gauges for RPM, EGT, Fuel, Oil)
-- ═══════════════════════════════════════════════════════════════════════════════

function MakeDial(xpos, ypos, radius, start_deg, end_deg, param_name, max_val, label_text, unit_text, parent, line_color, fill_color)
	line_color = line_color or materials["GREEN"]
	fill_color = fill_color or materials["DIAL_BG"]
	local total_arc = end_deg - start_deg

	-- Dial Root
	local dial_root = CreateElement "ceSimple"
	dial_root.name       = create_guid_string()
	dial_root.init_pos   = {xpos, ypos, 0}
	if parent ~= nil then
		dial_root.parent_element = type(parent) == "table" and parent.name or parent
	end
	AddElement(dial_root)

	-- Dial Background Disc
	local bg_disc = CreateElement "ceMeshPoly"
	bg_disc.name           = create_guid_string()
	bg_disc.primitivetype  = "triangles"
	bg_disc.material       = fill_color
	bg_disc.parent_element = dial_root.name
	set_circle(bg_disc, radius)
	AddElement(bg_disc)

	-- Dial Outer Arc Rim
	local outer_arc = CreateElement "ceMeshPoly"
	outer_arc.name           = create_guid_string()
	outer_arc.primitivetype  = "triangles"
	outer_arc.material       = line_color
	outer_arc.init_rot       = {180 + start_deg, 0}
	outer_arc.parent_element = dial_root.name
	set_circle(outer_arc, radius, radius - 0.005, total_arc, 36)
	AddElement(outer_arc)

	-- Dial Tick Marks
	local num_ticks = 5
	local tick_step = total_arc / num_ticks
	for i = 0, num_ticks do
		local tick_angle = start_deg + (i * tick_step)
		local rad = math.rad(-tick_angle + 90)
		local tick = CreateElement "ceSimpleLineObject"
		tick.name           = create_guid_string()
		tick.material       = line_color
		tick.vertices       = {{0, 0}, {0, -0.016}}
		tick.width          = 0.0035
		tick.init_pos       = {radius * math.cos(rad), radius * math.sin(rad)}
		tick.init_rot       = {-tick_angle}
		tick.parent_element = dial_root.name
		AddElement(tick)
	end

	-- Center Hub
	local hub = CreateElement "ceMeshPoly"
	hub.name           = create_guid_string()
	hub.primitivetype  = "triangles"
	hub.material       = line_color
	hub.parent_element = dial_root.name
	set_circle(hub, 0.015)
	AddElement(hub)

	-- Rotating Needle
	local needle_root = CreateElement "ceSimple"
	needle_root.name           = create_guid_string()
	needle_root.init_pos       = {0, 0, 0}
	needle_root.init_rot       = {-start_deg, 0}
	needle_root.parent_element = dial_root.name
	needle_root.element_params = {param_name}
	local rot_gain = -math.rad(total_arc) / max_val
	needle_root.controllers    = {{"rotate_using_parameter", 0, rot_gain}}
	AddElement(needle_root)

	local needle = CreateElement "ceSimpleLineObject"
	needle.name           = create_guid_string()
	needle.material       = materials["WHITE"]
	needle.vertices       = {{0, -0.01}, {0, radius - 0.008}}
	needle.width          = 0.005
	needle.parent_element = needle_root.name
	AddElement(needle)

	-- Label and Unit
	if label_text ~= nil then
		add_text(label_text, 0, 0.04, dial_root, fonts["WHITE"], strdefs_TINY, "CenterCenter")
	end
	if unit_text ~= nil then
		add_text(unit_text, 0, -radius - 0.03, dial_root, fonts["AMBER"], strdefs_TINY, "CenterCenter")
	end

	-- Digital Value Box below or in center
	local val_txt = add_text_param(0, -0.02, param_name, "%3.0f", dial_root, fonts["GREEN"], strdefs_SML, "CenterCenter")

	return dial_root
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- TEXTURE QUAD SAMPLER (Sub-rectangle from texture atlas)
-- ═══════════════════════════════════════════════════════════════════════════════

function create_mfd_tex(material, UL_X, UL_Y, DR_X, DR_Y, scale, cx, cy)
	scale = scale or 1.0
	local mils = scale / 1024
	local W = DR_X - UL_X
	local H = DR_Y - UL_Y
	local center_x = cx or (UL_X + 0.5 * W)
	local center_y = cy or (UL_Y + 0.5 * H)
	local dcx = mils * (center_x - (UL_X + 0.5 * W))
	local dcy = mils * (center_y - (UL_Y + 0.5 * H))
	local half_w = 0.5 * W * mils
	local half_h = 0.5 * H * mils

	local obj = CreateElement "ceTexPoly"
	obj.material   = material
	obj.vertices   = {{-half_w - dcx,  half_h + dcy},
	                  { half_w - dcx,  half_h + dcy},
	                  { half_w - dcx, -half_h + dcy},
	                  {-half_w - dcx, -half_h + dcy}}
	obj.indices    = {0, 1, 2, 0, 2, 3}
	obj.tex_coords = {{UL_X / 2048, UL_Y / 2048},
	                  {DR_X / 2048, UL_Y / 2048},
	                  {DR_X / 2048, DR_Y / 2048},
	                  {UL_X / 2048, DR_Y / 2048}}
	return obj
end
