# Phase 5 — thirteen-frame audit revision

Run `build_b2_phase5.py` once in Blender 4.2 using Scripting > Open > Run Script.
It is standalone and needs no exporter. It creates a new scene, preserving the
open scene, and saves `B2_DCS_Cockpit_Phase5_Audit.blend`, a PNG overview and a
JSON provenance/menu manifest beside the script. Re-running creates another
scene and replaces those generated output files.

The original ChatGPT Phase 5 download was not present in this checkout or
Downloads. This replacement entry point uses the local reference revision's
primitive helpers and rebuilds the audited instrument architecture; it is not
a line-by-line patch of the unavailable original script.

Changes include square recessed MDUs with five generic keys on each edge,
three upper MDUs and navigation below per station, a distinct probable CID,
starboard CDU with named mode keys, the BARO/CMD ALT/RALT SET/A/S SET keypad,
CRS SEL/HDG SEL knobs, guarded gear hardware and layered centre controls.
The top-level menu strings and FCH > HYD/FCS relationship are stored as metadata.
No frequencies, acronym expansions or unseen operational pages are invented.

Hardware, static page artwork, render anchors and hidden click meshes are
separate. Click meshes carry stable control IDs but no runtime bindings.
Select the corresponding PAGE_PREVIEW empty and its descendants to replace
static MDU artwork with a future DCS render surface.

Limitations: dimensions, depth, opposite-station duplication, shell, seats,
throttles and mechanical control populations remain estimates. The CID
identification is inferred. This is a geometry review asset, not a finished
DCS cockpit or an exterior-aligned export. Local axes: X right, Y forward,
Z up, metres. Existing DCS Lua and EDM assets are not changed.

Validation built into the generator checks eight MDUs, 160 bezel click targets
and unique control IDs. The PNG provides a front overview for visual review.
