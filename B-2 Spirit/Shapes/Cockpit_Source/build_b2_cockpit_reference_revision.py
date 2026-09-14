"""Build a public-reference-led B-2-inspired DCS cockpit art revision.

This is a visual modelling source file, not an assertion of non-public B-2
technical data.  Its panel proportions, screen arrangement, bezels, comms unit,
keypad, guarded lower-panel controls, glare shield, seats and control columns
are based only on the supplied public video captures and public USAF imagery.

The active display captions are deliberately generic or visibly legible in the
reference frames.  They are presentation placeholders for a simulation UI;
they do not recreate the aircraft's operational software or control laws.

Run from Blender 4.x:
    blender.exe --background --python build_b2_cockpit_reference_revision.py

It writes a standalone .blend and a render alongside this source.  It does not
require the DCS EDM exporter, and never overwrites the committed EDM.
"""

from __future__ import annotations

import math
from pathlib import Path

import bpy
from mathutils import Vector


SOURCE_DIR = Path(__file__).resolve().parent
OUTPUT_BLEND = SOURCE_DIR / "B2_Spirit_Cockpit_Reference_Revision.blend"
OUTPUT_RENDER = SOURCE_DIR / "B2_Spirit_Cockpit_Reference_Revision.png"


def reset_scene() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)


def material(name: str, color: tuple[float, float, float, float], *, metallic: float = 0.0,
             roughness: float = 0.5, emission: tuple[float, float, float, float] | None = None,
             emission_strength: float = 0.0) -> bpy.types.Material:
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    assert bsdf is not None
    bsdf.inputs["Base Color"].default_value = color
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission:
        bsdf.inputs["Emission Color"].default_value = emission
        bsdf.inputs["Emission Strength"].default_value = emission_strength
    return mat


def box(name: str, location: tuple[float, float, float], size: tuple[float, float, float],
        mat: bpy.types.Material, *, bevel: float = 0.0,
        parent: bpy.types.Object | None = None) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=location)
    obj = bpy.context.object
    assert obj is not None
    obj.name = name
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    if bevel:
        modifier = obj.modifiers.new("Edge radii", "BEVEL")
        modifier.width = bevel
        modifier.segments = 3
        modifier.limit_method = "ANGLE"
    if parent:
        obj.parent = parent
    return obj


def cylinder(name: str, location: tuple[float, float, float], radius: float, depth: float,
             mat: bpy.types.Material, *, rotation: tuple[float, float, float] = (math.pi / 2, 0, 0),
             parent: bpy.types.Object | None = None) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=radius, depth=depth, location=location,
                                        rotation=rotation)
    obj = bpy.context.object
    assert obj is not None
    obj.name = name
    obj.data.materials.append(mat)
    bevel = obj.modifiers.new("Soft edge", "BEVEL")
    bevel.width = min(radius * 0.22, 0.006)
    bevel.segments = 2
    if parent:
        obj.parent = parent
    return obj


def text(name: str, body: str, location: tuple[float, float, float], size: float,
         mat: bpy.types.Material, *, parent: bpy.types.Object | None = None,
         align: str = "CENTER") -> bpy.types.Object:
    curve = bpy.data.curves.new(name, "FONT")
    curve.body = body
    curve.align_x = align
    curve.align_y = "CENTER"
    curve.size = size
    curve.extrude = 0.001
    curve.resolution_u = 4
    obj = bpy.data.objects.new(name, curve)
    bpy.context.collection.objects.link(obj)
    obj.location = location
    # Text normally faces +Z; this turns it toward the seated crew at -Y.
    obj.rotation_euler = (math.pi / 2, 0, 0)
    curve.materials.append(mat)
    if parent:
        obj.parent = parent
    return obj


def face_camera(obj: bpy.types.Object, target: tuple[float, float, float]) -> None:
    direction = Vector(target) - obj.location
    obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


