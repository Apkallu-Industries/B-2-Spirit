# pyright: reportMissingImports=false
"""
B-2 Cockpit cleanup + diagnostic pass (run on the donor-assembled scene).

Purpose (addresses the issues visible in the committed renders):
  1. Reports the world bounding box of the whole cockpit and of key part groups
     (seats, panel/MFDs, glareshield, pedestal) in DCS coordinates, so we can
     compute a correct pilot/copilot eye point for mainpanel_init.lua / Views.lua.
  2. Flags "floater" objects whose origin sits far from the cockpit centroid
     (the detached donor parts seen floating in b2_pedestal_controls.png).
  3. Flags "debris": tiny, low-vertex stray meshes (the specks near the top of
     b2_authentic_flight_deck_wide.png).
  4. Optionally deletes the debris and writes a *_cleaned.blend COPY - it never
     overwrites the source .blend.

USAGE (Windows, headless - does NOT need the EDM addon):
  blender "B2_Spirit_Cockpit_Centered.blend" --background --python cockpit_cleanup_diag.py
  # add --  --delete-debris   to actually remove debris into a _cleaned.blend copy:
  blender "B2_Spirit_Cockpit_Centered.blend" --background --python cockpit_cleanup_diag.py -- --delete-debris

Report is printed to the console and written to cockpit_diag_report.txt next to the .blend.
"""
try:
    import bpy          # type: ignore
    import mathutils    # type: ignore
except ImportError:
    pass
import sys, os, statistics

# ---- tunables -------------------------------------------------------------
DEBRIS_MAX_DIM   = 0.030   # m - meshes smaller than this in every axis are debris candidates
DEBRIS_MAX_VERTS = 12      # ...and with this few vertices
FLOATER_DIST     = 1.60    # m - object center farther than this from the cockpit centroid = floater
# ---------------------------------------------------------------------------

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
DELETE_DEBRIS = "--delete-debris" in argv

def b2dcs(v):
    # Blender world (bx,by,bz) -> DCS (x fwd, y up, z right):  x=bx, y=bz, z=-by
    return (v.x, v.z, -v.y)

def world_bbox(obj):
    cs = [obj.matrix_world @ mathutils.Vector(c) for c in obj.bound_box]
    xs = [c.x for c in cs]; ys = [c.y for c in cs]; zs = [c.z for c in cs]
    return mathutils.Vector((min(xs), min(ys), min(zs))), mathutils.Vector((max(xs), max(ys), max(zs)))

meshes = [o for o in bpy.data.objects if o.type == 'MESH']
report = []
def out(s):
    print(s); report.append(s)

out(f"=== B-2 Cockpit Diagnostic ===  meshes: {len(meshes)}  delete_debris={DELETE_DEBRIS}")

if not meshes:
    out("No mesh objects found - open the assembled cockpit .blend before running.")
    sys.exit(0)

# --- overall bbox + centroid (DCS coords) ---
gmin = mathutils.Vector(( 1e9,  1e9,  1e9))
gmax = mathutils.Vector((-1e9, -1e9, -1e9))
centers = []
for o in meshes:
    bmin, bmax = world_bbox(o)
    gmin = mathutils.Vector((min(gmin.x,bmin.x), min(gmin.y,bmin.y), min(gmin.z,bmin.z)))
    gmax = mathutils.Vector((max(gmax.x,bmax.x), max(gmax.y,bmax.y), max(gmax.z,bmax.z)))
    centers.append(((bmin+bmax)/2.0, o))

# robust centroid = median of object centers (ignores floaters)
med = mathutils.Vector((
    statistics.median([c.x for c,_ in centers]),
    statistics.median([c.y for c,_ in centers]),
    statistics.median([c.z for c,_ in centers]),
))
out(f"Overall bbox  DCS min {tuple(round(v,3) for v in b2dcs(gmin))}  max {tuple(round(v,3) for v in b2dcs(gmax))}")
out(f"Median center DCS {tuple(round(v,3) for v in b2dcs(med))}")

