# B-2 Cockpit Blockout (source, not shipped)

This folder holds Blender *source* for a cockpit interior — it is not read by
DCS at runtime (DCS only loads `.EDM` files from `Shapes/`, and mounts that
folder directly). Nothing here needs to ship with the mod; it's raw material
for finishing the cockpit in Blender.

## Why this exists

`Shapes/B-2_Spirit.EDM` (the exterior model) contains no cockpit interior
geometry at all — no panel, no seats, no instruments, only the exterior
shell and a canopy glass material. `Cockpit/Scripts/mainpanel_init.lua`
currently points `shape_name` back at that same exterior-only file, so the
in-flight cockpit view is effectively empty. This blockout is a first pass
at real interior geometry to fix that.

## What's here

- `B2_Spirit_Cockpit_Blockout.blend` — Blender 4.x scene (~270 objects) with a
  detailed two-seat interior:
  - Main instrument panel (tilted) with an 8-MFD grid (recessed screens +
    bezels) and an upper strip of 6 round engine/fuel gauges with rings.
  - Glareshield/coaming and three windscreen posts framing the forward view.
  - Center pedestal with a CDU-style keypad (3x3 buttons) and a 4-lever
    throttle quadrant with grips.
  - Two front seats (pan, back, headrest, armrests), two control yokes with
    remove-before-flight flags, and two sets of rudder pedals.
  - Third-crew (relief) provisions in the aft cabin: a centered jump seat,
    a fold-down crew-rest bunk (mattress + pillow + grab rail), and a
    provisions locker / galley — matching the real B-2's crew-rest space
    for long-duration (30+ hour) sorties.
  - Left/right side consoles, floor, side walls and aft bulkhead (the shell
    is extended aft of the front seats to enclose the rest area).
  - Detail pass: line-select key rows around every MFD, a standby instrument
    cluster, a master-caution / annunciator strip on the coaming, an overhead
    switch-panel with three switch banks, side-console switch rows, and a
    center-pedestal comms/nav radio stack with knobs.
  - All edges beveled; per-part materials assigned (panel, trim, screen,
    bezel, seat, gauge, metal, flag). Still untextured/no UVs — it's a
    geometry+placement pass, not a finished art asset.
- `B2_Spirit_Cockpit_Blockout.fbx` — same scene, neutral interchange format,
  in case you want to bring it into another DCC without opening the .blend.
- `sanity_check_render.png` — render from the pilot's DCS eye point.
- `overview_render.png` — top-down 3/4 render showing the whole layout.
- `crew_rest_render.png` — view aft from the front seats toward the
  third-crew jump seat, bunk and provisions.

## Coordinates (important if you add/move geometry)

The scene is built directly in DCS's aircraft.lua units (meters), using the
exporter's own axis-conversion matrix (`math_tools.py:ROOT_TRANSFORM_MATRIX`
in the EDM exporter addon) so it lines up with `B-2 Spirit/B-2.lua`'s
`crew_members` positions and `Views.lua`'s `EyePoint` without any manual
re-alignment:

- Blender X = DCS X (forward, nose direction, +X)
- Blender Y = −DCS Z (DCS Z is right+, so Blender +Y is the aircraft's left)
- Blender Z = DCS Y (up)

Pilot seat is at DCS `(6.80, 1.85, -0.65)` → Blender `(6.80, 0.65, 1.85)`;
copilot mirrors it at DCS Z=+0.65. The relief jump seat is centered and aft
at DCS `(6.00, 1.70, 0.00)`. All three match `B-2.lua`'s `crew_members`
positions. The panel face sits at DCS X=7.45, i.e. 0.65m forward of the
front seats.

## What's left before this can actually export as `.EDM`

The real EDM binary writer (Eagle Dynamics' `io_scene_edm` addon) only works
on Windows — its serializer is a compiled `pyedm_31x.pyd` (a Windows DLL);
on any other OS the addon falls back to an intentional dummy stub and
refuses to export (`"couldn't proceed edm export because it's python dummy
plugin, not native."` — that's the addon's own error string). So finishing
this has to happen in Blender on Windows:

1. Install Blender 4.2 or 4.5 LTS (the addon's supported versions) and the
   official `io_scene_edm` addon from
   https://github.com/EagleDynamics/Blender-EDM-Exporter (Preferences →
   Add-ons → Install From Disk, using `edm_tools_blender_plugin.zip` from
   that repo's Releases).
2. Open `B2_Spirit_Cockpit_Blockout.blend`.
3. Replace/refine the blockout geometry as far as you want to take it —
   the boxes are placeholders, not a target shape.
4. Assign real EDM materials (the addon's "Update EDM Materials" button, or
   the node-editor "Add EDM Default/Glass Material" operators) to every
   object — plain Blender materials alone won't export correctly.
5. File → Export → Eagle Dynamics Model (.edm), save as
   `Shapes/B-2_Spirit_Cockpit.EDM`.
6. In `Cockpit/Scripts/mainpanel_init.lua`, change `shape_name` from
   `"B-2_Spirit"` to `"B-2_Spirit_Cockpit"` so the cockpit view uses the new
   interior instead of the exterior-only shell.