def build_mfd(root: bpy.types.Object, index: int, center: tuple[float, float, float],
              caption: str, screen_detail: str, materials: dict[str, bpy.types.Material]) -> None:
    """Build a four-sided bezel-key display based on the visible panel hardware."""
    x, y, z = center
    width, height = 0.58, 0.49
    screen_width, screen_height = 0.395, 0.315
    panel, bezel, screen, button, screw, green = (
        materials["panel"], materials["bezel"], materials["screen"], materials["button"],
        materials["screw"], materials["green"],
    )
    box(f"MFD_{index:02}_housing", (x, y, z), (width, 0.09, height), panel, bevel=0.018, parent=root)
    box(f"MFD_{index:02}_bezel", (x, y - 0.052, z), (0.49, 0.028, 0.40), bezel, bevel=0.012, parent=root)
    box(f"MFD_{index:02}_screen", (x, y - 0.070, z), (screen_width, 0.008, screen_height), screen,
        bevel=0.005, parent=root)

    # The capture has chunky, individually housed bezel keys.  Six per side
    # gives the correct read at DCS cockpit distance without pretending the
    # undocumented per-key functions are known.
    for side in (-1, 1):
        for i in range(6):
            button_z = z + (i - 2.5) * 0.058
            button_x = x + side * 0.255
            box(f"PNT_MFD{index:02}_{'R' if side > 0 else 'L'}_{i + 1:02}",
                (button_x, y - 0.078, button_z), (0.044, 0.026, 0.037), button,
                bevel=0.005, parent=root)
    for side in (-1, 1):
        for i in range(6):
            button_x = x + (i - 2.5) * 0.058
            button_z = z + side * 0.205
            box(f"PNT_MFD{index:02}_{'T' if side > 0 else 'B'}_{i + 1:02}",
                (button_x, y - 0.078, button_z), (0.037, 0.026, 0.042), button,
                bevel=0.005, parent=root)

    for dx, dz in ((-0.225, -0.17), (-0.225, 0.17), (0.225, -0.17), (0.225, 0.17)):
        cylinder(f"MFD_{index:02}_fastener_{dx:+.2f}_{dz:+.2f}",
                 (x + dx, y - 0.089, z + dz), 0.008, 0.010, screw, parent=root)

    # Visual-only generic content: green CRT-like strokes and the publicly
    # readable high-level system headings from the supplied frame.
    text(f"MFD_{index:02}_caption", caption, (x, y - 0.076, z + 0.115), 0.032, green, parent=root)
    text(f"MFD_{index:02}_detail", screen_detail, (x, y - 0.077, z - 0.020), 0.021, green, parent=root)
    for row in range(3):
        box(f"MFD_{index:02}_data_{row}", (x, y - 0.077, z - 0.080 - row * 0.035),
            (0.26 - row * 0.025, 0.004, 0.006), green, parent=root)


def build_radio_unit(root: bpy.types.Object, materials: dict[str, bpy.types.Material]) -> None:
    """Far-right communications/control display and keypad seen in the captures."""
    panel, bezel, screen, button, screw, green = (
        materials["panel"], materials["bezel"], materials["screen"], materials["button"],
        materials["screw"], materials["green"],
    )
    x, y, z = 1.18, 1.00, 1.12
    box("COMMS_UFD_housing", (x, y, z), (0.44, 0.10, 0.67), panel, bevel=0.018, parent=root)
    box("COMMS_UFD_bezel", (x, y - 0.056, z + 0.12), (0.35, 0.027, 0.31), bezel, bevel=0.01, parent=root)
    box("COMMS_UFD_screen", (x, y - 0.074, z + 0.12), (0.245, 0.008, 0.21), screen, bevel=0.004, parent=root)
    for side in (-1, 1):
        for row in range(4):
            box(f"PNT_COMMS_{'R' if side > 0 else 'L'}_{row + 1}",
                (x + side * 0.154, y - 0.080, z + 0.20 - row * 0.054),
                (0.033, 0.027, 0.032), button, bevel=0.004, parent=root)
    for row in range(4):
        for column in range(3):
            box(f"PNT_COMMS_KEY_{row + 1}_{column + 1}",
                (x - 0.075 + column * 0.075, y - 0.080, z - 0.145 - row * 0.052),
                (0.052, 0.027, 0.034), button, bevel=0.006, parent=root)
    for dx, dz in ((-0.18, 0.39), (0.18, 0.39), (-0.18, -0.28), (0.18, -0.28)):
        cylinder(f"COMMS_fastener_{dx:+.2f}_{dz:+.2f}", (x + dx, y - 0.090, z + dz), 0.008, 0.010,
                 screw, parent=root)
    text("COMMS_header", "COMMS", (x, y - 0.081, z + 0.20), 0.026, green, parent=root)
    text("COMMS_lines", "COMM 1   318.050\nCOMM 2   305.100\nHF       RADIO SET", (x, y - 0.082, z + 0.075),
         0.018, green, parent=root)


