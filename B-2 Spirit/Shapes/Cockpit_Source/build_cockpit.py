import bpy, sys, math, mathutils

sys.path.insert(0, '/root/.config/blender/4.0/scripts/addons/io_scene_edm')
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.preferences.addon_enable(module='io_scene_edm')

# ---------------------------------------------------------------------------
# Coordinate convention (see Cockpit_Source/README.md):
#   Blender X = DCS X (forward/nose +)
#   Blender Y = -DCS Z (DCS Z is right+, so Blender +Y is aircraft LEFT)
#   Blender Z = DCS Y (up)
# Build everything in DCS meters; positions map to B-2.lua crew coords 1:1.
# ---------------------------------------------------------------------------
def d2b(x, y, z):
    return (x, -z, y)

def mat(name, color, rough=0.5, metallic=0.0, emissive=None):
    m = bpy.data.materials.get(name)
    if m:
        return m
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    m.diffuse_color = (*color, 1.0)          # workbench/object color
    b = m.node_tree.nodes.get("Principled BSDF")
    if b:
        b.inputs["Base Color"].default_value = (*color, 1.0)
        b.inputs["Roughness"].default_value = rough
        if "Metallic" in b.inputs:
            b.inputs["Metallic"].default_value = metallic
        if emissive and "Emission Color" in b.inputs:
            b.inputs["Emission Color"].default_value = (*emissive, 1.0)
            if "Emission Strength" in b.inputs:
                b.inputs["Emission Strength"].default_value = 1.0
    return m

M_PANEL  = mat("B2_Cockpit_Panel_Mat",  (0.035, 0.037, 0.040), rough=0.55)
M_TRIM   = mat("B2_Cockpit_Trim_Mat",   (0.075, 0.078, 0.085), rough=0.6)
M_SCREEN = mat("B2_Cockpit_Screen_Mat", (0.02, 0.06, 0.05),   rough=0.15, emissive=(0.01,0.05,0.04))
M_BEZEL  = mat("B2_Cockpit_Bezel_Mat",  (0.10, 0.10, 0.11),   rough=0.5)
M_SEAT   = mat("B2_Cockpit_Seat_Mat",   (0.06, 0.055, 0.05),  rough=0.85)
M_STICK  = mat("B2_Cockpit_Stick_Mat",  (0.02, 0.02, 0.02),   rough=0.4)
M_GAUGE  = mat("B2_Cockpit_Gauge_Mat",  (0.90, 0.90, 0.88),   rough=0.3)
M_METAL  = mat("B2_Cockpit_Metal_Mat",  (0.30, 0.30, 0.32),   rough=0.35, metallic=0.8)
M_FLAG   = mat("B2_Cockpit_Flag_Mat",   (0.65, 0.06, 0.05),   rough=0.7)

root = bpy.data.objects.new("Cockpit_Root", None)
bpy.context.collection.objects.link(root)

def box(name, dcs_center, dcs_size, material, parent=root, bevel=0.008, rot_b=None):
    bpy.ops.mesh.primitive_cube_add(size=1.0)
    o = bpy.context.active_object
    o.name = name
    o.location = d2b(*dcs_center)
    dx, dy, dz = dcs_size
    o.scale = (dx, dz, dy)          # Blender (x,y,z) <- DCS (fwd, lat, up)
    if rot_b:
        o.rotation_euler = rot_b
    o.data.materials.append(material)
    if bevel:
        bpy.ops.object.modifier_add(type='BEVEL')
        o.modifiers[-1].width = bevel
        o.modifiers[-1].segments = 2
        o.modifiers[-1].limit_method = 'ANGLE'
    o.parent = parent
    return o

def cyl(name, dcs_center, radius, depth, material, parent=root, axis='X'):
    # disc faces along DCS X (toward pilot). Blender cyl axis default Z -> rotate.
    bpy.ops.mesh.primitive_cylinder_add(radius=radius, depth=depth, vertices=24)
    o = bpy.context.active_object
    o.name = name
    o.location = d2b(*dcs_center)
    if axis == 'X':
        o.rotation_euler = (0, math.radians(90), 0)  # Blender Z-axis cyl -> along Blender X
    o.data.materials.append(material)
    o.parent = parent
    return o

# --- floor / shell (extended aft to house the 3rd-crew rest area) ------------
box("Interior_Floor", (6.45, 0.55, 0.0), (2.30, 0.05, 2.74), M_TRIM)
box("Interior_Wall_L", (6.45, 1.45, -1.38), (2.30, 1.85, 0.06), M_TRIM)
box("Interior_Wall_R", (6.45, 1.45,  1.38), (2.30, 1.85, 0.06), M_TRIM)
box("Interior_Aft_Bulkhead", (5.30, 1.35, 0.0), (0.06, 1.70, 2.74), M_TRIM)

