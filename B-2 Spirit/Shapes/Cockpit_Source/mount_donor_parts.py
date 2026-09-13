# pyright: reportMissingImports=false
"""
Path A - progressive donor swap for the B-2 cockpit.

Appends the remaining high-poly donor parts from B2_Cockpit_Donor_Library.blend,
positions them at the box-cockpit station anchors, and DELETES the matching
procedural box geometry so the donor part replaces it. Saves a *_swapped.blend
COPY - never overwrites the source scene.

Run on your Windows Blender against the assembled cockpit scene:
  blender "B2_Spirit_Cockpit_Centered.blend" --background --python mount_donor_parts.py

The parts already mounted by hand (ACES II seats, HOTAS sticks) are left alone.

COORDINATE FRAME
----------------
The scene is centered near origin. A DCS aircraft coordinate (x fwd, y up,
z right) maps to this scene's Blender space as:
    blender = ( x - 6.56, -z - 0.65, y - 2.10 )
so the PARTS table below is written in intuitive DCS metres.

IMPORTANT - this seeds best-estimate transforms only. Donor part ORIGINS and
native ORIENTATIONS vary, so after the first run open the _swapped.blend and
nudge each part's `pos` / `rot_deg` / `scale` in the table, then re-run. Work
one part at a time (comment the others out) until each sits right.
"""
try:
    import bpy          # type: ignore
    import mathutils    # type: ignore
except ImportError:
    pass
import os, math

HERE = os.path.dirname(bpy.data.filepath) if bpy.data.filepath else "."
LIB  = os.path.join(HERE, "Assets", "B2_Cockpit_Donor_Library.blend")

def d2b(x, y, z):
    return (x - 6.56, -z - 0.65, y - 2.10)

# donor: object name in the library
# pos  : DCS (x fwd, y up, z right) where the part ORIGIN should sit
# scale: uniform scale (donor parts are ~1:1, tweak if too big/small)
# rot_deg: Blender XYZ euler degrees (orientation of donor is unknown - set visually)
# mirror_z: if True, also create a right-side copy mirrored across the centreline
# delete: box-object name prefixes this donor part REPLACES (deleted)
PARTS = [
    dict(donor="HOTAS_Throttle_Quadrant", pos=(6.98, 1.28, 0.12), scale=1.0, rot_deg=(0,0,0),
         mirror_z=False, name="Donor_Throttle_Quadrant",
         delete=["Throttle_", "PNT_Throttle_", "Pedestal_Top_Slant"]),
    dict(donor="Rudder_Pedals", pos=(7.30, 0.75, -0.65), scale=1.0, rot_deg=(0,0,0),
         mirror_z=True, name="Donor_Rudder_Pedals",
         delete=["Rudder_Pilot", "Rudder_Copilot"]),
    dict(donor="UFC_CDU_Keypad", pos=(6.96, 1.30, -0.11), scale=1.0, rot_deg=(0,0,0),
         mirror_z=False, name="Donor_CDU_Keypad",
         delete=["PNT_CDU_Btn_", "Pedestal_CDU_"]),
    dict(donor="Switch_Banks", pos=(6.55, 1.10, -1.15), scale=1.0, rot_deg=(0,0,0),
         mirror_z=True, name="Donor_Switch_Banks",
         delete=["Console_Pilot", "Console_WSO", "Pilot_CB_", "WSO_CB_"]),
    dict(donor="HUD_Combiner_Glass", pos=(7.32, 2.14, -0.65), scale=1.0, rot_deg=(0,0,0),
         mirror_z=True, name="Donor_HUD_Glass",
         delete=["HUD_Glass_"]),
]

def append_donor(name):
    if not os.path.exists(LIB):
        print(f"!! donor library not found: {LIB}")
        return None
    with bpy.data.libraries.load(LIB, link=False) as (src, dst):
        if name in src.objects:
            dst.objects = [name]
        else:
            print(f"!! donor object '{name}' not in library"); dst.objects = []
    objs = [o for o in dst.objects if o is not None]
    for o in objs:
        bpy.context.scene.collection.objects.link(o)
    return objs[0] if objs else None

def place(obj, dcs_pos, scale, rot_deg, new_name):
    obj.name = new_name
    obj.location = d2b(*dcs_pos)
    obj.scale = (scale, scale, scale)
    obj.rotation_euler = tuple(math.radians(a) for a in rot_deg)

report = []
for p in PARTS:
    base = append_donor(p["donor"])
    if not base:
        continue
    place(base, p["pos"], p["scale"], p["rot_deg"], p["name"] + "_L" if p["mirror_z"] else p["name"])
    report.append(f"mounted {p['donor']} -> {base.name} at DCS{p['pos']}")
    if p["mirror_z"]:
        cp = base.copy(); cp.data = base.data.copy()
        bpy.context.scene.collection.objects.link(cp)
        x, y, z = p["pos"]
        place(cp, (x, y, -z), p["scale"], p["rot_deg"], p["name"] + "_R")
        # mirror across centreline: negate Blender Y offset handled by -z in d2b; also flip scale Y
        cp.scale = (p["scale"], -p["scale"], p["scale"])
        report.append(f"  + mirrored -> {cp.name}")
    # delete the box geometry this part replaces
    removed = 0
    for o in list(bpy.data.objects):
        if o.type == 'MESH' and any(o.name.startswith(pre) for pre in p["delete"]):
            bpy.data.objects.remove(o, do_unlink=True); removed += 1
    report.append(f"  deleted {removed} box meshes matching {p['delete']}")

dst = os.path.splitext(bpy.data.filepath or "cockpit.blend")[0] + "_swapped.blend"
bpy.ops.wm.save_as_mainfile(filepath=dst, copy=True)
report.append(f"saved swapped COPY: {dst}  (source untouched)")
print("\n".join(report))