def build_lower_console(root: bpy.types.Object, materials: dict[str, bpy.types.Material]) -> None:
    """Sloped control group: fuel schematic, guarded control and selector keypad."""
    panel, trim, button, metal, red, amber, green = (
        materials["panel"], materials["trim"], materials["button"], materials["metal"],
        materials["red"], materials["amber"], materials["green"],
    )
    # This console faces upward and toward both crewmembers, as in the footage.
    console = box("Center_lower_console", (0.28, 0.10, 0.61), (1.35, 1.00, 0.18), panel, bevel=0.025, parent=root)
    console.rotation_euler.x = math.radians(-19)

    schematic = box("Fuel_control_schematic", (-0.17, 0.02, 0.73), (0.76, 0.40, 0.03), trim, bevel=0.012, parent=root)
    schematic.rotation_euler.x = math.radians(-19)
    for row in range(2):
        for col in range(5):
            knob = cylinder(f"PNT_FUEL_CTRL_{row + 1}_{col + 1}",
                            (-0.43 + col * 0.13, 0.0, 0.79 - row * 0.12), 0.025, 0.030, metal,
                            rotation=(math.radians(71), 0, 0), parent=root)
            knob.rotation_euler.z = math.radians((row * 19 + col * 37) % 90)
    text("Fuel_panel_title", "FUEL  /  CROSSFEED", (-0.17, -0.034, 0.90), 0.027, green, parent=root)

    # A safeguarded red control is visually prominent in the public frame.
    box("Guarded_control_base", (0.40, 0.03, 0.78), (0.20, 0.30, 0.04), trim, bevel=0.009, parent=root)
    guard = box("PNT_Guarded_control", (0.40, -0.09, 0.82), (0.055, 0.16, 0.10), red, bevel=0.012, parent=root)
    guard.rotation_euler.x = math.radians(-21)
    text("Guarded_control_label", "GUARDED", (0.40, -0.040, 0.70), 0.020, amber, parent=root)

    # Course / heading-selector keypad visible under the main display bank.
    keypad_x, keypad_z = 0.83, 0.76
    box("Selector_keypad_base", (keypad_x, 0.01, keypad_z), (0.35, 0.48, 0.04), trim, bevel=0.012, parent=root)
    for row in range(4):
        for col in range(3):
            box(f"PNT_SELECTOR_{row + 1}_{col + 1}",
                (keypad_x - 0.10 + col * 0.10, -0.035, keypad_z + 0.07 - row * 0.09),
                (0.062, 0.030, 0.052), button, bevel=0.007, parent=root)
    for offset, label in ((0.16, "CRS SEL"), (0.03, "HDG SEL")):
        cylinder(f"PNT_{label.replace(' ', '_')}", (1.08, -0.04, keypad_z + offset), 0.042, 0.033,
                 metal, rotation=(math.radians(71), 0, 0), parent=root)
    text("Selector_title", "BARO   CMD ALT", (keypad_x, -0.045, keypad_z + 0.21), 0.020, green, parent=root)


def build_seat(root: bpy.types.Object, side: int, materials: dict[str, bpy.types.Material]) -> None:
    """A readable ejection-seat silhouette; surface detailing stays generic."""
    x = side * 0.76
    seat, frame, fabric, yellow = materials["seat"], materials["frame"], materials["fabric"], materials["yellow"]
    box(f"Seat_{side}_pan", (x, -0.84, 0.58), (0.54, 0.56, 0.13), seat, bevel=0.035, parent=root)
    box(f"Seat_{side}_cushion", (x, -0.92, 0.69), (0.45, 0.42, 0.11), fabric, bevel=0.030, parent=root)
    back = box(f"Seat_{side}_back", (x, -1.12, 1.13), (0.52, 0.16, 0.77), seat, bevel=0.035, parent=root)
    back.rotation_euler.x = math.radians(-12)
    box(f"Seat_{side}_headrest", (x, -1.16, 1.60), (0.31, 0.16, 0.24), seat, bevel=0.04, parent=root)
    for sx in (-0.25, 0.25):
        cylinder(f"Seat_{side}_rail_{sx:+.2f}", (x + sx, -1.12, 1.14), 0.032, 0.82, frame,
                 rotation=(0, 0, 0), parent=root)
    # Yellow black-striped pull-ring is modeled only as a generic ejection-seat cue.
    cylinder(f"Seat_{side}_pull_ring", (x, -0.62, 0.48), 0.075, 0.025, yellow,
             rotation=(math.pi / 2, 0, 0), parent=root)