# --- main instrument panel (slight aft tilt at top: rotate about Blender +Y) --
PANEL_TILT = math.radians(8)
box("Panel_Main", (7.52, 1.72, 0.0), (0.12, 0.60, 2.70), M_PANEL, rot_b=(0, PANEL_TILT, 0))

# glareshield / coaming: overhangs forward+up over the panel, tilted
box("Panel_Glareshield", (7.60, 2.06, 0.0), (0.34, 0.10, 2.78), M_TRIM,
    rot_b=(0, math.radians(20), 0))

# --- upper engine / fuel gauge strip (round dials, matches reference photo) ---
n_gauges = 6
gz0, gz1 = -0.95, 0.95
for i in range(n_gauges):
    z = gz0 + (gz1 - gz0) * i / (n_gauges - 1)
    cyl(f"Gauge_Upper_{i+1}", (7.455, 1.92, z), 0.052, 0.03, M_GAUGE)
    cyl(f"Gauge_Upper_{i+1}_Ring", (7.448, 1.92, z), 0.060, 0.012, M_BEZEL)

# --- 8 MFDs, 4 columns x 2 rows, centered ------------------------------------
cols, rows = 4, 2
bez, scr, gap = 0.27, 0.205, 0.055
grid_w = cols * bez + (cols - 1) * gap
z_start = -grid_w / 2 + bez / 2
for r in range(rows):
    y = 1.56 + r * (bez + gap)
    for c in range(cols):
        z = z_start + c * (bez + gap)
        idx = r * cols + c + 1
        box(f"MFD_{idx}_Bezel",  (7.452, y, z), (0.02, bez, bez), M_BEZEL, bevel=0.006)
        box(f"MFD_{idx}_Screen", (7.462, y, z), (0.008, scr, scr), M_SCREEN, bevel=0.0)

# --- center pedestal + throttle quadrant -------------------------------------
box("Pedestal_Body", (6.95, 1.05, 0.0), (0.70, 0.40, 0.34), M_PANEL)
box("Pedestal_TopConsole", (7.18, 1.30, 0.0), (0.24, 0.05, 0.30), M_TRIM,
    rot_b=(0, math.radians(35), 0))
# keypad block (CDU-like) on aft pedestal
box("Pedestal_Keypad", (6.72, 1.28, 0.0), (0.18, 0.03, 0.22), M_BEZEL)
for kr in range(3):
    for kc in range(3):
        box(f"Keypad_Btn_{kr}{kc}", (6.66, 1.34 - kr*0.045, -0.07 + kc*0.07),
            (0.01, 0.03, 0.045), M_TRIM, bevel=0.004)
# throttle quadrant: 4 levers on top-forward of pedestal
for t in range(4):
    z = -0.10 + t * 0.065
    box(f"Throttle_Base_{t+1}", (7.02, 1.20, z), (0.16, 0.04, 0.04), M_METAL, bevel=0.004)
    box(f"Throttle_Lever_{t+1}", (7.05, 1.32, z), (0.03, 0.20, 0.025), M_STICK,
        rot_b=(0, math.radians(-25), 0), bevel=0.004)
    box(f"Throttle_Grip_{t+1}", (7.10, 1.42, z), (0.05, 0.05, 0.04), M_STICK, bevel=0.008)

# --- side consoles -----------------------------------------------------------
box("Console_L", (6.95, 1.02, -1.05), (0.65, 0.30, 0.24), M_PANEL)
box("Console_R", (6.95, 1.02,  1.05), (0.65, 0.30, 0.24), M_PANEL)

# --- crew stations: seats, yokes, rudder pedals ------------------------------
def seat(prefix, sx, sy, sz):
    box(f"{prefix}_Pan",     (sx - 0.05, sy - 0.48, sz), (0.46, 0.10, 0.46), M_SEAT)
    box(f"{prefix}_Back",    (sx - 0.30, sy - 0.02, sz), (0.10, 0.78, 0.46), M_SEAT,
        rot_b=(0, math.radians(-6), 0))
    box(f"{prefix}_Headrest",(sx - 0.30, sy + 0.42, sz), (0.10, 0.16, 0.24), M_SEAT)
    box(f"{prefix}_Armrest_L",(sx - 0.10, sy - 0.30, sz - 0.26), (0.30, 0.05, 0.06), M_STICK)
    box(f"{prefix}_Armrest_R",(sx - 0.10, sy - 0.30, sz + 0.26), (0.30, 0.05, 0.06), M_STICK)