# --- key part-group bboxes (for eye-point calc) ---
groups = {
    "SEATS":       ("seat", "aces", "cushion", "headrest"),
    "PANEL/MFD":   ("panel", "mfd", "bezel", "glareshield", "hud"),
    "PEDESTAL":    ("pedestal", "throttle", "cdu"),
    "STICKS":      ("stick", "yoke", "grip"),
}
for gname, keys in groups.items():
    gm = mathutils.Vector(( 1e9, 1e9, 1e9)); gx = mathutils.Vector((-1e9,-1e9,-1e9)); n=0
    for o in meshes:
        ln = o.name.lower()
        if any(k in ln for k in keys):
            bmin,bmax = world_bbox(o)
            gm = mathutils.Vector((min(gm.x,bmin.x),min(gm.y,bmin.y),min(gm.z,bmin.z)))
            gx = mathutils.Vector((max(gx.x,bmax.x),max(gx.y,bmax.y),max(gx.z,bmax.z)))
            n += 1
    if n:
        out(f"[{gname}] {n} objs  DCS min {tuple(round(v,3) for v in b2dcs(gm))}  max {tuple(round(v,3) for v in b2dcs(gx))}")
    else:
        out(f"[{gname}] no objects matched {keys}")

# --- suggested eye points (seat top, nudged forward/up) ---
seat_objs = [o for o in meshes if any(k in o.name.lower() for k in ("seat","aces","cushion","headrest"))]
if seat_objs:
    # split by side (DCS z sign) using object center
    for label, sign in (("PILOT (left, z<0)", -1), ("COPILOT (right, z>0)", 1)):
        side = []
        for o in seat_objs:
            bmin,bmax = world_bbox(o); c=(bmin+bmax)/2.0; d=b2dcs(c)
            if (d[2] < 0) == (sign < 0):
                side.append((b2dcs(bmin), b2dcs(bmax)))
        if side:
            top = max(mx[1] for _,mx in side)
            fwd = max(mx[0] for _,mx in side)
            zc  = statistics.median([ (mn[2]+mx[2])/2 for mn,mx in side ])
            out(f"SUGGESTED EYE {label}: approx DCS ({round(fwd-0.30,2)}, {round(top-0.12,2)}, {round(zc,2)})  "
                f"(seat top y={round(top,2)}, front x={round(fwd,2)})")

# --- floaters + debris ---
floaters, debris = [], []
for c, o in centers:
    dist = (c - med).length
    bmin, bmax = world_bbox(o); dim = bmax - bmin
    maxdim = max(dim.x, dim.y, dim.z)
    nverts = len(o.data.vertices)
    if dist > FLOATER_DIST:
        floaters.append((dist, o.name, tuple(round(v,2) for v in b2dcs(c))))
    if maxdim < DEBRIS_MAX_DIM and nverts <= DEBRIS_MAX_VERTS:
        debris.append((o, maxdim, nverts, tuple(round(v,2) for v in b2dcs(c))))

out(f"\n--- FLOATERS (>{FLOATER_DIST}m from centroid): {len(floaters)} ---")
for dist, name, dc in sorted(floaters, reverse=True)[:60]:
    out(f"  {round(dist,2)}m  {name}  DCS{dc}")

out(f"\n--- DEBRIS (<{DEBRIS_MAX_DIM}m & <={DEBRIS_MAX_VERTS} verts): {len(debris)} ---")
for o, md, nv, dc in debris[:60]:
    out(f"  {o.name}  dim={round(md,3)} verts={nv} DCS{dc}")

# --- optional destructive cleanup into a COPY ---
if DELETE_DEBRIS and debris:
    for o, *_ in debris:
        bpy.data.objects.remove(o, do_unlink=True)
    src = bpy.data.filepath or "cockpit.blend"
    dst = os.path.splitext(src)[0] + "_cleaned.blend"
    bpy.ops.wm.save_as_mainfile(filepath=dst, copy=True)
    out(f"\nDeleted {len(debris)} debris meshes; saved CLEANED COPY to: {dst}")
    out("(source .blend untouched)")

# --- write report file ---
try:
    rp = os.path.join(os.path.dirname(bpy.data.filepath or "."), "cockpit_diag_report.txt")
    with open(rp, "w") as f:
        f.write("\n".join(report))
    print(f"\nReport written to {rp}")
except Exception as e:
    print(f"Report write note: {e}")
