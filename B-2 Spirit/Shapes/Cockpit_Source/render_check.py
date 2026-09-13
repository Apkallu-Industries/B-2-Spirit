import bpy, math, mathutils, sys

view = sys.argv[-1]
bpy.ops.wm.open_mainfile(filepath="/tmp/B2_Spirit_Cockpit.blend")
sc = bpy.context.scene
sc.render.engine = 'BLENDER_WORKBENCH'
sc.display.shading.color_type = 'MATERIAL'
sc.display.shading.light = 'STUDIO'
sc.render.resolution_x = 1000
sc.render.resolution_y = 680

def d2b(x, y, z):
    return (x, -z, y)

if view == 'eye':
    eye = d2b(6.85, 1.96, -0.65)      # pilot eye (DCS)
    tgt = d2b(7.50, 1.72, -0.20)
    lens = 15
    out = "/tmp/cockpit_eye.png"
elif view == 'copilot':
    eye = d2b(6.85, 1.96, 0.65)
    tgt = d2b(7.50, 1.72, 0.20)
    lens = 15
    out = "/tmp/cockpit_copilot.png"
elif view == 'aft':  # looking aft from between the front seats at the rest area
    eye = d2b(6.55, 1.95, 0.0)
    tgt = d2b(5.60, 1.10, -0.10)
    lens = 14
    out = "/tmp/cockpit_aft.png"
else:  # top-down-ish overview from above the open cockpit
    eye = d2b(6.10, 3.60, -1.70)
    tgt = d2b(6.60, 1.10, 0.20)
    lens = 16
    out = "/tmp/cockpit_3q.png"

cam_d = bpy.data.cameras.new("C"); cam_d.lens = lens
cam_o = bpy.data.objects.new("C", cam_d); bpy.context.collection.objects.link(cam_o)
cam_o.location = eye
dirv = mathutils.Vector((tgt[0]-eye[0], tgt[1]-eye[1], tgt[2]-eye[2]))
cam_o.rotation_euler = dirv.to_track_quat('-Z', 'Y').to_euler()
sc.camera = cam_o

s = bpy.data.lights.new("S", type='SUN'); s.energy = 2.5
so = bpy.data.objects.new("S", s); bpy.context.collection.objects.link(so)
so.rotation_euler = (math.radians(50), 0, math.radians(30))

sc.render.filepath = out
bpy.ops.render.render(write_still=True)
print(">>> RENDERED", out)