def yoke(prefix, bx, by, bz):
    box(f"{prefix}_Column", (bx, by + 0.18, bz), (0.05, 0.42, 0.05), M_STICK,
        rot_b=(0, math.radians(-10), 0))
    box(f"{prefix}_Wheel",  (bx + 0.06, by + 0.40, bz), (0.05, 0.10, 0.30), M_STICK, bevel=0.02)
    # remove-before-flight flag on the yoke (seen in reference photo)
    box(f"{prefix}_Flag", (bx + 0.02, by + 0.30, bz + 0.14), (0.02, 0.14, 0.05), M_FLAG)

def rudder(prefix, px, py, pz):
    box(f"{prefix}_L", (px, py, pz - 0.16), (0.20, 0.04, 0.10), M_METAL, bevel=0.006)
    box(f"{prefix}_R", (px, py, pz + 0.16), (0.20, 0.04, 0.10), M_METAL, bevel=0.006)

PILOT   = (6.80, 1.85, -0.65)   # left seat  - flies the aircraft
COPILOT = (6.80, 1.85,  0.65)   # right seat - mission commander
RELIEF  = (6.00, 1.70,  0.00)   # 3rd crew jump seat (centered, aft)
seat("Pilot_Seat",   *PILOT)
seat("Copilot_Seat", *COPILOT)
yoke("Yoke_Pilot",   7.12, 1.12, PILOT[2])
yoke("Yoke_Copilot", 7.12, 1.12, COPILOT[2])
rudder("Rudder_Pilot",   7.30, 0.74, PILOT[2])
rudder("Rudder_Copilot", 7.30, 0.74, COPILOT[2])

# --- third crew member: centered jump seat + aft crew rest provisions --------
def jumpseat(prefix, sx, sy, sz):
    box(f"{prefix}_Pan",     (sx - 0.05, sy - 0.42, sz), (0.42, 0.09, 0.42), M_SEAT)
    box(f"{prefix}_Back",    (sx - 0.26, sy + 0.02, sz), (0.09, 0.66, 0.42), M_SEAT,
        rot_b=(0, math.radians(-8), 0))
    box(f"{prefix}_Headrest",(sx - 0.26, sy + 0.38, sz), (0.09, 0.14, 0.22), M_SEAT)
    box(f"{prefix}_Post",    (sx - 0.05, sy - 0.70, sz), (0.08, 0.30, 0.08), M_METAL)

jumpseat("Relief_Seat", *RELIEF)

# crew rest bunk (fold-down cot) along the aft-left floor - lie-down provision
box("CrewRest_Bunk",    (5.65, 0.80, -0.55), (0.95, 0.07, 0.60), M_SEAT)
box("CrewRest_Mattress",(5.65, 0.86, -0.55), (0.90, 0.05, 0.54), M_SEAT)
box("CrewRest_Pillow",  (5.35, 0.92, -0.55), (0.22, 0.08, 0.40), M_SEAT)
box("CrewRest_Rail",    (5.65, 1.02, -0.86), (0.95, 0.40, 0.04), M_METAL, bevel=0.006)
# provisions / galley + relief locker on the aft-right
box("CrewRest_Locker",  (5.55, 1.05, 0.75),  (0.55, 0.95, 0.55), M_PANEL)
box("CrewRest_Locker_Door", (5.83, 1.05, 0.75), (0.02, 0.85, 0.48), M_TRIM, bevel=0.006)
box("CrewRest_Galley",  (5.55, 0.80, 0.10),  (0.55, 0.30, 0.55), M_TRIM)

# --- windscreen posts (frame the forward view) -------------------------------
box("Windscreen_Post_L", (7.66, 2.30, -0.70), (0.10, 0.55, 0.09), M_TRIM,
    rot_b=(0, math.radians(35), 0))
box("Windscreen_Post_R", (7.66, 2.30,  0.70), (0.10, 0.55, 0.09), M_TRIM,
    rot_b=(0, math.radians(35), 0))
box("Windscreen_Center", (7.70, 2.34, 0.0), (0.08, 0.50, 0.07), M_TRIM,
    rot_b=(0, math.radians(35), 0))

# ============================================================================
# DETAIL PASS: switch banks, overhead panel, annunciator, MFD keys, standby
# ============================================================================
def switch_row(prefix, x, y0, z0, n, dz, sw_mat=M_TRIM, dy=0.0, size=(0.012,0.02,0.022)):
    for i in range(n):
        box(f"{prefix}_{i+1}", (x, y0 + i*dy, z0 + i*dz), size, sw_mat, bevel=0.003)