def build_control_column(root: bpy.types.Object, side: int, materials: dict[str, bpy.types.Material]) -> None:
    x = side * 0.55
    frame, grip, red = materials["frame"], materials["grip"], materials["red"]
    cylinder(f"Control_column_{side}", (x, -0.25, 0.66), 0.045, 0.46, frame,
             rotation=(0, 0, 0), parent=root)
    grip_obj = box(f"Control_grip_{side}", (x, -0.26, 0.94), (0.13, 0.18, 0.18), grip, bevel=0.035, parent=root)
    grip_obj.rotation_euler.x = math.radians(-10)
    box(f"PNT_control_trigger_{side}", (x, -0.37, 0.91), (0.045, 0.045, 0.055), red, bevel=0.012, parent=root)


def build_scene() -> None:
    reset_scene()

    materials = {
        "panel": material("Panel dark", (0.035, 0.043, 0.047, 1), metallic=0.12, roughness=0.67),
        "trim": material("Panel trim", (0.17, 0.20, 0.21, 1), metallic=0.35, roughness=0.43),
        "bezel": material("Display bezel", (0.018, 0.023, 0.026, 1), metallic=0.20, roughness=0.45),
        "screen": material("Unlit CRT glass", (0.002, 0.012, 0.006, 1), metallic=0.05, roughness=0.22,
                           emission=(0.004, 0.025, 0.008, 1), emission_strength=0.30),
        "button": material("Bezel key", (0.11, 0.125, 0.13, 1), metallic=0.10, roughness=0.42),
        "screw": material("Fastener", (0.36, 0.39, 0.40, 1), metallic=0.85, roughness=0.30),
        "metal": material("Control metal", (0.22, 0.25, 0.27, 1), metallic=0.82, roughness=0.32),
        "green": material("CRT phosphor", (0.14, 0.95, 0.30, 1), roughness=0.28,
                            emission=(0.08, 1.0, 0.20, 1), emission_strength=4.5),
        "red": material("Guard red", (0.50, 0.015, 0.012, 1), metallic=0.15, roughness=0.38,
                        emission=(0.22, 0.0, 0.0, 1), emission_strength=0.4),
        "amber": material("Amber label", (0.95, 0.45, 0.03, 1), roughness=0.35,
                          emission=(1.0, 0.20, 0.0, 1), emission_strength=1.4),
        "seat": material("Seat shell", (0.055, 0.062, 0.058, 1), metallic=0.12, roughness=0.75),
        "frame": material("Seat and stick frame", (0.06, 0.07, 0.07, 1), metallic=0.64, roughness=0.36),
        "fabric": material("Seat fabric", (0.11, 0.12, 0.10, 1), roughness=0.92),
        "yellow": material("Safety yellow", (1.0, 0.58, 0.03, 1), metallic=0.05, roughness=0.40),
        "grip": material("Control grip", (0.018, 0.024, 0.025, 1), roughness=0.85),
    }

    root = bpy.data.objects.new("B2_Cockpit_PublicReference_Root", None)
    root["provenance"] = "PUBLIC_VISUAL_REFERENCE_ONLY"
    root["design_note"] = "Geometry is reference-led; display logic is simulation abstraction."
    bpy.context.collection.objects.link(root)

    # Cabin shell and instrumental panel: a single shared bank rather than
    # two invented full duplicate stations.
    box("Cockpit_floor", (0, -0.25, 0.18), (3.15, 3.35, 0.12), materials["panel"], bevel=0.025, parent=root)
    box("Cockpit_left_wall", (-1.58, -0.25, 1.25), (0.12, 3.2, 2.15), materials["panel"], bevel=0.025, parent=root)
    box("Cockpit_right_wall", (1.58, -0.25, 1.25), (0.12, 3.2, 2.15), materials["panel"], bevel=0.025, parent=root)
    box("Main_panel_backing", (0.0, 1.10, 1.36), (2.95, 0.17, 1.85), materials["trim"], bevel=0.055, parent=root)
    box("Main_panel_face", (0.0, 0.995, 1.40), (2.74, 0.09, 1.69), materials["panel"], bevel=0.045, parent=root)
    box("Glareshield", (0.0, 0.74, 2.24), (2.95, 0.58, 0.16), materials["bezel"], bevel=0.055, parent=root)
    for i in range(12):
        box(f"Glareshield_switch_{i + 1:02}", (-1.17 + i * 0.21, 0.53, 2.20),
            (0.075, 0.050, 0.055), materials["button"], bevel=0.010, parent=root)

    # Only the visual screen clusters observable in the frames are expressed.
    build_mfd(root, 1, (-0.39, 0.93, 1.70), "FUEL  FCS  ELEC", "ECS    ENG", materials)
    build_mfd(root, 2, (0.31, 0.93, 1.70), "FLT / ATT", "PFD", materials)
    build_mfd(root, 3, (-0.39, 0.93, 1.08), "NAV", "COURSE / DATA", materials)
    build_mfd(root, 4, (0.31, 0.93, 1.08), "STATUS", "SYSTEM MATRIX", materials)
    build_radio_unit(root, materials)
    build_lower_console(root, materials)

    for side in (-1, 1):
        build_seat(root, side, materials)
        build_control_column(root, side, materials)
    # A compact throttle pedestal is visually useful without representing a
    # specific engine-control arrangement as authentic.
    box("Throttle_pedestal", (0, -0.38, 0.59), (0.38, 0.82, 0.34), materials["panel"], bevel=0.04, parent=root)
    for side in (-0.075, 0.075):
        cylinder(f"PNT_throttle_{side:+.2f}", (side, -0.31, 0.90), 0.030, 0.42, materials["metal"],
                 rotation=(0, 0, math.radians(-20)), parent=root)
        box(f"Throttle_grip_{side:+.2f}", (side, -0.35, 1.08), (0.11, 0.09, 0.055), materials["grip"],
            bevel=0.018, parent=root)

    # Soft daylight through an open placeholder canopy and a low cockpit fill.
    world = bpy.context.scene.world or bpy.data.worlds.new("World")
    bpy.context.scene.world = world
    world.use_nodes = True
    bg = world.node_tree.nodes.get("Background")
    assert bg is not None
    bg.inputs["Color"].default_value = (0.015, 0.022, 0.030, 1)
    bg.inputs["Strength"].default_value = 0.20
    key = bpy.data.lights.new("Daylight", "AREA")
    key.energy = 900
    key.shape = "RECTANGLE"
    key.size = 3.2
    key.size_y = 1.5
    key_obj = bpy.data.objects.new("Daylight", key)
    bpy.context.collection.objects.link(key_obj)
    key_obj.location = (0, -0.4, 3.45)
    key_obj.rotation_euler = (math.radians(22), 0, 0)
    fill = bpy.data.lights.new("Panel_fill", "AREA")
    fill.energy = 70
    fill.color = (0.38, 0.55, 0.48)
    fill.size = 1.8
    fill_obj = bpy.data.objects.new("Panel_fill", fill)
    bpy.context.collection.objects.link(fill_obj)
    fill_obj.location = (0, -0.30, 1.8)
    fill_obj.rotation_euler = (math.radians(-90), 0, 0)

    camera_data = bpy.data.cameras.new("Pilot reference camera")
    camera_data.lens = 27
    camera = bpy.data.objects.new("Pilot reference camera", camera_data)
    bpy.context.collection.objects.link(camera)
    # This is ahead of the left-seat backrest, matching a pilot eye point
    # rather than an exterior observer looking through the seat.
    camera.location = (-0.55, -0.58, 1.52)
    face_camera(camera, (0.02, 0.86, 1.40))
    bpy.context.scene.camera = camera

    scene = bpy.context.scene
    scene.render.engine = "BLENDER_EEVEE_NEXT"
    scene.render.resolution_x = 1600
    scene.render.resolution_y = 1000
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.filepath = str(OUTPUT_RENDER)
    scene.render.film_transparent = False
    scene.view_settings.look = "AgX - Medium High Contrast"
    scene["reference_status"] = "PUBLIC_GEOMETRY_REFERENCE; SIMULATION_UI_ABSTRACTION"

    bpy.ops.wm.save_as_mainfile(filepath=str(OUTPUT_BLEND))
    bpy.ops.render.render(write_still=True)
    print(f"Saved: {OUTPUT_BLEND}")
    print(f"Rendered: {OUTPUT_RENDER}")


if __name__ == "__main__":
    build_scene()