# --- line-select keys around each MFD (5 per side, L and R) ------------------
mfd_positions = []
cols, rows = 4, 2
bez, gap = 0.27, 0.055
grid_w = cols * bez + (cols - 1) * gap
z_start = -grid_w / 2 + bez / 2
for r in range(rows):
    y = 1.56 + r * (bez + gap)
    for c in range(cols):
        z = z_start + c * (bez + gap)
        mfd_positions.append((y, z))
for i, (y, z) in enumerate(mfd_positions):
    for k in range(5):
        kz = z - bez/2 + 0.03 + k * ((bez-0.06)/4)
        box(f"MFD_{i+1}_KeyBot_{k+1}", (7.452, y - bez/2 - 0.012, kz), (0.014, 0.02, 0.02), M_TRIM, bevel=0.003)
        box(f"MFD_{i+1}_KeyTop_{k+1}", (7.452, y + bez/2 + 0.012, kz), (0.014, 0.02, 0.02), M_TRIM, bevel=0.003)

# --- standby instrument cluster (center panel, below MFD grid) ---------------
for i in range(3):
    z = -0.16 + i * 0.16
    cyl(f"Standby_Gauge_{i+1}", (7.452, 1.40, z), 0.045, 0.03, M_GAUGE)
    cyl(f"Standby_Gauge_{i+1}_Ring", (7.446, 1.40, z), 0.052, 0.012, M_BEZEL)

# --- annunciator / master caution panel on the glareshield ------------------
for r in range(2):
    for c in range(8):
        z = -0.62 + c * 0.16
        clr = M_FLAG if (r == 0 and c in (0, 7)) else M_BEZEL
        box(f"Annun_{r}_{c}", (7.50, 2.02 - r*0.045, z), (0.008, 0.03, 0.07), clr, bevel=0.002)
box("MasterCaution_L", (7.46, 2.00, -0.95), (0.02, 0.09, 0.11), M_FLAG, bevel=0.006)
box("MasterCaution_R", (7.46, 2.00,  0.95), (0.02, 0.09, 0.11), M_FLAG, bevel=0.006)

# --- overhead panel with switch banks (above/between the crew) --------------
box("Overhead_Panel", (6.55, 2.62, 0.0), (0.85, 0.10, 1.40), M_PANEL, rot_b=(0, math.radians(-6), 0))
for bank in range(3):
    z0 = -0.55 + bank * 0.55
    switch_row(f"Overhead_Bank{bank+1}", 6.45, 2.55, z0 - 0.18, 6, 0.07, dy=0.0,
               size=(0.02, 0.03, 0.03))
    switch_row(f"Overhead_Bank{bank+1}b", 6.65, 2.57, z0 - 0.18, 6, 0.07, dy=0.0,
               size=(0.02, 0.03, 0.03))

# --- side console switch banks (on top of each console) ---------------------
for side, zc in (("L", -1.05), ("R", 1.05)):
    for rrow in range(3):
        switch_row(f"Console_{side}_Row{rrow+1}", 6.80 - rrow*0.16, 1.19, zc - 0.09,
                   3, 0.09, size=(0.02, 0.03, 0.03))
    box(f"Console_{side}_Throttle_Guard", (7.10, 1.20, zc), (0.10, 0.05, 0.14), M_METAL, bevel=0.006)

# --- center pedestal comms/nav radio + CDU stack ----------------------------
for i in range(3):
    box(f"Pedestal_Radio_{i+1}", (6.80, 1.18 - i*0.10, 0.0), (0.16, 0.08, 0.26), M_BEZEL, bevel=0.004)
    switch_row(f"Pedestal_Radio_{i+1}_Knobs", 6.72, 1.18 - i*0.10, -0.08, 3, 0.08,
               size=(0.02, 0.03, 0.03), sw_mat=M_METAL)

for o in bpy.data.objects:
    if o.type == 'MESH':
        o.data.name = o.name + "_Mesh"

bpy.ops.wm.save_as_mainfile(filepath="/tmp/B2_Spirit_Cockpit.blend")
print(">>> SAVED_BLEND")
try:
    bpy.ops.export_scene.fbx(filepath="/tmp/B2_Spirit_Cockpit.fbx", use_selection=False)
    print(">>> SAVED_FBX")
except Exception as e:
    print(">>> FBX_FAIL", repr(e))
mesh_ct = len([o for o in bpy.data.objects if o.type == 'MESH'])
print(">>> MESH_COUNT", mesh_ct)
print(">>> DONE")
